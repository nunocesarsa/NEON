
#Folders
fld_rawdata = "D:/NEON/Data_Unzipped_Raw/" #folder where the rawdata is stored
fld_TempTables = "D:/NEON/Data_Preprocessed/TempTables/" #Temporary folder for dumping temporary tables
fld_MastTables = "D:/NEON/Data_Preprocessed/MasterTables/" #Folder for dumping master table


#open index table
index_table = read.csv("D:/NEON/Data_Preprocessed/IndexTables/NEON_Tables_Index_csv.csv")

unique(index_table$SampleType)

#function to fetch data tables
fetch_table <- function(file_path=NA,str_pattern){
  
  file_list = list.files(file_path,full.names = T,pattern = paste('*',str_pattern,'*',sep=""))
  if (length(file_list)==1){
    df.out = read.csv(file_list)
    return(df.out)
    
  } else if (length(file_list)>1){
    warning("More than one file found!!!")
    return("More than one table found!!!")
    
  } else {
    warning(paste("No table found!", file_path))
    return("No table found!")
  }
  
  
}

#test section 
test_path = 'D:/NEON/Data_Unzipped_Raw/NEON_clip-herb/NEON.D01.BART.DP1.10023.001.2014-07.basic.20210123T023002Z.RELEASE-2021'
fetch_table(file_path = test_path,'massdata') # should work
fetch_table(file_path = test_path,'10023') # should find more than one
fetch_table(file_path = test_path,'massdadfa') # should fail to find a file



#Preselection of the pipeline
#index_table=index_table[index_table$SampleType=="NEON_clip-herb",]
#index_table=index_table[index_table$SampleType=="NEON_litterfall",]

#this group has a lot of data which makes writing the dataframe to disk very slow 
#the alternative is then not to write it until the end
#also an extra script has to be run for the peryear version
#index_table=index_table[index_table$SampleType=="NEON_obs-phenology-plant",] 

#this also gets very slow if its writing on the disk the whole time.
#PS: it is als possible that some data is missing on this loop if we follow the indications on the manual
index_table=index_table[index_table$SampleType=="NEON_presence-cover-plant",] 

#this loop iterates and creates a master table per measurement that can be used for further queries later

#on the first iteration it creates a table (only works with the preselection of the pipeline above)
#once that is created, it appends each table type into a big master table of each type. The if clauses are needed to address when tables are missing.

