################################################################################
## This script generates daily Solar Radiation maps for the study-area extent ##
## using AgERA5_V2 data for 1981-2025.                                        ##
## Created by: Camilo Barrios-Perez (Ph.D) - c.barrios@cgiar.org              ##
################################################################################

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

setwd("\\\\ALLIANCEDFS.ALLIANCE.CGIAR.ORG/data_cluster17V2/Observed_Climate data/AgERA5_V2/Solar Radiation")

##################################################################################################
## This script section will make a for loop to import the Srad global daily maps and then clip  ##
## them using the Zoi shapefile. Next, a folder will be created for each year to save the daily ##
## solar radiation maps of the study region.                                                    ##
##################################################################################################

##--- Read folders with the number of years with Srad information ---##

years = list.dirs(getwd(), full.names = FALSE, recursive = FALSE)

##--- Make the for Loop ---##

for(i in 1:(length(years))){
  #i=1
  ##-- Import raster files for each year --##
  
  rastlist = list.files(path = paste(getwd(),"/",1980+i,sep =""), pattern=paste("Solar-Radiation-Flux_C3S-glob-agric_AgERA5_",1980+i,sep =""), full.names = TRUE, recursive = FALSE)
  allrasters = terra::rast(rastlist)
  
  ##-- Crop and mask the Srad maps to Zoi shapefile --##
  
  Srad = crop(allrasters, Zoi)
  
  ##-- Convert S.radiation maps from J m-2 day-1 to MJ m-2 day-1 --##
  S.Rad.MJ = (Srad/1000000)

  ##-- resample the raster stack maps of Srad --##
  Srad.5km = resample(S.Rad.MJ,reference.5km, method = 'bilinear')
  res(Srad.5km)==res(reference.5km)
  
  ##-- Create folders to save daily Srad maps for each year --## 
  
  dir.create(paste("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/Rad.Solar_5km_AgERA5/",1980+i,sep ="")) #change the folder
  
  for(j in 1:nlyr(Srad.5km)){
    #j=1
    raster.name = time(Srad.5km)[j]
    writeRaster(Srad.5km[[j]],paste("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/Rad.Solar_5km_AgERA5/",1980+i,"/Srad_",raster.name,".tif",sep =""))
    
  }
  
}
