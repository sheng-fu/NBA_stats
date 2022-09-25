# using tips on downloading Basketball-Reference.com's stats from the following webpage
# https://www.r-bloggers.com/2021/12/nba-analytics-tutorial-using-r-to-display-player-career-stats/

library(plyr)
library(tidyverse)
library(rvest)
library(ggrepel)
library(readr)
library(RCurl)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# define a function that grabs relevant W/L and adjusted W/L records of a player
get_win_loss <- function(player_link){ 
  # player link format: "/players/p/paulch01.html"

  player_code = gsub(".html", "", player_link)
  player_code = gsub("p/", "", player_code)
  
  # define player page URL: main page and the career splits page
  url <- paste0("https://www.basketball-reference.com",player_link)
  splits_url <- paste0("https://www.basketball-reference.com", gsub(".html", "/splits/", player_link))

  # get player name
  name <- url %>%
    read_html %>%
    html_node("h1") %>% html_text() %>% trimws()
  
  # get split stats into table
  split_stat <- splits_url %>%
    read_html %>%
    html_node("#div_splits")%>% 
    html_table()  
  
  # get real column names
  colnames(split_stat) = paste(colnames(split_stat), as.character(split_stat[1,]), sep = "X")
  
  # get the rows showing splits in wins and losses
  split_stat = dplyr::select(split_stat, -`X&nbsp`) %>% filter(XValue %in% c("Win", "Loss"))
  

  
  # get usage rates in wins and losses  
  w_usg = as.numeric(split_stat$`AdvancedXUSG%`[1])
  l_usg = as.numeric(split_stat$`AdvancedXUSG%`[2])
  
  # get games and minutes playeded in wins and losses
  w_games = as.numeric(split_stat$TotalsXG[1])
  w_mins = as.numeric(split_stat$TotalsXMP[1])
  l_games = as.numeric(split_stat$TotalsXG[2])
  l_mins = as.numeric(split_stat$TotalsXMP[2])
  
  # get total games played
  G = w_games + l_games
  
  # get adjusted winning/losing games played
  # adjusted w/l games = w/l games * proportion of w/l games played
  adjusted_w = w_games * ( w_mins / (w_games * 48))
  adjusted_l = l_games * ( l_mins / (l_games * 48))  
  
  # get raw winning rate
  raw_perc = w_games / G

  # get time-adjusted winning rate
  min_perc = adjusted_w / (adjusted_w + adjusted_l)  
  
  # get usage/time-adjusted winning percentage, 
  # i.e., usage rate in winning games * adjusted winning game played / usage rate * adjusted games played
  usg_perc =  (adjusted_w * w_usg)  / (adjusted_w * w_usg + adjusted_l * l_usg) 
  
  
  # get difference between offensive and defensive ratings in wins and losses 
  w_diff = as.numeric(split_stat$`AdvancedXORtg`[1]) - as.numeric(split_stat$`AdvancedXDRtg`[1])
  l_diff = as.numeric(split_stat$`AdvancedXORtg`[2]) - as.numeric(split_stat$`AdvancedXDRtg`[2])
  # calculate overall off/def rating difference
  raw_diff = w_diff + l_diff

  # adjust off/def rating difference by playing time
  min_diff = (w_diff * adjusted_w   + l_diff * adjusted_l ) / 
    (adjusted_w  + adjusted_l )
  
  # adjust off/def rating difference by usage rate 
  usg_diff = (w_diff * adjusted_w * w_usg  + l_diff * adjusted_l * l_usg) / 
    (adjusted_w * w_usg + adjusted_l * l_usg)

  # handling possible missing values  
  if (length(usg_perc) == 0){
    usg_perc = NA
  }
  
  if (length(usg_diff) == 0){
    usg_diff = NA
  }
  
  # save to outputs
  output = tibble(Player = name, G = G, 
                  raw_win_perc = raw_perc, min_win_perc = min_perc, 
                  usg_win_perc = usg_perc,
                  raw_rt_diff = raw_diff, min_rt_diff = min_diff, 
                  usg_rt_diff = usg_diff,
                  w_diff = w_diff, l_diff = l_diff)
  
  return(output)
  
}


# get data: get active players with most minutes per game 
active_url = "https://www.basketball-reference.com/leaders/mp_per_g_active.html"

active_leaders <- active_url %>%
  read_html %>% 
  html_node("#div_stats_active_mp_per_g")  %>% html_nodes("a") %>% html_attr("href")


# create empty tibble and get data for active/all-time players
result_active = tibble(Player = vector(), G = vector(),
                       raw_win_perc = vector(), min_win_perc = vector(), 
                       usg_win_perc = vector(),
                       raw_rt_diff = vector(), min_rt_diff = vector(), 
                       usg_rt_diff = vector(), w_diff = vector(), 
                       l_diff = vector())

for (i in active_leaders){
  print(i)
  result = rbind(result_active, get_win_loss(i))
  
}

# save for later use
write.table(result_active, file = "active_players.tsv", quote = F, row.names = F, sep = "\t")

# result_active = read_tsv("active_players.tsv")

# define PLOW: log( time-adjusted winning rate / raw winning rate )
result_active$plow = log(result_active$min_win_perc  / result_active$raw_win_perc)

# define BORROW: log( usage/time-adjusted winning rate / raw winning rate )
result_active$borrow = log(result_active$usg_win_perc  / result_active$raw_win_perc)

# draw and save graphs
png("BORROW.png", height = 1500, width = 2000)

ggplot(result_active, aes(x=usg_win_perc, y=borrow)) +
  geom_point() + 
  geom_label_repel(aes(x = usg_win_perc*100, 
                       y = borrow, 
                       label = Player), size = 10) +
  theme(text = element_text(size = 30),axis.text.x = element_text(size = 25),
        strip.text.x = element_text(size = 25), axis.title=element_text(size=25),
        plot.title = element_text(size = 20)) + ylab("BORROW") + xlab("adjusted W%")


dev.off()

png("PLOW.png", height = 1500, width = 2000)

ggplot(result_active, aes(x=usg_win_perc, y=plow)) +
  geom_point() + 
  geom_label_repel(aes(x = usg_win_perc*100, 
                       y = borrow, 
                       label = Player), size = 10) +
  theme(text = element_text(size = 30),axis.text.x = element_text(size = 25),
        strip.text.x = element_text(size = 25), axis.title=element_text(size=25),
        plot.title = element_text(size = 20)) + ylab("PLOW") + xlab("adjusted W%")


dev.off()

