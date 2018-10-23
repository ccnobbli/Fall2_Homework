libname TS "C:\Users\Christopher\Documents\GitHub\Fall2_Homework\data\Well Data_Split\final_wells\";

/* Turn All_Hourly.csv into All_hourly.sas7bdat */
PROC IMPORT OUT= WORK.All_hourly
         DATAFILE= "C:\Users\Christopher\Documents\GitHub\Fall2_Homework\data\Well Data_Split\final_wells\G580A_ALL.csv"
         DBMS=CSV REPLACE;
     GETNAMES=YES;
RUN;


proc datasets library=work;
copy in=work out=TS;
select All_hourly;
run;quit;

 /* Create temp file so we aren't messing with the old one */
proc sort data = TS.All_hourly out = work.All;
	by DateHour;
run;

/******************************BEGIN MODELING****************************************/

/* Create lag variables. It looks like it takes 1 or 2 hours for rain to affect well levels, etc */
data All;
set All;
	Rain1=lag1(Rain_ft);
	Rain2=lag2(Rain_ft);
	Rain3=lag3(Rain_ft);
	Rain4=lag4(Rain_ft);
	Rain5=lag5(Rain_ft);
	Rain6=lag6(Rain_ft);
	Rain7=lag7(Rain_ft);
	Rain8=lag8(Rain_ft);
	Rain9=lag9(Rain_ft);
	Rain10=lag10(Rain_ft);
	Rain11=lag11(Rain_ft);
	Rain12=lag12(Rain_ft);
	Rain13=lag13(Rain_ft);
	Rain14=lag14(Rain_ft);
	Rain15=lag15(Rain_ft);
	Rain16=lag16(Rain_ft);
	Tide1=lag1(Tide_ft);
	Tide2=lag2(Tide_ft);
	Tide3=lag3(Tide_ft);
	Tide4=lag4(Tide_ft);
	Tide5=lag5(Tide_ft);
	Well1=lag1(Well_ft);
	Well2=lag2(Well_ft);
	Welld = Well_ft - lag1(Well_ft);
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

/* Final test for accuracy of model on test set */

proc arima data=All;
identify var=Well_ft(1) crosscorr=(Rain_ft Tide_ft);
estimate input=((1,2,3) Rain_ft (1,3,4) Tide_ft) p=15 q=9 maxiter=250;*no white noise;
forecast out=G580A_ALL_Pred back=168 lead=168;
run;
quit;


proc datasets library=work;
copy in=work out=TS;
select G580A_ALL_Pred;
run;quit;
