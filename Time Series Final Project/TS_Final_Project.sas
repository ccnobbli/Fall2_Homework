libname TS "C:\Users\lasky\Google Drive\Graduate School _ Jobs\NCSU MSA\Programming\Git\Fall2_Homework\Time Series Final Project";

/* Turn All_Hourly.csv into All_hourly.sas7bdat */
/*
proc datasets library=work;
copy in=work out=TS;
select All_hourly;
run;quit;
*/
 /* Create temp file so we aren't messing with the old one */
proc sort data = TS.All_hourly out = work.All;
	by DateHour;
run;

/* Transforms DateHour character column into DateHour1 timeseries column */
data All_n;
	set All;
	Date = tranwrd(DateHour,"/","-");
	DateHour1 = input(Date,e8601dt19.);
	format DateHour1 datetime19.;
run;

/* Impute missing values for WellLevels in a linear fashion */
proc expand data=All_n out=All_NoNA;
	convert WellLevel=WellLevel / method=join;
	id DateHour1;
run;

/* Impute missing values for TideLevels in a linear fashion */
proc expand data=All_NoNA out=All_NoNA;
	convert TideLevel=TideLevel / method=join;
	id DateHour1;
run;

/* Keeping only necessary columns, DateHour1 is a time series column type now */
data All_NoNA (keep = DateHour1 WellLevel RainLevel TideLevel);
	set All_NoNA;
run;

/* Decomposition of well levels */
proc timeseries data=All_NoNA plots=(series decomp); *decomp REQUIRES seasonality to the data;
	id DateHour1 interval=hour;
	var WellLevel;
run;

/* Decomposition of rainlevels  */
proc timeseries data=All_NoNA plots=(series decomp); *decomp REQUIRES seasonality to the data;
	id DateHour1 interval=hour;
	var RainLevel;
run;

/* Decomposition of tidelevels */
proc timeseries data=All_NoNA plots=(series decomp); *decomp REQUIRES seasonality to the data;
	id DateHour1 interval=hour;
	var TideLevel;
run;

/* Visualization of well levels with rain levels */
proc sgplot data=All_NoNA;
	series x=DateHour1 y=WellLevel;
	series x=DateHour1 y=RainLevel;
run;
quit;

/* Visualization of well levels with tide levels */
proc sgplot data=All_NoNA;
	series x=DateHour1 y=WellLevel;
	series x=DateHour1 y=TideLevel;
run;
quit;

/* Checking if residuals are stationary */
proc arima data=All_NoNA;
identify var=WellLevel crosscorr=(RainLevel TideLevel);
estimate input=(RainLevel TideLevel) p=2 method=ML; *p=2 is small AR term;
forecast out=All_1;
run;
quit;

proc arima data=All_1;
identify var=residual stationarity=(adf=2);
run;
quit;  * residuals are stationary;


/******************************BEGIN MODELING****************************************/

/* Create lag variables. It looks like it takes 1 or 2 hours for rain to affect well levels, etc */
data All_NoNA;
set All_NoNA;
	Rain1=lag1(RainLevel);
	Rain2=lag2(RainLevel);
	Rain3=lag3(RainLevel);
	Tide1=lag1(TideLevel);
	Tide2=lag2(TideLevel);
	Tide3=lag3(TideLevel);
	Tide4=lag4(TideLevel);
	Tide5=lag5(TideLevel);
	Well1=lag1(WellLevel);
	Well2=lag2(WellLevel);
	Welld = WellLevel - lag1(WellLevel);
	*Include more lags of rain, plot two days worth to see how many lags;
run;
/*Subset data. Last week is the test set */
data train;
set All_NoNA;
if _n_<93515;
run;

data test;
set All_NoNA;
if _n_>93514;
run;

/* First need to check residuals are stationary in mean and variance  */
proc arima data=train;
identify var= WellLevel crosscorr=(RainLevel Rain1 Rain2 Rain3 TideLevel Tide1 Tide2 Tide3 Tide4 Tide5);
estimate p=2 input=(RainLevel Rain1 Rain2 Rain3 TideLevel Tide1 Tide2 Tide3 Tide4 Tide5);
forecast out=resid1;
run;
quit;


proc arima data=resid1;
identify var=residual stationarity=(adf=3 );
run;
quit;
*We have stationairity;

proc glmselect data=train;
model WellLevel=Welld RainLevel Rain1 Rain2 Rain3 TideLevel Tide1 Tide2 Tide3 Tide4 Tide5/selection=stepwise select=AICC;
run;
quit; *R-Squared = 1, probably have an issue with collinearity;

/*proc glmselect hinted at these lags*/
proc arima data=train;
identify var=WellLevel crosscorr=(RainLevel TideLevel);
estimate input=((1,2,3) RainLevel (1,3,4) TideLevel) p=2 method=ML;
run;
quit;

/*denominator term*/

proc arima data=train;
identify var=WellLevel crosscorr=(RainLevel TideLevel);
estimate input=(/(1) RainLevel (1,3,4) TideLevel) p=2 method=ML; *change of 20 with tide level changed to /(1);
run;
quit;
