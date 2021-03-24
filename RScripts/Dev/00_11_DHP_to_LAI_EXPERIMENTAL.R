#library
library(HelpersMG)
library(stringr)

library(raster)
library(sp)
library(rgdal)
library(rgeos)

## Requirements: imagemagick & NEF intepreter for windows (in my case)
## imagemagick https://imagemagick.org/script/download.php
## https://downloadcenter.nikonimglib.com/en/download/sw/97.html


#loading aux functions to call imagemagick
source('D:/NEON/RScripts/Dev/Aux_MagickFunctions.R')

#loading aux functions to calculate LAI
source('D:/NEON/RScripts/Dev/Aux_LAI_Functions.R')


#THIS IS A TEST SCRIPT FOR LAI CALCULATION FROM NEON'S DHP PHOTOGRAPHY

#IT ADAPTS FROM METHODS SHARED BY 

#INTERESTING READS:
#https://www.sciencedirect.com/science/article/pii/S0034425720303059#!
#https://www.sciencedirect.com/science/article/pii/S0168192320300460?via=ihub
#https://doi.org/10.1890/ES12-00196.1
#in this paper the author uses rectangular images
#https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5743530/#ece33567-sup-0001
#but did this nikon project the data onto the sensor area instead?3
#https://www.mdpi.com/2072-4292/1/4/1298/htm
#the parameters of licor come from:
#https://acsess.onlinelibrary.wiley.com/doi/10.2134/agronj1991.00021962008300050009x
#generating a simple approximation of the angle to the center pixel

#HEMIPHOT SCRIPTS:
#https://github.com/naturalis/Hemiphot/blob/master/Hemiphot.R
#NEON PROJECT REPOSITORY
#https://github.com/NEONScience?page=2

#path to .csv file
path2csv = "D:/NEON/Data_Neon/getLocTOS_DHP_20210323/getLocTOS_NEON10017_dhp_perimagefile.csv"

#loading csv
dhp.df = read.csv(path2csv)

head(dhp.df)

#creating a year column
dhp.df$Year <- substr(dhp.df$startDate,1,4)
#creating a YYYYMMDD column
dhp.df$YYYYMMDD <- gsub("-",'',substr(dhp.df$startDate,1,10))


#making a selection 
sel.df = dhp.df[dhp.df$siteID=='BART' & dhp.df$Year==2019 & dhp.df$cameraOrientation=='upward',]

#data subset
sel.df = sel.df[c(1,25,75,150,200,230,300),]

sel.df

