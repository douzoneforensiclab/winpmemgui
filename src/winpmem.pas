unit winpmem;

interface
uses SysUtils, Classes, Generics.Collections, Windows, elf, WinIoCtl;

var
// ioctl to get memory ranges from our driver.
PMEM_CTRL_IOCTRL : integer ;
PMEM_WRITE_ENABLE : integer;
PMEM_INFO_IOCTRL : integer;
{
PMEM_CTRL_IOCTRL : integer = CTL_CODE($22, $101, 0, 3);
PMEM_WRITE_ENABLE : integer = CTL_CODE($22, $102, 0, 3);
PMEM_INFO_IOCTRL : integer = CTL_CODE($22, $103, 0, 3);
}

const
PMEM_VERSION = '1.6.2';
PMEM_DEVICE_NAME  = 'pmem';
PMEM_SERVICE_NAME = 'pmem';

// These numbers are set in the resource editor for the FILE resource.
WINPMEM_64BIT_DRIVER = 104;
WINPMEM_32BIT_DRIVER = 105;
WINPMEM_FCAT_EXECUTABLE = 106;

PAGE_SIZE = $1000;

// We use this special section to mark the beginning of the pmem metadata
// region. Note that the metadata region extends past the end of this physical
// header - it is guaranteed to be the last section. This allows users to simply
// add notes by appending them to the end of the file (e.g. with a hex editor).
PT_PMEM_METADATA = (PT_LOOS + $d656d70);


PROCESSOR_ARCHITECTURE_INTEL          =  0 ;
PROCESSOR_ARCHITECTURE_MIPS           =  1 ;
PROCESSOR_ARCHITECTURE_ALPHA          =  2 ;
PROCESSOR_ARCHITECTURE_PPC            =  3 ;
PROCESSOR_ARCHITECTURE_SHX            =  4  ;
PROCESSOR_ARCHITECTURE_ARM            =  5 ;
PROCESSOR_ARCHITECTURE_IA64           =  6 ;
PROCESSOR_ARCHITECTURE_ALPHA64        =  7 ;
PROCESSOR_ARCHITECTURE_MSIL           =  8 ;
PROCESSOR_ARCHITECTURE_AMD64          =  9 ;
PROCESSOR_ARCHITECTURE_IA32_ON_WIN64  =  10;


// Available modes
PMEM_MODE_IOSPACE =0;
PMEM_MODE_PHYSICAL =1;
PMEM_MODE_PTE =2;
PMEM_MODE_PTE_PCI =3;

PMEM_MODE_AUTO =99;

//#pragma pack(push, 2)
type
{$ALIGN 2}
pmem_info_runs = packed record
  start : Int64;
  length : Int64;
end;
PHYSICAL_MEMORY_RANGE = pmem_info_runs;

PmemMemoryInfo = packed record
  CR3 : LARGE_INTEGER;
  NtBuildNumber : LARGE_INTEGER; // Version of this kernel.
  KernBase : LARGE_INTEGER;  // The base of the kernel image.
  KDBG : LARGE_INTEGER;  // The address of KDBG

  // Support up to 32 processors for KPCR.
  KPCR : array [0..32-1] of LARGE_INTEGER ;

  PfnDataBase : LARGE_INTEGER;
  PsLoadedModuleList : LARGE_INTEGER;
  PsActiveProcessHead : LARGE_INTEGER;

  // The address of the NtBuildNumber integer - this is used to find the kernel
  // base quickly.
  NtBuildNumberAddr : LARGE_INTEGER;

  // As the driver is extended we can add fields here maintaining
  // driver alignment..
  Padding : array [0..$fe - 1] of LARGE_INTEGER;

  NumberOfRuns : LARGE_INTEGER;

  // A Null terminated array of ranges.
  Run : array [0..100-1] of PHYSICAL_MEMORY_RANGE;
end;

PPmemMemoryInfo = ^PmemMemoryInfo;

TpMemLogType = (mlogNomal, mlogError);
TonLogMessage = procedure (sender : TObject; AValue : string; ALogType : TpMemLogType) of object;
TonStatus = procedure (sender : TObject; ACurrent, ATotal : Int64) of object;
TonMaxMemoryStatus = procedure (sender : TObject; ATotal : Int64) of object;

type
  TWinPmem = class
  protected
    default_mode_ : Uint32;
    FisCancel : Boolean;

    FonLogMessage : TonLogMessage;
    FonStatus :  TonStatus;
  private
    FonMaxMemoryStatus: TonMaxMemoryStatus;

  public
     suppress_output : int64;
    last_error : array [0..1024 -1] of char;

  constructor Create();
  destructor Destroy; override;

  function install_driver() : int64; virtual;
  function uninstall_driver(AisLog : boolean) : int64; virtual;
  function set_write_enabled() : int64; virtual;
  function  set_acquisition_mode(mode : UInt32) : int64; virtual;
  procedure set_driver_filename(driver_filename : string); virtual;
  procedure set_pagefile_path(pagefile_path : string); virtual;
  procedure write_page_file(); virtual;
  procedure print_memory_info(); virtual;

  // In order to create an image:

  // 1. Create an output file with create_output_file()
  // 2. Select either write_raw_image() or write_crashdump().
  // 3. When this object is deleted, the file is closed.
  function create_output_file(output_filename : string) : int64; virtual;
  function write_raw_image() : int64; virtual;
  function write_coredump() : int64; virtual;

  procedure SetCancel();

  property onLogMessage : TonLogMessage read FonLogMessage write FonLogMessage;
  property onStatus : TonStatus read FonStatus write FonStatus;
  property onMaxMemoryStatus : TonMaxMemoryStatus read FonMaxMemoryStatus write FonMaxMemoryStatus;


  // This is set if output should be suppressed (e.g. if we pipe the
  // image to the STDOUT).



  //function extract_driver() : Int64; overload; virtual; // result default 0
