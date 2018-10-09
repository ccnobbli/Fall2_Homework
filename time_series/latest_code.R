library(tidyverse)

#read in well data aggregated monthly in Python
df <- read_csv("C:\\Users\\Abigail\\Documents\\MSA\\Python\\G-1260_Monthly.csv", col_names= TRUE)


#Develop a time series data object named 'well'
#Can specify which month to start in with the vector input in the start argument
#well <- ts(df$Corrected, start = c(2007, 6553), frequency= 8736)
library(forecast)
well <- msts(df$Corrected, start= c(2007, 6553), seasonal.periods = c(24, 24*365.25))


#dealing with NA data
library(imputeTS)

plotNA.distribution(well)

comp_well <- na.interpolation(well)

#no red!!! no missing
plotNA.distribution(comp_well)

#creating a Holdout Data Sets
well_t = subset(comp_well,end=length(comp_well)-168)
well_v = subset(comp_well,start=length(comp_well)-167)


#Plot of the entire time series data object 
plot(well_t, col = "blue", main = "Well Depth - Trend/Cycle", xlab = "Date", ylab = "Depth of Well", lwd = 2)


#TS Decomposition, I think STL would be good because the seasonality doesn't appear to be consistent 
#Discuss when the seasonality changes at around 2012
#Recreate the seasonality plot
decomp_well_t <- mstl(well_t, s.window = 7)
plot(decomp_well_t)

?tseries::adf.test

?seasonal::seas


forecast::nsdiffs(well_t)


############Last term's homework code

#Creating plot of the seasonal component
plot(decomp_well_t$time.series[,1] ,
     col = "navy",
     main = "Seasonal Component of Training Subset of Well Water Height",
     xlab = "",
     ylab = "Seasonal Variation (Feet)",
     lwd = 2
)

a#Creating plot of the trend component
plot(decomp_well_t$time.series[,2] ,
     col = "navy",
     main = "Trend Component of Training Subset of Well Depth",
     #xlab = "Date",
     ylab = "Water Depth of Well in Feet",
     lwd = 2
)

#Trend/Cycle for Well
plot(well, col = "grey", main = "Well Depth - Trend/Cycle", xlab = "Date", ylab = "Depth of Well (Feet)", colour="grey", lwd = 2)
lines(decomp_well_t$time.series[,2], col = "navy", lwd = 2)

#Seasonally Adjusted 
seas_well_t=well_t - decomp_well_t$time.series[,1]
plot(well, col = "grey", main = "Well Depth - Seasonally Adjusted", xlab = "Date", ylab = "Depth of Well (Feet)", lwd = 2)
lines(seas_well_t, col = "navy", lwd = 2)

plot(seas_well_t)
#########################################################################################
#Holdout Holt-Winter ESM
HWES.well.train <- hw(well_t, seasonal = "additive")
well_test.results=forecast(HWES.well.train,h=6)


plot(well_test.results, main = "Well Depth with Holt-Winters ESM Forecast", xlab = "Date", ylab = "Depth (ft)")
error_well=well_v-well_test.results$mean
MAE=mean(abs(error_well))
MAPE=mean(abs(error_well)/abs(well_v))
error_well
MAPE

#HOLT Function
LES.well <- holt(well_t, initial = "optimal", h = 6)
summary(LES.well)
plot(LES.well, main = "Well Depth with LESM Forecast", xlab = "Date", ylab = "Depth (ft)")


#Plot of predicted values versus actual values of the validation dataset
plot(well_v, main = "Validation Data Versus Predicted Values",
     xlab = "Date",
     ylab = "Well Depth (Feet)",
     lwd = 2)

lines(well_test.results$mean,col="red",lwd=2)

#Plot of entire time series with the predictions
plot(well, col = "black", main = "Well Depth - Trend/Cycle", xlab = "Date", ylab = "Depth of Well (Feet)", lwd = 2)
lines(well_test.results$mean,col="red",lwd=2)
lines(well_v,col="purple",lwd=2)
vector_well_v = c(well_v)

#Dataframe of validation data set
df_well_v = data.frame(Values = vector_well_v,
                       Date = as.Date(c("2018-01-01", "2018-02-01", "2018-03-01","2018-04-01","2018-05-01","2018-06-01")),
                       ind = c(1,2,3,4,5,6),
                       stringsAsFactors = FALSE)

df_well_results = data.frame(Values = well_test.results$mean,
                             Date = as.Date(c("2018-01-01", "2018-02-01", "2018-03-01","2018-04-01","2018-05-01","2018-06-01")),
                             ind = c(1,2,3,4,5,6),
                             stringsAsFactors = FALSE)
#Creating dataframe of predicted values from sas additive seasonal esm
df_well_results_sas = data.frame(Values = c(4.63220,4.42801,4.20665,4.43158,4.76175,5.06238),
                                 Date = as.Date(c("2018-01-01", "2018-02-01", "2018-03-01","2018-04-01","2018-05-01","2018-06-01")),
                                 ind = c(1,2,3,4,5,6),
                                 stringsAsFactors = FALSE)

#Plot of Validation vs. Predicted Values
ggplot(df_well_v,aes(x=Date,y=Values,colour="Validation")) +
  geom_line(lwd=1)+
  geom_point() +
  labs(title="Actual Vs. Predicted Test Values for Well Water Height",x="Date (2018)",y="Well Water Height (Feet)") + 
  theme_classic() +
  geom_line(data=df_well_results_sas,aes(x=Date,y=Values,colour="Prediction"),lwd=1) + 
  geom_point(data=df_well_results_sas,aes(x=Date,y=Values,colour="Prediction")) +
  scale_colour_manual("", 
                      breaks = c("Validation", "Prediction"),
                      values = c("navy", "grey")) 

#Writing csv
write.csv(well, file = "C:/Users/Christian/Documents/AA502 - Time Series Class/Homework 1/well_timeseries.csv")




#######SAS CODE#######
/*Import full Dataset*/
  proc import out= Full_set
datafile= "C:\Users\Emily\Documents\Time Series\Homework\Full_dataset.csv"
dbms=csv ;
run;

/*Additive Seasonal only model*/
  proc esm data=Full_set print=all plot=all
seasonality=12 lead=6 back = 6 outfor=test_training;
forecast x/model=addseason;
run;