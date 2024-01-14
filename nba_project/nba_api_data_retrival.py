import pandas as pd
from pandas import json_normalize
import requests
from bs4 import BeautifulSoup
import html
import html5lib

# Send GET request to the API endpoint

API_KEY =   API_KEY
API_HOST =  API_HOST

url = "https://api-nba-v1.p.rapidapi.com/players"

querystring = {"team":"1","season":"2022", "team":"17"}

headers = {
	"X-RapidAPI-Key": API_KEY,
	"X-RapidAPI-Host": API_HOST
}

response = requests.get(url, headers=headers, params=querystring)

print(response.json())


# Assign API request to a variable
response_data = response.json()['response']

# Use json_normalize for nested JSON structure
teams_df = json_normalize(response_data)

# Get Team IDs
url = "https://api-nba-v1.p.rapidapi.com/teams"

headers = {
	"X-RapidAPI-Key": API_KEY,
	"X-RapidAPI-Host": API_HOST
}

response = requests.get(url, headers=headers)

# Convert to dataframe
teams_df = pd.json_normalize(response.json()['response'])

# Filter to NBA teams
teams_df = teams_df[teams_df['nbaFranchise'] == True]

# Iterate through years from 2013 to 2023
while start_year < 2024:
    # Current year for API request
    year = start_year
    
    # Move to the next year
    start_year += 1
    
    # Get the team ID for the champion of the current year
    get_id = champ_ids[champ_ids['Year'] == year]['id']
    
    # API endpoint for team statistics
    url = "https://api-nba-v1.p.rapidapi.com/teams/statistics"

    # Query parameters for the API request
    querystring = {"id": get_id, "season": year}

    # Headers for the API request
    headers = {
        "X-RapidAPI-Key": API_KEY,
        "X-RapidAPI-Host": API_HOST
    }

    # Send the API request and get the response
    response = requests.get(url, headers=headers, params=querystring)

    # Normalize the JSON response and concatenate it with the existing champion team season stats
    champ_team_season_stats = pd.concat([champ_team_season_stats, pd.json_normalize(response.json()['response'])])


# Scrape wikipedia data

# Wikipedia URL
wiki_url = 'https://en.wikipedia.org/wiki/List_of_NBA_champions'

# Send a GET request to the URL
response = requests.get(wiki_url)

# Check if the request was successful (status code 200)
if response.status_code == 200:
    # Parse the HTML content of the page
    soup = BeautifulSoup(response.content, 'html.parser')

    # Find the table you want to scrape (you may need to inspect the page source to identify the correct table)
    table = soup.find('table', {'class': 'wikitable sortable sticky-header'})

    # Use pandas to read the HTML table into a DataFrame
    champs_df = pd.read_html(str(table))[0]
    
    # Remove data that's not required in the table.
    champs_df = champs_df[50:].reset_index(drop=True)
    champs_df['Year'] = champs_df['Year'].str.replace(r'\[.\]', '', regex=True).astype(int)
    # Print the DataFrame
    print(champs_df.head())
else:
    print('Failed to retrieve the page. Status code:', response.status_code)

    champs_df = champs_df[50:]


# CLEAN UP THE DATA
# Get the NBA champs of the last 10 years
last_ten_champs = champs_df[champs_df['Year'].astype(int) >= 2013].reset_index(drop=True)

# Clean the name of western champions
last_ten_champs['Western champion'] = last_ten_champs['Western champion'].str.split(' \(')
# Use apply to extract the first item from each list
last_ten_champs['Western champion'] = \
    last_ten_champs['Western champion'].apply(lambda x: x[0] if isinstance(x, list) 
                                              and len(x) > 0 else None)

# Clean the name of the eastern champions
last_ten_champs['Eastern champion'] = last_ten_champs['Eastern champion'].str.split(' \(')
# Use apply to extract the first item from each list
last_ten_champs['Eastern champion'] = \
    last_ten_champs['Eastern champion'].apply(lambda x: x[0] if isinstance(x, list) 
                                              and len(x) > 0 else None)


# Keep only the winner
# Split result into two columns
last_ten_champs[['West Result', 'East Result']] = last_ten_champs['Result'].str.split('–')\
                                                                            .apply(pd.Series)
# Keep only the winner of the series
last_ten_champs['NBA Champion'] = ""
last_ten_champs.loc[last_ten_champs['West Result'] > last_ten_champs['East Result'], 
                'NBA Champion'] = last_ten_champs['Western champion']
last_ten_champs.loc[last_ten_champs['West Result'] < last_ten_champs['East Result'], 
                'NBA Champion'] = last_ten_champs['Eastern champion']

# Drop Irrelevant columns
last_ten_champs.drop(columns=['Reference', 'Coach', 'Coach.1'], inplace=True)


# Get team ids
team_ids = teams_df[['id','name']]

# Let the IDs of the last ten champs
champ_ids = last_ten_champs.merge(team_ids, left_on='NBA Champion', right_on='name', how='left')
champ_ids = champ_ids[['id','name', 'Year']]

# Starting year for collecting champion team season stats
start_year = 2013

# Initialize an empty DataFrame to store champion team season stats
champ_team_season_stats = pd.DataFrame()

# Export datasets
teams_df.to_csv('nba_teams.csv')
last_ten_champs.to_csv('last_ten_champs.csv', index=False)
champ_team_season_stats.to_csv('champ_team_season_stats.csv')