# readme prep
setwd('C:\\Users\\Sam\\Documents\\DATA\\NBA season projections')

# DRAWS FROM
# 0. 2016-17_playerBoxScore_utf8
#    2017-18_playerBoxScore_utf8
#    gameID.R

# MODEL WINNER/LOSER FROM 2017-18 SEASONS
# 1. drafts.R -- output is drafts.csv 
#                         --- drafts.csv: every draft pick since 2000
# 2. rookie_pred.R -- output is rookie_pred.csv 
#                         --- rookie_pred.csv: imputed rookie-year stats by pick
# 3. nba_stats.R -- output is stats.csv, seasons.csv, and seasons_adv.csv
#                         --- stats.csv: every player for every game
#                         --- seasons.csv: player yearly stats (regular)
#                         --- seasons_adv.csv: player yearly stats (advanced)
# 4. records.R -- output is records.csv
#                         --- records: contains historical team records
# 5. nba_proj.R -- output is ls.game_result.csv
#                         --- results.csv: aggregated lineup stats
# 6. NBAproj.ipynb -- output is choosing random forest model
#                         --- predicts winner of game (~64% accuracy)
# 7. RF_tuning.ipynb -- output is parameters of RF model
#                         --- max_depth = 3 , max_features = 2, min_samples_leaf = 7, min_samples_split = 7
# 8. NBArandomforest.ipynb -- output is rfPreProcess function
#                         --- rfPreProcess: recreates the RF training model from #6 prediction



# COLLECT STATS FOR UPCOMING SEASON
# 9. depth_chart_scraper_ESPN.ipynb -- output is espn_depth_chart.csv 
#                         --- team depth charts from ESPN
# 10. 2018-19_schedule.R -- output is schedules.csv
#                         --- schedules.csv: every game in 2018-19 season
# 11. 2018-19_stats.R -- output is depth.csv
#                         --- team-by-team depth charts with player stats (run this again if depth chart changes)
