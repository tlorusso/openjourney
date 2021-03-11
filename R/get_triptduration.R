#' Get tripduration
#'
#' @param auth authentication token
#' @param origin geocoordinates of the origin, WGS
#' @param destination geocoordinates of the destination
#' @param time departure time in format "YYYY-MM-16T08:34:40"
#' @param sys.sleep delay after an API-call until the next is triggered
#'
#' @return tibble
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
#' get_tripduration(auth="your_token", origin=origin,destination,time, sys.sleep=2)
#'

get_tripduration<- function(auth=NA,
                            origin=NA,
                            destination=NA,
                            time=NA,
                            sys.sleep=NA){

purrr::map_dfr(1:length(origin[[1]]),
        ~suppressWarnings(get_ojp_time(auth=auth,
              origin=c(origin[[1]][[.]],origin[[2]][[.]]),
              destination=destination,
              time=time,
              sys.sleep=sys.sleep)
          ))

}
