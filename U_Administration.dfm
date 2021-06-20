object Administration: TAdministration
  Left = 365
  Top = 282
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Administration'
  ClientHeight = 227
  ClientWidth = 664
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 649
    Height = 209
    Caption = 'Administration'
    TabOrder = 0
    object GroupBox2: TGroupBox
      Left = 16
      Top = 80
      Width = 625
      Height = 113
      Caption = 'Requ'#234'te SQL'
      TabOrder = 0
      object SQL: TMemo
        Left = 8
        Top = 18
        Width = 609
        Height = 55
        TabOrder = 0
      end
      object BitBtn1: TBitBtn
        Left = 8
        Top = 78
        Width = 75
        Height = 25
        Caption = 'SQL'
        TabOrder = 1
        OnClick = BitBtn1Click
      end
    end
    object GroupBox3: TGroupBox
      Left = 16
      Top = 16
      Width = 625
      Height = 57
      Caption = 'Raccourcis'
      TabOrder = 1
      object BitBtn2: TBitBtn
        Left = 13
        Top = 19
        Width = 156
        Height = 25
        Caption = 'R'#233'initialiser protection CD'
        TabOrder = 0
        OnClick = BitBtn2Click
      end
      object BitBtn3: TBitBtn
        Left = 181
        Top = 19
        Width = 156
        Height = 25
        Caption = 'R'#233'initialiser protection Artistes'
        TabOrder = 1
        OnClick = BitBtn3Click
      end
    end
  end
end