for (i in 1:nrow(index_table)){

  temp_type = index_table$SampleType[i]
  temp_path = paste(fld_rawdata,index_table$Fullpath[i],sep="")
  
  print(paste(i,'of',nrow(index_table)))
  
  
  if (i==1){
    
    if (temp_type=="NEON_clip-herb"){
      
      df.master.massdata = fetch_table(temp_path,'massdata')
      df.master.perbout = fetch_table(temp_path,'perbout')
      #print(nrow(df.master.massdata))
      
      df.master.NEON_clip_herb.summary = data.frame('i'=i,"Variable"='massdata',"nrows"=nrow(df.master.massdata),"Path"=temp_path)
      df.master.NEON_clip_herb.summary = rbind(df.master.NEON_clip_herb.summary,
                                               data.frame('i'=i,"Variable"='perbout',"nrows"=nrow(df.master.perbout),"Path"=temp_path))
    } else if (temp_type=="NEON_litterfall"){
      
      df.master.litter.massdata = fetch_table(temp_path,'massdata')
      df.master.litter.pertrap  = fetch_table(temp_path,'pertrap')
      #print(nrow(df.master.massdata))
      
      df.master.NEON_litterfall.summary = data.frame('i'=i,"Variable"='massdata',"nrows"=nrow(df.master.litter.massdata),"Path"=temp_path)
      df.master.NEON_litterfall.summary = rbind(df.master.NEON_litterfall.summary,
                                               data.frame('i'=i,"Variable"='pertrap',"nrows"=nrow(df.master.litter.pertrap),"Path"=temp_path))
      
    } else if (temp_type=="NEON_obs-phenology-plant"){
      
      df.master.pheno.indiv = fetch_table(temp_path,'phe_perindividual.basic')
      df.master.pheno.statu = fetch_table(temp_path,'phe_statusintensity')
      #print(nrow(df.master.massdata))
      
      df.master.NEON_phenology.summary = data.frame('i'=i,"Variable"='perindividual',"nrows"=nrow(df.master.pheno.indiv),"Path"=temp_path)
      df.master.NEON_phenology.summary = rbind(df.master.NEON_phenology.summary,
                                                data.frame('i'=i,"Variable"='statusintensity',"nrows"=nrow(df.master.pheno.statu),"Path"=temp_path))
      
    } else if (temp_type=="NEON_presence-cover-plant"){
      
      df.master.prese.01m2 = fetch_table(temp_path,'.div_1m2Data.')
      df.master.prese.10m2 = fetch_table(temp_path,'.div_10m2Data100m2')
      #print(nrow(df.master.massdata))
      
      df.master.NEON_presence.summary = data.frame('i'=i,"Variable"='01m2',"nrows"=nrow(df.master.prese.01m2),"Path"=temp_path)
      df.master.NEON_presence.summary = rbind(df.master.NEON_presence.summary,
                                               data.frame('i'=i,"Variable"='10m2',"nrows"=nrow(df.master.prese.10m2),"Path"=temp_path))
      
    }
    
  
    
    
  } else {
    
    if (temp_type=="NEON_clip-herb"){
      
      df.temp.massdata = fetch_table(temp_path,'massdata')
      df.temp.perbout = fetch_table(temp_path,'perbout')
      #print(nrow(df.temp.massdata))
      
      if (is.data.frame(df.temp.massdata)==T){
        df.master.massdata = rbind(df.master.massdata,df.temp.massdata)
        df.master.NEON_clip_herb.summary = rbind(df.master.NEON_clip_herb.summary,
                                                 data.frame('i'=i,"Variable"='massdata',"nrows"=nrow(df.temp.massdata),"Path"=temp_path))
        
        write.csv(df.master.massdata,paste(fld_MastTables,'MASTER-',temp_type,'_massdata_csv.csv',sep=""),row.names = F)
        write.csv(df.master.NEON_clip_herb.summary,paste(fld_MastTables,'MASTER-',temp_type,'_summary_csv.csv',sep=""),row.names = F)
      } 
      
      if (is.data.frame(df.temp.perbout)==T){
        df.master.perbout  = rbind(df.master.perbout,df.temp.perbout)
        df.master.NEON_clip_herb.summary = rbind(df.master.NEON_clip_herb.summary,
                                                 data.frame('i'=i,"Variable"='perbout',"nrows"=nrow(df.temp.perbout),"Path"=temp_path))
        
        write.csv(df.master.perbout ,paste(fld_MastTables,'MASTER-',temp_type,'_perbout_csv.csv',sep=""),row.names = F)
        write.csv(df.master.NEON_clip_herb.summary,paste(fld_MastTables,'MASTER-',temp_type,'_summary_csv.csv',sep=""),row.names = F)
      }       
    
    } else if(temp_type=="NEON_litterfall"){
      
      df.temp.litter.massdata = fetch_table(temp_path,'massdata')
      df.temp.litter.pertrap = fetch_table(temp_path,'pertrap')
      #print(nrow(df.temp.litter.massdata))
      
      if (is.data.frame(df.temp.litter.massdata)==T){
        df.master.litter.massdata = rbind(df.master.litter.massdata,df.temp.litter.massdata)
        df.master.NEON_litterfall.summary = rbind(df.master.NEON_litterfall.summary,
                                                 data.frame('i'=i,"Variable"='massdata',"nrows"=nrow(df.temp.litter.massdata),"Path"=temp_path))
        
        #write.csv(df.master.litter.massdata,paste(fld_MastTables,'MASTER-',temp_type,'_massdata_csv.csv',sep=""),row.names = F)
        write.csv(df.master.NEON_litterfall.summary,paste(fld_MastTables,'MASTER-',temp_type,'_summary_csv.csv',sep=""),row.names = F)
      } 
      
      if (is.data.frame(df.temp.litter.pertrap)==T){
        df.master.litter.pertrap  = rbind(df.master.litter.pertrap,df.temp.litter.pertrap)
        df.master.NEON_litterfall.summary = rbind(df.master.NEON_litterfall.summary,
                                                 data.frame('i'=i,"Variable"='pertrap',"nrows"=nrow(df.temp.litter.pertrap),"Path"=temp_path))
        
        #write.csv(df.master.litter.pertrap ,paste(fld_MastTables,'MASTER-',temp_type,'_pertrap_csv.csv',sep=""),row.names = F)
        write.csv(df.master.NEON_litterfall.summary,paste(fld_MastTables,'MASTER-',temp_type,'_summary_csv.csv',sep=""),row.names = F)
      }  
      
    } else if(temp_type=="NEON_obs-phenology-plant"){
      
      df.temp.pheno.indiv = fetch_table(temp_path,'phe_perindividual.basic')
      df.temp.pheno.statu = fetch_table(temp_path,'phe_statusintensity')
      #print(nrow(df.temp.pheno.indiv))
      
      if (is.data.frame(df.temp.pheno.indiv)==T){
        df.master.pheno.indiv = rbind(df.master.pheno.indiv,df.temp.pheno.indiv)
        df.master.NEON_phenology.summary = rbind(df.master.NEON_phenology.summary,
                                                 data.frame('i'=i,"Variable"='phe_perindividual',"nrows"=nrow(df.temp.pheno.indiv),"Path"=temp_path))
        
        #write.csv(df.master.pheno.indiv,paste(fld_MastTables,'MASTER-',temp_type,'_phe_perindividual_csv.csv',sep=""),row.names = F)
        write.csv(df.master.NEON_phenology.summary,paste(fld_MastTables,'MASTER-',temp_type,'_summary_csv.csv',sep=""),row.names = F)
      } 
      
      if (is.data.frame(df.temp.pheno.statu)==T){
        df.master.pheno.statu  = rbind(df.master.pheno.statu,df.temp.pheno.statu)
        df.master.NEON_phenology.summary = rbind(df.master.NEON_phenology.summary,
                                                 data.frame('i'=i,"Variable"='phe_statusintensity',"nrows"=nrow(df.temp.pheno.statu),"Path"=temp_path))
        
        #write.csv(df.master.pheno.statu ,paste(fld_MastTables,'MASTER-',temp_type,'_phe_statusintensity_csv.csv',sep=""),row.names = F)
        write.csv(df.master.NEON_phenology.summary,paste(fld_MastTables,'MASTER-',temp_type,'_summary_csv.csv',sep=""),row.names = F)
      }  
    
      
    } else if(temp_type=="NEON_presence-cover-plant"){
      
      df.temp.prese.01m2 = fetch_table(temp_path,'.div_1m2Data.')
      df.temp.prese.10m2 = fetch_table(temp_path,'.div_10m2Data100m2')
      #print(nrow(df.temp.pheno.indiv))
      
      if (is.data.frame(df.temp.prese.01m2)==T){
        df.master.prese.01m2 = rbind(df.master.prese.01m2,df.temp.prese.01m2)
        df.master.NEON_presence.summary = rbind(df.master.NEON_presence.summary,
                                                 data.frame('i'=i,"Variable"='01m2',"nrows"=nrow(df.temp.prese.01m2),"Path"=temp_path))
        
        #write.csv(df.master.prese.01m2,paste(fld_MastTables,'MASTER-',temp_type,'_div_1m2Data_csv.csv',sep=""),row.names = F)
        write.csv(df.master.NEON_presence.summary,paste(fld_MastTables,'MASTER-',temp_type,'_summary_csv.csv',sep=""),row.names = F)
      } 
      
      if (is.data.frame(df.temp.prese.10m2)==T){
        df.master.prese.10m2  = rbind(df.master.prese.10m2,df.temp.prese.10m2)
        df.master.NEON_presence.summary = rbind(df.master.NEON_presence.summary,
                                                 data.frame('i'=i,"Variable"='10m2',"nrows"=nrow(df.temp.prese.10m2),"Path"=temp_path))
        
        #write.csv(df.master.prese.10m2 ,paste(fld_MastTables,'MASTER-',temp_type,'_div_10m2Data100m2_csv.csv',sep=""),row.names = F)
        write.csv(df.master.NEON_presence.summary,paste(fld_MastTables,'MASTER-',temp_type,'_summary_csv.csv',sep=""),row.names = F)
      }  
      
      
    }
    
  }
}

