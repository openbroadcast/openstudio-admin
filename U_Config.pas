unit U_Config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, Filectrl, Registry;

type
  TConfig = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Directory: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Config: TConfig;

implementation

{$R *.dfm}

procedure TConfig.BitBtn1Click(Sender: TObject);
var
  Dir: string;
begin
  Dir := 'C:\'; // par exemple...
  if SelectDirectory('Choisissez le répertoire des voice track:', '', Dir) then Directory.Text := Dir + '\';
  //if SelectDirectory(Dir, [sdAllowCreate, sdPerformCreate, sdPrompt], 0) then Directory.Text := Dir + '\';
end;


procedure TConfig.FormCreate(Sender: TObject);
begin
  with TRegistry.Create do
  try
    OpenKey('Software\OpenStudio\Admin', true);
    if ValueExists('VoiceTrackPath') then Directory.Text := ReadString('VoiceTrackPath');
  finally
    Free;
  end;
end;

procedure TConfig.BitBtn2Click(Sender: TObject);
begin
  with TRegistry.Create do
  try
    OpenKey('Software\OpenStudio\Admin', true);
    WriteString('VoiceTrackPath', Directory.Text);
  finally
    Free;
  end;
  Close;
end;

procedure TConfig.BitBtn3Click(Sender: TObject);
begin
  Close;
end;

end.
