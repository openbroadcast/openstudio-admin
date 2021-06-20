unit U_ConfMySQL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Registry, Mask;

type
  TConfMySQL = class(TForm)
    GroupBox1: TGroupBox;
    serveur: TEdit;
    login: TEdit;
    base: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    motdepasse: TMaskEdit;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  ConfMySQL: TConfMySQL;

implementation

{$R *.dfm}

procedure TConfMySQL.BitBtn1Click(Sender: TObject);
begin
  Hide;
end;

procedure TConfMySQL.BitBtn2Click(Sender: TObject);
begin
  with TRegistry.Create do
  try
    OpenKey('Software\OpenStudio\Admin', true);
    WriteString('serveur', serveur.Text);
    WriteString('login', login.Text);
    WriteString('motdepasse', motdepasse.Text);
    WriteString('base', base.Text);
  finally
    Free;
  end;
  ShowMessage('Redémarrez le logiciel');
  Application.Terminate;
end;

procedure TConfMySQL.FormShow(Sender: TObject);
begin
  with TRegistry.Create do
  try
    OpenKey('Software\OpenStudio\Admin', true);
    if ValueExists('serveur') then
      serveur.Text := ReadString('serveur');
    if ValueExists('login') then
      login.Text := ReadString('login');
    if ValueExists('motdepasse') then
      motdepasse.Text := ReadString('motdepasse');
    if ValueExists('base') then
      base.Text := ReadString('base');

  finally
    Free;
  end;
end;

end.
