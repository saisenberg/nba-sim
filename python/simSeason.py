import pandas as pd
pd.options.mode.chained_assignment = None
from selectWinner import aggWinner, pickWinner, setWinner
from initialize import initialize
from lineupFinder import lineupFinder
from runGame import runGame

# Simulate a season
def simSeason(schedules, east, depth_df, pca_s, pca_b, RF, teams, win_prob_power, injury_freq, injury_print=False):
    global injuries
    global depth
    standings, injuries, depth_df = initialize(schedules, east, depth_df)
    season = pd.concat(schedules.apply(lambda x: runGame(depth_df, injuries, x, injury_freq, injury_print), axis=1).values.tolist()).sort_values('gmDateTime').reset_index(drop=True)
    season = aggWinner(season, pca_s, pca_b, RF, win_prob_power)
    for team in teams:
        standings[team]['W'] = season[season['teamAbbr']==team].IsWinner.sum()
        standings[team]['L'] = 82-season[season['teamAbbr']==team].IsWinner.sum()
    return(season, injuries, standings)