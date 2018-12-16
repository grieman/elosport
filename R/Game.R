Game <- R6::R6Class("Game",
                    public = list(
                      date = NULL,
                      home = NULL,
                      away = NULL,
                      home_score = NULL,
                      away_score = NULL,
                      winner = NULL,
                      loser = NULL,
                      point_diff = NULL,
                      # These parameters will come from a parameter object that is passed in
                      home_advantage = NULL,
                      score_factor = NULL,
                      k = NULL,
                      mov_score_add = NULL,
                      mov_score_mult = NULL,
                      mov_elo_add = NULL,
                      mov_elo_mult = NULL,
                      initialize = function(date, home_team, away_team, home_score, away_score, elo_params){
                        #### CHECK ELO PARAMS
                        ###
                        self$date <- date
                        self$home_team <- home_team
                        self$away_team <- away_team
                        self$home_score <- home_score
                        self$away_score <- away_score
                      }
                    ))





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
