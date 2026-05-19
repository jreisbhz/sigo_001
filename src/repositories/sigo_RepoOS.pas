unit sigo_RepoOS;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_BaseRepository, sigo_ModelOS;

type
  TsigoRepoOS = class(TsigoBaseRepository)
  public
    constructor Create;
    function BuscarPorNumero(const ANumero: string): TsigoModelOS;
    procedure Salvar(const AOS: TsigoModelOS);
    procedure Atualizar(const AOS: TsigoModelOS);
    function ListarTodas: TSQLQuery;
    function ListarPorStatus(const AStatus: string): TSQLQuery;
    function ListarAbertas: TSQLQuery;
  end;

implementation

constructor TsigoRepoOS.Create;
begin
  inherited Create('ordens_servico');
end;

function TsigoRepoOS.BuscarPorNumero(const ANumero: string): TsigoModelOS;
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  Result := nil;
  LSQL := 'SELECT * FROM ordens_servico WHERE numero = :NUMERO';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('NUMERO').AsString := ANumero;
    LQuery.Open;
    if not LQuery.EOF then
    begin
      Result := TsigoModelOS.Create;
      Result.ID := LQuery.FieldByName('id').AsInteger;
      Result.Numero := LQuery.FieldByName('numero').AsString;
      Result.Status := LQuery.FieldByName('status').AsString;
      Result.ClienteID := LQuery.FieldByName('cliente_id').AsInteger;
      Result.TotalGeral := LQuery.FieldByName('total_geral').AsFloat;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoOS.Salvar(const AOS: TsigoModelOS);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO ordens_servico (numero, cliente_id, veiculo_id, colaborador_id, ' +
          'status, box_prisma, data_abertura, km_entrada, defeito_relatado, ativo) ' +
          'VALUES (:NUM, :CLI, :VEI, :COL, :STATUS, :BOX, :DATA, :KM, :DEF, 1)';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('NUM').AsString := AOS.Numero;
    LQuery.ParamByName('CLI').AsInteger := AOS.ClienteID;
    LQuery.ParamByName('VEI').AsInteger := AOS.VeiculoID;
    LQuery.ParamByName('COL').AsInteger := AOS.ColaboradorID;
    LQuery.ParamByName('STATUS').AsString := AOS.Status;
    LQuery.ParamByName('BOX').AsString := AOS.BoxPrisma;
    LQuery.ParamByName('DATA').AsDateTime := AOS.DataAbertura;
    LQuery.ParamByName('KM').AsInteger := AOS.KmEntrada;
    LQuery.ParamByName('DEF').AsString := AOS.DefeitoRelatado;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoOS.Atualizar(const AOS: TsigoModelOS);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'UPDATE ordens_servico SET status = :STATUS, km_saida = :KM, ' +
          'desconto = :DESC, total_geral = :TOTAL, valor_pago = :PAGO ' +
          'WHERE id = :ID';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('STATUS').AsString := AOS.Status;
    LQuery.ParamByName('KM').AsInteger := AOS.KmSaida;
    LQuery.ParamByName('DESC').AsFloat := AOS.Desconto;
    LQuery.ParamByName('TOTAL').AsFloat := AOS.TotalGeral;
    LQuery.ParamByName('PAGO').AsFloat := AOS.ValorPago;
    LQuery.ParamByName('ID').AsInteger := AOS.ID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoRepoOS.ListarTodas: TSQLQuery;
begin
  Result := ExecutarQuery('SELECT * FROM vw_os_completa ORDER BY data_abertura DESC');
end;

function TsigoRepoOS.ListarPorStatus(const AStatus: string): TSQLQuery;
begin
  Result := ExecutarQuery(
    'SELECT * FROM vw_os_completa WHERE status = ''' + AStatus + ''' ' +
    'ORDER BY data_abertura DESC'
  );
end;

function TsigoRepoOS.ListarAbertas: TSQLQuery;
begin
  Result := ExecutarQuery(
    'SELECT * FROM vw_os_completa WHERE status IN (''ABERTA'', ''EM_ANDAMENTO'') ' +
    'ORDER BY data_abertura DESC'
  );
end;

end.
