unit U_Gestion;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, MysqlComponent, BASS, Spin,
  ExtCtrls, ComCtrls, Menus, JvExControls, JvComponent, JvButton,
  JvTransparentButton, JvExButtons, JvBitBtn, AppEvnts;

type
  TGestion = class(TForm)
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    BitBtn3: TBitBtn;
    GroupBox1: TGroupBox;
    Titre: TEdit;
    Album: TEdit;
    Annee: TSpinEdit;
    Tempo: TSpinEdit;
    FadeOut: TEdit;
    OpenDialog1: TOpenDialog;
    Categorie: TComboBox;
    Path: TEdit;
    Parcourir: TBitBtn;
    GroupBox2: TGroupBox;
    CutIntro: TBitBtn;
    EcouteFin: TBitBtn;
    CutFadeOut: TBitBtn;
    Play: TBitBtn;
    Stop: TBitBtn;
    CutFadeIn: TBitBtn;
    Modifier: TBitBtn;
    StatusBar1: TStatusBar;
    FadeIn: TEdit;
    Intro: TEdit;
    Frequence: TSpinEdit;
    Play2: TBitBtn;
    RePlay: TBitBtn;
    RePlay2: TBitBtn;
    RePlayerEnd: TBitBtn;
    SSCategorie: TComboBox;
    PopupMenu1: TPopupMenu;
    Recherche1: TMenuItem;
    RechercheCatgorie1: TMenuItem;
    JvBitBtn1: TJvBitBtn;
    Label1: TLabel;
    autoplay: TRadioButton;
    autoplayend: TRadioButton;
    autosave: TCheckBox;
    ApplicationEvents1: TApplicationEvents;
    FileCut: TEdit;
    FindFileCut: TBitBtn;
    FileCutPlay: TBitBtn;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    supprimer: TBitBtn;
    IsValid: TCheckBox;
    Artiste: TComboBox;
    PopupMenu2: TPopupMenu;
    Supprimerlartiste1: TMenuItem;
    procedure FindFileCutClick(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ParcourirClick(Sender: TObject);
    procedure PlayClick(Sender: TObject);
    procedure CutFadeInClick(Sender: TObject);
    procedure CutIntroClick(Sender: TObject);
    procedure CutFadeOutClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure EcouteFinClick(Sender: TObject);
    procedure RePlayClick(Sender: TObject);
    procedure RePlay2Click(Sender: TObject);
    procedure RePlayerEndClick(Sender: TObject);
    procedure ModifierClick(Sender: TObject);
    procedure FadeInChange(Sender: TObject);
    procedure IntroChange(Sender: TObject);
    procedure FadeOutChange(Sender: TObject);
    procedure ArtisteChange(Sender: TObject);
    procedure TitreChange(Sender: TObject);
    procedure AlbumChange(Sender: TObject);
    procedure AnneeChange(Sender: TObject);
    procedure FrequenceChange(Sender: TObject);
    procedure TempoChange(Sender: TObject);
    procedure PathChange(Sender: TObject);
    procedure CategorieChange(Sender: TObject);
    procedure SSCategorieChange(Sender: TObject);
    procedure Recherche1Click(Sender: TObject);
    procedure RechercheCatgorie1Click(Sender: TObject);
    procedure StringGrid2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ApplicationEvents1ShortCut(var Msg: TWMKey;
      var Handled: Boolean);
    procedure FileCutPlayClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure supprimerClick(Sender: TObject);
    procedure IsValidClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Supprimerlartiste1Click(Sender: TObject);
  private
    { Déclarations privées }
    x, c1: Integer;
  end;
  TStringGridX = class(TStringGrid)
  public
    { Déclarations publiques }
  end;

var
  Gestion: TGestion;

implementation

uses U_Welcome, FindCat, U_Bibliotheque;

{$R *.dfm}

function addslashes(s: string): string;
begin
  s := StringReplace(s, '\', '\\', [rfReplaceAll]); // Replace \ to \\
  Result := StringReplace(s, '''', '\''', [rfReplaceAll]); // Replace ' to \'
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

procedure RequestSQL(SQL: string);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
  Duree: Double;
  Select: string;
begin

  Select := 'SELECT playlist.Id, artistes.Name AS Artiste, playlist.Titre, playlist.Annee, playlist.Duree, playlist.Frequence, ';
  Select := Select + 'playlist.Tempo, playlist.Intro, playlist.FadeIn, playlist.FadeOut, playlist.Path, playlist.Album, playlist.Categorie, ';
  Select := Select + 'playlist.SSCategorie, playlist.Duree, playlist.Valide, artistes.ID FROM playlist LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) WHERE ';

  Res := welcome.Sql.Query(Select + SQL);

  if Res = nil then ShowMessage('Aucun resultat')
  else
  try

    Gestion.StringGrid1.Show;
    Gestion.StringGrid1.ColCount := 17;
    Gestion.StringGrid1.RowCount := welcome.sql.num_rows(Res);

    Gestion.StringGrid1.ColWidths[0] := 0; // ID
    Gestion.StringGrid1.ColWidths[1] := 280; // Artiste
    Gestion.StringGrid1.ColWidths[2] := 380; // Titre
    Gestion.StringGrid1.ColWidths[3] := 45; // Annee
    Gestion.StringGrid1.ColWidths[4] := 40; // Duree
    Gestion.StringGrid1.ColWidths[5] := 0; // Frequence
    Gestion.StringGrid1.ColWidths[6] := 0; // Tempo
    Gestion.StringGrid1.ColWidths[7] := 0; // Intro
    Gestion.StringGrid1.ColWidths[8] := 0; // Fade In
    Gestion.StringGrid1.ColWidths[9] := 0; // Fade Out
    Gestion.StringGrid1.ColWidths[10] := 0; // Path
    Gestion.StringGrid1.ColWidths[11] := 0; // Album
    Gestion.StringGrid1.ColWidths[12] := 0; // Categorie
    Gestion.StringGrid1.ColWidths[13] := 0; // SSCategorie
    Gestion.StringGrid1.ColWidths[14] := 0; // Duree en SEC
    Gestion.StringGrid1.ColWidths[15] := 0; // Valide
    Gestion.StringGrid1.ColWidths[16] := 0; // ArtisteID

    j := 0;
    Row := welcome.Sql.fetch_row(Res);
    while Row <> nil do
    begin
      for i := 0 to Gestion.StringGrid1.ColCount do
      begin
        if (i = 4) then
        begin
          Duree := StrToFloat(StringReplace(Row[i], '.', ',', [rfReplaceAll]));
          Gestion.StringGrid1.Cells[i, j] := format('%2.2d:%2.2d', [trunc(Duree) div 60, trunc(Duree) mod 60]);
        end
        else
        begin
          Gestion.StringGrid1.Cells[i, j] := Row[i];
        end;
      end;
      Row := welcome.sql.fetch_row(Res);
      j := j + 1;
    end;
  finally
    welcome.sql.free_result(Res);
  end;

end;

procedure TGestion.FindFileCutClick(Sender: TObject);
begin
  if not OpenDialog1.Execute then Exit;
  FileCut.Text := OpenDialog1.FileName;
end;

procedure TGestion.BitBtn3Click(Sender: TObject);

var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
begin

  Res := welcome.Sql.Query('SELECT ID, Name FROM artistes ORDER by Name ASC;');

  if Res = nil then ShowMessage('Aucun resultat')
  else
  try

    StringGrid2.Show;
    StringGrid2.ColCount := 2;
    StringGrid2.RowCount := welcome.sql.num_rows(Res);

    StringGrid2.ColWidths[0] := 0;
    StringGrid2.ColWidths[1] := 500;

    j := 0;
    Row := welcome.Sql.fetch_row(Res);
    while Row <> nil do
    begin
      for i := 0 to StringGrid2.ColCount do
      begin
        StringGrid2.Cells[i, j] := Row[i]; // La cellule en MAJ.
      end;
      Row := welcome.sql.fetch_row(Res);
      j := j + 1;
    end;
  finally
    welcome.sql.free_result(Res);
  end;

end;

procedure TGestion.FormShow(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i: Integer;
begin

  if (welcome.sql.Connected = true) then
  begin

    BitBtn3.Click();

    with Artiste.Items do
      for i := Count - 1 downto 0 do
        Delete(i);

    Res := welcome.sql.Query('SELECT id, Name FROM artistes ORDER by Name ASC;');
    Row := welcome.sql.fetch_row(Res);
    while Row <> nil do
    begin
      Artiste.AddItem(Row[1], TObject(StrToInt(Row[0])));
      Row := welcome.sql.fetch_row(Res);
    end;
    welcome.sql.free_result(Res);

    with Categorie.Items do
      for i := Count - 1 downto 0 do
        Delete(i);

    Res := welcome.sql.Query('SELECT id, nom FROM categories;');

    Row := welcome.sql.fetch_row(Res);
    while Row <> nil do
    begin
      Categorie.AddItem('(' + Row[0] + ') ' + Row[1], TObject(StrToInt(Row[0])));
      Row := welcome.sql.fetch_row(Res);
    end;

    welcome.sql.free_result(Res);


    Listbox1.Clear;
    welcome.sql.ListFieldsInListBox(Listbox1, 'playlist');
    ListBox1.ItemIndex := 0;


  end;

end;

procedure TGestion.ParcourirClick(Sender: TObject);
begin
  if not OpenDialog1.Execute then Exit;
  Path.Text := OpenDialog1.FileName;
  StringGrid1.Cells[10, StringGrid1.Row] := Path.Text;
end;

procedure TGestion.PlayClick(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(Path.Text), 0, 0, 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TGestion.CutIntroClick(Sender: TObject);
var
  Temps: Single;
  Cue: string;
begin
  Temps := BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetPosition(c1, 0));
  Cue := StringReplace(format('%.2f', [Temps]), ',', '.', [rfReplaceAll]);
  StringGrid1.Cells[7, StringGrid1.Row] := Cue;
  Intro.Text := Cue;
  if (autosave.Checked) then begin Modifier.Click; end;
end;

procedure TGestion.CutFadeInClick(Sender: TObject);
var
  Temps: Single;
  Cue: string;
begin
  Temps := BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetPosition(c1, 0));
  Cue := StringReplace(format('%.2f', [Temps]), ',', '.', [rfReplaceAll]);
  StringGrid1.Cells[8, StringGrid1.Row] := Cue;
  FadeIn.Text := Cue;
  if (autosave.Checked) then begin Modifier.Click; end;
end;

procedure TGestion.CutFadeOutClick(Sender: TObject);
var
  Temps: Single;
  Cue: string;
begin
  Temps := BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetPosition(c1, 0));
  Cue := StringReplace(format('%.2f', [Temps]), ',', '.', [rfReplaceAll]);
  StringGrid1.Cells[9, StringGrid1.Row] := Cue;
  FadeOut.Text := Cue;
  if (autosave.Checked) then begin Modifier.Click; end;
end;

procedure TGestion.StopClick(Sender: TObject);
begin
  BASS_ChannelStop(c1);
end;

procedure TGestion.StringGrid1Click(Sender: TObject);
begin
  Artiste.ItemIndex := Artiste.items.IndexOfObject(TObject(StrToInt(StringGrid1.cells[16, StringGrid1.Row])));
  Titre.Text := StringGrid1.cells[2, StringGrid1.Row];
  Album.Text := StringGrid1.cells[11, StringGrid1.Row];

  Annee.Value := StrToInt(StringGrid1.cells[3, StringGrid1.Row]);
  Frequence.Value := StrToInt(StringGrid1.cells[5, StringGrid1.Row]);
  Tempo.Value := StrToInt(StringGrid1.cells[6, StringGrid1.Row]);

  Categorie.ItemIndex := Categorie.items.IndexOfObject(TObject(StrToInt(StringGrid1.cells[12, StringGrid1.Row])));
  CategorieChange(sender);
  SSCategorie.ItemIndex := SSCategorie.items.IndexOfObject(TObject(StrToInt(StringGrid1.cells[13, StringGrid1.Row])));

  Intro.Text := StringGrid1.cells[7, StringGrid1.Row];
  FadeIn.Text := StringGrid1.cells[8, StringGrid1.Row];
  FadeOut.Text := StringGrid1.cells[9, StringGrid1.Row];
  Path.Text := StringGrid1.cells[10, StringGrid1.Row];

  if (StringGrid1.cells[15, StringGrid1.Row] = '1') then
  begin
    isValid.Checked := True;
  end
  else
    if (StringGrid1.cells[15, StringGrid1.Row] = '0') then
    begin
      isValid.Checked := False;
    end
    else
    begin
      isValid.Checked := True;
    end;

  if (autoplay.Checked) then Play.Click();
  if (autoplayend.Checked) then EcouteFin.Click();

end;

procedure TGestion.EcouteFinClick(Sender: TObject);
var
  Temps: Single;
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(Path.Text), 0, 0, 0);
  Temps := BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetLength(c1, 0)) - 10;
  BASS_ChannelSetPosition(c1, BASS_ChannelSeconds2Bytes(c1, Temps), 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TGestion.RePlayClick(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(Path.Text), 0, 0, 0);
  BASS_ChannelSetPosition(c1, BASS_ChannelSeconds2Bytes(c1, strtofloat(StringReplace(FadeIn.Text, '.', ',', [rfReplaceAll]))), 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TGestion.RePlay2Click(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(Path.Text), 0, 0, 0);
  BASS_ChannelSetPosition(c1, BASS_ChannelSeconds2Bytes(c1, strtofloat(StringReplace(Intro.Text, '.', ',', [rfReplaceAll]))), 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TGestion.RePlayerEndClick(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(Path.Text), 0, 0, 0);
  BASS_ChannelSetPosition(c1, BASS_ChannelSeconds2Bytes(c1, strtofloat(StringReplace(FadeOut.Text, '.', ',', [rfReplaceAll]))), 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TGestion.ModifierClick(Sender: TObject);
var
  RequestSQL,Valide: string;
begin
  if(IsValid.Checked) then begin Valide:='1'; end else Valide:='0';
  RequestSQL := 'UPDATE playlist SET Artiste=' + IntToStr(integer(Artiste.items.objects[Artiste.itemindex])) + ', Titre=''' + addslashes(Titre.Text) + ''', Album=''' + addslashes(Album.Text) + ''', Annee=''' + IntToStr(Annee.Value) + ''', Frequence=''' + IntToStr(Frequence.Value) + ''', Tempo=''' + IntToStr(Tempo.Value) + ''', Intro=''' + Intro.Text + ''', FadeIn=''' + FadeIn.Text + ''', FadeOut=''' + FadeOut.Text + ''', Path=''' + addslashes(Path.Text) + ''', Categorie=' + IntToStr(integer(Categorie.items.objects[Categorie.itemindex])) + ', SSCategorie=' + IntToStr(integer(SSCategorie.items.objects[SSCategorie.itemindex])) + ', Valide=''' + Valide + ''', Date_Mod=NOW() WHERE id=' + StringGrid1.cells[0, StringGrid1.Row] + ';';
  welcome.Sql.query(RequestSQL);
  StatusBar1.Panels[0].Text := FormatDateTime('hh:mm:ss', Time) + ' : modifié';
end;

procedure TGestion.IntroChange(Sender: TObject);
begin
  StringGrid1.Cells[7, StringGrid1.Row] := Intro.Text;
end;

procedure TGestion.FadeInChange(Sender: TObject);
begin
  StringGrid1.Cells[8, StringGrid1.Row] := FadeIn.Text;
end;

procedure TGestion.FadeOutChange(Sender: TObject);
begin
  StringGrid1.Cells[9, StringGrid1.Row] := FadeOut.Text;
end;

procedure TGestion.ArtisteChange(Sender: TObject);
begin
  StringGrid1.Cells[1, StringGrid1.Row] := Artiste.Text;
  StringGrid1.Cells[16, StringGrid1.Row] := IntToStr(integer(Artiste.items.objects[Artiste.itemindex]));
end;

procedure TGestion.TitreChange(Sender: TObject);
begin
  StringGrid1.Cells[2, StringGrid1.Row] := Titre.Text;
end;

procedure TGestion.AlbumChange(Sender: TObject);
begin
  StringGrid1.Cells[11, StringGrid1.Row] := Album.Text;
end;

procedure TGestion.AnneeChange(Sender: TObject);
begin
  StringGrid1.Cells[3, StringGrid1.Row] := Annee.Text;
end;

procedure TGestion.FrequenceChange(Sender: TObject);
begin
  StringGrid1.Cells[5, StringGrid1.Row] := Frequence.Text;
end;

procedure TGestion.TempoChange(Sender: TObject);
begin
  StringGrid1.Cells[6, StringGrid1.Row] := Tempo.Text;
end;

procedure TGestion.PathChange(Sender: TObject);
begin
  StringGrid1.Cells[10, StringGrid1.Row] := Path.Text;
end;

procedure TGestion.CategorieChange(Sender: TObject);
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
    SSCategorieChange(sender);
  end;

  welcome.sql.free_result(Res);
  StringGrid1.Cells[12, StringGrid1.Row] := IntToStr(integer(Categorie.items.objects[Categorie.itemindex]));
end;

procedure TGestion.SSCategorieChange(Sender: TObject);
begin
  //ShowMessage(IntToStr(SSCategorie.ItemIndex));
  StringGrid1.Cells[13, StringGrid1.Row] := IntToStr(integer(SSCategorie.items.objects[SSCategorie.itemindex]));
end;

procedure TGestion.Recherche1Click(Sender: TObject);
var
  Reponse: string;
begin
  Reponse := InputBox('Rechercher', 'Tappez ci dessous la chanson que vous recherchez:', '');

  if Reponse = '' then
  begin
    StatusBar1.Panels[0].Text := 'Entrez un mot clef !';
  end
  else
  begin
    RequestSQL('artistes.Name LIKE ''%' + Reponse + '%'' OR playlist.Titre LIKE ''%' + Reponse + '%'' OR playlist.Album LIKE ''%' + Reponse + '%'' OR playlist.Annee LIKE ''%' + Reponse + '%'' ORDER by playlist.' + listbox1.Items.Strings[listbox1.ItemIndex] + ' ASC;');
  end;
end;

procedure TGestion.RechercheCatgorie1Click(Sender: TObject);
begin
  FindCategory.ShowModal;
  RequestSQL('playlist.Categorie LIKE ''%' + FindCategory.FindCategorie + '%'' AND playlist.SSCategorie LIKE ''%' + FindCategory.FindSSCategorie + '%'' ORDER by playlist.' + listbox1.Items.Strings[listbox1.ItemIndex] + ' ASC;');
end;

procedure TGestion.StringGrid2Click(Sender: TObject);
begin
  RequestSQL('artistes.ID=' + Bibliotheque.Addslashes(StringGrid2.cells[0, StringGrid2.Row]) + ' ORDER by playlist.' + listbox1.Items.Strings[listbox1.ItemIndex] + ' ASC;');
end;

procedure TGestion.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
end;

procedure TGestion.ApplicationEvents1ShortCut(var Msg: TWMKey;
  var Handled: Boolean);
var Key: Word;
begin
  Key := Msg.CharCode;

  if (Key = VK_F1) then
  begin
    CutFadeIn.Click;
    FileCutPlay.Click;
    Handled := True;
    exit;
  end;

  if (Key = VK_F2) then
  begin
    CutFadeOut.Click;
    FileCutPlay.Click;
    Handled := True;
    exit;
  end;

  if (Key = VK_F3) then
  begin
    CutIntro.Click;
    FileCutPlay.Click;
    Handled := True;
    exit;
  end;

  if (Key = VK_F4) then
  begin
    Modifier.Click;
    Handled := True;
    exit;
  end;

  if (Key = VK_F9) then
  begin
    if(isValid.Checked) then
    begin
      isValid.Checked:=False;
    end
    else
    begin
      isValid.Checked:=True;
    end;

    Handled := True;
    exit;
  end;

  if (Key = VK_LEFT) then
  begin
    BASS_ChannelSetPosition(c1, BASS_ChannelSeconds2Bytes(c1, BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetPosition(c1, 0)) - 1), 0);
    Handled := True;
    exit;
  end;

  if (Key = VK_RIGHT) then
  begin
    BASS_ChannelSetPosition(c1, BASS_ChannelSeconds2Bytes(c1, BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetPosition(c1, 0)) + 1), 0);
    Handled := True;
    exit;
  end;


end;

procedure TGestion.FileCutPlayClick(Sender: TObject);
begin
  BASS_ChannelStop(c1);
  BASS_StreamFree(c1);
  c1 := BASS_StreamCreateFile(False, PChar(FileCut.Text), 0, 0, 0);
  BASS_ChannelPlay(c1, False);
end;

procedure TGestion.ListBox1Click(Sender: TObject);
begin
  ShowMessage('Les prochaines requêtes seront triées par: ' + listbox1.Items.Strings[listbox1.ItemIndex]);
end;

procedure TGestion.supprimerClick(Sender: TObject);
begin

  welcome.sql.Query('DELETE FROM playlist WHERE id=''' + StringGrid1.cells[0, StringGrid1.Row] + ''';');
  welcome.sql.Query('DELETE FROM waitlist WHERE PlaylistID=''' + StringGrid1.cells[0, StringGrid1.Row] + ''';');

  BitBtn3.Click();

  StatusBar1.Panels[0].Text := FormatDateTime('hh:mm:ss', Time) + ' : Disque n° '+ StringGrid1.cells[0, StringGrid1.Row] +' ' + Artiste.Text + ' - ' + Titre.Text + ' supprimé';

  if ((StringGrid1.RowCount - 1) <> 0) then
  begin
    GridDeleteRow(StringGrid1.Row, StringGrid1);
    x := (x - 1);
  end
  else
  begin
    StringGrid1.Rows[StringGrid1.Row].Clear;
    x := 0;
  end;

  StringGrid1.Repaint();
  StringGrid2.Repaint();
  StringGrid1Click(sender);
  
end;

procedure TGestion.IsValidClick(Sender: TObject);
begin
  StringGrid1.Cells[15, StringGrid1.Row] := BoolToStr(IsValid.Checked);
  if (autosave.Checked) then begin Modifier.Click; end;
end;

procedure TGestion.StringGrid1DrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  with Sender as TStringGrid do with Canvas do
    begin
    { sélection de la couleur de fond }

      if gdFixed in State then
      begin
        Brush.Color := clBtnFace;
      end
      else if gdSelected in State then
      begin
        Brush.Color := clNavy;
      end
      else if (StringGrid1.Cells[15, ARow] = '0') then
      begin
        Brush.Color := 9934847;
      end
      else
      begin
        Brush.Color := $B7FFB7;
      end;

    { Dessin du fond }
      FillRect(Rect);

    { Sélection de la couleur d'écriture }
      if gdSelected in State then
      begin
        Font.Color := clWhite;
      end
      else
      begin
        Font.Color := clBlack;
      end;

    { Dessin du texte }
      TextOut(Rect.Left, Rect.Top, Cells[ACol, ARow]);

    end;

end;

procedure TGestion.Supprimerlartiste1Click(Sender: TObject);
var
buttonSelected : Integer;
begin
    buttonSelected := MessageDlg('Veuillez confirmer la suppression de l''artiste et ses chansons',mtConfirmation, mbOKCancel, 0);

    if buttonSelected = mrOK then
    begin
      Welcome.sql.Query('DELETE FROM artistes WHERE ID='+StringGrid2.cells[0, StringGrid2.Row]);
      Welcome.sql.Query('DELETE FROM playlist WHERE Artiste='+StringGrid2.cells[0, StringGrid2.Row]);
      BitBtn3.Click();
      ShowMessage('Artiste supprimé!');
    end;
end;

end.
