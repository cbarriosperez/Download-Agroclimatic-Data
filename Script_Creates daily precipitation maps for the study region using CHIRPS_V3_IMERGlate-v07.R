##############################################################################
## This script generates daily precipitation maps for the study-area extent ##
## using CHIRPS_V3_IMERGlate-v07 data for 2000-2025.                        ##
## Created by: Camilo Barrios-Perez (Ph.D) - c.barrios@cgiar.org            ##
##############################################################################

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

###########################################################################################
### This script section will make a for loop to extract daily precipitation from CHIRPS ###
###########################################################################################

##-- Working directory --##

setwd("\\\\ALLIANCEDFS.ALLIANCE.CGIAR.ORG/data_cluster17V2/Observed_Climate data/CHIRPS_V3/CHIRPS_V3_IMERGlate-v07_Daily")

#######################################################################################################
## This script section will make a for loop to import the CHIRPS global daily precipitation maps     ##
## and then clip them using the Zoi shapefile. Next, a folder will be created for each year to       ##
## save the daily precipitation maps of the study region                                             ##
#######################################################################################################

##--- Read folders with the number of years with CHIRPS information ---##

years = list.dirs(getwd(), full.names = FALSE, recursive = FALSE)

##--- Make the for Loop ---##

for(i in 20:(length(years))){
  #i=19
  ##-- Import raster files for each year --##
  
  rastlist = list.files(path = paste(getwd(),"/",1999+i,sep =""), pattern="tif$", full.names = TRUE, recursive = FALSE)
  allrasters = terra::rast(rastlist)
  
  ##-- Crop and mask the precipitation maps to Zoi shapefile --##
  
  precipitation = crop(allrasters, Zoi)
  precipitation = ifel(precipitation < 0, NA, precipitation)
  
  ##-- Create folders to save daily precipitation maps for each year --## 
  
  dir.create(paste("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/CHIRPS_V3_IMERGlate-v07/",1999+i,sep ="")) #change the folder
  
  for(j in 1:nlyr(precipitation)){
    
    raster.name = names(precipitation)[j]
    writeRaster(precipitation[[j]],paste("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/CHIRPS_V3_IMERGlate-v07/",1999+i,"/",raster.name,".tif",sep =""))
    
  }
  
}
