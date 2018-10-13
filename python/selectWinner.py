import numpy as np
from pcaPrep import pcaPrep

# Pick game winner from predicted probabilities
def pickWinner(season_df, gameID):
    WinProb_weighted_index = list(season_df.columns).index('WinProb_weighted')
    teamAbbr_index = list(season_df.columns).index('teamAbbr')
    gameID_index = list(season_df.columns).index('gameID')
    season_df = np.array(season_df)
    season_df = season_df[(season_df[:,gameID_index]==gameID)]
    season_df = season_df[:,[teamAbbr_index,WinProb_weighted_index]]
    winner = np.random.choice(season_df[:,0], p=season_df[:,1].astype('float'))
    return(winner)

# Set winners and losers
def setWinner(gameID, winCol, season_df):
    Winner_index = list(season_df.columns).index('Winner')
    winner = np.array(season_df[season_df['gameID']==gameID])[:,Winner_index]
    winner = [team for team in winner if team][0]
    return(winner)
    
# Aggregate season win totals
def aggWinner(season, pca_s, pca_b, RF, win_prob_power=1.4):
    RF_cols = pcaPrep(season, pca_s, pca_b)
    season['WinProb'] = (RF.predict_proba(RF_cols)[:,1])**win_prob_power
    season['WinProb_weighted'] = season.apply(lambda x: x['WinProb'] / season[season['gameID']==x['gameID']].WinProb.sum(), axis=1)
    season['Winner'] = season.apply(lambda x: pickWinner(season, x['gameID']) if x['IsInjuryGame']==1 else None, axis=1)
    season['Winner'] = season.apply(lambda x: setWinner(x['gameID'], x['Winner'], season), axis=1)
    season['IsWinner'] = season.apply(lambda x: 1 if x['Winner'] == x['teamAbbr'] else 0, axis=1)
    return(season)