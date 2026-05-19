unit sigo_RepoCliente;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_BaseRepository, sigo_ModelCliente;

type
  TsigoRepoCliente = class(TsigoBaseRepository)
  public
    constructor Create;
    function BuscarPorCPFCNPJ(const ACpfCnpj: string): TsigoModelCliente;
    procedure Salvar(const ACliente: TsigoModelCliente);
    procedure Atualizar(const ACliente: TsigoModelCliente);
    function ListarTodos: TSQLQuery;
    function BuscarPorNome(const ANome: string): TSQLQuery;
  end;

implementation

constructor TsigoRepoCliente.Create;
begin
  inherited Create('clientes');
end;

function TsigoRepoCliente.BuscarPorCPFCNPJ(const ACpfCnpj: string): TsigoModelCliente;
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  Result := nil;
  LSQL := 'SELECT * FROM clientes WHERE cpf_cnpj = :CPFCNPJ';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('CPFCNPJ').AsString := ACpfCnpj;
    LQuery.Open;
    if not LQuery.EOF then
    begin
      Result := TsigoModelCliente.Create;
      Result.ID := LQuery.FieldByName('id').AsInteger;
      Result.TipoPessoa := LQuery.FieldByName('tipo_pessoa').AsString;
      Result.Nome := LQuery.FieldByName('nome').AsString;
      Result.CpfCnpj := LQuery.FieldByName('cpf_cnpj').AsString;
      Result.Email := LQuery.FieldByName('email').AsString;
      Result.Celular := LQuery.FieldByName('celular').AsString;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoCliente.Salvar(const ACliente: TsigoModelCliente);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO clientes (tipo_pessoa, nome, fantasia, cpf_cnpj, rg_ie, ' +
          'data_nasc, logradouro, numero, complemento, bairro, cidade, uf, cep, ' +
          'telefone, celular, celular2, email, observacoes, limite_credito, ativo) ' +
          'VALUES (:TP, :NOME, :FANTASIA, :CPFCNPJ, :RGIE, :DATA, :LOG, :NUM, ' +
          ':COMP, :BAIRRO, :CIDADE, :UF, :CEP, :TEL, :CEL, :CEL2, :EMAIL, :OBS, ' +
          ':LIMITE, :ATIVO)';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('TP').AsString := ACliente.TipoPessoa;
    LQuery.ParamByName('NOME').AsString := ACliente.Nome;
    LQuery.ParamByName('FANTASIA').AsString := ACliente.Fantasia;
    LQuery.ParamByName('CPFCNPJ').AsString := ACliente.CpfCnpj;
    LQuery.ParamByName('RGIE').AsString := ACliente.RgIe;
    LQuery.ParamByName('DATA').AsDate := ACliente.DataNasc;
    LQuery.ParamByName('LOG').AsString := ACliente.Logradouro;
    LQuery.ParamByName('NUM').AsString := ACliente.Numero;
    LQuery.ParamByName('COMP').AsString := ACliente.Complemento;
    LQuery.ParamByName('BAIRRO').AsString := ACliente.Bairro;
    LQuery.ParamByName('CIDADE').AsString := ACliente.Cidade;
    LQuery.ParamByName('UF').AsString := ACliente.UF;
    LQuery.ParamByName('CEP').AsString := ACliente.CEP;
    LQuery.ParamByName('TEL').AsString := ACliente.Telefone;
    LQuery.ParamByName('CEL').AsString := ACliente.Celular;
    LQuery.ParamByName('CEL2').AsString := ACliente.Celular2;
    LQuery.ParamByName('EMAIL').AsString := ACliente.Email;
    LQuery.ParamByName('OBS').AsString := ACliente.Observacoes;
    LQuery.ParamByName('LIMITE').AsFloat := ACliente.LimiteCredito;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(ACliente.Ativo);
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoCliente.Atualizar(const ACliente: TsigoModelCliente);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'UPDATE clientes SET nome = :NOME, email = :EMAIL, celular = :CEL, ' +
          'cidade = :CIDADE, ativo = :ATIVO WHERE id = :ID';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('NOME').AsString := ACliente.Nome;
    LQuery.ParamByName('EMAIL').AsString := ACliente.Email;
    LQuery.ParamByName('CEL').AsString := ACliente.Celular;
    LQuery.ParamByName('CIDADE').AsString := ACliente.Cidade;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(ACliente.Ativo);
    LQuery.ParamByName('ID').AsInteger := ACliente.ID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoRepoCliente.ListarTodos: TSQLQuery;
begin
  Result := Listar('ativo = 1 ORDER BY nome');
end;

function TsigoRepoCliente.BuscarPorNome(const ANome: string): TSQLQuery;
begin
  Result := Listar('ativo = 1 AND nome LIKE ''%' + ANome + '%'' ORDER BY nome');
end;

end.
