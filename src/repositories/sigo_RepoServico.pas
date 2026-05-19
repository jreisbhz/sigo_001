unit sigo_RepoServico;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_BaseRepository, sigo_ModelServico;

type
  TsigoRepoServico = class(TsigoBaseRepository)
  public
    constructor Create;
    function BuscarPorCodigo(const ACodigo: string): TsigoModelServico;
    procedure Salvar(const AServico: TsigoModelServico);
    procedure Atualizar(const AServico: TsigoModelServico);
    function ListarTodos: TSQLQuery;
  end;

implementation

constructor TsigoRepoServico.Create;
begin
  inherited Create('servicos');
end;

function TsigoRepoServico.BuscarPorCodigo(const ACodigo: string): TsigoModelServico;
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  Result := nil;
  LSQL := 'SELECT * FROM servicos WHERE codigo = :CODIGO';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('CODIGO').AsString := ACodigo;
    LQuery.Open;
    if not LQuery.EOF then
    begin
      Result := TsigoModelServico.Create;
      Result.ID := LQuery.FieldByName('id').AsInteger;
      Result.Codigo := LQuery.FieldByName('codigo').AsString;
      Result.Nome := LQuery.FieldByName('nome').AsString;
      Result.ValorPadrao := LQuery.FieldByName('valor_padrao').AsFloat;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoServico.Salvar(const AServico: TsigoModelServico);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO servicos (codigo, nome, descricao, valor_padrao, ' +
          'tempo_estimado, ativo) VALUES (:COD, :NOME, :DESC, :VALOR, :TEMPO, :ATIVO)';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('COD').AsString := AServico.Codigo;
    LQuery.ParamByName('NOME').AsString := AServico.Nome;
    LQuery.ParamByName('DESC').AsString := AServico.Descricao;
    LQuery.ParamByName('VALOR').AsFloat := AServico.ValorPadrao;
    LQuery.ParamByName('TEMPO').AsInteger := AServico.TempoEstimado;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(AServico.Ativo);
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoServico.Atualizar(const AServico: TsigoModelServico);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'UPDATE servicos SET nome = :NOME, valor_padrao = :VALOR, ativo = :ATIVO ' +
          'WHERE id = :ID';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('NOME').AsString := AServico.Nome;
    LQuery.ParamByName('VALOR').AsFloat := AServico.ValorPadrao;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(AServico.Ativo);
    LQuery.ParamByName('ID').AsInteger := AServico.ID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoRepoServico.ListarTodos: TSQLQuery;
begin
  Result := Listar('ativo = 1 ORDER BY nome');
end;

end.
