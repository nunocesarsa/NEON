

###################### IMAGEMAGICK WRAPPERS ############################
#image magick functions
## https://imagemagick.org/script/command-line-options.php




## function to generate call imagemagick to convert NEON NEF to anotherimage

NEF2RST <- function(path.in,fld.out="./NEF2RST/",out.name="Image.jpg",interlace=T,autogamma=T,qval=100){
  
  #increase the gblur and decrease the quality to save low resolution images
  
  #-strip -> removes metadata
  #-plane -> creates a rgb image
  path.out = paste(fld.out,out.name,sep="")
  
  if (interlace==T){
    interstr = "-interlace Plane"
  } else {
    interstr = ""
  }
  
  if (autogamma==T){
    autogstr = "-auto-gamma"
  } else{
    autogstr = ""
  }
  
  out.str = paste("magick",
                  path.in,
                  autogstr,
                  interstr,
                  #"-auto-gamma -interlace Plane",
                  #"-compress lzw",
                  "-quality", paste(qval,"%",sep=""),
                  path.out)
  
  
  return(out.str)
  
  #out.str = paste("magick",
  #                path.in,
                  #"-auto-gamma -interlace Plane",
  #                "-auto-gamma -interlace Plane -gaussian-blur", gblur,
                  #"-compress lzw",
  #                "-quality", paste(qval,"%",sep=""),
  #                path.out)
  
  
}

#https://s3.data.neonscience.org/neon-dhp-images/D11/2019/CLBJ15/CLBJ_002/understory/D11_8745.NEF
#https://s3.data.neonscience.org/neon-dhp-images/D11/2019/CLBJ15/CLBJ_002/overstory/D11_8702.NEF

#NEF2RST("ola")
#NEF2RST("D:/NEON/DHP_LAI_Scripts/TestData/Upward_D11_8702.NEF",
#        "D:/NEON/DHP_LAI_Scripts/TestOutputs/",
#        "Upward_D11_8702.jpg")
#system(NEF2RST("D:/NEON/DHP_LAI_Scripts/TestData/Upward_D11_8702.NEF",
#               "D:/NEON/DHP_LAI_Scripts/TestOutputs/",
#               "Upward_D11_8702.jpg"))
#system(NEF2RST("D:/NEON/DHP_LAI_Scripts/TestData/Upward_D11_8702.NEF",
#               "D:/NEON/DHP_LAI_Scripts/TestOutputs/",
#               "Upward_D11_8702_LQ.jpg",0.25,5))

channelremove <- function(path.in,fld.out="./NEF2RST/",out.name="Image_Blue.jpg",channels="RG"){
  
  #this function removes channels from the input image. If you want red channel, you should remove gb, etc. 
  
  path.out = paste(fld.out,out.name,sep="")
  
  out.str = paste("magick",
                  path.in,
                  "-channel",channels,
                  "-fx 0",
                  path.out)
  
  return(out.str)
  
}

#channelremove("D:/NEON/DHP_LAI_Scripts/TestOutputs/Upward_D11_8702.jpg",
#        "D:/NEON/DHP_LAI_Scripts/TestOutputs/","Upward_D11_8702_blue.jpg",
#        "RG")
#system(channelremove("D:/NEON/DHP_LAI_Scripts/TestOutputs/Upward_D11_8702.jpg",
#                     "D:/NEON/DHP_LAI_Scripts/TestOutputs/","Upward_D11_8702_red.jpg",
#                     "BG"))

thresholder <- function(path.in,fld.out="./NEF2RST/",out.name="Image_Blue.jpg",method="Otsu"){
  
  #runs one of the thresholders provided by imagemagick https://imagemagick.org/script/command-line-options.php#auto-threshold
  
  path.out = paste(fld.out,out.name,sep="")
  
  out.str = paste("magick convert",
                  path.in,
                  "-auto-threshold",method,
                  path.out)
  
  
  
  return(out.str)
}


########################################################################

############### LAI CALCULATION FUNCTIONS ##############################


