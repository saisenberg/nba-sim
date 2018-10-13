import pandas as pd

# Initialize season
def initialize(schedules, east, depth):
    global injuries
    global standings
    
    standings = {team:{'W':0, 'L':0} for team in sorted(list(schedules['teamAbbr'].unique()))}
    for team in standings:
        if team in east:
            standings[team]['conf'] = 'E'
        else:
            standings[team]['conf'] = 'W'
    
    # Initialize injuries (# games)
    # Sourced from CBSSports & RotoWorld
    injuries = {player: 0 for player in list(depth.Player)}

    injuries['A. Ajinca'] = 10   # Out indefinitely
    injuries['A. Roberson'] = 25   # 12/1
    injuries['Bogdan Bogdanovic'] = 10   # 11/1
    injuries['B. Knight'] = 25   # Out indefinitely
    injuries['D. Booker'] = 10   # 11/1
    injuries['D. Cousins'] = 10   # 11/1
    injuries['D. Murray'] = (82+16)   # Out for season
    injuries['D. Waiters'] = 35   # Out indefinitely
    injuries['I. Thomas'] = 25   # Out indefinitely
    injuries['Justin Anderson'] = 41   # Out indefinitely
    injuries['J. Bayless'] = 10   # Out indefinitely
    injuries['J. Butler'] = (82+16)   # Refuses to play
    injuries['J. Noah'] = (82+16)   # Waived
    injuries['J. Meeks'] = 19   # Susp. 19 games
    injuries['J. Patton'] = 40   # 1/1
    injuries['J. Vanderbilt'] = 41   # Out indefinitely
    injuries['K. Porzingis'] = 35   # 12/25
    injuries['L. Markkanen'] = 25   # 11/30
    injuries['L. Walker IV'] = 15 # 11/17
    injuries['M. Porter Jr.'] = 41   # Out indefinitely
    injuries['O. Asik'] = 50   # Out indefinitely
    injuries['W. Chandler'] = 5   # 2-3 weeks
    injuries['Z. Smith'] = 40 # 1/1

    # Add InjuryTime column to depth df
    depth['InjuryTime'] = depth.apply(lambda x: injuries[x['Player']], axis=1)
        
    return(standings, injuries, depth)