import operator
import numpy as np
from printSeedings import printSeedings

# Compile playoff seedings
def playoffPrep(standings_all_df, east, results_print=False):
    standings_east = {}
    standings_west = {}
    
    for team in standings_all_df:
        if team in east:
            standings_east[team] = np.mean(standings_all_df[team])
        else:
            standings_west[team] = np.mean(standings_all_df[team])
    standings_east = sorted(standings_east.items(), key=operator.itemgetter(1), reverse=True)
    standings_west = sorted(standings_west.items(), key=operator.itemgetter(1), reverse=True)
    standings_combined = {'east':standings_east, 'west':standings_west}
    
    if results_print:
        print('Regular-Season Results (East)')
        printSeedings(standings_combined['east'])
        print('')
        print('Regular-Season Results (West)')
        printSeedings(standings_combined['west'])

    # Initialize seedings and matchups
    playoff_teams_east = standings_combined['east'][0:8]
    playoff_teams_west = standings_combined['west'][0:8]
    
    return(standings_combined)