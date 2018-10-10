library(tidyverse)

#read in well data aggregated monthly in Python
df <- read_csv("C:\\Users\\Abigail\\Documents\\MSA\\Python\\G-1260_Monthly.csv", col_names= TRUE)


#Develop a time series data object named 'well'
#Can specify which month to start in with the vector input in the start argument
#well <- ts(df$Corrected, start = c(2007, 6553), frequency= 8736)
library(forecast)
well <- msts(df$Corrected, start= c(2007, 6553), seasonal.periods = c(24, 24*365.25))


View(well)


#dealing with NA data
install.packages("imputeTS")
library(imputeTS)

plotNA.distribution(well)

comp_well <- na.interpolation(well)

#no red!!! no missing
plotNA.distribution(comp_well)

#creating a Holdout Data Sets
well_t = subset(comp_well,end=length(well)-168)
well_v = subset(comp_well,start=length(well)-167)


#Plot of the entire time series data object 
plot(well_t, col = "blue", main = "Well Depth - Trend/Cycle", xlab = "Date", ylab = "Depth of Well", lwd = 2)


#TS Decomposition, I think STL would be good because the seasonality doesn't appear to be consistent 
#Discuss when the seasonality changes at around 2012
#Recreate the seasonality plot
decomp_well_t <- mstl(well_t, s.window = 7)
plot(decomp_well_t)

#validation
decomp_well_v <- mstl(well_v, s.window = 7)
plot(decomp_well_v)


#estimate # of seasonal differences neccesary
nsdiffs(well_t, alpha = 0.05, max.D = 1)

#automated seasonal differencing for daily season
ndiffs(diff(well_t, lag = 24))
#0

#automated seasonal differencing for annual season
ndiffs(diff(well_t, lag = 24*365.25))
#1
###does this mean that we need to take an annual difference?


#library(tseries)
#adf.test(well_t, alternative = "stationary", k = 0)


#### adding Sine and Cosine in ARIMA to model seasonality
#tx <- read_sas(paste(file.dir, input.file1, sep = ""))
#airline <- read_sas(paste(file.dir, input.file2, sep = ""))
#tx.ts<-ts(tx$Temperature,frequency = 12)
#air.ts<-ts(airline$LogPsngr,frequency = 12)
index.ts=seq(1,length(well_t))
x1.sin=sin(2*pi*index.ts*1/8766)
x1.cos=cos(2*pi*index.ts*1/8766)
x2.sin=sin(2*pi*index.ts*2/8766)
x2.cos=cos(2*pi*index.ts*2/8766)
x3.sin=sin(2*pi*index.ts*3/8766)
x3.cos=cos(2*pi*index.ts*3/8766)
x4.sin=sin(2*pi*index.ts*4/8766)
x4.cos=cos(2*pi*index.ts*4/8766)
x5.sin=sin(2*pi*index.ts*5/8766)
x5.cos=cos(2*pi*index.ts*5/8766)
x1.24.sin=sin(2*pi*index.ts*1/24)
x1.24.cos=cos(2*pi*index.ts*1/24)
x2.24.sin=sin(2*pi*index.ts*2/24)
x2.24.cos=cos(2*pi*index.ts*2/24)
x3.24.sin=sin(2*pi*index.ts*3/24)
x3.24.cos=cos(2*pi*index.ts*3/24)
x4.24.sin=sin(2*pi*index.ts*4/24)
x4.24.cos=cos(2*pi*index.ts*4/24)
x5.24.sin=sin(2*pi*index.ts*5/24)
x5.24.cos=cos(2*pi*index.ts*5/24)
x.reg=cbind(x1.sin,x1.cos,x2.sin,x2.cos,x3.sin,x3.cos,x4.sin,x4.cos,x5.sin,x5.cos,x1.24.sin,x1.24.cos,x2.24.sin,x2.24.cos,x3.24.sin,x3.24.cos,x4.24.sin,x4.24.cos,x5.24.sin,x5.24.cos)
arima.1<-Arima(well_t,order=c(0,0,0),xreg=x.reg)
summary(arima.1)


#trying to fit a fourier
fit <- auto.arima(well_t, seasonal=FALSE,
                  xreg=fourier(, K=c(10,10)))




