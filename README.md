

## Simulating the 2018-19 NBA Season

The 2018-19 NBA season begins on Tuesday, October 16. This project trains a model on the past two years of NBA games, and uses it to simulate five hundred iterations of the 2018-19 NBA season. Ultimately, we achieve a full set of projected standings for the year.

A full description of the project can be found at [**saisenberg.com**](https://saisenberg.com/projects/nba-sim.html).

### Getting started

#### Prerequisite software

* Python (suggested install through [Anaconda](https://www.anaconda.com/download/))


* [R](https://www.r-project.org/)

#### Prerequisite libraries

* Python:
    - bs4, datetime, math, numpy, operator, os, pandas, random (```all installed with Anaconda```)
    

* R:

```
lib <- c('dplyr', 'ggplot2', 'gtools', 'htmltab', 'lubridate', 'maps', 'openxlsx', 'splitstackshape', 'stringi', 'stringr', 'tidyr')
install_packages(lib)
```
    
    
### Instructions for use

#### Skip to step 4 to bypass all web scraping, data cleaning, and data aggregation.

#### 1. Web scraping - 2016-17 and 2017-18 seasons

a) Run */r/drafts.R*

This program scrapes and cleans all post-2000 NBA draft history from [*basketball-reference*](https://basketball-reference.com). The output of */r/drafts.R* can also be found at */data/drafts.csv*.

b) Run */r/rookie_pred.R*

This program scrapes and cleans the last ten years' worth of rookie-year statistics from [*basketball-reference*](https://basketball-reference.com) and imputes rookie statistics based on draft pick. The output of */r/rookie_pred.R* can also be found at */data/rookie_pred.csv*.

c) Run */r/nba_stats.R*

This program scrapes and cleans [*basketball-reference*](https://basketball-reference.com) for player statistics. The output of */r/nba_stats.R* can be also be found at */data/stats.csv*, */data/seasons.csv*, and */data/seasons_adv.csv*.

d) Run */r/records.R*

This program scrapes [*basketball-reference*](https://basketball-reference.com) for historical team win-loss records. The output of */r/records.R* can also be found at */data/records.csv*.

e) Run */r/nba_proj.R*

This program aggregates season-by-season player statistics at the lineup level for 2016-17 and 2017-18 games. The output of */r/nba_proj.R* can also be found at */data/results.csv*.

#### 2. Train model

f) Run the code contained in */python/nba_select_model.ipynb*

This code trains a series of models (logistic regression, decision trees, random forests, and gradient boosted trees) on 2016-17 and 2017-18 season data. In this case, random forests consistently produce the best results.

g) Run the code contained in */python/nba_tune_model.ipynb*

This code repeatedly performs grid search to identify optimal parameters of the random forest model. These parameters are a *max_depth* of 4, *max_features* of 5, and *min_samples_leaf* of 5. 

#### 3. Web scraping - 2018-19 season

h) Run the code contained in */python/depth_chart_scraper.ipynb*

This code scrapes and organizes NBA depth charts from [*ESPN*](http://www.espn.com/nba/depth/_/type/print).

i) Run */r/2018-19_schedule.R*

This program scrapes [*basketball-reference*](https://basketball-reference.com) for each team's 2018-19 schedule. The output of */r/2018-19_schedule.R* can also be found at */data/schedules.csv*.

j) Run */r/2018-19_stats.R*

This program aggregates and organizes statistics for all 2018-19 NBA players and merges results with the team depth charts (see step (h)). The output of */r/2018-19_stats.R* can also be found at */data/depth.csv*.

#### 4. Simulate 2018-19 season

k) Run */python/fullPrep.py* and */python/fullSim.py* (consecutively)

Make sure to change your working directory to */python/* in both .py files.

* *fullPrep.py* loads and prepares the necessary functions and .csv files for simulating an NBA season. 

* *fullSim.py* simulates the NBA regular season and playoffs [*num_season_sim*] and [*num_playoff_sim*] number of times, respectively.

  * The following *fullSim* parameters can be changed:
    * *num_season_sim* (default = 1) - the number of regular seasons to simulate
    * *num_playoffs_sim* (default = 1) - the number of playoffs to simulate (using the mean playoff seedings of all season simulations)
    * *win_prob_power* (default = 1.4) - the power to which every lineup's respective win probability is raised
    * *injury_freq* (default = 700 for regular season; 900 for playoffs) - the probability of player injury. Note that higher numbers corresponds with *fewer* injuries; an *injury_freq* of 1/700, for instance, means that one in every seven hundred players will suffer an injury
    * *injury_print* (default = False) - whether injuries are printed throughout each simulated season



### Author

* **Sam Isenberg** - [saisenberg.com](https://saisenberg.com) | [github.com/saisenberg](https://github.com/saisenberg)


### License

This project is licensed under the MIT License - see the *LICENSE.md* file for details.

### Acknowledgements

* [basketball-reference](https://basketball-reference.com)
* [CBS Sports](https://cbssports.com/nba/injuries/)
* [ESPN](http://www.espn.com/nba/depth/_/type/print)
* [Paul Rossotti](https://www.kaggle.com/pablote/nba-enhanced-stats)
* [RotoWorld](http://rotoworld.com/teams/injuries/nba/all/)
