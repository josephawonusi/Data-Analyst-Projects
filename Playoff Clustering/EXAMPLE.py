from nba_api.stats.endpoints import leaguedashteamstats, playoffpicture
import pandas as pd

# Function to get team stats for a given season
def get_team_stats(season):
    stats = leaguedashteamstats.LeagueDashTeamStats(season=season)
    stats_df = stats.get_data_frames()[0]
    return stats_df

# Collect data for multiple seasons
seasons = ['2010-11', '2011-12', '2012-13', '2013-14', '2014-15', '2015-16', '2016-17', '2017-18', '2018-19', '2019-20', '2020-21', '2021-22']
data = pd.concat([get_team_stats(season) for season in seasons], keys=seasons)

# Reset index and clean data
data.reset_index(level=0, inplace=True)
data.rename(columns={'level_0': 'SEASON'}, inplace=True)

# Function to get playoff picture for a given season
def get_playoff_picture(season):
    teams = playoffpicture.PlayoffPicture(season_id=season)
    east_teams_df = teams.get_data_frames()[2]
    east_teams_df = east_teams_df[['TEAM_ID', 'CLINCHED_PLAYOFFS']]
    west_teams_df = teams.get_data_frames()[3]
    west_teams_df = west_teams_df[['TEAM_ID', 'CLINCHED_PLAYOFFS']]
    pl_teams_df = pd.concat([east_teams_df, west_teams_df])
    pl_teams_df['SEASON'] = str(int(season[1:]) - 1) + "-" + str(season[-2:])
    return pl_teams_df

seasons_2 = ["22011", "22012", "22013", "22014", "22015", "22016", "22017", "22018", "22019", "22020", "22021", "22022"]
pl_df = pd.concat([get_playoff_picture(season) for season in seasons_2])

# Merge with data
data = data.merge(pl_df, on=["TEAM_ID", "SEASON"])

# Preprocessing steps
data = data.fillna(0)
data = pd.get_dummies(data, columns=['SEASON'])
