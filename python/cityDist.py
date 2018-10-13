import numpy as np

# Calculate distance between two cities
def cityDist(team1, team2, cities, city_abbrvs):
    ll1 = np.array((cities.loc[city_abbrvs[team1]].lat, cities.loc[city_abbrvs[team1]].long))
    ll2 = np.array((cities.loc[city_abbrvs[team2]].lat, cities.loc[city_abbrvs[team2]].long))
    distance = np.linalg.norm(ll1-ll2)
    return(distance)