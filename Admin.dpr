program Admin;

uses
  Forms,
  U_Admin in 'U_Admin.pas' {Ajout},
  mysql in 'mysql.pas',
  mysqlcomp in 'mysqlcomp.pas',
  U_Welcome in 'U_Welcome.pas' {welcome},
  U_ConfMySQL in 'U_ConfMySQL.pas' {ConfMySQL},
  U_About in 'U_About.pas' {About},
  U_Waitlist in 'U_Waitlist.pas' {waitlist},
  U_Gestion in 'U_Gestion.pas' {Gestion},
  FindCat in 'FindCat.pas' {FindCategory},
  U_Bibliotheque in 'U_Bibliotheque.pas' {Bibliotheque},
  U_Jingles in 'U_Jingles.pas' {Jingles},
  U_GrillePub in 'U_GrillePub.pas' {GrillePub},
  U_Timer in 'U_Timer.pas' {Timer},
  U_Canvas in 'U_Canvas.pas' {CanvasControl},
  U_Users in 'U_Users.pas' {Users},
  U_Campaign in 'U_Campaign.pas' {Campaign},
  U_SelectPub in 'U_SelectPub.pas' {SelectPub},
  U_Planning in 'U_Planning.pas' {Planning},
  U_Stations in 'U_Stations.pas' {StationsForm},
  U_PubLocale in 'U_PubLocale.pas' {PubLocale},
  U_ModifyDuree in 'U_ModifyDuree.pas' {ModifyDuree},
  U_log in 'U_Log.pas' {log},
  U_Config in 'U_Config.pas' {Config},
  U_Administration in 'U_Administration.pas' {Administration},
  U_AddZikToPage in 'U_AddZikToPage.pas' {PageSelector},
  Bass in 'Bass.pas',
  ExecAndWait in 'ExecAndWait.pas',
  U_Formats in 'U_Formats.pas' {Formats},
  U_Category in 'U_Category.pas' {Category};

{$E .exe}

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'OpenStudio Administrator';
  Application.CreateForm(Twelcome, welcome);
  Application.CreateForm(TAjout, Ajout);
  Application.CreateForm(TConfMySQL, ConfMySQL);
  Application.CreateForm(TAbout, About);
  Application.CreateForm(Twaitlist, waitlist);
  Application.CreateForm(TGestion, Gestion);
  Application.CreateForm(TFindCategory, FindCategory);
  Application.CreateForm(TBibliotheque, Bibliotheque);
  Application.CreateForm(TJingles, Jingles);
  Application.CreateForm(TGrillePub, GrillePub);
  Application.CreateForm(TTimer, Timer);
  Application.CreateForm(TCanvasControl, CanvasControl);
  Application.CreateForm(TUsers, Users);
  Application.CreateForm(TCampaign, Campaign);
  Application.CreateForm(TSelectPub, SelectPub);
  Application.CreateForm(TPlanning, Planning);
  Application.CreateForm(TStationsForm, StationsForm);
  Application.CreateForm(TPubLocale, PubLocale);
  Application.CreateForm(TModifyDuree, ModifyDuree);
  Application.CreateForm(Tlog, log);
  Application.CreateForm(TConfig, Config);
  Application.CreateForm(TAdministration, Administration);
  Application.CreateForm(TPageSelector, PageSelector);
  Application.CreateForm(TFormats, Formats);
  Application.CreateForm(TCategory, Category);
  Application.Run;
end.

