unit sigo_CtrlVeiculo;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, sqldb, sigo_ModelVeiculo, sigo_RepoVeiculo, sigo_DBConnection;

type
  TsigoCtrlVeiculo = class
  private
    FRepo: TsigoRepoVeiculo;
    FDB: TsigoDBConnection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Salvar(const AVeiculo: TsigoModelVeiculo);
    procedure Atualizar(const AVeiculo: TsigoModelVeiculo);
    procedure Excluir(AVeiculoID: Integer);
    function BuscarPorPlaca(const APlaca: string): TsigoModelVeiculo;
    procedure CarregarMarcas(AMarcas: TStrings);
    procedure CarregarModelos(AMarcaID: Integer; AModelos: TStrings);
    procedure CarregarAnos(AModeloID: Integer; AAnos: TStrings);
  end;

implementation

constructor TsigoCtrlVeiculo.Create;
begin
  inherited Create;
  FRepo := TsigoRepoVeiculo.Create;
  FDB := TsigoDBConnection.Instancia;
end;

destructor TsigoCtrlVeiculo.Destroy;
begin
  FreeAndNil(FRepo);
  inherited Destroy;
end;

procedure TsigoCtrlVeiculo.Salvar(const AVeiculo: TsigoModelVeiculo);
begin
  if AVeiculo.Placa = '' then
    raise Exception.Create('Placa do veículo é obrigatória');
  FRepo.Salvar(AVeiculo);
end;

procedure TsigoCtrlVeiculo.Atualizar(const AVeiculo: TsigoModelVeiculo);
begin
  if AVeiculo.ID <= 0 then
    raise Exception.Create('Veículo inválido');
  FRepo.Atualizar(AVeiculo);
end;

procedure TsigoCtrlVeiculo.Excluir(AVeiculoID: Integer);
begin
  if AVeiculoID <= 0 then Exit;
  FRepo.Excluir(AVeiculoID);
end;

function TsigoCtrlVeiculo.BuscarPorPlaca(const APlaca: string): TsigoModelVeiculo;
begin
  Result := FRepo.BuscarPorPlaca(APlaca);
end;

procedure TsigoCtrlVeiculo.CarregarMarcas(AMarcas: TStrings);
var
  LQuery: TSQLQuery;
begin
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text := 'SELECT id, nome FROM fipe_marcas ORDER BY nome';
    LQuery.Open;
    AMarcas.Clear;
    while not LQuery.EOF do
    begin
      AMarcas.AddObject(LQuery.FieldByName('nome').AsString,
        TObject(Pointer(LQuery.FieldByName('id').AsInteger)));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoCtrlVeiculo.CarregarModelos(AMarcaID: Integer; AModelos: TStrings);
var
  LQuery: TSQLQuery;
begin
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text := 'SELECT id, nome FROM fipe_modelos WHERE marca_id = :MARCA ORDER BY nome';
    LQuery.ParamByName('MARCA').AsInteger := AMarcaID;
    LQuery.Open;
    AModelos.Clear;
    while not LQuery.EOF do
    begin
      AModelos.AddObject(LQuery.FieldByName('nome').AsString,
        TObject(Pointer(LQuery.FieldByName('id').AsInteger)));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TsigoCtrlVeiculo.CarregarAnos(AModeloID: Integer; AAnos: TStrings);
var
  LQuery: TSQLQuery;
begin
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text := 'SELECT id, nome FROM fipe_anos WHERE modelo_id = :MODELO ORDER BY nome';
    LQuery.ParamByName('MODELO').AsInteger := AModeloID;
    LQuery.Open;
    AAnos.Clear;
    while not LQuery.EOF do
    begin
      AAnos.AddObject(LQuery.FieldByName('nome').AsString,
        TObject(Pointer(LQuery.FieldByName('id').AsInteger)));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

end.
