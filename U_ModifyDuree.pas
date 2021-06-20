unit U_ModifyDuree;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, MysqlComponent, BASS;

type
  TModifyDuree = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    StatusBar1: TStatusBar;
    actif: TCheckBox;
    Button2: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    c1: Integer;
    Stop: Boolean;
    { Déclarations publiques }
  end;

var
  ModifyDuree: TModifyDuree;

implementation

uses U_Welcome;

{$R *.dfm}

procedure TModifyDuree.Button1Click(Sender: TObject);
var
  Temps: Single;
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  RequestSQL: string;
begin

  Res := Welcome.Sql.Query('SELECT id, Path FROM playlist ORDER by id ASC;');

  if Res = nil then begin
    StatusBar1.Panels[0].Text := 'Pas de médias ?';
  end
  else
  try

    Row := Welcome.sql.fetch_row(Res);
    while Row <> nil do
    begin

      c1 := BASS_StreamCreateFile(False, PChar(Row[1]), 0, 0, 0);
      Temps := BASS_ChannelBytes2Seconds(c1, BASS_ChannelGetLength(c1, 0));
      BASS_ChannelStop(c1);
      BASS_StreamFree(c1);
      RequestSQL := 'UPDATE playlist SET Duree=''' + StringReplace(format('%.2f', [Temps]), ',', '.', [rfReplaceAll]) + ''' WHERE id=''' + Row[0] + '''';
      Memo1.Lines.Add(RequestSQL);
      if (actif.Checked) then Welcome.Sql.Query(RequestSQL);
      Row := Welcome.sql.fetch_row(Res);
      Application.ProcessMessages;

      if (Stop = True) then
      begin
        Stop := False;
        Break;
      end;

    end;
  finally
    Welcome.sql.free_result(Res);
  end;

end;

procedure TModifyDuree.Button2Click(Sender: TObject);
begin
  Stop := True;
  Memo1.Clear;
end;

end.
