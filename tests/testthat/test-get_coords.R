test_that("request works", {

  long_or <- 8.55
  lat_or <- 47.4

  long_dest <- 8.57
  lat_dest <- 47.4

  time <- paste0(Sys.Date(),"T08:34:40")

  token1 <- paste("Bearer", "57c5dbbbf1fe4d000100001863396e06bcc5472eab6cacd76e44d91e", sep = " ")


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

  # if(grepl("rate limit exceeded", response)) message("Rate limit exceeded")

  parse <- xmlParse(response)

  xml_data2 <- xmlToList(parse)

  testthat::expect_that(xml_data2$OJPResponse$ServiceDelivery$OJPTripDelivery$Status, equals("true"))

})
