# using tips on downloading Basketball-Reference.com's stats from the following webpage
# https://www.r-bloggers.com/2021/12/nba-analytics-tutorial-using-r-to-display-player-career-stats/

library(plyr)
library(tidyverse)
library(rvest)
library(ggrepel)
library(readr)
library(RCurl)
library(jpeg)
library(lubridate)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

#calculating odds-defying career achievements based on the adjusted "favorite toy" quantification
#https://www.baseball-reference.com/bullpen/Favorite_toy
#smaller number -> a greater degree of odds-defying

favorite_toy <- function(x1, age, s_minus_1, s_minus_2, s_minus_3) {
  
  x2 = max(1.5, 24 - 0.6*age)
  x3 = (s_minus_1*3 + s_minus_2*2 + s_minus_3*1)/6
  x3 = max(x3, s_minus_1*0.75)
  prob = (x3*x2 - (x1/2))/x1
  
  return(prob)
}

favorite_toy_vec <- function(vect, age, yrs_start = 0) {
  
  x_total = tail(vect, n=1)
  #print(x_total)
  x_1 = vect[1+yrs_start]
  x_2 = vect[2+yrs_start]
  x_3 = vect[3+yrs_start]
  up_to = sum(vect[1:(3+yrs_start)])
  #print(x_total-x_1to3)
  
  print(c(x_3, x_2, x_1))

  return(favorite_toy(x_total - up_to, age, x_3, x_2, x_1))
}

favorite_toy_vec_gen <- function(vect, vect_G, age, yrs_start = 0) {
  
  x_total = tail(vect, n=1)
  #print(x_total)
  x_1 = vect[1+yrs_start]
  x_2 = vect[2+yrs_start]
  x_3 = vect[3+yrs_start]
  g_1 = vect_G[1+yrs_start]
  g_2 = vect_G[2+yrs_start]
  g_3 = vect_G[3+yrs_start]
  up_to = sum(vect[1:(3+yrs_start)])
  #print(x_total-x_1to3)
  
  print(c(x_3, x_2, x_1))
  
  
  return(favorite_toy(x_total - up_to, age, x_3/g_3*82, x_2/g_2*82, x_1/g_3*82))
}


#yrs_start: 0 = starting from rookie year
#G: True = using averages in those three years to estimate per-year production

player_to_probs <- function(player_link, yrs_start = 0, G = FALSE){

url <- paste0("https://www.basketball-reference.com",player_link)
career <- url %>%
  read_html %>% html_node("#switcher_totals-playoffs_totals") %>% html_table()

#View(career)
if ("Trp-Dbl" %in% colnames(career))
{career = career[,1:(length(colnames(career))-2)]}

regular = career[1:which(career$Season == "Career")[1],] %>%
  mutate_at(vars(-c("Season", "Tm", "Lg", "Pos")), function(x) as.numeric(as.character(x)))

yrs = c()
for (i in 1:(which(career$Season == "Career")[1]-1)){
  if (regular$Tm[i] == "TOT"){
    yrs = c(yrs, regular$Season[i])
   
  }
}

for (yr in yrs)
{regular = filter(regular, !(Season == yr & Tm != 'TOT'))}


age_4 = regular$Age[4] + yrs_start
cat("age:")
cat((age_4-2):age_4)
cat("\n")

if (G == FALSE){

cat("pts:")
cat(favorite_toy_vec(regular$PTS, age_4, yrs_start))
cat("\ntrb:")
cat(favorite_toy_vec(regular$TRB, age_4, yrs_start))
cat("\nast:")
cat(favorite_toy_vec(regular$AST, age_4, yrs_start))
cat("\nstl:")
cat(favorite_toy_vec(regular$STL, age_4, yrs_start))
cat("\nblk:")
cat(favorite_toy_vec(regular$BLK, age_4, yrs_start))
cat("\nfg:")
cat(favorite_toy_vec(regular$FG, age_4, yrs_start))
cat("\n3p:")
cat(favorite_toy_vec(regular$`3P`, age_4, yrs_start)) }

else {
  
  cat("pts:")
  cat(favorite_toy_vec_gen(regular$PTS, regular$G, age_4, yrs_start))
  cat("\ntrb:")
  cat(favorite_toy_vec_gen(regular$TRB, regular$G, age_4, yrs_start))
  cat("\nast:")
  cat(favorite_toy_vec_gen(regular$AST, regular$G, age_4, yrs_start))
  cat("\nstl:")
  cat(favorite_toy_vec_gen(regular$STL, regular$G, age_4, yrs_start))
  cat("\nblk:")
  cat(favorite_toy_vec_gen(regular$BLK, regular$G, age_4, yrs_start))
  cat("\nfg:")
  cat(favorite_toy_vec_gen(regular$FG, regular$G, age_4, yrs_start))
  cat("\n3p:")
  cat(favorite_toy_vec_gen(regular$`3P`, regular$G, age_4, yrs_start))  
  
}

}



player_to_probs("/players/j/jamesle01.html", G = T)
player_to_probs("/players/a/abdulka01.html", G = T)
player_to_probs("/players/j/jordami01.html", G = T)
player_to_probs("/players/i/iversal01.html", G = T)

player_to_probs("/players/d/duncati01.html", G = T)

player_to_probs("/players/m/millemi01.html")

player_to_probs("/players/o/olajuha01.html", G = T)
player_to_probs("/players/b/bryanko01.html", G = T)
player_to_probs("/players/b/bryanko01.html", yrs_start = 2, G = T)

player_to_probs("/players/b/bryanko01.html", yrs_start = 3, G = T)
player_to_probs("/players/d/duncati01.html")
player_to_probs("/players/d/duncati01.html", G = T)
player_to_probs("/players/d/duncati01.html", yrs_start = 1)
player_to_probs("/players/d/duncati01.html", yrs_start = 2)

player_to_probs("/players/h/hasleud01.html", G = T)

player_to_probs("/players/c/chambwi01.html", G = T)
player_to_probs("/players/c/chambwi01.html", G = T, yrs_start = 5)

player_to_probs("/players/e/evansty01.html", G = T)

player_to_probs("/players/m/mingya01.html", G = T)

player_to_probs("/players/g/georgpa01.html", G = T)

player_to_probs("/players/h/hillgr01.html", G = T)

player_to_probs("/players/r/rosede01.html", G = T)

player_to_probs("/players/a/anthoca01.html", G= T)

player_to_probs("/players/n/nowitdi01.html", G = T)
player_to_probs("/players/n/nowitdi01.html", G = T, 1)

#odds of final pts total based on first three years
#LeBron: 28.0% 
#Jabbar: 29.1%
#Hakeem Olajuwon: 28.5%
#Tim Duncan: 31.4%
#Michael Jordan: 41.3% 
#Carmelo Anthony: 42.0% 
#Allen Iverson: 58.4% 
#Grant Hill: 70.9% 
#Wilt Chamberlain: 88.8%! 
#Udonis Haslem: 98.1% 
#Tyreke Evans: 100% 
#Yao Ming: 100% 

#Kobe Bryant: 1%; 23.7% if using production in yrs 3-5
#Dirk Nowitzki: 2.3%; 16.7% if using production in yrs 2-4

