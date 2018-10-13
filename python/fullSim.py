# Run entire season simulation and playoff simulation N times
# To be run after fullPrep.py

import os
#os.chdir("[SET WORKING DIRECTORY]")
os.chdir(r'C:\Users\Sam\Documents\DATA\NBA season projections\NBAsim GITHUB ENVIRONMENT\python')

import numpy as np
import pandas as pd
from datetime import datetime as dt

from selectWinner import aggWinner, pickWinner, setWinner
from initialize import initialize
from playoffPrep import playoffPrep
from rfPreprocess import rfPreprocess
from runGame import runGame
from simPlayoffs import simRound1, simRound2, simRound3, simFinals, simPlayoffs
from simSeason import simSeason

# Set number of simulations (regular season and playoffs)
num_season_sim = 1
num_playoff_sim = 1

# Initialization
standings, injuries, depth = initialize(schedules, east, depth)
pca_s, pca_b, RF = rfPreprocess()
teams = sorted(depth.teamAbbr.unique())

# Simulate N seasons
standings_all = {team:[] for team in teams}
tt1 = dt.now()
for i in range(num_season_sim):
    t1 = dt.now()
    print('Starting regular season iteration ' + str(i+1))
    try:
        season, injuries, standings = simSeason(schedules, east, depth, pca_s, pca_b, RF, teams, win_prob_power=1.4, injury_freq=700, injury_print=False)
        for team in standings:
            standings_all[team].append(standings[team]['W'])
    except:
        pass
    t2 = dt.now()
    tdiff = t2 - t1
    tdiff = divmod(tdiff.days * 86400 + tdiff.seconds, 60)
    print('Iteration ' + str(i+1) + ': ' + str(tdiff[0]) + 'M' + str(tdiff[1]) + 'S')
tt2 = dt.now()
ttdiff = tt2 - tt1
ttdiff = divmod(ttdiff.days * 86400 + ttdiff.seconds, 60)
print('All simulations complete: ' + str(ttdiff[0]) + 'M' + str(ttdiff[1]) + 'S')
standings_combined = playoffPrep(standings_all, east, False)

# Simulate N playoffs using the results from N seasons
winners = []
runnerups = []
semifinal_easts = []
semifinal_wests = []
for i in range(num_playoff_sim):
    p1 = dt.now()
    print('Starting playoff iteration ' + str(i+1))
    winner, runnerup, semifinal_east, semifinal_west = simPlayoffs(standings_combined, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, win_prob_power=1.4, injury_freq=900, injury_print=False, result_print=True)
    winners.append(winner)
    runnerups.append(runnerup)
    semifinal_easts.append(semifinal_east)
    semifinal_wests.append(semifinal_west)
    p2 = dt.now()
    pdiff = p2 - p1
    pdiff = divmod(pdiff.days * 86400 + pdiff.seconds, 60)
    print('Iteration ' + str(i+1) + ': ' + str(pdiff[0]) + 'M' + str(pdiff[1]) + 'S\n')
    
# Print playoff results
print('NBA Championship Winners')
print(pd.Series(winners).value_counts())
print('')
print('NBA Championship Runners-Up')
print(pd.Series(runnerups).value_counts())
print('')
print('NBA Championship Conference Semi-Finalists (East)')
print(pd.Series(semifinal_easts).value_counts())
print('')
print('NBA Championship Conference Semi-Finalists (West)')
print(pd.Series(semifinal_wests).value_counts())