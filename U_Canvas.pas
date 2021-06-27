unit U_Canvas;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, MySQLComponent, ComCtrls,
  MPlayer, Spin, DateUtils, BASS;

type
  TCanvasControl = class(TForm)
    StringGrid1: TStringGrid;
    StatusBar1: TStatusBar;
    vider: TBitBtn;
    BitBtn5: TBitBtn;
    Panel1: TPanel;
    consulter: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    BitBtn4: TBitBtn;
    GroupBox3: TGroupBox;
    Categorie: TComboBox;
    ssCategorie: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    canvasname: TComboBox;
    Label3: TLabel;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    GroupBox2: TGroupBox;
    protectioncd: TSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    protectionartist: TSpinEdit;
    Label6: TLabel;
    Label7: TLabel;
    Comment: TEdit;
    Label8: TLabel;
    loadComboBox: TBitBtn;
    procedure viderClick(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure consulterClick(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure CategorieChange(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure loadComboBoxClick(Sender: TObject);
  private
    { Déclarations privées }
    x, Update: Integer;
  end;
  TStringGridX = class(TStringGrid)
  public
    procedure MoveColumn(FromIndex, ToIndex: Longint);
    procedure MoveRow(FromIndex, ToIndex: Longint);
    procedure InsertRow(ARow: Longint);
    { Déclarations publiques }
  end;

var
  CanvasControl: TCanvasControl;

implementation

uses U_Welcome, U_Bibliotheque, U_Jingles;

{$R *.dfm}

procedure DeleteFromDB(id: Integer);
var
  Res: PMYSQL_RES;
begin

  Res := welcome.sql.Query('DELETE FROM canvas WHERE id=''' + IntToStr(id) + ''';');
  welcome.sql.free_result(Res);

end;

procedure TStringGridX.InsertRow(ARow: Longint);
var
  GemRow: Integer;
begin
  GemRow := Row;
  while ARow < FixedRows do Inc(ARow);
  RowCount := RowCount + 1;
  MoveRow(RowCount - 1, ARow);
  Row := GemRow;
  Rows[Row].Clear;
end;

procedure GridDeleteRow(RowNumber: Integer; Grid: TstringGrid);
var
  i: Integer;
begin
  Grid.Row := RowNumber;
  if (Grid.Row = Grid.RowCount - 1) then
    { On the last row}
    Grid.RowCount := Grid.RowCount - 1
  else
  begin
    { Not the last row}
    for i := RowNumber to Grid.RowCount - 1 do
      Grid.Rows[i] := Grid.Rows[i + 1];
    Grid.RowCount := Grid.RowCount - 1;
  end;
end;

procedure TStringGridX.MoveColumn(FromIndex, ToIndex: Integer);
begin
  inherited;
end;

procedure TStringGridX.MoveRow(FromIndex, ToIndex: Integer);
begin
  inherited;
end;

procedure TCanvasControl.viderClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to StringGrid1.Rowcount - 1 do
  begin
    StringGrid1.Rows[i].clear;
  end;
  StringGrid1.rowcount := 1;
  x := 0;

end;

procedure TCanvasControl.BitBtn5Click(Sender: TObject);
begin
  if ((StringGrid1.RowCount - 1) <> 1) then
  begin
    GridDeleteRow(StringGrid1.Row, StringGrid1);
    DeleteFromDB(StrToInt(StringGrid1.cells[4, StringGrid1.Row]));
    x := (x - 1);
  end
  else
  begin
    StringGrid1.Rows[StringGrid1.Row].Clear;
    x := 0;
  end;
end;

procedure TCanvasControl.consulterClick(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
  Select: string;
begin

  StringGrid1.ColCount := 9;
  StringGrid1.Cells[0, 0] := 'ID canvas';
  StringGrid1.ColWidths[0] := 125;
  StringGrid1.Cells[1, 0] := 'Categorie';
  StringGrid1.ColWidths[1] := 125;
  StringGrid1.Cells[2, 0] := 'Sous Categorie';
  StringGrid1.ColWidths[2] := 125;
  StringGrid1.Cells[3, 0] := 'Commentaire';
  StringGrid1.ColWidths[3] := 125;
  StringGrid1.ColWidths[4] := 0;
  StringGrid1.ColWidths[5] := 0;
  StringGrid1.ColWidths[6] := 0;
  StringGrid1.ColWidths[7] := 0;
  StringGrid1.ColWidths[8] := 0;

  Select := 'SELECT canvas.format, categories.nom, sscategories.nom, canvas.Comment, canvas.id, canvas.protectioncd, canvas.protectionartist, canvas.Categorie, canvas.ssCategorie ';
  Select := Select + 'FROM canvas LEFT JOIN categories ON (categories.id=canvas.Categorie) LEFT JOIN sscategories ON (sscategories.id=canvas.SSCategorie) ORDER by canvas.format, canvas.id ASC;';

  Res := Welcome.Sql.Query(Select);

  if Res = nil then begin
    StatusBar1.Panels[0].Text := 'Pas encore de Canvas';
  end
  else if (Welcome.sql.num_rows(Res) = 0) then
  begin
    StatusBar1.Panels[0].Text := 'Pas encore de Canvas';
  end
  else
  try

    StringGrid1.RowCount := Welcome.sql.num_rows(Res) + 1;
    StringGrid1.FixedRows := 1;

    j := 1;
    Row := Welcome.sql.fetch_row(Res);
    while Row <> nil do
    begin
      for i := 0 to StringGrid1.ColCount do
      begin
        StringGrid1.Cells[i, j] := Row[i];
      end;
      Row := Welcome.sql.fetch_row(Res);
      j := j + 1;
    end;
  finally
    Welcome.sql.free_result(Res);
  end;

end;

procedure TCanvasControl.BitBtn4Click(Sender: TObject);
var
  format, vcategorie, vsscategorie : String;
begin

  format := IntToStr(integer(CanvasName.items.objects[CanvasName.itemindex]));
  vcategorie := IntToStr(integer(Categorie.items.objects[Categorie.itemindex]));
  vsscategorie := IntToStr(integer(SSCategorie.items.objects[SSCategorie.itemindex]));


  if (Update <> 0) then
  begin
    Welcome.Sql.Query('UPDATE canvas SET format=' + format + ', Categorie=''' + vcategorie + ''', ssCategorie=''' + vsscategorie + ''', Comment=''' + Comment.Text + ''', protectioncd=''' + IntToStr(protectioncd.Value) + ''', protectionartist=''' + IntToStr(protectionartist.Value) + ''' WHERE id=''' + IntToStr(Update) + ''';');
  end
  else
  begin
    Welcome.Sql.Query('INSERT into canvas SET format=' + format + ', Categorie=''' + vcategorie + ''', ssCategorie=''' + vsscategorie + ''', Comment=''' + Comment.Text + ''', protectioncd=''' + IntToStr(protectioncd.Value) + ''', protectionartist=''' + IntToStr(protectionartist.Value) + ''';');
  end;

  StringGrid1.cells[0, StringGrid1.Row] := IntToStr(integer(CanvasName.items.objects[CanvasName.itemindex]));
  StringGrid1.cells[1, StringGrid1.Row] := Categorie.Text;
  StringGrid1.cells[2, StringGrid1.Row] := SSCategorie.Text;
  StringGrid1.cells[5, StringGrid1.Row] := IntToStr(protectioncd.Value);
  StringGrid1.cells[6, StringGrid1.Row] := IntToStr(protectionartist.Value);
  StringGrid1.cells[7, StringGrid1.Row] := IntToStr(integer(Categorie.items.objects[Categorie.itemindex]));
  StringGrid1.cells[8, StringGrid1.Row] := IntToStr(integer(SSCategorie.items.objects[SSCategorie.itemindex]));

  Update := 0;
  Consulter.Click;
end;

procedure TCanvasControl.BitBtn1Click(Sender: TObject);
begin
 if(StringGrid1.cells[0, StringGrid1.Row] <> '') then
 begin
    CanvasName.ItemIndex := CanvasName.items.IndexOfObject(TObject(StrToInt(StringGrid1.cells[0, StringGrid1.Row])));
    Categorie.ItemIndex := Categorie.items.IndexOfObject(TObject(StrToInt(StringGrid1.cells[7, StringGrid1.Row])));
    CategorieChange(Sender);
    SSCategorie.ItemIndex := SSCategorie.items.IndexOfObject(TObject(StrToInt(StringGrid1.cells[8, StringGrid1.Row])));
    Comment.Text := StringGrid1.cells[3, StringGrid1.Row];
    Update := StrToInt(StringGrid1.cells[4, StringGrid1.Row]);
    protectioncd.Value := StrToInt(StringGrid1.cells[5, StringGrid1.Row]);
    protectionartist.Value := StrToInt(StringGrid1.cells[6, StringGrid1.Row]);
  end;
end;

procedure TCanvasControl.BitBtn2Click(Sender: TObject);
begin
  Update := 0;
  TStringGridX(StringGrid1).InsertRow(StringGrid1.Row);
end;

procedure TCanvasControl.FormShow(Sender: TObject);
begin

  if (welcome.sql.Connected = true) then
  begin

    vider.Click();
    consulterClick(Sender);
    loadComboBox.Click();

  end;

end;

procedure TCanvasControl.BitBtn6Click(Sender: TObject);
begin
  TStringGridX(StringGrid1).MoveRow(StringGrid1.Row, StringGrid1.Row - 1);
end;

procedure TCanvasControl.BitBtn7Click(Sender: TObject);
begin
  TStringGridX(StringGrid1).MoveRow(StringGrid1.Row, StringGrid1.Row + 1);
end;

procedure TCanvasControl.BitBtn8Click(Sender: TObject);
var
  i: Integer;
begin

  if welcome.sql.Connected = False then
  begin
    ShowMessage('Vous devez être connecté au serveur.');
  end
  else
  begin

  // Delete All
    welcome.sql.Query('TRUNCATE TABLE canvas;');

    for i := 1 to (StringGrid1.RowCount - 1) do
    begin
      welcome.Sql.query('INSERT INTO canvas SET format=''' + StringGrid1.cells[0, i] + ''', Categorie=''' + StringGrid1.cells[7, i] + ''', ssCategorie=''' + StringGrid1.cells[8, i] + ''', Comment=''' + StringGrid1.cells[3, i] + ''', protectioncd=''' + StringGrid1.cells[5, i] + ''', protectionartist=''' + StringGrid1.cells[6, i] + ''';');
    end;

    consulterClick(Sender);

  end;

end;

procedure TCanvasControl.CategorieChange(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i: Integer;
  RequestSQL: string;
begin
  SSCategorie.Clear;
  with SSCategorie.Items do
    for i := Count - 1 downto 0 do
      Delete(i);

  RequestSQL := 'SELECT id, nom FROM sscategories WHERE categorie=' + IntToStr(integer(Categorie.items.objects[Categorie.itemindex])) + ';';
  Res := welcome.sql.Query(RequestSQL);

  Row := welcome.sql.fetch_row(Res);
  while Row <> nil do
  begin
    SSCategorie.AddItem(Row[1], TObject(StrToInt(Row[0])));
    Row := welcome.sql.fetch_row(Res);
  end;

  if (SSCategorie.Items.Count = 0) then begin
    SSCategorie.AddItem('(0) Default', TObject(0));
    SSCategorie.ItemIndex := 0;
  end;

  welcome.sql.free_result(Res);

end;

procedure TCanvasControl.StringGrid1Click(Sender: TObject);
begin
  BitBtn1Click(Sender);
end;

procedure TCanvasControl.loadComboBoxClick(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
begin

    Categorie.Clear;
    SSCategorie.Clear;

    Res := welcome.sql.Query('SELECT id, nom FROM categories;');
    Row := welcome.sql.fetch_row(Res);

    while Row <> nil do
    begin
      Categorie.AddItem(Row[1], TObject(StrToInt(Row[0])));
      Row := welcome.sql.fetch_row(Res);
    end;
    welcome.sql.free_result(Res);

    CanvasName.Clear;

  //  with CanvasName.Items do
  //   for i := Count - 1 downto 0 do
  //    Delete(i);

    Res := welcome.sql.Query('SELECT ID, Name FROM formats;');
    Row := welcome.sql.fetch_row(Res);

    while Row <> nil do
    begin
      CanvasName.AddItem('(' + Row[0] + ') ' + Row[1], TObject(StrToInt(Row[0])));
      Row := welcome.sql.fetch_row(Res);
    end;

    CanvasName.ItemIndex := 0;

    welcome.sql.free_result(Res);
end;

end.

