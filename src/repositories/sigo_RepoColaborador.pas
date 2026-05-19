unit sigo_RepoColaborador;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_BaseRepository, sigo_ModelColaborador;

type
  TsigoRepoColaborador = class(TsigoBaseRepository)
  public
    constructor Create;
    procedure Salvar(const AColaborador: TsigoModelColaborador);
    procedure Atualizar(const AColaborador: TsigoModelColaborador);
    function ListarTodos: TSQLQuery;
    function ListarMecanicos: TSQLQuery;
  end;

implementation

constructor TsigoRepoColaborador.Create;
begin
  inherited Create('colaboradores');
end;

procedure TsigoRepoColaborador.Salvar(const AColaborador: TsigoModelColaborador);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO colaboradores (usuario_id, nome, cpf, rg, data_nasc, ' +
          'cargo, especialidade, telefone, celular, email, data_admissao, salario, ' +
          'comissao_pct, ativo) VALUES (:USERID, :NOME, :CPF, :RG, :DATA, :CARGO, ' +
          ':ESPEC, :TEL, :CEL, :EMAIL, :ADMISSAO, :SALARIO, :COMISSAO, :ATIVO)';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('USERID').AsInteger := AColaborador.UsuarioID;
    LQuery.ParamByName('NOME').AsString := AColaborador.Nome;
    LQuery.ParamByName('CPF').AsString := AColaborador.CPF;
    LQuery.ParamByName('RG').AsString := AColaborador.RG;
    LQuery.ParamByName('DATA').AsDate := AColaborador.DataNasc;
    LQuery.ParamByName('CARGO').AsString := AColaborador.Cargo;
    LQuery.ParamByName('ESPEC').AsString := AColaborador.Especialidade;
    LQuery.ParamByName('TEL').AsString := AColaborador.Telefone;
    LQuery.ParamByName('CEL').AsString := AColaborador.Celular;
    LQuery.ParamByName('EMAIL').AsString := AColaborador.Email;
    LQuery.ParamByName('ADMISSAO').AsDate := AColaborador.DataAdmissao;
    LQuery.ParamByName('SALARIO').AsFloat := AColaborador.Salario;
    LQuery.ParamByName('COMISSAO').AsFloat := AColaborador.ComissaoPct;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(AColaborador.Ativo);
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoColaborador.Atualizar(const AColaborador: TsigoModelColaborador);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'UPDATE colaboradores SET nome = :NOME, cargo = :CARGO, ' +
          'especialidade = :ESPEC, ativo = :ATIVO WHERE id = :ID';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('NOME').AsString := AColaborador.Nome;
    LQuery.ParamByName('CARGO').AsString := AColaborador.Cargo;
    LQuery.ParamByName('ESPEC').AsString := AColaborador.Especialidade;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(AColaborador.Ativo);
    LQuery.ParamByName('ID').AsInteger := AColaborador.ID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoRepoColaborador.ListarTodos: TSQLQuery;
begin
  Result := Listar('ativo = 1 ORDER BY nome');
end;

function TsigoRepoColaborador.ListarMecanicos: TSQLQuery;
begin
  Result := Listar('ativo = 1 AND especialidade IS NOT NULL ORDER BY nome');
end;

end.
