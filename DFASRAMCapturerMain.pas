unit DFASRAMCapturerMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, StdCtrls, RzPrgres, winpmem, GTForm;

type
  TDFASRAMCapturerMainForm = class(TGTForm)
    Label1: TLabel;
    edtExportFolder: TEdit;
    SaveDialog1: TSaveDialog;
    mmoLog: TMemo;
    btnOk: TButton;
    btnCancel: TButton;
    btnClose: TButton;
    progressbar: TRzProgressBar;
    lblStatus: TLabel;
    btnFolderselect: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnCloseClick(Sender: TObject);
    procedure btnFolderselectClick(Sender: TObject);
  private
    { Private declarations }
    FWinpem : TWinPmem;

    FisCancel : boolean;

    FTickCount : Cardinal;
    FisRunning : boolean;

    procedure onLogMessage(sender : TObject; AValue : string; ALogType : TpMemLogType);
    procedure onStatus(sender : TObject; ACurrent, ATotal : Int64);
    procedure onMaxMemoryStatus(sender : TObject; ATotal : Int64);
  public
    { Public declarations }
  end;

var
  DFASRAMCapturerMainForm: TDFASRAMCapturerMainForm;

implementation
uses gnugettext;

{$R *.dfm}

function FormatByteSize(bytes: Int64): string;
var
  B : UInt64;
  KB : UInt64;
  MB : UInt64;
  GB : UInt64;
  TB : UInt64;
begin
//  result := IntToStr(bytes);
  B := 1;
  KB := 1024 * B;
  MB := 1024 * KB;
  GB := 1024 * MB;
  TB := 1024 * GB;

  if bytes <= 0 then
  begin
    result := '0 byte'  ;
    Exit;
  end;

  if bytes > TB then
    result := FormatFloat('#.## TB', bytes / TB)
  else
    if bytes > GB then
      result := FormatFloat('#.## GB', bytes / GB)
    else
      if bytes > MB then
        result := FormatFloat('#.## MB', bytes / MB)
      else
        if bytes > KB then
          result := FormatFloat('#.## KB', bytes / KB)
        else
          result := FormatFloat('#.## bytes', bytes) ;

end;

procedure SetExt(var AFileName : string; ASrcExt : string; ADestExt : string);
begin
  if ASrcExt = '' then
  begin
    AFileName := AFileName + ADestExt;
  end
  else begin
    if CompareText(ASrcExt, ADestExt) <> 0 then
    begin
      AFileName := AFileName + ADestExt;
    end;
  end;
end;

procedure TDFASRAMCapturerMainForm.btnCancelClick(Sender: TObject);
begin
  if MessageBox(self.Handle, PChar(_('진행 중인 작업을 취소 하시겠습니까?')), Pchar(_('안내')), MB_YESNO + MB_ICONQUESTION ) = ID_YES then
  begin
    FisCancel := true;
  end;
end;

procedure TDFASRAMCapturerMainForm.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TDFASRAMCapturerMainForm.btnFolderselectClick(Sender: TObject);
var
  szExt : string;
  szFileName : string;
begin
  SaveDialog1.FileName := edtExportFolder.Text;
  if SaveDialog1.Execute then
  begin
    szExt := ExtractFileExt(SaveDialog1.FileName);
    szFileName := SaveDialog1.FileName;
    SetExt(szFileName, szExt, '.raw');
    edtExportFolder.Text := szFileName;
  end;
end;

procedure TDFASRAMCapturerMainForm.btnOkClick(Sender: TObject);
var
//  pwinpmem : TWinPmem;
  sys_info : SYSTEM_INFO;
  ret : Integer;
  mode : Integer;
  coredump_output : boolean;
  status : Int64;
