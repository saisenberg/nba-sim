import pandas as pd
from sklearn.decomposition import PCA
from sklearn.ensemble import RandomForestClassifier

# Train random forest model
def rfPreprocess():
    
    # Read data and turn binary columns to 0/1
    trainingresults = pd.read_csv('..\\data\\results.csv')
    trainingresults['teamRslt'] = [1 if x == 'Win' else 0 for x in trainingresults['teamRslt']]   # Win = 1, Loss = 0
    trainingresults['teamLoc'] = [1 if x == 'Home' else 0 for x in trainingresults['teamLoc']]  # Home = 1, Away = 0
    
    # X/Y
    Y = trainingresults['teamRslt']
    X = trainingresults.loc[:, ['teamLoc', 'diff_starting_WS', 'diff_starting_BPM', 
                        'diff_starting_MP_per_game', 'diff_starting_GSpct', 'diff_bench_WS', 
                        'diff_bench_BPM', 'diff_bench_MP_per_game', 'diff_bench_GSpct', 
                        'timeSincePrev', 'distSincePrev']]
    
    # Separate PCA cols
    PCA_cols_starting = ['diff_starting_WS', 'diff_starting_MP_per_game', 'diff_starting_GSpct']
    PCA_cols_bench = ['diff_bench_WS', 'diff_bench_MP_per_game', 'diff_bench_GSpct']
    X_PCA_cols_starting = X.loc[:, PCA_cols_starting]
    X_PCA_cols_bench = X.loc[:, PCA_cols_bench]
    
    # PCA on starter metrics
    pca_starters = PCA(n_components=0.75, random_state=1)
    pca_starters.fit(X_PCA_cols_starting)
    X_PCA_cols_starting_transformed = pd.Series(pca_starters.transform(X_PCA_cols_starting)[:,0])
    
    # PCA on bench metrics
    pca_bench = PCA(n_components=0.75, random_state=1)
    pca_bench.fit(X_PCA_cols_bench)
    X_PCA_cols_bench_transformed = pd.Series(pca_bench.transform(X_PCA_cols_bench)[:,0])
    
    # Combine PCA cols with non-PCA cols
    X_noPCA = X.drop(PCA_cols_starting+PCA_cols_bench, axis=1).reset_index()
    X_new = pd.concat([X_noPCA, X_PCA_cols_starting_transformed, X_PCA_cols_bench_transformed], axis=1)
    X_new = X_new.rename(columns = {0:'PC_starters', 1:'PC_bench'})
    X_new = X_new.drop('index', axis=1)
    
    # Train random forest model
    RF = RandomForestClassifier(max_depth=4, max_features=5, min_samples_leaf=5, n_estimators=1001, random_state=1)
    RF.fit(X_new, Y)
    
    # Return pca objects and random forest object
    return(pca_starters, pca_bench, RF)