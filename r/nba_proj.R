library(dplyr)
library(gtools)
library(htmltab)
library(maps)
library(splitstackshape)
library(stringi)
library(stringr)

stats <- read.csv('.\\data\\stats.csv', stringsAsFactors = F)
seasons <- read.csv('.\\data\\seasons.csv', stringsAsFactors = F)
seasons_adv <- read.csv('.\\data\\seasons_adv.csv', stringsAsFactors = F)


# Player stats----
# Players' total minutes played & GS%
ps.stats <- seasons %>% 
  group_by(Player, yeargroup) %>% 
  summarise(total_MP = sum(MP), G = sum(G), GS = sum(GS)) %>% 
  mutate(GSpct = GS/G, MP_per_game = total_MP/G)


# Weighted advanced stats
ps.advanced <- seasons_adv %>% left_join(ps.stats[,c('Player', 'total_MP', 'yeargroup')], by = c('Player', 'yeargroup')) %>% 
  mutate(WS = WS*(MP/total_MP), BPM = BPM*(MP/total_MP)) %>% 
  group_by(Player, yeargroup) %>% 
  summarise(WS = sum(WS), BPM = sum(BPM))
ps.stats <- left_join(ps.stats, ps.advanced, by = c('Player', 'yeargroup'))
rm(ps.advanced)


# Merge with lineup stats
all_stats <- left_join(stats, ps.stats, by=c('playFullNm' = 'Player', 'season' = 'yeargroup'))


# Player draft positions---- 
all_drafts <- read.csv('C:\\Users\\Sam\\Documents\\DATA\\NBA season projections\\Raw data\\drafts.csv')
all_drafts$Player <- as.character(all_drafts$Player)
all_drafts <- all_drafts %>% 
  filter(Draft >= 2000) %>% 
  select(Pick, Player, Draft)


# Fix instances of different players with same name
all_stats[all_stats$playFullNm == 'Marcus Thornton' & all_stats$teamAbbr == 'WAS',]$playFullNm <- 'Marcus Thornton (1)'
all_drafts[all_drafts$Player == 'Marcus Thornton' & all_drafts$Draft == 2009,]$Player <- 'Marcus Thornton (1)'
all_drafts[all_drafts$Player == 'Marcus Thornton' & all_drafts$Draft == 2015,]$Player <- 'Marcus Thornton (2)'
all_stats[all_stats$playFullNm == 'Justin Jackson' & all_stats$teamAbbr == 'SAC',]$playFullNm <- 'Justin Jackson (1)'
all_drafts[all_drafts$Player == 'Justin Jackson' & all_drafts$Draft == 2017,]$Player <- 'Justin Jackson (1)'
all_drafts[all_drafts$Player == 'Justin Jackson' & all_drafts$Draft == 2018,]$Player <- 'Justin Jackson (2)'



# Merge with draft positions
all_stats <- left_join(all_stats, all_drafts[,c(1,2)], by=c('playFullNm'='Player'))


# Assume 60th pick for undrafted
all_stats$Pick <- ifelse(is.na(all_stats$Pick), 60, all_stats$Pick)
all_stats$imputed <- ifelse(is.na(all_stats$total_MP), 1, 0)


# Predict rookie-year output for all rookies----
rookie_pred <- read.csv('C:\\Users\\Sam\\Documents\\DATA\\NBA season projections\\Raw data\\rookie_pred.csv')


# Replace NAs with predictions
all_stats$WS <- ifelse(is.na(all_stats$WS), rookie_pred[all_stats$Pick, 'WS'], all_stats$WS)
all_stats$BPM <- ifelse(is.na(all_stats$BPM), rookie_pred[all_stats$Pick, 'BPM'], all_stats$BPM)
all_stats$total_MP <- ifelse(is.na(all_stats$total_MP), rookie_pred[all_stats$Pick, 'total_MP'], all_stats$total_MP)
all_stats$G <- ifelse(is.na(all_stats$G), rookie_pred[all_stats$Pick, 'G'], all_stats$G)
all_stats$GSpct <- ifelse(is.na(all_stats$GSpct), rookie_pred[all_stats$Pick, 'GSpct'], all_stats$GSpct)


