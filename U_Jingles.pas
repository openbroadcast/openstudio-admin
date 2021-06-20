unit U_Jingles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, MysqlComponent, BASS, ComCtrls, Menus,
  JvExButtons, JvBitBtn;

type
  TJingles = class(TForm)
    StringGrid1: TStringGrid;
    play: TBitBtn;
    Stop: TBitBtn;
    StatusBar1: TStatusBar;
    titre: TLabel;
    JingleChoice: TPageControl;
    ListJingles: TBitBtn;
    procedure StringGrid1DblClick(Sender: TObject);
    procedure playClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure JingleChoiceChange(Sender: TObject);
    procedure ListJinglesClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    SenderBib: Integer;
    Preecoute: Integer;
    FindCategorie, FindSSCategorie: string;
  end;

var
  Jingles: TJingles;

implementation

uses U_Gestion, U_Welcome, U_Waitlist, FindCat;

{$R *.dfm}


procedure TJingles.StringGrid1DblClick(Sender: TObject);
begin

  // Id, Artiste, Titre, Annee, Duree, Frequence, Tempo, Intro, FadeIn, FadeOut, Path, Cat, SSCat

  waitlist.StringGrid1.Cells[0, waitlist.StringGrid1.Row] := StringGrid1.cells[0, StringGrid1.Row]; // ID
      //waitlist.StringGrid1.Cells[1, waitlist.StringGrid1.Row] := StringGrid1.cells[0, StringGrid1.Row]; // Date
      //waitlist.StringGrid1.Cells[2, waitlist.StringGrid1.Row] := StringGrid1.cells[0, StringGrid1.Row]; // Heure
  waitlist.StringGrid1.Cells[3, waitlist.StringGrid1.Row] := StringGrid1.cells[1, StringGrid1.Row]; // ARTISTE
  waitlist.StringGrid1.Cells[4, waitlist.StringGrid1.Row] := StringGrid1.cells[2, StringGrid1.Row]; // TITRE
  waitlist.StringGrid1.Cells[5, waitlist.StringGrid1.Row] := StringGrid1.cells[3, StringGrid1.Row]; // Année
  waitlist.StringGrid1.Cells[6, waitlist.StringGrid1.Row] := StringGrid1.cells[13, StringGrid1.Row]; // Duree
  waitlist.StringGrid1.Cells[7, waitlist.StringGrid1.Row] := StringGrid1.cells[5, StringGrid1.Row]; // Frequence ?
  waitlist.StringGrid1.Cells[8, waitlist.StringGrid1.Row] := StringGrid1.cells[6, StringGrid1.Row]; // Tempo ?
  waitlist.StringGrid1.Cells[9, waitlist.StringGrid1.Row] := StringGrid1.cells[7, StringGrid1.Row]; // Intro
  waitlist.StringGrid1.Cells[10, waitlist.StringGrid1.Row] := StringGrid1.cells[8, StringGrid1.Row]; // Fade IN ?
  waitlist.StringGrid1.Cells[11, waitlist.StringGrid1.Row] := StringGrid1.cells[9, StringGrid1.Row]; // Fade Out
  waitlist.StringGrid1.Cells[12, waitlist.StringGrid1.Row] := StringGrid1.cells[10, StringGrid1.Row]; // Fichier ?
  waitlist.StringGrid1.Cells[13, waitlist.StringGrid1.Row] := StringGrid1.cells[11, StringGrid1.Row]; // Cat
  waitlist.StringGrid1.Cells[14, waitlist.StringGrid1.Row] := StringGrid1.cells[12, StringGrid1.Row]; // ssCat

  waitlist.CalculateWaitlist(StringGrid1.Cells[2, StringGrid1.Row]);
  ModalResult := mrOk;

end;

