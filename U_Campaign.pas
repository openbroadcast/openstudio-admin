unit U_Campaign;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, MySQLComponent, ComCtrls,
  MPlayer, Spin, DateUtils, BASS, Mask;

type
  TCampaign = class(TForm)
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
    annonceur: TEdit;
    valide: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    campagne: TEdit;
    Label4: TLabel;
    duree: TSpinEdit;
    mediaid: TEdit;
    Label5: TLabel;
    date_out: TDateTimePicker;
    date_in: TDateTimePicker;
    Label6: TLabel;
    Label7: TLabel;
    diffusions_total: TEdit;
    diffusions_count: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    MediaFile: TEdit;
    DureeFile: TEdit;
    BitBtn1: TBitBtn;
    Stations: TComboBox;
    allStations: TRadioButton;
    selectStation: TRadioButton;
    GroupBox2: TGroupBox;
    SpinEdit1: TSpinEdit;
    Label3: TLabel;
    Label10: TLabel;
    SpinEdit2: TSpinEdit;
    Label11: TLabel;
    procedure viderClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure consulterClick(Sender: TObject);
    procedure validateformClick(Sender: TObject);
    procedure ModifierClick(Sender: TObject);
    procedure AjouterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure mediaidKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure mediaidClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure allStationsClick(Sender: TObject);
    procedure selectStationClick(Sender: TObject);
  private
    { Déclarations privées }
    x, Update: Integer;
  end;
  TStringGridX = class(TStringGrid)
  public
    { Déclarations publiques }
  end;

var
  Campaign: TCampaign;

implementation

uses U_Welcome, U_Bibliotheque, U_Jingles, U_SelectPub;

{$R *.dfm}

procedure DeleteFromDB(id: Integer);
var
  Res: PMYSQL_RES;
