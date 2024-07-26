USE [Project]
GO

-- 1. Get the number of games played
SELECT COUNT(*) as 'number_of_games'
FROM [dbo].[linchess];

-- 2. What is the distribution of game ratings in the dataset?
SELECT AVG(ABS(white_rating - black_rating)) as avg_rating_diff,
	ROUND(STDEV(ABS(white_rating - black_rating)),0) as stdev_rating_diff
FROM [dbo].[linchess]; 
GO -- Avgerage difference 173 Points, STD 179 points


-- 3. What percentage of games does the weaker player win?
SELECT COUNT(*) AS 'underdog_wins',  (COUNT(*)*100/(SELECT COUNT(*) from linchess)) AS 'underdog_percentage'
FROM linchess
WHERE (winner = 'black' AND black_rating < white_rating) OR (winner = 'white' AND white_rating < black_rating)
GO
-- 32%

-- 4. How does the average number of turns vary between rated and unrated games?
SELECT ROUND(AVG(turns),0) as 'avg_turns', rated
FROM linchess
GROUP BY rated
GO

-- 5. What are the most common time increments used in the dataset?
SELECT TOP 5 COUNT(increment_code) as 'increment_code_count', increment_code
FROM linchess
GROUP BY increment_code
ORDER BY increment_code_count DESC
GO -- 10+0, 15+0, 15+15, 5+5, 5+8

-- 7. Can you identify any patterns in the opening moves that lead to shorter or longer games?
SELECT opening_name, AVG(turns) as avg_turns, COUNT(opening_name) as 'opening_count'
FROM linchess
GROUP BY opening_name
HAVING COUNT(opening_name) > 2	-- Removing unique openings
ORDER BY opening_count DESC, avg_turns 
GO

-- 8. What is the distribution of game outcomes (winner) in the dataset?
SELECT winner, COUNT(winner) as 'win_count', 
	CAST(COUNT(winner)*100.0/(SELECT COUNT(*) FROM linchess) AS DECIMAL(4,2)) as 'win_perc'
FROM linchess
GROUP BY winner
GO

-- 9. Is there a correlation between the time increment and the game outcome?
SELECT increment_code, winner, COUNT(winner) as 'winner_count'
FROM linchess
GROUP BY increment_code, winner
ORDER BY increment_code, winner_count DESC
GO
	-- What side has the most wins based on time increment?
WITH WinnerCounts AS (
    SELECT increment_code, winner, COUNT(winner) AS winner_count
    FROM linchess
    GROUP BY increment_code, winner
)
SELECT increment_code, 
       MAX(winner_count) AS max_winner_count, winner,
       FIRST_VALUE(winner) 
	   OVER (
			PARTITION BY increment_code 
			ORDER BY winner_count DESC
			)	AS side_with_max_wins
FROM WinnerCounts
GROUP BY increment_code, winner_count, winner
ORDER BY increment_code;
GO

-- 10.How has the popularity of openings changed over time (based on start time)?
-- Convert to datetime
SELECT TOP 10 LEFT(created_at,11), LEFT(last_move_at, 8)
FROM linchess

UPDATE linchess
SET new_created_at = DATEADD(DAY, CONVERT(BIGINT, created_at), '19000101');

SELECT TOP 10 created_at, new_created_at
FROM linchess;



SELECT CONVERT(DATE, LEFT(created_at, 8))
FROM linchess

SELECT CAST(CAST(created_at) as char(8)) AS DATE) as created_as_dt,
	   CAST(CAST(last_move_at AS CHAR(8)) AS DATE) AS last_move_at_dt
FROM linchess

-- 11. Analyse player progession over time
SELECT player_id,
	COUNT(*) AS total_games,
	SUM(CASE WHEN (winner = 'white' AND white_id = player_id) OR (winner = 'white' AND black_id = player_id) THEN 1 ELSE 0 END) AS wins,
	SUM(CASE WHEN (winner = 'black' AND white_id = player_id) OR (winner = 'black' AND black_id = player_id) THEN 1 ELSE 0 END) AS losses,
	SUM(CASE WHEN winner  = 'draw' THEN 1 ElSE 0 END) AS draws,
	ROUND(AVG(white_rating), 2) AS average_rating,
	DATEADD(MONTH, DATEDIFF(MONTH,  0, created_date), 0) AS month
