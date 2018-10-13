library(dplyr)
library(htmltab)
library(lubridate)
library(stringr)

# Projected 2018-19 team lineups----
depth <- read.csv('.\\data\\espn_depth_chart.csv')
depth$Player <- as.character(depth$Player)

# Scrape 2016-18 stats (regular)
seasons <- data.frame()
for(year in 2016:2018){
  print(paste0('Scraping ', year, ' season statistics!'))
  url <- paste0('https://www.basketball-reference.com/leagues/NBA_', year, '_totals.html')
  data <- htmltab(url, which = 1)
  data$year <- year
  seasons <- smartbind(seasons, data)
  rm(data)
}
seasons <- filter(seasons, Player != 'Player')
seasons <- seasons %>% 
  group_by(Player, year) %>% 
  filter(row_number(year)==1)
seasons[c(1,4,6:31)] <- apply(seasons[c(1,4,6:31)], 2, function(x){as.numeric(x)})
seasons <- seasons %>% 
  select(-Rk)


# Scrape 2016-18 stats (advanced)
seasons_adv <- data.frame()
for(year in 2016:2018){
  print(paste0('Scraping ', year, ' season (advanced) statistics!'))
  url <- paste0('https://www.basketball-reference.com/leagues/NBA_', year, '_advanced.html')
  data <- htmltab(url, which = 1)
  data$year <- year
  seasons_adv <- smartbind(seasons_adv, data)
  rm(data)
}
seasons_adv <- filter(seasons_adv, Player != 'Player')
seasons_adv <- seasons_adv %>% 
  group_by(Player, year) %>% 
  filter(row_number(year)==1)
seasons_adv[c(1,4,6:28)] <- apply(seasons_adv[c(1,4,6:28)], 2, function(x){as.numeric(x)})


# Player name matching----
nameChange <- function(oldname, newname){
  seasons$Player <<- str_replace(string = seasons$Player, pattern = oldname, replacement = newname)
  seasons_adv$Player <<- str_replace(string = seasons_adv$Player, pattern = oldname, replacement = newname)
}
nameChange('Derrick Jones', 'Derrick Jones Jr.')
nameChange('James Ennis', 'James Ennis III')
nameChange('Dennis Smith', 'Dennis Smith Jr.')
nameChange('Tim Hardaway', 'Tim Hardaway Jr.')
nameChange('Otto Porter', 'Otto Porter Jr.')
nameChange('Larry Nance', 'Larry Nance Jr.')
nameChange('Glenn Robinson', 'Glenn Robinson III')
nameChange('Kelly Oubre', 'Kelly Oubre Jr.')
nameChange('Walt Lemon, Jr.', 'Walt Lemon Jr.')
nameChange('Wade Baldwin', 'Wade Baldwin IV')
nameChange('Frank Mason', 'Frank Mason III')
nameChange('Derrick Walton', 'Derrick Walton Jr.')

seasons$Player2 <- paste0(substr(seasons$Player, 1, 1), '. ', substr(seasons$Player, regexpr(' ', seasons$Player)+1, nchar(seasons$Player)))
seasons_adv$Player2 <- paste0(substr(seasons_adv$Player, 1, 1), '. ', substr(seasons_adv$Player, regexpr(' ', seasons_adv$Player)+1, nchar(seasons_adv$Player)))


# Duplicate names
nameDup <- function(oldname, newname, team){
  depth$Player <<- ifelse(depth$Player == oldname & depth$teamAbbr == team, newname, depth$Player)
  seasons$Player2 <<- ifelse(seasons$Player == newname, newname, seasons$Player2)
  seasons_adv$Player2 <<- ifelse(seasons_adv$Player == newname, newname, seasons_adv$Player2)
}

nameDup('A. Johnson', 'Amir Johnson', 'PHI')
nameDup('A. Johnson', 'Alize Johnson', 'IND')
nameDup('B. Bogdanovic', 'Bojan Bogdanovic', 'IND')
nameDup('B. Bogdanovic', 'Bogdan Bogdanovic', 'SAC')
nameDup('D. Green', 'Draymond Green', 'GSW')
nameDup('D. Green', 'Danny Green', 'TOR')
nameDup('J. Evans', 'Jacob Evans', 'GSW')
nameDup('J. Evans', 'Jawun Evans', 'LAC')
nameDup('J. Grant', 'Jerami Grant', 'OKC')
nameDup('J. Grant', 'Jerian Grant', 'ORL')
nameDup('J. Holiday', 'Jrue Holiday', 'NOP')
nameDup('J. Holiday', 'Justin Holiday', 'CHI')
nameDup('J. Green', 'JaMychal Green', 'MEM')
nameDup('J. Green', 'Jeff Green', 'WAS')
nameDup('J. Jackson', 'Josh Jackson', 'PHO')
nameDup('J. Jackson', 'Justin Jackson', 'SAC')
nameDup('J. Smith', 'J.R. Smith', 'CLE')
nameDup('J. Smith', 'Jason Smith', 'WAS')
nameDup('M. Beasley', 'Malik Beasley', 'DEN')
nameDup('M. Beasley', 'Michael Beasley', 'LAL')
nameDup('M. Bridges', 'Miles Bridges', 'CHO')
nameDup('M. Bridges', 'Mikal Bridges', 'PHO')
nameDup('M. Morris', 'Monte Morris', 'DEN')
nameDup('M. Morris', 'Markieff Morris', 'WAS')
nameDup('M. Morris', 'Marcus Morris', 'BOS')
nameDup('M. Plumlee', 'Miles Plumlee', 'ATL')
nameDup('M. Plumlee', 'Mason Plumlee', 'DEN')
nameDup('S. Curry', 'Stephen Curry', 'GSW')
nameDup('S. Curry', 'Seth Curry', 'POR')
nameDup('T. Young', 'Trae Young', 'ATL')
nameDup('T. Young', 'Thaddeus Young', 'IND')
nameDup('J. Anderson', 'Justin Anderson', 'ATL')
nameDup('A. Harrison', 'Andrew Harrison', 'MEM')
nameDup('D. Williams', 'Derrick Williams', 'N/A')
nameDup('J. Crawford', 'Jordan Crawford', 'N/A')
nameDup('M. Williams', 'Marvin Williams', 'CHO')
nameDup('M. Williams', 'Matt Williams', 'N/A')
nameDup('T. Jones', 'Tyus Jones', 'MIN')
nameDup('D. Jones', 'Damian Jones', 'GSW')
nameDup('J. Johnson', 'James Johnson', 'MIA')
nameDup('J. Young', 'Joe Young', 'N/A')


