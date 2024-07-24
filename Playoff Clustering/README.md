# NBA Playoff Prediction

This project aims to predict NBA playoff appearances based on historical team statistics. By leveraging the `nba_api`, we collect and process data to build a predictive model.

## Project Overview

The project involves several key steps:
1. Collecting team statistics for multiple NBA seasons.
2. Retrieving playoff standings data.
3. Merging team statistics with playoff data.
4. Preprocessing the data for predictive modeling.

## Data Collection

We use the `nba_api` to gather data on team performance and playoff standings:

- **Team Statistics**: For each season, we collect a variety of performance metrics.
- **Playoff Picture**: We retrieve the playoff standings for each season.

## Data Processing

The collected data undergoes several preprocessing steps:
- Merging team statistics with playoff data.
- Handling missing values.
- Encoding categorical variables.

## Usage

### Requirements

- Python 3.x
- pandas
- nba_api

### Installation

To get started, clone this repository and install the required packages:

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name
pip install -r requirements.txt
