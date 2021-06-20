unit U_Timer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, MySQLComponent, ComCtrls,
  MPlayer, Spin, DateUtils, BASS;

type
  TTimer = class(TForm)
    StringGrid1: TStringGrid;
    StatusBar1: TStatusBar;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    datein: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    dateout: TDateTimePicker;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    timein: TSpinEdit;
    timeout: TSpinEdit;
    debug: TMemo;
    generate: TSpeedButton;
    supprimer: TSpeedButton;
    consulter: TSpeedButton;
    BitBtn7: TBitBtn;
    BitBtn4: TBitBtn;
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure generateClick(Sender: TObject);
    procedure supprimerClick(Sender: TObject);
    procedure consulterClick(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
  private
    { Déclarations privées }
    x: Integer;
    WhileStop: Boolean;
  end;
  TStringGridX = class(TStringGrid)
  public
    procedure MoveColumn(FromIndex, ToIndex: Longint);
    procedure MoveRow(FromIndex, ToIndex: Longint);
    { Déclarations publiques }
  end;

var
  Timer: TTimer;

implementation

uses U_Welcome, U_Bibliotheque, U_Jingles;

{$R *.dfm}

procedure AddToStringGrid(DateTime: TDateTime);
var
  Res, Res2, Res3: PMYSQL_RES;
  Row, Row2, Row3: PMYSQL_ROW;
  Timing, TopHoraire, Select: string;
  Heure, HeureNext: Integer;
begin

  Res := welcome.sql.Query('SELECT duree, minute, seconde, canvas, prior, duree FROM grillepub WHERE heure=''' + FormatDateTime('hh', DateTime) + ''' ORDER by heure, minute ASC;');
  Row := welcome.sql.fetch_row(Res);
  while Row <> nil do
  begin
  // Boucle des écrans sur l'heure renvoyée. (07, 20, 40, 50)

    Res2 := welcome.sql.Query('SELECT Categorie, ssCategorie FROM canvas WHERE format=' + Row[3] + ' ORDER by id ASC;');
    Row2 := welcome.sql.fetch_row(Res2);
    while Row2 <> nil do
    begin
  // Boucle du Canvas

      Heure := StrToInt(FormatDateTime('h', DateTime));
      HeureNext := Heure + 1;
      if (HeureNext = 24) then HeureNext := 0;

  // Comblage
      //if (StrToInt(Row2[0]) = 6) then Timing := 'AND playlist.Duree=''' + Row[5] + ''' ' else Timing := '';
      if (StrToInt(Row2[0]) = 6) then Timing := 'AND playlist.Duree<=''' + Row[5] + ''' ' else Timing := '';
      if (StrToInt(Row2[0]) = 7) then TopHoraire := 'AND playlist.Titre=''' + IntToStr(HeureNext) + ''' ' else TopHoraire := '';

      Select := 'SELECT playlist.Id, artistes.Name AS artiste, playlist.Titre, playlist.Annee, playlist.Duree, playlist.Frequence, ';
      Select := Select + 'playlist.Tempo, playlist.Intro, playlist.FadeIn, playlist.FadeOut, playlist.Path, playlist.Categorie, playlist.ssCategorie ';
      Select := Select + 'FROM playlist LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
      Select := Select + 'WHERE playlist.Categorie=' + Row2[0] + ' AND playlist.ssCategorie=' + Row2[1] + ' ';
      Select := Select + 'AND playlist.Valide ' + TopHoraire + ' ' + Timing + ' ';
      Select := Select + 'ORDER by Rand() LIMIT 1;';

      Res3 := welcome.Sql.Query(Select);
      Row3 := welcome.Sql.fetch_row(Res3);

      if Row3 = nil then
      begin
        Timer.debug.Lines.Add('Pas de comblage trouvé en cat ' + Row2[0] + ' ' + Row2[1] + ' en Timing: ' + Timing);
      end
      else
      begin

        Timer.StringGrid1.Cells[0, Timer.x] := Row3[0]; // ID
        Timer.StringGrid1.Cells[1, Timer.x] := FormatDateTime('yyyy-MM-dd', DateTime); // Date
        Timer.StringGrid1.Cells[2, Timer.x] := IntToStr(Heure); // Heure
        Timer.StringGrid1.Cells[3, Timer.x] := Row[1]; // Minute
        Timer.StringGrid1.Cells[4, Timer.x] := Row[2]; // Seconde (Canvas Row[3] pas besoin)
        Timer.StringGrid1.Cells[5, Timer.x] := Row[4]; // Prior
        Timer.StringGrid1.Cells[6, Timer.x] := Row3[1]; // ARTISTE
        Timer.StringGrid1.Cells[7, Timer.x] := Row3[2]; // TITRE
        Timer.StringGrid1.Cells[8, Timer.x] := Row3[3]; // Année
        Timer.StringGrid1.Cells[9, Timer.x] := Row3[4]; // Duree
        Timer.StringGrid1.Cells[10, Timer.x] := Row3[5]; // Frequence ?
        Timer.StringGrid1.Cells[11, Timer.x] := Row3[6]; // Tempo ?
        Timer.StringGrid1.Cells[12, Timer.x] := Row3[7]; // Intro
        Timer.StringGrid1.Cells[13, Timer.x] := Row3[8]; // Fade IN ?
        Timer.StringGrid1.Cells[14, Timer.x] := Row3[9]; // Fade Out
        Timer.StringGrid1.Cells[15, Timer.x] := Row3[10]; // Fichier ?
        Timer.StringGrid1.Cells[16, Timer.x] := Row3[11]; // Cat
        Timer.StringGrid1.Cells[17, Timer.x] := Row3[12]; // ssCat
        Timer.x := Timer.x + 1;
        Timer.StringGrid1.RowCount := Timer.x;

        welcome.sql.free_result(Res3);
        Application.ProcessMessages;

      end;


  // Fin ittération du Canvas
      Row2 := welcome.sql.fetch_row(Res2);
    end;
    welcome.sql.free_result(Res2);
    Application.ProcessMessages;


  // Fin ittération de l'heure renvoyée.
    Row := welcome.sql.fetch_row(Res);
  end;
  welcome.sql.free_result(Res);
  Application.ProcessMessages;

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

procedure Traitement(const DateDebut, DateFin: TDateTime);
var
  dt: TDateTime;
begin
  dt := DateDebut;

  while (dt < DateFin) do
  begin
    Timer.debug.Lines.Add('Comblé du ' + DateToStr(dt) + ' à ' + TimeToStr(TimeOf(dt)) + '...');
    AddToStringGrid(dt);
    Timer.debug.Lines.Add('OK');
    dt := IncHour(dt, 1);
    Application.ProcessMessages;

    if (Timer.WhileStop = True) then
    begin
      Timer.WhileStop := False;
      Exit;
    end;

  end;
end;

procedure Delete(const DateDebut, DateFin: TDateTime);
var
  Res: PMYSQL_RES;
begin
  timer.debug.Lines.Add('Delete du ' + DateToStr(DateDebut) + ' à ' + TimeToStr(TimeOf(DateDebut)) + ' au ' + DateToStr(DateFin) + ' à ' + TimeToStr(TimeOf(DateFin)) + '... ok');
  Res := welcome.sql.Query('DELETE FROM timer WHERE Date_Play >= ''' + FormatDateTime('yyyy-MM-dd hh', DateDebut) + ':00:00' + ''' AND Date_Play <= ''' + FormatDateTime('yyyy-MM-dd hh', DateFin) + ':59:59' + ''';');
  welcome.sql.free_result(Res);
end;

procedure TTimer.BitBtn3Click(Sender: TObject);
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

procedure TTimer.BitBtn2Click(Sender: TObject);
var
  i: Integer;
  DatePlay, RequestSQL: string;
begin

  if welcome.sql.Connected = False then
  begin
    ShowMessage('Vous devez être connecté au serveur SQL.');
  end
  else
  begin

    for i := 0 to StringGrid1.RowCount - 1 do
    begin
      DatePlay := StringGrid1.cells[1, i] + ' ' + StringGrid1.cells[2, i] + ':' + StringGrid1.cells[3, i] + ':' + StringGrid1.cells[4, i];
      RequestSQL := 'INSERT INTO timer SET PlaylistID=' + StringGrid1.cells[0, i] + ', Frequence=''' + StringGrid1.cells[10, i] + ''', Tempo=''' + StringGrid1.cells[11, i] + ''',  Intro=''' + StringGrid1.cells[12, i] + ''', FadeIn=''' + StringGrid1.cells[13, i] + ''', FadeOut=''' + StringGrid1.cells[14, i] + ''', Prior=''' + StringGrid1.cells[5, i] + ''', Joue=0, Date_Play=''' + DatePlay + ''', Date_Insert=NOW(), Date_Mod=NOW();';
      welcome.Sql.query(RequestSQL);
      //debug.lines.add(RequestSQL);
      //debug.Lines.Add('Ajout de ' + StringGrid1.cells[6, i] + ' ' + StringGrid1.cells[7, i]);
    end;
    StatusBar1.Panels[0].Text := IntToStr(i) + ' fichiers ajoutés au Timer avec succès';

  end;

  BitBtn3.Click;
end;

procedure TTimer.BitBtn1Click(Sender: TObject);
begin
  TStringGridX(StringGrid1).MoveRow(StringGrid1.Row, StringGrid1.Row - 1);
end;

procedure TTimer.BitBtn6Click(Sender: TObject);
begin
  TStringGridX(StringGrid1).MoveRow(StringGrid1.Row, StringGrid1.Row + 1);
end;

procedure TTimer.BitBtn5Click(Sender: TObject);
begin
  if (StringGrid1.RowCount <> 1) then
  begin
    GridDeleteRow(StringGrid1.Row, StringGrid1);
    x := (x - 1);
  end
  else
  begin
    StringGrid1.Rows[StringGrid1.Row].Clear;
    x := 0;
  end;
end;

procedure TTimer.FormCreate(Sender: TObject);
begin
  StringGrid1.ColCount := 18;
  StringGrid1.ColWidths[0] := 0;
  StringGrid1.ColWidths[1] := 65;
  StringGrid1.ColWidths[2] := 25;
  StringGrid1.ColWidths[3] := 25;
  StringGrid1.ColWidths[4] := 25;
  StringGrid1.ColWidths[5] := 25;
  StringGrid1.ColWidths[6] := 250;
  StringGrid1.ColWidths[7] := 250;
  StringGrid1.ColWidths[8] := 50;
  StringGrid1.ColWidths[9] := 30;
  StringGrid1.ColWidths[10] := 50;
  StringGrid1.ColWidths[11] := 50;
  StringGrid1.ColWidths[12] := 15;
  StringGrid1.ColWidths[13] := 35;
  StringGrid1.ColWidths[14] := 35;
  StringGrid1.ColWidths[15] := 35;
  StringGrid1.ColWidths[16] := 35;
  StringGrid1.ColWidths[17] := 0;

  dateIn.DateTime := Now();
  dateOut.DateTime := Now();
end;

procedure TTimer.generateClick(Sender: TObject);
var
  dtDebut, dtFin: TDateTime;
begin
  dtDebut := IncHour(DateOf(DateIN.Date), TimeIN.Value);
  dtFin := IncHour(DateOf(DateOUT.Date), TimeOUT.Value + 1);
  Traitement(dtDebut, dtFin);
end;

procedure TTimer.supprimerClick(Sender: TObject);
var
  dtDebut, dtFin: TDateTime;
begin
  dtDebut := IncHour(DateOf(DateIN.Date), TimeIN.Value);
  dtFin := IncHour(DateOf(DateOUT.Date), TimeOUT.Value);
  Delete(dtDebut, dtFin);
end;

procedure TTimer.consulterClick(Sender: TObject);

var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
  DatePlayIN, DatePlayOUT, RequestSQL: string;
begin

  DatePlayIN := FormatDateTime('yyyy-MM-dd', DateIN.Date) + ' ' + IntToStr(TimeIN.Value) + ':00:00';
  DatePlayOUT := FormatDateTime('yyyy-MM-dd', DateOUT.Date) + ' ' + IntToStr(TimeOUT.Value) + ':59:59';

  RequestSQL := 'SELECT timer.ID, DATE_FORMAT(timer.Date_Play, ''%Y-%m-%d'') AS Day, DATE_FORMAT(timer.Date_Play, ''%H'') AS Hour, ';
  RequestSQL := RequestSQL + 'DATE_FORMAT(timer.Date_Play, ''%i'') AS Minute, DATE_FORMAT(timer.Date_Play, ''%s'') AS Seconde, timer.Prior, ';
  RequestSQL := RequestSQL + 'artistes.Name AS artiste, playlist.Titre, playlist.Annee, playlist.Duree, timer.Frequence, timer.Tempo, timer.Intro, ';
  RequestSQL := RequestSQL + 'timer.FadeIn, timer.FadeOut, playlist.Path, playlist.Categorie, ';
  RequestSQL := RequestSQL + 'playlist.ssCategorie, playlist.Duree, timer.ID ';
  RequestSQL := RequestSQL + 'FROM timer ';
  RequestSQL := RequestSQL + 'LEFT JOIN playlist ON (playlist.ID=timer.PlaylistID) ';
  RequestSQL := RequestSQL + 'LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
  RequestSQL := RequestSQL + 'WHERE timer.Date_Play >= ''' + DatePlayIN + ''' AND ';
  RequestSQL := RequestSQL + 'timer.Date_Play <= ''' + DatePlayOUT + ''' ORDER by timer.Date_Play ASC;';

  Res := Welcome.Sql.Query(RequestSQL);

  if Res = nil then begin
    StatusBar1.Panels[0].Text := 'Pas de comblage pour la date donnée';
  end
  else
  try

    StringGrid1.RowCount := Welcome.sql.num_rows(Res);

    j := 0;
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

procedure TTimer.BitBtn7Click(Sender: TObject);
begin
  supprimer.Click;
  BitBtn2.Click;
end;

procedure TTimer.BitBtn4Click(Sender: TObject);
begin
  WhileStop := True;
end;

end.