#generating a raster to represent all zenith angles in the image - scaled to the diagonal 180deg
gen_zenith_rst = function(in.rst,method=1){
  
  #somewhat arbitrary
  #binary.image = in.rst > 50
  binary.image = in.rst
  
  #get the corner coordinates
  if (method==1){
    x_r <- xFromCol(binary.image,ncol(binary.image))
    y_t <- yFromRow(binary.image,1)
  } else if (method == 2){
    x_r <- ncol(binary.image)
    y_t <- nrow(binary.image)
  } else{
    stop(paste("method",method,"is not implemented"))
  }


  
  #get center coordinates
  x_c <- x_r/2
  y_c <- y_t/2
  
  #get diagonal:
  diag = sqrt((x_r)^2+(y_t)^2)
  diag_angle = 180/diag #this assumes a camera wit 180º along the diagonal
  
  #creates a raster with the X and Y coordinaates - this makes it easier later when generating the zenith raster
  x_rst <- setValues(binary.image,xFromCell(binary.image,1:ncell(binary.image)))
  y_rst <- setValues(binary.image,yFromCell(binary.image,1:ncell(binary.image)))
  
  
  #plot(x_rst)
  
  #here we go
  
  #test.rst = sqrt((x_rst-x_c)^2+(y_rst-y_c)^2)
  #plot(test.rst)
  zen_rst <- sqrt((x_rst-x_c)^2+(y_rst-y_c)^2)*diag_angle

  
  return(zen_rst) 
}

#generating a raster to represent all angles in relation to a zenith
gen_azimuth_rst <- function(in.rst,method=1,doflip=T){
  
  #somewhat arbitrary
  #binary.image = in.rst > 50
  binary.image = in.rst
  
  #get the corner coordinates
  if (method==1){
    x_r <- xFromCol(binary.image,ncol(binary.image))
    y_t <- yFromRow(binary.image,1)
  } else if (method == 2){
    x_r <- ncol(binary.image)
    y_t <- nrow(binary.image)
  } else{
    stop(paste("method",method,"is not implemented"))
  }
  
  #get center coordinates
  x_c <- x_r/2
  y_c <- y_t/2
  
  #get diagonal:
  diag = sqrt((x_r)^2+(y_t)^2)
  diag_angle = 180/diag #this assumes a camera wit 180º along the diagonal
  
  #creates a raster with the X and Y coordinaates - this makes it easier later when generating the zenith raster
  x_rst <- setValues(binary.image,xFromCell(binary.image,1:ncell(binary.image)))
  y_rst <- setValues(binary.image,yFromCell(binary.image,1:ncell(binary.image)))
  
  
  ### using atan2
  #by using abs functions we can force the image to create mirrored  versions which might be useful
  azi_rst <- atan2((x_rst-x_c),(y_rst-y_c))*180/pi+180
  
  if (doflip==T){
    return(flip(azi_rst,direction = 'y'))
  } else if (doflip == T){
    return(azi_rst)
  } else {
    stop(paste(doflip,"is not recognized, either True or False"))
    
  }
  
  
}

#this function extracts a ring given an image that represent the distance in zenith from the center
ring_calc <- function(r, min, max,ringval=NA,closed="both") {
  rr <- r[]
  
  #notice that this methods EXCLUDES so, the next logic is a bit funky at first to understand
  if (closed == "both"){
    
    rr[rr < min | rr > max] <- ringval
    
  } else if (closed == "left"){
    
    rr[rr < min | rr >= max] <- ringval
  } else if (closed == "right"){
    rr[rr <= min | rr > max] <- ringval
    
  } else if (closed == "neither"){
    rr[rr <= min | rr >= max] <- ringval
  }

  r[] <- rr
  r
}


#this function removes the selected area of the image
ring_calc2 <- function(r, min, max,ringval=NA,closed="both") {
  rr <- r[]
  
  #notice that this methods includes
  if (closed == "both"){
    
    rr[rr >= min & rr <= max] <- ringval
    
  } else if (closed == "left"){
    
    rr[rr <= min & rr > max] <- ringval
    
  } else if (closed == "right"){
    rr[rr < min & rr >= max] <- ringval
    
  } else if (closed == "neither"){
    rr[rr < min & rr > max] <- ringval
  }
  
  r[] <- rr
  r
}

