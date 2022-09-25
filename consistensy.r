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

# define function to download a number of stats
get_stats <- function(player_link){
  url <- paste0("https://www.basketball-reference.com",player_link)
  log_url <- paste0("https://www.basketball-reference.com", gsub(".html", "/gamelog/2022", player_link))
  log_adv_url <- paste0("https://www.basketball-reference.com", gsub(".html", "/gamelog-advanced/2022", player_link))
  
  name <- url %>%
    read_html %>%
    html_node("h1") %>% html_text() %>% trimws()
  
  stat <- url %>%
    read_html %>%
    html_node("#div_per_game")%>% 
    html_table() %>% rename(X1 = 20, X2 = 25) %>% filter(Season == "2021-22") 
  
  adv_stat <- url %>%
    read_html %>%
    html_node("#div_advanced")%>% 
    html_table() %>% rename(X1 = 20, X2 = 25) %>% filter(Season == "2021-22") 
  
  
  log_stat <- log_url %>%
    read_html %>%
    html_node("#div_pgl_basic")%>% 
    html_table()  
  
  log_adv_stat <- log_adv_url %>%
    read_html %>%
    html_node("#pgl_advanced")%>% 
    html_table()  
  
  log_stat = log_stat[grepl(":", log_stat$MP),]
  log_adv_stat = log_adv_stat[grepl(":", log_adv_stat$MP),]
  
  log_adv_stat$ORtg= as.numeric(log_adv_stat$ORtg)
  log_adv_stat$DRtg= as.numeric(log_adv_stat$DRtg)
  log_adv_stat$BPM = as.numeric(log_adv_stat$BPM)
  
  log_stat$MP = ms(log_stat$MP)
  log_stat$MP = minute(log_stat$MP) + second(log_stat$MP)/60 
  
  log_stat$PTS = as.numeric(log_stat$PTS)
  
  # calculating local fluctuations of performances (in GmSc) 
  log_stat$GmSc = as.numeric(log_stat$GmSc)
  GmSc_diff = mean(diff(log_stat$GmSc))
  MP_diff = mean(diff(log_stat$MP))
  GmSc_diff_abs = mean(abs(diff(log_stat$GmSc)))
  MP_diff_abs = mean(abs(diff(log_stat$MP)))
  
  
  log_adv_stat$`USG%` = as.numeric(log_adv_stat$`USG%`)
  
  teams = unique(log_stat$Tm)
  teams = teams[teams != "Tm"]
  
  log_stat = rename(log_stat, WL = 8, host = 6)
  
  log_stat$margin = as.numeric(gsub("[WL ()]", "", log_stat$WL))
  log_stat$WL = gsub("[^WL]", "", log_stat$WL)
  log_stat$WL = if_else(log_stat$WL == "W", 1, 0)
  
  if (length(log_stat$WL) >= 3)
  {
    cor_WL_GmSc = unname(cor.test(log_stat$WL, log_stat$GmSc)[[4]])
    cor_margin_GmSc = unname(cor.test(log_stat$margin, log_stat$GmSc)[[4]])
    cor_WL_MP = unname(cor.test(log_stat$WL, log_stat$MP)[[4]])
    cor_margin_MP = unname(cor.test(log_stat$margin, log_stat$MP)[[4]])
    cor_WL_USG = unname(cor.test(log_stat$WL, log_adv_stat$`USG%`)[[4]])
    cor_margin_USG = unname(cor.test(log_stat$margin, log_adv_stat$`USG%`)[[4]])
    cor_WL_ORtg = unname(cor.test(log_stat$WL, log_adv_stat$ORtg)[[4]])
    cor_margin_ORtg = unname(cor.test(log_stat$margin, log_adv_stat$ORtg)[[4]])
    cor_WL_DRtg = unname(cor.test(log_stat$WL, log_adv_stat$DRtg)[[4]])
    cor_margin_DRtg = unname(cor.test(log_stat$margin, log_adv_stat$DRtg)[[4]])
    cor_WL_BPM = unname(cor.test(log_stat$WL, log_adv_stat$BPM)[[4]])
    cor_margin_BPM = unname(cor.test(log_stat$margin, log_adv_stat$BPM)[[4]])
    cor_GmSc_BPM = unname(cor.test(log_stat$GmSc, log_adv_stat$BPM)[[4]])
  }
  else {
    cor_WL_GmSc = 0
    cor_margin_GmSc = 0
    cor_WL_MP = 0
    cor_margin_MP = 0
    cor_WL_USG = 0
    cor_margin_USG = 0  
    cor_WL_ORtg = 0
    cor_margin_ORtg = 0
    cor_WL_DRtg = 0
    cor_margin_DRtg = 0
    cor_WL_BPM = 0
    cor_margin_BPM = 0
    cor_GmSc_BPM = 0
  }
  
  output = tibble(Player = name, G = length(log_stat$PTS), team = paste(unique(teams), collapse = "_"),
                  W = sum(log_stat$WL), 
                  cor_WL_GmSc = cor_WL_GmSc, cor_margin_GmSc = cor_margin_GmSc,
                  cor_WL_MP = cor_WL_MP, cor_margin_MP = cor_margin_MP,
                  cor_WL_USG = cor_WL_USG, cor_margin_USG = cor_margin_USG,
                  cor_WL_ORtg = cor_WL_ORtg, cor_margin_ORtg = cor_margin_ORtg,
                  cor_WL_DRtg = cor_WL_DRtg, cor_margin_DRtg = cor_margin_DRtg,
                  cor_WL_BPM = cor_WL_BPM, cor_margin_BPM = cor_margin_BPM,
                  cor_GmSc_BPM = cor_GmSc_BPM,
                  PTS_sd = sd(log_stat$PTS),
                  MP_sd = sd(log_stat$MP),
                  GmSc = mean(log_stat$GmSc), GmSc_sd = sd(log_stat$GmSc),
                  USG_sd = sd(log_adv_stat$`USG%`),
                  ORtg = mean(log_adv_stat$ORtg), ORtg_sd = sd(log_adv_stat$ORtg),
                  DRtg = mean(log_adv_stat$DRtg), DRtg_sd = sd(log_adv_stat$DRtg),
                  BPM_log = mean(log_adv_stat$BPM), BPM_sd = sd(log_adv_stat$BPM),
                  
                  GmSc_diff = GmSc_diff, MP_diff = MP_diff,
                  GmSc_diff_abs = GmSc_diff_abs, MP_diff_abs = MP_diff_abs)
  
  output$G = as.numeric(output$G)
  stat$G = as.numeric(stat$G)
  adv_stat$G = as.numeric(adv_stat$G)
  
  output = left_join(output, stat, by = c("G"))
  output = left_join(output, adv_stat, by = c("G", "Season", "Lg", "Tm", "Age", "Pos"))
  output = dplyr::select(output, -MP.y) %>% rename(MP = MP.y)
  
  colnames(output)
  
  
  return(output)
  
}



