PROC IMPORT OUT= WORK.De 
            DATAFILE= "C:\Users\Christopher\Documents\IAA\TimeSeries\HW4
\data\indeed\data_engineer_clean.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
