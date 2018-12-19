Team <- R6::R6Class("Team",
      public = list(
        alias = NULL,
        elo_score = NULL,
        games = c(),
        history = data.frame(),
        initialize = function(alias = NA, elo_start = NA){
          self$alias <- alias
          self$elo_score <- elo_start
        },
        add_game = function(match, elo_change){
          self$games %<>% append(match)
          self$elo_score %<>% add(elo_change)
          if(match$winner$alias == self$alias){
            result <- "W"
            opponent <- match$loser$alias
          } else {
            result <- "L"
            opponent <- match$winner$alias
          }
          if (match$home_team$alias == self$alias){
            location <- "H"
          } else {location <- "A"}

          game_record <- list("Date" = match$date,
                              "Opponent" = opponent,
                              "Location" = location,
                              "Result" = result,
                              "Elo" = self$elo_score)
          self$history %<>% rbind(game_record)
          self$history[c("Date","Opponent","Location","Result")] %<>% apply(2, as.character)
        }
        )
      )
