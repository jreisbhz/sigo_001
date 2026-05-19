unit sigo_RepoUsuario;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_BaseRepository, sigo_ModelUsuario;

type
  TsigoRepoUsuario = class(TsigoBaseRepository)
  public
    constructor Create;
    function BuscarPorLogin(const ALogin, ASenhaHash: string): TsigoModelUsuario;
    procedure Salvar(const AUsuario: TsigoModelUsuario);
    procedure Atualizar(const AUsuario: TsigoModelUsuario);
    function ListarTodos: TSQLQuery;
  end;

implementation

constructor TsigoRepoUsuario.Create;
begin
  inherited Create('usuarios');
end;

function TsigoRepoUsuario.BuscarPorLogin(const ALogin, ASenhaHash: string): TsigoModelUsuario;
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  Result := nil;
  LSQL := 'SELECT * FROM usuarios WHERE login = :LOGIN AND senha_hash = :SENHA';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('LOGIN').AsString := ALogin;
    LQuery.ParamByName('SENHA').AsString := ASenhaHash;
    LQuery.Open;
    if not LQuery.EOF then
    begin
      Result := TsigoModelUsuario.Create;
      Result.ID := LQuery.FieldByName('id').AsInteger;
      Result.Nome := LQuery.FieldByName('nome').AsString;
      Result.Login := LQuery.FieldByName('login').AsString;
      Result.SenhaHash := LQuery.FieldByName('senha_hash').AsString;
      Result.Perfil := LQuery.FieldByName('perfil').AsString;
      Result.Ativo := LQuery.FieldByName('ativo').AsInteger = 1;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoUsuario.Salvar(const AUsuario: TsigoModelUsuario);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO usuarios (nome, login, senha_hash, perfil, ativo) ' +
          'VALUES (:NOME, :LOGIN, :SENHA, :PERFIL, :ATIVO)';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('NOME').AsString := AUsuario.Nome;
    LQuery.ParamByName('LOGIN').AsString := AUsuario.Login;
    LQuery.ParamByName('SENHA').AsString := AUsuario.SenhaHash;
    LQuery.ParamByName('PERFIL').AsString := AUsuario.Perfil;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(AUsuario.Ativo);
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoUsuario.Atualizar(const AUsuario: TsigoModelUsuario);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'UPDATE usuarios SET nome = :NOME, perfil = :PERFIL, ativo = :ATIVO ' +
          'WHERE id = :ID';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('NOME').AsString := AUsuario.Nome;
    LQuery.ParamByName('PERFIL').AsString := AUsuario.Perfil;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(AUsuario.Ativo);
    LQuery.ParamByName('ID').AsInteger := AUsuario.ID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoRepoUsuario.ListarTodos: TSQLQuery;
begin
  Result := Listar('ativo = 1');
end;

end.
