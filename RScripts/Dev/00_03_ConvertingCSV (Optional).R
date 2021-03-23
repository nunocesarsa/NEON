
#in case the computer needs another csv format to open the data directly in excel

#path2stackfiles
path2stacktables = 'D:/NEON/Data_Neon/stackByTable_20210318'

list.dirs(path2stacktables,recursive = F)

for (product_i in list.dirs(path2stacktables,recursive = F)){
  
  print(paste("Processing:",product_i))
  
  #move to directory
  setwd(product_i)
  newdirname = "stackedFiles_csv2"
  dir.create(newdirname) #ignore warnings in case folder exists for some reason
  
  #pointer str
  origin_fld = paste(product_i,'stackedFiles',sep="/")
  target_fld = paste(product_i,newdirname,sep="/")

  #print(list.files(origin_fld,pattern = ".csv"))
  for (table_i in list.files(origin_fld,pattern = ".csv")){
    
    in_path = paste(origin_fld,table_i,sep="/")
    outpath = paste(target_fld,table_i,sep="/")
    
    in.df = read.csv(in_path)
    
    write.csv2(in.df,outpath,row.names = F)
    #print(outpath)
  }
}
