unit U_Waitlist;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, MySQLComponent, ComCtrls,
  Spin, DateUtils, BASS, Printers, Menus, JvExButtons, JvBitBtn, Registry;

const
  SecPerDay = 86400;
  SecPerHour = 3600;
  SecPerMinute = 60;

type
  Twaitlist = class(TForm)
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
    BitBtn4: TBitBtn;
    BitBtn8: TBitBtn;
    play: TBitBtn;
    Stop: TBitBtn;
    titre: TLabel;
    autoplay: TCheckBox;
    BitBtn7: TBitBtn;
    BitBtn9: TBitBtn;
    SpeedButton1: TSpeedButton;
    SaveDialog1: TSaveDialog;
    SpeedButton2: TSpeedButton;
    PrintDialog1: TPrintDialog;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    Calculate: TBitBtn;
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure generateClick(Sender: TObject);
    procedure supprimerClick(Sender: TObject);
    procedure consulterClick(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure playClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StringGrid1Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure CalculateClick(Sender: TObject);
  private
    { Déclarations privées }
    x: Integer;
    Preecoute: Integer;
    WhileStop: Boolean;
    VoiceTrackID: Integer;
    VoiceTrackPath: string;
    procedure PrintGrid(const Grid: TStringGrid; const Title: string; Orientation: TPrinterOrientation);
    procedure GetZoneImpressionInPixels(PrinterHandle: HDC; var Height, Width: Integer);
  public
    function GetDecallPrevious(): Double;
    function CalculateWaitlist(Hour: string): Double;
  end;
  TStringGridX = class(TStringGrid)
  public
    procedure MoveColumn(FromIndex, ToIndex: Longint);
    procedure MoveRow(FromIndex, ToIndex: Longint);
    procedure InsertRow(ARow: Longint);
    { Déclarations publiques }
  end;

var
  waitlist: Twaitlist;

implementation

uses U_Welcome, U_Bibliotheque, U_Jingles;

{$R *.dfm}

function SecondToTime(const Seconds: Cardinal): Double;
var
  ms, ss, mm, hh, dd: Cardinal;
begin
  dd := Seconds div SecPerDay;
  hh := (Seconds mod SecPerDay) div SecPerHour;
  mm := ((Seconds mod SecPerDay) mod SecPerHour) div SecPerMinute;
  ss := ((Seconds mod SecPerDay) mod SecPerHour) mod SecPerMinute;
  ms := 0;
  Result := dd + EncodeTime(hh, mm, ss, ms);
end;

procedure XlsWriteCellLabel(XlsStream: TStream; const ACol, ARow: Word;
  const AValue: string);
var
  L: Word;
const
{$J+}
  CXlsLabel: array[0..5] of Word = ($204, 0, 0, 0, 0, 0);
{$J-}
begin
  L := Length(AValue);
  CXlsLabel[1] := 8 + L;
  CXlsLabel[2] := ARow;
  CXlsLabel[3] := ACol;
  CXlsLabel[5] := L;
  XlsStream.WriteBuffer(CXlsLabel, SizeOf(CXlsLabel));
  XlsStream.WriteBuffer(Pointer(AValue)^, L);
end;

function SaveAsExcelFile(AGrid: TStringGrid; AFileName: string): Boolean;
const
{$J+}CXlsBof: array[0..5] of Word = ($809, 8, 00, $10, 0, 0); {$J-}
  CXlsEof: array[0..1] of Word = ($0A, 00);
var
  FStream: TFileStream;
  I, J: Integer;
begin
  FStream := TFileStream.Create(PChar(AFileName), fmCreate or fmOpenWrite);
  try
    CXlsBof[4] := 0;
    FStream.WriteBuffer(CXlsBof, SizeOf(CXlsBof));
    for i := 0 to AGrid.ColCount - 1 do
      for j := 0 to AGrid.RowCount - 1 do
        XlsWriteCellLabel(FStream, I, J, AGrid.cells[i, j]);
    FStream.WriteBuffer(CXlsEof, SizeOf(CXlsEof));
    Result := True;
  finally
    FStream.Free;
  end;
end;

function twaitlist.GetDecallPrevious(): Double;
var
  Decall: Double;
begin
  Decall := 0;
  // Protection 0
  if (waitlist.x <> 0) then
  begin
  // Si la Decall du précédent est vide
    if (waitlist.StringGrid1.Cells[16, (waitlist.x - 1)] = '') then
    begin
      Decall := 0;
    end
    else
    begin
      Decall := StrToFloat(StringReplace(waitlist.StringGrid1.cells[16, (waitlist.x - 1)], '.', ',', [rfReplaceAll]));
    end;
  end;
  Result := Decall;
end;

function Twaitlist.CalculateWaitlist(Hour: string): Double;
var i: Integer;
  Val: Double;
begin
  Val := 0;
  for i := 0 to StringGrid1.RowCount - 1 do
  begin
    if (Hour = StringGrid1.cells[2, i]) then
    begin
      if (i = 0) then
      begin
        StringGrid1.cells[16, i] := '0';
      end
      else
      begin
        Val := StrToFloat(StringReplace(StringGrid1.cells[16, (i - 1)], '.', ',', [rfReplaceAll])) + StrToFloat(StringReplace(StringGrid1.cells[6, i], '.', ',', [rfReplaceAll]));
        StringGrid1.cells[16, i] := StringReplace(FloatToStr(Val), ',', '.', [rfReplaceAll]);
      end;
    end;
  end;
  Result := Val;
end;

procedure AddToStringGrid(DateTime: TDateTime);
var
  Res1, Res2, Res3: PMYSQL_RES;
  Row1, Row2, Row3: PMYSQL_ROW;
  DayofHour, Hour, Canvas, RequestSQL, VoiceTrackName, HeureCurrent, DoublonCD, DoublonArtist, Select: string;
  DateCurrent: TDateTime;
  Decall, GetDecall, GetProtection: Double;
  days: array[1..7] of string;
begin

{ *********************************************************************** }
{                        INITALISATION VARIABLES                          }
{ *********************************************************************** }

  with TRegistry.Create do
  try
    OpenKey('Software\OpenStudio\Admin', true);
    if ValueExists('VoiceTrackPath') then waitlist.VoiceTrackPath := ReadString('VoiceTrackPath');
  finally
    Free;
  end;

  days[1] := 'dimanche';
  days[2] := 'lundi';
  days[3] := 'mardi';
  days[4] := 'mercredi';
  days[5] := 'jeudi';
  days[6] := 'vendredi';
  days[7] := 'samedi';

  Hour := FormatDateTime('hh', DateTime);
  DayofHour := days[DayOfWeek(DateTime)];

{ *********************************************************************** }
{                        SELECTION DU CANVAS                              }
{ *********************************************************************** }

  RequestSQL := 'SELECT canvas FROM planning WHERE ' + DayofHour + '=''1'' AND  (FromHour <= ''' + Hour + ''' AND ToHour >= ''' + Hour + ''');';
  Res1 := welcome.sql.Query(RequestSQL);

  if Res1 = nil then begin
    waitlist.debug.Lines.Add('Pas de canvas trouvé pour le ' + DayofHour + ' a ' + Hour + 'H.');
  end
  else
  try

{ *********************************************************************** }
{                  SELECTION DU CANVAS A UTILISER                         }
{ *********************************************************************** }

    Row1 := welcome.sql.fetch_row(Res1);
    while Row1 <> nil do
    begin
      Canvas := Row1[0];
      waitlist.debug.Lines.Add('Canvas utilisé : ' + Canvas);
      Row1 := welcome.sql.fetch_row(Res1);
    end;

  finally
    welcome.sql.free_result(Res1);
  end;

{ *********************************************************************** }
{                  SELECTION DES CATAGORIES DU CANVAS                     }
{ *********************************************************************** }

  waitlist.VoiceTrackID := 1; // reset variable voicetrack - nouvelle heure commence.

  Res2 := welcome.sql.Query('SELECT Categorie, SScategorie, protectioncd, protectionartist FROM canvas WHERE format=''' + Canvas + ''' ORDER by ID ASC;');
  Row2 := welcome.sql.fetch_row(Res2);
  while Row2 <> nil do
  begin

{ *********************************************************************** }
{                        DEBUT DU CANVAS                                  }
{                          VOICE TRACK                                    }
{ *********************************************************************** }

    if (Row2[0] = 'INTERVENTION') then
    begin
      VoiceTrackName := 'I-' + FormatDateTime('yyyy-MM-dd', DateTime) + '-' + FormatDateTime('hh', DateTime) + '-' + IntToStr(waitlist.VoiceTrackID) + '.WAV';
      waitlist.VoiceTrackID := waitlist.VoiceTrackID + 1;
      waitlist.StringGrid1.Cells[0, waitlist.x] := ''; // ID
      waitlist.StringGrid1.Cells[1, waitlist.x] := FormatDateTime('yyyy-MM-dd', DateTime); // Date
      waitlist.StringGrid1.Cells[2, waitlist.x] := FormatDateTime('hh', DateTime); // Heure
      waitlist.StringGrid1.Cells[3, waitlist.x] := 'INTERVENTION'; // ARTISTE
      waitlist.StringGrid1.Cells[4, waitlist.x] := Uppercase(VoiceTrackName); // TITRE

      waitlist.StringGrid1.Cells[5, waitlist.x] := FormatDateTime('yyyy', DateTime); // Année
      waitlist.StringGrid1.Cells[6, waitlist.x] := '0'; // Duree
      waitlist.StringGrid1.Cells[7, waitlist.x] := '0'; // Frequence ?
      waitlist.StringGrid1.Cells[8, waitlist.x] := '0'; // Tempo ?
      waitlist.StringGrid1.Cells[9, waitlist.x] := '0'; // Intro
      waitlist.StringGrid1.Cells[10, waitlist.x] := '0'; // Fade IN ?
      waitlist.StringGrid1.Cells[11, waitlist.x] := '0'; // Fade Out

      waitlist.StringGrid1.Cells[12, waitlist.x] := waitlist.VoiceTrackPath + VoiceTrackName; // Fichier ?
      waitlist.StringGrid1.Cells[13, waitlist.x] := 'INTERVENTION'; // Cat
      waitlist.StringGrid1.Cells[14, waitlist.x] := ''; // ssCat
      waitlist.StringGrid1.Cells[15, waitlist.x] := ''; // ArtistID
      waitlist.StringGrid1.Cells[16, waitlist.x] := ''; // Decall
      waitlist.x := waitlist.x + 1;
      waitlist.StringGrid1.RowCount := waitlist.x;
    end
    else
    begin

{ *********************************************************************** }
{           RECHERCHER UN CD PAS ENCORE DIFFUSE                           }
{ *********************************************************************** }

        //GetDecall := waitlist.GetDecallPrevious();
        //GetProtection := StrToFloat(Row2[2]);
        //DateCurrent := (DateTime + SecondToTime(Trunc(GetDecall))) - SecondToTime(Trunc(GetProtection));

      if (Row2[2]<>'0') then DoublonCD := ' AND playlist.Date_Joue < SUBDATE(''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', DateTime) + ''', INTERVAL '+Row2[2]+' SECOND) ' else  DoublonCD:='';
      //if (Row2[3]<>'0') then DoublonArtist := ' AND artistes.LastBroadcasting < SUBDATE(''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', DateTime) + ''', INTERVAL '+Row2[3]+'  SECOND) ' else  DoublonArtist:='';
      DoublonArtist:='';

      Select := 'SELECT playlist.Id, artistes.Name AS artiste, playlist.Titre, playlist.Annee, playlist.Duree, ';
      Select := Select + 'playlist.Frequence, playlist.Tempo, playlist.Intro, playlist.FadeIn, playlist.FadeOut, playlist.Path, ';
      Select := Select + 'playlist.Categorie, playlist.ssCategorie, playlist.Artiste ';
      Select := Select + 'FROM playlist LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
      Select := Select + 'WHERE FadeOut >= 4.00 AND playlist.Categorie=' + Row2[0] + ' AND playlist.ssCategorie=' + Row2[1] + ' AND playlist.Valide ' + DoublonCD + DoublonArtist;
      Select := Select + 'ORDER by Rand() LIMIT 1;';
      //ShowMessage(Select);
      Res3 := welcome.Sql.Query(Select);
      Row3 := welcome.Sql.fetch_row(Res3);

      if Row3 = nil then
      begin
        waitlist.debug.Lines.Add('Pas de titre trouvé dans la catégorie ' + Row2[0] + ' ' + Row2[1]);
      end
      else
      begin

