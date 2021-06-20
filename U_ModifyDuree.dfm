object ModifyDuree: TModifyDuree
  Left = 325
  Top = 262
  Width = 741
  Height = 263
  BorderStyle = bsSizeToolWin
  Caption = 'V'#233'rifier les dur'#233'es'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 378
    Height = 13
    Caption = 
      'Cette application vous permet de v'#233'rifier les dur'#233'es des fichier' +
      's MP3/WAV/MP2'
  end
  object Memo1: TMemo
    Left = 8
    Top = 24
    Width = 713
    Height = 145
    Lines.Strings = (
      '')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 560
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = Button1Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 213
    Width = 733
    Height = 19
    Panels = <
      item
        Width = 50
      end>
  end
  object actif: TCheckBox
    Left = 488
    Top = 181
    Width = 57
    Height = 17
    Caption = 'Actif'
    TabOrder = 3
  end
  object Button2: TButton
    Left = 640
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 4
    OnClick = Button2Click
  end
end
