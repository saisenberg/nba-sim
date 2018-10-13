from playoffInitialize import playoffInitialize
from playoffSeriesSim import playoffSeriesSim

# Simulate round 1 of playoffs
def simRound1(standings_combined, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
              win_prob_power, injury_freq, injury_print=False, result_print=False):
    playoffInitialize(depth)
    
    # Initialize seedings and matchups
    playoff_teams_east = standings_combined['east'][0:8]
    playoff_teams_west = standings_combined['west'][0:8]
    seeds1 = [(1,8), (2,7), (3,6), (4,5)]
    rd1 = {'east':[], 'west':[]}
    for seed_matchup in seeds1:
        team1 = playoff_teams_east[seed_matchup[0]-1][0]
        team2 = playoff_teams_east[seed_matchup[1]-1][0]
        rd1['east'].append({team1:seed_matchup[0], team2:seed_matchup[1]})
        team1 = playoff_teams_west[seed_matchup[0]-1][0]
        team2 = playoff_teams_west[seed_matchup[1]-1][0]
        rd1['west'].append({team1:seed_matchup[0], team2:seed_matchup[1]})
    
    # Simulate round 1
    if (injury_print) | (result_print):
        print('Round 1:\n--------')
    winners_rd1 = []
    for conf in rd1:
        for matchup in rd1[conf]:
            team1 = list(matchup.keys())[0]
            team2 = list(matchup.keys())[1]
            series_result = playoffSeriesSim(team1, team2, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
                                             win_prob_power, injury_freq, injury_print=injury_print, result_print=result_print)
            winner = max(series_result, key=series_result.get)
            winners_rd1.append(winner)
    if (injury_print) | (result_print):
        print('')
    
    return(winners_rd1)



# Simulate round 2 of playoffs
def simRound2(standings_combined, winners_rd1, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
              win_prob_power, injury_freq, injury_print=False, result_print=False):
    
    # Initialize seedings and matchups
    rd2 = {'east1458':[], 'east2367':[], 'west1458':[], 'west2367':[]}
    seeds2 = [(1,4,5,8), (2,3,6,7)]
    for team in winners_rd1:
        if team in [i[0] for i in standings_combined['east']]:
            seed = [i[0] for i in standings_combined['east']].index(team)+1
            if seed in seeds2[0]:
                rd2['east1458'].append(team)
            elif seed in seeds2[1]:
                rd2['east2367'].append(team)
        elif team in [i[0] for i in standings_combined['west']]:
            seed = [i[0] for i in standings_combined['west']].index(team)+1
            if seed in seeds2[0]:
                rd2['west1458'].append(team)
            elif seed in seeds2[1]:
                rd2['west2367'].append(team)
    
    # Simulate round 2
    if (injury_print) | (result_print):
        print('Round 2:\n--------')
    winners_rd2 = []
    for matchup in rd2:
        team1 = rd2[matchup][0]
        team2 = rd2[matchup][1]
        series_result = playoffSeriesSim(team1, team2, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
                                         win_prob_power, injury_freq, injury_print=injury_print, result_print=result_print)
        winner = max(series_result, key=series_result.get)
        winners_rd2.append(winner)
    if (injury_print) | (result_print):
        print('')
    
    return(winners_rd2)



# Simulate round 3 of playoffs (conference championship)
def simRound3(standings_combined, winners_rd2, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
              win_prob_power, injury_freq, injury_print=False, result_print=False):
    
    # Initialize seedings and matchups
    rd3 = {'east':[], 'west':[]}
    for team in winners_rd2:
        if team in [i[0] for i in standings_combined['east']]:
            rd3['east'].append(team)
        elif team in [i[0] for i in standings_combined['west']]:
            rd3['west'].append(team)
    
    # Simulate round 3
    if (injury_print) | (result_print):
        print('Round 3:\n--------')
    winners_rd3 = []
    for matchup in rd3:
        team1 = rd3[matchup][0]
        team2 = rd3[matchup][1]
        series_result = playoffSeriesSim(team1, team2, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
                                         win_prob_power, injury_freq, injury_print=injury_print, result_print=result_print)
        winner = max(series_result, key=series_result.get)
        winners_rd3.append(winner)
    if (injury_print) | (result_print):
        print('')
    
    return(winners_rd3)



# Simulate Finals
def simFinals(winners_rd3, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
              win_prob_power, injury_freq, injury_print=False, result_print=False):
    if (injury_print) | (result_print):
        print('Finals:\n--------')
    team1 = winners_rd3[0]
    team2 = winners_rd3[1]
    series_result = playoffSeriesSim(team1, team2, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
                                     win_prob_power, injury_freq, injury_print=injury_print, result_print=result_print)
    winner = max(series_result, key=series_result.get)
    if (injury_print) | (result_print):
        print('')
    return(winner)
  
    

# Simulate entire playoffs
def simPlayoffs(standings_combined, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
                win_prob_power, injury_freq, injury_print=False, result_print=False):
    winners_rd1 = simRound1(standings_combined, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
                            win_prob_power, injury_freq, injury_print, result_print)
    winners_rd2 = simRound2(standings_combined, winners_rd1, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
                            win_prob_power, injury_freq, injury_print, result_print)
    winners_rd3 = simRound3(standings_combined, winners_rd2, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
                            win_prob_power, injury_freq, injury_print, result_print)
    winner = simFinals(winners_rd3, depth, injuries, cities, city_abbrvs, pca_s, pca_b, RF, 
                       win_prob_power, injury_freq, injury_print, result_print)
    runnerup = [team for team in winners_rd3 if team is not winner][0]
    semifinal_east = [team for team in winners_rd2 if team not in [winner, runnerup]][0]
    semifinal_west = [team for team in winners_rd2 if team not in [winner, runnerup]][1]
    return(winner, runnerup, semifinal_east, semifinal_west)