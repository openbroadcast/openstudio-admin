unit U_log;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids, MySQLComponent, ComCtrls,
  Spin, DateUtils, BASS, Printers, Menus, JvExButtons, JvBitBtn;

type
  Tlog = class(TForm)
    StringGrid1: TStringGrid;
    StatusBar1: TStatusBar;
    datein: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    dateout: TDateTimePicker;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    timeout: TSpinEdit;
    supprimer: TSpeedButton;
    consulter: TSpeedButton;
    timein: TSpinEdit;
    SpeedButton2: TSpeedButton;
    PrintDialog1: TPrintDialog;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure supprimerClick(Sender: TObject);
    procedure consulterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Déclarations privées }
    x: Integer;
    procedure PrintGrid(const Grid: TStringGrid; const Title: string; Orientation: TPrinterOrientation);
    procedure GetZoneImpressionInPixels(PrinterHandle: HDC; var Height, Width: Integer);

  public
    { Déclarations publiques }
  end;

var
  log: Tlog;

implementation

uses U_Welcome, U_Bibliotheque, U_Jingles;

{$R *.dfm}

procedure ClearStringGrid();
var
  i: Integer;
begin
  for i := 0 to log.StringGrid1.Rowcount - 1 do
  begin
    log.StringGrid1.Rows[i].clear;
  end;
  log.StringGrid1.rowcount := 1;
  log.x := 0;
end;

procedure XlsWriteCellLabel(XlsStream: TStream; const ACol, ARow: Word;
  const AValue: string);
var
  L: Word;
const
{$J+}
  CXlsLabel: array[0..5] of Word = ($204, 0, 0, 0, 0, 0);
{$J-}
begin
  L := Length(AValue);
  CXlsLabel[1] := 8 + L;
  CXlsLabel[2] := ARow;
  CXlsLabel[3] := ACol;
  CXlsLabel[5] := L;
  XlsStream.WriteBuffer(CXlsLabel, SizeOf(CXlsLabel));
  XlsStream.WriteBuffer(Pointer(AValue)^, L);
end;

function SaveAsExcelFile(AGrid: TStringGrid; AFileName: string): Boolean;
const
{$J+}CXlsBof: array[0..5] of Word = ($809, 8, 00, $10, 0, 0); {$J-}
  CXlsEof: array[0..1] of Word = ($0A, 00);
var
  FStream: TFileStream;
  I, J: Integer;
begin
  FStream := TFileStream.Create(PChar(AFileName), fmCreate or fmOpenWrite);
  try
    CXlsBof[4] := 0;
    FStream.WriteBuffer(CXlsBof, SizeOf(CXlsBof));
    for i := 0 to AGrid.ColCount - 1 do
      for j := 0 to AGrid.RowCount - 1 do
        XlsWriteCellLabel(FStream, I, J, AGrid.cells[i, j]);
    FStream.WriteBuffer(CXlsEof, SizeOf(CXlsEof));
    Result := True;
  finally
    FStream.Free;
  end;
end;

procedure Tlog.PrintGrid(const Grid: TStringGrid; const Title: string; Orientation: TPrinterOrientation);
var
  iLOGPIXELSX, iRow, iCol, iWidth, iHeight, X, Y, iPage: integer;
  R: TRect;
  sz: string;
  bDoCenter: boolean;

  procedure PrintTitle;
  var
    iTextW: integer;
    szPage: string;
  begin
    // Titre
    Printer.Canvas.Pen.Color := 0;
    Printer.Canvas.Font.Name := 'Times New Roman';
    Printer.Canvas.Font.Size := 12;
    Printer.Canvas.Font.Style := [fsBold];
    iTextW := Printer.Canvas.TextWidth(Title);
    Printer.Canvas.TextOut((iWidth - iTextW) div 2, 100, Title);

    // N° de page
    Printer.Canvas.Font.Style := [];
    szPage := '- ' + IntToStr(iPage) + ' -';
    iTextW := Printer.Canvas.TextWidth(szPage);
    Printer.Canvas.TextOut((iWidth - iTextW) div 2, iHeight - 90, szPage);

    // Utilise la police de la grille (Pour l'impression des cellules)
    Printer.Canvas.Font.Name := Grid.Font.Name;
    Printer.Canvas.Font.Size := Grid.Font.Size;
    Printer.Canvas.Font.Style := Grid.Font.Style;
  end;

  function GetValue(const Value: integer): integer;
  begin
    Result := MulDiv(Value, iLOGPIXELSX, Self.PixelsPerInch);
  end;

