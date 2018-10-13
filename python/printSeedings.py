# Print seedings
def printSeedings(standings_dict):
    for num, team in enumerate(standings_dict):
        print(str(num+1), '. ', team[0], ' ', round(team[1],1), sep='')