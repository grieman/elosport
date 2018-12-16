make_elo_params <- function(home_advantage, k, mov_elo_add, mov_elo_mult, mov_score_add, mov_score_mult, score_factor){
  out <- list(
    "home_advantage" = home_advantage,
    "k" = k,
    "mov_elo_add" = mov_elo_add,
    "mov_elo_mult" = mov_elo_mult,
    "mov_score_add" = mov_score_add,
    "mov_score_mult" = mov_score_mult,
    "score_factor" = score_factor
  )
  return(out)
}
