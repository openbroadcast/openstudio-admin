unit U_SelectPub;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Buttons, MysqlComponent, BASS, ComCtrls, Menus,
  JvExButtons, JvBitBtn;

type
  TSelectPub = class(TForm)
    StringGrid1: TStringGrid;
    play: TBitBtn;
    Stop: TBitBtn;
    StatusBar1: TStatusBar;
    titre: TLabel;
    afficher: TBitBtn;
    vider: TBitBtn;
    procedure StringGrid1DblClick(Sender: TObject);
    procedure playClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure viderClick(Sender: TObject);
    procedure afficherClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    SenderBib: Integer;
    Preecoute: Integer;
    FindCategorie, FindSSCategorie: string;
  end;

var
  SelectPub: TSelectPub;

implementation

uses U_Gestion, U_Welcome, U_Waitlist, FindCat, U_Campaign;

{$R *.dfm}

function FloatSQLToFloatFR(s: string): double;
begin
  Result := StrToFloat(StringReplace(s, '.', ',', [rfReplaceAll]));
end;


procedure TSelectPub.StringGrid1DblClick(Sender: TObject);
begin

  // Id, Artiste, Titre, Annee, Duree, Frequence, Tempo, Intro, FadeIn, FadeOut, Path, Cat, SSCat

  campaign.mediaid.Text := StringGrid1.cells[0, StringGrid1.Row]; // ID
  campaign.DureeFile.Text := StringGrid1.cells[13, StringGrid1.Row]; // Duree
  campaign.MediaFile.Text := StringGrid1.cells[10, StringGrid1.Row]; // Fichier ?

  ModalResult := mrOk;

end;

procedure TSelectPub.playClick(Sender: TObject);
begin
  BASS_ChannelStop(Preecoute);
  BASS_StreamFree(Preecoute);
  Preecoute := BASS_StreamCreateFile(False, Pchar(SelectPub.StringGrid1.cells[10, SelectPub.StringGrid1.Row]), 0, 0, 0);
  BASS_ChannelPlay(Preecoute, False);
  titre.Caption := SelectPub.StringGrid1.cells[1, SelectPub.StringGrid1.Row] + ' ' + SelectPub.StringGrid1.cells[2, SelectPub.StringGrid1.Row];
end;

procedure TSelectPub.StopClick(Sender: TObject);
begin
  BASS_ChannelStop(Preecoute);
end;

procedure TSelectPub.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  BASS_ChannelStop(Preecoute);
  BASS_StreamFree(Preecoute);
end;

procedure TSelectPub.viderClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to StringGrid1.Rowcount - 1 do
  begin
    StringGrid1.Rows[i].clear;
  end;
  StringGrid1.rowcount := 1;
end;

procedure TSelectPub.afficherClick(Sender: TObject);
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j, k: integer;
  RequestSQL: string;
begin

  for k := 0 to StringGrid1.Rowcount - 1 do
  begin
    StringGrid1.Rows[k].clear;
  end;

  RequestSQL := 'SELECT playlist.ID, artistes.Name AS artiste, playlist.Titre, playlist.Annee, playlist.Duree, playlist.Frequence, playlist.Tempo, ';
  RequestSQL := RequestSQL + 'playlist.Intro, playlist.FadeIn, playlist.FadeOut, playlist.Path, playlist.Categorie, playlist.ssCategorie, playlist.Duree ';
  RequestSQL := RequestSQL + 'FROM playlist ';
  RequestSQL := RequestSQL + 'LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
  RequestSQL := RequestSQL + 'WHERE playlist.Categorie=8 ORDER by playlist.ID ASC;';

  Res := welcome.sql.Query(RequestSQL);

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
          StringGrid1.Cells[i, j] := format('%2.2d:%2.2d', [trunc(FloatSQLToFloatFR(Row[i])) div 60, trunc(FloatSQLToFloatFR(Row[i])) mod 60]);
        end
        else
        begin
          StringGrid1.Cells[i, j] := Row[i];
        end;
      end;
      Row := welcome.sql.fetch_row(Res);
      j := j + 1;
    end;
  finally
    welcome.sql.free_result(Res);
  end;
end;

procedure TSelectPub.FormShow(Sender: TObject);
begin
  vider.Click;
  afficher.Click;
end;

end.