## function to generate a set of zenith/azimuth windows to be used for the rest of the calculations
gen_grid <- function(zen.in,azi.in,zen_max=60,zen_min=0,zen_width=10,azi_width=10,verbose=F){
  
  #creating a list of out multipliers 
  list.zen = seq(1,round((zen_max-zen_min)/zen_width))
  list.azi = seq(1,round(360/azi_width))
  
  #creating a blank output raster
  #out.rst = zen.in*0
  
  #id counter
  k = 1
  
  for (i in list.zen){
    
    min_zen = zen_min+(i-1)*zen_width
    max_zen = zen_min+i*zen_width
    
    if (verbose==T){
      print("...........................................")
      print(paste("Processing zenith: [",min_zen,",",max_zen,"]",sep=""))
    }
    


    i_zen = ring_calc(zen.in,min_zen,max_zen,closed="left")
    
    #plot(i_zen)
    
    for (j in list.azi){
      
      min_azi = (j-1)*azi_width
      max_azi = j*azi_width
      
      if (verbose==T){
        print(paste("Processing azimuth: [",min_azi,",",max_azi,"]",sep=""))
      }
      
      i_azi = ring_calc(azi.in,min_azi,max_azi,closed="left")
      
      #plot(i_azi)
      
      
      if (i==1 & j==1){
        #print("first if")
        out.rst = (i_zen*i_azi)*0+k
        k=k+1
      } else {
        #print("second if")
        tmp.rst = (i_zen*i_azi)*0+k
        out.rst = cover(out.rst,tmp.rst)
        k=k+1
      }
      
      #plot(out.rst)
      
      
    }
  }
  
  return(out.rst)
}

#ratio between 
ratio_sky <- function(x,doPlot=F){
  
  #the incoming raster (rst.in) should have values 0 for background/sky and 1 for the leaf/woody materials
  #x = rst.in > 50
  #x = rst.in
  
  #notice that if the data is a circular fisheye image then this will not work - you have to remove the black region first
  #meaning it expects full fisheye camera
  #ring_calc can be used for that purpose
  sky <- x==0
  veg <- x==1
  
  if (doPlot==T){
    par(mfrow=c(1,2))
    plot(sky,main="sky")
    plot(veg,main="veg")
    par(mfrow=c(1,1))
  }

  
  #outval = cellStats(sky,sum)/(cellStats(veg,sum)
  outval = cellStats(sky,sum)/(cellStats(veg,sum)+cellStats(sky,sum))
  
  return(outval)
}

gap_frac <- function(tgt.rst,zen.rst,min,max){
  
  ring = ring_calc(zen.rst,min,max)*0+1
  #plot(ring)
  outval = ratio_sky(ring*tgt.rst)
  return(outval)
}

