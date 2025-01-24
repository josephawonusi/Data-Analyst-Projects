# LinChess Data Analysis Project

This project contains SQL scripts and stored procedures to analyze and report player performance in a chess dataset stored in an MS SQL Server database. The dataset is from the `linchess` table, which includes game records with details such as player IDs, game results, and timestamps.

## Project Structure

- **linchess_query.sql**: SQL script to create and populate tables, define partitions, and create stored procedures for generating player performance reports.

## Table of Contents

- [Setup](#setup)
- [Power Bi Dasheboard](#dashboard#)
- [Tables](#tables)
- [Stored Procedures](#stored-procedures)
- [Usage](#usage)

## Power BI Dashboard
### Rating Difference
![image](https://github.com/user-attachments/assets/2f9dcf47-3103-4242-bb64-d03f36d17f18)
### Player Rating
![image](https://github.com/user-attachments/assets/2f350152-06e2-4103-8853-8918f13b9089)

## Setup

1. Ensure you have MS SQL Server installed and running.
2. Create a new database or use an existing one.
3. Run the `linchess_query.sql` script to create the necessary tables and stored procedures.

## Tables

### `linchess`

The primary table containing chess game records. Columns include:
- `created_at`: The timestamp of the game in char(15) format.
- `white_id`: The ID of the white player.
- `black_id`: The ID of the black player.
- `winner`: The result of the game (e.g., 'white', 'black', 'draw').

### `id_table`

A derived table containing:
- `player_id`: Consolidated player ID from `white_id` and `black_id`.
- `rating`: Player rating.
- `created_date`: The game date converted from `created_at`.
- `result`: The result of the game for the player ('win', 'lose', 'draw').

### `partitioned_games`

A partitioned table for efficient querying based on the year of the game date. Columns include:
- `player_id`: Player ID.
- `rating`: Player rating.
- `created_date`: The game date.
- `result`: The result of the game for the player ('win', 'lose', 'draw').

## Stored Procedures

### `PlayerPerformanceReport`

Generates a performance report for players within a specified date range.

#### Parameters
- `@start_date` (DATE): The start date for the report.
- `@end_date` (DATE): The end date for the report.

#### Output
- `player_id`: Player ID.
- `total_games`: Total number of games played.
- `wins`: Number of games won.
- `losses`: Number of games lost.
- `draws`: Number of games drawn.
- `average_rating`: Average rating of the player.

## Usage

1. Execute the stored procedure to generate the report:

    ```sql
    EXEC PlayerPerformanceReport @start_date = '2023-01-01', @end_date = '2023-12-31';
    ```

2. Review the output to analyze player performance over the specified date range.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## Acknowledgements

Thanks to the contributors and the community for their valuable input and support.
