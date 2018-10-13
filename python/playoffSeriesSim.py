import numpy as np
import pandas as pd
from cityDist import cityDist
from pcaPrep import pcaPrep
from runGame import runGame

# Simulate a playoff series
def playoffSeriesSim(team1, team2, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
                     win_prob_power=1.4, injury_freq=900, injury_print=False, result_print=False):
    
    # Series information
    game_num = 0
    home_away_order = [None, 
                       {'home':team1, 'away':team2, 'travel':False}, 
                       {'home':team1, 'away':team2, 'travel':False}, 
                       {'home':team2, 'away':team1, 'travel':True},
                       {'home':team2, 'away':team1, 'travel':False},
                       {'home':team1, 'away':team2, 'travel':True},  
                       {'home':team2, 'away':team1, 'travel':True},
                       {'home':team1, 'away':team2, 'travel':True}]
    series_wins = {team1:0, team2:0}
    
    # Game information
    while (series_wins[team1] < 4) & (series_wins[team2] < 4):
        game_num += 1
        home_team = home_away_order[game_num]['home']
        travel = home_away_order[game_num]['travel']
        timeSincePrev = 2
        if travel:
            distSincePrev = cityDist(team1, team2, cities, city_abbrvs)
        else:
            distSincePrev = 0
        
        # Simulate game from both teams' perspectives
        game_df = []
        for perspectives in [{'POV_team':team1, 'nonPOV_team':team2}, 
                             {'POV_team':team2, 'nonPOV_team':team1}]:
            POV_team = perspectives['POV_team']
            nonPOV_team = perspectives['nonPOV_team']
            if POV_team == home_team:
                teamLoc = 1
            else:
                teamLoc = 0
            if POV_team == team2:
                IsInjuryGame = 1
            else:
                IsInjuryGame = 0
            game_row = pd.DataFrame(pd.Series([POV_team, nonPOV_team, teamLoc, IsInjuryGame])).transpose().rename(columns={0:'teamAbbr', 1:'opptAbbr', 2:'teamLoc', 3:'IsInjuryGame'})
            game_df.append(game_row)
            
        game = pd.concat([game_df[0], game_df[1]], axis=0).reset_index(drop=True)
        game['gameID'] = 'gm' + str(game_num) + '-' + game.teamAbbr[0] + 'x' + game.teamAbbr[1]
        game = pd.concat(game.apply(lambda x: runGame(depth, injuries, x, 900, injury_print), axis=1).values.tolist()).reset_index(drop=True)
        game['timeSincePrev'] = timeSincePrev
        game['distSincePrev'] = distSincePrev
        game = pcaPrep(game, pca_s, pca_b)
        game['WinProb'] = (RF.predict_proba(game)[:,1])**win_prob_power
        game['WinProb_weighted'] = game.apply(lambda x: x['WinProb'] / game['WinProb'].sum(), axis=1)
        game['teamAbbr'] = pd.Series([team1, team2])
        winner = np.random.choice(game['teamAbbr'], p=game['WinProb_weighted'])
        series_wins[winner] += 1
    
    if result_print:
        print(series_wins)
    return(series_wins)