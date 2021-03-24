
library(neonUtilities)

#Ran on 2021/03/18
setwd("D:/NEON/Data_Neon/")

#Data products
data.list = data.frame('Name'=c('Herbaceous clip harvest',
                                'Litterfall and fine woody debris production and chemistry',
                                'Non-herbaceous perennial vegetation structure',
                                'Plant phenology observations',
                                'Plant presence and percent cover',
                                'Woody plant vegetation structure',
                                #'Litter chemical properties',
                                'Plant foliar traits'),
                       'dpID'=c('DP1.10023.001',
                                'DP1.10033.001',
                                'DP1.10045.001',
                                'DP1.10055.001',
                                'DP1.10058.001',
                                'DP1.10098.001',
                                #'DP1.10031.001', # bundled with dp10033.001
                                'DP1.10026.001'))
data.list$dateDownload = '18/03/2021'

#downloading loop - Request a token to make it faster
for (i in 4:nrow(data.list)){
  print(i)
  
  zipsByProduct(dpID=data.list$dpID[i],
                site='all',
                package='basic',
                check.size = F,
                savepath = './ZipsByProduct_20210318/',
                token='eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnL2FwaS92MC8iLCJzdWIiOiJudW5vLmNlc2FyLnNhQGdtYWlsLmNvbSIsInNjb3BlIjoicmF0ZTpwdWJsaWMiLCJpc3MiOiJodHRwczovL2RhdGEubmVvbnNjaWVuY2Uub3JnLyIsImV4cCI6MTc3Mzc4ODY1OSwiaWF0IjoxNjE2MTA4NjU5LCJlbWFpbCI6Im51bm8uY2VzYXIuc2FAZ21haWwuY29tIn0.qnbWk3ORey0uecnIvPVaxys0wdik0CMsUGeCabrJck2XUdLGxD-R7NSW4hON1GH6_qPj3MJnKS6EiKN4-NSTnw'
  )
  }
