#library(stringr)

#This script simply iterates on the master folder and indexes all data into a single table that can be 
#queried to extract specific paths to data folder

#path to save folder
path2outfld = "D:/NEON/Data_Preprocessed/IndexTables/"

#path to unzipped folders
path2fld = 'D:/NEON/Data_Unzipped_Raw/'

#iterating on folders
k = 1
for (i in list.dirs(path2fld,full.names = F,recursive = F)){
  
  #print(i)
  full.path = paste(path2fld,i,sep="")
  
  for (j in list.dirs(full.path,full.names = F,recursive = F)){
    #print(j)

    #dismounting the string
    tmp_str=unlist(strsplit(j,'[.]'))
    
    #on the first path create a dataframe
    if (k == 1){
      out.df = data.frame('ID'=k,
                          'SampleType'=i,
                          'ORIGIN'=tmp_str[1],
                          'DOM'=tmp_str[2],
                          'SITE'=tmp_str[3],
                          'DPL'=tmp_str[4],
                          'PRNUM'=tmp_str[5],
                          'REV'=tmp_str[6],
                          'DateRedux'=tmp_str[7], # from here (including) the naming of the files is aparently different
                          'DType'= tmp_str[8],
                          'DateProc'= tmp_str[9],
                          'ReleaseType'=tmp_str[10],
                          #'Remaining'=paste(tmp_str[11:length(tmp_str)],collapse = "."),
                          'Fullpath'=paste(i,j,sep="/"))
    } else {
      tmp.df <- data.frame('ID'=k,
                           'SampleType'=i,
                           'ORIGIN'=tmp_str[1],
                           'DOM'=tmp_str[2],
                           'SITE'=tmp_str[3],
                           'DPL'=tmp_str[4],
                           'PRNUM'=tmp_str[5],
                           'REV'=tmp_str[6],
                           'DateRedux'=tmp_str[7], # from here (including) the naming of the files is aparently different
                           'DType'= tmp_str[8],
                           'DateProc'= tmp_str[9],
                           'ReleaseType'=tmp_str[10],
                           #'Remaining'=paste(tmp_str[11:length(tmp_str)],collapse = "."),
                           'Fullpath'=paste(i,j,sep="/"))
      
      out.df= rbind(out.df,tmp.df)
      
      
    }
    k=k+1
    
  }
}

write.csv(out.df,paste(path2outfld,"NEON_Tables_Index_csv.csv",sep=""),row.names = F)
write.csv2(out.df,paste(path2outfld,"NEON_Tables_Index_csv2.csv",sep=""),row.names = F)