begin
  if trim(edtExportFolder.Text) = '' then
  begin
    MessageBox(self.Handle, PChar(_('저장 경로를 설정하십시요.')), Pchar(_('안내')), MB_ICONINFORMATION);
    edtExportFolder.SetFocus;
    exit;
  end;

  edtExportFolder.Text := trim(edtExportFolder.Text);

  lblStatus.Caption := '( 0 / 0 )';

  FisRunning := true;

  FTickCount := GetTickCount;
  progressbar.Percent := 0;
  FisCancel := False;
  ForceDirectories(ExtractfilePath(edtExportFolder.text));
  mmoLog.Clear;

  btnOk.Enabled := false;
  btnCancel.Enabled := true;
  btnClose.Enabled := False;

  ZeroMemory(@sys_info, sizeof(sys_info));

  GetNativeSystemInfo(sys_info);
  FWinpem := TWinPmem.Create;
  FWinpem.onLogMessage := onLogMessage;
  FWinpem.onStatus := onStatus;
  mode := PMEM_MODE_AUTO;

  case sys_info.wProcessorArchitecture OF
    PROCESSOR_ARCHITECTURE_AMD64:
    begin
      FWinpem.set_driver_filename(ExtractFilePath(ParamStr(0)) +'winpmem_x64.sys');
      FWinpem.DefaultMode := PMEM_MODE_PTE;
    end;

    PROCESSOR_ARCHITECTURE_INTEL:
    begin
      FWinpem.set_driver_filename(ExtractFilePath(ParamStr(0)) + 'winpmem_x86.sys');
      FWinpem.DefaultMode := PMEM_MODE_PHYSICAL;
    end;
  end;


  // 페이지 파일 분석도 한다면 //
  //FWinpem.set_pagefile_path('c:\pagefile.sys');
  // Produce an ELF core dump.
  coredump_output := False;

  ret := FWinpem.create_output_file(edtExportFolder.text);

  if ret > 0 then
  begin
    ret := FWinpem.install_driver;
    if ret > 0 then
    begin
      ret  := FWinpem.set_acquisition_mode(mode);
      if ret > 0 then
      begin
        if coredump_output then
        begin
          status := FWinpem.write_coredump;
        end
        else begin
          status := FWinpem.write_raw_image;
        end;
      end;
    end;

    FWinpem.uninstall_driver(true);

    if FisCancel then
    begin
      mmoLog.Lines.Add('RAM Capture Cancel.');
    end
    else begin
      mmoLog.Lines.Add('RAM Capture finished.');
    end;



  end;

  FreeAndNil(FWinpem);

  btnOk.Enabled := True;
  btnCancel.Enabled := false;
  btnClose.Enabled := True;
  FisRunning := false;
end;

procedure TDFASRAMCapturerMainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if FisRunning then
  begin
    CanClose := false;
    if MessageBox(self.Handle, PChar(_('진행 중인 작업을 취소 하시겠습니까?')), Pchar(_('안내')), MB_YESNO + MB_ICONQUESTION ) = ID_YES then
    begin
      FisCancel := true;
    end;
  end
  else begin
    CanClose := true;
  end;

end;

procedure TDFASRAMCapturerMainForm.FormCreate(Sender: TObject);
begin
  edtExportFolder.Text := ExtractFilePath(ParamStr(0)) + 'ARGOSDFAS_' + FormatDateTime('yyyymmddhhnnss', now) + '.raw';
  FTickCount := 0;
  btnCancel.Enabled := false;
end;


procedure TDFASRAMCapturerMainForm.onLogMessage(sender: TObject; AValue: string; ALogType : TpMemLogType);
begin
  mmoLog.Lines.Add(AValue);
  Application.ProcessMessages;
end;

procedure TDFASRAMCapturerMainForm.onMaxMemoryStatus(sender: TObject;
  ATotal: Int64);
begin
  mmoLog.Lines.Add('Total Physical Memory Size : ' + FormatByteSize(ATotal) );
end;

procedure TDFASRAMCapturerMainForm.onStatus(sender: TObject; ACurrent,
  ATotal: Int64);
var
  izPercent : Integer;
  procedure StatusCaption();
  begin
    lblStatus.Caption := Format('( %s / %s )', [FormatByteSize(ACurrent), FormatByteSize(ATotal)]);
  end;
begin
  izPercent := Trunc( ACurrent / ATotal * 100);
  if izPercent <> progressbar.Percent then
  begin
    progressbar.Percent := izPercent;
    Application.ProcessMessages;
    StatusCaption();
  end;

  if (GetTickCount - FTickCount) > 800 then
  begin
    Application.ProcessMessages;
    FTickCount := GetTickCount;
    StatusCaption();
  end;

  if FisCancel then
  begin
    TWinPmem(sender).SetCancel;
  end;

end;

end.
