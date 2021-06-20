unit ExecAndWait;

interface
uses
  Windows, ShellApi;

procedure ExecuteWait(Programme: string; Arguments: string);

implementation

procedure ExecuteWait(Programme: string; Arguments: string);
var ShExecInfo: TShellExecuteInfo;
begin
  FillChar(ShExecInfo, SizeOf(ShExecInfo), 0);
  with ShExecInfo do begin
    cbSize := SizeOf(ShExecInfo);
    fMask := SEE_MASK_NOCLOSEPROCESS;
    lpFile := PChar(Programme);
    lpParameters := PChar(Arguments);
    lpVerb := 'open';
    nShow := SW_HIDE;
  end;
  if ShellExecuteEx(@ShExecInfo) then begin { on execute le programme }
    WaitForSingleObject(ShExecInfo.hProcess, INFINITE); { on attends un temps indefinis que l'application externe s'arrete }
  end;
end;

end.
