unit U_Welcome;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, XPMan, ImgList,
  StdCtrls, MysqlComponent, Registry, ExtCtrls, Menus, CoolTrayIcon,
  BASS, JvLookOut, JvExControls, JvComponent, ShellAPI, IniFiles, Grids,
  OleCtrls, SHDocVw;

type
  Twelcome = class(TForm)
    Images: TImageList;
    XPManifest1: TXPManifest;
    sql: TMysqlComponent;
    connectsql: TTimer;
    CoolTrayIcon1: TCoolTrayIcon;
    PopupMenu1: TPopupMenu;
    Fermer1: TMenuItem;
    Rduire1: TMenuItem;
    Restaurer1: TMenuItem;
    About1: TMenuItem;
    JvLookOut1: TJvLookOut;
    LookOutPage1: TJvLookOutPage;
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    StatusBar1: TStatusBar;
    LookOutButton2: TJvLookOutButton;
    LookOutButton3: TJvLookOutButton;
    Rduire2: TMenuItem;
    Fermer2: TMenuItem;
    Aide1: TMenuItem;
    Siteduprojet: TMenuItem;
    Info1: TMenuItem;
    LookOutPage2: TJvLookOutPage;
    LookOutButton1: TJvLookOutButton;
    LookOutButton4: TJvLookOutButton;
    LookOutButton5: TJvLookOutButton;
    LookOutButton6: TJvLookOutButton;
    LookOutButton7: TJvLookOutButton;
    LookOutButton8: TJvLookOutButton;
    LookOutPage3: TJvLookOutPage;
    LookOutButton9: TJvLookOutButton;
    LookOutButton10: TJvLookOutButton;
    LookOutPage4: TJvLookOutPage;
    LookOutPage5: TJvLookOutPage;
    LookOutButton11: TJvLookOutButton;
    LookOutButton12: TJvLookOutButton;
    LookOutButton13: TJvLookOutButton;
    LookOutButton14: TJvLookOutButton;
    LookOutButton15: TJvLookOutButton;
    LookOutPage6: TJvLookOutPage;
    LookOutButton16: TJvLookOutButton;
    LookOutButton17: TJvLookOutButton;
    Panel1: TPanel;
    LookOutPage7: TJvLookOutPage;
    LookOutButton19: TJvLookOutButton;
    LookOutButton20: TJvLookOutButton;
    LookOutButton21: TJvLookOutButton;
    Utilisateur: TLabel;
    Serial: TLabel;
    Label1: TLabel;
    Administrator: TJvLookOutButton;
    LookOutButton23: TJvLookOutButton;
    GroupBox1: TGroupBox;
    interprete: TLabel;
    titre: TLabel;
    starttime: TLabel;
    annee: TLabel;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    StringGrid1: TStringGrid;
    GroupBox5: TGroupBox;
    StringGrid2: TStringGrid;
    TimerGetStats: TTimer;
    LookOutButton24: TJvLookOutButton;
    LookOutButton18: TJvLookOutButton;
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure connectsqlTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Fermer1Click(Sender: TObject);
    procedure Rduire1Click(Sender: TObject);
    procedure Restaurer1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure JvTransparentButton6Click(Sender: TObject);
    procedure JvTransparentButton7Click(Sender: TObject);
    procedure CoolTrayIcon1DblClick(Sender: TObject);
    procedure Rduire2Click(Sender: TObject);
    procedure Fermer2Click(Sender: TObject);
    procedure Info1Click(Sender: TObject);
    procedure LookOutButton2Click(Sender: TObject);
    procedure LookOutButton3Click(Sender: TObject);
    procedure LookOutButton1Click(Sender: TObject);
    procedure LookOutButton8Click(Sender: TObject);
    procedure LookOutButton7Click(Sender: TObject);
    procedure LookOutButton6Click(Sender: TObject);
    procedure LookOutButton4Click(Sender: TObject);
    procedure LookOutButton5Click(Sender: TObject);
    procedure LookOutButton9Click(Sender: TObject);
    procedure LookOutButton10Click(Sender: TObject);
    procedure LookOutButton11Click(Sender: TObject);
    procedure LookOutButton12Click(Sender: TObject);
    procedure LookOutButton16Click(Sender: TObject);
    procedure LookOutButton18Click(Sender: TObject);
    procedure LookOutButton13Click(Sender: TObject);
    procedure LookOutButton15Click(Sender: TObject);
    procedure LookOutButton14Click(Sender: TObject);
    procedure SiteduprojetClick(Sender: TObject);
    procedure LookOutButton17Click(Sender: TObject);
    procedure LookOutButton19Click(Sender: TObject);
    procedure LookOutButton20Click(Sender: TObject);
    procedure LookOutButton21Click(Sender: TObject);
    procedure AdministratorClick(Sender: TObject);
    procedure LookOutButton23Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerGetStatsTimer(Sender: TObject);
    procedure LookOutButton24Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    procedure ClearStringGrid1();
    procedure ClearStringGrid2();
    procedure ConnectionSQL();
    procedure GetStats();
    { Déclarations publiques }
  end;

