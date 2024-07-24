# NBA API Data Ingestion with Requests

## Overview

This project involves the extraction of NBA data using the NBA API (https://rapidapi.com/api-sports/api/api-nba) with the 'requests' and 'pandas' libraries. Additionally, information on the last 10 NBA champions is scraped from Wikipedia using 'BeautifulSoup'. The goal is to gather and process data for analysis and visualization.

## Project Structure

- **API Key and Host:**
  - API_KEY and API_HOST are required for accessing the NBA API. Ensure they are provided before running the code.

- **Notebook Contents:**
  - **1. NBA API Data Retrieval:**
    - Utilizes 'requests' and 'json_normalize' to obtain NBA player and team data.
    - Exports NBA team data to 'nba_teams.csv'.

  - **2. Wikipedia Data Scraping:**
    - Uses 'BeautifulSoup' to scrape NBA champions' data from Wikipedia.
    - Cleans and formats the data, exporting it to 'last_ten_champs.csv'.

  - **3. Data Cleaning and Transformation:**
    - Processes the DataFrame for the last 10 NBA champions.
    - Determines the winner of each series and creates a 'NBA Champion' column.
    - Drops irrelevant columns and exports the cleaned data.
## File Descriptions

- `NBA_API_Data_Ingestion.ipynb`: Jupyter Notebook containing the project code.
- `nba_teams.csv`: CSV file containing NBA team data.
- `last_ten_champs.csv`: CSV file with cleaned data on the last 10 NBA champions.

## Acknowledgments

- NBA API: [API Sports](https://rapidapi.com/api-sports/api/api-nba)
- Wikipedia: [List of NBA champions](https://en.wikipedia.org/wiki/List_of_NBA_champions)
  

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
## Environment
Python 3.10 or above

## Getting Started

1. Install the required libraries:

   ```bash
   pip install requests pandas beautifulsoup4 html5lib
   ```

2. Set up the necessary API_KEY and API_HOST for NBA API access.

3. Run the Jupyter Notebook: `NBA_API_Data_Ingestion.ipynb`.

---

Feel free to add or modify sections based on additional project details or specific instructions for users.