begin
  GetZoneImpressionInPixels(Printer.Handle, iHeight, iWidth);

  // Récupère la résolution de l'écran
  iLOGPIXELSX := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
  iPage := 1;

  Printer.Title := Title;
  Printer.BeginDoc;

  // Titre
  PrintTitle;

  // Initialise le rectangle
  FillChar(R, SizeOf(TRect), #0);
  R.Bottom := 300;

  // Parcours toutes les lignes
  for iRow := 0 to Grid.RowCount - 1 do begin
    R.Right := 0;
    R.Top := R.Bottom;
    R.Bottom := R.Top + GetValue(Grid.RowHeights[iRow]);

    // Pour l'impression des titres de colonne
    bDoCenter := (iRow = 0) and (Grid.FixedRows > 0);

    // Page suivante
    if (R.Bottom > iHeight) then begin
      inc(iPage);
      Printer.NewPage;
      PrintTitle;
      R.Top := 0;
      R.Bottom := R.Top + GetValue(Grid.RowHeights[iRow]);
    end;

    // Parcours toutes les colonnes
    for iCol := 0 to Grid.ColCount - 1 do begin
      // Rectangle d'impression
      R.Left := R.Right;
      R.Right := R.Left + GetValue(Grid.ColWidths[iCol]);

      // Texte à imprimer
      sz := Grid.Cells[iCol, iRow];

      // Imprime le texte
      Y := R.Top + ((R.Bottom - R.Top - Printer.Canvas.TextHeight(sz)) div 2);
      if bDoCenter then X := R.Left + ((R.Right - R.Left - Printer.Canvas.TextWidth(sz)) div 2)
      else X := R.Left + 10;
      Printer.Canvas.TextRect(R, X, Y, sz);
      Printer.Canvas.MoveTo(R.Left, R.Top);
      Printer.Canvas.LineTo(R.Right, R.Top);
      Printer.Canvas.LineTo(R.Right, R.Bottom);
      Printer.Canvas.LineTo(R.Left, R.Bottom);
      Printer.Canvas.LineTo(R.Left, R.Top);
    end;
  end;
  Printer.EndDoc;
end;

//====================================================================================================

procedure Tlog.GetZoneImpressionInPixels(PrinterHandle: HDC; var Height, Width: integer);
begin
  Height := GetDeviceCaps(PrinterHandle, VERTRES);
  Width := GetDeviceCaps(PrinterHandle, HORZRES);
end;



procedure Tlog.FormCreate(Sender: TObject);
begin
  StringGrid1.ColCount := 6;
  StringGrid1.ColWidths[0] := 30;
  StringGrid1.ColWidths[1] := 400;
  StringGrid1.ColWidths[2] := 400;
  StringGrid1.ColWidths[3] := 30;
  StringGrid1.ColWidths[4] := 35;
  StringGrid1.ColWidths[5] := 50;

  dateIn.DateTime := Now();
  dateOut.DateTime := Now();
end;

procedure Tlog.supprimerClick(Sender: TObject);
var
  DatePlayIN, DatePlayOUT: string;
begin
  DatePlayIN := FormatDateTime('yyyy-MM-dd', DateIN.Date) + ' ' + IntToStr(TimeIN.Value) + ':00:00';
  DatePlayOUT := FormatDateTime('yyyy-MM-dd', DateOUT.Date) + ' ' + IntToStr(TimeOUT.Value) + ':00:00';
  Welcome.Sql.Query('DELETE FROM log WHERE Date_Insert >= ''' + DatePlayIN + ''' AND Date_Insert <= ''' + DatePlayOUT + ''' ORDER by Id ASC;');
  ClearStringGrid();
end;

procedure Tlog.consulterClick(Sender: TObject);

var
  Res: PMYSQL_RES;
  Row: PMYSQL_ROW;
  i, j: integer;
  DatePlayIN, DatePlayOUT, RequestSQL: string;
  Duree: Double;
begin

  ClearStringGrid();

  DatePlayIN := FormatDateTime('yyyy-MM-dd', DateIN.Date) + ' ' + IntToStr(TimeIN.Value) + ':00:00';
  DatePlayOUT := FormatDateTime('yyyy-MM-dd', DateOUT.Date) + ' ' + IntToStr(TimeOUT.Value) + ':59:59';

  RequestSQL := 'SELECT playlist.ID, artistes.Name AS Artiste, playlist.Titre, playlist.Annee, playlist.Duree, ';
  RequestSQL := RequestSQL + 'DATE_FORMAT(log.Date_Joue, ''%H:%i:%s'') AS Date_Joue_FR FROM log ';
  RequestSQL := RequestSQL + 'LEFT JOIN playlist ON (playlist.ID=log.PlaylistID) ';
  RequestSQL := RequestSQL + 'LEFT JOIN artistes ON (artistes.ID=playlist.Artiste) ';
  RequestSQL := RequestSQL + 'WHERE log.Date_Joue >= ''' + DatePlayIN + ''' AND log.Date_Joue <= ''' + DatePlayOUT + ''' ORDER by log.Date_Joue ASC;';

  Res := Welcome.Sql.Query(RequestSQL);

  if Res = nil then begin
    StatusBar1.Panels[0].Text := 'Pas de log pour la date demandée';
  end
  else
  try

    StringGrid1.RowCount := Welcome.sql.num_rows(Res);

    j := 0;
    Row := Welcome.sql.fetch_row(Res);
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
      Row := Welcome.sql.fetch_row(Res);
      j := j + 1;
    end;
  finally
    Welcome.sql.free_result(Res);
  end;

end;

procedure Tlog.FormShow(Sender: TObject);
begin
  consulter.Click();
end;

procedure Tlog.SpeedButton2Click(Sender: TObject);
begin
  if (not PrintDialog1.Execute) then Exit;
  PrintGrid(StringGrid1, 'LOG', poPortrait);
end;

procedure Tlog.SpeedButton1Click(Sender: TObject);
begin
  if (not SaveDialog1.Execute) then Exit;
  SaveAsExcelFile(StringGrid1, SaveDialog1.FileName);
end;

end.
