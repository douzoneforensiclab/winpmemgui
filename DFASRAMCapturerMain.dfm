object DFASRAMCapturerMainForm: TDFASRAMCapturerMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Argos DFAS RAM Capturer'
  ClientHeight = 317
  ClientWidth = 586
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 11
    Top = 16
    Width = 51
    Height = 13
    Caption = #44221#47196' '#49444#51221
  end
  object progressbar: TRzProgressBar
    Left = 11
    Top = 77
    Width = 564
    Height = 20
    BorderOuter = fsFlat
    BorderWidth = 0
    InteriorOffset = 0
    PartsComplete = 0
    Percent = 0
    ThemeAware = False
    TotalParts = 0
  end
  object lblStatus: TLabel
    Left = 539
    Top = 60
    Width = 36
    Height = 13
    Alignment = taRightJustify
    Caption = '( 0 / 0 )'
  end
  object edtExportFolder: TEdit
    Left = 11
    Top = 35
    Width = 537
    Height = 21
    ImeName = 'Microsoft IME 2010'
    MaxLength = 500
    TabOrder = 0
  end
  object mmoLog: TMemo
    Left = 11
    Top = 104
    Width = 564
    Height = 163
    BevelInner = bvNone
    BevelOuter = bvNone
    Color = clBtnFace
    ImeName = 'Microsoft IME 2010'
    ReadOnly = True
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 339
    Top = 282
    Width = 75
    Height = 25
    Caption = #49884#51089
    TabOrder = 2
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 420
    Top = 282
    Width = 75
    Height = 25
    Caption = #52712#49548
    TabOrder = 3
    OnClick = btnCancelClick
  end
  object btnClose: TButton
    Left = 501
    Top = 282
    Width = 75
    Height = 25
    Caption = #45803#44592
    TabOrder = 4
    OnClick = btnCloseClick
  end
  object btnFolderselect: TButton
    Left = 551
    Top = 32
    Width = 25
    Height = 24
    Caption = '...'
    TabOrder = 5
    OnClick = btnFolderselectClick
  end
  object SaveDialog1: TSaveDialog
    FileName = 'E:\1.Src\21.10_DFAS_PRO_v1.1\Source2\SubUtils\RAM_Capturer\'#12601
    Filter = 'RAW RAM Capturer File|*.raw'
    Left = 331
    Top = 128
  end
end
