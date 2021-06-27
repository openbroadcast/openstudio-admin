object Category: TCategory
  Left = 510
  Top = 360
  Width = 941
  Height = 164
  Caption = 'Category'
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
    Width = 897
    Height = 109
    Caption = 'Modifier le nom de la cat'#233'gorie'
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
      Left = 594
      Top = 31
      Width = 75
      Height = 23
      Caption = 'Modifier'
      TabOrder = 1
      Visible = False
      OnClick = Button1Click
    end
    object SSCategorie: TComboBox
      Left = 13
      Top = 60
      Width = 265
      Height = 21
      ItemHeight = 13
      TabOrder = 2
      OnChange = SSCategorieChange
    end
    object Button2: TButton
      Left = 593
      Top = 60
      Width = 75
      Height = 23
      Caption = 'Modifier'
      TabOrder = 3
      OnClick = Button2Click
    end
    object CategorieName: TEdit
      Left = 296
      Top = 32
      Width = 289
      Height = 21
      TabOrder = 4
    end
    object SSCategorieName: TEdit
      Left = 296
      Top = 60
      Width = 289
      Height = 21
      TabOrder = 5
    end
    object Button3: TButton
      Left = 674
      Top = 60
      Width = 75
      Height = 23
      Caption = 'Ajouter'
      TabOrder = 6
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 754
      Top = 60
      Width = 75
      Height = 23
      Caption = 'Supprimer'
      TabOrder = 7
      OnClick = Button4Click
    end
  end
end
