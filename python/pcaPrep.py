import pandas as pd

# Perform PCA on game row and prepare for random forest
def pcaPrep(df, pca_s, pca_b):
    X_PCA_starting = df.loc[:,['diff_starting_WS', 
                               'diff_starting_MP_per_game', 'diff_starting_GSpct']]
    X_PCA_bench = df.loc[:,['diff_bench_WS', 'diff_bench_MP_per_game', 
                            'diff_bench_GSpct']]
    starters_PC1 = pd.Series(pca_s.transform(X_PCA_starting)[:,0])
    bench_PC1 = pd.Series(pca_b.transform(X_PCA_bench)[:,0])
    nonPCA = df.loc[:,['teamLoc', 'diff_starting_BPM', 'diff_bench_BPM', 'timeSincePrev', 
                       'distSincePrev']]
    RF_cols = pd.concat([nonPCA, starters_PC1, bench_PC1], axis=1).rename(columns={0:'starters_PC1', 1:'bench_PC1'})
    return(RF_cols)