FROM( SELECT *
		FROM (SELECT *, white_id as player_id
		FROM linchess
		UNION ALL
		SELECT *, black_ID as player_id
		FROM linchess) games
		) id_table
WHERE rated = 'TRUE'
GROUP BY 
    player_id, DATEADD(MONTH, DATEDIFF(MONTH,  0, created_date), 0)
ORDER BY 
    player_id, month;

-- Create table with player_id key which who will either be playing white or black.
SELECT *,
    CASE 
        WHEN (winner = 'white' AND white_id = player_id) OR (winner = 'black' AND black_id = player_id) THEN 'win'
        WHEN (winner = 'black' AND white_id = player_id) OR (winner = 'white' AND black_id = player_id) THEN 'lose'
        WHEN winner = 'draw' THEN 'draw'
        ELSE 'unknown' -- Optional: handle cases where the winner value is neither 'white', 'black', nor 'draw'
    END AS result,
	CASE
		WHEN white_id = player_id THEN white_rating
		WHEN black_id = player_id THEN black_rating
		END AS rating
INTO id_table
FROM (
    SELECT *, white_id AS player_id
    FROM linchess
    UNION ALL
    SELECT *, black_id AS player_id
    FROM linchess
) games;

-- 11. Calculate the running total of wins for each player.

SELECT 
    player_id,
    created_date,
    result,
    SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) OVER (PARTITION BY player_id ORDER BY created_date) AS running_total_wins
FROM id_table
ORDER BY 
    player_id, created_date;

-- 12. Analyze player progression through different rating levels.
WITH RatingLevels AS (
    SELECT
        player_id,
        rating,
        created_date,
        100 AS level
    FROM 
        id_table
    WHERE 
        rating < 2500
    UNION ALL
    SELECT
        g.player_id,
        g.rating,
        g.created_date,
        rl.level + 100
    FROM 
        id_table g
    JOIN 
        RatingLevels rl ON g.player_id = rl.player_id AND g.rating >= rl.rating AND g.created_date > rl.created_date
)
SELECT 
    player_id,
    MAX(level) AS max_level
FROM 
    RatingLevels
GROUP BY 
    player_id
ORDER BY 
    max_level DESC;

-- 13. Optimise the data to speed up queries
-- Create indexes on frequently queried columns to speed up query performance.
CREATE INDEX idx_player_id ON id_table(player_id);
CREATE INDEX idx_game_date ON id_table(created_date);

-- Create a partition function
CREATE PARTITION FUNCTION pfYearRange (DATE)
AS RANGE LEFT FOR VALUES ('2015-01-01', '2016-01-01', '2017-01-01', '2018-01-01');

-- Create a partition scheme
CREATE PARTITION SCHEME psYearRange
AS PARTITION pfYearRange
ALL TO ([PRIMARY]);

-- Create the partitioned table
CREATE TABLE partitioned_games (
    player_id INT,
    rating INT,
    created_date DATE,
    result VARCHAR(10)
)
ON psYearRange (created_date);


-- 14. Create the stored procedure for generating player performance reports
CREATE PROCEDURE PlayerPerformanceReport
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SELECT player_id,
        COUNT(*) AS total_games,
        SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS wins,
        SUM(CASE WHEN result = 'lose' THEN 1 ELSE 0 END) AS losses,
        SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS draws,
        ROUND(AVG(CAST(rating AS FLOAT)), 2) AS average_rating
    FROM id_table
    WHERE created_date BETWEEN @start_date AND @end_date
    GROUP BY player_id
    ORDER BY wins DESC;
END;

-- Execute the stored procedure with specified date range
EXEC PlayerPerformanceReport @start_date = '2017-01-01', @end_date = '2017-12-31';

-- 15. Create view to simplify access to complex data.
CREATE VIEW PlayerMonthlyPerformance AS
SELECT player_id,
    COUNT(*) AS total_games,
    SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN result = 'loss' THEN 1 ELSE 0 END) AS losses,
	SUM(CASE WHEN result = 'draw' THEN 1 ELSE 0 END) AS draws,
    ROUND(AVG(rating), 2) AS average_rating,
    DATEADD(MONTH, DATEDIFF(MONTH,  0, created_date), 0) AS month
FROM id_table
GROUP BY player_id,  DATEADD(MONTH, DATEDIFF(MONTH,  0, created_date), 0);


SELECT TOP 100 *
FROM PlayerMonthlyPerformance