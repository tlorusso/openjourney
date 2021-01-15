# # Generate a raster of the canton of zurich to get p
#
# library(raster)
#
# ## testdata
#
# # shapefile
# shp <- getData(country='CH', level=1) %>%
#         sf::st_as_sf() %>%
#         filter(NAME_1=="Zürich")
#
# r <- raster(ncol=180, nrow=180)
# r <- raster(ncol=40, nrow=40)
# extent(r) <- extent(shp)
# rp <- rasterize(shp, r)
#
# plot(rp)
#
# sf_coords <- rasterToPoints(rp, spatial=TRUE) %>% sf::st_as_sf()
#
# coords <- sf::st_coordinates(sf_coords) %>%
#           as_tibble() %>%
#           rename(lat=Y,lon=X)
#
#
#
#
body
