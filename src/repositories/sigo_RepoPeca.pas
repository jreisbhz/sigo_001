unit sigo_RepoPeca;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_BaseRepository, sigo_ModelPeca;

type
  TsigoRepoPeca = class(TsigoBaseRepository)
  public
    constructor Create;
    function BuscarPorCodigo(const ACodigo: string): TsigoModelPeca;
    procedure Salvar(const APeca: TsigoModelPeca);
    procedure Atualizar(const APeca: TsigoModelPeca);
    function ListarTodos: TSQLQuery;
    function ListarCriticas: TSQLQuery;
  end;

implementation

constructor TsigoRepoPeca.Create;
begin
  inherited Create('pecas');
end;

function TsigoRepoPeca.BuscarPorCodigo(const ACodigo: string): TsigoModelPeca;
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  Result := nil;
  LSQL := 'SELECT * FROM pecas WHERE codigo = :CODIGO';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('CODIGO').AsString := ACodigo;
    LQuery.Open;
    if not LQuery.EOF then
    begin
      Result := TsigoModelPeca.Create;
      Result.ID := LQuery.FieldByName('id').AsInteger;
      Result.Codigo := LQuery.FieldByName('codigo').AsString;
      Result.Descricao := LQuery.FieldByName('descricao').AsString;
      Result.EstoqueAtual := LQuery.FieldByName('estoque_atual').AsFloat;
      Result.PrecoVista := LQuery.FieldByName('preco_vista').AsFloat;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoPeca.Salvar(const APeca: TsigoModelPeca);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO pecas (categoria_id, fornecedor_id, codigo, codigo_fabricante, ' +
          'codigo_barras, descricao, unidade, localizacao, marca, estoque_atual, ' +
          'estoque_minimo, estoque_maximo, preco_custo, margem_vista, margem_prazo, ' +
          'margem_atacado, preco_vista, preco_prazo, preco_atacado, observacoes, ativo) ' +
          'VALUES (:CAT, :FORN, :COD, :CODFAB, :BARRAS, :DESC, :UNI, :LOC, :MARCA, ' +
          ':EST, :ESTMIN, :ESTMAX, :CUSTO, :MV, :MP, :MA, :PV, :PP, :PA, :OBS, :ATIVO)';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('CAT').AsInteger := APeca.CategoriaID;
    LQuery.ParamByName('FORN').AsInteger := APeca.FornecedorID;
    LQuery.ParamByName('COD').AsString := APeca.Codigo;
    LQuery.ParamByName('CODFAB').AsString := APeca.CodigoFabricante;
    LQuery.ParamByName('BARRAS').AsString := APeca.CodigoBarras;
    LQuery.ParamByName('DESC').AsString := APeca.Descricao;
    LQuery.ParamByName('UNI').AsString := APeca.Unidade;
    LQuery.ParamByName('LOC').AsString := APeca.Localizacao;
    LQuery.ParamByName('MARCA').AsString := APeca.Marca;
    LQuery.ParamByName('EST').AsFloat := APeca.EstoqueAtual;
    LQuery.ParamByName('ESTMIN').AsFloat := APeca.EstoqueMinimo;
    LQuery.ParamByName('ESTMAX').AsFloat := APeca.EstoqueMaximo;
    LQuery.ParamByName('CUSTO').AsFloat := APeca.PrecoCusto;
    LQuery.ParamByName('MV').AsFloat := APeca.MargemVista;
    LQuery.ParamByName('MP').AsFloat := APeca.MargemPrazo;
    LQuery.ParamByName('MA').AsFloat := APeca.MargemAtacado;
    LQuery.ParamByName('PV').AsFloat := APeca.PrecoVista;
    LQuery.ParamByName('PP').AsFloat := APeca.PrecoPrazo;
    LQuery.ParamByName('PA').AsFloat := APeca.PrecoAtacado;
    LQuery.ParamByName('OBS').AsString := APeca.Observacoes;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(APeca.Ativo);
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoPeca.Atualizar(const APeca: TsigoModelPeca);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'UPDATE pecas SET descricao = :DESC, estoque_atual = :EST, ' +
          'preco_custo = :CUSTO, preco_vista = :PV, ativo = :ATIVO WHERE id = :ID';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('DESC').AsString := APeca.Descricao;
    LQuery.ParamByName('EST').AsFloat := APeca.EstoqueAtual;
    LQuery.ParamByName('CUSTO').AsFloat := APeca.PrecoCusto;
    LQuery.ParamByName('PV').AsFloat := APeca.PrecoVista;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(APeca.Ativo);
    LQuery.ParamByName('ID').AsInteger := APeca.ID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoRepoPeca.ListarTodos: TSQLQuery;
begin
  Result := Listar('ativo = 1 ORDER BY descricao');
end;

function TsigoRepoPeca.ListarCriticas: TSQLQuery;
begin
  Result := ExecutarQuery(
    'SELECT * FROM pecas WHERE ativo = 1 AND estoque_atual <= estoque_minimo ' +
    'ORDER BY estoque_atual ASC'
  );
end;

end.
