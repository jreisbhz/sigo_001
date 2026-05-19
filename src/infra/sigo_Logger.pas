unit sigo_Logger;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes;

type
  TsigoLogger = class
  private
    FCaminhoLogs: string;
    procedure RegistrarInterno(const ANivel, AMensagem: string);
  public
    class var FInstancia: TsigoLogger;
    class function Instancia: TsigoLogger;
    constructor Create;
    procedure Info(const AMensagem: string);
    procedure Aviso(const AMensagem: string);
    procedure Erro(const AMensagem: string);
    procedure Debug(const AMensagem: string);
  end;

function Logger: TsigoLogger;

implementation

function Logger: TsigoLogger;
begin
  Result := TsigoLogger.Instancia;
end;

class function TsigoLogger.Instancia: TsigoLogger;
begin
  if not Assigned(FInstancia) then
    FInstancia := TsigoLogger.Create;
  Result := FInstancia;
end;

constructor TsigoLogger.Create;
begin
  inherited Create;
  FCaminhoLogs := ExtractFilePath(ParamStr(0)) + 'logs' + PathDelim;
  if not DirectoryExists(FCaminhoLogs) then
    ForceDirectories(FCaminhoLogs);
end;

procedure TsigoLogger.RegistrarInterno(const ANivel, AMensagem: string);
var
  LArquivo: string;
  LArq: TextFile;
  LLogMensagem: string;
begin
  LArquivo := FCaminhoLogs + 'sigo_' + FormatDateTime('yyyymmdd', Date) + '.log';
  LLogMensagem := Format('[%s] [%s] %s',
    [FormatDateTime('hh:nn:ss', Now), ANivel, AMensagem]);

  try
    AssignFile(LArq, LArquivo);
    if FileExists(LArquivo) then
      Append(LArq)
    else
      Rewrite(LArq);
    try
      WriteLn(LArq, LLogMensagem);
    finally
      CloseFile(LArq);
    end;
  except
    // Silenciosamente ignora erros de log
  end;
end;

procedure TsigoLogger.Info(const AMensagem: string);
begin
  RegistrarInterno('INFO', AMensagem);
end;

procedure TsigoLogger.Aviso(const AMensagem: string);
begin
  RegistrarInterno('AVISO', AMensagem);
end;

procedure TsigoLogger.Erro(const AMensagem: string);
begin
  RegistrarInterno('ERRO', AMensagem);
end;

procedure TsigoLogger.Debug(const AMensagem: string);
begin
  {$IFDEF DEBUG}
  RegistrarInterno('DEBUG', AMensagem);
  {$ENDIF}
end;

end.
