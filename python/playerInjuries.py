import math
import numpy as np
import pandas as pd
import random
from standardizeList import standardizeList


# Create player injuries
def injuryCreate(depth, injuries, teamAbbr, opptAbbr, freq):
    InjuryTime_index = list(depth.columns).index('InjuryTime')
    teamAbbr_index = list(depth.columns).index('teamAbbr')
    injured_players = []
    depth_df = np.array(depth)
    depth_df = depth_df[((depth_df[:,teamAbbr_index]==teamAbbr) | (depth_df[:,teamAbbr_index]==opptAbbr)) & (depth_df[:,InjuryTime_index] == 0)]
    players = list(depth_df[:,0])
    for player in players:
        injury_prob = np.random.random()
        if injury_prob < (1/freq):
            injury_severity = np.random.random()
            if injury_severity < (1/8):
                injury_length = min([82+16, math.ceil(np.random.exponential(scale=60))])
            else:
                injury_length = min([82+16, math.ceil(np.random.exponential(scale=5))])
            injuries[player] = injury_length
            injured_players.append({player:injury_length})
    depth['InjuryTime'] = depth.apply(lambda x: injuries[x['Player']], axis=1)
    return(injured_players)



# Replace injured players
def injuryReplace(players, full_lineup, depth, num_players, power):
    while players.shape[0] < num_players:
        
        # Randomly choose a replacement player [fr. relative (MP/G)^N]
        replacements = list(full_lineup[full_lineup['Depth']==depth+1].Player)
        probs = standardizeList(list(full_lineup[full_lineup['Depth']==depth+1].MP_per_game), power)
        replacement = random.choices(population=replacements, weights=probs)
        
        # Update in players df
        replacement_row = full_lineup[full_lineup['Player']==replacement[0]]
        replacement_row['Depth'] = depth
        
        # Update in full_lineup df
        full_lineup = full_lineup[~(full_lineup['Player'] == replacement[0])]
        full_lineup = pd.concat([full_lineup, replacement_row], axis=0)
        players = pd.concat([players, replacement_row], axis=0)
        
        # Re-sort both dfs
        players = players.sort_values(['Depth', 'Player'])
        full_lineup = full_lineup.sort_values(['Depth', 'Player'])
        
    return(players, full_lineup)



# Update player injury days
def injuryUpdate(depth, injuries, teamAbbr, opptAbbr):
    teamAbbr_index = list(depth.columns).index('teamAbbr')
    depth_df = np.array(depth)
    depth_df = depth_df[(depth_df[:,teamAbbr_index]==teamAbbr) | (depth_df[:,teamAbbr_index]==opptAbbr)]
    players = list(depth_df[:,0])
    for player in players:
        if injuries[player] > 0:
            injuries[player] -= 1
    depth['InjuryTime'] = depth.apply(lambda x: injuries[x['Player']], axis=1)