//  function extract_driver(driver_filename : Pchar) : Int64; overload; virtual;
  property DefaultMode : Uint32 read default_mode_ write default_mode_;
  protected
  // The file handle to the pmem device.
   fd_ : THandle;

  // The file handle to the image file.
  out_fd_ : THandle;
  service_name : Pchar;
  //buffer_ : PAnsiChar; // TBytes 로 해도 될거 같은데 //
  buffer_ : TBytes;
  buffer_size_ : Cardinal;
  driver_filename_ : string;
  driver_is_tempfile_ : BOOL;

  // This is the maximum size of memory calculated.
  max_physical_memory_ : Uint64;

  // Current offset in output file (Total bytes written so far).
  out_offset : Uint64;

  // The current acquisition mode.
  mode_ : Uint32;

  // The pagefile name to acquire.
  pagefile_path_ : string;

  procedure CreateChildProcess(command : Pchar; stdout_wr : THandle);

  //function extract_file_(resource_id : Int64; filename : string) : int64;
  function write_coredump_header_(info : PPmemMemoryInfo) : int64; virtual;

  //procedure LogError(Msg : Pchar); virtual;
  //procedure Log(const Msg : Pchar; Args: array of const); virtual;
  //procedure LogLastError(Msg : Pchar); virtual;

  procedure LogInfo(AMsg : string; ALogType : TpMemLogType);
  procedure StatusInfo(ACurrent, ATotal : int64);

  function pad(length : int64) : Int64;
  function copy_memory(start, end_ : UInt64) : int64;

 private
   metadata_ : AnsiString;
   metadata_len_ : DWORD;

  // The offset of the previous metadata header.
  last_header_offset_ : Uint64;
  procedure print_mode_(mode : Uint32);

  end;


//  TWinPmem32 = class(TWinPmem)
//  public
//    constructor Create();
//    function extract_driver() : Int64; overload; override;
//  end;
//
//  TWinPmem64 = class(TWinPmem)
//  public
//    constructor Create();
//    function extract_driver() : Int64; overload; override;
//  end;

type
tm = packed record
        tm_sec : Integer;//     /* seconds after the minute - [0,59] */
        tm_min : Integer;//     /* minutes after the hour - [0,59] */
        tm_hour : Integer;//    /* hours since midnight - [0,23] */
        tm_mday : Integer;//    /* day of the month - [1,31] */
        tm_mon : Integer;//     /* months since January - [0,11] */
        tm_year : Integer;//    /* years since 1900 */
        tm_wday : Integer;//    /* days since Sunday - [0,6] */
        tm_yday : Integer;//    /* days since January 1 - [0,365] */
        tm_isdst : Integer;//   /* daylight savings time flag */
end;

__time32_t = LongInt;


implementation
uses Math, WinSvc;

function SetFilePointerEx(hFile: THandle; liDistanceToMove: LARGE_INTEGER;
     lpNewFilePointer: PLargeInteger; dwMoveMethod: DWORD): BOOL;
    stdcall; external 'kernel32.dll';
procedure RtlZeroMemory(destination:pointer; length:dword); stdcall; external 'kernel32.dll';


///* Create a YAML file describing the image encoded into a null terminated
//   string. Caller will own the memory.
// */
function store_metadata_(info : PPmemMemoryInfo) : string;
var
 sys_info : SYSTEM_INFO;
  newtime : tm;
  aclock : __time32_t;
  arch : string;
begin


//  char time_buffer[32];
//  errno_t errNum;
//  char *arch = NULL;
//
//  _time32( &aclock );   // Get time in seconds.
//  _gmtime32_s( &newtime, &aclock );   // Convert time to struct tm form.
//
//  // Print local time as a string.
//  errNum = asctime_s(time_buffer, 32, &newtime);
//  if (errNum) {
//    time_buffer[0] = 0;
//  }

  // Get basic architecture information (Note that we always write ELF64 core
  // dumps - even on 32 bit platforms).
  ZeroMemory(@sys_info, sizeof(sys_info));
  GetNativeSystemInfo(sys_info);

  arch := 'Unknown';
  case sys_info.wProcessorArchitecture of
    PROCESSOR_ARCHITECTURE_AMD64: arch := 'AMD64';
    PROCESSOR_ARCHITECTURE_INTEL: arch := 'I386';
  end;

  Result :=       '# PMEM'+#10 +
                  '---'+#10 +   // The start of the YAML file.
                  'acquisition_tool: WinPMEM " '+ PMEM_VERSION +' "'+#10 +
                  'acquisition_timestamp: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + #10 +
                  'CR3: '+IntToHex(info^.CR3.QuadPart, 2)+#10 +
                  'NtBuildNumber: '+IntToHex(info^.NtBuildNumber.QuadPart, 2)+#10 +
                  'NtBuildNumberAddr: ' + IntToHex(info^.NtBuildNumberAddr.QuadPart,2)+#10 +
                  'KernBase:'+IntToHex(info^.KernBase.QuadPart, 2)+#10 +
                  'Arch: '+ arch +#10 +
                  '...';  // This is the end of a YAML file.
