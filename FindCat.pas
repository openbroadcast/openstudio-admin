unit FindCat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MysqlComponent;

type
  TFindCategory = class(TForm)
    Categorie: TComboBox;
    GroupBox1: TGroupBox;
    Button1: TButton;
    SSCategorie: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CategorieChange(Sender: TObject);
  private
    { Déclarations privées }
  public
    FindCategorie, FindSSCategorie: string;
    { Déclarations publiques }
  end;

var
  FindCategory: TFindCategory;

implementation

uses U_Welcome, U_Gestion;

{$R *.dfm}

procedure TFindCategory.FormShow(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i: Integer;
begin

  with Categorie.Items do
    for i := Count - 1 downto 0 do
      Delete(i);

  with SSCategorie.Items do
    for i := Count - 1 downto 0 do
      Delete(i);

  Res := welcome.sql.Query('SELECT id, nom FROM categories;');
  Row := welcome.sql.fetch_row(Res);

  while Row <> nil do
  begin
    Categorie.AddItem('(' + Row[0] + ') ' + Row[1], TObject(StrToInt(Row[0])));
    Row := welcome.sql.fetch_row(Res);
  end;

  Categorie.ItemIndex := 0;
  CategorieChange(sender);

  welcome.sql.free_result(Res);
end;

procedure TFindCategory.CategorieChange(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i: Integer;
  RequestSQL: string;
begin

  with SSCategorie.Items do
    for i := Count - 1 downto 0 do
      Delete(i);

  RequestSQL := 'SELECT id, nom FROM sscategories WHERE categorie=' + IntToStr(integer(Categorie.items.objects[Categorie.itemindex])) + ';';
  Res := welcome.sql.Query(RequestSQL);

  Row := welcome.sql.fetch_row(Res);
  while Row <> nil do
  begin
    SSCategorie.AddItem('(' + Row[0] + ') ' + Row[1], TObject(StrToInt(Row[0])));
    Row := welcome.sql.fetch_row(Res);
  end;

  if (SSCategorie.Items.Count = 0) then begin
    SSCategorie.AddItem('(0) Default', TObject(0));
  end;

  SSCategorie.ItemIndex := 0;

  welcome.sql.free_result(Res);

end;

procedure TFindCategory.Button1Click(Sender: TObject);
begin
  FindCategorie := IntToStr(integer(Categorie.items.objects[Categorie.itemindex]));
  FindSSCategorie := IntToStr(integer(SSCategorie.items.objects[SSCategorie.itemindex]));
  ModalResult := mrOk;
end;

end.
