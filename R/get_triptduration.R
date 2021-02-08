#' Title
#'
#' @param auth
#' @param origin
#' @param destination
#' @param time
#' @param sys.sleep
#'
#' @return
#' @export
#'
#' @examples
#'
#' origin <- list(c(8.572164,47.40459),
#'                c(8.59557,47.39675))
#'
#' destination <- c(7.45,46.9)
#'
#' # origin <- coords %>%
#' # select(long,lat) %>% purrr::transpose()
#'
#' destination <- c(7.45,46.9)
#'
#' get_tripduration(auth=token1, origin=origin,destination,time, sys.sleep=2)
#'

get_tripduration<- function(auth=token1,
                            origin=NA,
                            destination=NA,
                            time=NA,
                            sys.sleep=NA){

purrr::map_dfr(1:length(origin),
        ~get_ojp_time(
              origin=c(origin[[.]][[1]],origin[[.]][[2]]),
              destination=destination,
              time=time,
              sys.sleep=5))

}
