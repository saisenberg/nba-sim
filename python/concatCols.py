import pandas as pd
from aggStats import aggStats

# Organize aggregated lineup stats
def concatCols(team_starting, oppt_starting, team_bench, oppt_bench):
    ts = pd.DataFrame([aggStats(team_starting)])
    os = pd.DataFrame([aggStats(oppt_starting)])
    tb = pd.DataFrame([aggStats(team_bench)])
    ob = pd.DataFrame([aggStats(oppt_bench)])
    
    ts.columns = ['team_starting_BPM', 'team_starting_GSpct', 'team_starting_MP_per_game', 
                  'team_starting_WS']
    os.columns = ['oppt_starting_BPM', 'oppt_starting_GSpct', 'oppt_starting_MP_per_game', 
                  'oppt_starting_WS']
    tb.columns = ['team_bench_BPM', 'team_bench_GSpct', 'team_bench_MP_per_game', 
                  'team_bench_WS']
    ob.columns = ['oppt_bench_BPM', 'oppt_bench_GSpct', 'oppt_bench_MP_per_game', 
                  'oppt_bench_WS']
    
    new_cols = pd.concat([ts, os, tb, ob], axis=1)
    new_cols['diff_starting_BPM'] = new_cols.apply(lambda x: x['team_starting_BPM']-x['oppt_starting_BPM'], axis=1)
    new_cols['diff_starting_GSpct'] = new_cols.apply(lambda x: x['team_starting_GSpct']-x['oppt_starting_GSpct'], axis=1)
    new_cols['diff_starting_MP_per_game'] = new_cols.apply(lambda x: x['team_starting_MP_per_game']-x['oppt_starting_MP_per_game'], axis=1)
    new_cols['diff_starting_WS'] = new_cols.apply(lambda x: x['team_starting_WS']-x['oppt_starting_WS'], axis=1)
    new_cols['diff_bench_BPM'] = new_cols.apply(lambda x: x['team_bench_BPM']-x['oppt_bench_BPM'], axis=1)
    new_cols['diff_bench_GSpct'] = new_cols.apply(lambda x: x['team_bench_GSpct']-x['oppt_bench_GSpct'], axis=1)
    new_cols['diff_bench_MP_per_game'] = new_cols.apply(lambda x: x['team_bench_MP_per_game']-x['oppt_bench_MP_per_game'], axis=1)
    new_cols['diff_bench_WS'] = new_cols.apply(lambda x: x['team_bench_WS']-x['oppt_bench_WS'], axis=1)
    
    return(new_cols)