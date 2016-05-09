
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
library(ggplot2)

stations <- read.fwf("ghcnd-stations.txt", widths = c(11, 9, 10, 7, 3, 31, 4, 4, 6, 14))
colnames(stations) <- c("ID", "LATITUDE", "LONGITUDE", "ELEVATION", "STATE", "NAME",
                        "GSNFLAG", "HCNFLAG", "WMOID", "METHOD")

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
summary(prcp_texas)

plot(prcp_texas, pch = 20, col = "steelblue")
plot(coastsCoarse, add = T)

prcp_texas <- subset(data, data$STATE == " TX" & data$YEAR == "2000")
prcp_texas <- prcp_texas[ ,c("LATITUDE", "LONGITUDE", "VALUE1")]
ggplot() +  geom_point(data=prcp_texas, aes(x=LONGITUDE, y=LATITUDE), fill="grey40", colour="grey90", alpha=1)+
  labs(x="", y="", title="Precipitation for Jan Year 2000")+ #labels
  theme(axis.ticks.y = element_blank(),axis.text.y = element_blank(), # get rid of x ticks/text
        axis.ticks.x = element_blank(),axis.text.x = element_blank(), # get rid of y ticks/text
        plot.title = element_text(lineheight=.8, face="bold", vjust=1))+ # make title bold and add space
  geom_point(aes(x=LONGITUDE, y=LATITUDE, color=VALUE1), data=prcp_texas, alpha=1, size=3, color="grey20")+# to get outline
  geom_point(aes(x=LONGITUDE, y=LATITUDE, color=VALUE1), data=prcp_texas, alpha=1, size=2)+
  scale_colour_gradientn("Precipitation", 
                         colours=c( "#f9f3c2","#660000"))+ # change color scale
  coord_equal(ratio=1) # square plot to avoid the distortion


