unit sigo_CtrlCliente;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelCliente, sigo_RepoCliente;

type
  TsigoCtrlCliente = class
  private
    FRepo: TsigoRepoCliente;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Salvar(const ACliente: TsigoModelCliente);
    procedure Atualizar(const ACliente: TsigoModelCliente);
    procedure Excluir(AClienteID: Integer);
    function BuscarPorCPFCNPJ(const ACpfCnpj: string): TsigoModelCliente;
  end;

implementation

constructor TsigoCtrlCliente.Create;
begin
  inherited Create;
  FRepo := TsigoRepoCliente.Create;
end;

destructor TsigoCtrlCliente.Destroy;
begin
  FreeAndNil(FRepo);
  inherited Destroy;
end;

procedure TsigoCtrlCliente.Salvar(const ACliente: TsigoModelCliente);
begin
  if ACliente.Nome = '' then
    raise Exception.Create('Nome do cliente é obrigatório');
  FRepo.Salvar(ACliente);
end;

procedure TsigoCtrlCliente.Atualizar(const ACliente: TsigoModelCliente);
begin
  if ACliente.ID <= 0 then
    raise Exception.Create('Cliente inválido');
  FRepo.Atualizar(ACliente);
end;

procedure TsigoCtrlCliente.Excluir(AClienteID: Integer);
begin
  if AClienteID <= 0 then Exit;
  FRepo.Excluir(AClienteID);
end;

function TsigoCtrlCliente.BuscarPorCPFCNPJ(const ACpfCnpj: string): TsigoModelCliente;
begin
  Result := FRepo.BuscarPorCPFCNPJ(ACpfCnpj);
end;

end.
