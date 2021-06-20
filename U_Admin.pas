unit U_Admin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, MysqlComponent, Spin, FileCtrl, InfoMP3,
  ComCtrls, Grids, BASS;

type
  TAjout = class(TForm)

    BitBtn3: TBitBtn;
    InfoMP31: TInfoMP3;
    StringGrid1: TStringGrid;
    StatusBar1: TStatusBar;
    ComboBox2: TComboBox;
    preecoute: TBitBtn;
    BitBtn5: TBitBtn;
    ComboBox3: TComboBox;
    addall: TBitBtn;
    GroupBox1: TGroupBox;
    Titre: TEdit;
    Album: TEdit;
    Annee: TSpinEdit;
    Tempo: TSpinEdit;
    Categorie: TComboBox;
    Path: TEdit;
    Parcourir: TBitBtn;
    GroupBox2: TGroupBox;
    Intro: TEdit;
    FadeOut: TEdit;
    FadeIn: TEdit;
    CutFadeIn: TBitBtn;
    CutIntro: TBitBtn;
    EcouteFin: TBitBtn;
    CutFadeOut: TBitBtn;
    Play: TBitBtn;
    Stop: TBitBtn;
    Play2: TBitBtn;
    RePlay: TBitBtn;
    RePlay2: TBitBtn;
    RePlayerEnd: TBitBtn;
    Frequence: TSpinEdit;
    SSCategorie: TComboBox;
    OpenDialog1: TOpenDialog;
    DeleteRow: TBitBtn;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    FilterComboBox1: TFilterComboBox;
    selectall: TBitBtn;
    FileListBox1: TFileListBox;
    Artiste: TComboBox;
    Button1: TButton;
    procedure preecouteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn3Click(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BitBtn5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure addallClick(Sender: TObject);
    procedure CutFadeInClick(Sender: TObject);
    procedure CutIntroClick(Sender: TObject);
    procedure CutFadeOutClick(Sender: TObject);
    procedure PlayClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure Play2Click(Sender: TObject);
    procedure EcouteFinClick(Sender: TObject);
    procedure ArtisteChange(Sender: TObject);
    procedure TitreChange(Sender: TObject);
    procedure AlbumChange(Sender: TObject);
    procedure AnneeChange(Sender: TObject);
    procedure FrequenceChange(Sender: TObject);
    procedure TempoChange(Sender: TObject);
    procedure CategorieChange(Sender: TObject);
    procedure SSCategorieChange(Sender: TObject);
    procedure ParcourirClick(Sender: TObject);
    procedure DeleteRowClick(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure RePlayClick(Sender: TObject);
    procedure RePlay2Click(Sender: TObject);
    procedure RePlayerEndClick(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
    procedure selectallClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    pointer: Integer;
  public
    m1, c1: Integer;
  end;

var
  Ajout: TAjout;

implementation

uses U_Welcome;

{$R *.dfm}

function addslashes(s: string): string;
begin
  s := StringReplace(s, '\', '\\', [rfReplaceAll]); // Replace \ to \\
  Result := StringReplace(s, '''', '\''', [rfReplaceAll]); // Replace ' to \'
end;

procedure fetchArtists();
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i: Integer;
begin
  with Ajout.Artiste.Items do
    for i := Count - 1 downto 0 do
      Delete(i);

  Res := welcome.sql.Query('SELECT Name FROM artistes ORDER by Name ASC;');
  Row := welcome.sql.fetch_row(Res);
  while Row <> nil do
  begin
    Ajout.Artiste.Items.Add(Row[0]);
    Row := welcome.sql.fetch_row(Res);
  end;
  welcome.sql.free_result(Res);
end;

function setArtist(Artist: string): Int64;
begin
  welcome.sql.Query('INSERT INTO artistes SET Name=''' + addslashes(Artist) + ''';');
  Result := welcome.sql.mysql_insert_id(welcome.sql.Linkp);
end;

function getArtistID(Artist: string): string;
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
begin

  Res := welcome.sql.Query('SELECT ID FROM artistes WHERE Name=''' + addslashes(Artist) + ''' LIMIT 1;');
  if (Res <> nil) then
  begin
    try
      Row := welcome.sql.fetch_row(Res);
      if (Row <> nil) then
      begin
        Result := Row[0];
      end
      else
      begin
        Result := IntToStr(setArtist(Artist));
      end;
    except;
      welcome.sql.free_result(Res);
    end;
  end
  else
  begin
    Result := IntToStr(setArtist(Artist));
  end;

end;

function GetFirstToken(S: string; Token: Char): string;
var I: integer;
begin
  I := 1;
  // On parcourt la chaîne jusqu'à trouver un caractère Token
  while (I <= Length(S)) and (S[I] <> Token) do inc(I);
  // On copie la chaîne depuis le début jusqu'au caractère avant Token
  Result := Copy(S, 1, I - 1);
end;

// Renvoie la dernière sous-chaîne de S délimitée par Token
// (si Token n'est pas dans S, renvoie S)

function GetLastToken(S: string; Token: Char): string;
var I: integer;
begin
  I := Length(S);
  // On parcourt la chaîne à l'envers jusqu'à trouver un caractère Token
  while (I > 0) and (S[I] <> Token) do dec(I);
  // On copie la chaîne depuis le caractère après Token jusqu'à la fin
  Result := Copy(S, I + 1, Length(S));
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

function AddToStringGrid(Handle: Integer): Boolean;
var
  Titre, Artiste, Album, Commentaire, Annee, Genre,
    AudioVersion, LayerVersion, Protection, Bitrate,
    Samplerate, Tailledeframe, ChannelMode, ExtensionChannelMode,
    Copyright, OriginalVersion, Emphasis, DureeFull, Duree, FadeOut: string;
  path, FileName: string;
  FrequenceTemp: Single;
  Temps: Single;
begin

  if welcome.sql.Connected = false then
  begin
    ShowMessage('Vous devez être connecté au serveur !');
    Result := False;
  end
  else
  begin

    if (Ajout.ComboBox2.Items[Ajout.ComboBox2.ItemIndex] = '') OR (Ajout.ComboBox3.Items[Ajout.ComboBox3.ItemIndex] = '') then
    begin
      ShowMessage('Cette catégorie n''est pas correcte.');
      Result := False;
    end
    else
    begin

      FileName := Ajout.DirectoryListBox1.Directory + '\' + Ajout.FileListBox1.Items[Handle];
      Ajout.InfoMP31.GetMP3Info(FileName);

      Artiste := Ajout.InfoMP31.Artiste;
      Titre := Ajout.InfoMP31.Titre;

          // Protection tags vides..

      if (trim(Artiste) = '') or (trim(Titre) = '') then // un coup de trim ici aussi si non.. :)
      begin
        path := GetFirstToken(GetLastToken(FileName, '\'), '.');
        Artiste := Trim(GetFirstToken(path, '-'));
        Titre := Trim(GetLastToken(path, '-'));
      end;

      Album := Ajout.InfoMP31.Album;
      Commentaire := Ajout.InfoMP31.Commentaire;
      Annee := Ajout.InfoMP31.Annee;
      Genre := Ajout.InfoMP31.Genre;
      AudioVersion := Ajout.InfoMP31.AudioVersion;
      LayerVersion := Ajout.InfoMP31.LayerVersion;
      Protection := Ajout.InfoMP31.Protection;
      Bitrate := IntToStr(Ajout.InfoMP31.Bitrate);
      Samplerate := IntToStr(Ajout.InfoMP31.SampleRate);
      TailledeFrame := IntToStr(Ajout.InfoMP31.Tailledeframe);
      ChannelMode := Ajout.InfoMP31.Channelmode;
      ExtensionChannelMode := Ajout.InfoMP31.ExtensionChannelMode;
      Copyright := Ajout.InfoMP31.Copyright;
      OriginalVersion := Ajout.InfoMP31.OriginalVersion;
      Emphasis := Ajout.InfoMP31.Emphasis;
      DureeFull := IntToStr(Ajout.InfoMP31.duree.full);

      Ajout.StringGrid1.Show;

      Ajout.StringGrid1.Cells[0, Ajout.pointer] := addslashes(FileName); // Path
      Ajout.StringGrid1.Cells[1, Ajout.pointer] := trim(Artiste); // artiste
      Ajout.StringGrid1.Cells[2, Ajout.pointer] := trim(Titre); // Titre
      Ajout.StringGrid1.Cells[3, Ajout.pointer] := trim(Album); // Album
      if (trim(Annee) = '') then
      begin
        Ajout.StringGrid1.Cells[4, Ajout.pointer] := FormatDateTime('yyyy', Date); // Annee par defaut
      end
      else
      begin
        Ajout.StringGrid1.Cells[4, Ajout.pointer] := trim(Annee); // Annee
      end;
      Ajout.StringGrid1.Cells[5, Ajout.pointer] := IntToStr(integer(Ajout.ComboBox2.items.objects[Ajout.ComboBox2.itemindex])); // Categorie
      Ajout.StringGrid1.Cells[6, Ajout.pointer] := IntToStr(integer(Ajout.ComboBox3.items.objects[Ajout.ComboBox3.itemindex])); // ssCategorie
      Ajout.StringGrid1.Cells[7, Ajout.pointer] := '0'; // Tempo

      // Extension := ExtractFileExt(FileName);
      // if( (Extension = '.wav') OR (Extension = '.WAV') ) then

      // Open file
      Ajout.c1 := BASS_StreamCreateFile(False, PChar(FileName), 0, 0, BASS_STREAM_DECODE);
      // Frequency
      BASS_ChannelGetAttribute(Ajout.c1, BASS_ATTRIB_FREQ, FrequenceTemp);
      // Duration
      Temps := BASS_ChannelBytes2Seconds(Ajout.c1, BASS_ChannelGetLength(Ajout.c1, 0));
      Duree := StringReplace(format('%.2f', [Temps]), ',', '.', [rfReplaceAll]);
      FadeOut := StringReplace(format('%.2f', [Temps-2]), ',', '.', [rfReplaceAll]);

      // Close file
      BASS_StreamFree(Ajout.c1);

      Ajout.StringGrid1.Cells[8, Ajout.pointer] := FloatToStr(FrequenceTemp); // Sample Rate
      Ajout.StringGrid1.Cells[9, Ajout.pointer] := Duree; // Duree
      Ajout.StringGrid1.Cells[10, Ajout.pointer] := '0'; // Fade In
      Ajout.StringGrid1.Cells[11, Ajout.pointer] := '0'; // Intro
      Ajout.StringGrid1.Cells[12, Ajout.pointer] := FadeOut; // Fade Out
      Ajout.StringGrid1.Cells[13, Ajout.pointer] := FileName; // Path complet

      Ajout.pointer := Ajout.pointer + 1;
      Ajout.StringGrid1.RowCount := Ajout.pointer;

      Result := True;

    end;
  end;
end;

procedure TAjout.FormCreate(Sender: TObject);
begin

  fetchArtists();

  StringGrid1.ColCount := 14;
  StringGrid1.ColWidths[0] := 0;
  StringGrid1.ColWidths[1] := 100;
  StringGrid1.ColWidths[2] := 100;
  StringGrid1.ColWidths[3] := 100;
  StringGrid1.ColWidths[4] := 30;
  StringGrid1.ColWidths[5] := 80;
  StringGrid1.ColWidths[6] := 80;
  StringGrid1.ColWidths[7] := 15;
  StringGrid1.ColWidths[8] := 35;
  StringGrid1.ColWidths[9] := 35;
  StringGrid1.ColWidths[10] := 35;
  StringGrid1.ColWidths[11] := 35;
  StringGrid1.ColWidths[12] := 35;
  StringGrid1.ColWidths[13] := 0;

end;

procedure TAjout.preecouteClick(Sender: TObject);
begin

  if (preecoute.tag = 0) then
  begin
    BASS_ChannelStop(m1);
    m1 := BASS_StreamCreateFile(False, PChar(FileListBox1.Items.Strings[FileListBox1.ItemIndex]), 0, 0, 0);
    BASS_ChannelPlay(m1, False);
    preecoute.tag := 1;
    preecoute.caption := 'stop';
  end
  else
  begin
    BASS_ChannelStop(m1);
    preecoute.tag := 0;
    preecoute.caption := 'Pré-Ecoute';
  end;
end;

procedure TAjout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Hide;
  Stop.Click;
end;


procedure TAjout.BitBtn3Click(Sender: TObject);
var
  i: Integer;
  ArtistID: string;
begin

  if welcome.sql.Connected = false then
  begin
    ShowMessage('Vous devez être connecté au serveur');
  end
  else
  begin

    for i := 0 to StringGrid1.RowCount - 1 do
    begin
      ArtistID := getArtistID(StringGrid1.cells[1, i]);
      welcome.Sql.query('INSERT INTO playlist SET Artiste=' + ArtistID + ', Titre=''' + addslashes(StringGrid1.cells[2, i]) + ''', Album=''' + addslashes(StringGrid1.cells[3, i]) + ''', Annee=''' + StringGrid1.cells[4, i] + ''', Duree=''' + StringGrid1.cells[9, i] + ''', Frequence=''' + StringGrid1.cells[8, i] + ''', Tempo=''' + StringGrid1.cells[7, i] + ''',  FadeIn=''' + StringGrid1.cells[10, i] + ''', Intro=''' + StringGrid1.cells[11, i] + ''', FadeOut=''' + StringGrid1.cells[12, i] + ''', Path=''' + StringGrid1.cells[0, i] + ''', Categorie=''' + StringGrid1.cells[5, i] + ''', ssCategorie=''' + StringGrid1.cells[6, i] + ''', Date_Insert=NOW(), Date_Mod=NOW();');
    end;
    ShowMessage(IntToStr(i) + ' fichiers ajoutés !');

  end;

end;

procedure TAjout.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = (VK_Return) then
  begin
    FileListBox1DblClick(sender);
  end;

  if Key = (VK_Separator) then
  begin
    FileListBox1DblClick(sender);
  end;
end;

procedure TAjout.BitBtn5Click(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to StringGrid1.rowcount - 1 do
  begin
    StringGrid1.Rows[i].clear;
  end;
  StringGrid1.rowcount := 1;
  pointer := 0;
end;

procedure TAjout.FormShow(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i: Integer;
begin

  if (welcome.sql.Connected) then
  begin

    Categorie.Clear;
    with Categorie.Items do
      for i := Count - 1 downto 0 do
        Delete(i);

    ComboBox2.Clear;
    with ComboBox2.Items do
      for i := Count - 1 downto 0 do
        Delete(i);

    Res := welcome.sql.Query('SELECT id, nom FROM categories;');

    Row := welcome.sql.fetch_row(Res);
    while Row <> nil do
    begin
      Categorie.AddItem('(' + Row[0] + ') ' + Row[1], TObject(StrToInt(Row[0])));
      ComboBox2.AddItem('(' + Row[0] + ') ' + Row[1], TObject(StrToInt(Row[0])));

      Row := welcome.sql.fetch_row(Res);
    end;

    welcome.sql.free_result(Res);

  end;

end;


procedure TAjout.addallClick(Sender: TObject);
var
  i: Integer;
begin

  with FileListBox1 do
    if SelCount > 0 then
      for i := 0 to Items.Count - 1 do
        if Selected[i] then
        begin
          if (not AddToStringGrid(i)) then exit;
        end;
end;

procedure TAjout.CutFadeInClick(Sender: TObject);
var
  Temps: Single;
  Cue: string;
begin
  Temps := BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetPosition(c1, 0));
  Cue := StringReplace(format('%.2f', [Temps]), ',', '.', [rfReplaceAll]);
  StringGrid1.Cells[10, StringGrid1.Row] := Cue;
  FadeIn.Text := Cue;
end;

procedure TAjout.CutIntroClick(Sender: TObject);
var
  Temps: Single;
  Cue: string;
begin
  Temps := BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetPosition(c1, 0));
  Cue := StringReplace(format('%.2f', [Temps]), ',', '.', [rfReplaceAll]);
  StringGrid1.Cells[11, StringGrid1.Row] := Cue;
  Intro.Text := Cue;
end;

procedure TAjout.CutFadeOutClick(Sender: TObject);
var
  Temps: Single;
  Cue: string;
begin
  Temps := BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetPosition(c1, 0));
  Cue := StringReplace(format('%.2f', [Temps]), ',', '.', [rfReplaceAll]);
  StringGrid1.Cells[12, StringGrid1.Row] := Cue;
  FadeOut.Text := Cue;
end;

procedure TAjout.PlayClick(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(StringGrid1.cells[13, StringGrid1.Row]), 0, 0, 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TAjout.Play2Click(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(StringGrid1.cells[13, StringGrid1.Row]), 0, 0, 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TAjout.EcouteFinClick(Sender: TObject);
var
  Temps: Single;
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(StringGrid1.cells[13, StringGrid1.Row]), 0, 0, 0);
  Temps := BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetLength(c1, 0)) - 10;
  BASS_ChannelSetPosition(c1, BASS_ChannelSeconds2Bytes(c1, Temps), 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TAjout.RePlayClick(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(StringGrid1.cells[13, StringGrid1.Row]), 0, 0, 0);
  BASS_ChannelSetPosition(c1, BASS_ChannelSeconds2Bytes(c1, strtofloat(StringReplace(FadeIn.Text, '.', ',', [rfReplaceAll]))), 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TAjout.RePlay2Click(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(StringGrid1.cells[13, StringGrid1.Row]), 0, 0, 0);
  BASS_ChannelSetPosition(c1, BASS_ChannelSeconds2Bytes(c1, strtofloat(StringReplace(Intro.Text, '.', ',', [rfReplaceAll]))), 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TAjout.RePlayerEndClick(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(StringGrid1.cells[13, StringGrid1.Row]), 0, 0, 0);
  BASS_ChannelSetPosition(c1, BASS_ChannelSeconds2Bytes(c1, strtofloat(StringReplace(FadeOut.Text, '.', ',', [rfReplaceAll]))), 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TAjout.StopClick(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
end;

procedure TAjout.ArtisteChange(Sender: TObject);
begin
  StringGrid1.Cells[1, StringGrid1.Row] := Artiste.Text;
end;

procedure TAjout.TitreChange(Sender: TObject);
begin
  StringGrid1.Cells[2, StringGrid1.Row] := Titre.Text;
end;

procedure TAjout.AlbumChange(Sender: TObject);
begin
  StringGrid1.Cells[3, StringGrid1.Row] := Album.Text;
end;

procedure TAjout.AnneeChange(Sender: TObject);
begin
  StringGrid1.Cells[4, StringGrid1.Row] := Annee.Text;
end;

procedure TAjout.FrequenceChange(Sender: TObject);
begin
  StringGrid1.Cells[8, StringGrid1.Row] := Frequence.Text;
end;

procedure TAjout.TempoChange(Sender: TObject);
begin
  StringGrid1.Cells[7, StringGrid1.Row] := Tempo.Text;
end;

procedure TAjout.CategorieChange(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i: Integer;
  RequestSQL: string;
begin

  with SSCategorie.Items do
    for i := Count - 1 downto 0 do
      Delete(i);

  RequestSQL := 'SELECT id, nom FROM sscategories WHERE categorie=' + IntToStr(integer(Categorie.items.objects[Categorie.itemindex])) + ';';
  Res := welcome.sql.Query(RequestSQL);

  Row := welcome.sql.fetch_row(Res);
  while Row <> nil do
  begin
    SSCategorie.AddItem('(' + Row[0] + ') ' + Row[1], TObject(StrToInt(Row[0])));
    Row := welcome.sql.fetch_row(Res);
  end;

  if (SSCategorie.Items.Count = 0) then begin
    SSCategorie.AddItem('(0) Default', TObject(0));
    SSCategorie.ItemIndex := 0;
  end;

  welcome.sql.free_result(Res);
  StringGrid1.Cells[5, StringGrid1.Row] := IntToStr(integer(Categorie.items.objects[Categorie.itemindex]));
end;

procedure TAjout.SSCategorieChange(Sender: TObject);
begin
  StringGrid1.Cells[6, StringGrid1.Row] := IntToStr(integer(SSCategorie.items.objects[SSCategorie.itemindex]));
end;

procedure TAjout.ParcourirClick(Sender: TObject);
begin
  if not OpenDialog1.Execute then Exit;
  Path.Text := OpenDialog1.FileName;
  StringGrid1.Cells[0, StringGrid1.Row] := addslashes(OpenDialog1.FileName);
  StringGrid1.Cells[13, StringGrid1.Row] := OpenDialog1.FileName;
end;

procedure TAjout.DeleteRowClick(Sender: TObject);
begin
  GridDeleteRow(StringGrid1.Row, StringGrid1);
  pointer := (pointer - 1);
end;


procedure TAjout.StringGrid1Click(Sender: TObject);
begin
  Artiste.Text := StringGrid1.cells[1, StringGrid1.Row];
  Titre.Text := StringGrid1.cells[2, StringGrid1.Row];
  Album.Text := StringGrid1.cells[3, StringGrid1.Row];

  Annee.Value := StrToInt(StringGrid1.cells[4, StringGrid1.Row]);
  Frequence.Value := StrToInt(StringGrid1.cells[8, StringGrid1.Row]);
  Tempo.Value := StrToInt(StringGrid1.cells[7, StringGrid1.Row]);

  Categorie.ItemIndex := Categorie.items.IndexOfObject(TObject(StrToInt(StringGrid1.cells[5, StringGrid1.Row])));
  CategorieChange(sender);
  SSCategorie.ItemIndex := SSCategorie.items.IndexOfObject(TObject(StrToInt(StringGrid1.cells[6, StringGrid1.Row])));

  FadeIn.Text := StringGrid1.cells[10, StringGrid1.Row];
  Intro.Text := StringGrid1.cells[11, StringGrid1.Row];
  FadeOut.Text := StringGrid1.cells[12, StringGrid1.Row];
  Path.Text := StringGrid1.cells[13, StringGrid1.Row];
end;

procedure TAjout.ComboBox2Change(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i: Integer;
begin

  with ComboBox3.Items do
    for i := Count - 1 downto 0 do
      Delete(i);

  Res := welcome.sql.Query('SELECT id, nom FROM sscategories WHERE categorie=' + IntToStr(integer(ComboBox2.items.objects[ComboBox2.itemindex])) + ';');

  Row := welcome.sql.fetch_row(Res);
  while Row <> nil do
  begin
    ComboBox3.AddItem('(' + Row[0] + ') ' + Row[1], TObject(StrToInt(Row[0])));
    Row := welcome.sql.fetch_row(Res);
  end;

  if (ComboBox3.Items.Count = 0) then begin
    ComboBox3.AddItem('(0) Default', TObject(0));
    ComboBox3.ItemIndex := 0;
    //ComboBox3Change(sender);
  end;

  welcome.sql.free_result(Res);
end;

procedure TAjout.FileListBox1DblClick(Sender: TObject);
begin
  AddToStringGrid(Ajout.FileListBox1.ItemIndex);
end;

procedure TAjout.selectallClick(Sender: TObject);
begin
  FileListBox1.SelectAll;
end;

procedure TAjout.Button1Click(Sender: TObject);
begin
  ShowMessage(getArtistID(InputBox('Créer un artiste', 'Entrez son nom: ', '')));
  fetchArtists();
end;

end.