# Calculate remaining stats
all_stats$GS <- ifelse(is.na(all_stats$GS), all_stats$G * all_stats$GSpct, all_stats$GS)
all_stats$MP_per_game <- ifelse(is.na(all_stats$MP_per_game), all_stats$total_MP / all_stats$G, all_stats$MP_per_game)


# Lineup-level stats----
# Game outcome, location, date/time
ls.game_result <- stats %>% 
  group_by(lineupID) %>% 
  top_n(1) %>% 
  select(gameID, season, lineupID, teamRslt, teamLoc, gmDateTime, teamAbbr, opptAbbr, opptRslt, opptlineupID) %>% 
  distinct()


# Function to collect time since team's last game
sincePrev <- function(team, dateTime){
  
  data <- as.data.frame(ls.game_result) %>% 
    filter(teamAbbr == team) %>% 
    arrange(gmDateTime)
  
  index <- which(data$gmDateTime == dateTime)
  
  if(index == 1){
    time_since <- 10
  } else {
    time_since <- difftime(data$gmDateTime[index], data$gmDateTime[index-1], units = 'days')
  }
  
  rm(data)
  return(time_since)
}

ls.game_result$timeSincePrev <- unname(mapply(sincePrev, ls.game_result$teamAbbr, ls.game_result$gmDateTime))


# Distance from team's last game
city_abbrv <- c("ATL"="Atlanta", "BKN"="New York", "BOS"="Boston", "CHA"="Charlotte", "CHI"="Chicago", "CLE"="Cleveland", "DAL"="Dallas", "DEN"="Denver", "DET"="Detroit", "GS"="Oakland", "HOU"="Houston", "IND"="Indianapolis", "LAC"="Los Angeles", "LAL"="Los Angeles", "MEM"="Memphis", "MIA"="Miami", "MIL"="Milwaukee", "MIN"="Minneapolis", "NO"="New Orleans", "NY"="New York", "OKC"="Oklahoma City", "ORL"="Orlando", "PHI"="Philadelphia", "PHO"="Phoenix", "POR"="Portland", "SA"="San Antonio", "SAC"="Sacramento", "TOR"="Toronto", "UTA"="Salt Lake City", "WAS"="Washington")
ls.game_result$city_played <- ifelse(ls.game_result$teamLoc=='Home', ls.game_result$teamAbbr, ls.game_result$opptAbbr)
ls.game_result$city_played <- unname(city_abbrv[ls.game_result$city_played])

cities <- world.cities
cities <- cities %>% 
  filter(name %in% unique(ls.game_result$city_played), country.etc %in% c('USA', 'Canada')) %>% 
  filter(country.etc == 'USA' | name == 'Toronto') %>% 
  filter(!(name == 'Portland' & pop < 500000)) %>% 
  select(name, lat, long)

ls.game_result <- ls.game_result %>% 
  left_join(cities, by = c('city_played' = 'name'))

# Function to collect (Euclidean) distance from location of team's previous game
distancePrev <- function(team, dateTime){
  
  data <- as.data.frame(ls.game_result) %>% 
    filter(teamAbbr == team) %>% 
    arrange(gmDateTime)
  
  index <- which(data$gmDateTime == dateTime)
  
  if(index == 1){
    return(0)
  } else {
    lat1 <- unname(unlist(data[index, 'lat']))
    long1 <- unname(unlist(data[index, 'long']))
    lat2 <- unname(unlist(data[index-1, 'lat']))
    long2 <- unname(unlist(data[index-1, 'long']))
    dist_since <- sqrt((lat1-lat2)^2 + (long1-long2)^2)
    return(dist_since)
  }
  
  rm(data)
}

ls.game_result$distSincePrev <- unname(unlist(mapply(distancePrev, ls.game_result$teamAbbr, ls.game_result$gmDateTime)))


