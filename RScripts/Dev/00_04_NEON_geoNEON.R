
### this script just generates the "broader" positions. Other command has to be used to generate more precise geolocations (which i will do later)
gc()


#Installing development version
library(devtools)
#install_github('NEONScience/NEON-geolocation/geoNEON', dependencies=TRUE)  #2021/03/19
library(geoNEON)

#Possible, depending on R version it seems
#install.packages('geoNEON')

#For more info:
#https://github.com/NEONScience/NEON-geolocation
#https://github.com/NEONScience/NEON-geolocation/tree/master/geoNEON

#test run
#hbp_massdata = read.csv('D:/NEON/Data_Neon/stackByTable_20210318/NEON10023/stackedFiles/hbp_massdata.csv')
#hbp_perbout  = read.csv('D:/NEON/Data_Neon/stackByTable_20210318/NEON10023/stackedFiles/hbp_perbout.csv')
#head(hbp_massdata)
#head(hbp_perbout)
#hbp_massdata.sel = hbp_massdata[1:2000,]
#hbp_massdata.sel.spatial = geoNEON::getLocByName(hbp_massdata.sel,'namedLocation')
#write.csv2(hbp_massdata.sel.spatial,'C:/Users/nunoc/OneDrive/Desktop/testfolderdump/hpd_massdata_sample.csv')

#Real run
path2fld = 'D:/NEON/Data_Neon/stackByTable_20210318'
path2outfld = 'D:/NEON/Data_Neon/geoNEON_202103018'


data.files = data.frame('dpID'=c(10023,10023,
                                 10026,10026,10026,10026,10026,10026,10026,
                                 10033,10033,10033,10033,10033,10033,
                                 10045,10045,
                                 10055,10055,10055,
                                 10058,10058,
                                 10098,10098,10098,10098
                                 ),
                        'TableID'= c('hbp_massdata','hbp_perbout',
                                     'cfc_carbonNitrogen','cfc_chemistrySubsampling','cfc_chlorophyll','cfc_elements','cfc_fieldData','cfc_lignin','cfc_LMA',
                                     'ltr_chemistrySubsampling','ltr_fielddata','ltr_litterCarbonNitrogen','ltr_litterLignin','ltr_massdata','ltr_pertrap',
                                     'nst_perindividual','vst_perplotperyear',
                                     'phe_perindividual','phe_perindividualperyear','phe_statusintensity',
                                     'div_1m2Data','div_10m2Data100m2Data',
                                     'vst_apparentindividual','vst_mappingandtagging','vst_perplotperyear','vst_shrubgroup'))



for (i in 1:nrow(data.files)){
  
  #generating path to file
  dpID = paste('NEON',data.files$dpID[i],sep="")
  tbID = paste(data.files$TableID[i],'.csv',sep="")
  i_filepath = paste(path2fld,dpID,'stackedFiles',tbID,sep="/")
  
  #generating path to output
  o_filepath = paste(path2outfld,paste(dpID,tbID,sep='_'),sep='/')
  
  #loading csv
  print(paste('Processing:',i,'of',nrow(data.files),'-',dpID,'-',tbID))
  
  #loading and applying function
  i_df = read.csv(i_filepath)
  o_df = geoNEON::getLocByName(i_df,'namedLocation',
                               token='eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnL2FwaS92MC8iLCJzdWIiOiJudW5vLmNlc2FyLnNhQGdtYWlsLmNvbSIsInNjb3BlIjoicmF0ZTpwdWJsaWMiLCJpc3MiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnLyIsImV4cCI6MTc3Mzc4ODY1OSwiaWF0IjoxNjE2MTA4NjU5LCJlbWFpbCI6Im51bm8uY2VzYXIuc2FAZ21haWwuY29tIn0.qnbWk3ORey0uecnIvPVaxys0wdik0CMsUGeCabrJck2XUdLGxD-R7NSW4hON1GH6_qPj3MJnKS6EiKN4-NSTnw')
  
  #saving to disk
  write.csv(o_df,o_filepath,row.names = F)
  print(paste('Output saved to:',o_filepath))
  
  
}

