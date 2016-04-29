library(sp)
library(maptools)
library(maps)
library(rgdal)
library(lattice)
library(grid)
library(RColorBrewer)
library(googleVis)
library(RgoogleMaps)
library(sqldf)
library(rworldmap)
library(dismo)

stations <- read.fwf("ghcnd-stations.txt", widths = c(11, 9, 10, 7, 3, 31, 4, 4, 6, 14))
colnames(stations) <- c("ID", "LATITUDE", "LONGITUDE", "ELEVATION", "STATE", "NAME", "GSNFLAG", 
                        "HCNFLAG", "WMOID", "METHOD")

prcp <- read.fwf("mly-prcp-filled.txt", widths = c(11, 5,  6, 2, rep(c(5, 2), 11)))
colnames(prcp) <- c("STNID", "YEAR", paste(c("VALUE", "FLAG"), rep(c(1:12), each = 2), sep = ""))

data <- sqldf("SELECT s.*, p.*
              FROM stations as s
              INNER JOIN prcp as p on s.ID = p.STNID")

prcp_texas <- subset(data, data$STATE == " TX" & data$YEAR == "2000")
prcp_texas <- prcp_texas[ ,c("LATITUDE", "LONGITUDE", "VALUE1")]
prcp_texas$LATITUDE <- as.numeric(prcp_texas$LATITUDE)
prcp_texas$LONGITUDE <- as.numeric(prcp_texas$LONGITUDE)
coordinates(prcp_texas) <- c("LONGITUDE", "LATITUDE")
crs.geo <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")
proj4string(prcp_texas) <- crs.geo

writeOGR(prcp_texas, dsn = "locsgb.shp", layer = "locs2.gb", driver = "ESRI Shapefile")
gb.shape <- readOGR("locsgb.shp")

ggplot() +  geom_polygon(data=gb.shape, aes(x=LONGITUDE, y=LATITUDE, group=group))