var
  welcome: Twelcome;
  HookID: THandle;

implementation

uses U_Admin, U_ConfMySQL, U_About, U_Waitlist, U_Gestion, U_GrillePub, U_Canvas,
  U_Timer, U_Users, U_Campaign, U_Planning, U_Stations, U_PubLocale,
  U_ModifyDuree, U_log, U_Config,
  U_Administration, U_AddZikToPage, U_Formats, U_Category;

{$R *.dfm}

procedure TWelcome.ConnectionSQL();
begin
  if sql.Connected = false then
  begin
    Statusbar1.Panels[0].Text := 'Connexion en cours ...';
    sql.Connect;
  end;

  if sql.Connected = false then
  begin
    Statusbar1.Panels[0].Text := 'Echec de connexion à MySQL';
    connectsql.Interval := 10000;
    exit;
  end
  else
  begin
    Statusbar1.Panels[0].Text := 'Connecté à MySQL';
  end;

  if sql.Selected = false then
  begin
    Statusbar1.Panels[0].Text := 'Impossible d''ouvrir la database';
    connectsql.Interval := 10000;
    sql.Close;
    exit;
  end;
end;

procedure twelcome.ClearStringGrid1();
var
  i: Integer;
begin
  for i := 0 to StringGrid1.Rowcount - 1 do
  begin
    StringGrid1.Rows[i].clear;
  end;
  StringGrid1.rowcount := 1;
end;

procedure twelcome.ClearStringGrid2();
var
  i: Integer;
begin
  for i := 0 to StringGrid2.Rowcount - 1 do
  begin
    StringGrid2.Rows[i].clear;
  end;
  StringGrid2.rowcount := 1;
end;

procedure Twelcome.GetStats();
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
  Duree: Double;
  Playlist, RequestSQL: string;
