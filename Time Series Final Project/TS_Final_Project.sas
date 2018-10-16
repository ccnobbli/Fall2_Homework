libname TS "C:\Users\lasky\Google Drive\Graduate School _ Jobs\NCSU MSA\Programming\Git\Fall2_Homework\Time Series Final Project";

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

/* Create column with a sequence of x values (SeqNo) which will be referenced in the linear imputation below */
data All_n;
	set All;
	Date = tranwrd(DateHour,"/","-");
	DateHour1 = input(Date,e8601dt19.);
	format DateHour1 datetime19.;
run;

/* Impute missing values in a linear fashion */
proc expand data=All_n out=All_NoNA;
	convert WellLevel=linear / method=join;
	id DateHour1;
run;

/* Drop SeqNo and WellLevel and rename the linearaly imputed column to WellLevel_Imp */
data All_NoNA (keep = DateHour1 WellLevel_Imp RainLevel TideLevel);
	set All_NoNA (rename=(linear=WellLevel_Imp));
run;

proc timeseries data=All_NoNA plots=(series decomp); *decomp REQUIRES seasonality to the data;
	id DateHour1 interval=hour;
	var WellLevel_Imp;
run;
