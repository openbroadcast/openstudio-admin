unit U_AddZikToPage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, MysqlComponent, StdCtrls, Buttons;

type
  TPageSelector = class(TForm)
    StringGrid1: TStringGrid;
    DateTimePicker1: TDateTimePicker;
    StatusBar1: TStatusBar;
    contenu: TGroupBox;
    StringGrid2: TStringGrid;
    BitBtn1: TBitBtn;
    GroupBox2: TGroupBox;
    parcourir2: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    procedure DateTimePicker1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure parcourir2Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    procedure RequestSQL1(SQL: string);
    procedure RequestSQL2(SQL: string);
    procedure SGClear1();
    procedure SGClear2();
    { Déclarations privées }
  end;
  TStringGridX = class(TStringGrid)
  public
    procedure MoveColumn(FromIndex, ToIndex: Longint);
    procedure MoveRow(FromIndex, ToIndex: Longint);
    procedure InsertRow(ARow: Longint);
    { Déclarations publiques }
  end;

var
  PageSelector: TPageSelector;

implementation

uses U_Welcome, U_Bibliotheque;

{$R *.dfm}

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

procedure TPageSelector.SGClear1();
var
  i: Integer;
begin
  for i := 0 to StringGrid1.Rowcount - 1 do
  begin
    StringGrid1.Rows[i].clear;
  end;
  StringGrid1.rowcount := 1;
end;

procedure TPageSelector.SGClear2();
var
  i: Integer;
begin
  for i := 0 to StringGrid2.Rowcount - 1 do
  begin
    StringGrid2.Rows[i].clear;
  end;
  StringGrid2.rowcount := 1;
end;

procedure TPageSelector.RequestSQL1(SQL: string);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
begin

  if (welcome.Sql.connected) then
  begin

    Res := Welcome.Sql.Query(SQL);

    if Res = nil then StatusBar1.Panels[0].Text := 'Aucun résultat'
    else
    try

      SGClear1();
      StringGrid1.Show;
      StringGrid1.ColCount := 3;
      StringGrid1.RowCount := Welcome.sql.num_rows(Res);

      StringGrid1.ColWidths[0] := 0;
      StringGrid1.ColWidths[1] := 80;
      StringGrid1.ColWidths[2] := 100;

      j := 0;
      Row := welcome.Sql.fetch_row(Res);
      while Row <> nil do
      begin
        for i := 0 to StringGrid1.ColCount do
        begin
          StringGrid1.Cells[i, j] := Row[i];
        end;
        Row := welcome.sql.fetch_row(Res);
        j := j + 1;
      end;
    finally
      welcome.sql.free_result(Res);
    end;

  end;
end;

procedure TPageSelector.RequestSQL2(SQL: string);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
  Duree: Extended;
begin

  if (welcome.Sql.connected) then
  begin

    Res := Welcome.Sql.Query(SQL);

    if Res = nil then StatusBar1.Panels[0].Text := 'Ecran vide'
    else
    try

      SGClear2();
      StringGrid2.Show;
      StringGrid2.ColCount := 17;
      StringGrid2.RowCount := Welcome.sql.num_rows(Res);

      StringGrid2.ColWidths[0] := 0; // ID
      StringGrid2.ColWidths[1] := 70; // Date
      StringGrid2.ColWidths[2] := 55; // Heure
      StringGrid2.ColWidths[3] := 25; // Prior
      StringGrid2.ColWidths[4] := 250; // artiste
      StringGrid2.ColWidths[5] := 250; // titre
      StringGrid2.ColWidths[6] := 50; // annee
      StringGrid2.ColWidths[7] := 30; // duree  (humain)
      StringGrid2.ColWidths[8] := 50; // frequence
      StringGrid2.ColWidths[9] := 50; //tempo
      StringGrid2.ColWidths[10] := 15; // intro
      StringGrid2.ColWidths[11] := 35; // fade in
      StringGrid2.ColWidths[12] := 35; // fade out
      StringGrid2.ColWidths[13] := 35; // path
      StringGrid2.ColWidths[14] := 35; // Cat
      StringGrid2.ColWidths[15] := 35; // SSCat
      StringGrid2.ColWidths[16] := 35; // Duree (machine)

      j := 0;
      Row := welcome.Sql.fetch_row(Res);
      while Row <> nil do
      begin
        for i := 0 to StringGrid2.ColCount do
        begin
          if (i = 7) then
          begin
            Duree := StrToFloat(StringReplace(Row[i], '.', ',', [rfReplaceAll]));
            StringGrid2.Cells[i, j] := format('%2.2d:%2.2d', [trunc(Duree) div 60, trunc(Duree) mod 60]);
          end
          else
          begin
            StringGrid2.Cells[i, j] := Row[i];
          end;
        end;
        Row := welcome.sql.fetch_row(Res);
        j := j + 1;
      end;
    finally
      welcome.sql.free_result(Res);
    end;

  end;
