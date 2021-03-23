#Installing development version
library(devtools)
#install_github('NEONScience/NEON-geolocation/geoNEON', dependencies=TRUE)  #2021/03/19
library(geoNEON)

#setting up pats
path2fld = 'D:/NEON/Data_Neon/stackByTable_DHP_20210323'
path2outfld = 'D:/NEON/Data_Neon/getLocTOS_DHP_20210323'

data.files = data.frame('dpID'=c(10017),'TableID'= c('dhp_perimagefile'))

#hbp_perbout not working for some wacky reason
#ph_perindividual also fails
for (i in 1:nrow(data.files)){
  
  #i=2
  #generating path to file
  #dpID = paste('getLocTOS_NEON',data.files$dpID[i],sep="")
  dpID = paste('NEON',data.files$dpID[i],sep="")
  tbID = paste(data.files$TableID[i],'.csv',sep="")
  
  i_filepath = paste(path2fld,dpID,'stackedFiles',tbID,sep="/")
  
  #generating path to output
  o_filepath = paste(path2outfld,paste('getLocTOS',dpID,tbID,sep='_'),sep='/')
  
  #loading csv
  print(paste('Processing:',i,'of',nrow(data.files),'-',dpID,'-',tbID))
  
  #loading and applying function
  i_df = read.csv(i_filepath)
  #i_df = i_df[i_df$siteID=='BART',] #uncomment for a sample example
  o_df = geoNEON::getLocTOS(data=i_df,dataProd=data.files$TableID[i],
                            token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnL2FwaS92MC8iLCJzdWIiOiJudW5vLmNlc2FyLnNhQGdtYWlsLmNvbSIsInNjb3BlIjoicmF0ZTpwdWJsaWMiLCJpc3MiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnLyIsImV4cCI6MTc3Mzg4Mzg3MSwiaWF0IjoxNjE2MjAzODcxLCJlbWFpbCI6Im51bm8uY2VzYXIuc2FAZ21haWwuY29tIn0.MsU9SbNGA1sH7aj29fdJuCZv73C5HD7b_OLQYozryaIDaS62xwcYHxuHHlryvie89kVP4QrBH6oMn5V3eVkyBw')
  
  #saving to disk
  write.csv(o_df,o_filepath,row.names = F)
  print(paste('Output saved to:',o_filepath))
  #print(data.files$TableID[i])
  
}


#creating csv2
my.df = read.csv('D:/NEON/Data_Neon/getLocTOS_DHP_20210323/getLocTOS_NEON10017_dhp_perimagefile.csv')
write.csv2(my.df,'D:/NEON/Data_Neon/getLocTOS_DHP_20210323/getLocTOS_NEON10017_dhp_perimagefile_csv2.csv',row.names = F)
