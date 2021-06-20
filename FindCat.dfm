object FindCategory: TFindCategory
  Left = 457
  Top = 263
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Rechercher une cat'#233'gorie'
  ClientHeight = 140
  ClientWidth = 303
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
  object GroupBox1: TGroupBox
    Left = 8
    Top = 4
    Width = 289
    Height = 125
    Caption = 'S'#233'lectionnez le nom de la cat'#233'gorie'
    TabOrder = 0
    object Categorie: TComboBox
      Left = 13
      Top = 32
      Width = 265
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnChange = CategorieChange
    end
    object Button1: TButton
      Left = 99
      Top = 90
      Width = 75
      Height = 25
      Caption = 'Recherche'
      TabOrder = 1
      OnClick = Button1Click
    end
    object SSCategorie: TComboBox
      Left = 13
      Top = 60
      Width = 265
      Height = 21
      ItemHeight = 13
      TabOrder = 2
    end
  end
end