{ *********************************************************************** }
{                    CALCUL DATE DE PASSAGE                               }
{    HeureCurrent = Approximation (sans écrans pub) de l'heure de passage }
{ *********************************************************************** }
        Decall := 0;
        // Protection 0
        if (waitlist.x <> 0) then
        begin
          // Si l'heure est bien égale
          if (FormatDateTime('hh', DateTime) = waitlist.StringGrid1.cells[2, (waitlist.x - 1)]) then
          begin
            // Si la Decall du précédent est vide
            if (waitlist.StringGrid1.Cells[16, (waitlist.x - 1)] = '') then
            begin
              Decall := StrToFloat(StringReplace(Row3[4], '.', ',', [rfReplaceAll]));
            end
            else
            begin
              Decall := StrToFloat(StringReplace(waitlist.StringGrid1.cells[16, (waitlist.x - 1)], '.', ',', [rfReplaceAll])) + StrToFloat(StringReplace(Row3[4], '.', ',', [rfReplaceAll]));
            end;
          end
          else
          begin
            Decall := 0; // Premier de l'heure.
          end;
        end;

        if (Decall >= 3600) then
        begin
          HeureCurrent := FormatDateTime('hh', DateTime) + ':59:59';
        end
        else
        begin
          HeureCurrent := FormatDateTime('hh', DateTime) + format(':%2.2d:%2.2d', [trunc(Decall) div 60, trunc(Decall) mod 60]);
        end;

{ *********************************************************************** }
{             MISE A JOUR DE L'HEURE DE PASSAGE                          }
{ *********************************************************************** }

        HeureCurrent := FormatDateTime('yyyy-mm-dd hh:mm:ss', DateTime);
        welcome.Sql.query('UPDATE artistes SET LastBroadcasting='''+ HeureCurrent +''' WHERE ID='+ Row3[13] +';');
        welcome.sql.query('UPDATE playlist SET Date_Joue=''' + HeureCurrent + ''' WHERE ID='+ Row3[0] +';');

        //waitlist.debug.Lines.Add('Protection doublon. Artist: ' + Row3[13] + ' / Titre: ' + Row3[0] + ' / ' + HeureCurrent);

{ *********************************************************************** }
{                    AJOUT EN STRINGGRID                                  }
{ *********************************************************************** }

        waitlist.StringGrid1.Cells[0, waitlist.x] := Row3[0]; // ID
        waitlist.StringGrid1.Cells[1, waitlist.x] := FormatDateTime('yyyy-MM-dd', DateTime); // Date
        waitlist.StringGrid1.Cells[2, waitlist.x] := FormatDateTime('hh', DateTime); // Heure
        waitlist.StringGrid1.Cells[3, waitlist.x] := Row3[1]; // ARTISTE
        waitlist.StringGrid1.Cells[4, waitlist.x] := Row3[2]; // TITRE
        waitlist.StringGrid1.Cells[5, waitlist.x] := Row3[3]; // Année
        waitlist.StringGrid1.Cells[6, waitlist.x] := Row3[4]; // Duree
        waitlist.StringGrid1.Cells[7, waitlist.x] := Row3[5]; // Frequence ?
        waitlist.StringGrid1.Cells[8, waitlist.x] := Row3[6]; // Tempo ?
        waitlist.StringGrid1.Cells[9, waitlist.x] := Row3[7]; // Intro
        waitlist.StringGrid1.Cells[10, waitlist.x] := Row3[8]; // Fade IN ?
        waitlist.StringGrid1.Cells[11, waitlist.x] := Row3[9]; // Fade Out
        waitlist.StringGrid1.Cells[12, waitlist.x] := Row3[10]; // Fichier ?
        waitlist.StringGrid1.Cells[13, waitlist.x] := Row3[11]; // Cat
        waitlist.StringGrid1.Cells[14, waitlist.x] := Row3[12]; // ssCat
        waitlist.StringGrid1.Cells[15, waitlist.x] := Row3[13]; // ArtisteID

{ *********************************************************************** }
{                    CALCUL DU DECALLAGE                                  }
{ *********************************************************************** }

        if (waitlist.x <> 0) then
        begin
          if (waitlist.StringGrid1.cells[16, (waitlist.x - 1)] <> '') then
          begin
            if (waitlist.StringGrid1.Cells[2, waitlist.x] = waitlist.StringGrid1.Cells[2, (waitlist.x - 1)]) then
            begin
              waitlist.StringGrid1.Cells[16, waitlist.x] := StringReplace(FloatToStr(StrToFloat(StringReplace(waitlist.StringGrid1.cells[16, (waitlist.x - 1)], '.', ',', [rfReplaceAll])) + StrToFloat(StringReplace(waitlist.StringGrid1.cells[6, waitlist.x], '.', ',', [rfReplaceAll]))), ',', '.', [rfReplaceAll]); // Decallage
            end
            else
            begin
              waitlist.StringGrid1.Cells[16, waitlist.x] := '0';
            end;
          end
          else
          begin
            waitlist.StringGrid1.Cells[16, waitlist.x] := waitlist.StringGrid1.cells[6, waitlist.x];
          end;
        end
        else
        begin
          waitlist.StringGrid1.Cells[16, waitlist.x] := '0';
        end;

{ *********************************************************************** }
{                        FIN                                              }
{ *********************************************************************** }


        waitlist.x := waitlist.x + 1;
        waitlist.StringGrid1.RowCount := waitlist.x;

        welcome.sql.free_result(Res3);
        Application.ProcessMessages;

      end;

    end;

  // Fin ittération canvas
    Row2 := welcome.sql.fetch_row(Res2);
  end;
  welcome.sql.free_result(Res2);
  Application.ProcessMessages;

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

procedure Traitement(const DateDebut, DateFin: TDateTime);
var
  dt: TDateTime;
begin
  dt := DateDebut;

  while (dt < DateFin) do
  begin
    waitlist.debug.Lines.Add('Généré du ' + DateToStr(dt) + ' à ' + TimeToStr(TimeOf(dt)) + '...');
    AddToStringGrid(dt);
    waitlist.debug.Lines.Add('OK');
    dt := IncHour(dt, 1);
    Application.ProcessMessages;

    if (waitlist.WhileStop = True) then
    begin
      waitlist.WhileStop := False;
      Exit;
    end;
  end;
end;

procedure Delete(const DateDebut, DateFin: TDateTime);
var
  Res: PMYSQL_RES;
begin
  waitlist.debug.Lines.Add('Delete du ' + DateToStr(DateDebut) + ' à ' + TimeToStr(TimeOf(DateDebut)) + ' au ' + DateToStr(DateFin) + ' à ' + TimeToStr(TimeOf(DateFin)) + '... ok');
  Res := welcome.sql.Query('DELETE FROM waitlist WHERE Date_Play >= ''' + FormatDateTime('yyyy-MM-dd hh', DateDebut) + ':00:00' + ''' AND Date_Play <= ''' + FormatDateTime('yyyy-MM-dd hh', DateFin) + ':59:59' + ''';');
  welcome.sql.free_result(Res);
end;

procedure Twaitlist.BitBtn3Click(Sender: TObject);
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

procedure Twaitlist.BitBtn2Click(Sender: TObject);
var
  i: Integer;
  DatePlay, sqlQuery: string;
begin

  if welcome.sql.Connected = False then
  begin
    ShowMessage('Vous devez être connecté au serveur MySQL.');
  end
  else
  begin

    for i := 0 to StringGrid1.RowCount - 1 do
    begin
      DatePlay := StringGrid1.cells[1, i] + ' ' + StringGrid1.cells[2, i] + ':00:00';
      sqlQuery := 'INSERT INTO waitlist SET PlaylistID=' + StringGrid1.cells[0, i] + ', Frequence=''' + StringGrid1.cells[7, i] + ''', Tempo=''' + StringGrid1.cells[8, i] + ''',  Intro=''' + StringGrid1.cells[9, i] + ''', FadeIn=''' + StringGrid1.cells[10, i] + ''', FadeOut=''' + StringGrid1.cells[11, i] + ''', Joue=0, Date_Play=''' + DatePlay + ''', Date_Insert=NOW(), Date_Mod=NOW();';
      welcome.Sql.query(sqlQuery);
    end;

    StatusBar1.Panels[0].Text := IntToStr(i) + ' fichiers ajoutés à la waitlist avec succès';

  end;

  BitBtn3.Click;
end;

procedure Twaitlist.PrintGrid(const Grid: TStringGrid; const Title: string; Orientation: TPrinterOrientation);
var
  iLOGPIXELSX, iRow, iCol, iWidth, iHeight, X, Y, iPage: integer;
  R: TRect;
  sz: string;
  bDoCenter: boolean;

  procedure PrintTitle;
  var
    iTextW: integer;
    szPage: string;
  begin
    // Titre
    Printer.Canvas.Pen.Color := 0;
    Printer.Canvas.Font.Name := 'Times New Roman';
    Printer.Canvas.Font.Size := 12;
    Printer.Canvas.Font.Style := [fsBold];
    iTextW := Printer.Canvas.TextWidth(Title);
    Printer.Canvas.TextOut((iWidth - iTextW) div 2, 100, Title);

    // N° de page
    Printer.Canvas.Font.Style := [];
    szPage := '- ' + IntToStr(iPage) + ' -';
    iTextW := Printer.Canvas.TextWidth(szPage);
    Printer.Canvas.TextOut((iWidth - iTextW) div 2, iHeight - 90, szPage);

    // Utilise la police de la grille (Pour l'impression des cellules)
    Printer.Canvas.Font.Name := Grid.Font.Name;
    Printer.Canvas.Font.Size := Grid.Font.Size;
    Printer.Canvas.Font.Style := Grid.Font.Style;
  end;

  function GetValue(const Value: integer): integer;
  begin
    Result := MulDiv(Value, iLOGPIXELSX, Self.PixelsPerInch);
  end;

begin
  GetZoneImpressionInPixels(Printer.Handle, iHeight, iWidth);

  // Récupère la résolution de l'écran
  iLOGPIXELSX := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
  iPage := 1;

  Printer.Title := Title;
  Printer.BeginDoc;

  // Titre
  PrintTitle;

  // Initialise le rectangle
  FillChar(R, SizeOf(TRect), #0);
  R.Bottom := 300;

  // Parcours toutes les lignes
  for iRow := 0 to Grid.RowCount - 1 do begin
    R.Right := 0;
    R.Top := R.Bottom;
    R.Bottom := R.Top + GetValue(Grid.RowHeights[iRow]);

    // Pour l'impression des titres de colonne
    bDoCenter := (iRow = 0) and (Grid.FixedRows > 0);

    // Page suivante
    if (R.Bottom > iHeight) then begin
      inc(iPage);
      Printer.NewPage;
      PrintTitle;
      R.Top := 0;
      R.Bottom := R.Top + GetValue(Grid.RowHeights[iRow]);
    end;

    // Parcours toutes les colonnes
    for iCol := 0 to Grid.ColCount - 1 do begin
      // Rectangle d'impression
      R.Left := R.Right;
      R.Right := R.Left + GetValue(Grid.ColWidths[iCol]);

      // Texte à imprimer
      sz := Grid.Cells[iCol, iRow];

      // Imprime le texte
      Y := R.Top + ((R.Bottom - R.Top - Printer.Canvas.TextHeight(sz)) div 2);
      if bDoCenter then X := R.Left + ((R.Right - R.Left - Printer.Canvas.TextWidth(sz)) div 2)
      else X := R.Left + 10;
      Printer.Canvas.TextRect(R, X, Y, sz);
      Printer.Canvas.MoveTo(R.Left, R.Top);
      Printer.Canvas.LineTo(R.Right, R.Top);
      Printer.Canvas.LineTo(R.Right, R.Bottom);
      Printer.Canvas.LineTo(R.Left, R.Bottom);
      Printer.Canvas.LineTo(R.Left, R.Top);
    end;
  end;
  Printer.EndDoc;
end;

//====================================================================================================

procedure Twaitlist.GetZoneImpressionInPixels(PrinterHandle: HDC; var Height, Width: integer);
begin
  Height := GetDeviceCaps(PrinterHandle, VERTRES);
  Width := GetDeviceCaps(PrinterHandle, HORZRES);
end;



procedure Twaitlist.BitBtn1Click(Sender: TObject);
begin
  TStringGridX(StringGrid1).MoveRow(StringGrid1.Row, StringGrid1.Row - 1);
end;

procedure Twaitlist.BitBtn6Click(Sender: TObject);
begin
  TStringGridX(StringGrid1).MoveRow(StringGrid1.Row, StringGrid1.Row + 1);
end;

procedure Twaitlist.BitBtn5Click(Sender: TObject);
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

  if ((StringGrid1.Cells[3, StringGrid1.Row] = 'INTERVENTION') and (VoiceTrackID <> 1)) then VoiceTrackID := VoiceTrackID - 1;
end;

procedure Twaitlist.FormCreate(Sender: TObject);
begin
  StringGrid1.ColCount := 17;
  StringGrid1.ColWidths[0] := 0; // ID
  StringGrid1.ColWidths[1] := 65; // Date
  StringGrid1.ColWidths[2] := 25; // Heure
  StringGrid1.ColWidths[3] := 250; // Artiste Name
  StringGrid1.ColWidths[4] := 250; // Title
  StringGrid1.ColWidths[5] := 40; // Annee
  StringGrid1.ColWidths[6] := 40;  // Duree
  StringGrid1.ColWidths[7] := 0;   // Frequence
  StringGrid1.ColWidths[8] := 0;   // Tempo
  StringGrid1.ColWidths[9] := 40;  // Intro
  StringGrid1.ColWidths[10] := 40;  // Fade IN
  StringGrid1.ColWidths[11] := 40;   // Fade OUT
  StringGrid1.ColWidths[12] := 0;    // Path
  StringGrid1.ColWidths[13] := 0;    // Cat
  StringGrid1.ColWidths[14] := 0;    // SSCat
  StringGrid1.ColWidths[15] := 0; //  ArtisteID
  StringGrid1.ColWidths[16] := 50; //  decallage

  dateIn.DateTime := Now();
  dateOut.DateTime := Now();

  VoiceTrackID := 1;
end;

procedure Twaitlist.generateClick(Sender: TObject);
var
  dtDebut, dtFin: TDateTime;
begin
  dtDebut := IncHour(DateOf(DateIN.Date), TimeIN.Value);
  dtFin := IncHour(DateOf(DateOUT.Date), TimeOUT.Value + 1);
  Traitement(dtDebut, dtFin);
end;

procedure Twaitlist.supprimerClick(Sender: TObject);
var
  dtDebut, dtFin: TDateTime;
begin
  dtDebut := IncHour(DateOf(DateIN.Date), TimeIN.Value);
  dtFin := IncHour(DateOf(DateOUT.Date), TimeOUT.Value);
  Delete(dtDebut, dtFin);
end;

procedure Twaitlist.consulterClick(Sender: TObject);

var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
  DatePlayIN, DatePlayOUT, RequestSQL: string;
begin

  DatePlayIN := FormatDateTime('yyyy-MM-dd', DateIN.Date) + ' ' + IntToStr(TimeIN.Value) + ':00:00';
  DatePlayOUT := FormatDateTime('yyyy-MM-dd', DateOUT.Date) + ' ' + IntToStr(TimeOUT.Value) + ':59:59';

  RequestSQL := 'SELECT playlist.ID, DATE_FORMAT(waitlist.Date_Play, ''%Y-%m-%d'') AS Day, DATE_FORMAT(waitlist.Date_Play, ''%H'') AS Hour, artistes.Name AS artiste, playlist.Titre, playlist.Annee, playlist.Duree, ';
  RequestSQL := RequestSQL + 'waitlist.Frequence, waitlist.Tempo, waitlist.Intro, waitlist.FadeIn, waitlist.FadeOut, playlist.Path, ';
  RequestSQL := RequestSQL + 'playlist.Categorie, playlist.ssCategorie, playlist.Artiste, playlist.Duree ';
  RequestSQL := RequestSQL + 'FROM waitlist ';
  RequestSQL := RequestSQL + 'LEFT JOIN playlist ON (playlist.ID=waitlist.PlaylistID) ';
  RequestSQL := RequestSQL + 'LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
  RequestSQL := RequestSQL + 'WHERE waitlist.Date_Play >= ''' + DatePlayIN + ''' AND waitlist.Date_Play <= ''' + DatePlayOUT + ''' ';
  RequestSQL := RequestSQL + 'ORDER by waitlist.Date_Play ASC;';
  //ShowMessage(RequestSQL);
  Res := Welcome.Sql.Query(RequestSQL);

  if Res = nil then begin
    StatusBar1.Panels[0].Text := 'Pas de playlist pour la date donnée';
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

procedure Twaitlist.BitBtn4Click(Sender: TObject);
begin
  stop.Click;
  Bibliotheque.ShowModal;
end;

procedure Twaitlist.playClick(Sender: TObject);
begin
  BASS_ChannelStop(Preecoute);
  BASS_StreamFree(Preecoute);
  Preecoute := BASS_StreamCreateFile(False, Pchar(StringGrid1.cells[12, StringGrid1.Row]), 0, 0, 0);
  BASS_ChannelPlay(Preecoute, False);
  titre.Caption := StringGrid1.cells[3, StringGrid1.Row] + ' ' + StringGrid1.cells[4, StringGrid1.Row];
end;

procedure Twaitlist.StopClick(Sender: TObject);
begin
  BASS_ChannelStop(Preecoute);
end;

procedure Twaitlist.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  BASS_ChannelStop(Preecoute);
  BASS_StreamFree(Preecoute);
end;

procedure Twaitlist.StringGrid1Click(Sender: TObject);
begin
  if (autoplay.Checked) then play.Click;
end;

procedure Twaitlist.BitBtn7Click(Sender: TObject);
begin
  supprimer.Click;
  BitBtn2.Click;
end;

procedure Twaitlist.BitBtn8Click(Sender: TObject);
begin
  stop.Click;
  Jingles.ShowModal;
end;

procedure Twaitlist.BitBtn9Click(Sender: TObject);
var
  Res2: PMYSQL_RES;
  Row2: PMYSQL_ROW;
  Select: string;
begin

  Select := 'SELECT playlist.Id, artistes.Name AS artiste, playlist.Titre, playlist.Annee, playlist.Duree, ';
  Select := Select + 'playlist.Frequence, playlist.Tempo, playlist.Intro, playlist.FadeIn, playlist.FadeOut, playlist.Path, ';
  Select := Select + 'playlist.Categorie, playlist.ssCategorie, playlist.Artiste ';
  Select := Select + 'FROM playlist LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
  Select := Select + 'WHERE Valide AND playlist.Categorie=''' + StringGrid1.Cells[13, StringGrid1.Row] + ''' AND playlist.ssCategorie=''' + StringGrid1.Cells[14, StringGrid1.Row] + ''' ';
  Select := Select + 'ORDER by Rand() LIMIT 1;';

  Res2 := welcome.Sql.Query(Select);
  Row2 := welcome.Sql.fetch_row(Res2);

  if Row2 = nil then
  begin
    waitlist.StatusBar1.Panels[0].Text := 'Pas de titre trouvé dans la catégorie ' + StringGrid1.Cells[13, StringGrid1.Row] + ' ' + StringGrid1.Cells[14, StringGrid1.Row];
  end
  else
  begin

    waitlist.StringGrid1.Cells[0, StringGrid1.Row] := Row2[0]; // ID
      //waitlist.StringGrid1.Cells[1, StringGrid1.Row] := FormatDateTime('yyyy-MM-dd', DateTime); // Date
      //waitlist.StringGrid1.Cells[2, StringGrid1.Row] := FormatDateTime('hh', DateTime); // Heure
    waitlist.StringGrid1.Cells[3, StringGrid1.Row] := Row2[1]; // ARTISTE
    waitlist.StringGrid1.Cells[4, StringGrid1.Row] := Row2[2]; // TITRE
    waitlist.StringGrid1.Cells[5, StringGrid1.Row] := Row2[3]; // Année
    waitlist.StringGrid1.Cells[6, StringGrid1.Row] := Row2[4]; // Duree
    waitlist.StringGrid1.Cells[7, StringGrid1.Row] := Row2[5]; // Frequence ?
    waitlist.StringGrid1.Cells[8, StringGrid1.Row] := Row2[6]; // Tempo ?
    waitlist.StringGrid1.Cells[9, StringGrid1.Row] := Row2[7]; // Intro
    waitlist.StringGrid1.Cells[10, StringGrid1.Row] := Row2[8]; // Fade IN ?
    waitlist.StringGrid1.Cells[11, StringGrid1.Row] := Row2[9]; // Fade Out
    waitlist.StringGrid1.Cells[12, StringGrid1.Row] := Row2[10]; // Fichier ?
    waitlist.StringGrid1.Cells[13, StringGrid1.Row] := Row2[11]; // Cat
    waitlist.StringGrid1.Cells[14, StringGrid1.Row] := Row2[12]; // ssCat
    waitlist.StringGrid1.Cells[15, StringGrid1.Row] := Row2[13]; // ArtisteID

    //CalculateWaitlist(StringGrid1.Cells[2, StringGrid1.Row]);

    welcome.sql.free_result(Res2);

  end;
  if (autoplay.Checked) then play.Click;
end;

procedure Twaitlist.SpeedButton1Click(Sender: TObject);
begin
  if (not SaveDialog1.Execute) then Exit;
  SaveAsExcelFile(StringGrid1, SaveDialog1.FileName);
end;

procedure Twaitlist.SpeedButton2Click(Sender: TObject);
begin
  if (not PrintDialog1.Execute) then Exit;
  PrintGrid(StringGrid1, 'Playlist', poPortrait);
end;

procedure Twaitlist.BitBtn10Click(Sender: TObject);
begin
  WhileStop := True;
end;

procedure Twaitlist.BitBtn11Click(Sender: TObject);
var
  Reponse: string;
begin
  Reponse := InputBox('Commentaire', 'Entrez le commentaire ci dessous:', '');

  if Reponse = '' then
  begin
    StatusBar1.Panels[0].Text := 'Entrez un commentaire!';
  end
  else
  begin
    TStringGridX(StringGrid1).InsertRow(StringGrid1.Row);
    StringGrid1.Cells[3, StringGrid1.Row] := 'COMMENTAIRE'; // ARTISTE
    StringGrid1.Cells[4, StringGrid1.Row] := Uppercase(Reponse); // TITRE
  end;
end;

procedure Twaitlist.BitBtn12Click(Sender: TObject);
var
  Reponse, VoiceTrackName: string;
  Jour, Heure: string;
begin
  VoiceTrackName := 'I-' + StringGrid1.cells[1, StringGrid1.Row] + '-' + StringGrid1.cells[2, StringGrid1.Row] + '-' + IntToStr(VoiceTrackID) + '.WAV';
  Reponse := InputBox('Commentaire', 'Proposition de nom de fichier:', VoiceTrackName);

  if Reponse = '' then
  begin
    StatusBar1.Panels[0].Text := 'Entrez un nom de fichier!';
  end
  else
  begin
    Jour := StringGrid1.Cells[1, StringGrid1.Row];
    Heure := StringGrid1.Cells[2, StringGrid1.Row];
    TStringGridX(StringGrid1).InsertRow(StringGrid1.Row);
    StringGrid1.Cells[1, StringGrid1.Row] := Jour;
    StringGrid1.Cells[2, StringGrid1.Row] := Heure;
    StringGrid1.Cells[3, StringGrid1.Row] := 'INTERVENTION'; // ARTISTE
    StringGrid1.Cells[4, StringGrid1.Row] := Uppercase(Reponse); // TITRE

    StringGrid1.Cells[5, StringGrid1.Row] := FormatDateTime('yyyy', Now()); // Année
    StringGrid1.Cells[6, StringGrid1.Row] := '0'; // Duree
    StringGrid1.Cells[7, StringGrid1.Row] := '0'; // Frequence ?
    StringGrid1.Cells[8, StringGrid1.Row] := '0'; // Tempo ?
    StringGrid1.Cells[9, StringGrid1.Row] := '0'; // Intro
    StringGrid1.Cells[10, StringGrid1.Row] := '0'; // Fade IN ?
    StringGrid1.Cells[11, StringGrid1.Row] := '0'; // Fade Out

    StringGrid1.Cells[12, StringGrid1.Row] := VoiceTrackPath + Reponse;

    StringGrid1.Cells[13, StringGrid1.Row] := 'INTERVENTION'; // Cat
    StringGrid1.Cells[14, StringGrid1.Row] := ''; // ssCat

    VoiceTrackID := VoiceTrackID + 1;
  end;
end;

procedure Twaitlist.CalculateClick(Sender: TObject);
begin
  ShowMessage('Durée totale: ' + FloatToStr(Trunc(CalculateWaitlist(StringGrid1.Cells[2, StringGrid1.Row]))) + ' sec.');
end;

end.