procedure TJingles.playClick(Sender: TObject);
begin
  BASS_ChannelStop(Preecoute);
  BASS_StreamFree(Preecoute);
  Preecoute := BASS_StreamCreateFile(False, Pchar(Jingles.StringGrid1.cells[10, Jingles.StringGrid1.Row]), 0, 0, 0);
  BASS_ChannelPlay(Preecoute, False);
  titre.Caption := Jingles.StringGrid1.cells[1, Jingles.StringGrid1.Row] + ' ' + Jingles.StringGrid1.cells[2, Jingles.StringGrid1.Row];
end;

procedure TJingles.StopClick(Sender: TObject);
begin
  BASS_ChannelStop(Preecoute);
end;

procedure TJingles.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  BASS_ChannelStop(Preecoute);
  BASS_StreamFree(Preecoute);
end;

procedure TJingles.JingleChoiceChange(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j, k: integer;
  Duree: Double;
  Select: string;
begin

  for k := 0 to StringGrid1.Rowcount - 1 do
  begin
    StringGrid1.Rows[k].clear;
  end;

  Select := 'SELECT playlist.Id, artistes.Name AS artiste, playlist.Titre, playlist.Annee, playlist.Duree, ';
  Select := Select + 'playlist.Frequence, playlist.Tempo, playlist.Intro, playlist.FadeIn, playlist.FadeOut, playlist.Path, ';
  Select := Select + 'playlist.Categorie, playlist.ssCategorie, playlist.Duree ';
  Select := Select + 'FROM playlist LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
  Select := Select + 'WHERE playlist.Categorie=''Jingles'' AND playlist.SSCategorie=''' + JingleChoice.ActivePage.Caption + ''' ';

  Res := welcome.sql.Query(Select);

  if Res = nil then StatusBar1.Panels[0].Text := 'Pas de fichier'
  else
  try

    StringGrid1.ColCount := 14;
    StringGrid1.RowCount := welcome.sql.num_rows(Res);

    StringGrid1.ColWidths[0] := 0;
    StringGrid1.ColWidths[1] := 160;
    StringGrid1.ColWidths[2] := 190;
    StringGrid1.ColWidths[3] := 45;
    StringGrid1.ColWidths[4] := 40;
    StringGrid1.ColWidths[5] := 0;
    StringGrid1.ColWidths[6] := 0;
    StringGrid1.ColWidths[7] := 0;
    StringGrid1.ColWidths[8] := 0;
    StringGrid1.ColWidths[9] := 0;
    StringGrid1.ColWidths[10] := 0;
    StringGrid1.ColWidths[11] := 0;
    StringGrid1.ColWidths[12] := 0;
    StringGrid1.ColWidths[13] := 0;

    j := 0;
    Row := welcome.sql.fetch_row(Res);
    while Row <> nil do
    begin
      for i := 0 to StringGrid1.ColCount do
      begin
        if (i = 4) then
        begin
          Duree := StrToFloat(StringReplace(Row[i], '.', ',', [rfReplaceAll]));
          StringGrid1.Cells[i, j] := format('%2.2d:%2.2d', [trunc(Duree) div 60, trunc(Duree) mod 60]);
        end
        else
        begin
          StringGrid1.Cells[i, j] := Row[i]; // La cellule en MAJ.
        end;
      end;
      Row := welcome.sql.fetch_row(Res);
      j := j + 1;
    end;
  finally
    welcome.sql.free_result(Res);
  end;

end;

procedure TJingles.ListJinglesClick(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
begin
  if (welcome.sql.Connected) then
  begin

    Res := welcome.sql.Query('SELECT nom FROM sscategories WHERE categorie = ''Jingles'';');

    Row := welcome.sql.fetch_row(Res);
    while Row <> nil do
    begin

      with JingleChoice do
        with TTabSheet.Create(Self) do
        begin
          PageControl := JingleChoice;
          TabVisible := true;
          Caption := Row[0];
        end;

      Row := welcome.sql.fetch_row(Res);
    end;

    welcome.sql.free_result(Res);

  end;
end;

end.
