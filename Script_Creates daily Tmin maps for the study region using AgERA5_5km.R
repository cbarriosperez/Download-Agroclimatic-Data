#####################################################################
## This script generates daily Tmin maps for the study-area extent ##
## using AgERA5_V2 data for 1981-2025.                             ##
## Created by: Camilo Barrios-Perez (Ph.D) - c.barrios@cgiar.org   ##
#####################################################################

######################
## Upload libraries ##
######################

library(terra) # Para manejo de rásteres y análisis espacial
library(sp)    # Para trabajar con objetos espaciales
library(sf)    # Para leer y manipular datos vectoriales (shapefiles)

##############################################################
## Import the shapefile of the study region in the Amazonia ##
##############################################################

Zoi = st_read("\\\\Catalogue/sat_pma/data/inputs/zoi/zoi_geo.shp")

########################################################
## Import the reference raster file at 5km resolution ##
########################################################

reference.5km = terra::rast("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/CHIRPS_V3_ERA5/1981/chirps-v3.0.1981.01.01.tif")

#################################################################################################
### This script section will make a for loop to extract daily minimum temperature from AgERA5 ###
#################################################################################################

##-- Working directory --##

setwd("\\\\ALLIANCEDFS.ALLIANCE.CGIAR.ORG/data_cluster17V2/Observed_Climate data/AgERA5_V2/Minimum Temperature")

##################################################################################################
## This script section will make a for loop to import the Tmin global daily maps and then clip  ##
## them using the Zoi shapefile. Next, a folder will be created for each year to save the daily ##
## minimum temperature maps of the study region.                                                ##
##################################################################################################

##--- Read folders with the number of years with Tmin information ---##

years = list.dirs(getwd(), full.names = FALSE, recursive = FALSE)

##--- Make the for Loop ---##

for(i in 1:(length(years))){
  #i=1
  ##-- Import raster files for each year --##
  
  rastlist = list.files(path = paste(getwd(),"/",1980+i,sep =""), pattern=paste("Temperature-Air-2m_Min-24h_C3S-glob-agric_AgERA5_",1980+i,sep =""), full.names = TRUE, recursive = FALSE)
  allrasters = terra::rast(rastlist)
  
  ##-- Crop and mask the Tmin maps to Zoi shapefile --##
  
  Tmin = crop(allrasters, Zoi)
  
  ##-- Convert Tmin maps from K to °C --##
  T.min.C = (Tmin - 273.15)

  ##-- resample the raster stack maps of Tmin --##
  Tmin.5km = resample(T.min.C,reference.5km, method = 'bilinear')
  res(Tmin.5km)==res(reference.5km)
  
  ##-- Create folders to save daily Tmin maps for each year --## 
  
  dir.create(paste("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/Tmin_5km_AgERA5/",1980+i,sep ="")) #change the folder
  
  for(j in 1:nlyr(Tmin.5km)){
    #j=1
    raster.name = time(Tmin.5km)[j]
    writeRaster(Tmin.5km[[j]],paste("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/Tmin_5km_AgERA5/",1980+i,"/Tmin_",raster.name,".tif",sep =""))
    
  }
  
}
