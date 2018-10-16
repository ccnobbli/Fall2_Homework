libname TS "C:\Users\lasky\Google Drive\Graduate School _ Jobs\NCSU MSA\Programming\Git\Fall2_Homework\Time Series Final Project";

/*
proc datasets library=work;
copy in=work out=TS;
select All_hourly;
run;quit;
*/


proc expand data = TS.All_Hourly
