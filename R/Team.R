Team <- R6::R6Class("Team",
      public = list(
        alias = NULL,
        elo_score = NULL,
        games = c(),
        history = data.frame(Date = as.Date(character()),
                             Opponent = character(),
                             Location = character(),
                             Result = character(),
                             Elo = character()),
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

          game_record <- data.frame("Date" = match$date,
                              "Opponent" = opponent,
                              "Location" = location,
                              "Result" = result,
                              "Elo" = self$elo_score)

          self$history %<>% rbind(game_record)
          self$history[c("Opponent","Location","Result")] %<>% apply(2, as.character)
          #if self$history$Date is not a date object, then make string, otherwise keep as date
        }
        )
      )
