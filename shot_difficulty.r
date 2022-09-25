library(plyr)
library(tidyverse)
library(rvest)
library(ggrepel)
library(readr)
library(RCurl)
library(jpeg)
library(lubridate)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# read defender distance results (21-22 regular season, from NBA.com/stats)
reg_1 = read_tsv("data/def_dist_reg22_0-2.tsv")
reg_3 = read_tsv("data/def_dist_reg22_2-4.tsv")
reg_5 = read_tsv("data/def_dist_reg22_4-6.tsv")
reg_7 = read_tsv("data/def_dist_reg22_6.tsv")
reg_1$dist = 1
reg_3$dist = 3
reg_5$dist = 5
reg_7$dist = 7

reg = rbind(reg_1, reg_3, reg_5, reg_7) %>% replace(is.na(.), 0)

#get summary and filter players with 1/3 of the season played and shot more than 10 FGs per game
shots_reg = group_by(reg, PLAYER_ID, PLAYER_NAME) %>% summarise(G = max(GP), 
                                                                mean_def_dist = sum(FGA*dist/sum(FGA)),
                                                                mean_efg = sum(FGA_FREQUENCY*EFG_PCT),
                                                                FGA = sum(FGA),
                                                                mean_def_dist_2 = sum(FG2A*dist/sum(FG2A)),
                                                                mean_efg_2 = sum(FG2A*FG2_PCT/sum(FG2A)),
                                                                FGA_2 = sum(FG2A),
                                                                mean_def_dist_3 = sum(FG3A*dist/sum(FG3A)),
                                                                mean_efg_3 =  sum(FG3A*FG3_PCT/sum(FG3A)),
                                                                FGA_3 = sum(FG3A)
) %>% filter(G > 27, FGA > 10)

# read shot distance data (21-22 regular season, from NBA.com/stats)
reg_dist = read_tsv("data/shot_dist_reg22.tsv") %>% 
  rename(FGM_0_5 = 8, FGA_0_5 = 9, FG_PCT_0_5 = 10,
         FGM_5_9 = 11, FGA_5_9 = 12, FG_PCT_5_9 = 13,
         FGM_10_14 = 14, FGA_10_14 = 15, FG_PCT_10_14 = 16,
         FGM_15_19 = 17, FGA_15_19 = 18, FG_PCT_15_19 = 19,
         FGM_20_24 = 20, FGA_20_24 = 21, FG_PCT_20_24 = 22,
         FGM_25_29 = 23, FGA_25_29 = 24, FG_PCT_25_29 = 25,
         FGM_30_34 = 26, FGA_30_34 = 27, FG_PCT_30_34 = 28,
         FGM_35_39 = 29, FGA_35_39 = 30, FG_PCT_35_39 = 31,
         FGM_40plus = 32, FGA_40plus = 33, FG_PCT_40_plus = 34) %>% replace(is.na(.), 0)
colnames(reg_dist)

# get summary
reg_dist = group_by(reg_dist, PLAYER_ID, PLAYER_NAME) %>%
  mutate(FGA = sum(FGA_0_5, FGA_5_9, FGA_10_14, FGA_15_19, 
                   FGA_20_24, FGA_25_29, FGA_30_34, FGA_35_39, FGA_40plus)) %>%
  mutate(FGA_dist = 2.5*FGA_0_5/FGA + 7*FGA_5_9/FGA + 12*FGA_10_14/FGA + 17*FGA_15_19/FGA +
           22*FGA_20_24/FGA + 27*FGA_25_29/FGA + 32*FGA_30_34/FGA + 37*FGA_35_39/FGA + 42*FGA_40plus/FGA)

# join two data frames
reg_dist = dplyr::select(reg_dist, PLAYER_ID, PLAYER_NAME, FGA_dist)
overall = left_join(shots_reg, reg_dist, by = c("PLAYER_ID", "PLAYER_NAME"))

# train a linear model to predict defender distance from shot distance
dist_model = lm(mean_def_dist ~ FGA_dist, data = overall)

# flip the signs of the residuals as the measurement of shot difficulty
overall$shot_difficulty = -residuals(dist_model)

# make and save the plot
png("shot_difficulty.png", height = 1800, width = 3000)

ggplot(overall, aes(x=shot_difficulty, y=mean_efg, color = FGA)) +
  geom_point() + xlab("Shot Difficulty") + ylab("eFG%") +
  geom_label_repel(aes(x = shot_difficulty, 
                       y = mean_efg, 
                       label = PLAYER_NAME,
                       color = FGA), size = 13) +
  theme(text = element_text(size = 30),axis.text.x = element_text(size = 25),
        strip.text.x = element_text(size = 25), axis.title=element_text(size=35),
        plot.title = element_text(size = 35)) +
  scale_color_continuous(high = "#132B43", low = "#56B1F7") +
  ggtitle("Shot Difficulty, 21-22 Reg. Season")

dev.off()