teams = c("BOS", "PHI", "TOR", "BRK", "NYK",
          "MIL", "CHI", "CLE", "IND", "DET",
          "MIA", "ATL", "CHO", "WAS", "ORL",
          "UTA", "DEN", "MIN", "POR", "OKC",
          "PHO", "GSW", "LAC", "LAL", "SAC",
          "MEM", "DAL", "NOP", "SAS", "HOU")



result = get_stats(player_link)

for (team in teams){
  
  team_url = paste("https://www.basketball-reference.com/teams/", team, "/2022.html", sep = "")
  
  roster <- team_url %>%
    read_html %>%
    html_node("#div_roster")%>% 
    html_table()  
  
  roster <- team_url %>%
    read_html %>% 
    html_node("#div_roster") %>%  html_node("#roster") %>% html_nodes("a") %>% html_attr("href")
  
  roster = roster[grepl("players", roster)]
  
  
  
  for (i in roster){
    
    print(i)
    url <- paste0("https://www.basketball-reference.com",i)
    stat <- url %>%
      read_html %>%
      html_node("#div_per_game")
    
    if (!is.na(stat)){
      stat <- url %>%
        read_html %>%
        html_node("#div_per_game")%>% 
        html_table()
      
      if("2021-22" %in% stat$Season)
        
      { result = rbind(result, get_stats(i))}  
      
      
    }
    
    
  }
  

}

write.table(result, file = "data/22_stats.tsv", quote = F, row.names = F, sep = "\t",
            fileEncoding="UTF-8")


# read if already saved:
# result = read_tsv("data/22_stats.tsv")
result = result[result$G > 1,] %>% distinct() 
result_filtered = filter(result, G > 27, MP > 16)


# use a linear model to predict SD of GmSc given mean GmSc, mean/sd minutes per game
con_model = lm(GmSc_sd ~ GmSc * MP_sd * MP, data = result_filtered)
# flip the residuals to define global consistensy
result_filtered$global_consistency = -residuals(con_model)

# use a linear model to predict mean absolute GmSc difference between games 
# from mean GmSc, mean absolute minutes difference between games, and mean minutes per game
con_model_2 = lm(GmSc_diff_abs  ~ GmSc * MP_diff_abs * MP, data = result_filtered)
# flip the residuals to define local consistensy
result_filtered$local_consistency = -residuals(con_model_2)


png("consistency_glob_2022.png", height = 1500, width = 2500)

ggplot(result_filtered, aes(x=global_consistency, y=GmSc )) +
  geom_point() + 
  geom_label_repel(aes(x = global_consistency, 
                       y = GmSc , 
                       label = Player,
                       color = W/G), size = 12) +
  theme(text = element_text(size = 30),axis.text.x = element_text(size = 25),
        strip.text.x = element_text(size = 25), axis.title=element_text(size=25),
        plot.title = element_text(size = 20))+ 
  scale_color_continuous(high = "#132B43", low = "#56B1F7")

dev.off()

png("consistency_loc_2022.png", height = 1500, width = 2500)

ggplot(result_filtered, aes(x=local_consistency, y=GmSc )) +
  geom_point() + 
  geom_label_repel(aes(x = local_consistency, 
                       y = GmSc , 
                       label = Player,
                       color = W/G), size = 12) +
  theme(text = element_text(size = 30),axis.text.x = element_text(size = 25),
        strip.text.x = element_text(size = 25), axis.title=element_text(size=25),
        plot.title = element_text(size = 20))+ 
  scale_color_continuous(high = "#132B43", low = "#56B1F7")

dev.off()