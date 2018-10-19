PROC IMPORT OUT= WORK.DS_CLEAN 
            DATAFILE= "C:\Users\Christopher\Documents\IAA\TimeSeries\HW4
\data\indeed\data_scientist_clean.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
