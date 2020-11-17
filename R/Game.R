Game <- R6::R6Class("Game",
    public = list(
      date = NULL,
      home_team = NULL,
      away_team = NULL,
      home_score = NULL,
      away_score = NULL,
      winner = NULL,
      loser = NULL,
      point_diff = NULL,
      elo_diff = NULL,
      home_elo = NULL,
      away_elo = NULL,
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
        self$home_elo <- self$home_team$elo_score
        self$away_elo <- self$away_team$elo_score
        self$point_diff <- self$home_score - self$away_score
        self$elo_diff <- self$home_elo - self$away_elo

        # if(self$home_score > self$away_score){
        #   self$winner <- self$home_team
        #   self$loser <- self$away_team
        # } else {
        #   self$winner <- self$away_team
        #   self$loser <- self$home_team
        # }

      },
      process = function(){
        result <- (sign(self$point_diff) + 1) / 2
        self$spread <- self$elo_diff / self$score_factor
        self$prediction <- 1 / (10 ^ (-(self$home_team$elo_score - self$away_team$elo_score) / self$score_factor^2) + 1)


        self$mov_mod <- log(abs(self$point_diff) + self$mov_score_add) * (self$mov_score_mult / (
          (self$home_team$elo_score - self$away_team$elo_score) * sign(self$point_diff) * self$mov_elo_mult + self$mov_elo_add))

        self$elo_change <- (result - self$prediction) * self$k * self$mov_mod

        self$home_team$add_game(self, self$elo_change)
        self$away_team$add_game(self, (self$elo_change * -1))
        }
    ))
