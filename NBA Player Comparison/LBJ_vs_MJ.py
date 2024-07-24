from nba_api.stats.endpoints import playercareerstats, teamplayerdashboard
from nba_api.stats.static import players, teams
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Function to get player ID
def get_player_id(player_name):
    player_dict = players.find_players_by_full_name(player_name)
    return player_dict[0]['id']

# Function to get team ID by abbreviation
def get_team_id(team_abbreviation):
    team_dict = teams.find_team_by_abbreviation(team_abbreviation)
    return team_dict['id']

# Function to get player stats for the last 10 seasons
def get_last_10_seasons_stats(player_id):
    career = playercareerstats.PlayerCareerStats(player_id=player_id)
    career_df = career.get_data_frames()[0]
    # Sort by season_id to get the last 10 seasons
    career_df = career_df.sort_values(by='SEASON_ID', ascending=False).head(10)
    # Create 'YEAR' column representing the number of years the player has played
    career_df['YEAR'] = range(1, len(career_df) + 1)
    return career_df

# Function to get teammate stats for a specific season
def get_teammate_stats(season, team_id):
    team_dashboard = teamplayerdashboard.TeamPlayerDashboard(team_id=team_id, season=season)
    teammate_stats = team_dashboard.get_data_frames()[1]  # Get Player Totals
    return teammate_stats

# Calculate advanced metrics
def calculate_advanced_metrics(df):
    df['TS%'] = df['PTS'] / (2 * (df['FGA'] + 0.44 * df['FTA']))
    # Simplified PER calculation for demonstration
    df['PER'] = (df['PTS'] + df['REB'] + df['AST'] + df['STL'] + df['BLK']) / df['GP']
    return df

# Get LeBron James' stats
lebron_id = get_player_id("LeBron James")
lebron_stats = get_last_10_seasons_stats(lebron_id)
lebron_stats = calculate_advanced_metrics(lebron_stats)

# Get Michael Jordan's stats
jordan_id = get_player_id("Michael Jordan")
jordan_stats = get_last_10_seasons_stats(jordan_id)
jordan_stats = calculate_advanced_metrics(jordan_stats)

# Function to compare player stats against their teammates
def compare_against_teammates(player_stats, player_name):
    comparison_list = []

    for i, row in player_stats.iterrows():
        season = row['SEASON_ID']
        team_id = get_team_id(row['TEAM_ABBREVIATION'])
        teammates = get_teammate_stats(season, team_id)
        teammates = calculate_advanced_metrics(teammates)
        
        # Exclude the player from the teammate stats
        teammates = teammates[teammates['PLAYER_ID'] != row['PLAYER_ID']]
        
        avg_teammates = teammates[['PTS', 'AST', 'REB', 'PER']].mean()
        
        comparison_list.append({
            'YEAR': row['YEAR'],
            'PLAYER_NAME': player_name,
            'PTS': row['PTS'],
            'AST': row['AST'],
            'REB': row['REB'],
            'PER': row['PER'],
            'TEAM_PTS': avg_teammates['PTS'],
            'TEAM_AST': avg_teammates['AST'],
            'TEAM_REB': avg_teammates['REB'],
            'TEAM_PER': avg_teammates['PER']
        })
    
    return pd.DataFrame(comparison_list)

# Compare LeBron James against his teammates
lebron_comparison = compare_against_teammates(lebron_stats, "LeBron James")

# Compare Michael Jordan against his teammates
jordan_comparison = compare_against_teammates(jordan_stats, "Michael Jordan")

# Combine the comparisons into one DataFrame
comparison_df = pd.concat([lebron_comparison, jordan_comparison])

# Plotting the comparisons
def plot_comparison(df, stat):
    plt.figure(figsize=(14, 7))
    
    # LeBron James
    lbj_df = df[df['PLAYER_NAME'] == "LeBron James"]
    plt.plot(lbj_df['YEAR'], lbj_df[stat], marker='o', label="LeBron James")
    plt.plot(lbj_df['YEAR'], lbj_df[f'TEAM_{stat}'], marker='x', linestyle='--', label="LeBron's Teammates")
    
    # Michael Jordan
    mj_df = df[df['PLAYER_NAME'] == "Michael Jordan"]
    plt.plot(mj_df['YEAR'], mj_df[stat], marker='o', label="Michael Jordan")
    plt.plot(mj_df['YEAR'], mj_df[f'TEAM_{stat}'], marker='x', linestyle='--', label="Jordan's Teammates")
    
    plt.xlabel('Year')
    plt.ylabel(stat)
    plt.title(f'{stat} Comparison - Player vs Teammates')
    plt.legend()
    plt.grid(True)
    plt.show()

# Plot the comparisons
plot_comparison(comparison_df, 'PTS')
plot_comparison(comparison_df, 'AST')
plot_comparison(comparison_df, 'REB')
plot_comparison(comparison_df, 'PER')

# Save the comparison data to a CSV file
comparison_df.to_csv('comparison_stats.csv', index=False)
