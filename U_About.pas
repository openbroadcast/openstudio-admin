unit U_About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls;

type
  TAbout = class(TForm)
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    version: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private

  public
    function ApplicationVersion: string;
    { D�clarations publiques }
  end;

var
  About: TAbout;

implementation

{$R *.dfm}

function TAbout.ApplicationVersion: string;
var
  VerInfoSize, VerValueSize, Dummy: DWord;
  VerInfo: Pointer;
  VerValue: PVSFixedFileInfo;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  {Deux solutions : }
  if VerInfoSize <> 0 then
  {- Les info de version sont inclues }
  begin
    {On alloue de la m�moire pour un pointeur sur les info de version : }
    GetMem(VerInfo, VerInfoSize);
    {On r�cup�re ces informations : }
    GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
    {On traite les informations ainsi r�cup�r�es : }
    with VerValue^ do
    begin
      Result := IntTostr(dwFileVersionMS shr 16);
      Result := Result + '.' + IntTostr(dwFileVersionMS and $FFFF);
      Result := Result + '.' + IntTostr(dwFileVersionLS shr 16);
      Result := Result + '.' + IntTostr(dwFileVersionLS and $FFFF);
    end;

    {On lib�re la place pr�c�demment allou�e : }
    FreeMem(VerInfo, VerInfoSize);
  end

  else
    {- Les infos de version ne sont pas inclues }
    {On d�clenche une exception dans le programme : }
    raise EAccessViolation.Create('0.0.0.0');
end;

procedure TAbout.FormCreate(Sender: TObject);
begin
  Version.Caption := ApplicationVersion;
end;

procedure TAbout.BitBtn1Click(Sender: TObject);
begin
  Self.Close;
end;

end.