PAI_calc <- function(x,zen_rst,azi_rst,method,zen_width=10,azi_width=10,ai=NA,wi=NA,verbose=F){
  
  #x is the binary classified image
  #zen.rst is a raster representing the zenith angle of each pixel, counter clockwise and as if the north was upwards from the center point
  #azi.rst is a raster representing the azimuth angle of each pixel
  
  #for LAI2200
  #ai is a list of zenith angles as this: c(7, 23, 38, 53, 68)
  #wi is a list of weights as this: c(0.034, 0.104, 0.160, 0.218, 0.494)
  
  #for Warren-Wilson - notice that in this case both LAIe and LAI are returned - clumping index can be estimated after
  #ai is the 57.5 zenith angle
  #wi is the scalar given in the formula: 0.93
  

  
  if (method == "LAI2200"){
  
    
    
    stop("Not working for now")
    
    #outval
    outval = 0
    
    #forces defaults if missing
    if (is.na(ai)){
      ai = c(7, 23, 38, 53, 68)
      print("Using default zenith angles for LAI2200")
    }
    if (is.na(wi)){
      wi = c(0.034, 0.104, 0.160, 0.218, 0.494)
      print("Using default weights for LAI2200")
    }
    
    #checks if length of ai and wi and breaks if nto the same
    if(length(ai)!=length(wi)){stop("Length mismatch between zenith angles and weights")}
    
    #iterating on the angles
    for (i in 1:length(ai)){
      
      #print(i)
      
      
      zen_min = ai[i] - zen_width/2
      zen_max = ai[i] + zen_width/2
      
      #generates the required grid
      cell_rst = gen_grid(zen_rst,azi_rst,
                          zen_min = zen_min,zen_max=zen_max,
                          zen_width = zen_width, azi_width = azi_width,
                          verbose = verbose)
      
      
      outval_angle=0
    
      for (j in unique(cell_rst)){
        #print(j)
        
        tmp.rst <- cell_rst==j
        
        #print("here 2")
        tmp.rst[tmp.rst==0] <- NA
        
        #fetching the binary values
        #print("here 3")
        tmp.rst = tmp.rst*x
        
        outval_angle =  outval_angle + ratio_sky(tmp.rst)
      }
      #plot(cell_rst)
      
      print(outval_angle)
      outval = outval+2*(-log(outval_angle)*wi[i]*cos(ai[i]*pi/180))
      
    }
    
    
    #outval = 2*(-log(outval)*wi[i]*cos(angle[i]*pi/180))
    return(outval)
    
  } 
  else if(method=="Warren-Wilson"){
  
    #forces defaults if missing
    if (is.na(ai)){
      ai = 57.5
      print("Using default zenith of 57.5 degree for Warren-wilson")
    }
    if (is.na(wi)){
      wi = 0.93
      print("Using default scalar of 1/0.93 for Warren-wilson")
    }
    
    #fetching mins
    zen_min = 1 - zen_width/2
    zen_max = 1 + zen_width/2
    
    #generating cell area 
    cell_rst = gen_grid(zen_rst,azi_rst,
                        zen_min = zen_min,zen_max=zen_max,
                        zen_width = zen_width, azi_width = azi_width,
                        verbose = verbose)
    
    
    #temp values
    sum_gapf = 0
    sum_log_gapf = 0
    
    unique_vals = unique(cell_rst)
    mean_scaler = length(unique_vals)

    #iterating on the various gap fractions
    for (j in unique_vals){
      
      
      tmp.rst <- cell_rst==j
      
      #print("here 2")
      tmp.rst[tmp.rst==0] <- NA
      
      #fetching the binary values
      #print("here 3")
      tmp.rst = tmp.rst*x
      
      sum_gapf  =  sum_gapf  + ratio_sky(tmp.rst)/mean_scaler
      sum_log_gapf  = sum_log_gapf + log(ratio_sky(tmp.rst))
    }
    
    #warren miler returns a list
    outval = list()
    
    outval["LAIe"]= -log(sum_gapf)/wi
    outval["LAI"] = -(sum_log_gapf/mean_scaler)/wi
    outval["ClumpInd"] = outval$LAIe/outval$LAI
    
    return(outval)
  }
  
  
  
  
}

#####################################################################################################

