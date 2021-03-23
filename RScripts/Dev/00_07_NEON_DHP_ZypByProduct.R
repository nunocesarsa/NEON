library(neonUtilities)
gc()


#Ran on 23/03/2021

#Test download
setwd("D:/NEON/Data_Neon/")

#create a directory
dir.create('ZipsByProduct_DHP_20210323')

zipsByProduct(dpID='DP1.10017.001',
              site='all',
              package='basic',
              check.size = F,
              savepath ='D:/NEON/Data_Neon//ZipsByProduct_DHP_20210323/',
              token='eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnL2FwaS92MC8iLCJzdWIiOiJudW5vLmNlc2FyLnNhQGdtYWlsLmNvbSIsInNjb3BlIjoicmF0ZTpwdWJsaWMiLCJpc3MiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnLyIsImV4cCI6MTc3Mzg4Mzg3MSwiaWF0IjoxNjE2MjAzODcxLCJlbWFpbCI6Im51bm8uY2VzYXIuc2FAZ21haWwuY29tIn0.MsU9SbNGA1sH7aj29fdJuCZv73C5HD7b_OLQYozryaIDaS62xwcYHxuHHlryvie89kVP4QrBH6oMn5V3eVkyBw')

