# -*- coding: utf-8 -*-
"""
Created on Wed Aug 11 12:47:03 2021

@author: Nuno Cesar de Sa
"""
#general purpose libraries
import numpy as np
import math

#to load and save images
from PIL import Image
import rawpy

#image processing stuff
from skimage import exposure
from skimage.filters import threshold_otsu, threshold_isodata #, try_all_threshold 
#from skimage import img_as_float
#from skimage.io import imread,imsave



class DHP:
    
    def __init__(self,in_path,out_path=None):
        
        self.in_path = in_path
        #self.in_img = rawpy.imread(in_path).postprocess()[:,:,2]
    
    def __str__(self):
        return "Path to file is: " + self.in_path
    
    def __repr__(self):
        return self.in_path
    
    #interacting 
    def Load_NEF(self,band=2,outval=False):
        
        self.rst_raw_band = rawpy.imread(self.in_path).postprocess()[:,:,band]
        
        #return a numpy raster if needed - notice it creates a global variable that used by other functions
        if outval == True:
            return (self.rst_raw_band)
        

    def ImageCorrection(self,k=.5,mth="gamma",outval=False):
        
        if mth == "gamma":
            self.rst_cor_band = exposure.adjust_gamma(self.rst_raw_band, k)
        elif mth == "log":
            self.rst_cor_band = exposure.adjust_log(self.rst_raw_band, k)
        else:
            raise ValueError(mth + " algorithm not implemented for image correction!")
        
        if outval == True:
            return(self.rst_cor_band)
    
    def ImageThreshold(self,mth="ISODATA"):
        
        if mth == "ISODATA":
            self.thres = threshold_isodata(self.rst_cor_band)
        elif mth == "OTSU":
            self.thres = threshold_otsu(self.rst_cor_band)
        else:
            raise ValueError(mth + " algorithm not implemented for thresholding!")
        
        return(self.thres)
    
    def BinaryImg(self,outval=False):
        
        self.rst_BinImg = (self.rst_cor_band > self.thres)
        
        if outval == True:
            return self.rst_BinImg
    
    
    #generates the zenith image
    def GenAngles(self,outval=False):
        
        img_in = self.rst_BinImg
        
        #get corner coordinates
        y_t, x_r = img_in.shape
        
        #x_r=img_in.shape[1]
        #y_t=img_in.shape[0]
        
        #get center coordinates
        x_c = x_r/2
        y_c = y_t/2
        
        #get diagonal value
        #diag = math.sqrt()
        diag = 180/math.sqrt(((x_r)**2)+((y_t)**2))
        
        #creates an index value
        y_np,x_np = np.indices(img_in.shape)
        
        #change in each axis
        dx = (x_np-x_c)
        dy = (y_np-y_c)
        
        dx2 = np.multiply(dx,dx)
        dy2 = np.multiply(dy,dy)
        
        #zenith
        zen_out = diag*np.sqrt(dx2+dy2)
        
        #azimuth
        azi_out = np.arctan2(dy,dx)*180/math.pi + 180 # to force an intervall betwen 0 and 360
        
      
        #creates global variable
        self.rst_Angles = zen_out,azi_out
        
        if outval == True:
            return(self.rst_Angles)
        
    def GenGrid(self,zen_min=0,zen_max=60,zen_w=10,azi_w=10,direction="up",outval=False):
        
        zen_in = self.rst_Angles[0]
        azi_in = self.rst_Angles[1]
        
    
        #generating lists
        dzen = zen_max - zen_min
        list_zen = range(0,round(dzen/zen_w))
        list_azi = range(0,round(360/azi_w))
        
        k = 1
        for i in list_zen:
            min_zen = zen_min + i*zen_w
            max_zen = zen_min + (i+1)*zen_w
            
            #print("Min z:" +  str(min_zen) + " Max z:" + str(max_zen))
            
            for j in list_azi:
                min_azi = j*azi_w
                max_azi = (j+1)*azi_w
                
                #print("Min a:" +  str(min_azi) + " Max a:" + str(max_azi))
                
                out_zen = (zen_in >= min_zen) * (zen_in < max_zen)
                out_azi = (azi_in >= min_azi) * (azi_in < max_azi)
                
                if k == 1:
                    rst_Grid = out_zen*out_azi*k
                    k=k+1
                else:
                    tmpval = out_zen*out_azi*k
                    rst_Grid = tmpval+rst_Grid
                    k = k+1
                    
        if direction == "down":
            azi_msk = (azi_in > 315) +  (azi_in < 225)
            rst_Grid = rst_Grid*azi_msk
    
        
        self.rst_CellID=rst_Grid
    
        if outval == True:
            return(self.rst_CellID)
        
    def GapFrac(self,verbose=False):
        
        #using the objects created, it calculates the number of each pixel per cell
        bin_img = self.rst_BinImg
        grid_img = self.rst_CellID
        
    
    
        #selecting unique values
        unique_vals = np.unique(grid_img)
        
        total = 0 
        for i in unique_vals[1:]:
            #print(i)
            
            #create the mask for the cell
            cell_msk = (grid_img==i)
            
            #gets the 1 in the background and the canopy
            bck_msk = np.sum(cell_msk*(bin_img==1))
            can_msk = np.sum(cell_msk*(bin_img==0))
            
            #print the output data
            if verbose == True:
                print("ID: " + str(i) + " Background: " + str(bck_msk) + " Canopy:" + str(can_msk) + " Sum: " + str(bck_msk + can_msk) )
            
            
            total = total +  bck_msk + can_msk
            # im = Image.fromarray(cell_msk)
            # im.save("D:/NEON/DHP_Processing/python_temp/"+"Cell_"+str(i).zfill(3)+".tif")
            # im = Image.fromarray(bck_msk)
            # im.save("D:/NEON/DHP_Processing/python_temp/"+"Back_"+str(i).zfill(3)+".tif")
            # im = Image.fromarray(can_msk)
            # im.save("D:/NEON/DHP_Processing/python_temp/"+"Cano_"+str(i).zfill(3)+".tif")
            
        print(total)


