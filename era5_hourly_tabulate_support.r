Get_Header <- function(sFile)
{
  nc <- nc_open(sFile)
  print(nc) # uncomment this line if you want to see an overview of the file contents
  close(nc)
}


Create_CSV_File <- function(sFile)
{
  
  # 1440 longitude steps, where each step = 0.25 degrees
  # 721 latitude steps, where each step = 0.25 degrees
  # 8760 hourly time steps = 365 days
  
  nc <- nc_open(sFile)
  
  # print(nc) # uncomment this line if you want to see an overview of the file contents
  
  dname <- "t2m" # temperature at 2 meters above the earth's surface
  dlname <- ncatt_get( nc, dname, attname="long_name", verbose=FALSE )
  dlunits <- ncatt_get( nc, dname, attname="units", verbose=FALSE )
  fillvalue <- ncatt_get(nc, dname, "_FillValue")
  scale <- ncatt_get(nc, dname,"scale_factor")
  offset <- ncatt_get(nc,dname,"add_offset")

  fillvalue <- as.numeric(fillvalue)  # -32767
  scale <- as.numeric(scale)    # 0.001763198
  offset <- as.numeric(offset)  # 257.7037
  
  # get the dimensions of the data array  
  
  xlon <- ncvar_get(nc, "longitude")
  xlat <- ncvar_get(nc, "latitude")
  xver <- ncvar_get(nc, "expver")
  xtime <- ncvar_get(nc, "time")
  
  nlon <- dim(xlon)   #1440
  nlat<- dim(xlat)    #741
  nver<- dim(xver)    #2   version? 1, 5  
  ntime<- dim(xtime)  #492 months
  
  print(nlon)
  print(nlat)
  print(nver)
  print(ntime)
  
  # make grid of given longitude and latitude
  
  lonlat <- expand.grid(xlon, xlat)     
  lonlat <- data.frame(lonlat)
  
  names(lonlat)[1] <- "lon"
  names(lonlat)[2] <- "lat"
  
  nDays = ntime / 24
  nHour = 1
  nDays = 3
  
  # for each day in the year, use hourly data to compute the daily average temperature
  for (d in 1:nDays)
  {
    print(d)
    # extract 24 hours of data           #c(lon, lat, ver, time)
    myArray <- ncvar_get(nc, dname, start=c(1, 1, 1, nHour), count=c(-1, -1, 1, 24))
    # convert to data frame
    myVector <- as.vector(myArray) 
    myMatrix <- matrix(myVector, nrow = nlon * nlat, ncol = 24)
    myDF <- data.frame(myMatrix)
    # compute daily mean
    xDay <- rowMeans(subset(myDF, select = c(1:24)), na.rm = TRUE)
    xDay <- data.frame(xDay)
    # add label
    sDay <- paste("d", as.character(d), sep="")
    # save results
    names(xDay)[1] <- sDay
    if (d == 1) {
     xDays <- xDay  
    } else {
     xDays <- cbind(xDays,xDay)
    }
    # move to next day
    nHour <- nHour + 24
  }

  nc_close(nc)
  
  # convert from Kelvin to Celsius
    
  xDays <- xDays - 273.15
  
  # round
  
  xDays <- round(xDays, 2)
  
  # drop some lat/lon points, leaving us with with 1 degree spacing instead of 0.25 degrees
  
  xDays <- cbind(lonlat, xDays)
  
  myDF <- xDays
  
  if (UseOneDegreeSpacing == TRUE)
  {
    myDF <- myDF[ abs( myDF$lon - round(myDF$lon ) ) < 0.00000001,  ]
    myDF <- myDF[ abs( myDF$lat - round(myDF$lat ) ) < 0.00000001,  ]
    #myDF$xlon <- myDF$lon - floor(myDF$lon)
    #myDF$xlat <- myDF$lat - floor(myDF$lat)
    #print(names(myDF))
    #myDF <- subset(myDF, xlon == .25 | xlon == 0.75)
    #myDF <- subset(myDF, xlat == .25 | xlat == 0.75)
    #myDF <- subset(myDF, select= -c(xlon, xlat) )
  }
      
  # drop lat/lon points that are outside of user-specified rectangle
      
  if (Extract_Rectangular_Area == TRUE)
  {
    myDF <- myDF[ myDF$lat >= Area_Lat_Min,  ]
    myDF <- myDF[ myDF$lat <= Area_Lat_Max,  ]
    myDF <- myDF[ myDF$lon >= Area_Lon_Min,  ]
    myDF <- myDF[ myDF$lon <= Area_Lon_Max,  ]
  }
    
  #xOut <- round(xOut, 2)

  # output
  
  write.csv(myDF, file = CSV_Output_File, row.names = FALSE)

}  