begin

  Res := welcome.sql.Query('DELETE FROM campagnes WHERE id=''' + IntToStr(id) + ''';');
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

procedure TCampaign.viderClick(Sender: TObject);
var
  i: Integer;
begin

  for i := 0 to Stations.Items.Count - 1
    do
  begin
    Stations.Items.Delete(i);
  end;

  for i := 0 to StringGrid1.Rowcount - 1 do
  begin
    StringGrid1.Rows[i].clear;
  end;
  StringGrid1.rowcount := 1;
  x := 0;

end;

procedure TCampaign.DeleteClick(Sender: TObject);
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

procedure TCampaign.consulterClick(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
begin

  if (welcome.sql.Connected = true) then
  begin

    Res := Welcome.Sql.Query('SELECT id, annonceur,campagne,diffusions_total,diffusions_count,duree,valide,DATE_FORMAT(date_debut, ''%d/%m/%Y'') AS date_debut_fr, DATE_FORMAT(date_fin, ''%d/%m/%Y'') AS date_fin_fr, mediaid, station FROM campagnes ORDER by id ASC;');

    if Res = nil then begin
      StatusBar1.Panels[0].Text := 'Pas de campagnes';
    end
    else
    try

      StringGrid1.ColCount := 11;
      StringGrid1.Cells[0, 0] := 'Id';
      StringGrid1.ColWidths[0] := 25;
      StringGrid1.Cells[1, 0] := 'Annonceur';
      StringGrid1.ColWidths[1] := 100;
      StringGrid1.Cells[2, 0] := 'Campagne';
      StringGrid1.ColWidths[2] := 100;
      StringGrid1.Cells[3, 0] := 'Diffusions tot.';
      StringGrid1.ColWidths[3] := 50;
      StringGrid1.Cells[4, 0] := 'Diffusions fait.';
      StringGrid1.ColWidths[4] := 50;
      StringGrid1.Cells[5, 0] := 'Duree';
      StringGrid1.ColWidths[5] := 50;
      StringGrid1.Cells[6, 0] := 'Actif';
      StringGrid1.ColWidths[6] := 25;
      StringGrid1.Cells[7, 0] := 'Debut';
      StringGrid1.ColWidths[7] := 80;
      StringGrid1.Cells[8, 0] := 'Fin';
      StringGrid1.ColWidths[8] := 80;
      StringGrid1.ColWidths[9] := 0;
      StringGrid1.ColWidths[10] := 0;


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

    with Stations.Items do
      for i := Count - 1 downto 0 do
        Delete(i);

    Res := welcome.sql.Query('SELECT id, stationName FROM stations ORDER by stationName ASC;');
    Row := welcome.sql.fetch_row(Res);
    while Row <> nil do
    begin
      Stations.AddItem(Row[1], TObject(StrToInt(Row[0])));
      Row := welcome.sql.fetch_row(Res);
    end;
    welcome.sql.free_result(Res);

  end;

end;

procedure TCampaign.validateformClick(Sender: TObject);
var
  ValideVar: Integer;
  Station: string;
begin
  if (valide.Checked) then ValideVar := 1 else ValideVar := 0;

  if ((Update = 0) and (Duree.Text <> DureeFile.Text)) then
  begin
    MessageDlg('Attention! La durée achetée n''est pas égale à la durée du média ! Veuillez calibrer le média avant.', mtError, [mbOK], 0);
  end
  else
  begin

    if (AllStations.Checked) then
    begin
      station := '0';
    end
    else
    begin
      station := IntToStr(integer(Stations.items.objects[Stations.itemindex]));
    end;

    if (Update <> 0) then Welcome.Sql.Query('UPDATE campagnes SET annonceur=''' + annonceur.Text + ''', campagne=''' + campagne.Text + ''', mediaid=''' + mediaid.Text + ''', duree=''' + IntToStr(duree.value) + ''', diffusions_total=''' + diffusions_total.Text + ''', diffusions_count=''' + diffusions_count.Text + ''', station=' + Station + ' , valide=''' + IntToStr(ValideVar) + ''', date_debut=''' + FormatDateTime('yyyy-MM-dd', date_in.Date) + ''', date_fin=''' + FormatDateTime('yyyy-MM-dd', date_out.Date) + ''' WHERE id=''' + IntToStr(Update) + ''';')
    else Welcome.Sql.Query('INSERT into campagnes SET annonceur=''' + annonceur.Text + ''', campagne=''' + campagne.Text + ''', mediaid=''' + mediaid.Text + ''', duree=''' + IntToStr(duree.value) + ''', diffusions_total=''' + diffusions_total.Text + ''', diffusions_count=''' + diffusions_total.Text + ''', station=' + Station + ' , valide=''' + IntToStr(ValideVar) + ''', date_debut=''' + FormatDateTime('yyyy-MM-dd', date_in.Date) + ''', date_fin=''' + FormatDateTime('yyyy-MM-dd', date_out.Date) + ''', date_encodage=CURDATE() ;');

    vider.Click;
    consulter.Click;
    ajouter.Click;

  end;

end;

procedure TCampaign.ModifierClick(Sender: TObject);
begin
  Update := StrToInt(StringGrid1.cells[0, StringGrid1.Row]);
  annonceur.Text := StringGrid1.cells[1, StringGrid1.Row];
  campagne.Text := StringGrid1.cells[2, StringGrid1.Row];
  diffusions_total.Text := StringGrid1.cells[3, StringGrid1.Row];
  diffusions_count.Text := StringGrid1.cells[4, StringGrid1.Row];
  duree.Value := StrToInt(StringGrid1.cells[5, StringGrid1.Row]);
  if (StringGrid1.cells[6, StringGrid1.Row] = '1') then valide.Checked := True else valide.Checked := False;
  date_in.DateTime := StrToDate(StringGrid1.cells[7, StringGrid1.Row]);
  date_out.DateTime := StrToDate(StringGrid1.cells[8, StringGrid1.Row]);
  mediaid.Text := StringGrid1.cells[9, StringGrid1.Row];

  if (StringGrid1.cells[10, StringGrid1.Row] = '0') then
  begin
    AllStations.checked := True;
  end
  else
  begin
    SelectStation.checked := True;
    Stations.ItemIndex := Stations.items.IndexOfObject(TObject(StrToInt(StringGrid1.cells[10, StringGrid1.Row])));
  end;
end;

procedure TCampaign.AjouterClick(Sender: TObject);
begin
  annonceur.Text := '';
  campagne.Text := '';
  duree.Value := 5;
  mediaid.Text := '';
  diffusions_total.Text := '';
  diffusions_count.Text := '';
  date_in.DateTime := Now();
  date_out.DateTime := Now();
  valide.Checked := True;
  AllStations.checked := True;
  Update := 0;
end;

procedure TCampaign.FormShow(Sender: TObject);
begin

  if (welcome.sql.Connected = true) then
  begin
    vider.Click();
    consulter.Click();
  end;

end;

procedure TCampaign.StringGrid1Click(Sender: TObject);
begin
  Modifier.Click;
end;

procedure TCampaign.mediaidKeyPress(Sender: TObject; var Key: Char);
begin
  if not (key in ['0'..'9', #8]) then key := #0;
end;

procedure TCampaign.FormCreate(Sender: TObject);
begin
  date_in.DateTime := Now();
  date_out.DateTime := Now();
end;

procedure TCampaign.mediaidClick(Sender: TObject);
begin
  SelectPub.ShowModal;
end;

procedure TCampaign.BitBtn1Click(Sender: TObject);
begin
  diffusions_count.Text := '0';
end;

procedure TCampaign.allStationsClick(Sender: TObject);
begin
  Stations.Enabled := False;
end;

procedure TCampaign.selectStationClick(Sender: TObject);
begin
  Stations.Enabled := True;
end;

end.
