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
          home_win <- sign(match$home_score - match$away_score)
          if (match$home_team$alias == self$alias){
            location <- "H"
            opponent <- match$away_team$alias
            result <- home_win
          } else {
            location <- "A"
            opponent <- match$home_team$alias
            result <- home_win * -1
          }

          result %<>% plyr::mapvalues(from = c(1, -1, 0), to = c('W', 'L', 'D'), warn_missing = FALSE)

          game_record <- data.frame("Date" = match$date,
                              "Opponent" = opponent,
                              "Location" = location,
                              "Result" = result,
                              "Elo" = self$elo_score,
                              "Score" = paste0(match$home_score, '-', match$away_score))

          self$history %<>% rbind(game_record)
          self$history[c("Opponent","Location", "Result")] %<>% apply(2, as.character)
          self$history <- self$history[order(self$history$Date),]
        }
        )
      )
