unit U_Users;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, MySQLComponent, ComCtrls,
  MPlayer, Spin, DateUtils, BASS, Mask;

type
  TUsers = class(TForm)
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
    password: TMaskEdit;
    login: TEdit;
    GroupBox2: TGroupBox;
    droits: TSpinEdit;
    valide: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure viderClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure consulterClick(Sender: TObject);
    procedure validateformClick(Sender: TObject);
    procedure ModifierClick(Sender: TObject);
    procedure AjouterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
  private
    { Déclarations privées }
    x, Update: Integer;
  end;
  TStringGridX = class(TStringGrid)
  public
    { Déclarations publiques }
  end;

var
  Users: TUsers;

implementation

uses U_Welcome, U_Bibliotheque, U_Jingles;

{$R *.dfm}

procedure DeleteFromDB(id: Integer);
var
  Res: PMYSQL_RES;
begin

  Res := welcome.sql.Query('DELETE FROM utilisateurs WHERE id=''' + IntToStr(id) + ''';');
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

procedure TUsers.viderClick(Sender: TObject);
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

procedure TUsers.DeleteClick(Sender: TObject);
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

procedure TUsers.consulterClick(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
begin

  Res := Welcome.Sql.Query('SELECT id, login,password,valide,droits FROM utilisateurs WHERE login != ''sysop'' ORDER by id ASC;');

  if Res = nil then begin
    StatusBar1.Panels[0].Text := 'Pas d''utilisateurs';
  end
  else
  try

    StringGrid1.ColCount := 5;
    StringGrid1.Cells[0, 0] := 'Id';
    StringGrid1.ColWidths[0] := 50;
    StringGrid1.Cells[1, 0] := 'Login';
    StringGrid1.ColWidths[1] := 200;
    StringGrid1.Cells[2, 0] := 'Mot de passe';
    StringGrid1.ColWidths[2] := 200;
    StringGrid1.Cells[3, 0] := 'Valide';
    StringGrid1.ColWidths[3] := 50;
    StringGrid1.Cells[4, 0] := 'Droits';
    StringGrid1.ColWidths[4] := 50;

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

procedure TUsers.validateformClick(Sender: TObject);
var
  ValideVar: Integer;
begin
  if (login.Text = 'sysop') then exit;
  if (valide.Checked) then ValideVar := 1 else ValideVar := 0;

  if (Update <> 0) then Welcome.Sql.Query('UPDATE utilisateurs SET login=''' + login.Text + ''', password=''' + password.Text + ''', valide=''' + IntToStr(ValideVar) + ''', droits=''' + IntToStr(droits.value) + ''' WHERE id=''' + IntToStr(Update) + ''';')
  else Welcome.Sql.Query('INSERT into utilisateurs SET login=''' + login.Text + ''', password=''' + password.Text + ''', valide=''' + IntToStr(ValideVar) + ''', droits=''' + IntToStr(droits.value) + ''';');

  consulter.Click;

  login.Text := '';
  password.Text := '';
  valide.Checked := True;
  droits.Value := 0;
  Update := 0;

end;

procedure TUsers.ModifierClick(Sender: TObject);
begin

  Update := StrToInt(StringGrid1.cells[0, StringGrid1.Row]);
  Login.Text := StringGrid1.cells[1, StringGrid1.Row];
  Password.Text := StringGrid1.cells[2, StringGrid1.Row];
  Droits.Value := StrToInt(StringGrid1.cells[4, StringGrid1.Row]);
  if (StringGrid1.cells[3, StringGrid1.Row] = '1') then valide.Checked := True else valide.Checked := False;

end;

procedure TUsers.AjouterClick(Sender: TObject);
begin
  login.Text := '';
  password.Text := '';
  valide.Checked := True;
  droits.Value := 0;
  Update := 0;
end;

procedure TUsers.FormShow(Sender: TObject);
begin

  if (welcome.sql.Connected = true) then
  begin
    vider.Click();
    consulter.Click();
  end;

end;

procedure TUsers.StringGrid1Click(Sender: TObject);
begin
  Modifier.Click;
end;

end.
