%macro main;
    %if %upcase(&EM_ACTION) = CREATE %then %do;
        filename temp catalog 'sashelp.emtxtext.topic_create.source';
        %include temp;
        %create;
    %end;
    %if %upcase(&EM_ACTION) = TRAIN %then %do;
        filename temp catalog 'sashelp.emtxtext.topic_train.source';
        %include temp;
        %train;
    %end;
   %if %upcase(&EM_ACTION) = SCORE %then %do;
        filename temp catalog 'sashelp.emtxtext.topic_score.source';
        %include temp;
        %score;
    %end;
    %if %upcase(&EM_ACTION) = REPORT %then %do;
        filename temp catalog 'sashelp.emtxtext.topic_report.source';
        %include temp;
        %report;
    %end;
%mend main;

%main;