#writting phenology data to disk
#write.csv(df.master.pheno.indiv,paste(fld_MastTables,'MASTER-',temp_type,'_phe_perindividual_csv.csv',sep=""),row.names = F)
#write.csv(df.master.pheno.statu ,paste(fld_MastTables,'MASTER-',temp_type,'_phe_statusintensity_csv.csv',sep=""),row.names = F)

#writting plant presence to disk
write.csv(df.master.prese.01m2,paste(fld_MastTables,'MASTER-',temp_type,'_div_1m2Data_csv.csv',sep=""),row.names = F)
write.csv(df.master.prese.10m2,paste(fld_MastTables,'MASTER-',temp_type,'_div_10m2Data100m2_csv.csv',sep=""),row.names = F)


gc()


#### test area ###

fetch_table <- function(tab_type=NA,file_path=NA,str_pattern){
  
  
  
  
  if (tab_type=="NEON_clip-herb"){
    
    df.out = read.csv(list.files(file_path,full.names = T,pattern = paste('*',str_pattern,'*',sep="")))
    #df2 = read.csv(list.files(file_path,full.names = T,pattern = "*perbout*"))
    #outlist = list('massdata'=df1,'perbout'=df2)
    
  } else if (tab_type=="NEON_litterfall") {
    
  } else if (tab_type=="NEON_obs-phenology-plant") {
    
  } else if (tab_type=="NEON_presence-cover-plant") {
    
  } else if (tab_type=="NEON_struct-non-herb-perennial-veg") {
    
  } else if (tab_type=="NEON_struct-woody-plant") {
    
  } else if (tab_type=="NEON_traits-foliar") {
    
  } else {
    stop("TABLE TYPE NOT FOUND!")
  }
  
  return(df.out)
}


