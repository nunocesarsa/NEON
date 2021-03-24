
##### These functions were adapted from the publicly available github repository by Hans ter Steege (2018)

## link to script: https://github.com/naturalis/Hemiphot/blob/master/Hemiphot.R

##########          How to cite the use of Hemiphot         ##########
#If you use Hemiphot.R for your research or work please cite as:
#Hans ter Steege (2018) Hemiphot.R: Free R scripts to analyse hemispherical 
#photographs for canopy openness, leaf area index and photosynthetic 
#active radiation under forest canopies.  
#Unpublished report. Naturalis Biodiversity Center, Leiden, The Netherlands
#https://github.com/Hans-ter-Steege/Hemiphot
#######END          How to cite the use of Hemiphot         ##########





#FUNCTIONS
PlotHemiImage = function(image = "", draw.circle = T){
  
  plot(image)
  if (draw.circle == T) {
    
    DrawCircle(cx=ncol(image)/2,cy=nrow(image)/2,radius=nrow(image)/2)
  }
  
}

DrawCircle = function(cx = 100, cy = 100, radius = 50){
  x = 0:radius
  y = sin(acos(x/radius)) * radius
  points(cx + x, cy + y, col = "red", cex = 0.1)
  points(cx + x, cy - y, col = "red", cex = 0.1)
  points(cx - x, cy + y, col = "red", cex = 0.1)
  points(cx - x, cy - y, col = "red", cex = 0.1)
  y = x
  x = cos(asin(x/radius)) * radius
  points(cx + x, cy + y, col = "red", cex = 0.1)
  points(cx + x, cy - y, col = "red", cex = 0.1)
  points(cx - x, cy + y, col = "red", cex = 0.1)
  points(cx - x, cy - y, col = "red", cex = 0.1)
  text(cx+radius-25, cy, "W", col = "red")
  text(cx-radius+25, cy, "E", col = "red")
  text(cx, cy+radius-25, "N", col = "red")
  text(cx, cy-radius+25, "S", col = "red")
}

#ratio sky and vegetation
ratio_sky <- function(x){
  
  #notice that if the data is a circular fisheye image then this will not work - you have to remove the black region first
  #ring_calc can be used for that purpose
  sky = x>0
  veg = x<1
  #outval = cellStats(sky,sum)/(cellStats(veg,sum)
  outval = cellStats(sky,sum)/(cellStats(veg,sum)+cellStats(sky,sum))
  
  return(outval)
}

#this function extracts a ring given an image that represent the distance in zenith from the center
ring_calc <- function(r, min, max) {
  rr <- r[]
  rr[rr <= min | rr >= max] <- NA
  r[] <- rr
  r
}



gap_frac <- function(tgt.rst,zen.rst,min,max){
  
  ring = ring_calc(zen.rst,min,max)*0+1
  outval = ratio_sky(ring*tgt.rst)
  return(outval)
}


#LAI 
#Instrument for Indirect Measurement of Canopy Architecture
#and https://github.com/naturalis/Hemiphot/blob/master/Hemiphot.R
Lai_calc <- function(x,zen_rst,width){
  
  wi = c(0.034, 0.104, 0.160, 0.218, 0.494)
  angle = c(7, 23, 38, 53, 68)  
  
  outval = 0
  for (i in 1:length(angle)){
    min_a = angle[i]-width
    max_a = angle[i]+width
    
    #in my case, i do not need to divide by 13 to get the final value because my gap fraciton is calculated and not loaded
    #and the sum is made within the loop
    outval = outval + (-log(gap_frac(x,zen_rst,min_a,max_a))*wi[i]*cos(angle[i]*pi/180))
    
  }
  
  return(2*outval)
}

