
# This program converts the ERA5 monthly temperature data file
# from NetCDF to CSV. The input for the program is one year's
# worth of hourly ERA5 data

#The ERA5 data is on a 0.25 degree grid. Because the grid 
# spacing is so small, the resulting CSV file is very big. 

# To make the data more manageable, I drop all grid 
# points except for those that correspond with integer
# degree values. This reduces the data down to 1/16 of its
# original size. Using this approach, the resulting CSV
# file is about 500 megabytes. To further reduce its size,
# I've included parameters to restrict the range of years you
# which to examine. Also, if you wish, you can isolate a
# rectangular lat/lon area, dropping all grid points outside
# of that area.

# the data inputs needed to run this program can be download from here:
# https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-land-monthly-means?tab=form


Location_R_Code <- "D:/JPW/data_ERA5_Hourly"  # location of your R program

ERA5_Data <- "D:/JPW/data_ERA5_Hourly/data_era5_hourly_t2m_2019.nc"

CSV_Output_File <<- "out_era5_daily.csv"  # this output file is produced by this program

Extract_Rectangular_Area <<- TRUE  # false = entire planet, true = a particular area

UseOneDegreeSpacing <<- TRUE   #    set to TRUE if you want to drop all non-integer latitude
                               #    and longitude grid points. This reduces the data to 
                               #    1/16th its original size.

# use the min and max boundaries below to specify a rectangular area

Area_Lat_Min <<- 35  # degrees north
Area_Lat_Max <<- 45  # degrees north

Area_Lon_Min <<- 250  # degrees east
Area_Lon_Max <<- 270  # degrees east

cat("\014")

# you need the ncdf4 library, but you only need to install it once

#install.packages("ncdf4")  
#install.packages("matrixStats")

library("ncdf4")
library("matrixStats")

setwd(Location_R_Code)

source("era5_hourly_tabulate_support.r")

cat("\014")

#Create_CSV_File(ERA5_Data)

Get_Slice(ERA5_Data)

print("Success! The CSV output file was generated. ")

print("Note that the data in the output file are expressed in degrees Celsius.")
