# Scrapes NBA regular and advanced stats for all relevant players

library(dplyr)
library(openxlsx)
library(stringr)

stats1 <- read.xlsx('.\\data\\2016-17_playerBoxScore_utf8.xlsx')
stats1$season <- 2017
stats2 <- read.xlsx('.\\data\\2017-18_playerBoxScore_utf8.xlsx')
stats2$season <- 2018
stats <- rbind(stats1, stats2)
rm(stats1, stats2)

# Collect and clean season-by-season regular stats
seasons <- data.frame()
for(year in (min(stats$season)-3):(max(stats$season)-1)){
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


# Collect and clean season-by-season advanced stats
seasons_adv <- data.frame()
for(year in (min(stats$season)-3):(max(stats$season)-1)){
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
# Player full name
stats$playFullNm <- paste(stats$playFNm, stats$playLNm)
stats$playFullNm <- iconv(stats$playFullNm, from = 'UTF-8', to='ASCII//TRANSLIT')


# Match names between frames
stats$playFullNm <- str_replace(stats$playFullNm, 'Earl Smith', 'J.R. Smith')
stats$playFullNm <- str_replace(stats$playFullNm, 'Christian McCollum', 'CJ McCollum')
stats$playFullNm <- str_replace(stats$playFullNm, 'Edward Davis', 'Ed Davis')
stats$playFullNm <- str_replace(stats$playFullNm, 'Joseph Ingles', 'Joe Ingles')
stats$playFullNm <- str_replace(stats$playFullNm, 'Jeffree Withey', 'Jeff Withey')
stats$playFullNm <- str_replace(stats$playFullNm, 'Wardell Curry', 'Stephen Curry')
stats$playFullNm <- str_replace(stats$playFullNm, 'Emanuel Ginobili', 'Manu Ginobili')
stats$playFullNm <- str_replace(stats$playFullNm, 'Patrick Mills', 'Patty Mills')
stats$playFullNm <- str_replace(stats$playFullNm, 'Jose Barea', 'J.J. Barea')
stats$playFullNm <- str_replace(stats$playFullNm, 'Calvin Miles', 'C.J. Miles')
stats$playFullNm <- str_replace(stats$playFullNm, 'Joseph Young', 'Joe Young')
stats$playFullNm <- str_replace(stats$playFullNm, 'Christopher McCullough', 'Chris McCullough')
stats$playFullNm <- str_replace(stats$playFullNm, 'Ishmael Smith', 'Ish Smith')
stats$playFullNm <- str_replace(stats$playFullNm, 'Jakob Poltl', 'Jakob Poeltl')
stats$playFullNm <- str_replace(stats$playFullNm, 'William Barton', 'Will Barton')
stats$playFullNm <- str_replace(stats$playFullNm, 'Michael Conley', 'Mike Conley')
stats$playFullNm <- str_replace(stats$playFullNm, 'Vincent Carter', 'Vince Carter')
stats$playFullNm <- str_replace(stats$playFullNm, 'Zachary LaVine', 'Zach LaVine')
stats$playFullNm <- str_replace(stats$playFullNm, 'Chavano Hield', 'Buddy Hield')
stats$playFullNm <- str_replace(stats$playFullNm, 'Guillermo Hernangomez', 'Willy Hernangomez')
stats$playFullNm <- str_replace(stats$playFullNm, 'Kehinde Oladipo', 'Victor Oladipo')
stats$playFullNm <- str_replace(stats$playFullNm, 'Alejandro Abrines', 'Alex Abrines')
stats$playFullNm <- str_replace(stats$playFullNm, 'Nikolas Stauskas', 'Nik Stauskas')
stats$playFullNm <- str_replace(stats$playFullNm, 'Houston Grant', 'Jerami Grant')
stats$playFullNm <- str_replace(stats$playFullNm, 'Timothy McConnell', 'T.J. McConnell')
stats$playFullNm <- str_replace(stats$playFullNm, 'Keith Thompson', 'Hollis Thompson')
stats$playFullNm <- str_replace(stats$playFullNm, 'Anthony Warren', 'T.J. Warren')
stats$playFullNm <- str_replace(stats$playFullNm, 'Oleksiy Len', 'Alex Len')
stats$playFullNm <- str_replace(stats$playFullNm, 'Anthony Tucker', 'P.J. Tucker')
stats$playFullNm <- str_replace(stats$playFullNm, 'Konstantine Koufos', 'Kosta Koufos')
stats$playFullNm <- str_replace(stats$playFullNm, 'Samuel Dekker', 'Sam Dekker')
stats$playFullNm <- str_replace(stats$playFullNm, 'Louis Williams', 'Lou Williams')
stats$playFullNm <- str_replace(stats$playFullNm, 'Michael Muscala', 'Mike Muscala')
stats$playFullNm <- str_replace(stats$playFullNm, 'Timothy Hardaway', 'Tim Hardaway')
stats$playFullNm <- str_replace(stats$playFullNm, 'Taurean Prince', 'Taurean Waller-Prince')
stats$playFullNm <- str_replace(stats$playFullNm, 'Alfonso Burke', 'Trey Burke')
stats$playFullNm <- str_replace(stats$playFullNm, 'Sheldon McClellan', 'Sheldon Mac')
stats$playFullNm <- str_replace(stats$playFullNm, 'Douglas McDermott', 'Doug McDermott')
stats$playFullNm <- str_replace(stats$playFullNm, 'Jonathan Redick', 'J.J. Redick')
stats$playFullNm <- str_replace(stats$playFullNm, 'Luc Richard Mbah a Moute', 'Luc Mbah a Moute')
stats$playFullNm <- str_replace(stats$playFullNm, 'Brian Wilcox', 'C.J. Wilcox')
stats$playFullNm <- str_replace(stats$playFullNm, 'Charles Watson', 'C.J. Watson')
stats$playFullNm <- str_replace(stats$playFullNm, 'Aaron Hammons', 'A.J. Hammons')
stats$playFullNm <- str_replace(stats$playFullNm, 'Walter Tavares', 'Edy Tavares')
stats$playFullNm <- str_replace(stats$playFullNm, 'Francis Kaminsky', 'Frank Kaminsky')
stats$playFullNm <- str_replace(stats$playFullNm, 'Kahlil Felder', 'Kay Felder')
stats$playFullNm <- str_replace(stats$playFullNm, 'James McAdoo', 'James Michael McAdoo')
stats$playFullNm <- str_replace(stats$playFullNm, 'Patrick Connaughton', 'Pat Connaughton')
stats$playFullNm <- str_replace(stats$playFullNm, 'Holdyn Grant', 'Jerian Grant')
stats$playFullNm <- str_replace(stats$playFullNm, 'John Lucas', 'John Lucas III')
stats$playFullNm <- str_replace(stats$playFullNm, 'Kevin Ferrell', 'Yogi Ferrell')
stats$playFullNm <- str_replace(stats$playFullNm, 'Joshua McRoberts', 'Josh McRoberts')
stats$playFullNm <- str_replace(stats$playFullNm, 'Ronald Hunter', 'R.J. Hunter')
stats$playFullNm <- str_replace(stats$playFullNm, 'Reginald Bullock', 'Reggie Bullock')
stats$playFullNm <- str_replace(stats$playFullNm, 'Ronald Price', 'Ronnie Price')
stats$playFullNm <- str_replace(stats$playFullNm, 'Michael Tobey', 'Mike Tobey')
stats$playFullNm <- str_replace(stats$playFullNm, 'Jonathan Johnson', 'Brice Johnson')
stats$playFullNm <- str_replace(stats$playFullNm, 'Benjamin Bentil', 'Ben Bentil')
stats$playFullNm <- str_replace(stats$playFullNm, 'Jesusemilore Ojeleye', 'Semi Ojeleye')
stats$playFullNm <- str_replace(stats$playFullNm, 'DeShane Larkin', 'Shane Larkin')
stats$playFullNm <- str_replace(stats$playFullNm, 'Ty Leaf', 'T.J. Leaf')
stats$playFullNm <- str_replace(stats$playFullNm, 'Edrice Adebayo', 'Bam Adebayo')
stats$playFullNm <- str_replace(stats$playFullNm, 'Benjamin Simmons', 'Ben Simmons')
stats$playFullNm <- str_replace(stats$playFullNm, 'James Scott', 'Mike Scott')
stats$playFullNm <- str_replace(stats$playFullNm, 'Joshua Jackson', 'Josh Jackson')
stats$playFullNm <- str_replace(stats$playFullNm, 'Michael James', 'Mike James')
stats$playFullNm <- str_replace(stats$playFullNm, 'Ogugua Anunoby', 'OG Anunoby')
stats$playFullNm <- str_replace(stats$playFullNm, 'Christopher Anigbogu', 'Ike Anigbogu')
stats$playFullNm <- str_replace(stats$playFullNm, 'DeVante Wilson', 'D.J. Wilson')
stats$playFullNm <- str_replace(stats$playFullNm, 'Maximilian Kleber', 'Maxi Kleber')
stats$playFullNm <- str_replace(stats$playFullNm, 'Joshua Smith', 'Josh Smith')
stats$playFullNm <- str_replace(stats$playFullNm, 'Vincent Hunter', 'Vince Hunter')
stats$playFullNm <- str_replace(stats$playFullNm, 'Matthew Williams', 'Matt Williams')
stats$playFullNm <- str_replace(stats$playFullNm, 'Nazareth Mitrou-Long', 'Naz Mitrou-Long')
stats$playFullNm <- str_replace(stats$playFullNm, 'Joshia Gray', 'Josh Gray')
stats$playFullNm <- str_replace(stats$playFullNm, 'Demarious Brown', 'Markel Brown')
stats$playFullNm <- str_replace(stats$playFullNm, 'Perry Dozier', 'PJ Dozier')
stats$playFullNm <- str_replace(stats$playFullNm, 'Walter Lemon', 'Walt Lemon, Jr.')
stats$playFullNm <- str_replace(stats$playFullNm, 'Brian Hopson', 'Scotty Hopson')

seasons <- filter(seasons, Player %in% stats$playFullNm)
seasons_adv <- filter(seasons_adv, Player %in% stats$playFullNm)


# More preprocessing----
# Format game date/time
stats$gmDate <- as.Date(stats$gmDate, origin = "1899-12-30")
stats$gmTime <- 24 * stats$gmTime
stats$gmTime <- ifelse(stats$gmTime > 12, stats$gmTime - 12, stats$gmTime)
stats$gmHour <- floor(stats$gmTime)
stats$gmMin <- 60 * (stats$gmTime - stats$gmHour)
stats$gmHour <- stats$gmHour + 12
stats$gmMin <- ifelse(stats$gmMin == 0, "00", stats$gmMin)
stats$gmDateTime <- as.POSIXct(strptime(paste0(stats$gmDate, " ", stats$gmHour, ":", stats$gmMin), format = '%Y-%m-%d %H:%M'))


# Order the starter/bench factor
stats$playStat <- factor(stats$playStat, levels = c('Starter', 'Bench'))


# Unique lineup ID
stats$lineupID <- paste0(stats$gmDate, '-', stats$teamAbbr)
stats$opptlineupID <- paste0(stats$gmDate, '-', stats$opptAbbr)
stats <- arrange(stats, gmDateTime, lineupID, playStat, desc(playMin))


# Unique game ID
source('.\\r\\gameID.R')
stats$gameID <- apply(stats, 1, makegameID, which(names(schedule)=='gmDate'), which(names(schedule)=='teamAbbr'), which(names(schedule)=='opptAbbr'))


# Separately group data (Prior 3 years for 2017 and 2018)
seasons1 <- seasons %>% filter(year %in% c(2014:2016)) %>% mutate(yeargroup = 2017)
seasons2 <- seasons %>% filter(year %in% c(2015:2017)) %>% mutate(yeargroup = 2018)
seasons <- bind_rows(seasons1, seasons2)
rm(seasons1, seasons2)

seasons_adv1 <- seasons_adv %>% filter(year %in% c(2014:2016)) %>% mutate(yeargroup = 2017)
seasons_adv2 <- seasons_adv %>% filter(year %in% c(2015:2017)) %>% mutate(yeargroup = 2018)
seasons_adv <- bind_rows(seasons_adv1, seasons_adv2)
rm(seasons_adv1, seasons_adv2)


write.csv(stats, '.\\data\\stats.csv', row.names = F)
write.csv(seasons, '.\\data\\seasons.csv', row.names = F)
write.csv(seasons_adv, '.\\data\\seasons_adv.csv', row.names = F)