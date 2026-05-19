unit sigo_RepoVeiculo;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_BaseRepository, sigo_ModelVeiculo;

type
  TsigoRepoVeiculo = class(TsigoBaseRepository)
  public
    constructor Create;
    function BuscarPorPlaca(const APlaca: string): TsigoModelVeiculo;
    procedure Salvar(const AVeiculo: TsigoModelVeiculo);
    procedure Atualizar(const AVeiculo: TsigoModelVeiculo);
    function ListarPorCliente(AClienteID: Integer): TSQLQuery;
    function ListarTodos: TSQLQuery;
  end;

implementation

constructor TsigoRepoVeiculo.Create;
begin
  inherited Create('veiculos');
end;

function TsigoRepoVeiculo.BuscarPorPlaca(const APlaca: string): TsigoModelVeiculo;
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  Result := nil;
  LSQL := 'SELECT * FROM veiculos WHERE placa = :PLACA';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('PLACA').AsString := APlaca;
    LQuery.Open;
    if not LQuery.EOF then
    begin
      Result := TsigoModelVeiculo.Create;
      Result.ID := LQuery.FieldByName('id').AsInteger;
      Result.Placa := LQuery.FieldByName('placa').AsString;
      Result.Marca := LQuery.FieldByName('marca').AsString;
      Result.Modelo := LQuery.FieldByName('modelo').AsString;
      Result.ClienteID := LQuery.FieldByName('cliente_id').AsInteger;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoVeiculo.Salvar(const AVeiculo: TsigoModelVeiculo);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT INTO veiculos (cliente_id, placa, marca, modelo, versao, ' +
          'ano_fabricacao, ano_modelo, cor, combustivel, renavam, chassi, km_atual, ' +
          'observacoes, ativo) VALUES (:CLI, :PLACA, :MARCA, :MODELO, :VERSAO, ' +
          ':ANOFAB, :ANOMOD, :COR, :COMB, :RENAVAM, :CHASSI, :KM, :OBS, :ATIVO)';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('CLI').AsInteger := AVeiculo.ClienteID;
    LQuery.ParamByName('PLACA').AsString := AVeiculo.Placa;
    LQuery.ParamByName('MARCA').AsString := AVeiculo.Marca;
    LQuery.ParamByName('MODELO').AsString := AVeiculo.Modelo;
    LQuery.ParamByName('VERSAO').AsString := AVeiculo.Versao;
    LQuery.ParamByName('ANOFAB').AsInteger := AVeiculo.AnoFabricacao;
    LQuery.ParamByName('ANOMOD').AsInteger := AVeiculo.AnoModelo;
    LQuery.ParamByName('COR').AsString := AVeiculo.Cor;
    LQuery.ParamByName('COMB').AsString := AVeiculo.Combustivel;
    LQuery.ParamByName('RENAVAM').AsString := AVeiculo.Renavam;
    LQuery.ParamByName('CHASSI').AsString := AVeiculo.Chassi;
    LQuery.ParamByName('KM').AsInteger := AVeiculo.KmAtual;
    LQuery.ParamByName('OBS').AsString := AVeiculo.Observacoes;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(AVeiculo.Ativo);
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoRepoVeiculo.Atualizar(const AVeiculo: TsigoModelVeiculo);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'UPDATE veiculos SET km_atual = :KM, cor = :COR, ativo = :ATIVO WHERE id = :ID';
  LQuery := NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('KM').AsInteger := AVeiculo.KmAtual;
    LQuery.ParamByName('COR').AsString := AVeiculo.Cor;
    LQuery.ParamByName('ATIVO').AsInteger := Integer(AVeiculo.Ativo);
    LQuery.ParamByName('ID').AsInteger := AVeiculo.ID;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoRepoVeiculo.ListarPorCliente(AClienteID: Integer): TSQLQuery;
var
  LSQL: string;
begin
  LSQL := 'SELECT * FROM veiculos WHERE cliente_id = ' + IntToStr(AClienteID) +
          ' AND ativo = 1 ORDER BY placa';
  Result := ExecutarQuery(LSQL);
end;

function TsigoRepoVeiculo.ListarTodos: TSQLQuery;
begin
  Result := Listar('ativo = 1 ORDER BY placa');
end;

end.
