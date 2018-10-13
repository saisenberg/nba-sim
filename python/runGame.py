from concatCols import concatCols
from playerInjuries import injuryCreate, injuryUpdate
from lineupFinder import lineupFinder
import pandas as pd

# Run a game (lineups, injuries)
def runGame(depth, injuries, row, injury_freq, injury_print=False):
    team_starting, oppt_starting, team_bench, oppt_bench = lineupFinder(depth, row['teamAbbr'], row['opptAbbr'], 2, 2)
    new_cols = concatCols(team_starting, oppt_starting, team_bench, oppt_bench)
    full_row = pd.concat([pd.DataFrame(row).transpose().reset_index(drop=True), new_cols], axis=1)
    if row['IsInjuryGame'] == 1:
        injuryUpdate(depth, injuries, row['teamAbbr'], row['opptAbbr'])
        new_injuries = injuryCreate(depth, injuries, row['teamAbbr'], row['opptAbbr'], injury_freq)
        if injury_print:
            if len(new_injuries) > 0:
                print('Injury: ', new_injuries, ' (gameID: ', row['gameID'], ')', sep='')
    return(full_row)