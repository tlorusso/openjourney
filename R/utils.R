#' Turn numeric origin / destination vector to list
#'
#' @param x
#'
#' @return list
#' @noRd
#'
#' @examples
#' destination <- c(7,41)
#'
#' coordinates_to_list(destination)
#'
#' [[1]]
#' [1] 7
#' [[2]]
#' [1] 41
#'

coordinates_to_list <- function(x){

  if(is.list(x)==FALSE) {list(list(long=x[1], lat=x[2]))} else {x}

}

#' Check coordinates
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
check_coordinates <- function(x){

  # add check for lat / long range

  if(length(x!=2)){stop("Origin / destination is not a numeric vector or list of length two (long / lat)")}

}

#
#' Generate vector of NAs to fill in the id-variables with length equal to a coordinate vector
#'
#' @return
#' @export
#' @noRd
#'

na_vec <- function(coord_var, name_var){

if(!length(coord_var)==length(name_var)){

message("length of origin OR destination - coordinate vector does not match with the id vector. Ids are set to NA." )

      rep(NA, length(coord_var))

} else {name_var}

}
