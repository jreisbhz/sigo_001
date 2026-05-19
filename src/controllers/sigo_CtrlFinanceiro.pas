unit sigo_CtrlFinanceiro;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_ModelFinanceiro, sigo_RepoFinanceiro;

type
  TsigoCtrlFinanceiro = class
  private
    FRepo: TsigoRepoFinanceiro;
  public
    constructor Create;
    destructor Destroy; override;
    procedure InserirCaixaMovimento(const AMovimento: TsigoModelCaixaMovimento);
    procedure InserirContaReceber(const AConta: TsigoModelContaReceber);
    procedure SalvarContaReceber(const AConta: TsigoModelContaReceber);
    procedure AtualizarContaReceber(const AConta: TsigoModelContaReceber);
    procedure ExcluirContaReceber(AID: Integer);
    procedure InserirContaPagar(const AConta: TsigoModelContaPagar);
    procedure SalvarContaPagar(const AConta: TsigoModelContaPagar);
    procedure AtualizarContaPagar(const AConta: TsigoModelContaPagar);
    procedure ExcluirContaPagar(AID: Integer);
    function CalcularSaldoDia(AData: TDate): Double;
  end;

implementation

constructor TsigoCtrlFinanceiro.Create;
begin
  inherited Create;
  FRepo := TsigoRepoFinanceiro.Create;
end;

destructor TsigoCtrlFinanceiro.Destroy;
begin
  FreeAndNil(FRepo);
  inherited Destroy;
end;

procedure TsigoCtrlFinanceiro.InserirCaixaMovimento(const AMovimento: TsigoModelCaixaMovimento);
begin
  if AMovimento.Valor <= 0 then
    raise Exception.Create('Valor deve ser maior que zero');
  FRepo.InserirCaixaMovimento(AMovimento);
end;

procedure TsigoCtrlFinanceiro.InserirContaReceber(const AConta: TsigoModelContaReceber);
begin
  if AConta.ClienteID <= 0 then
    raise Exception.Create('Cliente é obrigatório');
  FRepo.InserirContaReceber(AConta);
end;

procedure TsigoCtrlFinanceiro.SalvarContaReceber(const AConta: TsigoModelContaReceber);
begin
  if AConta.ClienteID <= 0 then
    raise Exception.Create('Cliente é obrigatório');
  FRepo.InserirContaReceber(AConta);
end;

procedure TsigoCtrlFinanceiro.AtualizarContaReceber(const AConta: TsigoModelContaReceber);
begin
  if AConta.ID <= 0 then
    raise Exception.Create('Conta a receber inválida');
  FRepo.AtualizarContaReceber(AConta);
end;

procedure TsigoCtrlFinanceiro.ExcluirContaReceber(AID: Integer);
begin
  if AID <= 0 then Exit;
  FRepo.ExcluirContaReceber(AID);
end;

procedure TsigoCtrlFinanceiro.InserirContaPagar(const AConta: TsigoModelContaPagar);
begin
  if AConta.Valor <= 0 then
    raise Exception.Create('Valor deve ser maior que zero');
  FRepo.InserirContaPagar(AConta);
end;

procedure TsigoCtrlFinanceiro.SalvarContaPagar(const AConta: TsigoModelContaPagar);
begin
  if AConta.Valor <= 0 then
    raise Exception.Create('Valor deve ser maior que zero');
  FRepo.InserirContaPagar(AConta);
end;

procedure TsigoCtrlFinanceiro.AtualizarContaPagar(const AConta: TsigoModelContaPagar);
begin
  if AConta.ID <= 0 then
    raise Exception.Create('Conta a pagar inválida');
  FRepo.AtualizarContaPagar(AConta);
end;

procedure TsigoCtrlFinanceiro.ExcluirContaPagar(AID: Integer);
begin
  if AID <= 0 then Exit;
  FRepo.ExcluirContaPagar(AID);
end;

function TsigoCtrlFinanceiro.CalcularSaldoDia(AData: TDate): Double;
var
  LQuery: TSQLQuery;
  LEntrada, LSaida: Double;
begin
  LEntrada := 0;
  LSaida := 0;
  LQuery := FRepo.ListarCaixaPorData(AData);
  try
    while not LQuery.EOF do
    begin
      if LQuery.FieldByName('tipo').AsString = 'ENTRADA' then
        LEntrada := LEntrada + LQuery.FieldByName('valor').AsFloat
      else
        LSaida := LSaida + LQuery.FieldByName('valor').AsFloat;
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
  Result := LEntrada - LSaida;
end;

end.
