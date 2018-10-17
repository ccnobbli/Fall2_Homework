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

/* Visualize rain vs well height to see the affect of rain to determine number of lags, using just a few days */

data RainWell;
	set All_NoNA;
	if _n_ > 9373 and _n_ < 9393;
run;

proc sgplot data=RainWell;
	series x=DateHour1 y=WellLevel;
	series x=DateHour1 y=RainLevel;
run;
quit; *picked 16 lags;
proc sgplot data=RainWell;
	series x=DateHour1 y=WellLevel;
run;
quit; *picked 16 lags;
proc sgplot data=RainWell;;
	series x=DateHour1 y=RainLevel;
run;
quit; *picked 16 lags;


/******************************BEGIN MODELING****************************************/

/* Create lag variables. It looks like it takes 1 or 2 hours for rain to affect well levels, etc */
data All_NoNA;
set All_NoNA;
	Rain1=lag1(RainLevel);
	Rain2=lag2(RainLevel);
	Rain3=lag3(RainLevel);
	Rain4=lag4(RainLevel);
	Rain5=lag5(RainLevel);
	Rain6=lag6(RainLevel);
	Rain7=lag7(RainLevel);
	Rain8=lag8(RainLevel);
	Rain9=lag9(RainLevel);
	Rain10=lag10(RainLevel);
	Rain11=lag11(RainLevel);
	Rain12=lag12(RainLevel);
	Rain13=lag13(RainLevel);
	Rain14=lag14(RainLevel);
	Rain15=lag15(RainLevel);
	Rain16=lag16(RainLevel);
	Tide1=lag1(TideLevel);
	Tide2=lag2(TideLevel);
	Tide3=lag3(TideLevel);
	Tide4=lag4(TideLevel);
	Tide5=lag5(TideLevel);
	Well1=lag1(WellLevel);
	Well2=lag2(WellLevel);
	Welld = WellLevel - lag1(WellLevel);
	pi=constant("pi"); *change pi to constant;
	s1=sin(2*pi*1*_n_/14.37);
	c1=cos(2*pi*1*_n_/14.37);
	s2=sin(2*pi*2*_n_/14.37);
	c2=cos(2*pi*2*_n_/14.37);
	s3=sin(2*pi*3*_n_/14.37);
	c3=cos(2*pi*3*_n_/14.37);
	s4=sin(2*pi*4*_n_/14.37);
	c4=cos(2*pi*4*_n_/14.37);
	s5=sin(2*pi*1*_n_/24.7);
	c5=cos(2*pi*1*_n_/24.7);
	s6=sin(2*pi*2*_n_/24.7);
	c6=cos(2*pi*2*_n_/24.7);
	s7=sin(2*pi*3*_n_/24.7);
	c7=cos(2*pi*3*_n_/24.7);
	s8=sin(2*pi*4*_n_/24.7);
	c8=cos(2*pi*4*_n_/24.7);
	s9=sin(2*pi*1*_n_/12.5);
	c9=cos(2*pi*1*_n_/12.5);
	s10=sin(2*pi*2*_n_/12.5);
	c10=cos(2*pi*2*_n_/12.5);
	s11=sin(2*pi*3*_n_/12.5);
	c11=cos(2*pi*3*_n_/12.5);
	s12=sin(2*pi*4*_n_/12.5);
	c12=cos(2*pi*4*_n_/12.5);
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
identify var= WellLevel crosscorr=(RainLevel Rain1-Rain16 TideLevel Tide1-Tide5 s1-c4);
estimate p=2 input=(RainLevel Rain1 Rain2 Rain3 Rain4 Rain5 Rain6 Rain7 Rain8 Rain9 Rain10 Rain11 Rain12 Rain13 Rain14 Rain15 Rain16 TideLevel Tide1 Tide2 Tide3 Tide4 Tide5);
forecast out=resid1;
run;
quit;


proc arima data=resid1;
identify var=residual stationarity=(adf=3 );
run;
quit;
*We have stationairity;

proc glmselect data=train;
model WellLevel=RainLevel Rain1-Rain16 TideLevel Tide1-Tide5 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12/selection=stepwise select=AICC;
run;
quit;


/*No white noise model*/
proc arima data=train;
identify var=WellLevel(1) crosscorr=(RainLevel TideLevel);
estimate input=((1,2,3) RainLevel (1,3,4) TideLevel) p=15 q=9 method=ML;*no white noise;
forecast out=abimodel back=168 lead=168;
run;
quit;

/**/

proc arima data=train;
identify var=WellLevel(1) crosscorr=(RainLevel TideLevel);
estimate input=(/(1) RainLevel (1) TideLevel) p=9 q=9 method=ML; *large decrease in white noise;
forecast out=p9q9model back=168 lead=168;
run;
quit;



/*denominator term*/

proc arima data=train;
identify var=WellLevel(1) crosscorr=(RainLevel TideLevel);
estimate input=(/(1) RainLevel (1) TideLevel) p=1 method=ML; *Slight decrease in white noise;
forecast out=p1model back=168 lead=168;
run;
quit;

/* Measure of accuracy */

data val;
merge abimodel (rename=(residual=abires)) p9q9model (rename=(residual=p9q9res)) p1model (rename=(residual=p1res));
if _n_ > 93345;
run;

data val;
	set val;
	absAbiRes=abs(abires);
	absp9q9Res=abs(p9q9res);
	absp1Res=abs(p1res);
	mape_abi=absAbiRes/abs(WellLevel);
	mape_p9q9=absp9q9Res/abs(WellLevel);
	mape_p1 =absp1Res/abs(WellLevel);
run;

proc means data=val;
	var absAbiRes absp9q9Res absp1Res mape_abi mape_p9q9 mape_p1;
run; *First model, no white noise model, has the lowest MAPE of 0.0304199;

/* Final test for accuracy of model on test set */

proc arima data=All_NoNA;
identify var=WellLevel(1) crosscorr=(RainLevel TideLevel);
estimate input=((1,2,3) RainLevel (1,3,4) TideLevel) p=15 q=9 method=ML;*no white noise;
forecast out=FinModel back=168 lead=168;
run;
quit;

data Fin;
merge FinModel (rename=(residual=FinRes));
if _n_ > 93514;
run;

data Fin;
	set Fin;
	absFinRes=abs(FinRes);
	mape_Fin=absFinRes/abs(WellLevel);
run;

proc means data=Fin;
	var absFinRes mape_Fin;
run; *Final arima model [ARIMA(15,1,9)] MAPE of 0.0432893 on test set;
