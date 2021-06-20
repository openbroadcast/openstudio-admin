unit U_Administration;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TAdministration = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    SQL: TMemo;
    BitBtn1: TBitBtn;
    GroupBox3: TGroupBox;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Administration: TAdministration;

implementation

uses U_Welcome;

{$R *.dfm}

procedure TAdministration.BitBtn1Click(Sender: TObject);
begin
  welcome.sql.Query(SQL.Text);
end;

procedure TAdministration.BitBtn2Click(Sender: TObject);
begin
  SQL.Clear;
  SQL.Lines.Add('UPDATE playlist SET Date_Joue=''0000-00-00 00:00:00'';');
end;

procedure TAdministration.BitBtn3Click(Sender: TObject);
begin
  SQL.Clear;
  SQL.Lines.Add('UPDATE artistes SET LastBroadcasting=''0000-00-00 00:00:00'';');
end;

end.
