program DFASRAMCapturer;

uses
  Forms,
  SysUtils,
  windows,
  DFASRAMCapturerMain in 'DFASRAMCapturerMain.pas' {DFASRAMCapturerMainForm},
  elf in 'src\elf.pas',
  WinIoCtl in 'src\WinIoCtl.pas',
  winpmem in 'src\winpmem.pas',
  gnugettext in 'src\GTLanguage\gnugettext.pas',
  GTForm in 'src\GTLanguage\GTForm.pas',
  GTLanguageFrame in 'src\GTLanguage\GTLanguageFrame.pas' {GTfraLanguage: TFrame},
  GTLanguageList in 'src\GTLanguage\GTLanguageList.pas',
  GTLanguagesEx in 'src\GTLanguage\GTLanguagesEx.pas',
  common in 'src\common.pas';

{$R *.res}

var
  Mutex :hWnd;
  LngFlag : Integer;
  fraGTLanguage: TGTfraLanguage;
begin

  SysUtils.ShortDateFormat := 'yyyy-mm-dd';
  SysUtils.DateSeparator := '-';

  Mutex := CreateMutex(nil, False, '_DZ_A_R_G_O_S_DFAS_RAMCAPTURER_');


  try
    if (GetLastError <> ERROR_ALREADY_EXISTS) and (Mutex <> 0) then
    begin

      ReportMemoryLeaksOnShutdown := DebugHook <> 0;

      if ParamCount > 0 then
      begin
        LngFlag := StrToIntDef(ParamStr(1), -1);
        LanguageFlag := LngFlag;

        fraGTLanguage := TGTfraLanguage.Create(nil);
        fraGTLanguage.InstalledOnly := true;
        fraGTLanguage.cmbLanguage.ItemIndex := LanguageFlag;
        fraGTLanguage.LanguageSelect;
        fraGTLanguage.Free;

        {
        LanguageFlag := LngFlag;
        pForm := TCaptureOptionForm.Create(nil);
        pForm.fraGTLanguage.LanguageSelect;
        pForm.Free;
        }
      end;

      Application.Initialize;
      Application.Title := 'Argos DFAS RAM Capturer';
      Application.MainFormOnTaskbar := True;
      Application.CreateForm(TDFASRAMCapturerMainForm, DFASRAMCapturerMainForm);
  Application.Run;
    end;
  finally
    CloseHandle(Mutex);
  end;
end.
