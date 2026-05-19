unit sigo_CtrlOS;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelOS, sigo_RepoOS, sigo_Utils;

type
  TsigoCtrlOS = class
  private
    FRepo: TsigoRepoOS;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Salvar(const AOS: TsigoModelOS);
    procedure Atualizar(const AOS: TsigoModelOS);
    procedure Excluir(AOSID: Integer);
    function BuscarPorNumero(const ANumero: string): TsigoModelOS;
    function GerarNumeroOS: string;
    procedure CalcularTotais(var AOS: TsigoModelOS);
  end;

implementation

constructor TsigoCtrlOS.Create;
begin
  inherited Create;
  FRepo := TsigoRepoOS.Create;
end;

destructor TsigoCtrlOS.Destroy;
begin
  FreeAndNil(FRepo);
  inherited Destroy;
end;

procedure TsigoCtrlOS.Salvar(const AOS: TsigoModelOS);
var
  LOS: TsigoModelOS;
begin
  if AOS.ClienteID <= 0 then
    raise Exception.Create('Cliente é obrigatório');
  if AOS.VeiculoID <= 0 then
    raise Exception.Create('Veículo é obrigatório');
  LOS := AOS;
  LOS.Numero := GerarNumeroOS;
  LOS.Status := 'ABERTA';
  CalcularTotais(LOS);
  FRepo.Salvar(LOS);
end;

procedure TsigoCtrlOS.Atualizar(const AOS: TsigoModelOS);
var
  LOS: TsigoModelOS;
begin
  if AOS.ID <= 0 then
    raise Exception.Create('OS inválida');
  LOS := AOS;
  CalcularTotais(LOS);
  FRepo.Atualizar(LOS);
end;

procedure TsigoCtrlOS.Excluir(AOSID: Integer);
begin
  if AOSID <= 0 then Exit;
  FRepo.Excluir(AOSID);
end;

function TsigoCtrlOS.BuscarPorNumero(const ANumero: string): TsigoModelOS;
begin
  Result := FRepo.BuscarPorNumero(ANumero);
end;

function TsigoCtrlOS.GerarNumeroOS: string;
begin
  Result := GerarNumeroOS;
end;

procedure TsigoCtrlOS.CalcularTotais(var AOS: TsigoModelOS);
begin
  AOS.TotalGeral := AOS.TotalPecas + AOS.TotalServicos - AOS.Desconto;
end;

end.
