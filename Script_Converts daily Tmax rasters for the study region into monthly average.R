###########################################################################################################
## This script converts daily Tmax rasters for the study region into monthly averages.                   ##
## The script loops through each year's folder, average the daily TIFFs month-by-month, and writes out   ##
## a GeoTIFF for each month with a consistent name.                                                      ##
## By: Camilo Barrios-Pérez (c.barrios@cgiar.org)                                                        ##  
## Date: 11/13/2025                                                                                       ##
###########################################################################################################

####################
## Load libraries ##
####################

library(terra)     # Raster/spatial data handling (SpatRaster)
library(ncdf4)     # NetCDF support (not used below, but often handy with CHIRPS/ERA5)
library(lubridate) # Easy date handling (year/month extraction)

#####################################################################################
## Set the working Directory to import precipitation data for all gridded products ##
#####################################################################################

# Root folder that contains one subfolder per year (e.g., 1981, 1982, ..., etc.)
setwd("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/Tmax_5km_AgERA5")

##########################
# Tmax-AgERA5.v2 - Daily #
##########################

##--- Read the list of year folders that have daily TIFFs ---##
# Returns the immediate subdirectories (not recursive) as names (e.g., "1981", "1982", ...)
rastlist.Tmax = list.dirs(getwd(), full.names = FALSE, recursive = FALSE)

# Number of years available
nyears = length(rastlist.Tmax)

## Loop over years ##
for (i in 1:nyears){
  #i=1
  ## Generating range of dates; the first year is 1981 and builds years as 1980 + i.##
  date = seq(as.Date(paste0(1980+i,'-01-01')), as.Date(paste0(1980+i,'-12-31')), by = "day")
  
  # Extract year and month numbers for each date (e.g., 1981, 1..12)
  year = lubridate::year(date)
  month = lubridate::month(date)
  
  ##-- Stack all daily rasters for this year --##
  # Build the path to this year's folder and list all .tif daily files inside.
  # Each file is assumed to be a single-day Tmax raster.
  rastlist = list.files(path = paste(getwd(),"/",1980+i,sep =""), pattern="tif$", full.names = TRUE, recursive = FALSE)
  allrasters = terra::rast(rastlist)
  
  ## Loop over months to compute monthly averages ##
  for (j in 1:12) {
    #j=1
    
    # Define start/end month (same because we process one month at a time)
    month_start= j
    month_end= j
    
    # First and last daily positions for this month (useful if we needed ranges)
    ini= which(year == 1980+i & month == month_start)[1]#Get the index of the first date corresponding to the year 'i' and the starting month
    last = which(year == 1980+i & month == month_end)[length(which(year == 1980+i & month == month_end))] 
    
    # Average all daily Tmax layers for the current month to get monthly average
    Avg.Tmax = mean(allrasters[[ini:last]])
    
    # Zero-padded month string (e.g., "01", "02", ..., "12")
    month_str = sprintf("%02d", j)
    
    # Name the output raster layer (e.g., "ETo_Total_198101")
    names(Avg.Tmax)= paste0("Tmax_Avg_",1980+i, month_str) 
    
    # Write or export the monthly precipitation raster to disk
    writeRaster(Avg.Tmax, paste0("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Mensual/Tmax_5km_AgERA5/Tmax_AgERA5-v2_", 1980+i, month_str, ".tif"))
    
  }
}