begin

  if (sql.Connected = True) then
  begin

  // Date courante
    Playlist := FormatDateTime('yyyy-mm-dd HH', Now);

  // Titre en cours

    RequestSQL := 'SELECT playlist.ID, artistes.Name AS Artiste, playlist.Titre, playlist.Annee, playlist.Duree, ';
    RequestSQL := RequestSQL + 'DATE_FORMAT(log.Date_Joue, ''%H:%i:%s'') AS Date_Play_FR FROM log ';
    RequestSQL := RequestSQL + 'LEFT JOIN playlist ON (playlist.ID=log.PlaylistID) ';
    RequestSQL := RequestSQL + 'LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
    RequestSQL := RequestSQL + 'WHERE log.Date_Joue LIKE ''' + Playlist + '%'' ORDER by log.ID DESC LIMIT 1;';

    Res := sql.Query(RequestSQL);
    if Res = nil then Statusbar1.Panels[0].Text := 'Pas d''enregistrement'
    else
    try
      Row := sql.fetch_row(Res);
      if (Row <> nil) then
      begin
        interprete.Caption := Row[1];
        titre.Caption := Row[2];
        annee.Caption := Row[3];
        starttime.Caption := Row[5];
      end;
    except;
      sql.free_result(Res);
    end;


  // WAITLIST

    RequestSQL := 'SELECT waitlist.ID, artistes.Name AS Artiste, playlist.Titre, playlist.Annee, playlist.Duree, ';
    RequestSQL := RequestSQL + 'DATE_FORMAT(waitlist.Date_Play, ''%H:%i:%s'') AS Date_Play_FR FROM waitlist ';
    RequestSQL := RequestSQL + 'LEFT JOIN playlist ON (playlist.ID=waitlist.PlaylistID) ';
    RequestSQL := RequestSQL + 'LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
    RequestSQL := RequestSQL + 'WHERE waitlist.Date_Play LIKE ''' + Playlist + '%'' AND waitlist.Joue=0 ORDER by waitlist.ID ASC;';

    Res := Sql.Query(RequestSQL);

    if Res = nil then begin
      StatusBar1.Panels[0].Text := 'Pas de waitlist pour la date demandée';
    end
    else
    try



      ClearStringGrid1();
      StringGrid1.RowCount := sql.num_rows(Res);

      j := 0;
      Row := sql.fetch_row(Res);
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
            StringGrid1.Cells[i, j] := Row[i];
          end;
        end;
        Row := sql.fetch_row(Res);
        j := j + 1;
      end;

    finally
      sql.free_result(Res);
    end;


  // LOG

    RequestSQL := 'SELECT playlist.ID, artistes.Name AS Artiste, playlist.Titre, playlist.Annee, playlist.Duree, ';
    RequestSQL := RequestSQL + 'DATE_FORMAT(log.Date_Joue, ''%H:%i:%s'') AS Date_Joue_FR FROM log ';
    RequestSQL := RequestSQL + 'LEFT JOIN playlist ON (playlist.ID=log.PlaylistID) ';
    RequestSQL := RequestSQL + 'LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
    RequestSQL := RequestSQL + 'WHERE log.Date_Joue LIKE ''' + Playlist + '%'' ORDER by log.ID DESC;';

    Res := Sql.Query(RequestSQL);

    if Res = nil then begin
      StatusBar1.Panels[0].Text := 'Pas de log pour la date demandée';
    end
    else
    try



      ClearStringGrid2();
      StringGrid2.RowCount := sql.num_rows(Res);

      j := 0;
      Row := sql.fetch_row(Res);
      while Row <> nil do
      begin
        for i := 0 to StringGrid2.ColCount do
        begin

          if (i = 4) then
          begin
            Duree := StrToFloat(StringReplace(Row[i], '.', ',', [rfReplaceAll]));
            StringGrid2.Cells[i, j] := format('%2.2d:%2.2d', [trunc(Duree) div 60, trunc(Duree) mod 60]);
          end
          else
          begin
            StringGrid2.Cells[i, j] := Row[i];
          end;
        end;
        Row := sql.fetch_row(Res);
        j := j + 1;
      end;

    finally
      sql.free_result(Res);
    end;

  end;

end;

function MouseProc(nCode: Integer; wParam, lParam: Longint): Longint; stdcall;
var
  szClassName: array[0..255] of Char;
const
  ie_name = 'Internet Explorer_Server';
begin
  case nCode < 0 of
    True:
      Result := CallNextHookEx(HookID, nCode, wParam, lParam)
  else
    case wParam of
      WM_RBUTTONDOWN,
        WM_RBUTTONUP:
        begin
          GetClassName(PMOUSEHOOKSTRUCT(lParam)^.HWND, szClassName, SizeOf(szClassName));
          if lstrcmp(@szClassName[0], @ie_name[1]) = 0 then
            Result := HC_SKIP
          else
            Result := CallNextHookEx(HookID, nCode, wParam, lParam);
        end
    else
      Result := CallNextHookEx(HookID, nCode, wParam, lParam);
    end;
  end;
end;

procedure Twelcome.ToolButton1Click(Sender: TObject);
begin
  sql.close;
  Application.Terminate;
end;

procedure Twelcome.ToolButton2Click(Sender: TObject);
begin
  Ajout.Show;
end;

procedure Twelcome.connectsqlTimer(Sender: TObject);
begin
  ConnectionSQL();
  if (sql.Connected = True) and (welcome.tag = 0) then
  begin
    welcome.tag := 1;
  end;
end;

procedure Twelcome.FormCreate(Sender: TObject);
var
  Inifile: TIniFile;
