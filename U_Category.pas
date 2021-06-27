unit U_Category;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MysqlComponent;

type
  TCategory = class(TForm)
    GroupBox1: TGroupBox;
    Categorie: TComboBox;
    Button1: TButton;
    SSCategorie: TComboBox;
    Button2: TButton;
    CategorieName: TEdit;
    SSCategorieName: TEdit;
    Button3: TButton;
    Button4: TButton;
    procedure FormShow(Sender: TObject);
    procedure CompleteCategories(Sender: TObject);
    procedure CategorieChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SSCategorieChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Category: TCategory;

implementation

uses U_Welcome;

{$R *.dfm}

function getCategoryName(id: string): string;
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
begin

  Res := welcome.sql.Query('SELECT nom FROM categories WHERE id=' + id + ' LIMIT 1;');
  if (Res <> nil) then
  begin
    try
      Row := welcome.sql.fetch_row(Res);
      if (Row <> nil) then
      begin
        Result := Row[0];
      end;
    except;
      welcome.sql.free_result(Res);
    end;
  end;

end;

function getSSCategoryName(id: string): string;
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
begin

  Res := welcome.sql.Query('SELECT nom FROM sscategories WHERE id=' + id + ' LIMIT 1;');
  if (Res <> nil) then
  begin
    try
      Row := welcome.sql.fetch_row(Res);
      if (Row <> nil) then
      begin
        Result := Row[0];
      end;
    except;
      welcome.sql.free_result(Res);
    end;
  end;

end;

procedure TCategory.FormShow(Sender: TObject);
begin
  CompleteCategories(Sender);
end;

procedure TCategory.CompleteCategories(Sender: TObject);
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

procedure TCategory.CategorieChange(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i: Integer;
  RequestSQL, currentId: string;
begin

  currentId := IntToStr(integer(Categorie.items.objects[Categorie.itemindex]));
  CategorieName.Text := getCategoryName(currentId);

  with SSCategorie.Items do
    for i := Count - 1 downto 0 do
      Delete(i);

  RequestSQL := 'SELECT id, nom FROM sscategories WHERE categorie=' + currentId + ';';
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

procedure TCategory.Button1Click(Sender: TObject);
begin
  if(CategorieName.Text <> '') then
  begin
    welcome.sql.Query('UPDATE categories SET nom=''' + CategorieName.Text + ''' WHERE id=' + IntToStr(integer(Categorie.items.objects[Categorie.itemindex])));
    CompleteCategories(Sender);
  end;
end;

procedure TCategory.Button2Click(Sender: TObject);
var
  i: Integer;
begin
  if(SSCategorieName.Text <> '') then
  begin
    welcome.sql.Query('UPDATE sscategories SET nom=''' + SSCategorieName.Text + ''' WHERE id=' + IntToStr(integer(SSCategorie.items.objects[SSCategorie.itemindex])));
    i := SSCategorie.itemindex;
    CategorieChange(Sender);
    SSCategorie.itemindex := i;
  end;
end;

procedure TCategory.SSCategorieChange(Sender: TObject);
var
  currentId: string;
begin

  currentId := IntToStr(integer(SSCategorie.items.objects[SSCategorie.itemindex]));
  SSCategorieName.Text := getSSCategoryName(currentId);

end;

procedure TCategory.Button3Click(Sender: TObject);
begin
  if(SSCategorieName.Text <> '') then
  begin
    welcome.sql.Query('INSERT INTO sscategories SET categorie = '+ IntToStr(integer(Categorie.items.objects[Categorie.itemindex])) +', nom=''' + SSCategorieName.Text + ''';');
    CategorieChange(Sender);
    SSCategorie.itemindex := SSCategorie.Items.Count - 1;
  end;
end;

procedure TCategory.Button4Click(Sender: TObject);
begin
  welcome.sql.Query('DELETE FROM sscategories WHERE id=' + IntToStr(integer(SSCategorie.items.objects[SSCategorie.itemindex])));
  CategorieChange(Sender);
  SSCategorieName.Text := '';
end;

end.