PAI_calc_parallel <- function(x,zen_rst,azi_rst,method,zen_width=10,azi_width=10,ai=NA,wi=NA,verbose=F){
  
  #x is the binary classified image
  #zen.rst is a raster representing the zenith angle of each pixel, counter clockwise and as if the north was upwards from the center point
  #azi.rst is a raster representing the azimuth angle of each pixel
  
  #for LAI2200
  #ai is a list of zenith angles as this: c(7, 23, 38, 53, 68)
  #wi is a list of weights as this: c(0.034, 0.104, 0.160, 0.218, 0.494)
  
  #for Warren-Wilson - notice that in this case both LAIe and LAI are returned - clumping index can be estimated after
  #ai is the 57.5 zenith angle
  #wi is the scalar given in the formula: 0.93
  
  
  
  if (method == "LAI2200"){
    
    
    
    stop("Not working for now")
    
    #outval
    outval = 0
    
    #forces defaults if missing
    if (is.na(ai)){
      ai = c(7, 23, 38, 53, 68)
      print("Using default zenith angles for LAI2200")
    }
    if (is.na(wi)){
      wi = c(0.034, 0.104, 0.160, 0.218, 0.494)
      print("Using default weights for LAI2200")
    }
    
    #checks if length of ai and wi and breaks if nto the same
    if(length(ai)!=length(wi)){stop("Length mismatch between zenith angles and weights")}
    
    #iterating on the angles
    for (i in 1:length(ai)){
      
      #print(i)
      
      
      zen_min = ai[i] - zen_width/2
      zen_max = ai[i] + zen_width/2
      
      #generates the required grid
      cell_rst = gen_grid(zen_rst,azi_rst,
                          zen_min = zen_min,zen_max=zen_max,
                          zen_width = zen_width, azi_width = azi_width,
                          verbose = verbose)
      
      
      outval_angle=0
      
      for (j in unique(cell_rst)){
        #print(j)
        
        tmp.rst <- cell_rst==j
        
        #print("here 2")
        tmp.rst[tmp.rst==0] <- NA
        
        #fetching the binary values
        #print("here 3")
        tmp.rst = tmp.rst*x
        
        outval_angle =  outval_angle + ratio_sky(tmp.rst)
      }
      #plot(cell_rst)
      
      print(outval_angle)
      outval = outval+2*(-log(outval_angle)*wi[i]*cos(ai[i]*pi/180))
      
    }
    
    
    #outval = 2*(-log(outval)*wi[i]*cos(angle[i]*pi/180))
    return(outval)
    
  } 
  else if(method=="Warren-Wilson"){
    
    #forces defaults if missing
    if (is.na(ai)){
      ai = 57.5
      print("Using default zenith of 57.5 degree for Warren-wilson")
    }
    if (is.na(wi)){
      wi = 0.93
      print("Using default scalar of 1/0.93 for Warren-wilson")
    }
    
    #fetching mins
    zen_min = 1 - zen_width/2
    zen_max = 1 + zen_width/2
    
    #generating cell area 
    cell_rst = gen_grid(zen_rst,azi_rst,
                        zen_min = zen_min,zen_max=zen_max,
                        zen_width = zen_width, azi_width = azi_width,
                        verbose = verbose)
    
    
    #temp values
    sum_gapf = 0
    sum_log_gapf = 0
    
    unique_vals = unique(cell_rst)
    mean_scaler = length(unique_vals)
    
    UseCores <- 8 # i want to do other stuff at the same time...
    cl       <- makeCluster(UseCores)
    registerDoParallel(cl)
    
    
    #iterating on the various gap fractions
    out.df = foreach(j=1:length(unique_vals),.combine = rbind) %dopar% { 
      
      library(raster)
      source("D:/NEON/DHP_LAI_Scripts/DHP_LAI_R/FunctionsImport.r")
      
      
      #fetching raster
      k = unique(cell_rst)[j]
      
      #selects the ith cell
      tmp.rst <- cell_rst == k
      #creates a mask only for the ith cell
      tmp.rst[tmp.rst==0] <- NA
      
      #multiplying
      tmp.rst = tmp.rst*x
      
      #fetching values
      #sum_gapf  =  sum_gapf  + ratio_sky(tmp.rst)/mean_scaler
      #sum_log_gapf  = sum_log_gapf + log(ratio_sky(tmp.rst))
      
      outval = data.frame("LAIe"=ratio_sky(tmp.rst),
                          "LAI"=log(ratio_sky(tmp.rst)))
    
    }
    
    stopCluster(cl)
    #gc()

    
    #warren miler returns a list
    outval = list()
    
    outval["LAIe"]= -log(mean(out.df$LAIe))/wi
    
    outval["LAI"] = -mean(out.df$LAI)/wi
    
    outval["ClumpInd"] = outval$LAIe/outval$LAI
    
    return(outval)
  }
  
  
  
  
}



### downwards images

thr_downwards <- function(in.path){
  
  #input should be the multiband raster with RGB bands
  R = raster(in.path,band=1)#stack(in.path,band=1)
  G = raster(in.path,band=2)#stack(in.path,band=2)
  B = raster(in.path,band=3)#stack(in.path,band=3)
  
  exG = 2*G - R - B
  exR = 1.4*R-G
  
  tmp.rst = (exG - exR)
  
  return(tmp.rst>0)
}


