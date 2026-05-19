unit sigo_RepoVenda;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_BaseRepository, sigo_ModelVenda;

type
  TsigoRepoVenda = class(TsigoBaseRepository)
  public
    constructor Create;
    procedure Salvar(const AVenda: TsigoModelVenda);
    procedure Atualizar(const AVenda: TsigoModelVenda);
    function ListarTodas: TSQLQuery;
    function ListarAbertas: TSQLQuery;
  end;

implementation

constructor TsigoRepoVenda.Create;
begin
  inherited Create('vendas');
end;

procedure TsigoRepoVenda.Salvar(const AVenda: TsigoModelVenda);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO vendas (numero_comanda, data_venda, cliente_id, atendente_id, ' +
          'desconto, total, status, forma_pagamento, observacoes) ' +
          'VALUES (:NUM, :DATA, :CLI, :ATEND, :DESC, :TOTAL, :STATUS, :FORMA, :OBS)';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('NUM').AsString := AVenda.NumeroComanda;
    LQuery.ParamByName('DATA').AsDateTime := AVenda.DataVenda;
    LQuery.ParamByName('CLI').AsInteger := AVenda.ClienteID;
    LQuery.ParamByName('ATEND').AsInteger := AVenda.AtendenteID;
    LQuery.ParamByName('DESC').AsFloat := AVenda.Desconto;
    LQuery.ParamByName('TOTAL').AsFloat := AVenda.Total;
    LQuery.ParamByName('STATUS').AsString := AVenda.Status;
    LQuery.ParamByName('FORMA').AsString := AVenda.FormaPagamento;
    LQuery.ParamByName('OBS').AsString := AVenda.Observacoes;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoVenda.Atualizar(const AVenda: TsigoModelVenda);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'UPDATE vendas SET status = :STATUS, data_entrega = :ENTREGA, ' +
          'total = :TOTAL WHERE id = :ID';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('STATUS').AsString := AVenda.Status;
    LQuery.ParamByName('ENTREGA').AsDate := AVenda.DataEntrega;
    LQuery.ParamByName('TOTAL').AsFloat := AVenda.Total;
    LQuery.ParamByName('ID').AsInteger := AVenda.ID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoRepoVenda.ListarTodas: TSQLQuery;
begin
  Result := Listar('ORDER BY data_venda DESC');
end;

function TsigoRepoVenda.ListarAbertas: TSQLQuery;
begin
  Result := Listar('status = ''ABERTA'' ORDER BY data_venda DESC');
end;

end.
