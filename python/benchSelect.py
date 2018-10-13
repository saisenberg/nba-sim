import numpy as np
from standardizeList import standardizeList

# Randomly choose bench players [fr. relative (MP/G)^N]
def benchSelect(bench, num, power): 
    players = list(bench.Player)    
    probs = standardizeList(list(bench.MP_per_game), power)
    choices = sorted(np.random.choice(players, replace=False, size=num, p=probs))
    bench = bench[bench['Player'].isin(choices)]
    return(bench)