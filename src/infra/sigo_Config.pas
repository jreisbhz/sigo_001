unit sigo_Config;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, IniFiles, Classes;

type
  TsigoConfig = class
  private
    FIniFile: TIniFile;
    FCaminhoIni: string;
    procedure CarregarIni;
    function GetNomeSistema: string;
    function GetVersao: string;
    function GetBanco: string;
    function GetLogDir: string;
    function GetTema: string;
  public
    class var FInstancia: TsigoConfig;
    class function Instancia: TsigoConfig;
    constructor Create;
    destructor Destroy; override;
    procedure Salvar;
    function ObterString(const ASecao, AChave, APadrao: string): string;
    procedure DefinirString(const ASecao, AChave, AValor: string);
    function ObterInteiro(const ASecao, AChave: string; APadrao: Integer): Integer;
    procedure DefinirInteiro(const ASecao, AChave: string; AValor: Integer);
    function ObterBooleano(const ASecao, AChave: string; APadrao: Boolean): Boolean;
    property NomeSistema: string read GetNomeSistema;
    property Versao: string read GetVersao;
    property Banco: string read GetBanco;
    property LogDir: string read GetLogDir;
    property Tema: string read GetTema;
  end;

function Config: TsigoConfig;

implementation

function Config: TsigoConfig;
begin
  Result := TsigoConfig.Instancia;
end;

class function TsigoConfig.Instancia: TsigoConfig;
begin
  if not Assigned(FInstancia) then
    FInstancia := TsigoConfig.Create;
  Result := FInstancia;
end;

procedure TsigoConfig.CarregarIni;
var
  LCaminho: string;
begin
  LCaminho := ExtractFilePath(ParamStr(0)) + 'config' + PathDelim + 'sigo.ini';
  FCaminhoIni := LCaminho;
  if not FileExists(LCaminho) then
  begin
    FIniFile := TIniFile.Create(LCaminho);
    FIniFile.WriteString('Sistema', 'NomeSistema', 'SIGO');
    FIniFile.WriteString('Sistema', 'Versao', '1.0.0');
    FIniFile.WriteString('Sistema', 'Tema', 'DARK');
    FIniFile.WriteString('Banco', 'Arquivo', 'sigo.db');
    FIniFile.WriteString('Log', 'Diretorio', 'logs');
    FIniFile.Free;
  end;
  FIniFile := TIniFile.Create(LCaminho);
end;

constructor TsigoConfig.Create;
begin
  inherited Create;
  CarregarIni;
end;

destructor TsigoConfig.Destroy;
begin
  if Assigned(FIniFile) then
    FreeAndNil(FIniFile);
  inherited Destroy;
end;

procedure TsigoConfig.Salvar;
begin
  if Assigned(FIniFile) then
    FIniFile.UpdateFile;
end;

function TsigoConfig.GetNomeSistema: string;
begin
  Result := ObterString('Sistema', 'NomeSistema', 'SIGO');
end;

function TsigoConfig.GetVersao: string;
begin
  Result := ObterString('Sistema', 'Versao', '1.0.0');
end;

function TsigoConfig.GetBanco: string;
begin
  Result := ObterString('Banco', 'Arquivo', 'sigo.db');
end;

function TsigoConfig.GetLogDir: string;
begin
  Result := ObterString('Log', 'Diretorio', 'logs');
end;

function TsigoConfig.GetTema: string;
begin
  Result := ObterString('Sistema', 'Tema', 'DARK');
end;

function TsigoConfig.ObterString(const ASecao, AChave, APadrao: string): string;
begin
  if Assigned(FIniFile) then
    Result := FIniFile.ReadString(ASecao, AChave, APadrao)
  else
    Result := APadrao;
end;

procedure TsigoConfig.DefinirString(const ASecao, AChave, AValor: string);
begin
  if Assigned(FIniFile) then
    FIniFile.WriteString(ASecao, AChave, AValor);
end;

function TsigoConfig.ObterInteiro(const ASecao, AChave: string; APadrao: Integer): Integer;
begin
  if Assigned(FIniFile) then
    Result := FIniFile.ReadInteger(ASecao, AChave, APadrao)
  else
    Result := APadrao;
end;

procedure TsigoConfig.DefinirInteiro(const ASecao, AChave: string; AValor: Integer);
begin
  if Assigned(FIniFile) then
    FIniFile.WriteInteger(ASecao, AChave, AValor);
end;

function TsigoConfig.ObterBooleano(const ASecao, AChave: string; APadrao: Boolean): Boolean;
begin
  if Assigned(FIniFile) then
    Result := FIniFile.ReadBool(ASecao, AChave, APadrao)
  else
    Result := APadrao;
end;

end.
