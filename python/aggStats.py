# Aggregate stats for a given lineup
def aggStats(df):
    WS = df['WS'].mean()
    BPM = df['BPM'].mean()
    MP_per_game = df['MP_per_game'].mean()
    GSpct = df['GSpct'].mean()  
    return({'WS':WS, 'BPM':BPM, 'MP_per_game':MP_per_game, 'GS_pct':GSpct})