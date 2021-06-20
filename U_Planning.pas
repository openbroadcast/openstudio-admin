unit U_Planning;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, MySQLComponent, ComCtrls,
  MPlayer, Spin, DateUtils, BASS, Mask, JvExStdCtrls, JvButton, JvCtrls;

type
  TPlanning = class(TForm)
    StringGrid1: TStringGrid;
    StatusBar1: TStatusBar;
    vider: TBitBtn;
    Delete: TBitBtn;
    Panel1: TPanel;
    consulter: TSpeedButton;
    Modifier: TBitBtn;
    Ajouter: TBitBtn;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    validateform: TBitBtn;
    GroupBox2: TGroupBox;
    Lundi: TCheckBox;
    Mardi: TCheckBox;
    Mercredi: TCheckBox;
    Jeudi: TCheckBox;
    Vendredi: TCheckBox;
    Samedi: TCheckBox;
    Dimanche: TCheckBox;
    AlldaysOK: TJvImgBtn;
    WeekOk: TJvImgBtn;
    WeekendOk: TJvImgBtn;
    AlldaysKO: TJvImgBtn;
    WeekKo: TJvImgBtn;
    WeekendKo: TJvImgBtn;
    FromHour: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    ToHour: TSpinEdit;
    Label3: TLabel;
    GroupBox3: TGroupBox;
    canvasname: TComboBox;
    procedure viderClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure consulterClick(Sender: TObject);
    procedure validateformClick(Sender: TObject);
    procedure ModifierClick(Sender: TObject);
    procedure AjouterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure WeekendOkClick(Sender: TObject);
    procedure WeekOkClick(Sender: TObject);
    procedure AlldaysOKClick(Sender: TObject);
    procedure AlldaysKOClick(Sender: TObject);
    procedure WeekKoClick(Sender: TObject);
    procedure WeekendKoClick(Sender: TObject);
    procedure FromHourChange(Sender: TObject);
    procedure ToHourChange(Sender: TObject);
  private
    { Déclarations privées }
    x, Update: Integer;
  end;
  TStringGridX = class(TStringGrid)
  public
    { Déclarations publiques }
  end;

var
  Planning: TPlanning;

implementation

uses U_Welcome, U_Bibliotheque, U_Jingles;

{$R *.dfm}

procedure DeleteFromDB(id: Integer);
var
  Res: PMYSQL_RES;
