
libname termloc "C:\Users\Christopher\Documents\IAA\TimeSeries\HW4\text_minining_project\Workspaces\EMWS1";

%let _multifile=%SYSFUNC(PATHNAME(work))/TextFilter_multi.txt;
%let _multiSLength= %klength(&_multifile);

data termloc.TextFilter_tmconfig;
length multiterm $ &_multiSLength;
set termloc.TextFilter_tmconfig;
multiterm=ktrim(symget('_multifile'));
run;

proc sql noprint;
select multiencoding into: _tmmultiencoding
from termloc.TextFilter_tmconfig;
quit;

filename _multout "&_multifile";
data _NULL_;
set termloc.TextParsing_multiall;
file _multout encoding= "%trim(&_tmmultiencoding)";
put term ':3:' role;
run;