//  return asprintf(// A YAML File describing metadata about this image.
//                  "# PMEM\n"
//                  "---\n"   // The start of the YAML file.
//                  "acquisition_tool: 'WinPMEM " PMEM_VERSION "'\n"
//                  "acquisition_timestamp: %s\n"
//                  "CR3: %#llx\n"
//                  "NtBuildNumber: %#llx\n"
//                  "NtBuildNumberAddr: %#llx\n"
//                  "KernBase: %#llx\n"
//                  "Arch: %s\n"
//                  "...\n",  // This is the end of a YAML file.
//                  time_buffer,
//                  info->CR3.QuadPart,
//                  info->NtBuildNumber.QuadPart,
//                  info->NtBuildNumberAddr.QuadPart,
//                  info->KernBase.QuadPart,
//                  arch
//                  );
end;


{ TWinPmem }

function TWinPmem.copy_memory(start, end_: UInt64): int64;
label error;

var
  large_start : LARGE_INTEGER;
  count : Int64;
  to_write : DWORD;
  bytes_read : DWORD;
  bytes_written : DWORD;
begin
  count := 0;

  if (start > max_physical_memory_) then
  begin
    result := 0;
    exit;
  end;

  // Clamp the region to the top of physical memory.
  if (end_ > max_physical_memory_) then
  begin
    end_ := max_physical_memory_;
  end;

  while(start < end_) do
  begin
    to_write := DWORD(min(buffer_size_, end_ - start));
    bytes_read := 0;
    bytes_written := 0;

    large_start.QuadPart := start;

    if(not SetFilePointerEx(
       fd_, large_start, nil, FILE_BEGIN)) then
//    if not (SetFilePointerEx(
//       fd_, large_start, nil, FILE_BEGIN)) then
    begin
      //LogError(TEXT("Failed to seek in the pmem device.\n"));
      LogInfo('Failed to seek in the pmem device.', mlogError);
      goto error;
    end;

    if( not ReadFile(fd_, buffer_[0], to_write, bytes_read, nil) or
       (bytes_read <> to_write) ) then
    begin
      //LogError(TEXT("Failed to Read memory.\n"));
      LogInfo('Failed to Read memory.', mlogError);
      goto error;
    end;

    if not (WriteFile(out_fd_, buffer_[0], bytes_read,
                  bytes_written, nil) or
       (bytes_written <> bytes_read)) then
    begin
      //LogLastError(TEXT("Failed to write image file"));
      LogInfo('Failed to write image file', mlogError);
      goto error;
    end;

    out_offset := out_offset + bytes_written;

    if((count mod 50) = 0) then
    begin
      // 퍼센트네 //
      //Log(TEXT("\n%02lld%% 0x%08llX "), (start * 100) / max_physical_memory_,
      //    start);
      //LogInfo('0x' + IntToHex(start, 2) + '...', mlogNomal);
    end;
    StatusInfo(start, max_physical_memory_);

    //Log(TEXT("."));

    start := start + to_write;
    Inc(count);

    if FisCancel then
    begin
      OutputDebugString('RAM Capturer Cancel');
      Break;
    end;
  end;

  //Log(TEXT("\n"));
  result := 1;
  Exit;

 error:
  result := 0;

end;

constructor TWinPmem.Create;
begin
  fd_ := (INVALID_HANDLE_VALUE);
  buffer_size_ := (1024*1024);
//  buffer_ := nil;
  suppress_output := 0;
  service_name := (PMEM_SERVICE_NAME);
  max_physical_memory_ := (0);
  mode_ := (PMEM_MODE_AUTO);
  default_mode_ := (PMEM_MODE_AUTO);
  metadata_ := '';
  metadata_len_ := (0);
  driver_filename_ := '';
  driver_is_tempfile_ := (false);
  out_offset := (0);
  pagefile_path_ := '';

  SetLength(buffer_, buffer_size_);
  FillChar(buffer_[0], buffer_size_, 0);
end;

procedure TWinPmem.CreateChildProcess(command: Pchar;
  stdout_wr: THandle);
var
  piProcInfo : PROCESS_INFORMATION;
  siStartInfo : STARTUPINFO;
  bSuccess  : BOOL;
begin
  bSuccess := FALSE;
  // Set up members of the PROCESS_INFORMATION structure.
  ZeroMemory( @piProcInfo, sizeof(PROCESS_INFORMATION) );

  // Set up members of the STARTUPINFO structure.
  // This structure specifies the STDIN and STDOUT handles for redirection.
  ZeroMemory( @siStartInfo, sizeof(STARTUPINFO) );
  siStartInfo.cb := sizeof(STARTUPINFO);
  siStartInfo.hStdInput := 0;
  siStartInfo.hStdOutput := stdout_wr;
  siStartInfo.hStdError := stdout_wr;
  siStartInfo.dwFlags := siStartInfo.dwFlags and STARTF_USESTDHANDLES;

  //Log(L"Launching %s\n", command);
  LogInfo('Launching : ' + StrPas(command), mlogNomal);

  // Create the child process.
  bSuccess := CreateProcess(nil,
                           command,       // command line
                           nil,          // process security attributes
                           nil,          // primary thread security attributes
                           TRUE,          // handles are inherited
                           0,             // creation flags
                           nil,          // use parent's environment
                           nil,          // use parent's current directory
                           siStartInfo,  // STARTUPINFO pointer
                           piProcInfo);  // receives PROCESS_INFORMATION

  // If an error occurs, exit the application.
  if ( not bSuccess ) then
  begin
//    LogLastError(L"Unable to launch process.");
    LogInfo('Unable to launch process.', mlogError);
//    return;
    exit;
  end;

  // Close handles to the child process and its primary thread.
  // Some applications might keep these handles to monitor the status
  // of the child process, for example.
  CloseHandle(piProcInfo.hProcess);
  CloseHandle(piProcInfo.hThread);
  CloseHandle(stdout_wr);

end;

function TWinPmem.create_output_file(output_filename: string): int64;
var
  status : Int64;
  szoutput_filename : string;