# Opponent time & distance since previous game
oppPrev <- ungroup(ls.game_result) %>% 
  select(lineupID, timeSincePrev, distSincePrev) %>% 
  rename(opptlineupID = lineupID, oppt_timeSincePrev = timeSincePrev, oppt_distSincePrev = distSincePrev)
ls.game_result <- ls.game_result %>% left_join(oppPrev, by = 'opptlineupID')


# Fix times/distances for start of 2018 season
ls.game_result$distSincePrev <- ifelse(ls.game_result$timeSincePrev > 30, 0, ls.game_result$distSincePrev)
ls.game_result$oppt_distSincePrev <- ifelse(ls.game_result$oppt_timeSincePrev > 30, 0, ls.game_result$oppt_distSincePrev)

ls.game_result$timeSincePrev <- ifelse(ls.game_result$timeSincePrev > 30, 10, ls.game_result$timeSincePrev)
ls.game_result$oppt_timeSincePrev <- ifelse(ls.game_result$oppt_timeSincePrev > 30, 10, ls.game_result$oppt_timeSincePrev)


# Starting lineup stats (team & opponent)----
# Mean WS, BPM, MP/G, GSpct
ls.stats.s <- all_stats %>% 
  filter(playStat == 'Starter') %>% 
  group_by(lineupID) %>% 
  select(lineupID, WS, BPM, MP_per_game, GSpct) %>% 
  summarise_all(mean)
ls.game_result <- left_join(ls.game_result, ls.stats.s, by = 'lineupID') %>% 
  rename(team_starting_WS = WS, team_starting_BPM = BPM, team_starting_MP_per_game = MP_per_game, team_starting_GSpct = GSpct) %>% 
  left_join(ls.stats.s, by = c('opptlineupID' = 'lineupID')) %>% 
  rename(oppt_starting_WS = WS, oppt_starting_BPM = BPM, oppt_starting_MP_per_game = MP_per_game, oppt_starting_GSpct = GSpct)


# Bench stats (team & opponent, top 3 by MP)----
bench3 <- all_stats %>% 
  filter(playStat == 'Bench') %>% 
  group_by(lineupID) %>% 
  top_n(3, playMin)


# Randomly sample from ties in top 3 by MP
bench3 <- getanID(bench3, 'lineupID')
ties4 <- sort(c(which(bench3$.id == 4), which(bench3$.id == 4)-1))
ties5 <- sort(c(which(bench3$.id == 5), which(bench3$.id == 5)-1, which(bench3$.id == 5)-2))
ties6 <- sort(c(which(bench3$.id == 6), which(bench3$.id == 6)-1, which(bench3$.id == 6)-2, which(bench3$.id == 6)-3))


# Unique 2 and 3-way ties
ties4 <- setdiff(ties4, ties5)
ties5 <- setdiff(ties5, ties6)


# Randomly select tie rows to remove
removes <- bind_rows(
  bench3[ties4,] %>% group_by(lineupID) %>% sample_n(1),
  bench3[ties5,] %>% group_by(lineupID) %>% sample_n(2),
  bench3[ties6,] %>% group_by(lineupID) %>% sample_n(3)
  ) %>% distinct


# Remove all randomly chosen rows
bench3 <- bench3 %>% 
  bind_rows(removes) %>% 
  arrange(lineupID, .id)
removes_index <- sort(c(which(duplicated(bench3)), which(duplicated(bench3))-1))
bench3 <- bench3[-removes_index,]


# Aggregate bench stats
ls.stats.b <- bench3 %>% 
  group_by(lineupID) %>% 
  select(lineupID, WS, BPM, MP_per_game, GSpct) %>% 
  summarise_all(mean)
ls.game_result <- left_join(ls.game_result, ls.stats.b, by = 'lineupID') %>% 
  rename(team_bench_WS = WS, team_bench_BPM = BPM, team_bench_MP_per_game = MP_per_game, team_bench_GSpct = GSpct) %>% 
  left_join(ls.stats.b, by = c('opptlineupID' = 'lineupID')) %>% 
  rename(oppt_bench_WS = WS, oppt_bench_BPM = BPM, oppt_bench_MP_per_game = MP_per_game, oppt_bench_GSpct = GSpct)


