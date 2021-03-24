#' Get_ojp_time get traveltime between two coordinates
#'
#' @param auth authentication token
#' @param origin geocoordinates of the origin, WGS
#' @param destination geocoordinates of the destination
#' @param time departure time in format "YYYY-MM-16T08:34:40"
#' @param sys.sleep delay after an API-call until the next is triggered
#'
#' @return tibble
#' @noRd
#'
#' @examples
#' coords <- geo(address = c("Zürich Schwamendingerplatz, Switzerland",
#'                           "Bahnhof Stettbach, Switzerland"), method ='osm')
#'
#' ojp <- get_tripduration_internal(
#'   origin=c(coords[1,]$long,coords[1,]$lat),
#'   destination=c(coords[2,]$long,coords[2,]$lat),
#'   time="2021-03-18T08:34:40"
#' )
#'

get_tripduration_internal <- function(auth=NA,
                         origin=NA,
                         origin_id=origin_id,
                         destination=NA,
                         destination_id=destination_id,
                         time=NA,
                         sys.sleep=NA){

# add delay between requests to respect API-Rate limits
if(!is.na(sys.sleep)) {Sys.sleep(sys.sleep)}

if(is.na(auth)) {stop("Authentication token required. Please provide a token: get_tripduration(auth='your_token',...)")}

# message(paste0(origin[1]," and ", origin[2]))

# add checks for coordinates etc.
#coordinates of the origin
#
# origin <- c(8.572164,47.40459)
#
# destination <- c(7.45,46.9)

long_or <- origin[1]
lat_or <- origin[2]

#coordinates of the destination
long_dest <- destination[1]
lat_dest <- destination[2]

#compile request body
body  <- glue::glue('<?xml version="1.0" encoding="utf-8"?>
<OJP xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.siri.org.uk/siri" version="1.0" xmlns:ojp="http://www.vdv.de/ojp" xsi:schemaLocation="http://www.siri.org.uk/siri ../ojp-xsd-v1.0/OJP.xsd">
    <OJPRequest>
        <ServiceRequest>
            <RequestTimestamp>2020-12-16T20:38:51.798Z</RequestTimestamp>
            <RequestorRef>openjourney package</RequestorRef>
            <ojp:OJPTripRequest>
                <RequestTimestamp>2020-12-16T20:38:51.798Z</RequestTimestamp>
                <ojp:Origin>
                    <ojp:PlaceRef>
                        <ojp:LocationName>
                            <ojp:Text>Whatever</ojp:Text>
                        </ojp:LocationName>
                        <ojp:GeoPosition>
                            <Longitude>{long_or}</Longitude>
                            <Latitude>{lat_or}</Latitude>
                        </ojp:GeoPosition>
                    </ojp:PlaceRef>
                    <ojp:DepArrTime>{time}</ojp:DepArrTime>
                </ojp:Origin>
                <ojp:Destination>
                    <ojp:PlaceRef>
                        <ojp:LocationName>
                            <obj:Text>Loc2</obj:Text>
                        </ojp:LocationName>
                        <ojp:GeoPosition>
                            <Longitude>{long_dest}</Longitude>
                            <Latitude>{lat_dest}</Latitude>
                        </ojp:GeoPosition>
                    </ojp:PlaceRef>
                </ojp:Destination>
                <ojp:Params>
                    <ojp:IncludeTrackSections>false</ojp:IncludeTrackSections>
                    <ojp:IncludeLegProjection>false</ojp:IncludeLegProjection>
                    <ojp:IncludeTurnDescription>false</ojp:IncludeTurnDescription>
                    <ojp:IncludeIntermediateStops>false</ojp:IncludeIntermediateStops>
                </ojp:Params>
            </ojp:OJPTripRequest>
        </ServiceRequest>
    </OJPRequest>
</OJP>')


post <- httr::POST(url="https://api.opentransportdata.swiss/ojp2020",
                  add_headers(Authorization=auth),
                  httr::content_type_xml(),
                  body=body)

# extract response
response <- suppressMessages(httr::content(post,as="text"))

# Error message if rate limit is exceeded
if(grepl("Rate limit exceeded", response)) stop("Rate limit exceeded")

# version with xml2
parsed_xml <- xml2::read_xml(response)

# xml_name(parsed_xml)
# xml_children(parsed_xml)
# xml_text(parsed_xml)

# xml_find_all(xml_list , ".//siri:TripResult")

trips <- xml2::xml_find_all(parsed_xml, ".//ojp:Trip")

doc <- xml2::read_xml(response)

# Check if status == TRUE
trips_found <- xml2::xml_find_all(doc, ".//siri:Status")%>%
  xml2::xml_text()

# verbose if(all(trips_found!=true)) {message("trip not found")}

if(all(trips_found=="true")) {

# Get data

  # https://xml2.r-lib.org/reference/xml_find_all.html

# braucht es gsub?
dataframe <- xml_find_all(doc, ".//ojp:Trip") %>%
  purrr::map_df(function(x) {
    list(
      # get tripdurations
      trip_duration=xml2::xml_find_first(x, ".//ojp:Duration") %>%  xml2::xml_text() %>%  gsub('^"|"$', "", .),
      # get number of transfers
      transfers=xml2::xml_find_first(x, ".//ojp:Transfers") %>%  xml2::xml_text() %>%  gsub('^"|"$', "", .)
    )
  })

} else {

dataframe <- tibble(
  trip_duration=NA,
  transfers=NA
  )
}

# if(xml_data2$OJPResponse$ServiceDelivery$OJPTripDelivery$Status=="true"){
#
#   trip_duration <- xml_data2$OJPResponse$ServiceDelivery$OJPTripDelivery$TripResult$Trip$Duration
#
# } else {trip_duration <- NA}

message(paste0(long_dest,lat_dest))

dataframe %>%
  mutate(
    #extract hours
      trip_duration_h = as.numeric(gsub(".*?([0-9]+)H.*", "\\1", trip_duration)),
    #extract minutes
      trip_duration_m = as.numeric(gsub(".*?([0-9]+)M.*", "\\1", trip_duration))) %>%
    #calulate trip duration in minutes
      dplyr::mutate(duration_min=ifelse(is.na(trip_duration_h),trip_duration_m,trip_duration_h*60+trip_duration_m),
           #coordinates /id of the origin
           origin=list(st_point(c(long_or,lat_or))),
           # origin_id=origin_id,
           #coordinates of the destination
           destination=list(st_point(c(long_dest,lat_dest)))) %>%
           # destination_id=destination_id
#            #as sf dataframe / set swiss coordinate system
#            sf::st_as_sf() %>%
#            sf::st_set_crs(4326)%>%
           dplyr::select(-trip_duration_h,-trip_duration_m) %>%
           dplyr::select(duration_min,
                         duration_orig=trip_duration,
                         transfers,
                         origin,
                         # origin_id,
                         destination
                         # ,
                         # destination_id
                         )


}
