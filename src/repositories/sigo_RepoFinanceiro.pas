unit sigo_RepoFinanceiro;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_BaseRepository, sigo_ModelFinanceiro, sigo_DBConnection;

type
  TsigoRepoFinanceiro = class
  private
    FDB: TsigoDBConnection;
  public
    constructor Create;
    procedure InserirCaixaMovimento(const AMovimento: TsigoModelCaixaMovimento);
    procedure InserirContaReceber(const AConta: TsigoModelContaReceber);
    procedure AtualizarContaReceber(const AConta: TsigoModelContaReceber);
    procedure ExcluirContaReceber(AID: Integer);
    procedure InserirContaPagar(const AConta: TsigoModelContaPagar);
    procedure AtualizarContaPagar(const AConta: TsigoModelContaPagar);
    procedure ExcluirContaPagar(AID: Integer);
    function ListarCaixaPorData(AData: TDate): TSQLQuery;
    function ListarContasReceberAbertas: TSQLQuery;
    function ListarContasPagarAbertas: TSQLQuery;
    function ObterResumoMes(AMes: Integer; AAno: Integer): TSQLQuery;
  end;

implementation

constructor TsigoRepoFinanceiro.Create;
begin
  inherited Create;
  FDB := TsigoDBConnection.Instancia;
end;