begin
  status := 1;
  szoutput_filename := output_filename;
  // The special file name of - means we should use stdout.
  if CompareText(szoutput_filename, '-') = 0 then
  begin
    out_fd_ := GetStdHandle(STD_OUTPUT_HANDLE);
    suppress_output := 1;
    status := 1;
    result := status;
    exit;
  end;


  // Create the output file.
  out_fd_ := CreateFile(Pchar(output_filename),
                       GENERIC_WRITE,
                       FILE_SHARE_READ,
                       nil,
                       CREATE_ALWAYS,
                       FILE_ATTRIBUTE_NORMAL,
                       0);

  if (out_fd_ = INVALID_HANDLE_VALUE) then
  begin
    //LogError(TEXT("Unable to create output file."));
    LogInfo('Unable to create output file.', mlogError);
    status := -1;
    result := status;
    exit;
  end;

end;

destructor TWinPmem.Destroy;
begin
  if (fd_ <> INVALID_HANDLE_VALUE) then
  begin
    CloseHandle(fd_);
  end;

  SetLength(buffer_, 0);

//  if (driver_filename_ and driver_is_tempfile_) {
//    free(driver_filename_);
//  }
//  if (driver_filename_  <> nil) and driver_is_tempfile_ then
//  begin
//    FreeMemory(driver_filename_);
//  end;
  inherited;
end;

//function TWinPmem.extract_driver(driver_filename: Pchar): Int64;
//begin
//  set_driver_filename(driver_filename);
//  Result := extract_driver();
//end;
//
//function TWinPmem.extract_driver: Int64;
//label error;
//begin
//
//end;

//function TWinPmem.extract_file_(resource_id: Int64; filename: string): int64;
//begin
//// 파일 꺼내는거 //
//end;

function TWinPmem.install_driver: int64;
label error;
label service_error;
var
  scm, service : SC_HANDLE;
  status : Int64;
  psTemp : Pchar;
