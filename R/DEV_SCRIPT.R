library(magrittr)
library(ggplot2)
library(lubridate)

df_1987 <- read.csv("data/English_Premiership_1987.csv")
df_1987$Date %<>% ymd()

elo_params <- make_elo_params(0, 20, 2.2, .001, 1, 2.2, 10)

all_teams <- list()

for (team in df_1987$Home_Team %>% unique){
  if (!team %in% all_teams){
    print(team)
    all_teams[[team]] <- Team$new(team, 2500)
  }
}

schedule_1987 <- Schedule$new(1987, df_1987, elo_params)
schedule_1987$make_games(all_teams)
for (game in schedule_1987$games){
  game$process()
}

str(all_teams$Bath$history)

ggplot(all_teams$Bath$history, aes(Date, Elo)) + geom_line()
