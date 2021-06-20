object Formats: TFormats
  Left = 506
  Top = 279
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Formats'
  ClientHeight = 123
  ClientWidth = 253
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object formatsName: TComboBox
    Left = 13
    Top = 56
    Width = 229
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 14
    Top = 8
    Width = 225
    Height = 25
    Caption = 'Cr'#233'er un nouveau format'
    TabOrder = 1
    OnClick = BitBtn1Click
  end
  object BitBtn2: TBitBtn
    Left = 14
    Top = 80
    Width = 225
    Height = 25
    Caption = 'Supprimer le format s'#233'lectionn'#233
    TabOrder = 2
    OnClick = BitBtn2Click
  end
end