begin
  status := -1;

  uninstall_driver(false);

  scm := OpenSCManager(nil, nil, SC_MANAGER_CREATE_SERVICE);
  if (scm = 0) then
  begin
    //LogError(TEXT("Can not open SCM. Are you administrator?\n"));
    LogInfo('Can not open SCM. Are you administrator?', mlogError);
    goto error;
  end;

  service := CreateService(scm,
                          service_name,
                          service_name,
                          SERVICE_ALL_ACCESS,
                          SERVICE_KERNEL_DRIVER,
                          SERVICE_DEMAND_START,
                          SERVICE_ERROR_NORMAL,
                          Pchar(driver_filename_),
                          nil,
                          nil,
                          nil,
                          nil,
                          nil);

  if (GetLastError() = ERROR_SERVICE_EXISTS) then
  begin
    service := OpenService(scm, service_name, SERVICE_ALL_ACCESS);
  end;

  if (service = 0) then
  begin
    goto error;
  end;

  psTemp := nil;
  if (not StartService(service, 0, psTemp)) then
  begin
    if (GetLastError() <> ERROR_SERVICE_ALREADY_RUNNING) then
    begin
      //LogError(TEXT("Error: StartService(), Cannot start the driver.\n"));
      LogInfo('Cannot start the driver.', mlogError);
      goto service_error;
    end;
  end;

  //Log(L"Loaded Driver %s.\n", driver_filename_);
  //LogInfo('Loaded Driver : ' + driver_filename_);
  LogInfo('Loaded Driver', mlogNomal);

  fd_ := CreateFile(PChar('\\.\' +PMEM_DEVICE_NAME),
                   // Write is needed for IOCTL.
                   GENERIC_READ or GENERIC_WRITE,
                   FILE_SHARE_READ or FILE_SHARE_WRITE,
                   nil,
                   OPEN_EXISTING,
                   FILE_ATTRIBUTE_NORMAL,
                   0);

  if(fd_ = INVALID_HANDLE_VALUE) then
  begin
    //LogError(TEXT("Can not open raw device."));
    LogInfo('Can not open raw device.', mlogError);
    status := -1;

  end
  else begin
    status := 1;
  end;

 service_error:
 begin
  CloseServiceHandle(service);
  CloseServiceHandle(scm);
 end;

 error:
 begin
  // Only remove the driver file if it was a temporary file.
    if (driver_is_tempfile_) then
    begin
      //Log(L"Deleting %s\n", driver_filename_);
      //DeleteFile(PChar(driver_filename_));
    end;
 end;

 result := status;
end;

procedure TWinPmem.LogInfo(AMsg: string; ALogType : TpMemLogType);
begin
  if Assigned(FonLogMessage) then
  begin
    FonLogMessage(self, AMsg, ALogType);
  end
  else begin
    OutputDebugString(PChar(AMsg));
  end;
end;

//procedure TWinPmem.Log(const Msg: Pchar; Args: array of const);
//begin
//
//end;
//
//procedure TWinPmem.LogError(Msg: Pchar);
//begin
//
//end;
//
//procedure TWinPmem.LogLastError(Msg: Pchar);
//begin
//
//end;

function TWinPmem.pad(length: int64): Int64;
label error;

var
  count, start : Int64;
  to_write  : DWORD;
  bytes_written : DWORD;
begin
  count := 1;
  start := 0;

  ZeroMemory(@buffer_[0], buffer_size_);

  while(start < length) do
  begin
    to_write := DWord(Min(buffer_size_, length - start));
    bytes_written := 0;

    if(not WriteFile(out_fd_, buffer_[0],
                  to_write, bytes_written, nil) or (bytes_written <> to_write)) then
    begin
      //LogLastError(TEXT("Failed to write padding"));
      LogInfo('Failed to write padding', mlogError);
      goto error;
    end;

    out_offset := out_offset + bytes_written;

    start := start + bytes_written;
    //Log(TEXT("."));

    if( not (count mod 60 = 0)) then
    begin
      //Log(TEXT("\n0x%08llX "), start);
      //LogInfo('padding : ' + IntToHex(start, 2), mlogNomal);
    end;

    count := count + 1;

    if FisCancel then Break;


  end;

  result := 1;
  exit;

 error :
 begin
  result := 0;
 end;
end;

// Display information about the memory geometry.
procedure TWinPmem.print_memory_info;
var
info : PmemMemoryInfo;
i : int64;
size : DWORD;
installed_memory : ULONGLONG;
statusx : MEMORYSTATUSEX ;
begin

  size := 0;
  // Get the memory ranges.
  if( not DeviceIoControl(fd_, PMEM_INFO_IOCTRL, nil, 0, @info,
                      sizeof(info), size, nil)) then
  begin
   // LogError(TEXT("Failed to get memory geometry,"));
    LogInfo('Failed to get memory geometry,', mlogError);
    exit;
  end;


  //Log(TEXT("CR3: 0x%010llX\n %d memory ranges:\n"), info.CR3.QuadPart,
  //    info.NumberOfRuns);
  //LogInfo('CR3: '+IntToHex(info.CR3.QuadPart, 2)+' - '+IntToStr(int64(info.NumberOfRuns))+'  memory ranges', mlogNomal);

  i := 0;
  while i < info.NumberOfRuns.QuadPart do
  begin

    //Log(TEXT("Start 0x%08llX - Length 0x%08llX\n"), info.Run[i].start,
    //  info.Run[i].length);
    LogInfo('Start '+inttostr(info.Run[i].start)+' - Length ' + IntToStr(info.Run[i].length), mlogNomal);
    max_physical_memory_ := info.Run[i].start + info.Run[i].length;
    inc(i);
  end;

  // When using the pci introspection we dont know the maximum physical memory,
  // we therefore make a guess based on the total ram in the system.
  //Log(TEXT("Acquitision mode "));
  //LogInfo('Acquitision mode ', mlogNomal);
  print_mode_(mode_);
  //Log(TEXT("\n"));

  if (mode_ = PMEM_MODE_PTE_PCI) then
  begin
    installed_memory := 0;

    statusx.dwLength := sizeof(statusx);

    if (GlobalMemoryStatusEx (statusx)) then
    begin
      max_physical_memory_ := Trunc(statusx.ullTotalPhys * 3 / 2);
      LogInfo('Max physical memory guessed at ' + IntToHex(max_physical_memory_, 2), mlogNomal);
      //Log(TEXT("Max physical memory guessed at 0x%08llX\n"),
      //         max_physical_memory_);

    end
    else begin
//      Log(TEXT("Unable to guess max physical memory. Just Ctrl-C when ")
//          TEXT("done.\n"));
    end;

  end;
  //Log(TEXT("\n"));



end;

procedure TWinPmem.print_mode_(mode: Uint32);
begin
  case mode of
    PMEM_MODE_IOSPACE:
    begin
      //Log(TEXT("MMMapIoSpace"));
      //LogInfo('MMMapIoSpace', mlogNomal);
    end;
    PMEM_MODE_PHYSICAL:
    begin
      //Log(TEXT("\\\\.\\PhysicalMemory"));
      //LogInfo('\\.\PhysicalMemory', mlogNomal);
    end;

    PMEM_MODE_PTE:
    begin
      //Log(TEXT("PTE Remapping"));
      //LogInfo('PTE Remapping', mlogNomal);
    end;
    PMEM_MODE_PTE_PCI:
    begin
      //Log(TEXT("PTE Remapping with PCI introspection"));
      //LogInfo('PTE Remapping with PCI introspection', mlogNomal);
    end;
    else begin
      //Log(TEXT("Unknown"));
      //LogInfo('Unknown', mlogNomal);
    end;
  end;
end;

procedure TWinPmem.SetCancel;
begin
  FisCancel := true;
end;

function TWinPmem.set_acquisition_mode(mode: UInt32): int64;
var
  size : DWORD;
begin
  size := 0;

  if (mode = PMEM_MODE_AUTO) then
  begin
    mode := default_mode_;
  end;

  // Set the acquisition mode.
  if(not DeviceIoControl(fd_, PMEM_CTRL_IOCTRL, @mode, 4, nil, 0,
                      size, nil)) then
  begin
    //Log(TEXT("Failed to set acquisition mode %lu "), mode);
    LogInfo('Failed to set acquisition mode : ' + IntToStr(mode), mlogNomal);
    //LogLastError(L"");
    print_mode_(mode);
    //Log(TEXT("\n"));
    result := -1;
    exit;
  end;

  mode_ := mode;
  result := 1;
end;

procedure TWinPmem.set_driver_filename(driver_filename: string);
begin
  driver_filename_ := driver_filename;
(*
//  DWORD res;

//  if(driver_filename_) {
//    free(driver_filename_);
//    driver_filename_ = NULL;
//  };
//
//  if (driver_filename) {
//    driver_filename_ = (TCHAR * )malloc(MAX_PATH * sizeof(TCHAR));
//    if (driver_filename_) {
//      res = GetFullPathName(driver_filename, MAX_PATH,
//                            driver_filename_, NULL);
//    };
//  };

*)
end;

procedure TWinPmem.set_pagefile_path(pagefile_path: string);
begin
(*
  DWORD res;

  if(pagefile_path_) {
    free(pagefile_path_);
    pagefile_path_ = NULL;
  };

  if (path) {
    pagefile_path_ = (TCHAR * )malloc(MAX_PATH * sizeof(TCHAR));
    if (pagefile_path_) {
      res = GetFullPathName(path, MAX_PATH,
                            pagefile_path_, NULL);
    };

    // Split at the drive letter. C:\pagefile.sys
    pagefile_path_[2] = 0;
  };
*)

  pagefile_path_ := pagefile_path;
end;

// Turn on write support in the driver.
function TWinPmem.set_write_enabled: int64;
var
  mode : UInt32;
  size : DWORD;
begin
  mode := 0;
  size := 0;
  if( not DeviceIoControl(fd_, PMEM_WRITE_ENABLE, @mode, 4, nil, 0,
                      size, nil)) then
  begin
    //LogError(TEXT("Failed to set write mode. Maybe these drivers do ")
    //         TEXT("not support this mode?\n"));
    LogInfo('Failed to set write mode. Maybe these drivers do not support this mode?', mlogError);
    //return -1;
    result := -1;
    exit;
  end;

  //Log(TEXT("Write mode enabled! Hope you know what you are doing.\n"));
  LogInfo('Write mode enabled! Hope you know what you are doing.', mlogNomal);
  result := 1;
end;

procedure TWinPmem.StatusInfo(ACurrent, ATotal: int64);
begin
  if Assigned(FonStatus) then
  begin
    FonStatus(Self, ACurrent, ATotal);
  end;
end;

function TWinPmem.uninstall_driver(AisLog : boolean): int64;
var
  scm, service : SC_HANDLE;
  ServiceStatus : SERVICE_STATUS;
begin
  Result := 0;
  scm := OpenSCManager(nil, nil, SC_MANAGER_CREATE_SERVICE);

  if (scm = 0) then exit;

  service := OpenService(scm, service_name, SERVICE_ALL_ACCESS);

  if (service <> 0) then
  begin
    ControlService(service, SERVICE_CONTROL_STOP, ServiceStatus);
    DeleteService(service);
    CloseServiceHandle(service);
    Result := 1;

    if AisLog then
    begin
      LogInfo('Driver Unloaded.', mlogNomal);
    end;
  end
  else begin

  end;


  CloseServiceHandle(scm);
  //Log(TEXT("Driver Unloaded.\n"));

  //Result := 0;

end;

function TWinPmem.write_coredump: int64;
label exitgoto;
var
  info : PmemMemoryInfo;
  size : DWORD;
  i : Int64;
  status : Int64;
begin

  FisCancel := false;
  // Somewhere to store the info from the driver;
  size := 0;
  i := 0;
  status := -1;

  if(out_fd_=INVALID_HANDLE_VALUE) then
  begin
    //LogError(TEXT("Must open an output file first."));
    LogInfo('Must open an output file first.', mlogError);
    goto exitgoto;
  end;

  RtlZeroMemory(@info, sizeof(info));

  // Get the memory ranges.
  if( not DeviceIoControl(fd_, PMEM_INFO_IOCTRL, nil, 0, @info,
                      sizeof(info), size, nil)) then
  begin
    //LogError(TEXT("Failed to get memory geometry,"));
    LogInfo('Failed to get memory geometry,', mlogError);
    status := -1;
    goto exitgoto;
  end;

  //Log(TEXT("Will write an elf coredump.\n"));
  LogInfo('Will write an elf coredump.', mlogNomal);
  print_memory_info();

  if(write_coredump_header_(@info) = 0) then
  begin
    //LogInfo('write_coredump_header_ FALSE');
    goto exitgoto;
  end;

  while i < info.NumberOfRuns.QuadPart do
  begin
    //for(i=0; i < info.NumberOfRuns.QuadPart; i++) {
    copy_memory(info.Run[i].start, info.Run[i].start + info.Run[i].length);

    Inc(i);
    if FisCancel then Break;
  end;

  // Remember where we wrote the last metadata header.
  last_header_offset_ := out_offset;

  if( not WriteFile(out_fd_, metadata_[1], metadata_len_, metadata_len_, nil)) then
  begin
    //LogError(TEXT("Can not write metadata.\n"));
    LogInfo('Can not write metadata.', mlogError);
  end;

  out_offset := out_offset + metadata_len_;

  if not FisCancel  then
  begin
    if(pagefile_path_ <> '') then
    begin
      write_page_file();
    end;
  end;

 exitgoto :
 begin
   CloseHandle(out_fd_);
   out_fd_ := INVALID_HANDLE_VALUE;
   Result := status;
 end;

end;

function TWinPmem.write_coredump_header_(info: PPmemMemoryInfo): int64;
label error;
var
  header : Elf64_Ehdr;
  header_size : DWORD;
  pheader : Elf64_Phdr;
  i : Integer;
  file_offset : uint64;
  range : PHYSICAL_MEMORY_RANGE;
begin
  i := 0;

  if(metadata_ = '') then
  begin
    metadata_ := store_metadata_(info);
    if (metadata_ = '') then goto error;

    metadata_len_ := Length(metadata_);
  end;

  // Where we start writing data.
  file_offset := (
      sizeof(Elf64_Ehdr) +
      // One Phdr for each run and one for the metadata.
      (info^.NumberOfRuns.QuadPart + 1) * sizeof(Elf64_Phdr));

  // All values that are unset will be zero
  RtlZeroMemory(@header, sizeof(Elf64_Ehdr));

  // We create a 64 bit core dump file with one section
  // for each physical memory segment.
  header.ident[0] := ELFMAG0;
  header.ident[1] := Ord(ELFMAG1);
  header.ident[2] := Ord(ELFMAG2);
  header.ident[3] := Ord(ELFMAG3);
  header.ident[4] := ELFCLASS64;
  header.ident[5] := ELFDATA2LSB;
  header.ident[6] := EV_CURRENT;
  header.type_    := ET_CORE;
  header.machine  := EM_X86_64;
  header.version  := EV_CURRENT;
  header.phoff    := sizeof(Elf64_Ehdr);
  header.ehsize   := sizeof(Elf64_Ehdr);
  header.phentsize:= sizeof(Elf64_Phdr);

  // One more header for the metadata.
  header.phnum    := uint32(info^.NumberOfRuns.QuadPart + 1);
  header.shentsize:= sizeof(Elf64_Shdr);
  header.shnum    := 0;

  header_size := sizeof(header);
  if(not WriteFile(out_fd_, header, header_size, header_size, nil)) then
  begin
    LogInfo('Failed to write header', mlogError);
    //LogLastError(TEXT("Failed to write header"));
    goto error;
  end;

  out_offset := out_offset + header_size;

  i := 0;
  while i<info^.NumberOfRuns.QuadPart do
  begin
    range := info^.Run[i];

    RtlZeroMemory(@pheader, sizeof(Elf64_Phdr));

    pheader.type_ := PT_LOAD;
    pheader.paddr := range.start;
    pheader.memsz := range.length;
    pheader.align := PAGE_SIZE;
    pheader.flags := PF_R;
    pheader.off := file_offset;
    pheader.filesz := range.length;

    // Move the file offset by the size of this run.
    file_offset := file_offset + range.length;

    header_size := sizeof(pheader);
    if(not WriteFile(out_fd_, pheader, header_size, header_size, nil)) then
    begin
      //LogLastError(TEXT("Failed to write header"));
      LogInfo('Failed to write header', mlogError);
      goto error;
    end;

    out_offset := out_offset + header_size;
    inc(i);
  end;

  // Add a header for the metadata so it can be easily found in the file.
  RtlZeroMemory(@pheader, sizeof(Elf64_Phdr));
  pheader.type_ := PT_PMEM_METADATA;

  // The metadata section will be written at the end of the
  pheader.off := file_offset;
  pheader.filesz := metadata_len_;

  header_size := sizeof(pheader);
  if(not WriteFile(out_fd_, pheader, header_size, header_size, nil)) then
  begin
    //LogLastError(TEXT("Failed to write header"));
    LogInfo('Failed to write header', mlogError);
    goto error;
  end;

  out_offset := out_offset + header_size;

  result := 1;
  Exit;

 error:
 begin
    Result := 0;
 end;
end;

// Copy the pagefile to the current place in the output file.
procedure TWinPmem.write_page_file;
label error;
var
  pagefile_offset : UInt64;
  count : Integer;
  total_mb_read : Integer;
  path : array [0..MAX_PATH] of char;
  filename : array [0..MAX_PATH] of char;

  saAttr : SECURITY_ATTRIBUTES;
  stdout_rd : THandle;
  stdout_wr : THandle;
  command_line : string;
  bytes_read : DWORD;
  bytes_written : DWORD;
  metadata : string;
  metadata_len  : DWORD;
begin
  pagefile_offset := out_offset;
  count := 0;
  total_mb_read := 0;

  if(GetTempPath(MAX_PATH, path) = 0) then
  begin
    //LogError(TEXT("Unable to determine temporary path."));
    goto error;
  end;

  // filename is now the random path.
  GetTempFileName(path, Pchar('fls'), 0, filename);

  //Log(L"Extracting fcat to %s\n", filename);
//  if(extract_file_(WINPMEM_FCAT_EXECUTABLE, filename)<0) then
//  begin
//    goto error;
//  end;


  stdout_rd := 0;
  stdout_wr := 0;

  saAttr.nLength := sizeof(SECURITY_ATTRIBUTES);
  saAttr.bInheritHandle := TRUE;
  saAttr.lpSecurityDescriptor := nil;

  // Create a pipe for the child process's STDOUT.
  if (not CreatePipe(stdout_rd, stdout_wr, @saAttr, 0)) then
  begin
//    LogLastError(L"StdoutRd CreatePipe");
    LogInfo('StdoutRd CreatePipe', mlogError);
    goto error;
  end;

  // Ensure the read handle to the pipe for STDOUT is not inherited.
  SetHandleInformation(stdout_rd, HANDLE_FLAG_INHERIT, 0);

  command_line := Format('%s %s \\.\%s', [strpas(filename),
    ExtractFileName(pagefile_path_),
    ExcludeTrailingPathDelimiter(ExtractFileDrive(pagefile_path_))]);
  //TCHAR *command_line = aswprintf(L"%s %s \\\\.\\%s", filename,
  //                                &pagefile_path_[3],
  //                                pagefile_path_);

  CreateChildProcess(Pchar(command_line), stdout_wr);
  //Log(L"Preparing to read pagefile.\n");
  while (true) do
  begin
    bytes_read := buffer_size_;
    bytes_written := 0;

    if(not ReadFile(stdout_rd, buffer_[0], bytes_read, bytes_read, nil))  then
    begin
      break;
    end;

    count := count + bytes_read;
    if (count > 1024 * 1024) then
    begin
      count := count - (1024*1024);
      if (total_mb_read mod 50 = 0) then
      begin
        //Log(L"\n% 5dMb ", total_mb_read);
        LogInfo(IntToStr(total_mb_read) + ' 5dMb ', mlogNomal);
      end;

      total_mb_read :=  total_mb_read + 1;
      //Log(L".");
    end;


    if(WriteFile(out_fd_, buffer_[0], bytes_read, bytes_written, nil) or
       (bytes_written <> bytes_read)) then
    begin
      //LogLastError(L"Failed to write image file");
      LogInfo('Failed to write image file', mlogError);
      goto error;
    end;

    out_offset := out_offset + bytes_written;
  end;

 error:
 begin
  //  Log(L"\n");

  // Write another metadata header.
  metadata :=
  '# PMEM'+#10 +
  '---'+#10 +
  'PreviousHeader: ' + IntToStr(last_header_offset_) + #10 +
  'PagefileOffset: '+ IntToStr(pagefile_offset) + #10 +
  'PagefileSize: ' + IntToStr(out_offset - pagefile_offset)+#10 +
  '...'+#10;

   metadata_len := length(metadata) * 2;
   bytes_written := 0;

  if(not WriteFile(out_fd_, metadata[1], metadata_len, bytes_written, nil) or
     (bytes_written <> metadata_len)) then
  begin
    //LogLastError(L"Failed to write image file");
  end;

  out_offset := out_offset + bytes_written;
 end;

   if filename <> nil then
   begin
      if fileexists(StrPas(filename)) then
      begin
        DeleteFile(filename);
      end;
   end;


end;

function TWinPmem.write_raw_image: int64;
label exitgoto;

var
  info : PmemMemoryInfo;
  size : DWORD;
  i : Int64;
  status : Int64;
  offset : Int64;
begin
  FisCancel := false;
  //struct PmemMemoryInfo info;
  size := 0;
  i := 0;
  status := -1;

  if(out_fd_=INVALID_HANDLE_VALUE) then
  begin
    //LogError(TEXT("Must open an output file first."));
    LogInfo('Must open an output file first.', mlogError);
    goto exitgoto;
  end;

  RtlZeroMemory(@info, sizeof(info));

  // Get the memory ranges.
  if(not DeviceIoControl(fd_, PMEM_INFO_IOCTRL, nil, 0, @info,
                      sizeof(info), size, nil)) then
  begin
    //LogError(TEXT("Failed to get memory geometry,"));
    LogInfo('Failed to get memory geometry,', mlogError);
    status := -1;
    goto exitgoto;
  end;

//  Log(TEXT("Will generate a RAW image\n"));
  print_memory_info();

  offset := 0;

  while i < info.NumberOfRuns.QuadPart do
  begin
    if(info.Run[i].start > offset) then
    begin
      //Log(TEXT("Padding from 0x%08llX to 0x%08llX\n"), offset, info.Run[i].start);
      LogInfo('Padding from '+IntToHex(offset, 2)+' to ' + IntToHex(info.Run[i].start, 2), mlogNomal);
      if(pad(info.Run[i].start - offset) = 0) then
      begin
        goto exitgoto;
      end;
    end;

    if FisCancel then Break;


    copy_memory(info.Run[i].start, info.Run[i].start + info.Run[i].length);
    offset := info.Run[i].start + info.Run[i].length;
    Inc(i);

    if FisCancel then Break;
    
  end;

  // All is well.
  status := 1;

  exitgoto:
  begin
    CloseHandle(out_fd_);
    out_fd_ := INVALID_HANDLE_VALUE;
    result := status;

    if FisCancel then
    begin

    end
    else begin
      StatusInfo(max_physical_memory_, max_physical_memory_);
    end;
  end;
end;

//{ TWinPmem64 }
//
//constructor TWinPmem64.Create;
//begin
//  inherited;
//  default_mode_ := PMEM_MODE_PTE;
//end;
//
//function TWinPmem64.extract_driver: Int64;
//begin
//// 64 bit drivers use PTE acquisition by default.
//  default_mode_ := PMEM_MODE_PTE;
//
//  if (driver_filename_ = '') then
//  begin
////    TCHAR path[MAX_PATH + 1];
////    TCHAR filename[MAX_PATH + 1];
////
////    // Gets the temp path env string (no guarantee it's a valid path).
////    if(!GetTempPath(MAX_PATH, path)) {
////      LogError(TEXT("Unable to determine temporary path."));
////      goto error;
////    }
////
////    GetTempFileName(path, service_name, 0, filename);
////    set_driver_filename(filename);
////
////    driver_is_tempfile_ = true;
//  end;
//
////  Log(L"Extracting driver to %s\n", driver_filename_);
//
//  result := extract_file_(WINPMEM_64BIT_DRIVER, driver_filename_);
//
//end;
//
//{ TWinPmem32 }
//
//constructor TWinPmem32.Create;
//begin
//  inherited;
//  default_mode_ := PMEM_MODE_PHYSICAL;
//end;
//
//function TWinPmem32.extract_driver: Int64;
//begin
//// 32 bit acquisition defaults to physical device.
//  default_mode_ := PMEM_MODE_PHYSICAL;
//
//  if (driver_filename_ = '') then
//  begin
////    TCHAR path[MAX_PATH + 1];
////    TCHAR filename[MAX_PATH + 1];
////
////    // Gets the temp path env string (no guarantee it's a valid path).
////    if(!GetTempPath(MAX_PATH, path)) {
////      LogError(TEXT("Unable to determine temporary path."));
////      goto error;
////    }
////
////    GetTempFileName(path, service_name, 0, filename);
////    set_driver_filename(filename);
////
////    driver_is_tempfile_ = true;
//  end;
//
////  Log(L"Extracting driver to %s\n", driver_filename_);
//
//  result := extract_file_(WINPMEM_32BIT_DRIVER, driver_filename_);
//
//
//end;

initialization
  PMEM_CTRL_IOCTRL := CTL_CODE($22, $101, 0, 3);
  PMEM_WRITE_ENABLE := CTL_CODE($22, $102, 0, 3);
  PMEM_INFO_IOCTRL := CTL_CODE($22, $103, 0, 3);

end.