procedure TsigoRepoFinanceiro.InserirCaixaMovimento(const AMovimento: TsigoModelCaixaMovimento);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO caixa_movimentos (os_id, tipo, categoria, descricao, ' +
          'valor, data_movimento, forma_pagamento, usuario_id, observacoes) ' +
          'VALUES (:OS, :TIPO, :CAT, :DESC, :VALOR, :DATA, :FORMA, :USER, :OBS)';
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('OS').AsInteger := AMovimento.OSID;
    LQuery.ParamByName('TIPO').AsString := AMovimento.Tipo;
    LQuery.ParamByName('CAT').AsString := AMovimento.Categoria;
    LQuery.ParamByName('DESC').AsString := AMovimento.Descricao;
    LQuery.ParamByName('VALOR').AsFloat := AMovimento.Valor;
    LQuery.ParamByName('DATA').AsDateTime := AMovimento.DataMovimento;
    LQuery.ParamByName('FORMA').AsString := AMovimento.FormaPagamento;
    LQuery.ParamByName('USER').AsInteger := AMovimento.UsuarioID;
    LQuery.ParamByName('OBS').AsString := AMovimento.Observacoes;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoFinanceiro.InserirContaReceber(const AConta: TsigoModelContaReceber);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO contas_receber (os_id, cliente_id, descricao, valor, ' +
          'data_vencimento, status, forma_pagamento, observacoes, usuario_id) ' +
          'VALUES (:OS, :CLI, :DESC, :VALOR, :VENC, :STATUS, :FORMA, :OBS, :USER)';
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('OS').AsInteger := AConta.OSID;
    LQuery.ParamByName('CLI').AsInteger := AConta.ClienteID;
    LQuery.ParamByName('DESC').AsString := AConta.Descricao;
    LQuery.ParamByName('VALOR').AsFloat := AConta.Valor;
    LQuery.ParamByName('VENC').AsDate := AConta.DataVencimento;
    LQuery.ParamByName('STATUS').AsString := AConta.Status;
    LQuery.ParamByName('FORMA').AsString := AConta.FormaPagamento;
    LQuery.ParamByName('OBS').AsString := AConta.Observacoes;
    LQuery.ParamByName('USER').AsInteger := AConta.UsuarioID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoFinanceiro.InserirContaPagar(const AConta: TsigoModelContaPagar);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO contas_pagar (fornecedor_id, descricao, valor, ' +
          'data_vencimento, status, forma_pagamento, observacoes) ' +
          'VALUES (:FORN, :DESC, :VALOR, :VENC, :STATUS, :FORMA, :OBS)';
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('FORN').AsInteger := AConta.FornecedorID;
    LQuery.ParamByName('DESC').AsString := AConta.Descricao;
    LQuery.ParamByName('VALOR').AsFloat := AConta.Valor;
    LQuery.ParamByName('VENC').AsDate := AConta.DataVencimento;
    LQuery.ParamByName('STATUS').AsString := AConta.Status;
    LQuery.ParamByName('FORMA').AsString := AConta.FormaPagamento;
    LQuery.ParamByName('OBS').AsString := AConta.Observacoes;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoRepoFinanceiro.ListarCaixaPorData(AData: TDate): TSQLQuery;
var
  LSQL: string;
  LDataStr: string;
begin
  LDataStr := FormatDateTime('yyyy-mm-dd', AData);
  LSQL := 'SELECT * FROM caixa_movimentos WHERE DATE(data_movimento) = ''' +
          LDataStr + ''' ORDER BY data_movimento';
  Result := FDB.NovaQuery;
  Result.SQL.Text := LSQL;
  Result.Open;
end;

function TsigoRepoFinanceiro.ListarContasReceberAbertas: TSQLQuery;
var
  LSQL: string;
begin
  LSQL := 'SELECT * FROM contas_receber WHERE status IN (''ABERTA'', ''VENCIDA'', ' +
          '''PARCIAL'') ORDER BY data_vencimento';
  Result := FDB.NovaQuery;
  Result.SQL.Text := LSQL;
  Result.Open;
end;

function TsigoRepoFinanceiro.ListarContasPagarAbertas: TSQLQuery;
var
  LSQL: string;
begin
  LSQL := 'SELECT * FROM contas_pagar WHERE status IN (''ABERTA'', ''VENCIDA'', ' +
          '''PARCIAL'') ORDER BY data_vencimento';
  Result := FDB.NovaQuery;
  Result.SQL.Text := LSQL;
  Result.Open;
end;

function TsigoRepoFinanceiro.ObterResumoMes(AMes: Integer; AAno: Integer): TSQLQuery;
var
  LSQL: string;
  LMesStr: string;
begin
  LMesStr := FormatFloat('00', AMes);
  LSQL := 'SELECT tipo, SUM(valor) as total FROM caixa_movimentos ' +
          'WHERE SUBSTR(data_movimento, 1, 7) = ''' + IntToStr(AAno) + '-' +
          LMesStr + ''' GROUP BY tipo';
  Result := FDB.NovaQuery;
  Result.SQL.Text := LSQL;
  Result.Open;
end;

procedure TsigoRepoFinanceiro.AtualizarContaReceber(const AConta: TsigoModelContaReceber);
var
  LQuery: TSQLQuery;
begin
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text :=
      'UPDATE contas_receber SET os_id=:OS, cliente_id=:CLI, descricao=:DESC, ' +
      'valor=:VALOR, valor_pago=:VPAGO, data_emissao=:EMIS, data_vencimento=:VENC, ' +
      'data_pagamento=:PAG, status=:STATUS, forma_pagamento=:FORMA, observacoes=:OBS ' +
      'WHERE id=:ID';
    LQuery.ParamByName('ID').AsInteger := AConta.ID;
    LQuery.ParamByName('OS').AsInteger := AConta.OSID;
    LQuery.ParamByName('CLI').AsInteger := AConta.ClienteID;
    LQuery.ParamByName('DESC').AsString := AConta.Descricao;
    LQuery.ParamByName('VALOR').AsFloat := AConta.Valor;
    LQuery.ParamByName('VPAGO').AsFloat := AConta.ValorPago;
    LQuery.ParamByName('EMIS').AsDate := AConta.DataEmissao;
    LQuery.ParamByName('VENC').AsDate := AConta.DataVencimento;
    LQuery.ParamByName('PAG').AsDate := AConta.DataPagamento;
    LQuery.ParamByName('STATUS').AsString := AConta.Status;
    LQuery.ParamByName('FORMA').AsString := AConta.FormaPagamento;
    LQuery.ParamByName('OBS').AsString := AConta.Observacoes;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoFinanceiro.ExcluirContaReceber(AID: Integer);
var
  LQuery: TSQLQuery;
begin
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text := 'DELETE FROM contas_receber WHERE id = :ID';
    LQuery.ParamByName('ID').AsInteger := AID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoFinanceiro.AtualizarContaPagar(const AConta: TsigoModelContaPagar);
var
  LQuery: TSQLQuery;
begin
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text :=
      'UPDATE contas_pagar SET fornecedor_id=:FORN, descricao=:DESC, valor=:VALOR, ' +
      'valor_pago=:VPAGO, data_emissao=:EMIS, data_vencimento=:VENC, ' +
      'data_pagamento=:PAG, status=:STATUS, forma_pagamento=:FORMA, observacoes=:OBS ' +
      'WHERE id=:ID';
    LQuery.ParamByName('ID').AsInteger := AConta.ID;
    LQuery.ParamByName('FORN').AsInteger := AConta.FornecedorID;
    LQuery.ParamByName('DESC').AsString := AConta.Descricao;
    LQuery.ParamByName('VALOR').AsFloat := AConta.Valor;
    LQuery.ParamByName('VPAGO').AsFloat := AConta.ValorPago;
    LQuery.ParamByName('EMIS').AsDate := AConta.DataEmissao;
    LQuery.ParamByName('VENC').AsDate := AConta.DataVencimento;
    LQuery.ParamByName('PAG').AsDate := AConta.DataPagamento;
    LQuery.ParamByName('STATUS').AsString := AConta.Status;
    LQuery.ParamByName('FORMA').AsString := AConta.FormaPagamento;
    LQuery.ParamByName('OBS').AsString := AConta.Observacoes;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoFinanceiro.ExcluirContaPagar(AID: Integer);
var
  LQuery: TSQLQuery;
begin
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text := 'DELETE FROM contas_pagar WHERE id = :ID';
    LQuery.ParamByName('ID').AsInteger := AID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

end.
