library(neonUtilities)
gc()

#Ran on 2021/03/23
setwd("D:/NEON/Data_Neon/")

#Loading folders
path2dirs=list.dirs('./ZipsByProduct_DHP_20210323',recursive = F)

path2dirs

#Looping -  WARNING - THE STACKBYTABLE FUNCTION DELETES THE ZIP FILES
for (i in 1:length(path2dirs)){
  print(paste(i,'of',length(path2dirs)))  
  
  outpath = paste('./stackByTable_DHP_20210323/NEON',
                  substr(path2dirs[i],
                         nchar(path2dirs[i])-4,
                         nchar(path2dirs[i])),
                  sep = "")
  
  stackByTable(filepath=path2dirs[i],
               savepath = outpath,
               nCores = 10)
  
  print(paste('Saved to:',outpath))
}