library(sqldf)
library(rworldmap)

stations <- read.fwf("ghcnd-stations.txt", widths = c(11, 9, 10, 7, 3, 31, 4, 4, 6, 14))
colnames(stations) <- c("ID", "LATITUDE", "LONGITUDE", "ELEVATION", "STATE", "NAME", "GSNFLAG", 
                        "HCNFLAG", "WMOID", "METHOD")

prcp <- read.fwf("mly-prcp-filled.txt", widths = c(11, 5,  6, 2, rep(c(5, 2), 11)))
colnames(prcp) <- c("STNID", "YEAR", paste(c("VALUE", "FLAG"), rep(c(1:12), each = 2), sep = ""))

data <- sqldf("SELECT s.*, p.*
               FROM stations as s
               INNER JOIN prcp as p on s.ID = p.STNID")

# Spatial Points
locs <- subset(data, data$STATE == " TX" & data$YEAR == "2000")
coordinates(locs) <- c("LONGITUDE", "LATITUDE")  # set spatial coordinates
crs.geo <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")  # geographical, datum WGS84
proj4string(locs) <- crs.geo
summary(locs)

## Subsetting a State in particular year
par(mar = rep(2, 4))
plot(locs, pch = 20, cex = 2, col = "steelblue")
plot(countriesLow, add = T)

###
gbmap <- gmap(locs, type = "satellite")

locs.gb.merc <- Mercator(locs)  # Google Maps are in Mercator projection. 
# This function projects the points to that projection to enable mapping
plot(gbmap)
points(locs.gb.merc, pch = 20, col = "red")


locs.gb.coords <- as.data.frame(coordinates(locs))  # retrieves coordinates 
# (1st column for longitude, 2nd column for latitude)
PlotOnStaticMap(lat = locs.gb.coords$LATITUDE, lon = locs.gb.coords$LONGITUDE, zoom = 5, 
                cex = 1.4, pch = 19, col = "red", FUN = points,  size = c(640, 640), add = F)


map.lim <- qbbox(locs.gb.coords$LATITUDE, locs.gb.coords$LONGITUDE, TYPE = "all")  # define region 
# of interest (bounding box)
mymap <- GetMap.bbox(map.lim$lonR, map.lim$latR, destfile = "gmap.png", maptype = "satellite")

PlotOnStaticMap(mymap, lat = locs.gb.coords$lat, lon = locs.gb.coords$lon, zoom = NULL, 
                cex = 1.3, pch = 19, col = "red", FUN = points, add = F)