#iterating and downloading the data
setwd('D:/NEON/TestFolder/DHP')
for (row_i in 1:nrow(sel.df[1,])){
  
  #fetching link and generating name
  dl.link = sel.df$imageFileUrl[row_i]
  outname = paste(sel.df$plotID[row_i],
                  '_',
                  sel.df$YYYYMMDD[row_i],
                  '_',
                  sel.df$pointID[row_i], #if needed, this part can be padded on the right using: str_pad('s60',3,side='right',pad = 0)
                  #'.NEF',
                  sep = "")
  
  #download folder
  outpath = paste('D:/NEON/TestFolder/DHP/TmpDown/',outname,'.NEF',sep = "")
  #compressed folder
  outcomp = paste('D:/NEON/TestFolder/DHP/TmpComp/',outname,'.jpg',sep = "")
  #thumbnail
  outthum = paste('D:/NEON/TestFolder/DHP/Thumbnail/',outname,'.jpg',sep = "")
  #metadata
  outmeta = paste('D:/NEON/TestFolder/DHP/Metadata/',outname,'.txt',sep = "")
  #output thresholds
  outthre = "D:/NEON/TestFolder/DHP/TmpThres/"
  
  print(paste(row_i,'of',nrow(sel.df)))
  
  
  #DOWNLOADING
  #Should a tryCatch loop be here?
  print(paste('Downloading:',dl.link,'to',outpath))
  #download.file(dl.link,destfile = outpath,method="curl")
  
  #A working version
  mgk.cmp = magick_compress(outpath,outcomp,0.05,'75%')
  print(paste('Compressed at:',outcomp))
  #system(mgk.cmp)
  #print(mgk.cmp)
  
  #A thumbnail version
  print(paste('Thumbnail at:',outthum))
  mgk.thm = magick_compress(outpath,outthum,0.5,'1%')
  #system(mgk.thm)
  #print(mgk.thm)
  
  #The metadata
  print(paste('Metadata at:',outthum))
  mgk.meta = magick_metadata(outpath)
  #metadata <- system(mgk.meta, intern = TRUE)
  sink(outmeta)
  #print(metadata)
  sink()
  #print(mgk.meta)
  
  #calculating the threshold
  #magick_thrshold(outcomp,outthre,outname,algo='Otsu',keepBlue = T)
  
  #loading the binary image - notice that the otsu threshold from imagemagic is not absolutely 1/0 so we have to correct that
  
  binary.image = raster(paste(outthre,outname,"_Th.jpg",sep=""))> 50 
  
  #fetching corners and diagonal
  #corner coordinates
  x_r <- xFromCol(binary.image,ncol(binary.image))
  y_t <- yFromRow(binary.image,1)
  #center coordinates
  x_c <- x_r/2
  y_c <- y_t/2
  #diagonal
  diag = sqrt((x_r)^2+(y_t)^2)
  diag_angle = 180/diag #this assumes a camera with 180º along the diagonal
  
  #creates a raster with the X and Y coordinaates - this makes it easier later when generating the zenith raster
  x_rst <- setValues(binary.image,xFromCell(binary.image,1:ncell(binary.image)))
  y_rst <- setValues(binary.image,yFromCell(binary.image,1:ncell(binary.image)))
  
  #here we go
  zen_rst <- sqrt((x_rst-x_c)^2+(y_rst-y_c)^2)*diag_angle
  
  #plot(zen_rst)
  
  print(Lai_calc(binary.image,zen_rst, 13))
}





magick_thrshold()











################################ testing area

outname

##Auxiliar functions
magick_compress <- function(path_in,path_out,gblur,quality){
  
  out_cmd = paste("magick",
                  path_in,
                  "-strip -interlace Plane -gaussian-blur ",gblur,"-quality",quality,
                  path_out,
                  sep=" ")
  return(out_cmd)
}

magick_metadata <- function(path_in){#,path_out,filename){
  
  #out_file = paste(path_out,filename,'.txt',sep="")
  out_cmd = paste('magick identify -verbose',
                  path_in,
                  #'>',
                  #out_file,
                  sep=" ")
  
  return(out_cmd)
}

magick_thrshold <- function(path_in,path_out,name_img,algo='Otsu',keepBlue=F,runmagick=T){
  
  #first part of the algorithm creates a blue only version of the image
  #then this band is used for the thresholding
  out_path_blue= paste(path_out,name_img,"_B.jpg",sep="")
  out_path_thre= paste(path_out,name_img,"_Th.jpg",sep="")
  
  mgk_blue = paste('magick convert',
                   path_in,
                   '-channel RG -fx 0',
                   out_path_blue,sep = " ")
  print(mgk_blue)
  mgk_algo = paste('magick convert',
                   out_path_blue,
                   '-auto-threshold',algo,
                   out_path_thre,sep = " ")
  
  if (runmagick==F){
    print(mgk_blue)
    print(mgk_algo)
  } else {
    
    system(mgk_blue)
    system(mgk_algo)
    
    if (keepBlue == F){
      file.remove(out_path_blue)
    }
  }
  
}

magick_thrshold('ola','ole','192')

sink(paste(outmeta,outname,'.txt',sep=""))
sink()
outname

system(magick_metadata(outpath,outmeta,outname))


a <- system(magick_metadata(outpath,outmeta,outname), intern = TRUE)

a

b <- system(magick_metadata(outpath), intern = TRUE)
b


head(sel.df)
wget()



unique(sel.df$siteID)

unique(dhp.df$siteID)
head(dhp.df)
