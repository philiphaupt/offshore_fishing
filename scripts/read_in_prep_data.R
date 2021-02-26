# git repo: https://github.com/philiphaupt/offshore_fishing.git
# https://odims.ospar.org/layers/geonode:ospar_bottom_f_intensur_2017_01_001
library(sf)
library(geojsonsf)
library(tidyverse)
library(RColorBrewer)
library(viridis)



# Read in fishing intensity 2017
fi_2017 <- geojsonsf::geojson_sf("https://odims.ospar.org/geoserver/wfs?srsName=EPSG%3A4326&outputFormat=json&service=WFS&srs=EPSG%3A4326&request=GetFeature&typename=geonode%3Aospar_bottom_f_intensur_2017_01_001&version=1.0.0&access_token=2b5be390784011eb8bcb0677b1562c8b")


# in district:
KEIFCA <- st_read("C:/Users/Phillip Haupt/Documents/GIS/6M_12M_from_territorial_sea_baseline_5_Jun_20_and_1983/KEIFCA_6NM.GPKG",  layer = "KEIFCA_6NM_district_1983_baseline_until_2020") %>% st_as_sf()
st_crs(KEIFCA)
st_layers("C:/Users/Phillip Haupt/Documents/GIS/6M_12M_from_territorial_sea_baseline_5_Jun_20_and_1983/KEIFCA_6NM.GPKG")

# clip by +6 nm bufffered (to get 12 NM) district
KEIFCA_buf <- st_buffer(KEIFCA, 11112) #1 nm = 1852, so 6 = 11112
KEIFCA_buf_wgs <- st_transform(KEIFCA_buf, 4326)
fi_2017_12NM <- st_intersection(fi_2017, KEIFCA_buf_wgs)

ggplot() +
  geom_sf(data = fi_2017_12NM, aes(fill = totvalue))+
  scale_fill_viridis(option = "C")+
  geom_sf(data = KEIFCA)
#  # 
ggplot() +
  geom_sf(data = fi_2017_12NM, aes(fill = SubsurfSAR))+
  scale_fill_gradientn(colors = terrain.colors(4))+
  geom_sf(data = KEIFCA)
  


# filter only the ones in Goodwin Sands
mcz_etrs89_sf <- st_read("C:/Users/Phillip Haupt/Documents/GIS/MPAs/MPAs_England.gpkg", layer = "MCZs_England_ETRS89_3035") # reads in the specified layer from geopackage
st_crs(mcz_etrs89_sf)# reveals taht the projections is ETRS89-extended - as indicated by the file name

goodwin_etrs89_sf <- mcz_etrs89_sf %>%  filter(MCZ_NAME == "Goodwin Sands") # KEEP ONLY Goodwin Sands MCZ - study area
goodwin_utm31_sf <- st_transform(goodwin_etrs89_sf, 32631) # transform the projection to UTM31N which is the standard used at KEIFCA.
goodwin_wgs84_sf <- st_transform(goodwin_utm31_sf, 4326) # only needed to intersect cefas survey data - which is a lot of points already in WGS84; therefore easier to transform Goodwin and then transform the intersected result to utm31N than transform ALL the points before intersecting.


# clip by goodwin
fi_goodwin_2017 <- st_intersection(fi_2017, goodwin_wgs84_sf)
ggplot(fi_goodwin_2017) +
  geom_sf(aes(fill = totvalue))

