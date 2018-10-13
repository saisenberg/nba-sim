# Scrape draft pick data (2000-2018)

library(dplyr)
library(gtools)
library(htmltab)

urlstart <- 'https://www.basketball-reference.com/draft/NBA_'
urlend <- '.html'

drafts <- data.frame()
for(year in 2000:2018){
  print(paste0('Scraping ', year, ' Draft!'))
  
  url <- paste0(urlstart, year, urlend)
  data <- htmltab(url, which = 1)

  cols <- c('Rk', 'Pick', 'Team', 'Player')
  names(data)[1:4] <- cols
  data <- data %>% filter(!(Player %in% c('Round 2', 'Player')), nchar(Pick)<=3) %>% select(cols) %>% mutate(Draft = year)
  drafts <- smartbind(drafts, data)
  
}

write.csv(drafts, '.\\data\\drafts.csv', row.names = F)
