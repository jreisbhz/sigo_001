unit sigo_CtrlPeca;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelPeca, sigo_RepoPeca, sigo_Utils;

type
  TsigoCtrlPeca = class
  private
    FRepo: TsigoRepoPeca;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Salvar(const APeca: TsigoModelPeca);
    procedure Atualizar(const APeca: TsigoModelPeca);
    procedure Excluir(APecaID: Integer);
    function BuscarPorCodigo(const ACodigo: string): TsigoModelPeca;
    procedure CalcularPrecos(var APeca: TsigoModelPeca);
  end;

implementation

constructor TsigoCtrlPeca.Create;
begin
  inherited Create;
  FRepo := TsigoRepoPeca.Create;
end;

destructor TsigoCtrlPeca.Destroy;
begin
  FreeAndNil(FRepo);
  inherited Destroy;
end;

procedure TsigoCtrlPeca.Salvar(const APeca: TsigoModelPeca);
var
  LPeca: TsigoModelPeca;
begin
  if APeca.Descricao = '' then
    raise Exception.Create('Descrição da peça é obrigatória');
  if APeca.Codigo = '' then
    raise Exception.Create('Código da peça é obrigatório');
  LPeca := APeca;
  CalcularPrecos(LPeca);
  FRepo.Salvar(LPeca);
end;

procedure TsigoCtrlPeca.Atualizar(const APeca: TsigoModelPeca);
var
  LPeca: TsigoModelPeca;
begin
  if APeca.ID <= 0 then
    raise Exception.Create('Peça inválida');
  LPeca := APeca;
  CalcularPrecos(LPeca);
  FRepo.Atualizar(LPeca);
end;

procedure TsigoCtrlPeca.Excluir(APecaID: Integer);
begin
  if APecaID <= 0 then Exit;
  FRepo.Excluir(APecaID);
end;

function TsigoCtrlPeca.BuscarPorCodigo(const ACodigo: string): TsigoModelPeca;
begin
  Result := FRepo.BuscarPorCodigo(ACodigo);
end;

procedure TsigoCtrlPeca.CalcularPrecos(var APeca: TsigoModelPeca);
begin
  APeca.PrecoVista := APeca.PrecoCusto + APeca.MargemVista;
  APeca.PrecoPrazo := APeca.PrecoCusto + APeca.MargemPrazo;
  APeca.PrecoAtacado := APeca.PrecoCusto + APeca.MargemAtacado;
end;

end.
