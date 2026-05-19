unit sigo_RepoFornecedor;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_BaseRepository, sigo_ModelFornecedor;

type
  TsigoRepoFornecedor = class(TsigoBaseRepository)
  public
    constructor Create;
    procedure Salvar(const AFornecedor: TsigoModelFornecedor);
    procedure Atualizar(const AFornecedor: TsigoModelFornecedor);
    function ListarTodos: TSQLQuery;
  end;

implementation

constructor TsigoRepoFornecedor.Create;
begin
  inherited Create('fornecedores');
end;

procedure TsigoRepoFornecedor.Salvar(const AFornecedor: TsigoModelFornecedor);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO fornecedores (tipo_pessoa, razao_social, fantasia, cnpj_cpf, ' +
          'ie, logradouro, numero, complemento, bairro, cidade, uf, cep, telefone, ' +
          'celular, email, contato, observacoes, ativo) VALUES (:TP, :RAZAO, ' +
          ':FANTASIA, :CNPJ, :IE, :LOG, :NUM, :COMP, :BAIRRO, :CIDADE, :UF, :CEP, ' +
          ':TEL, :CEL, :EMAIL, :CONTATO, :OBS, :ATIVO)';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('TP').AsString := AFornecedor.TipoPessoa;
    LQuery.ParamByName('RAZAO').AsString := AFornecedor.RazaoSocial;
    LQuery.ParamByName('FANTASIA').AsString := AFornecedor.Fantasia;
    LQuery.ParamByName('CNPJ').AsString := AFornecedor.CnpjCpf;
    LQuery.ParamByName('IE').AsString := AFornecedor.IE;
    LQuery.ParamByName('LOG').AsString := AFornecedor.Logradouro;
    LQuery.ParamByName('NUM').AsString := AFornecedor.Numero;
    LQuery.ParamByName('COMP').AsString := AFornecedor.Complemento;
    LQuery.ParamByName('BAIRRO').AsString := AFornecedor.Bairro;
    LQuery.ParamByName('CIDADE').AsString := AFornecedor.Cidade;
    LQuery.ParamByName('UF').AsString := AFornecedor.UF;
    LQuery.ParamByName('CEP').AsString := AFornecedor.CEP;
    LQuery.ParamByName('TEL').AsString := AFornecedor.Telefone;
    LQuery.ParamByName('CEL').AsString := AFornecedor.Celular;
    LQuery.ParamByName('EMAIL').AsString := AFornecedor.Email;
    LQuery.ParamByName('CONTATO').AsString := AFornecedor.Contato;
    LQuery.ParamByName('OBS').AsString := AFornecedor.Observacoes;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(AFornecedor.Ativo);
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoFornecedor.Atualizar(const AFornecedor: TsigoModelFornecedor);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'UPDATE fornecedores SET razao_social = :RAZAO, telefone = :TEL, ' +
          'email = :EMAIL, ativo = :ATIVO WHERE id = :ID';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('RAZAO').AsString := AFornecedor.RazaoSocial;
    LQuery.ParamByName('TEL').AsString := AFornecedor.Telefone;
    LQuery.ParamByName('EMAIL').AsString := AFornecedor.Email;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(AFornecedor.Ativo);
    LQuery.ParamByName('ID').AsInteger := AFornecedor.ID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoRepoFornecedor.ListarTodos: TSQLQuery;
begin
  Result := Listar('ativo = 1 ORDER BY razao_social');
end;

end.