# Player stats----
# Players' total minutes played & GS%
ps.stats <- seasons %>% 
  group_by(Player2) %>% 
  summarise(total_MP = sum(MP), G = sum(G), GS = sum(GS)) %>% 
  mutate(GSpct = GS/G, MP_per_game = total_MP/G)


# Weighted advanced stats
ps.advanced <- seasons_adv %>% left_join(ps.stats[,c('Player2', 'total_MP')], by = 'Player2') %>% 
  mutate(WS = WS*(MP/total_MP), BPM = BPM*(MP/total_MP)) %>% 
  group_by(Player2) %>% 
  summarise(WS = sum(WS), BPM = sum(BPM))
ps.stats <- left_join(ps.stats, ps.advanced, by = 'Player2') %>% 
  rename(Player = Player2)
rm(ps.advanced)

depth <- left_join(depth, ps.stats, by='Player')


# Impute stats for recent draftees----
drafts <- read.csv('.\\data\\drafts.csv', stringsAsFactors = F)
drafts <- drafts %>% 
  filter(Draft>=2016) %>% 
  select(-Rk)


# Name matching
drafts$Player <- str_replace(drafts$Player, 'Wendell Carter', 'Wendell Carter Jr.')
drafts$Player <- str_replace(drafts$Player, 'Michael Porter', 'Michael Porter Jr.')
drafts$Player <- str_replace(drafts$Player, 'Jaren Jackson', 'Jaren Jackson Jr.')
drafts$Player <- str_replace(drafts$Player, 'Melvin Frazier', 'Melvin Frazier Jr.')
drafts$Player <- str_replace(drafts$Player, 'Gary Trent', 'Gary Trent Jr.')
drafts$Player <- str_replace(drafts$Player, 'Marvin Bagley', 'Marvin Bagley III')
drafts$Player <- str_replace(drafts$Player, 'Lonnie Walker', 'Lonnie Walker IV')
drafts$Player <- str_replace(drafts$Player, 'Troy Brown', 'Troy Brown Jr.')

longname <- c('Trae Young', 'Miles Bridges', 'Mikal Bridges', 'Jacob Evans', 'Alize Johnson')
drafts$Player2 <- ifelse(drafts$Player %in% longname, drafts$Player, paste0(substr(drafts$Player, 1, 1), '. ', substr(drafts$Player, regexpr(' ', drafts$Player)+1, nchar(drafts$Player))))


# Assume 60th pick for undrafted, replace irrelevants with 0
depth <- left_join(depth, drafts[,c('Pick', 'Player2')], by = c('Player' = 'Player2'))
depth$Pick <- ifelse((is.na(depth$Pick) & is.na(depth$G)), 60, depth$Pick)
depth$Pick <- ifelse((is.na(depth$Pick) & depth$G > 0), 0, depth$Pick)


# Replace NAs with imputed predictions
rookie_pred <- read.csv('.\\data\\rookie_pred.csv', stringsAsFactors = F)

nonimputed <- depth %>% filter(!is.na(G)) %>% mutate(imputed = 0)
imputed <- depth %>% filter(is.na(G)) %>% mutate(imputed = 1)

imputed$WS <- rookie_pred[imputed$Pick, 'WS']
imputed$BPM <- rookie_pred[imputed$Pick, 'BPM']
imputed$total_MP <- rookie_pred[imputed$Pick, 'total_MP']
imputed$G <- rookie_pred[imputed$Pick, 'G']
imputed$GSpct <- rookie_pred[imputed$Pick, 'GSpct']
imputed$GS <- imputed$G * imputed$GSpct
imputed$MP_per_game <- imputed$total_MP / imputed$G

depth <- bind_rows(nonimputed, imputed) %>% 
  arrange(teamAbbr, Depth)
rm(nonimputed, imputed)


# Write to .csv
write.csv(depth, '.\\data\\depth.csv', row.names = F)
