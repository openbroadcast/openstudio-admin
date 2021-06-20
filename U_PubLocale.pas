unit U_PubLocale;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, MySQLComponent, ComCtrls,
  MPlayer, Spin, DateUtils, BASS;

type
  TPubLocale = class(TForm)
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
    WhileStop: Boolean;
    x: Integer;
  end;
  TStringGridX = class(TStringGrid)
  public
    procedure MoveColumn(FromIndex, ToIndex: Longint);
    procedure MoveRow(FromIndex, ToIndex: Longint);
    { Déclarations publiques }
  end;

var
  PubLocale: TPubLocale;

implementation

uses U_Welcome, U_Bibliotheque, U_Jingles, U_Waitlist;

{$R *.dfm}

procedure AddToStringGrid(DateTime: TDateTime);
var
  Res, Res2, Res3, Res4: PMYSQL_RES;
  Row, Row2, Row3, Row4: PMYSQL_ROW;
  i, j: Integer;
  RequeteSQL, ID, Artiste, Titre, Path, DureeRestante, DateEcranToSQL: string;
begin

  Res := welcome.sql.Query('SELECT id, stationName FROM stations;');
  Row := welcome.sql.fetch_row(Res);
  while Row <> nil do
  begin
  // Boucle sur les stations locales

    publocale.debug.Lines.Add('Station : ' + Row[1]);

    RequeteSQL := 'SELECT SUBSTRING(duree, 1, (CHAR_LENGTH(duree)-3)) as miniduree , heure, minute, seconde ';
    RequeteSQL := RequeteSQL + 'FROM grillepub WHERE heure=''' + FormatDateTime('hh', DateTime) + ''';';

    Res2 := welcome.sql.Query(RequeteSQL);

    Row2 := welcome.sql.fetch_row(Res2);
    while Row2 <> nil do
    begin
  // Boucle sur les écrans

      publocale.debug.Lines.Add('Taille de l''écran : ' + Row2[0]);
      j := 0;
      // Il y aura max (secondes) d'écrans. Exemple, 180 secondes = max 180 fichiers de 1'.
      for i := 1 to StrToInt(Row2[0]) do
      begin

        if j >= StrToInt(Row2[0]) then
        begin
          publocale.debug.Lines.Add('Ecran complet: ' + IntToStr(j));
          Break;
        end;

        // Find A Campaign
        DureeRestante := IntToStr(StrToInt(Row2[0]) - j);
        DateEcranToSQL := FormatDateTime('yyyy-MM-dd', DateTime) + ' ' + FormatDateTime('h', DateTime) + ':' + Row2[2] + ':00';

        RequeteSQL := 'SELECT id,annonceur,campagne,mediaid,duree ';
        RequeteSQL := RequeteSQL + 'FROM campagnes WHERE valide=1 AND (';
        RequeteSQL := RequeteSQL + 'date_debut <= ''' + FormatDateTime('yyyy-MM-dd', DateTime) + ''' AND ';
        RequeteSQL := RequeteSQL + 'date_fin >= ''' + FormatDateTime('yyyy-MM-dd', DateTime) + ''') ';
        RequeteSQL := RequeteSQL + 'AND diffusions_count <> 0 ';
        RequeteSQL := RequeteSQL + 'AND (station=' + Row[0] + ' OR station=0) ';
        RequeteSQL := RequeteSQL + 'AND (duree<=' + DureeRestante + ') AND date_dernier_ecran <> ''' + DateEcranToSQL + ''' ';
        RequeteSQL := RequeteSQL + 'ORDER by Rand() LIMIT 1;';

        Res3 := welcome.sql.Query(RequeteSQL);
        Row3 := welcome.sql.fetch_row(Res3);

        if Row3 = nil then
        begin

          // If Nil, Check Carpette.
          publocale.debug.Lines.Add('Pas de campagne trouvée pour la durée ' + DureeRestante);

          // Modulo de 5' Mod(Duree, 5) = 0.
          RequeteSQL := 'SELECT playlist.ID, artistes.Name AS artiste, playlist.Titre, playlist.Duree, playlist.Path ';
          RequeteSQL := RequeteSQL + 'FROM playlist ';
          RequeteSQL := RequeteSQL + 'LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
          RequeteSQL := RequeteSQL + 'WHERE playlist.Categorie=6 AND playlist.Duree<=''' + DureeRestante + '.00'' AND Mod(playlist.Duree, 5.00) = 0 ';
          RequeteSQL := RequeteSQL + 'AND playlist.Valide ORDER by playlist.Duree DESC, Rand() LIMIT 1;';

          Res4 := welcome.sql.Query(RequeteSQL);
          Row4 := welcome.sql.fetch_row(Res4);
          if Row4 = nil then
          begin
            publocale.debug.Lines.Add('Comblage  : PAS DE DURÉE TROUVÉE : ' + DureeRestante);
          end
          else
          begin
            Artiste := Row4[1];
            Titre := Row4[2];
            Path := Row4[4];


            PubLocale.StringGrid1.Cells[0, PubLocale.x] := Row4[0]; // ID
            PubLocale.StringGrid1.Cells[1, PubLocale.x] := FormatDateTime('yyyy-MM-dd', DateTime); // Date
            PubLocale.StringGrid1.Cells[2, PubLocale.x] := FormatDateTime('h', DateTime); // Heure
            PubLocale.StringGrid1.Cells[3, PubLocale.x] := Row2[2]; // Minute
            PubLocale.StringGrid1.Cells[4, PubLocale.x] := Row2[3]; // Seconde
            PubLocale.StringGrid1.Cells[5, PubLocale.x] := Row[0]; // Station
            PubLocale.StringGrid1.Cells[6, PubLocale.x] := Artiste; // ARTISTE
            PubLocale.StringGrid1.Cells[7, PubLocale.x] := Titre; // TITRE
            PubLocale.StringGrid1.Cells[8, PubLocale.x] := Row4[3]; // Duree
            PubLocale.StringGrid1.Cells[9, PubLocale.x] := Path; // Fichier ?
            PubLocale.x := PubLocale.x + 1;
            PubLocale.StringGrid1.RowCount := PubLocale.x;

            publocale.debug.Lines.Add('Comblage : ' + Artiste + ' ' + Titre + ' (' + Row4[3] + ')');

            j := j + StrToInt(Row4[3]);
            welcome.sql.free_result(Res3); // Libère la mémoire

          end;

          Application.ProcessMessages;

        end
        else
        begin

          publocale.debug.Lines.Add('Campagne trouvée: ' + Row3[1] + ' (' + Row3[4] + ')');

          Res4 := welcome.sql.Query('SELECT playlist.ID, artistes.Name, playlist.Titre, playlist.Path FROM playlist LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) WHERE playlist.ID=' + Row3[3] + ';');
          Row4 := welcome.sql.fetch_row(Res4);
          if Row4 = nil then
          begin
            publocale.debug.Lines.Add('Campagne: ' + Row3[1] + ' (' + Row3[2] + ') : MEDIA NON TROUVÉ !');
            Showmessage('Campagne: ' + Row3[1] + ' (' + Row3[2] + ') : MEDIA NON TROUVÉ !');
          end
          else
          begin
            ID := Row4[0];
            Artiste := Row4[1];
            Titre := Row4[2];
            Path := Row4[3];
          end;

          PubLocale.StringGrid1.Cells[0, PubLocale.x] := ID; // ID
          PubLocale.StringGrid1.Cells[1, PubLocale.x] := FormatDateTime('yyyy-MM-dd', DateTime); // Date
          PubLocale.StringGrid1.Cells[2, PubLocale.x] := FormatDateTime('h', DateTime); // Heure
          PubLocale.StringGrid1.Cells[3, PubLocale.x] := Row2[2]; // Minute
          PubLocale.StringGrid1.Cells[4, PubLocale.x] := Row2[3]; // Seconde
          PubLocale.StringGrid1.Cells[5, PubLocale.x] := Row[0]; // Station
          PubLocale.StringGrid1.Cells[6, PubLocale.x] := Artiste; // ARTISTE
          PubLocale.StringGrid1.Cells[7, PubLocale.x] := Titre; // TITRE
          PubLocale.StringGrid1.Cells[8, PubLocale.x] := Row3[4]; // Duree
          PubLocale.StringGrid1.Cells[9, PubLocale.x] := Path; // Fichier ?
          PubLocale.x := PubLocale.x + 1;
          PubLocale.StringGrid1.RowCount := PubLocale.x;

          j := j + StrToInt(Row3[4]);
          welcome.sql.free_result(Res3); // Libère la mémoire
          welcome.sql.Query('UPDATE campagnes SET date_dernier_ecran=''' + DateEcranToSQL + ''' WHERE id=' + Row3[0] + ';');
          Application.ProcessMessages;

        end;


      end;

  // Fin de boucle sur les écrans
      Row2 := welcome.sql.fetch_row(Res2);
    end;
    welcome.sql.free_result(Res2);

  // Fin de boucle sur les stations
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
    PubLocale.debug.Lines.Add('Comblé du ' + DateToStr(dt) + ' à ' + TimeToStr(TimeOf(dt)) + '...');
    AddToStringGrid(dt);
    PubLocale.debug.Lines.Add('OK');
    dt := IncHour(dt, 1);
    Application.ProcessMessages;


    if (PubLocale.WhileStop = True) then
    begin
      PubLocale.WhileStop := False;
      Exit;
    end;

  end;
end;

procedure Delete(const DateDebut, DateFin: TDateTime);
var
  Res: PMYSQL_RES;
begin
  publocale.debug.Lines.Add('Delete du ' + DateToStr(DateDebut) + ' à ' + TimeToStr(TimeOf(DateDebut)) + ' au ' + DateToStr(DateFin) + ' à ' + TimeToStr(TimeOf(DateFin)) + '... ok');
  Res := welcome.sql.Query('DELETE FROM pub_locales WHERE Date_Play >= ''' + FormatDateTime('yyyy-MM-dd hh', DateDebut) + ':00:00' + ''' AND Date_Play <= ''' + FormatDateTime('yyyy-MM-dd hh', DateFin) + ':59:59' + ''';');
  welcome.sql.free_result(Res);
end;

procedure TPubLocale.BitBtn3Click(Sender: TObject);
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

procedure TPubLocale.BitBtn2Click(Sender: TObject);
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
      RequestSQL := 'INSERT INTO pub_locales SET PlaylistID=' + StringGrid1.cells[0, i] + ', Station=' + StringGrid1.cells[5, i] + ', Joue=0, Date_Insert=NOW(), Date_Play=''' + DatePlay + ''';';
      welcome.Sql.query(RequestSQL);
      welcome.sql.Query('UPDATE campagnes SET diffusions_count=diffusions_count-1 WHERE id=' + StringGrid1.cells[0, i] + ';');
      debug.Lines.Add('Ajout de ' + StringGrid1.cells[6, i] + ' ' + StringGrid1.cells[7, i]);
    end;
    StatusBar1.Panels[0].Text := IntToStr(i) + ' fichiers ajoutés aux émetteurs avec succès';

  end;

  BitBtn3.Click;
end;

procedure TPubLocale.BitBtn1Click(Sender: TObject);
begin
  TStringGridX(StringGrid1).MoveRow(StringGrid1.Row, StringGrid1.Row - 1);
end;

procedure TPubLocale.BitBtn6Click(Sender: TObject);
begin
  TStringGridX(StringGrid1).MoveRow(StringGrid1.Row, StringGrid1.Row + 1);
end;

procedure TPubLocale.BitBtn5Click(Sender: TObject);
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

procedure TPubLocale.FormCreate(Sender: TObject);
begin
  StringGrid1.ColCount := 10;
  StringGrid1.ColWidths[0] := 0;
  StringGrid1.ColWidths[1] := 65;
  StringGrid1.ColWidths[2] := 25;
  StringGrid1.ColWidths[3] := 25;
  StringGrid1.ColWidths[4] := 25;
  StringGrid1.ColWidths[5] := 100;
  StringGrid1.ColWidths[6] := 250;
  StringGrid1.ColWidths[7] := 250;
  StringGrid1.ColWidths[8] := 25;
  StringGrid1.ColWidths[9] := 250;

  dateIn.DateTime := Now();
  dateOut.DateTime := Now();
end;

procedure TPubLocale.generateClick(Sender: TObject);
var
  dtDebut, dtFin: TDateTime;
begin
  dtDebut := IncHour(DateOf(DateIN.Date), TimeIN.Value);
  dtFin := IncHour(DateOf(DateOUT.Date), TimeOUT.Value + 1);
  Traitement(dtDebut, dtFin);
end;

procedure TPubLocale.supprimerClick(Sender: TObject);
var
  dtDebut, dtFin: TDateTime;
begin
  dtDebut := IncHour(DateOf(DateIN.Date), TimeIN.Value);
  dtFin := IncHour(DateOf(DateOUT.Date), TimeOUT.Value);
  Delete(dtDebut, dtFin);
end;

procedure TPubLocale.consulterClick(Sender: TObject);

var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
  DatePlayIN, DatePlayOUT, RequestSQL: string;
begin

  DatePlayIN := FormatDateTime('yyyy-MM-dd', DateIN.Date) + ' ' + IntToStr(TimeIN.Value) + ':00:00';
  DatePlayOUT := FormatDateTime('yyyy-MM-dd', DateOUT.Date) + ' ' + IntToStr(TimeOUT.Value) + ':59:59';

  RequestSQL := 'SELECT pub_locales.Id, DATE_FORMAT(pub_locales.Date_Play, ''%Y-%m-%d'') AS Day, ';
  RequestSQL := RequestSQL + 'DATE_FORMAT(pub_locales.Date_Play, ''%H'') AS Hour, ';
  RequestSQL := RequestSQL + 'DATE_FORMAT(pub_locales.Date_Play, ''%i'') AS Minute, ';
  RequestSQL := RequestSQL + 'DATE_FORMAT(pub_locales.Date_Play, ''%s'') AS Seconde, ';
  RequestSQL := RequestSQL + 'pub_locales.Station, artistes.Name AS artiste, playlist.Titre, playlist.Duree, playlist.Path ';
  RequestSQL := RequestSQL + 'FROM pub_locales ';
  RequestSQL := RequestSQL + 'LEFT JOIN playlist ON (playlist.ID=pub_locales.PlaylistID) ';
  RequestSQL := RequestSQL + 'LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
  RequestSQL := RequestSQL + 'WHERE pub_locales.Date_Play >= ''' + DatePlayIN + ''' AND pub_locales.Date_Play <= ''' + DatePlayOUT + ''' ';
  RequestSQL := RequestSQL + 'ORDER by pub_locales.Date_Play ASC;';

  Res := Welcome.Sql.Query(RequestSQL);

  if Res = nil then begin
    StatusBar1.Panels[0].Text := 'Pas de pubs pour la date donnée';
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

procedure TPubLocale.BitBtn7Click(Sender: TObject);
begin
  supprimer.Click;
  BitBtn2.Click;
end;

procedure TPubLocale.BitBtn4Click(Sender: TObject);
begin
  WhileStop := True;
end;

end.
