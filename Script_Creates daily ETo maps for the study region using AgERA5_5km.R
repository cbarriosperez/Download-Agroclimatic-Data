####################################################################
## This script generates daily ETo maps for the study-area extent ##
## using AgERA5_V2 data for 1981-2025.                            ##
## Created by: Camilo Barrios-Perez (Ph.D) - c.barrios@cgiar.org  ##
####################################################################

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

###########################################################################################
### This script section will make a for loop to extract daily precipitation from CHIRPS ###
###########################################################################################

##-- Working directory --##

setwd("\\\\ALLIANCEDFS.ALLIANCE.CGIAR.ORG/data_cluster17V2/Observed_Climate data/AgERA5_V2/ETo")

##################################################################################################
## This script section will make a for loop to import the ETo global daily precipitation maps   ##
## and then clip them using the Zoi shapefile. Next, a folder will be created for each year to  ##
## save the daily precipitation maps of the study region                                        ##
##################################################################################################

##--- Read folders with the number of years with CHIRPS information ---##

years = list.dirs(getwd(), full.names = FALSE, recursive = FALSE)

##--- Make the for Loop ---##

for(i in 1:(length(years))){
  #i=1
  ##-- Import raster files for each year --##
  
  rastlist = list.files(path = paste(getwd(),"/",1980+i,sep =""), pattern=paste("ReferenceET-PenmanMonteith-FAO56_C3S-glob-agric_AgERA5_",1980+i,sep =""), full.names = TRUE, recursive = FALSE)
  allrasters = terra::rast(rastlist)
  
  ##-- Crop and mask the precipitation maps to Zoi shapefile --##
  
  ETo = crop(allrasters, Zoi)

  ##-- resample the raster stack maps of Tmax --##
  ETo.5km = resample(ETo,reference.5km, method = 'bilinear')
  res(ETo.5km)==res(reference.5km)
  
  ##-- Create folders to save daily ETo maps for each year --## 
  
  dir.create(paste("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/ETo_5km_AgERA5/",1980+i,sep ="")) #change the folder
  
  for(j in 1:nlyr(ETo.5km)){
    #j=1
    raster.name = time(ETo.5km)[j]
    writeRaster(ETo.5km[[j]],paste("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/ETo_5km_AgERA5/",1980+i,"/ETo_",raster.name,".tif",sep =""))
    
  }
  
}
