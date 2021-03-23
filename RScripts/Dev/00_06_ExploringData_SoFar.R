

#libraries
library(lubridate)
library(ggplot2)
library(dplyr)

#paths to folders
path2files = list.files("D:/NEON/Data_Neon/geoNEON_202103018",pattern = '.csv',full.names = T)
filenames = list.files("D:/NEON/Data_Neon/geoNEON_202103018",pattern = '.csv',full.names = F)
outpath = 'D:/NEON/Data_Neon/geoNEON_202103018_ExploratoryPlots/'

for (i in 1:length(path2files)){
  
  print(paste("Processing:",path2files[i]))
  
  tmp.df <- read.csv(path2files[i])
  
  tmp.colnames = names(tmp.df)
  
  if (is.element('collectDate',tmp.colnames)==T){
    #tmp.df <- tmp.df[,c('siteID','collectDate')]
    print('collectDate')
    tmp.df <- tmp.df[,c('siteID','collectDate')]
    
    #aggreagtes date into counts
    count_df = tmp.df %>% count(siteID,collectDate)
    #creates a date field
    count_df$corrDate <- as.Date(substr(count_df$collectDate,1,10))
    
    #adds a column with the year marker
    count_df$Year <- strftime(count_df$corrDate, "%Y")
    
    
    outfilename = paste(outpath,filenames[i],'.png',sep='')
    png(filename =  outfilename,
        width=1024,height = 1024)
    print(ggplot(count_df,aes(corrDate,n,color=siteID))+
            geom_point()+
            ggtitle(filenames[i])+
            facet_grid(Year~.))
    dev.off()
    
    
    
  } else if(is.element('date',tmp.colnames)==T){
    print('date')
    
    #selecting meaningful tables
    tmp.df <- tmp.df[,c('siteID','date')]
    
    #aggregates date into counts
    count_df = tmp.df %>% count(siteID,date)
    count_df$corrDate <- as.Date(count_df$date)
    
    #adds a column with the year marker
    count_df$Year <- strftime(count_df$corrDate, "%Y")
    
    #plotting
    outfilename = paste(outpath,filenames[i],'.png',sep='')
    png(filename =  outfilename,
        width=1024,height = 1024)
    print(ggplot(count_df,aes(corrDate,n,color=siteID))+
            geom_point()+
            ggtitle(filenames[i])+
            facet_grid(Year~.))
    dev.off()
    
    
    
  
  } else if(is.element('endDate',tmp.colnames)==T){
    print('endDate')
    
    #selecting meaningful tables    
    tmp.df <- tmp.df[,c('siteID','endDate')]
    
    
    #aggregates date into counts
    count_df = tmp.df %>% count(siteID,endDate)
    count_df$corrDate <- as.Date(count_df$endDate) 
    
    #adds a column with the year marker
    count_df$Year <- strftime(count_df$corrDate, "%Y")
    
    #plotting
    filenames[i]
    outfilename = paste(outpath,filenames[i],'.png',sep='')
    png(filename =  outfilename,
        width=1024,height = 1024)
    print(ggplot(count_df,aes(corrDate,n,color=siteID))+
            geom_point()+
            ggtitle(filenames[i])+
            facet_wrap(Year~.))
    dev.off()

    
  } else {
    print('!!!!no date field found!!!!')
  }
  
  #
}


tmp.df$Year <- strftime(tmp.df$date, "%Y")

head(tmp.df)



dev.off()
str(tmp.df)

v <- c('a','b','c','e')
is.element('w',v)

my.df <- read.csv("D:/NEON/Data_Neon/geoNEON_202103018/NEON10023_hbp_massdata.csv")


head(my.df)

str(my.df)

names(my.df)
head(my.df)
my.df <- my.df[,c('siteID','collectDate','dryMass')]

head(my.df)


library(dplyr)

count_df = my.df %>% count(siteID,collectDate)

head(count_df)

count_df$corrDate <- as.Date(substr(count_df$collectDate,1,10))

head(count_df)

library(ggplot2)

ggplot(count_df,aes(corrDate,n,color=siteID))+geom_point()
