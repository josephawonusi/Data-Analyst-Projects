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
SELECT CONVERT(DATE, LEFT(created_at, 8))
FROM linchess

SELECT CAST(CAST(created_at) as char(8)) AS DATE) as created_as_dt,
	   CAST(CAST(last_move_at AS CHAR(8)) AS DATE) AS last_move_at_dt
FROM linchess

--What is the average rating difference between white and black players?
--Are there certain openings that tend to favor one color over the other?
--How does the average number of moves in the opening phase (opening ply) correlate with game outcome?
--What are the most common checkmates in the dataset?
--Is there a relationship between the opening chosen and the players' ratings?
--How does the distribution of game outcomes differ between rated and unrated games?
--Are there any noticeable trends in the start times of games (e.g., time of day, day of the week)?
--What is the average duration of games in terms of start and end times?
--Can you identify any outliers in terms of game length or rating differences?
--How does the distribution of opening ECO codes vary across different player ratings?