unit WinIoCtl;

interface
uses SysUtils;

function CTL_CODE(devicetype,func,method,access:integer):integer;

implementation

function CTL_CODE(devicetype,func,method,access:integer):integer;
begin
   Result:=(devicetype SHL 16) or (access SHL 14) or (func SHL 2) or method;
end;

end.