# Team and opponent records at start of game----
ls.game_result <- ls.game_result %>% 
  group_by(teamAbbr, teamRslt, season) %>% 
  mutate(teamRsltCount = seq(n()))
ls.game_result <- ls.game_result %>% 
  group_by(teamAbbr, season) %>% 
  mutate(teamGameCount = seq(n()))
ls.game_result <- ls.game_result %>% 
  group_by(opptAbbr, opptRslt, season) %>% 
  mutate(opptRsltCount = seq(n()))
ls.game_result <- ls.game_result %>% 
  group_by(opptAbbr, season) %>% 
  mutate(opptGameCount = seq(n()))


# Team and opponent win% at start of game
ls.game_result$teamWinPct <- ifelse(ls.game_result$teamRslt == 'Win', 
                                (ls.game_result$teamRsltCount-1) / (ls.game_result$teamGameCount-1),
                                (ls.game_result$teamGameCount-ls.game_result$teamRsltCount) / (ls.game_result$teamGameCount-1))
ls.game_result$teamWinPct <- ifelse(is.nan(ls.game_result$teamWinPct), 0, ls.game_result$teamWinPct)

ls.game_result$opptWinPct <- ifelse(ls.game_result$opptRslt == 'Win', 
                                    (ls.game_result$opptRsltCount-1) / (ls.game_result$opptGameCount-1),
                                    (ls.game_result$opptGameCount-ls.game_result$opptRsltCount) / (ls.game_result$opptGameCount-1))
ls.game_result$opptWinPct <- ifelse(is.nan(ls.game_result$opptWinPct), 0, ls.game_result$opptWinPct)


# If GameCount < 10, use the previous year's WinPct
records <- read.csv('.\\data\\records.csv', stringsAsFactors = F)
records <- records %>% 
  rename(PY_WinPct = WinPct) %>% 
  mutate(yeargroup = year + 1) %>% 
  select(teamAbbr, PY_WinPct, yeargroup)
ls.game_result <- ls.game_result %>% 
  left_join(records, by = c('teamAbbr'='teamAbbr', 'season'='yeargroup')) %>% 
  rename(PY_teamWinPct = PY_WinPct) %>% left_join(records, by = c('opptAbbr'='teamAbbr', 'season'='yeargroup')) %>% 
  rename(PY_opptWinPct = PY_WinPct)
ls.game_result$teamWinPct2 <- ifelse(ls.game_result$teamGameCount<10, ls.game_result$PY_teamWinPct, ls.game_result$teamWinPct)
ls.game_result$opptWinPct2 <- ifelse(ls.game_result$opptGameCount<10, ls.game_result$PY_opptWinPct, ls.game_result$opptWinPct)


# Compute differences between all team vs. opponent metrics
ls.game_result <- ls.game_result %>% mutate(diff_starting_WS = team_starting_WS - oppt_starting_WS, 
                               diff_starting_BPM = team_starting_BPM - oppt_starting_BPM,
                               diff_starting_MP_per_game = team_starting_MP_per_game - oppt_starting_MP_per_game,
                               diff_starting_GSpct = team_starting_GSpct - oppt_starting_GSpct,
                               diff_bench_WS = team_bench_WS - oppt_bench_WS, 
                               diff_bench_BPM = team_bench_BPM - oppt_bench_BPM,
                               diff_bench_MP_per_game = team_bench_MP_per_game - oppt_bench_MP_per_game,
                               diff_bench_GSpct = team_bench_GSpct - oppt_bench_GSpct,
                               diff_WinPct2 = teamWinPct2 - opptWinPct2,
                               diff_timeSincePrev = timeSincePrev - oppt_timeSincePrev,
                               diff_distSincePrev = distSincePrev - oppt_distSincePrev
                               )


write.csv(ls.game_result, '.\\data\\results.csv', row.names = F)