begin

  Res := welcome.sql.Query('DELETE FROM planning WHERE id=''' + IntToStr(id) + ''';');
  welcome.sql.free_result(Res);
  ShowMessage(IntToStr(id));

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

procedure TPlanning.viderClick(Sender: TObject);
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

procedure TPlanning.DeleteClick(Sender: TObject);
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

procedure TPlanning.consulterClick(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
begin

  Res := Welcome.Sql.Query('SELECT id, FromHour, ToHour, lundi, mardi, mercredi, jeudi, vendredi, samedi, dimanche, canvas FROM planning ORDER by id ASC;');

  if Res = nil then begin
    StatusBar1.Panels[0].Text := 'Pas de planning.';
  end
  else
  try

    StringGrid1.ColCount := 11;
    StringGrid1.Cells[0, 0] := 'Id';
    StringGrid1.ColWidths[0] := 25;
    StringGrid1.Cells[1, 0] := 'De';
    StringGrid1.ColWidths[1] := 25;
    StringGrid1.Cells[2, 0] := 'A';
    StringGrid1.ColWidths[2] := 25;
    StringGrid1.Cells[3, 0] := 'Lundi';
    StringGrid1.ColWidths[3] := 50;
    StringGrid1.Cells[4, 0] := 'Mardi';
    StringGrid1.ColWidths[4] := 50;
    StringGrid1.Cells[5, 0] := 'Mercredi';
    StringGrid1.ColWidths[5] := 50;
    StringGrid1.Cells[6, 0] := 'Jeudi';
    StringGrid1.ColWidths[6] := 50;
    StringGrid1.Cells[7, 0] := 'Vendredi';
    StringGrid1.ColWidths[7] := 50;
    StringGrid1.Cells[8, 0] := 'Samedi';
    StringGrid1.ColWidths[8] := 50;
    StringGrid1.Cells[9, 0] := 'Dimanche';
    StringGrid1.ColWidths[9] := 50;
    StringGrid1.Cells[10, 0] := 'Canvas';
    StringGrid1.ColWidths[10] := 150;

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

procedure TPlanning.validateformClick(Sender: TObject);
var
  LundiVar, MardiVar, MercrediVar, JeudiVar, VendrediVar, SamediVar, DimancheVar: Integer;
begin

  if (Lundi.Checked) then LundiVar := 1 else LundiVar := 0;
  if (Mardi.Checked) then MardiVar := 1 else MardiVar := 0;
  if (Mercredi.Checked) then MercrediVar := 1 else MercrediVar := 0;
  if (Jeudi.Checked) then JeudiVar := 1 else JeudiVar := 0;
  if (Vendredi.Checked) then VendrediVar := 1 else VendrediVar := 0;
  if (Samedi.Checked) then SamediVar := 1 else SamediVar := 0;
  if (Dimanche.Checked) then DimancheVar := 1 else DimancheVar := 0;

  if (Update <> 0) then Welcome.Sql.Query('UPDATE planning SET fromhour=''' + FromHour.Text + ''', tohour=''' + ToHour.Text + ''', lundi=''' + IntToStr(LundiVar) + ''', mardi=''' + IntToStr(MardiVar) + ''', mercredi=''' + IntToStr(MercrediVar) + ''', jeudi=''' + IntToStr(JeudiVar) + ''', vendredi=''' + IntToStr(VendrediVar) + ''', samedi=''' + IntToStr(SamediVar) + ''', dimanche=''' + IntToStr(DimancheVar) + ''', canvas=' + IntToStr(integer(CanvasName.items.objects[CanvasName.itemindex])) + ' WHERE id=''' + IntToStr(Update) + ''';')
  else Welcome.Sql.Query('INSERT into planning SET fromhour=''' + FromHour.Text + ''', tohour=''' + ToHour.Text + ''', lundi=''' + IntToStr(LundiVar) + ''', mardi=''' + IntToStr(MardiVar) + ''', mercredi=''' + IntToStr(MercrediVar) + ''', jeudi=''' + IntToStr(JeudiVar) + ''', vendredi=''' + IntToStr(VendrediVar) + ''', samedi=''' + IntToStr(SamediVar) + ''', dimanche=''' + IntToStr(DimancheVar) + ''', canvas=' + IntToStr(integer(CanvasName.items.objects[CanvasName.itemindex])) + ';');

  consulter.Click;
  Update := 0;

end;

procedure TPlanning.ModifierClick(Sender: TObject);
begin
// id, FromHour, ToHour, lundi, mardi, mercredi, jeudi, vendredi, samedi, dimanche, canvas

  Update := StrToInt(StringGrid1.cells[0, StringGrid1.Row]);

  FromHour.Value := StrToInt(StringGrid1.cells[1, StringGrid1.Row]);
  ToHour.Value := StrToInt(StringGrid1.cells[2, StringGrid1.Row]);

  if (StringGrid1.cells[3, StringGrid1.Row] = '1') then Lundi.Checked := True else Lundi.Checked := False;
  if (StringGrid1.cells[4, StringGrid1.Row] = '1') then Mardi.Checked := True else Mardi.Checked := False;
  if (StringGrid1.cells[5, StringGrid1.Row] = '1') then Mercredi.Checked := True else Mercredi.Checked := False;
  if (StringGrid1.cells[6, StringGrid1.Row] = '1') then Jeudi.Checked := True else Jeudi.Checked := False;
  if (StringGrid1.cells[7, StringGrid1.Row] = '1') then Vendredi.Checked := True else Vendredi.Checked := False;
  if (StringGrid1.cells[8, StringGrid1.Row] = '1') then Samedi.Checked := True else Samedi.Checked := False;
  if (StringGrid1.cells[9, StringGrid1.Row] = '1') then Dimanche.Checked := True else Dimanche.Checked := False;

  canvasname.Text := StringGrid1.cells[10, StringGrid1.Row];

end;

procedure TPlanning.AjouterClick(Sender: TObject);
begin
  FromHour.Value := 0;
  ToHour.Value := 23;
  AllDaysKO.Click();
  canvasname.Text := '';
  Update := 0;
end;

procedure TPlanning.FormShow(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i : Integer;
begin

  if (welcome.sql.Connected = true) then
  begin
    vider.Click();
    consulter.Click();

    with CanvasName.Items do
      for i := Count - 1 downto 0 do
        Delete(i);

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

end;

procedure TPlanning.StringGrid1Click(Sender: TObject);
begin
  Modifier.Click;
end;

procedure TPlanning.WeekendOkClick(Sender: TObject);
begin
  Samedi.Checked := True;
  Dimanche.Checked := True;
end;

procedure TPlanning.WeekOkClick(Sender: TObject);
begin
  Lundi.Checked := True;
  Mardi.Checked := True;
  Mercredi.Checked := True;
  Jeudi.Checked := True;
  Vendredi.Checked := True;
end;

procedure TPlanning.AlldaysOKClick(Sender: TObject);
begin
  WeekOk.Click;
  WeekendOk.Click;
end;

procedure TPlanning.AlldaysKOClick(Sender: TObject);
begin
  WeekKo.Click;
  WeekendKo.Click;
end;

procedure TPlanning.WeekKoClick(Sender: TObject);
begin
  Lundi.Checked := False;
  Mardi.Checked := False;
  Mercredi.Checked := False;
  Jeudi.Checked := False;
  Vendredi.Checked := False;
end;

procedure TPlanning.WeekendKoClick(Sender: TObject);
begin
  Samedi.Checked := False;
  Dimanche.Checked := False;
end;

procedure TPlanning.FromHourChange(Sender: TObject);
begin
  if (FromHour.Value >= ToHour.Value) then MessageDlg('L''heure de début ne peut être supérieur à l''heure de fin!', mtWarning, [mbOK], 0);
  exit;
end;

procedure TPlanning.ToHourChange(Sender: TObject);
begin
  if (ToHour.Value <= FromHour.Value) then MessageDlg('L''heure de fin ne peut être inférieure à l''heure de début!', mtWarning, [mbOK], 0);
  exit;
end;

end.

