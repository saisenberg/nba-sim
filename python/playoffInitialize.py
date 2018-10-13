import math
import numpy as np

# Initialize playoff injuries (randomly chosen)
def playoffInitialize(depth):
    global injuries

    injuries = {player: 0 for player in list(depth.Player)}    
    for player in list(depth.Player):
        injury_prob = np.random.random()
        if injury_prob < (1/400):
            injury_severity = np.random.random()
            if injury_severity < (1/8):
                injury_length = min([82+16, math.ceil(np.random.exponential(scale=60))])
            else:
                injury_length = min([82+16, math.ceil(np.random.exponential(scale=5))])
            injuries[player] = injury_length
    
    # Season-long 'injuries'
    injuries['D. Murray'] = 16   # Out for season
    injuries['J. Butler'] = 16   # Refuses to play
    injuries['J. Noah'] = 16   # Waived
    
    depth['InjuryTime'] = depth.apply(lambda x: injuries[x['Player']], axis=1)