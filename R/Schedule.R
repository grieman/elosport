Schedule <- R6::R6Class("Schedule",
      public = list(
        year = NULL,
        df = NULL,
        elo_params = NULL,
        games = NULL,
        initialize = function(year, source_df, elo_params){
          self$year <- year
          self$df <- source_df
          self$elo_params <- elo_params
        },
        make_games = function(all_teams){
          self$games <- list()
          ## Iterate through df and make a game for each line
          for (i in 1:nrow(self$df)) {
            row <- self$df[i,]
            self$games[[paste(row$Home_Team,
                              row$Away_Team,
                              row$Date,
                              sep = '_')]] <- Game$new(row$Date,
                                                  all_teams[[row$Home_Team]],
                                                  all_teams[[row$Away_Team]],
                                                  row$Home_Score,
                                                  row$Away_Score,
                                                  self$elo_params)
          }
        }
      ))
