unit U_Formats;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, MySQLComponent;

type
  TFormats = class(TForm)
    formatsName: TComboBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Formats: TFormats;

implementation

uses U_Welcome;

{$R *.dfm}

procedure loadFormats();
var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
begin

    Formats.formatsName.Clear;
    Res := welcome.sql.Query('SELECT ID, Name FROM formats;');
    Row := welcome.sql.fetch_row(Res);

    while Row <> nil do
    begin
      Formats.formatsName.AddItem('(' + Row[0] + ') ' + Row[1], TObject(StrToInt(Row[0])));
      Row := welcome.sql.fetch_row(Res);
    end;

    Formats.formatsName.ItemIndex := 0;

    welcome.sql.free_result(Res);

end;

procedure createFormat(name : String);
begin
  Welcome.Sql.Query('INSERT into formats SET Name='''+ name +''';');
end;

procedure TFormats.FormShow(Sender: TObject);
begin
  loadFormats();
end;

procedure TFormats.BitBtn1Click(Sender: TObject);
var
Reponse : String;
begin
  Reponse := InputBox('Créer un nouveau format', 'Entrez le nom du format a créer', '');
  if(Reponse <> '') then
  begin
    createFormat(Reponse);
    loadFormats();
    ShowMessage('Format créé!');
  end;
end;

procedure TFormats.BitBtn2Click(Sender: TObject);
var
buttonSelected : Integer;
begin
    buttonSelected := MessageDlg('Veuillez confirmer la suppression du format et de son canvas',mtConfirmation, mbOKCancel, 0);

    if buttonSelected = mrOK then
    begin
      Welcome.Sql.Query('DELETE FROM formats WHERE ID='+ IntToStr(integer(formatsName.items.objects[formatsName.itemindex])) +';');
      Welcome.Sql.Query('DELETE FROM canvas WHERE format='+ IntToStr(integer(formatsName.items.objects[formatsName.itemindex])) +';');
      loadFormats();
      ShowMessage('Format supprimé!');
    end;
end;

end.