Get_Slice <- function(sFile)
{
  
  # 1440 longitude steps, where each step = 0.25 degrees
  # 721 latitude steps, where each step = 0.25 degrees
  # 8760 hourly time steps = 365 days
  
  nc <- nc_open(sFile)
  
  # print(nc) # uncomment this line if you want to see an overview of the file contents
  
  dname <- "t2m" # temperature at 2 meters above the earth's surface
  dlname <- ncatt_get( nc, dname, attname="long_name", verbose=FALSE )
  dlunits <- ncatt_get( nc, dname, attname="units", verbose=FALSE )
  fillvalue <- ncatt_get(nc, dname, "_FillValue")
  scale <- ncatt_get(nc, dname,"scale_factor")
  offset <- ncatt_get(nc,dname,"add_offset")
  
  fillvalue <- as.numeric(fillvalue)  # -32767
  scale <- as.numeric(scale)    # 0.001763198
  offset <- as.numeric(offset)  # 257.7037
  
  # get the dimensions of the data array  
  
  xlon <- ncvar_get(nc, "longitude")
  xlat <- ncvar_get(nc, "latitude")
  xver <- ncvar_get(nc, "expver")
  xtime <- ncvar_get(nc, "time")
  
  nlon <- dim(xlon)   #1440
  nlat<- dim(xlat)    #741
  nver<- dim(xver)    #2   version? 1, 5  
  ntime<- dim(xtime)  #492 months
  
  print(nlon)
  print(nlat)
  print(nver)
  print(ntime)
  
  # make grid of given longitude and latitude
  
  lonlat <- expand.grid(xlon, xlat)     
  lonlat <- data.frame(lonlat)
  
  names(lonlat)[1] <- "lon"
  names(lonlat)[2] <- "lat"
  
  myArray <- ncvar_get(nc, dname, start=c(1, 1, 1,1), count=c(-1, -1, 1, 72))
  # convert to data frame
  myVector <- as.vector(myArray) 
  myMatrix <- matrix(myVector, nrow = nlon * nlat, ncol = 72)
  myDF <- data.frame(myMatrix)

  nc_close(nc)
  
  # convert from Kelvin to Celsius
  
  myDF <- myDF - 273.15
  
  # round
  
  myDF <- round(myDF, 2)
  
  # drop some lat/lon points, leaving us with with 1 degree spacing instead of 0.25 degrees
  
  myDF <- cbind(lonlat, myDF)
  
  if (UseOneDegreeSpacing == TRUE)
  {
    #myDF <- myDF[ abs( myDF$lon - round(myDF$lon ) ) < 0.00000001,  ]
    #myDF <- myDF[ abs( myDF$lat - round(myDF$lat ) ) < 0.00000001,  ]
    myDF$xlon <- myDF$lon - floor(myDF$lon)
    myDF$xlat <- myDF$lat - floor(myDF$lat)
    myDF <- subset(myDF, xlon == .25 | xlon == 0.75)
    myDF <- subset(myDF, xlat == .25 | xlat == 0.75)
    myDF <- subset(myDF, select= -c(xlon, xlat) )
  }
  
  # drop lat/lon points that are outside of user-specified rectangle
  
  if (Extract_Rectangular_Area == TRUE)
  {
    myDF <- myDF[ myDF$lat >= Area_Lat_Min,  ]
    myDF <- myDF[ myDF$lat <= Area_Lat_Max,  ]
    myDF <- myDF[ myDF$lon >= Area_Lon_Min,  ]
    myDF <- myDF[ myDF$lon <= Area_Lon_Max,  ]
  }
  
  #xOut <- round(xOut, 2)
  
  # output
  
  write.csv(myDF, file = "out_72_hours.csv", row.names = FALSE)
  
}  




round_df <- function(df, digits) 
{
  
  nums <- vapply(df, is.numeric, FUN.VALUE = logical(1))
  
  df[,nums] <- round(df[,nums], digits = digits)
  
  (df)
  
}

