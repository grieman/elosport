### Class for a club

Club <- R6::R6Class("Club",
                    public = list(
                      alias = NULL,
                      elo_score = NULL,
                      elo_history = NULL,
                      games = c(),
                      history = data.frame(),
                      initialize = function(alias = NA, elo_start = NA){
                        self$alias <- alias
                        self$elo_score <- elo_start
                        elo_history <- c(elo_start)
                      },
                      add_game = function(match, elo_change){
                        self$games %<>% append(match)
                        self$elo_score %<>% add(elo_change)
                        game_record <- list("Date" = NULL, "Result" = NULL, "Elo" = self$elo_score)
                        self$history %<>% rbind(game_record)
                      }
                      )
                    )


Bath <- Club$new(alias = 'Bath', elo_start = 2500)
