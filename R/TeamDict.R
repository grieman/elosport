TeamDict <- R6::R6Class("TeamDict",
               public <- list(
                 teams = NULL,
                 initialize = function(teams=list()){
                   self$teams <- teams
                 },
                 update = function(schedule){
                   for (team in schedule$df$Home_Team %>% unique) {
                     if (!team %in% self$teams){
                       self$teams[team] = Team$new(team)
                     }
                   }
                 }
               ))
