###############################################################################################################
## This script converts daily CHIRPS v3-ERA5 precipitation rasters for the study region into monthly totals. ##
## The script loops through each year's folder, sums the daily TIFFs month-by-month, and writes out          ##
## a GeoTIFF for each monthly total with a consistent name.                                                  ##
## By: Camilo Barrios-Pérez (c.barrios@cgiar.org)                                                            ##  
## Date: 8/13/2025                                                                                           ##
###############################################################################################################

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
setwd("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Diario/CHIRPS_V3_ERA5")

##########################
# CHIRPS-V3-ERA5 - Daily #
##########################

##--- Read the list of year folders that have daily TIFFs ---##
# Returns the immediate subdirectories (not recursive) as names (e.g., "1981", "1982", ...)
rastlist.Rain = list.dirs(getwd(), full.names = FALSE, recursive = FALSE)

# Number of years available
nyears = length(rastlist.Rain)

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
  # Each file is assumed to be a single-day precipitation raster.
  rastlist = list.files(path = paste(getwd(),"/",1980+i,sep =""), pattern="tif$", full.names = TRUE, recursive = FALSE)
  allrasters = terra::rast(rastlist)
  
  ## Loop over months to compute monthly totals ##
  for (j in 1:12) {
    #j=1
    
    # Define start/end month (same because we process one month at a time)
    month_start= j
    month_end= j
    
    # First and last daily positions for this month (useful if we needed ranges)
    ini= which(year == 1980+i & month == month_start)[1]#Get the index of the first date corresponding to the year 'i' and the starting month
    last = which(year == 1980+i & month == month_end)[length(which(year == 1980+i & month == month_end))] 
    
    # Sum all daily precipitation layers for the current month to get monthly total
    Total.rainfall = sum(allrasters[[ini:last]])
    
    # Zero-padded month string (e.g., "01", "02", ..., "12")
    month_str = sprintf("%02d", j)
    
    # Name the output raster layer (e.g., "Rain_Total_198101")
    names(Total.rainfall)= paste0("Rain_Total_",1980+i, month_str) 
    
    # Write or export the monthly precipitation raster to disk
    writeRaster(Total.rainfall, paste0("\\\\Catalogue/sat_pma/data/raw/Clima_Fuentes_Secundarias/Mensual/CHIRPS_V3_ERA5/Rain_Chirpsv3-ERA5_", 1980+i, month_str, ".tif"))
    
  }
}
