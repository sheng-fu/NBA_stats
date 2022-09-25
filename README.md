# NBA_stats
Calculating and visualizing some NBA stats

## Quantifying shot difficulty
Data from NBA.com: <br>
[Closest Defender](https://www.nba.com/stats/players/shots-closest-defender)  <br>
[Shooting](https://www.nba.com/stats/players/shooting) <br>

**Shot Difficulty (Linear Residuals)**: Negative residuals of average defender distance predicted by average shot distance

![This is an image](https://raw.githubusercontent.com/sheng-fu/NBA_stats/main/shot_difficulty.png)


## Quantifying consistency
Data from [Basketball Reference](https://www.basketball-reference.com/) <br>
Based 2021-22 season 

**Global consistency**: Negative residuals of standard deviation of a player's GmSc  predicted by average GmSc, average minutes per game, and standard deviation of minutes per game

![This is an image](https://raw.githubusercontent.com/sheng-fu/NBA_stats/main/consistency_glob_2022.png)

**Local consistency**: Negative residuals of standard deviation of a player's mean GmSc difference between games predicted by average GmSc, average minutes per game, and average difference of minutes between games

![This is an image](https://raw.githubusercontent.com/sheng-fu/NBA_stats/main/consistency_loc_2022.png)


## Quantifying whether players have bigger roles on winning teams
Data from [Basketball Reference](https://www.basketball-reference.com/) <br>
Based on top active 100 players in minutes per game

**BORROW (Bigger Offensive Roles, Relatively, On Winners)**: 
to what extent a player has had bigger offensive roles (and more playing time) in wins <br>

![This is an image](https://raw.githubusercontent.com/sheng-fu/NBA_stats/main/BORROW.png)

**PLOW (Playing Longer On Winners)**: 
to what extent a player has played more minutes in wins
![This is an image](https://raw.githubusercontent.com/sheng-fu/NBA_stats/main/PLOW.png)



(More descriptions and stats to come!)
