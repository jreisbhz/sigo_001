unit sigo_BaseRepository;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_DBConnection;

type
  TsigoBaseRepository = class
  protected
    FDB: TsigoDBConnection;
    FTabela: string;
    function NovaQuery: TSQLQuery;
    function ExecutarQuery(const ASQL: string): TSQLQuery;
  public
    constructor Create(const ATabela: string);
    function BuscarPorID(AID: Integer): TSQLQuery;
    function Listar(const AFiltro: string = ''): TSQLQuery;
    procedure Inserir(const ASQL: string);
    procedure Atualizar(const ASQL: string);
    procedure Excluir(AID: Integer);
  end;

implementation

constructor TsigoBaseRepository.Create(const ATabela: string);
begin
  inherited Create;
  FDB := TsigoDBConnection.Instancia;
  FTabela := ATabela;
end;

function TsigoBaseRepository.NovaQuery: TSQLQuery;
begin
  Result := FDB.NovaQuery;
end;

function TsigoBaseRepository.ExecutarQuery(const ASQL: string): TSQLQuery;
begin
  Result := NovaQuery;
  Result.SQL.Text := ASQL;
  Result.Open;
end;

function TsigoBaseRepository.BuscarPorID(AID: Integer): TSQLQuery;
var
  LSQL: string;
begin
  LSQL := 'SELECT * FROM ' + FTabela + ' WHERE id = :ID';
  Result := NovaQuery;
  Result.SQL.Text := LSQL;
  Result.ParamByName('ID').AsInteger := AID;
  Result.Open;
end;

function TsigoBaseRepository.Listar(const AFiltro: string = ''): TSQLQuery;
var
  LSQL: string;
begin
  LSQL := 'SELECT * FROM ' + FTabela;
  if AFiltro <> '' then
    LSQL := LSQL + ' WHERE ' + AFiltro;
  Result := ExecutarQuery(LSQL);
end;

procedure TsigoBaseRepository.Inserir(const ASQL: string);
var
  LQuery: TSQLQuery;
begin
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := ASQL;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoBaseRepository.Atualizar(const ASQL: string);
var
  LQuery: TSQLQuery;
begin
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := ASQL;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoBaseRepository.Excluir(AID: Integer);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'DELETE FROM ' + FTabela + ' WHERE id = :ID';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('ID').AsInteger := AID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

end.
