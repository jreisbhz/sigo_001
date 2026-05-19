unit sigo_DBConnection;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, sqldb, sqlite3conn, db, sigo_Config, sigo_Logger;

type
  TsigoDBConnection = class
  private
    FCon: TSQLite3Connection;
    FTran: TSQLTransaction;
    procedure InicializarConexao;
    procedure CriarBancoSeDNaoExistir;
  public
    class var FInstancia: TsigoDBConnection;
    class function Instancia: TsigoDBConnection;
    constructor Create;
    destructor Destroy; override;
    function NovaQuery: TSQLQuery;
    procedure ExecutarSQL(const ASQL: string);
    procedure Commit;
    procedure Rollback;
    procedure Verificar;
    property Conexao: TSQLite3Connection read FCon;
    property Transacao: TSQLTransaction read FTran;
  end;

function DBConnection: TsigoDBConnection;

implementation

function DBConnection: TsigoDBConnection;
begin
  Result := TsigoDBConnection.Instancia;
end;

class function TsigoDBConnection.Instancia: TsigoDBConnection;
begin
  if not Assigned(FInstancia) then
    FInstancia := TsigoDBConnection.Create;
  Result := FInstancia;
end;

constructor TsigoDBConnection.Create;
begin
  inherited Create;
  FCon := TSQLite3Connection.Create(nil);
  FTran := TSQLTransaction.Create(nil);
  FTran.DataBase := FCon;
  FCon.Transaction := FTran;
  InicializarConexao;
end;

destructor TsigoDBConnection.Destroy;
begin
  if Assigned(FCon) and FCon.Connected then
    FCon.Close;
  FreeAndNil(FTran);
  FreeAndNil(FCon);
  inherited Destroy;
end;

procedure TsigoDBConnection.InicializarConexao;
var
  LCaminhoBanco: string;
begin
  LCaminhoBanco := ExtractFilePath(ParamStr(0)) + Config.Banco;
  FCon.DatabaseName := LCaminhoBanco;
  try
    FCon.Connected := True;
    Logger.Info('Banco de dados conectado: ' + LCaminhoBanco);
  except
    on E: Exception do
    begin
      Logger.Erro('Erro ao conectar banco: ' + E.Message);
      raise;
    end;
  end;
end;

procedure TsigoDBConnection.CriarBancoSeDNaoExistir;
var
  LArquivoDDL: string;
  LConteudo: TStringList;
  LSQL: string;
begin
  LArquivoDDL := ExtractFilePath(ParamStr(0)) + '..' + PathDelim + 'database' +
                 PathDelim + 'DDL_SIGO_001.sql';

  if FileExists(LArquivoDDL) then
  begin
    LConteudo := TStringList.Create;
    try
      LConteudo.LoadFromFile(LArquivoDDL);
      LSQL := LConteudo.Text;
      ExecutarSQL(LSQL);
      Logger.Info('Banco de dados inicializado com sucesso');
    finally
      LConteudo.Free;
    end;
  end;
end;

procedure TsigoDBConnection.Verificar;
begin
  InicializarConexao;
  if not FCon.Connected then
    raise Exception.Create('Falha ao conectar ao banco de dados');
end;

function TsigoDBConnection.NovaQuery: TSQLQuery;
begin
  Result := TSQLQuery.Create(nil);
  Result.DataBase := FCon;
  Result.Transaction := FTran;
end;

procedure TsigoDBConnection.ExecutarSQL(const ASQL: string);
var
  LQuery: TSQLQuery;
begin
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := ASQL;
    LQuery.ExecSQL;
    Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoDBConnection.Commit;
begin
  try
    FTran.Commit;
  except
    Logger.Erro('Erro ao fazer commit da transação');
  end;
end;

procedure TsigoDBConnection.Rollback;
begin
  try
    FTran.Rollback;
  except
    Logger.Erro('Erro ao fazer rollback da transação');
  end;
end;

end.
