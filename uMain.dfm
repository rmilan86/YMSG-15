object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'YMSG15'
  ClientHeight = 221
  ClientWidth = 193
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 48
    Height = 13
    Caption = 'Username'
  end
  object Label2: TLabel
    Left = 8
    Top = 35
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object txtUsername: TEdit
    Left = 62
    Top = 5
    Width = 123
    Height = 21
    TabOrder = 0
    Text = 'zzzz_cracker_zzzz'
  end
  object txtPassword: TEdit
    Left = 62
    Top = 32
    Width = 123
    Height = 21
    TabOrder = 1
    Text = 'programmers'
  end
  object cmdLogin: TButton
    Left = 110
    Top = 59
    Width = 75
    Height = 25
    Caption = 'Login'
    TabOrder = 2
    OnClick = cmdLoginClick
  end
  object Button1: TButton
    Left = 110
    Top = 90
    Width = 75
    Height = 25
    Caption = 'Steal Cookie'
    TabOrder = 3
    OnClick = Button1Click
  end
  object sckYMSG: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = sckYMSGConnect
    OnRead = sckYMSGRead
    Left = 8
    Top = 56
  end
end
