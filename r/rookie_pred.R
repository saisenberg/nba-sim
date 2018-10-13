# Predict rookie-year production by draft position

library(dplyr)
library(ggplot2)
library(gtools)
library(htmltab)
library(tidyr)

# Scrape all rookie-year statistics (2007-2016)----
urlstart <- 'https://www.basketball-reference.com/play-index/psl_finder.cgi?request=1&match=single&type=advanced&per_minute_base=36&per_poss_base=100&lg_id=NBA&is_playoffs=N&year_min=&year_max=&franch_id=&season_start=1&season_end=1&age_min=0&age_max=99&shoot_hand=&height_min=0&height_max=99&birth_country_is=Y&birth_country=&birth_state=&college_id=&draft_year=&is_active=&debut_yr_nba_start=2007&debut_yr_nba_end=2016&is_hof=&is_as=&as_comp=gt&as_val=0&award=&pos_is_g=Y&pos_is_gf=Y&pos_is_f=Y&pos_is_fg=Y&pos_is_fc=Y&pos_is_c=Y&pos_is_cf=Y&qual=&c1stat=&c1comp=&c1val=&c2stat=&c2comp=&c2val=&c3stat=&c3comp=&c3val=&c4stat=&c4comp=&c4val=&c5stat=&c5comp=&c6mult=&c6stat=&order_by=ws&order_by_asc=&offset='

rookies <- data.frame()

for(i in c(0, seq(100,700,100))){
  url <- paste0(urlstart, i)
  data <- htmltab(url, which=1)
  rookies <- smartbind(rookies, data)
  rm(data)
}

# Clean rookies dataframe----
rookies <- rookies %>% filter(Player != 'Player')
rookies$Season <- as.numeric(substr(rookies$Season, 1, 4))
names(rookies) <- c('Rk', 'Player', 'Season', 'Age', 'Tm', 'Lg', 'WS', 'G', 'GS', 'MP', 'PER', '_3PAr', 'FTr', 
                    'ORB%', 'DRB%', 'TRB%', 'AST%', 'STL%', 'BLK%', 'TOV%', 'USG%', 'ORtg', 'DRtg', 'OWS', 'DWS', 
                    'WS/48', 'OBPM', 'DBPM', 'BPM', 'VORP')
rookies[,c(1,3,4,7:30)] <- apply(rookies[,c(1,3,4,7:30)], 2, function(x) as.numeric(x))
rookies$GSpct <- rookies$GS / rookies$G

# Import draft pick dataframe (see drafts.R)---- 
drafts <- read.csv('C:\\Users\\Sam\\Documents\\DATA\\NBA season projections\\Raw data\\drafts.csv')
drafts <- drafts %>% filter(Draft >= 2006) %>% select(-Rk)
drafts$Player <- as.character(drafts$Player)

# Fix instances of different players with same name
rookies[rookies$Player == 'Tony Mitchell' & rookies$Tm == 'MIL',]$Player <- 'Tony Mitchell (2)'
drafts[drafts$Player == 'Marcus Thornton' & drafts$Draft == 2015,]$Player <- 'Marcus Thornton (2)'

rookies[rookies$Player == 'Marcus Williams' & rookies$Tm == 'NJN',]$Player <- 'Marcus Williams (1)'
rookies[rookies$Player == 'Marcus Williams' & rookies$Tm == 'TOT',]$Player <- 'Marcus Williams (2)'
drafts[drafts$Player == 'Marcus Williams' & drafts$Draft == 2006,]$Player <- 'Marcus Williams (1)'
drafts[drafts$Player == 'Marcus Williams' & drafts$Draft == 2007,]$Player <- 'Marcus Williams (2)'

# Aggregate stats by draft pick----

# Aggregate WS, BPM, and MP stats by draft pick
rookie_stats <- left_join(drafts, rookies, by = c('Player'='Player')) %>% select(-Rk)
rookie_stats[is.na(rookie_stats)] <- 0
rookie_stats <- rookie_stats %>% filter(G > 0) %>% group_by(Pick) %>% summarise(medianWS = median(WS), medianBPM = median(BPM), medianMP= median(MP), medianG = median(G) , medianGSpct = median(GSpct))

# Create loess curves
loess.WS <- loess(formula = medianWS~Pick, data = rookie_stats, span = 0.45, weights = c(5, rep(2,4), rep(1,55)))
loess.BPM <- loess(formula = medianBPM~Pick, data = rookie_stats, span = 0.5, weights = c(5, rep(2,4), rep(1,55)))
loess.MP <- loess(formula = medianMP~Pick, data = rookie_stats, span = 0.6, weights = c(5, rep(2,4), rep(1,55)))
loess.G <- loess(formula = medianG~Pick, data = rookie_stats, span = 0.7, weights = c(5, rep(2,4), rep(1,55)))
loess.GSpct <- loess(formula = medianGSpct~Pick, data = rookie_stats, span = 0.6, weights = c(3, rep(1, 59)))

rookie_stats$fit_medianWS <- loess.WS$fitted
rookie_stats$fit_medianBPM <- loess.BPM$fitted
rookie_stats$fit_medianMP <- loess.MP$fitted
rookie_stats$fit_medianG <- loess.G$fitted
rookie_stats$fit_medianGSpct <- loess.GSpct$fitted

rookie_stats <- gather(rookie_stats, stat, val, medianWS:fit_medianGSpct)

# Plot loess curves against actual stats
# WS
ggplot(rookie_stats[rookie_stats$stat %in% c('medianWS', 'fit_medianWS'),], aes(x=Pick, y=val, color=stat)) + geom_point() + scale_color_manual(values = c('darkorange2', 'grey14')) + ggtitle('Median WS') + theme_minimal() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(color="black"))

# BPM
ggplot(rookie_stats[rookie_stats$stat %in% c('medianBPM', 'fit_medianBPM'),], aes(x=Pick, y=val, color=stat)) + geom_point() + scale_color_manual(values = c('darkorange2', 'grey14')) + ggtitle('Median BPM') + theme_minimal() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(color="black"))

# MP
ggplot(rookie_stats[rookie_stats$stat %in% c('medianMP', 'fit_medianMP'),], aes(x=Pick, y=val, color=stat)) + geom_point() + scale_color_manual(values = c('darkorange2', 'grey14')) + ggtitle('Median MP') + theme_minimal() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(color="black"))

# G
ggplot(rookie_stats[rookie_stats$stat %in% c('medianG', 'fit_medianG'),], aes(x=Pick, y=val, color=stat)) + geom_point() + scale_color_manual(values = c('darkorange2', 'grey14')) + ggtitle('Median G') + theme_minimal() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(color="black"))

# GSpct
ggplot(rookie_stats[rookie_stats$stat %in% c('medianGSpct', 'fit_medianGSpct'),], aes(x=Pick, y=val, color=stat)) + geom_point() + scale_color_manual(values = c('darkorange2', 'grey14')) + ggtitle('Median GSpct') + theme_minimal() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(color="black"))


rookie_pred <- as.data.frame(cbind(seq(1,60), predict(loess.WS), predict(loess.BPM), predict(loess.MP), predict(loess.G), predict(loess.GSpct)))
names(rookie_pred) <- c('Pick', 'WS', 'BPM', 'total_MP', 'G', 'GSpct')

write.csv(rookie_pred, '.\\data\\rookie_pred.csv', row.names = FALSE)
