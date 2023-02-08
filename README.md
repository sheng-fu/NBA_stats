# NBA_stats
Calculating and visualizing some NBA stats

## Quantifying the odds-defying nature of a player's cumulative achievement
Data from [Basketball Reference](https://www.basketball-reference.com/) <br>
Using an adapted version of the "[Favorite Toy](https://www.baseball-reference.com/bullpen/Favorite_toy)" formula <br>

Odds of scoring totals for some players based on their first three years <br>

LeBron James: 28.0%  <br>
Kareem Abdul-Jabbar: 29.1% <br>
Hakeem Olajuwon: 28.5% <br>
Tim Duncan: 31.4% <br>
Michael Jordan: 41.3% (two retirements)  <br>
Carmelo Anthony: 42.0% (big decline towards the end) <br>
Allen Iverson: 58.4% (relatively early decline) <br>
Grant Hill: 70.9% (career detrailed by injuries) <br>
Wilt Chamberlain: 88.8%! (peaked early, a peak including a 50-ppg season) <br>
Udonis Haslem: 98.1% (steadily declining role player) <br>
Yao Ming: 100% (career ended super early; number is actually 193%) <br>
Tyreke Evans: 100% (peaked early; career ended early; number is actually 207%) <br>

Kobe Bryant: 1.1% (23.7% if using years 3-5) <br>
Dirk Nowitzki: 2.3% (16.7% is using years 2-4) <br>


## Quantifying shot difficulty
Data from NBA.com: <br>
[Closest Defender](https://www.nba.com/stats/players/shots-closest-defender)  <br>
[Shooting](https://www.nba.com/stats/players/shooting) <br>

**Shot Difficulty (Linear Residuals)**: Negative residuals of average defender distance predicted by average shot distance

![This is an image](https://raw.githubusercontent.com/sheng-fu/NBA_stats/main/shot_difficulty.png)


## Quantifying consistency
Data from [Basketball Reference](https://www.basketball-reference.com/) <br>
Based on the 2021-22 season 

**Simple global consistency**: Standard deviation of GmSc divided by Standard deviation of minutes per game

![This is an image](https://raw.githubusercontent.com/sheng-fu/NBA_stats/main/consistency_simp_glob_2022.png)

**Global consistency (linear residuals)**: Negative residuals of standard deviation of a player's GmSc  predicted by average GmSc, average minutes per game, and standard deviation of minutes per game

![This is an image](https://raw.githubusercontent.com/sheng-fu/NBA_stats/main/consistency_glob_2022.png)

**Simple local consistency**: A player's mean GmSc difference between games divided by mean minutes difference between game

![This is an image](https://raw.githubusercontent.com/sheng-fu/NBA_stats/main/consistency_simp_loc_2022.png)

**Local consistency (linear residuals)**: Negative residuals of standard deviation of a player's mean GmSc difference between games predicted by average GmSc, average minutes per game, and average difference of minutes between games

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
