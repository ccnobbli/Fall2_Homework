PROC IMPORT OUT= WORK.fe 
            DATAFILE= "C:\Users\Christopher\Documents\IAA\TimeSeries\HW4
\data\indeed\biologist_clean.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
