unit U_Stations;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, MySQLComponent, ComCtrls,
  MPlayer, Spin, DateUtils, BASS, Mask;

type
  TStationsForm = class(TForm)
    StringGrid1: TStringGrid;
    StatusBar1: TStatusBar;
    vider: TBitBtn;
    Delete: TBitBtn;
    consulter: TSpeedButton;
    Modifier: TBitBtn;
    Ajouter: TBitBtn;
    procedure viderClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure consulterClick(Sender: TObject);
    procedure ModifierClick(Sender: TObject);
    procedure AjouterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
  private
    { Déclarations privées }
    x: Integer;
  end;
  TStringGridX = class(TStringGrid)
  public
    { Déclarations publiques }
  end;

var
  StationsForm: TStationsForm;

implementation

uses U_Welcome, U_Bibliotheque, U_Jingles;

{$R *.dfm}

procedure DeleteFromDB(id: Integer);
var
  Res: PMYSQL_RES;
begin

  Res := welcome.sql.Query('DELETE FROM stations WHERE id=''' + IntToStr(id) + ''';');
  welcome.sql.free_result(Res);
  //ShowMessage(IntToStr(id));

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

procedure TStationsForm.viderClick(Sender: TObject);
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

procedure TStationsForm.DeleteClick(Sender: TObject);
begin
  if ((StringGrid1.RowCount - 1) <> 0) then
  begin
    DeleteFromDB(StrToInt(StringGrid1.cells[0, StringGrid1.Row]));
    GridDeleteRow(StringGrid1.Row, StringGrid1);
    x := (x - 1);
  end
  else
  begin
    StringGrid1.Rows[StringGrid1.Row].Clear;
    x := 0;
  end;
end;

procedure TStationsForm.consulterClick(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
begin

  Res := Welcome.Sql.Query('SELECT id, stationName FROM stations ORDER by id ASC;');

  if Res = nil then begin
    StatusBar1.Panels[0].Text := 'Pas d''émetteurs';
  end
  else
  try

    StringGrid1.ColCount := 2;
    StringGrid1.Cells[0, 0] := 'Id';
    StringGrid1.ColWidths[0] := 50;
    StringGrid1.Cells[1, 0] := 'Nom';
    StringGrid1.ColWidths[1] := 350;

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

procedure TStationsForm.ModifierClick(Sender: TObject);
var
  Reponse: string;
begin
  Reponse := InputBox('Modifier un emetteur', 'Tappez ci dessous le nom de la station (max 8char RDS)', StringGrid1.cells[1, StringGrid1.Row]);

  if Reponse = '' then
  begin
    StatusBar1.Panels[0].Text := 'Entrez un nom !';
  end
  else
  begin
    Welcome.Sql.Query('UPDATE stations SET stationName=''' + Reponse + '''  WHERE id=''' + StringGrid1.cells[0, StringGrid1.Row] + ''';');
    vider.Click();
    consulter.Click();
  end;

end;

procedure TStationsForm.AjouterClick(Sender: TObject);
var
  Reponse: string;
begin
  Reponse := InputBox('Encoder un emetteur', 'Tappez ci dessous le nom de la station (max 8char RDS)', '');

  if Reponse = '' then
  begin
    StatusBar1.Panels[0].Text := 'Entrez un nom !';
  end
  else
  begin
    Welcome.Sql.Query('INSERT into stations SET stationName=''' + Reponse + ''';');
    vider.Click();
    consulter.Click();
  end;

end;

procedure TStationsForm.FormShow(Sender: TObject);
begin

  if (welcome.sql.Connected = true) then
  begin
    vider.Click();
    consulter.Click();
  end;

end;

procedure TStationsForm.StringGrid1DblClick(Sender: TObject);
begin
  Modifier.Click();
end;

end.
