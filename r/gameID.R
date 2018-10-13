# Unique game ID
makegameID <- function(x, dateIndex, teamAbbr_index, opptAbbr_index){
  
  gmDate <- paste0(year(x[dateIndex]), '-', month(x[dateIndex]), '-', day(x[dateIndex]))
  
  teams <- sort(c(x[teamAbbr_index], x[opptAbbr_index]))
  team1 <- teams[1]
  team2 <- teams[2]
  
  return(paste0(gmDate, '-', team1, 'x', team2))
}