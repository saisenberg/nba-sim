from benchSelect import benchSelect
from playerInjuries import injuryReplace

# Pick starting lineups and bench
def lineupFinder(depth, teamAbbr, opptAbbr, injuryPower, benchPower):
    lineup_team, lineup_oppt = depth[(depth['teamAbbr'] == teamAbbr) & (depth['InjuryTime'] == 0)], depth[(depth['teamAbbr'] == opptAbbr) & (depth['InjuryTime'] == 0)]
    
    # Replace missing starters
    starters_team, starters_oppt = lineup_team[lineup_team['Depth']==1], lineup_oppt[lineup_oppt['Depth']==1]
    starters_team, lineup_team = injuryReplace(starters_team, lineup_team, 1, 5, injuryPower)
    starters_oppt, lineup_oppt = injuryReplace(starters_oppt, lineup_oppt, 1, 5, injuryPower)
    
    # Replace missing bench
    bench_team, bench_oppt = lineup_team[lineup_team['Depth']==2], lineup_oppt[lineup_oppt['Depth']==2]
    bench_team, lineup_team = injuryReplace(bench_team, lineup_team, 2, 4, injuryPower)
    bench_oppt, lineup_oppt = injuryReplace(bench_oppt, lineup_oppt, 2, 4, injuryPower)
    
    # Select three bench players
    bench_team = benchSelect(bench_team, 3, benchPower)
    bench_oppt = benchSelect(bench_oppt, 3, benchPower)  
    
    return(starters_team, starters_oppt, bench_team, bench_oppt)