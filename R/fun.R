#' get_ojp_time get ...
#'
#' @param auth authentication token
#' @param origin geocoordinates of the origin, WGS
#' @param destination geocoordinates of the destination
#' @param time departure time in format "YYYY-MM-16T08:34:40"
#'
#' @return tibble
#' @export
#'
#' @examples
#' coords <- geo(address = c("Zürich Schwamendingerplatz, Switzerland", 
#'                           "Bahnhof Stettbach, Switzerland"), method ='osm')
#' 
#' ojp <- get_ojp_time(
#'   origin=c(coords[1,]$long,coords[1,]$lat), 
#'   destination=c(coords[2,]$long,coords[2,]$lat)
#' )

get_ojp_time <- function(auth=token1,
                         origin=NA, 
                         destination=NA,
                         time="2020-12-16T08:34:40"){
  
long_or <- origin[1]
lat_or <- origin[2]
  
long_dest <- destination[1]
lat_dest <- destination[2]

body  <-glue::glue('<?xml version="1.0" encoding="utf-8"?>
<OJP xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.siri.org.uk/siri" version="1.0" xmlns:ojp="http://www.vdv.de/ojp" xsi:schemaLocation="http://www.siri.org.uk/siri ../ojp-xsd-v1.0/OJP.xsd">
    <OJPRequest>
        <ServiceRequest>
            <RequestTimestamp>2020-12-16T20:38:51.798Z</RequestTimestamp>
            <RequestorRef>R Pa</RequestorRef>
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

# body
response <- httr::content(post,as="text")

parse <- xmlParse(response)

xml_data2 <<- xmlToList(parse)
# get duration of trip
tibble::tibble(
  origin=list(c(lat_or,long_or)),
  destination=list(c(lat_dest,long_dest)),
  duration=xml_data2$OJPResponse$ServiceDelivery$OJPTripDelivery$TripResult$Trip$Duration)

}