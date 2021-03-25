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
#' get_tripduration(auth="your_token", origin=origin,destination,time, sys.sleep=2)
#'

get_tripduration<- function(auth=NA,
                            origin=NA,
                            origin_id=NA,
                            destination=NA,
                            destination_id=NA,
                            time=NA,
                            sys.sleep=NA){

# Transform coordinates

destination <- coordinates_to_list(destination)

origin <- coordinates_to_list(origin)

# create all combinations of origins / destinations
trip_combinations = expand.grid(or = origin,
                                de = destination)

location_id <- expand.grid(origin_id, destination_id)

# Check if length of label vector corresponds with coordinate vector
#
# or_id <- na_vec(trip_combinations$or, location_id)
#
# de_id <- na_vec(trip_combinations$de, location_id)


df <- purrr::map_dfr(1:length(trip_combinations$or),
               ~suppressWarnings(get_tripduration_internal(auth=auth,
                                                           origin=trip_combinations$or[[.x]] %>% purrr::flatten_dbl(),
                                                           origin_id=location_id$Var1[[.x]],
                                                           destination=trip_combinations$de[[.x]] %>% purrr::flatten_dbl(),
                                                           destination_id=location_id$Var2[[.x]],
                                                           time=time,
                                                           sys.sleep=sys.sleep)
               ),
               .id="trip_id")

df %>%
  mutate_at(vars(origin, destination),
            ~st_as_sfc(.) %>% sf::st_set_crs(4326)
            ) %>%
          st_as_sf()

}
