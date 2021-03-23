library(neonUtilities)
gc()

#Installing development version
library(devtools)
#install_github('NEONScience/NEON-geolocation/geoNEON', dependencies=TRUE)  #2021/03/19
library(geoNEON)

#Ran on 2021/03/23
setwd("D:/NEON/Data_Neon/")

#Real run
path2fld = 'D:/NEON/Data_Neon/stackByTable_DHP_20210323'
path2outfld = 'D:/NEON/Data_Neon/geoNEON_DHP_202103023'


data.files = data.frame('dpID'=c(10017,10017),'TableID'= c('dhp_perplot','dhp_perimagefile'))


for (i in 2:nrow(data.files)){
  
  #generating path to file
  dpID = paste('NEON',data.files$dpID[i],sep="")
  tbID = paste(data.files$TableID[i],'.csv',sep="")
  tbID2 = paste(data.files$TableID[i],'_csv2.csv',sep="")
  i_filepath = paste(path2fld,dpID,'stackedFiles',tbID,sep="/")
  
  #generating path to output
  o_filepath = paste(path2outfld,paste(dpID,tbID,sep='_'),sep='/')
  o_filepath2 = paste(path2outfld,paste(dpID,tbID2,sep='_'),sep='/')
  
  #loading csv
  print(paste('Processing:',i,'of',nrow(data.files),'-',dpID,'-',tbID))
  
  #loading and applying function
  i_df = read.csv(i_filepath)
  o_df = geoNEON::getLocByName(i_df,'namedLocation',
                               token='eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnL2FwaS92MC8iLCJzdWIiOiJudW5vLmNlc2FyLnNhQGdtYWlsLmNvbSIsInNjb3BlIjoicmF0ZTpwdWJsaWMiLCJpc3MiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnLyIsImV4cCI6MTc3Mzc4ODY1OSwiaWF0IjoxNjE2MTA4NjU5LCJlbWFpbCI6Im51bm8uY2VzYXIuc2FAZ21haWwuY29tIn0.qnbWk3ORey0uecnIvPVaxys0wdik0CMsUGeCabrJck2XUdLGxD-R7NSW4hON1GH6_qPj3MJnKS6EiKN4-NSTnw')
  
  #saving to disk
  write.csv(o_df,o_filepath,row.names = F)
  write.csv2(o_df,o_filepath2,row.names = F)
  print(paste('Output saved to:',o_filepath))
  
  
}