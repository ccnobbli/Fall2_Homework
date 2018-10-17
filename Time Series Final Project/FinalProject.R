#install.packages('dplyr')
library(dplyr)
#install.packages('xts')
library(xts)

DataPath <- "C:\\Users\\lasky\\Google Drive\\Graduate School _ Jobs\\NCSU MSA\\Homework Groups\\Homework Fall 2\\Time Series\\"

###-----------------Data cleaning, no need to run---------------------###
{
HourlyLevels <- read.csv(paste(DataPath, 'G-1260_Well_Hourly.csv', sep = ''),col.names = c('DateHour','WellLevel'))

RainValues <- read.csv(paste(DataPath, 'G-1260_Rain.csv',sep = ''), col.names = c('DateHour','RainLevel'),sep = ",",stringsAsFactors = F)[,c(1,2)]
HourlyRain <- aggregate(. ~ DateHour, RainValues, sum)
#write.csv(HourlyRain,file = paste(DataPath,"G-1260_Rain_Hourly.csv",sep = ''))
All_Hourly <- left_join(HourlyLevels, HourlyRain, by = "DateHour")

TideValues <- read.csv(paste(DataPath, 'station_8722802.csv', sep = ''))
HourlyTide <- TideValues[which(substr(TideValues$Time,3,5)==":00"),]
HourlyTide_DateHour <- setNames(data.frame(matrix(ncol = 2, nrow = nrow(HourlyTide))), c("DateHour", "TideLevel")) #create new data frame
HourlyTide_DateHour[,1] <- paste(gsub("-","/",HourlyTide$Date),HourlyTide$Time)
HourlyTide_DateHour[,2] <- HourlyTide$Prediction
#write.csv(HourlyTide,file = paste(DataPath,"G-1260_Tide_Hourly.csv",sep = ''))
All_Hourly <- left_join(All_Hourly, HourlyTide_DateHour, by = "DateHour")
#write.csv(All_Hourly, paste(DataPath, "G-1260_All_Hourly.csv", sep = ''), row.names = FALSE)
}
###----------------Analysis--------------###

Hourly_Dat <- read.csv(paste(DataPath, 'G-1260_All_Hourly.csv',sep = ''))

