# Scrapes schedule for upcoming season
library(dplyr)
library(gtools)
library(htmltab)
library(lubridate)
library(maps)
library(stringr)

breference_abbrevs <- c('Atlanta Hawks'='ATL', 'Boston Celtics'='BOS', 'Brooklyn Nets'='BRK', 'Charlotte Hornets'='CHO', 'Chicago Bulls'='CHI', 'Cleveland Cavaliers'='CLE', 'Dallas Mavericks'='DAL', 'Denver Nuggets'='DEN', 'Detroit Pistons'='DET', 'Golden State Warriors'='GSW', 'Houston Rockets'='HOU', 'Indiana Pacers'='IND', 'Los Angeles Clippers'='LAC', 'Los Angeles Lakers'='LAL', 'Memphis Grizzlies'='MEM', 'Miami Heat'='MIA', 'Milwaukee Bucks'='MIL', 'Minnesota Timberwolves'='MIN', 'New Orleans Pelicans'='NOP', 'New York Knicks'='NYK', 'Oklahoma City Thunder'='OKC', 'Orlando Magic'='ORL', 'Philadelphia 76ers'='PHI', 'Phoenix Suns'='PHO', 'Portland Trail Blazers'='POR', 'Sacramento Kings'='SAC', 'San Antonio Spurs'='SAS', 'Toronto Raptors'='TOR', 'Utah Jazz'='UTA', 'Washington Wizards'='WAS')
breference_teams <- unname(breference_abbrevs)

city_abbrv <- c("ATL"="Atlanta", "BRK"="New York", "BOS"="Boston", "CHO"="Charlotte", "CHI"="Chicago", "CLE"="Cleveland", "DAL"="Dallas", "DEN"="Denver", "DET"="Detroit", "GSW"="Oakland", "HOU"="Houston", "IND"="Indianapolis", "LAC"="Los Angeles", "LAL"="Los Angeles", "MEM"="Memphis", "MIA"="Miami", "MIL"="Milwaukee", "MIN"="Minneapolis", "NOP"="New Orleans", "NYK"="New York", "OKC"="Oklahoma City", "ORL"="Orlando", "PHI"="Philadelphia", "PHO"="Phoenix", "POR"="Portland", "SAS"="San Antonio", "SAC"="Sacramento", "TOR"="Toronto", "UTA"="Salt Lake City", "WAS"="Washington")


urlstart <- 'https://www.basketball-reference.com/teams/'
urlend <- '/2019_games.html'


# Unique game ID
source('gameID.R')


# Function to collect time since team's last game
sincePrev <- function(team, dateTime){
  
  data <- as.data.frame(schedules) %>% 
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


# Function to collect (Euclidean) distance from location of team's previous game
distancePrev <- function(team, dateTime){
  
  data <- as.data.frame(schedules) %>% 
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


# Scrapes 2018-19 schedules by team
teamScrape <- function(team){
  print(team)
  url <- paste0(urlstart, team, urlend)
  schedule <- htmltab(url, which=1)
  schedule$teamAbbr <- team
  return(schedule)
}

schedules <- data.frame()
for(team in breference_teams){
  schedules <- smartbind(schedules, teamScrape(team))
}


# Clean data----
names(schedules) <- c('num', 'date', 'time', 'teamLoc', 'opptAbbr', 'teamAbbr')
schedules <- schedules %>% 
  filter(num != 'G')
schedules$teamLoc <- ifelse(is.na(schedules$teamLoc), 'Home', 'Away')


# Clean date/time
schedules$date <- mdy(schedules$date)
schedules$gmDateTime <- paste(schedules$date, schedules$time)
schedules$gmDateTime <- str_replace(schedules$gmDateTime, 'p', 'PM')
schedules$gmDateTime <- parse_date_time(schedules$gmDateTime, '%Y-%m-%d %I:%M%p')

schedules$opptAbbr <- breference_abbrevs[schedules$opptAbbr]
schedules <-  schedules %>% 
  select(gmDateTime, teamLoc, teamAbbr, opptAbbr)


# Game ID
schedules$gameID <- apply(schedules, 1, makegameID, which(names(schedules)=='gmDateTime'), which(names(schedules)=='teamAbbr'), which(names(schedules)=='opptAbbr'))


# Lineup ID
schedules$lineupID <- paste(year(schedules$gmDateTime), month(schedules$gmDateTime), day(schedules$gmDateTime), schedules$teamAbbr, sep = '-')
schedules$opptlineupID <- paste(year(schedules$gmDateTime), month(schedules$gmDateTime), day(schedules$gmDateTime), schedules$opptAbbr, sep = '-')


# Time since previous game
schedules$timeSincePrev <- unname(mapply(sincePrev, schedules$teamAbbr, schedules$gmDateTime))


# Distance from previous game
schedules$city_played <- ifelse(schedules$teamLoc == 'Home', schedules$teamAbbr, schedules$opptAbbr)
schedules$city_played <- unname(city_abbrv[schedules$city_played])

cities <- world.cities
cities <- cities %>% 
  filter(name %in% unique(schedules$city_played), country.etc %in% c('USA', 'Canada')) %>% 
  filter(country.etc == 'USA' | name == 'Toronto') %>% 
  filter(!(name == 'Portland' & pop < 500000)) %>% 
  select(name, lat, long)
schedules <- schedules %>% 
  left_join(cities, by = c('city_played' = 'name'))

schedules$distSincePrev <- unname(unlist(mapply(distancePrev, schedules$teamAbbr, schedules$gmDateTime)))

opptPrev <- schedules %>% 
  select(lineupID, timeSincePrev, distSincePrev) %>% 
  rename(opptlineupID = lineupID, oppt_timeSincePrev = timeSincePrev, oppt_distSincePrev = distSincePrev)
schedules <- schedules %>% left_join(opptPrev, by = 'opptlineupID')


# Write to .csv
write.csv(schedules, '.\\data\\schedules.csv', row.names = F)
