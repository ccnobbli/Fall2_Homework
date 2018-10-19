PROC IMPORT OUT= WORK.bioinf 
            DATAFILE= "C:\Users\Christopher\Documents\IAA\TimeSeries\HW4
\data\indeed\bioinformatics_clean.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