begin
  sql.close;

  with TRegistry.Create do
  try
    OpenKey('Software\OpenStudio\Admin', true);

    if (ValueExists('serveur') and ValueExists('login') and ValueExists('motdepasse') and ValueExists('base')) then
    begin
      sql.Host := ReadString('serveur');
      sql.Login := ReadString('login');
      sql.Password := ReadString('motdepasse');
      sql.Database := ReadString('base');
      ConnectionSQL();
    end
    else
    begin
      ShowMessage('Veuillez configurer MySQL, ensuite redémarrez le logiciel.');
    end;

  finally
    Free;
  end;

 // Initialize audio - default device, 44100hz, stereo, 16 bits
  if not BASS_Init(-1, 44100, BASS_DEVICE_SPEAKERS, Handle, nil) then
  begin
    ShowMessage('Pas de carte son!');
  end;


  if FileExists(ExtractFilePath(Application.ExeName) + '\user.reg') then
  begin
    IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + '\user.reg');
    Utilisateur.Caption := IniFile.ReadString('Registration', 'Name', 'NO_USER');
    Serial.Caption := IniFile.ReadString('Registration', 'Serial', '000000');
    IniFile.Free;
  end
  else
  begin
    ShowMessage('Pas de license trouvée.');
    Application.Terminate;
  end;

  if (sql.Connected = True) then
  begin
    StringGrid1.ColCount := 6;
    StringGrid1.ColWidths[0] := 0;
    StringGrid1.ColWidths[1] := 200;
    StringGrid1.ColWidths[2] := 200;
    StringGrid1.ColWidths[3] := 50;
    StringGrid1.ColWidths[4] := 50;
    StringGrid1.ColWidths[5] := 200;

    StringGrid2.ColCount := 6;
    StringGrid2.ColWidths[0] := 0;
    StringGrid2.ColWidths[1] := 200;
    StringGrid2.ColWidths[2] := 200;
    StringGrid2.ColWidths[3] := 50;
    StringGrid2.ColWidths[4] := 50;
    StringGrid2.ColWidths[5] := 200;

    GetStats();
    TimerGetStats.Enabled := True;
  end;

  HookID := SetWindowsHookEx(WH_MOUSE, MouseProc, 0, GetCurrentThreadId());

end;

procedure Twelcome.Fermer1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Twelcome.Rduire1Click(Sender: TObject);
begin
  Application.Minimize;
end;

procedure Twelcome.Restaurer1Click(Sender: TObject);
begin
  Application.Restore;
end;

procedure Twelcome.About1Click(Sender: TObject);
begin
  About.ShowModal;
end;

procedure Twelcome.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  sql.close;
  CoolTrayIcon1.Free;
  BASS_Free();
  Application.Terminate;
end;

procedure Twelcome.JvTransparentButton6Click(Sender: TObject);
begin
  sql.close;
  Application.Terminate;
end;

procedure Twelcome.JvTransparentButton7Click(Sender: TObject);
begin
  Application.Minimize;
end;

procedure Twelcome.CoolTrayIcon1DblClick(Sender: TObject);
begin
  Application.Restore;
end;


procedure Twelcome.Rduire2Click(Sender: TObject);
begin
  Application.Minimize;
end;

procedure Twelcome.Fermer2Click(Sender: TObject);
begin
  sql.close;
  Application.Terminate;
end;

procedure Twelcome.Info1Click(Sender: TObject);
begin
  About.Show;
end;

procedure Twelcome.LookOutButton2Click(Sender: TObject);
begin
  Users.Show;
end;

procedure Twelcome.LookOutButton3Click(Sender: TObject);
begin
  StationsForm.Show;
end;

procedure Twelcome.LookOutButton1Click(Sender: TObject);
begin
  ConfMySQL.Show;
end;

procedure Twelcome.LookOutButton8Click(Sender: TObject);
begin
  Sql.Query('REPAIR TABLE `campagnes` , `canvas` , `categories` , `grillepub` , `log` , `playlist` , `pub_locales` , `sscategories` , `timer` , `utilisateurs` , `waitlist`;');
  MessageDlg('Les tables ont été réparées.', mtConfirmation, [mbOk], 0);
end;

