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