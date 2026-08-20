object XICATests: TXICATests
  Left = 344
  Top = 250
  Caption = 'XICA Internal Tests'
  ClientHeight = 445
  ClientWidth = 661
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Label2: TLabel
    Left = 168
    Top = 32
    Width = 35
    Height = 15
    Caption = 'Device'
  end
  object Label3: TLabel
    Left = 156
    Top = 4
    Width = 47
    Height = 15
    Caption = 'Manager'
  end
  object Label4: TLabel
    Left = 176
    Top = 60
    Width = 24
    Height = 15
    Caption = 'Item'
  end
  object btListDevices: TButton
    Left = 6
    Top = 8
    Width = 75
    Height = 25
    Caption = 'List Devices'
    TabOrder = 0
    OnClick = btListDevicesClick
  end
  object Memo1: TMemo
    Left = 0
    Top = 102
    Width = 661
    Height = 343
    Align = alBottom
    TabOrder = 1
  end
  object edDevice: TSpinEdit
    Left = 208
    Top = 25
    Width = 50
    Height = 23
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object panDownload: TPanel
    Left = 281
    Top = 4
    Width = 378
    Height = 44
    TabOrder = 3
    object btDownload: TButton
      Left = 8
      Top = 0
      Width = 75
      Height = 25
      Caption = 'Download'
      TabOrder = 0
      OnClick = btDownloadClick
    end
  end
  object edManager: TSpinEdit
    Left = 208
    Top = 0
    Width = 50
    Height = 23
    MaxValue = 0
    MinValue = 0
    TabOrder = 4
    Value = 0
  end
  object edItem: TSpinEdit
    Left = 208
    Top = 53
    Width = 50
    Height = 23
    MaxValue = 2
    MinValue = 0
    TabOrder = 5
    Value = 0
  end
  object btUI_Select: TButton
    Left = 8
    Top = 40
    Width = 75
    Height = 25
    Caption = 'UI Select'
    TabOrder = 6
    OnClick = btUI_SelectClick
  end
  object btSettings: TButton
    Left = 6
    Top = 71
    Width = 75
    Height = 25
    Caption = 'Settings'
    TabOrder = 7
    OnClick = btSettingsClick
  end
end
