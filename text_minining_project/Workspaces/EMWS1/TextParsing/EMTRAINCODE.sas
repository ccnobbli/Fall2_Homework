%macro main();
  %if %upcase(&EM_ACTION) eq CREATE %then %do;
    filename temp catalog 'sashelp.emtxtext.parse_create.source';
    %include temp;
    %create();
  %end;
  %if %upcase(&EM_ACTION) eq TRAIN %then %do;
    filename temp catalog 'sashelp.emtxtext.parse_train.source';
    %include temp;
    %train();
  %end;
  %if %upcase(&EM_ACTION) eq REPORT %then %do;
    filename temp catalog 'sashelp.emtxtext.parse_report.source';
    %include temp;
    %report();
  %end;
  %if %upcase(&EM_ACTION) eq SCORE %then %do;
    filename temp catalog 'sashelp.emtxtext.parse_score.source';
    %include temp;
    %score();
  %end;
    %if %upcase(&EM_ACTION) eq OPENTABLE1 %then %do;
       filename temp catalog 'sashelp.emtxtext.parse_actions.source';
       %include temp;
       filename temp;
       %openTable1;
   %end;
%mend main;

%main();




