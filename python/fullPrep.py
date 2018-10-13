# Load all necessary files
# To be run before fullSim.py

import os
#os.chdir("[SET WORKING DIRECTORY]")
os.chdir(r'C:\Users\Sam\Documents\DATA\NBA season projections\NBAsim GITHUB ENVIRONMENT\python')


from datetime import datetime as dt
import pandas as pd

# Schedules
schedules = pd.read_csv('..\\data\\schedules.csv')
schedules = schedules.sort_values(['gmDateTime', 'gameID']).reset_index(0, drop=True)
schedules['gmDateTime'] = schedules.apply(lambda x: dt.strptime(x['gmDateTime'], "%Y-%m-%d %H:%M:%S"), axis=1)
schedules['IsInjuryGame'] = [0, 1]*int(schedules.shape[0]/2)
schedules['teamLoc'] = [1 if x == 'Home' else 0 for x in schedules['teamLoc']]  # Home = 1, Away = 0

# Depth charts
depth = pd.read_csv('..\\data\\depth.csv')
depth = depth.sort_values(['Player']).reset_index(drop=True)

# Manual updates to initial depth charts
# Golden State Warriors:
# D. Cousins to first-string / J. Bell to second-string / Damian Jones to third-string
depth.loc[depth['Player'] == 'D. Cousins', 'Depth'] = 1
depth.loc[depth['Player'] == 'J. Bell', 'Depth'] = 2
depth.loc[depth['Player'] == 'Damian Jones', 'Depth'] = 3

# Phoenix Suns:
# E. Okobo to first-string / T. Warren to second-string
depth.loc[depth['Player'] == 'E. Okobo', 'Depth'] = 1
depth.loc[depth['Player'] == 'T. Warren', 'Depth'] = 2

# San Antonio Spurs
# P. Mills to first-string
depth.loc[depth['Player'] == 'P. Mills', 'Depth'] = 1

# Conferences
east = ['ATL', 'BOS', 'BRK', 'CHI', 'CHO', 'CLE', 'DET', 'IND', 'MIA', 'MIL', 'NYK', 'ORL', 
        'PHI', 'TOR', 'WAS']
west = ['DAL', 'DEN', 'GSW', 'HOU', 'LAC', 'LAL', 'MEM', 'MIN', 'NOP', 'OKC', 'PHO', 'POR', 
        'SAC', 'SAS','UTA']

# City longitude and latitude information
cities = pd.read_csv('..\\data\\cities.csv').set_index('name')
city_abbrvs = {'ATL':'Atlanta', 'BOS':'Boston', 'BRK':'New York', 'CHI':'Chicago', 
               'CHO':'Charlotte', 'CLE':'Cleveland', 'DET':'Detroit', 'IND':'Indianapolis', 
               'MIA':'Miami', 'MIL':'Milwaukee', 'NYK':'New York', 'ORL':'Orlando', 
               'PHI':'Philadelphia', 'TOR':'Toronto', 'WAS':'Washington', 'DAL':'Dallas', 
               'DEN':'Denver', 'GSW':'Oakland', 'HOU':'Houston', 'LAC':'Los Angeles', 
               'LAL':'Los Angeles', 'MEM':'Memphis', 'MIN':'Minneapolis', 'NOP':'New Orleans', 
               'OKC':'Oklahoma City', 'PHO':'Phoenix', 'POR':'Portland', 'SAC':'Sacramento', 
               'SAS':'San Antonio', 'UTA':'Salt Lake City'}