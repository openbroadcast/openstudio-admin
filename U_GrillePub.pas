unit U_GrillePub;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, MySQLComponent, ComCtrls,
  DateUtils, BASS, Spin;

type
  TGrillePub = class(TForm)
    StringGrid1: TStringGrid;
    StatusBar1: TStatusBar;
    vider: TBitBtn;
    BitBtn5: TBitBtn;
    Panel1: TPanel;
    consulter: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Panel2: TPanel;
    heure: TSpinEdit;
    duree: TSpinEdit;
    minute: TSpinEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BitBtn4: TBitBtn;
    Label4: TLabel;
    prior: TRadioButton;
    prior2: TRadioButton;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    seconde: TSpinEdit;
    Label6: TLabel;
    Canvas: TComboBox;
    dureeMs: TSpinEdit;
    Label5: TLabel;
    procedure viderClick(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure consulterClick(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
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
  GrillePub: TGrillePub;

implementation

uses U_Welcome, U_Bibliotheque, U_Jingles;

{$R *.dfm}

function Explode(ch: string; sep: string = ';'): TStringList;
var
  p: integer;
begin
  p := pos(sep, ch);
  explode := TStringList.Create;
  while p > 0 do begin
    explode.Add(copy(ch, 1, p - 1));
    if p <= length(ch) then ch := copy(ch, p + length(sep), length(ch));
    p := pos(sep, ch);
  end;
  explode.Add(ch);
end;

function Implode(lst: TStringList; sep: string = ';'): string;
var
  i: integer;
  s: string;
begin
  i := 0;
  while i < lst.Count - 1 do begin
    s := s + lst[i] + sep;
    i := i + 1;
  end;
  if i < lst.Count then s := s + lst[i]; //Ne mets pas de séparateur sur le dernier élément
  result := s;
end;

procedure DeleteFromDB(id: Integer);
var
  Res: PMYSQL_RES;
begin

  Res := welcome.sql.Query('DELETE FROM grillepub WHERE id=''' + IntToStr(id) + ''';');
  welcome.sql.free_result(Res);

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

procedure TGrillePub.viderClick(Sender: TObject);
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

procedure TGrillePub.BitBtn5Click(Sender: TObject);
begin
  if ((StringGrid1.RowCount - 1) <> 0) then
  begin
    DeleteFromDB(StrToInt(StringGrid1.cells[6, StringGrid1.Row]));
    GridDeleteRow(StringGrid1.Row, StringGrid1);
    x := (x - 1);
  end
  else
  begin
    StringGrid1.Rows[StringGrid1.Row].Clear;
    x := 0;
  end;
end;

procedure TGrillePub.consulterClick(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
begin

  StringGrid1.ColCount := 7;
  StringGrid1.Cells[0, 0] := 'Heure';
  StringGrid1.ColWidths[0] := 50;
  StringGrid1.Cells[1, 0] := 'Minute';
  StringGrid1.ColWidths[1] := 50;
  StringGrid1.Cells[2, 0] := 'Seconde';
  StringGrid1.ColWidths[2] := 50;
  StringGrid1.Cells[3, 0] := 'Duree';
  StringGrid1.ColWidths[3] := 50;
  StringGrid1.Cells[4, 0] := 'Prior';
  StringGrid1.ColWidths[4] := 50;
  StringGrid1.Cells[5, 0] := 'Canvas';
  StringGrid1.ColWidths[5] := 500;
  StringGrid1.ColWidths[6] := 0;

  Res := Welcome.Sql.Query('SELECT heure, minute, seconde, duree , prior, canvas, id FROM grillepub ORDER by heure, minute ASC;');

  if Res = nil then begin
    StatusBar1.Panels[0].Text := 'Pas encore de Grille Pub';
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
        StringGrid1.Cells[i, j] := UpperCase(Row[i]); // La cellule en MAJ.
      end;
      Row := Welcome.sql.fetch_row(Res);
      j := j + 1;
    end;
  finally
    Welcome.sql.free_result(Res);
  end;

end;

procedure TGrillePub.BitBtn4Click(Sender: TObject);
var
  PriorVar: Integer;
  MyVarDuree: string;
begin

  if (Prior2.Checked) then PriorVar := 1 else PriorVar := 0;

  MyVarDuree := IntToStr(Duree.Value) + '.' + IntToStr(DureeMs.Value);

  if (Update <> 0) then Welcome.Sql.Query('UPDATE grillepub SET heure=''' + IntToStr(heure.Value) + ''', minute=''' + IntToStr(minute.Value) + ''', seconde=''' + IntToStr(seconde.Value) + ''', duree=''' + MyVarDuree + ''', canvas=' + IntToStr(integer(Canvas.items.objects[Canvas.itemindex])) + ', prior=''' + IntToStr(PriorVar) + ''' WHERE id=''' + IntToStr(Update) + ''';')
  else Welcome.Sql.Query('INSERT into grillepub SET heure=''' + IntToStr(heure.Value) + ''', minute=''' + IntToStr(minute.Value) + ''', seconde=''' + IntToStr(seconde.Value) + ''', duree=''' + MyVarDuree + ''', canvas=' + IntToStr(integer(Canvas.items.objects[Canvas.itemindex])) + ', prior=''' + IntToStr(PriorVar) + ''';');

  consulter.Click;

  Heure.Value := 0;
  Minute.Value := 0;
  Seconde.Value := 0;
  Duree.Value := 0;
  Prior.Checked := True;
  Prior2.Checked := False;
  Canvas.Text := '';
  Update := 0;
end;

procedure TGrillePub.BitBtn1Click(Sender: TObject);
var
  varDuree: TStringList;
begin
  Prior.Checked := False;
  Prior2.Checked := False;

  Heure.Value := StrToInt(StringGrid1.cells[0, StringGrid1.Row]);
  Minute.Value := StrToInt(StringGrid1.cells[1, StringGrid1.Row]);
  Seconde.Value := StrToInt(StringGrid1.cells[2, StringGrid1.Row]);
  varDuree := explode(StringGrid1.cells[3, StringGrid1.Row], '.');
  Duree.Value := StrToInt(varDuree[0]);
  DureeMs.Value := StrToInt(varDuree[1]);
  Canvas.Text := StringGrid1.cells[5, StringGrid1.Row];
  Update := StrToInt(StringGrid1.cells[6, StringGrid1.Row]);
  if (StringGrid1.cells[4, StringGrid1.Row] = '1') then Prior2.Checked := True else Prior.Checked := False;

end;

procedure TGrillePub.BitBtn2Click(Sender: TObject);
begin
  Heure.Value := 0;
  Minute.Value := 0;
  Seconde.Value := 0;
  Duree.Value := 0;
  Update := 0;
  Prior.Checked := True;
  Prior2.Checked := False;
  Canvas.Text := '';
end;

procedure TGrillePub.FormShow(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i: Integer;
begin

  if (welcome.sql.Connected = true) then
  begin

    vider.Click();
    consulter.Click();

    with Canvas.Items do
      for i := Count - 1 downto 0 do
        Delete(i);

    Res := welcome.sql.Query('SELECT ID, Name FROM formats;');
    Row := welcome.sql.fetch_row(Res);

    while Row <> nil do
    begin
      Canvas.AddItem('(' + Row[0] + ') ' + Row[1], TObject(StrToInt(Row[0])));
      Row := welcome.sql.fetch_row(Res);
    end;

    Canvas.ItemIndex := 0;

    welcome.sql.free_result(Res);

  end;

end;

procedure TGrillePub.StringGrid1Click(Sender: TObject);
begin
  BitBtn1.Click;
end;

end.

