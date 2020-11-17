#' Title
#'
#' @param home_advantage
#' @param k
#' @param mov_elo_add
#' @param mov_elo_mult
#' @param mov_score_add
#' @param mov_score_mult
#' @param score_factor
#'
#' @return
#' @export
#'
#' @examples
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