procedure Twelcome.LookOutButton7Click(Sender: TObject);
var Conf: integer;
begin

  Conf := MessageDlg(('Etes vous bien sur? Les tables suivantes seront vidées: Log, Pubs, Timer, Waitlists.'), mtWarning, mbOKCancel, 0);
  case Conf of

    idOK:
      begin
        Sql.Query('TRUNCATE `log` ;TRUNCATE `pub_locales` ;TRUNCATE `timer` ;TRUNCATE `waitlist` ;');
        MessageDlg('Les tables ont été vidées.', mtConfirmation, [mbOk], 0);
      end;

    idCancel:
      begin
        Abort;
      end;

  end;

end;

procedure Twelcome.LookOutButton6Click(Sender: TObject);
var Conf: integer;
begin

  Conf := MessageDlg(('Etes vous bien sur? Toutes les tables seront supprimées.'), mtWarning, mbOKCancel, 0);
  case Conf of

    idOK:
      begin
        Sql.Query('DROP TABLE `campagnes` , `canvas`, `categories`, `grillepub`, `log`, `playlist`, `pub_locales`, `sscategories`, `timer`, `utilisateurs`, `waitlist`;');
        MessageDlg('Les tables ont été supprimées.', mtConfirmation, [mbOk], 0);
      end;

    idCancel:
      begin
        Abort;
      end;

  end;
end;

procedure Twelcome.LookOutButton4Click(Sender: TObject);
begin
  sql.connect;
  connectsql.Enabled := True;
end;

procedure Twelcome.LookOutButton5Click(Sender: TObject);
begin
  sql.close;
  connectsql.Enabled := False;
  Statusbar1.Panels[0].Text := 'Déconnecter';

end;

procedure Twelcome.LookOutButton9Click(Sender: TObject);
begin
  Ajout.Show;
end;

procedure Twelcome.LookOutButton10Click(Sender: TObject);
begin
  Gestion.Show;
end;

procedure Twelcome.LookOutButton18Click(Sender: TObject);
begin
  Category.Show;
end;

procedure Twelcome.LookOutButton11Click(Sender: TObject);
begin
  Waitlist.Show;
end;

procedure Twelcome.LookOutButton12Click(Sender: TObject);
begin
  Timer.Show;
end;

procedure Twelcome.LookOutButton16Click(Sender: TObject);
begin
  Campaign.Show;
end;

procedure Twelcome.LookOutButton13Click(Sender: TObject);
begin
  CanvasControl.Show;
end;

procedure Twelcome.LookOutButton15Click(Sender: TObject);
begin
  Planning.Show;
end;

procedure Twelcome.LookOutButton14Click(Sender: TObject);
begin
  GrillePub.Show;
end;

procedure Twelcome.SiteduprojetClick(Sender: TObject);
var Conf: integer;
begin

  Conf := MessageDlg(('Vous allez être dirigé vers le site du projet'), mtInformation, mbOkCancel, 0);
  case Conf of

    idOK:
      begin
        ShellExecute(Handle, nil, 'https://github.com/openbroadcast', nil, nil, SW_SHOWNORMAL);
      end;

    idCancel:
      begin
        Abort;
      end;

  end;

end;

procedure Twelcome.LookOutButton17Click(Sender: TObject);
begin
  PubLocale.Show;
end;

procedure Twelcome.LookOutButton19Click(Sender: TObject);
begin
  ModifyDuree.Show;
end;

procedure Twelcome.LookOutButton20Click(Sender: TObject);
begin
  Log.Show;
end;

procedure Twelcome.LookOutButton21Click(Sender: TObject);
begin
  Config.Show;
end;

procedure Twelcome.AdministratorClick(Sender: TObject);
begin
  Administration.Show;
end;

procedure Twelcome.LookOutButton23Click(Sender: TObject);
begin
  PageSelector.Show;
end;

procedure Twelcome.FormResize(Sender: TObject);
begin
  // Permet de recadrer la hauteur du menu.
  JvLookOut1.ActivePage := JvLookOut1.ActivePage;
end;

procedure Twelcome.FormDestroy(Sender: TObject);
begin
  if HookID <> 0 then
    UnHookWindowsHookEx(HookID);
end;

procedure Twelcome.TimerGetStatsTimer(Sender: TObject);
begin
  GetStats();
end;

procedure Twelcome.LookOutButton24Click(Sender: TObject);
begin
  Formats.Show;
end;

end.
