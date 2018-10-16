libname TS "C:\Users\lasky\Google Drive\Graduate School _ Jobs\NCSU MSA\Programming\Git\Fall2_Homework\Time Series Final Project";

/*
proc datasets library=work;
copy in=work out=TS;
select All_hourly;
run;quit;
*/

proc sort data = TS.All_hourly out = work.All;
	by DateHour;
run;

data All_n;
	set All;
	SeqNo = _n_;
run;

/* Impute missing values in a linear fashion */
proc expand data=All_n out=All_NoNA;
	convert WellLevel=linear / method=join;
	id SeqNo;
run;

data All_NoNA (keep = DateHour WellLevel_Imp RainLevel TideLevel);
	set All_NoNA (rename=(linear=WellLevel_Imp));
run;

