# Scrape previous season standings
library(dplyr)
library(gtools)
library(htmltab)
library(stringi)
library(stringr)

cols <- c('Team', 'W', 'L', 'WinPct', 'GB', 'PTSperG', 'PTSAperG', 'SRS')
urlstart <- 'https://www.basketball-reference.com/leagues/NBA_'
urlend <- '_standings.html'


# Scrape standings data
records <- data.frame()
for(year in 2016:2018){
  url <- paste0(urlstart, year, urlend)
  
  east <- htmltab(url, which=1, colNames = cols)
  west <- htmltab(url, which=2, colNames = cols)
  
  standings <- smartbind(east, west) %>% select(Team, W, L, WinPct)
  standings$year <- year
  records <- smartbind(records, standings)
  rm(east, west, standings)
}


# Clean resulting dataframe
records$WinPct <- as.numeric(records$WinPct)
records$Team <- gsub(pattern = "[^[:alpha:] ]|Â", replacement = "", x = records$Team)
records$Team <- str_replace(records$Team, ' ers', ' 76ers')


# Add team abbreviations
team_abbrv <- c("Atlanta Hawks"="ATL", "Boston Celtics"="BOS", "Brooklyn Nets"="BKN", "Charlotte Hornets"="CHA", "Chicago Bulls"="CHI", "Cleveland Cavaliers"="CLE", "Dallas Mavericks"="DAL", "Denver Nuggets"="DEN", "Detroit Pistons"="DET", "Golden State Warriors"="GS", "Houston Rockets"="HOU", "Indiana Pacers"="IND", "Los Angeles Clippers"="LAC", "Los Angeles Lakers"="LAL", "Memphis Grizzlies"="MEM", "Miami Heat"="MIA", "Milwaukee Bucks"="MIL", "Minnesota Timberwolves"="MIN", "New Orleans Pelicans"="NO", "New York Knicks"="NY", "Oklahoma City Thunder"="OKC", "Orlando Magic"="ORL", "Philadelphia 76ers"="PHI", "Phoenix Suns"="PHO", "Portland Trail Blazers"="POR", "San Antonio Spurs"="SA", "Sacramento Kings"="SAC", "Toronto Raptors"="TOR", "Utah Jazz"="UTA", "Washington Wizards"="WAS")
records$teamAbbr <- team_abbrv[records$Team]


write.csv(records, '.\\data\\records.csv', row.names = F)
