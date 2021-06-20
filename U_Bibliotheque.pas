unit U_Bibliotheque;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, MysqlComponent, BASS, ComCtrls, Menus,
  JvExButtons, JvBitBtn;

type
  TBibliotheque = class(TForm)
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    BitBtn3: TBitBtn;
    play: TBitBtn;
    Stop: TBitBtn;
    StatusBar1: TStatusBar;
    titre: TLabel;
    JvBitBtn1: TJvBitBtn;
    PopupMenu1: TPopupMenu;
    Recherche1: TMenuItem;
    RechercheCatgorie1: TMenuItem;
    PopupMenu2: TPopupMenu;
    Supprimerlartiste1: TMenuItem;
    procedure StringGrid1DblClick(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure StringGrid2Click(Sender: TObject);
    procedure playClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Recherche1Click(Sender: TObject);
    procedure RechercheCatgorie1Click(Sender: TObject);
    procedure Supprimerlartiste1Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    SenderBib: Integer;
    Preecoute: Integer;
    function Addslashes(S: string): string;
  end;

var
  Bibliotheque: TBibliotheque;

implementation

uses U_Gestion, U_Welcome, U_Waitlist, FindCat, U_AddZikToPage;

{$R *.dfm}

function TBibliotheque.Addslashes(S: string): string;
begin
  Result := StringReplace(S, '''', '\''', [rfReplaceAll]);
end;

procedure RequestSQL(SQL: string);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
  Duree: Double;
  Select: string;
begin

  Select := 'SELECT playlist.Id, artistes.Name AS artiste, playlist.Titre, playlist.Annee, playlist.Duree, playlist.Frequence, ';
  Select := Select + 'playlist.Tempo, playlist.Intro, playlist.FadeIn, playlist.FadeOut, playlist.Path, playlist.Categorie, playlist.ssCategorie, ';
  Select := Select + 'playlist.Duree FROM playlist LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) WHERE ';

  Res := welcome.Sql.Query(Select + SQL);

  if Res = nil then ShowMessage('Aucun resultat' + SQL)
  else
  try

    Bibliotheque.Show;
    Bibliotheque.StringGrid1.ColCount := 14;
    Bibliotheque.StringGrid1.RowCount := welcome.sql.num_rows(Res);

    // Id, Artiste, Titre, Annee, Duree, Frequence, Tempo, Intro, FadeIn, FadeOut, Path, Categorie, ssCategorie, Duree

    Bibliotheque.StringGrid1.ColWidths[0] := 0; // ID
    Bibliotheque.StringGrid1.ColWidths[1] := 280; // Artiste
    Bibliotheque.StringGrid1.ColWidths[2] := 380; // Titre
    Bibliotheque.StringGrid1.ColWidths[3] := 45; // Annee
    Bibliotheque.StringGrid1.ColWidths[4] := 40; // Duree
    Bibliotheque.StringGrid1.ColWidths[5] := 0; // Frequence
    Bibliotheque.StringGrid1.ColWidths[6] := 0; // Tempo
    Bibliotheque.StringGrid1.ColWidths[7] := 0; // Intro
    Bibliotheque.StringGrid1.ColWidths[8] := 0; // Fade In
    Bibliotheque.StringGrid1.ColWidths[9] := 0; // Fade Out
    Bibliotheque.StringGrid1.ColWidths[10] := 0; // Path
    Bibliotheque.StringGrid1.ColWidths[11] := 0; // Cat
    Bibliotheque.StringGrid1.ColWidths[12] := 0; // SSCat
    Bibliotheque.StringGrid1.ColWidths[13] := 0; // Duree

    j := 0;
    Row := welcome.Sql.fetch_row(Res);
    while Row <> nil do
    begin
      for i := 0 to Bibliotheque.StringGrid1.ColCount do
      begin
        if (i = 4) then
        begin
          Duree := StrToFloat(StringReplace(Row[i], '.', ',', [rfReplaceAll]));
          Bibliotheque.StringGrid1.Cells[i, j] := format('%2.2d:%2.2d', [trunc(Duree) div 60, trunc(Duree) mod 60]);
        end
        else
        begin
          Bibliotheque.StringGrid1.Cells[i, j] := Row[i]; // La cellule en MAJ.
        end;
      end;
      Row := welcome.sql.fetch_row(Res);
      j := j + 1;
    end;
  finally
    welcome.sql.free_result(Res);
  end;

end;

procedure TBibliotheque.StringGrid1DblClick(Sender: TObject);
begin

  if (Bibliotheque.Tag = 1) then
  begin
    Bibliotheque.Tag := 0;
    PageSelector.StringGrid2.Cells[0, PageSelector.StringGrid2.Row] := StringGrid1.cells[0, StringGrid1.Row]; // ID
    PageSelector.StringGrid2.Cells[4, PageSelector.StringGrid2.Row] := StringGrid1.cells[1, StringGrid1.Row]; // ARTISTE
    PageSelector.StringGrid2.Cells[5, PageSelector.StringGrid2.Row] := StringGrid1.cells[2, StringGrid1.Row]; // TITRE
    PageSelector.StringGrid2.Cells[6, PageSelector.StringGrid2.Row] := StringGrid1.cells[3, StringGrid1.Row]; // Année
    PageSelector.StringGrid2.Cells[7, PageSelector.StringGrid2.Row] := StringGrid1.cells[4, StringGrid1.Row]; // Duree
    PageSelector.StringGrid2.Cells[8, PageSelector.StringGrid2.Row] := StringGrid1.cells[5, StringGrid1.Row]; // Frequence ?
    PageSelector.StringGrid2.Cells[9, PageSelector.StringGrid2.Row] := StringGrid1.cells[6, StringGrid1.Row]; // Tempo ?
    PageSelector.StringGrid2.Cells[10, PageSelector.StringGrid2.Row] := StringGrid1.cells[7, StringGrid1.Row]; // Intro
    PageSelector.StringGrid2.Cells[11, PageSelector.StringGrid2.Row] := StringGrid1.cells[8, StringGrid1.Row]; // Fade IN ?
    PageSelector.StringGrid2.Cells[12, PageSelector.StringGrid2.Row] := StringGrid1.cells[9, StringGrid1.Row]; // Fade Out
    PageSelector.StringGrid2.Cells[13, PageSelector.StringGrid2.Row] := StringGrid1.cells[10, StringGrid1.Row]; // Fichier ?
    PageSelector.StringGrid2.Cells[14, PageSelector.StringGrid2.Row] := StringGrid1.cells[11, StringGrid1.Row]; // Cat
    PageSelector.StringGrid2.Cells[15, PageSelector.StringGrid2.Row] := StringGrid1.cells[12, StringGrid1.Row]; // ssCat
    PageSelector.StringGrid2.Cells[16, PageSelector.StringGrid2.Row] := StringGrid1.cells[13, StringGrid1.Row]; // Duree
    PageSelector.StringGrid2.Cells[17, PageSelector.StringGrid2.Row] := StringGrid1.cells[0, StringGrid1.Row]; // ID
  end
  else
  begin
    waitlist.StringGrid1.Cells[0, waitlist.StringGrid1.Row] := StringGrid1.cells[0, StringGrid1.Row]; // ID
      //waitlist.StringGrid1.Cells[1, waitlist.StringGrid1.Row] := StringGrid1.cells[0, StringGrid1.Row]; // Date
      //waitlist.StringGrid1.Cells[2, waitlist.StringGrid1.Row] := StringGrid1.cells[0, StringGrid1.Row]; // Heure
    waitlist.StringGrid1.Cells[3, waitlist.StringGrid1.Row] := StringGrid1.cells[1, StringGrid1.Row]; // ARTISTE
    waitlist.StringGrid1.Cells[4, waitlist.StringGrid1.Row] := StringGrid1.cells[2, StringGrid1.Row]; // TITRE
    waitlist.StringGrid1.Cells[5, waitlist.StringGrid1.Row] := StringGrid1.cells[3, StringGrid1.Row]; // Année
    waitlist.StringGrid1.Cells[6, waitlist.StringGrid1.Row] := StringGrid1.cells[4, StringGrid1.Row]; // Duree
    waitlist.StringGrid1.Cells[7, waitlist.StringGrid1.Row] := StringGrid1.cells[5, StringGrid1.Row]; // Frequence ?
    waitlist.StringGrid1.Cells[8, waitlist.StringGrid1.Row] := StringGrid1.cells[6, StringGrid1.Row]; // Tempo ?
    waitlist.StringGrid1.Cells[9, waitlist.StringGrid1.Row] := StringGrid1.cells[7, StringGrid1.Row]; // Intro
    waitlist.StringGrid1.Cells[10, waitlist.StringGrid1.Row] := StringGrid1.cells[8, StringGrid1.Row]; // Fade IN ?
    waitlist.StringGrid1.Cells[11, waitlist.StringGrid1.Row] := StringGrid1.cells[9, StringGrid1.Row]; // Fade Out
    waitlist.StringGrid1.Cells[12, waitlist.StringGrid1.Row] := StringGrid1.cells[10, StringGrid1.Row]; // Fichier ?
    waitlist.StringGrid1.Cells[13, waitlist.StringGrid1.Row] := StringGrid1.cells[11, StringGrid1.Row]; // Cat
    waitlist.StringGrid1.Cells[14, waitlist.StringGrid1.Row] := StringGrid1.cells[12, StringGrid1.Row]; // ssCat
    waitlist.CalculateWaitlist(StringGrid1.Cells[2, StringGrid1.Row]);
  end;

  ModalResult := mrOk;

end;

procedure TBibliotheque.BitBtn3Click(Sender: TObject);

var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
begin

  Res := Welcome.Sql.Query('SELECT ID, Name FROM artistes ORDER by Name ASC;');

  if Res = nil then StatusBar1.Panels[0].Text := 'Aucun résultat'
  else
  try

    StringGrid2.Show;
    StringGrid2.ColCount := 2;
    StringGrid2.RowCount := Welcome.sql.num_rows(Res);

    StringGrid2.ColWidths[0] := 0;
    StringGrid2.ColWidths[1] := 500;

    j := 0;
    Row := Welcome.sql.fetch_row(Res);
    while Row <> nil do
    begin
      for i := 0 to StringGrid2.ColCount do
      begin
        StringGrid2.Cells[i, j] := Row[i]; // La cellule en MAJ.
      end;
      Row := Welcome.sql.fetch_row(Res);
      j := j + 1;
    end;
  finally
    Welcome.sql.free_result(Res);
  end;

end;

procedure TBibliotheque.StringGrid2Click(Sender: TObject);
begin
  RequestSQL('artistes.ID=' + StringGrid2.cells[0, Bibliotheque.StringGrid2.Row] + ' ORDER by playlist.Id ASC;');
end;

procedure TBibliotheque.playClick(Sender: TObject);
begin
  BASS_ChannelStop(Preecoute);
  BASS_StreamFree(Preecoute);
  Preecoute := BASS_StreamCreateFile(False, Pchar(Bibliotheque.StringGrid1.cells[10, Bibliotheque.StringGrid1.Row]), 0, 0, 0);
  BASS_ChannelPlay(Preecoute, False);
  titre.Caption := Bibliotheque.StringGrid1.cells[1, Bibliotheque.StringGrid1.Row] + ' ' + Bibliotheque.StringGrid1.cells[2, Bibliotheque.StringGrid1.Row];
end;

procedure TBibliotheque.StopClick(Sender: TObject);
begin
  BASS_ChannelStop(Preecoute);
end;

procedure TBibliotheque.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  BASS_ChannelStop(Preecoute);
  BASS_StreamFree(Preecoute);
end;

procedure TBibliotheque.FormShow(Sender: TObject);
begin
  BitBtn3.Click();
end;

procedure TBibliotheque.Recherche1Click(Sender: TObject);
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
    RequestSQL('artistes.Name LIKE ''%' + Reponse + '%'' OR playlist.Titre LIKE ''%' + Reponse + '%'' OR playlist.Album LIKE ''%' + Reponse + '%'' OR playlist.Annee LIKE ''%' + Reponse + '%'' ORDER by playlist.Id ASC;');
  end;
end;

procedure TBibliotheque.RechercheCatgorie1Click(Sender: TObject);
begin
  FindCategory.ShowModal;
  RequestSQL('playlist.Categorie = ' + FindCategory.FindCategorie + ' AND playlist.SSCategorie = ' + FindCategory.FindSSCategorie + ' ORDER by playlist.Id ASC;');
end;

procedure TBibliotheque.Supprimerlartiste1Click(Sender: TObject);
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