end;

procedure TPageSelector.DateTimePicker1Change(Sender: TObject);
begin
  RequestSQL1('SELECT DISTINCT DATE_FORMAT(Date_Play, ''%Y-%m-%d'') as dateuk, DATE_FORMAT(Date_Play, ''%d/%m/%Y'') as datefr, DATE_FORMAT(Date_Play, ''%H:%i:%s'') as heure FROM timer WHERE Date_Play LIKE ''' + FormatDateTime('yyyy-mm-dd', DateTimePicker1.DateTime) + '%'' ORDER by Date_Play ASC;');
end;

procedure TPageSelector.FormShow(Sender: TObject);
begin
  DateTimePicker1.DateTime := Now();
  DateTimePicker1.OnChange(self);
end;

procedure TPageSelector.StringGrid1DblClick(Sender: TObject);
var
  DatePlay, RequestSQL: string;
begin
  DatePlay := StringGrid1.Cells[0, StringGrid1.Row] + ' ' + StringGrid1.Cells[2, StringGrid1.Row];
  RequestSQL := 'SELECT timer.Id, DATE_FORMAT(timer.Date_Play, ''%Y-%m-%d'') as dateuk, DATE_FORMAT(timer.Date_Play, ''%H:%i:%s'') as time, ';
  RequestSQL := RequestSQL + 'timer.Prior, artistes.Name AS Artiste, playlist.Titre, playlist.Annee, playlist.Duree, timer.Frequence, timer.Tempo, ';
  RequestSQL := RequestSQL + 'timer.Intro, timer.FadeIn, timer.FadeOut, playlist.Path, playlist.Categorie, playlist.ssCategorie, playlist.Duree ';
  RequestSQL := RequestSQL + 'FROM timer ';
  RequestSQL := RequestSQL + 'LEFT JOIN playlist ON (playlist.ID=timer.PlaylistID) ';
  RequestSQL := RequestSQL + 'LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
  RequestSQL := RequestSQL + 'WHERE timer.Date_Play = ''' + DatePlay + ''' ORDER by timer.Id ASC;';
  //ShowMessage(RequestSQL);
  RequestSQL2(RequestSQL);
end;

procedure TPageSelector.parcourir2Click(Sender: TObject);
begin
  Bibliotheque.Tag := 1;
  Bibliotheque.ShowModal;
end;

procedure TPageSelector.BitBtn2Click(Sender: TObject);
begin
  TStringGridX(StringGrid2).MoveRow(StringGrid2.Row, StringGrid2.Row - 1);
end;

procedure TPageSelector.BitBtn4Click(Sender: TObject);
begin
  TStringGridX(StringGrid2).MoveRow(StringGrid2.Row, StringGrid2.Row + 1);
end;

procedure TPageSelector.BitBtn3Click(Sender: TObject);
begin
  if (StringGrid2.RowCount <> 1) then
  begin
    GridDeleteRow(StringGrid2.Row, StringGrid2);
  end
  else
  begin
    StringGrid2.Rows[StringGrid2.Row].Clear;
  end;
end;

procedure TPageSelector.BitBtn5Click(Sender: TObject);
begin
  TStringGridX(StringGrid2).InsertRow(StringGrid2.Row);
  StringGrid2.Cells[1, PageSelector.StringGrid2.Row] := StringGrid1.cells[0, StringGrid1.Row];
  StringGrid2.Cells[2, PageSelector.StringGrid2.Row] := StringGrid1.cells[2, StringGrid1.Row];
  StringGrid2.Cells[3, PageSelector.StringGrid2.Row] := '0';
end;

procedure TPageSelector.BitBtn1Click(Sender: TObject);
var
  i: Integer;
begin

  if welcome.sql.Connected = False then
  begin
    ShowMessage('Vous devez être connecté au serveur SQL.');
  end
  else
  begin

    welcome.sql.Query('DELETE FROM timer WHERE Date_Play = ''' + StringGrid1.cells[0, StringGrid1.Row] + ' ' + StringGrid1.cells[2, StringGrid1.Row] + ''';');

    for i := 0 to StringGrid2.RowCount - 1 do
    begin
      welcome.Sql.query('INSERT INTO timer SET Frequence=''' + StringGrid2.cells[8, i] + ''', Tempo=''' + StringGrid2.cells[9, i] + ''',  Intro=''' + StringGrid2.cells[10, i] + ''', FadeIn=''' + StringGrid2.cells[11, i] + ''', FadeOut=''' + StringGrid2.cells[12, i] + ''', Prior=''' + StringGrid2.cells[3, i] + ''', Date_Play=''' + StringGrid2.cells[1, i] + ' ' + StringGrid2.cells[2, i] + ''', Date_Insert=NOW(), Date_Mod=NOW();');
    end;
    StatusBar1.Panels[0].Text := IntToStr(i) + ' fichiers ajoutés au Timer avec succès';

  end;

end;

end.
