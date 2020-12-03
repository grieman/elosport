library(magrittr)
library(ggplot2)
library(lubridate)
library(elosport)
library(tidyverse)


'%nin%' <- function(x,y)!('%in%'(x,y))

premiership <- list()

files <- list.files(path="data", pattern="*.csv", full.names=TRUE, recursive=FALSE)
files <- lapply(files, read.csv)
for (i in c(1:10)) {
  dates <- files[[i]]$Date
  dates %<>% ymd()
  files[[i]]$Date <- dates
}
for (i in c(11:length(files))) {
  dates <- files[[i]]$Date
  dates %<>% dmy()
  files[[i]]$Date <- dates
}

schedule <- do.call(rbind, files)
schedule <- schedule[order(schedule$Date), ]

schedule <- schedule[schedule$Away_Score != "[]", ]

schedule$Away_Score %<>% as.numeric()
schedule$Home_Score %<>% as.numeric()
schedule$Home_Team <- gsub('\\s+', '', schedule$Home_Team)
schedule$Away_Team <- gsub('\\s+', '', schedule$Away_Team)

## club names change over time, need to use a manual mapping to standardize
names <- schedule$Home_Team %>% unique %>% sort
proper_names <- c(rep("Bath",2), rep("Bedford",2), rep("Bristol", 3), "Coventry", "Exeter", rep("Gloucester",3),
                  "Harlequins", rep("Leeds", 2), rep("Leicester", 2), "LiverpoolStHelens", "LondonIrish", "LondonScottish", "Wasps",
                  "LondonWelsh","Moseley", "Harlequins", rep('NewcastleFalcons',2),"NorthamptonSaints","Nottingham","Orrell",
                  "Richmond","RosslynPark","RotherhamTitans","RugbyLions", rep("Sale",2),"Saracens","Wasps","Waterloo","WestHartlepool","WorcesterWarriors")
names_df <- data.frame('rawname' = names, 'proper_names' = proper_names)

schedule$Home_Team <- names_df$proper_names[match(schedule$Home_Team, names_df$rawname)]
schedule$Away_Team <- names_df$proper_names[match(schedule$Away_Team, names_df$rawname)]



## Iterate here

pars <- data.frame(
  home_advantage = 0,
  k = 25,
  mov_elo_add = 2.2,
  mov_elo_mult = .001,
  mov_score_add = 1,
  mov_score_mult = 2.2,
  score_factor = 5,
  elo_original = 2500,
  elo_promoted_diff = 250
  )


get_season_error <- function(home_advantage,
                             k,
                             mov_elo_add,
                             mov_elo_mult,
                             mov_score_add,
                             mov_score_mult,
                             score_factor,
                             elo_original,
                             elo_promoted_diff,
                             schedule = schedule){
  elo_params <- make_elo_params(home_advantage, k, mov_elo_add, mov_elo_mult, mov_score_add, mov_score_mult, score_factor)

  train_schedule <- schedule[which(schedule$Date <= ymd('2017-06-01')), ]
  test_schedule <- schedule[which(schedule$Date > ymd('2017-06-01')), ]

  team_list <- list()
  for (team in schedule$Home_Team %>% unique){
    if (schedule[which(schedule$Home_Team == team), ][1, ]$Date < ymd("19880101")) {
      start_elo <- elo_original
    } else { # Teams that join the premiership do so from lower tiers, so _should_ have lower elos
      start_elo <- elo_original + elo_promoted_diff
    }
    team_list[[team]] <- Team$new(team, start_elo)
  }

  game_list <- list()
  for (row in 1:nrow(train_schedule)) {
    game_row <- train_schedule[row, ]
    game_name <- paste0(game_row$Home_Team, game_row$Away_Team, game_row$Date)
    game_list[[game_name]] <- Game$new(game_row$Date,
                                       team_list[[game_row$Home_Team]],
                                       team_list[[game_row$Away_Team]],
                                       game_row$Home_Score,
                                       game_row$Away_Score,
                                       elo_params,
                                       neutral_site = FALSE)

    game_list[[game_name]]$process()
  }

  last_season_error <- 0
  for (row in 1:nrow(test_schedule)) {
    game_row <- test_schedule[row, ]
    game_name <- paste0(game_row$Home_Team, game_row$Away_Team, game_row$Date)
    game_list[[game_name]] <- Game$new(game_row$Date,
                                       team_list[[game_row$Home_Team]],
                                       team_list[[game_row$Away_Team]],
                                       game_row$Home_Score,
                                       game_row$Away_Score,
                                       elo_params,
                                       neutral_site = FALSE)

    game_list[[game_name]]$process()
    game_error <- game_list[[game_name]]$spread - game_list[[game_name]]$point_diff
    last_season_error <- last_season_error + abs(game_error)
  }
  return(last_season_error)
}

pars <- expand.grid(
  home_advantage = c(0, 2, 4, 6, 8),
  k = c(5, 10, 15, 20, 25),
  mov_elo_add = 2.2,
  mov_elo_mult = .001,
  mov_score_add = 1,
  mov_score_mult = 2.2,
  score_factor = 5,
  elo_original = 2500,
  elo_promoted_diff = c(0, 100, 200)
)
print(dim(pars)[1])

results = plyr::mdply(pars, get_season_error, schedule, .parallel = TRUE)
results
