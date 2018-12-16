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
      spread = NULL,
      prediction = NULL,
      mov_mod = NULL,
      elo_change = NULL,

      # These parameters will come from a parameter object that is passed in
      #home_advantage = NULL,
      score_factor = NULL,
      k = NULL,
      mov_score_add = NULL,
      mov_score_mult = NULL,
      mov_elo_add = NULL,
      mov_elo_mult = NULL,
      initialize = function(date,
                            home_team,
                            away_team,
                            home_score,
                            away_score,
                            elo_params,
                            neutral_site = FALSE){

        #### ADD CHECK FOR ELO PARAMS
        if (!identical(names(elo_params),
                     c("home_advantage",
                       "k",
                       "mov_elo_add",
                       "mov_elo_mult",
                       "mov_score_add",
                       "mov_score_mult",
                       "score_factor"),
                     attrib.as.set = TRUE)) {
          stop(paste0("elo_params does not have the correct format.",
                      " It should be a named vector with fields ",
                      "home_advantage, k, mov_elo_add, mov_elo_mult,",
                      " mov_score_add, mov_score_mult, and score_factor.",
                      "It is easiest to create using the function",
                      " make_elo_params"))
        }
        #self$home_advantage <- elo_params$home_advantage
        self$score_factor   <- elo_params$score_factor
        self$k              <- elo_params$k
        self$mov_score_add  <- elo_params$mov_score_add
        self$mov_score_mult <- elo_params$mov_score_mult
        self$mov_elo_add    <- elo_params$mov_elo_add
        self$mov_elo_mult   <- elo_params$mov_elo_mult

        self$date <- date
        self$home_team <- home_team
        self$away_team <- away_team
        self$home_score <- home_score
        #if(neutral_site != FALSE){
        #  self$home_score %<>% add(-self$home_advantage)
        #  }
        self$away_score <- away_score
        self$point_diff <- home_score - away_score
      },
      process = function(){
        self$spread <- self$point_diff / self$score_factor
        self$prediction <- 1 / (10 ^ (-(self$home_team$elo_score - self$away_team$elo_score) / self$score_factor^2) + 1)
        self$mov_mod <- log(abs(self$point_diff) + self$mov_score_add) * (self$mov_score_mult / (
          (self$winner$elo_score - self$loser$elo_score) * self$elo_score_mult + self$elo_score_add))
        self$elo_change <- log(self$point_diff + 1) * self$k * self$mov_mod
        self$winner$add_game(self, self$elo_change)
        self$loser$add_game(self, (self$elo_change * -1))
        }
    ))