class NEON_DataManager:
    
    def __init__(self,path_link,out_fld=None,out_name=None):
        
        self.path_link = path_link
        self.out_fld   = out_fld
        self.out_name  = out_name
        
    def __str__(self):
        
        print("Download path: " +  self.path_link)
        
        return "Output path:   " +  self.out_fld + self.out_name
    
    def start_download(self,mth="urllib"):
        
        in_path = self.path_link
        out_path = self.out_fld + self.out_name
        
        if mth == "urllib":
            
            urllib.request.urlretrieve(in_path, out_path)
        
        else:
            raise ValueError(mth + " not implemented for downloading")
   
        


##Testing area
#my_img = DHP("D:/NEON/DHP_Processing/tmp/DHP.2016.01.BART047.E2.OVERSTORY.NEF")


def tester(path2file):
    
    outobj = DHP(path2file)
    outobj.Load_NEF()
    outobj.ImageCorrection()
    outobj.ImageThreshold()
    outobj.BinaryImg()
    
    outobj.GenAngles()
    
    outobj.GenGrid(zen_min=57.5-5,zen_max=57.5+5)
    outobj.GapFrac(verbose=True)

#tester("D:/NEON/DHP_Processing/tmp/DHP.2016.01.BART047.E2.OVERSTORY.NEF")



### open NEON CSV

import pandas as pd

#my_data = pd.read_csv("D:/NEON/Data_Neon/stackByTable_DHP_20210323/NEON10017/stackedFiles/dhp_perimagefile.csv",sep=",",decimal=".")


import urllib.request

#urllib.request.urlretrieve("https://s3.data.neonscience.org/neon-dhp-images/D01/2016/BART01/BART_047/understory/D01_2091.NEF", "D:/NEON/DHP_Processing/teste.NEF")


bb = NEON_DataManager("https://s3.data.neonscience.org/neon-dhp-images/D01/2016/BART01/BART_047/understory/D01_2091.NEF",
                      "D:/NEON/DHP_Processing/","D01_2091.NEF")
print(bb)
