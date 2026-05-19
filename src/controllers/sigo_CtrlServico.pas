unit sigo_CtrlServico;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelServico, sigo_RepoServico;

type
  TsigoCtrlServico = class
  private
    FRepo: TsigoRepoServico;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Salvar(const AServico: TsigoModelServico);
    procedure Atualizar(const AServico: TsigoModelServico);
    procedure Excluir(AServicoID: Integer);
    function BuscarPorCodigo(const ACodigo: string): TsigoModelServico;
  end;

implementation

constructor TsigoCtrlServico.Create;
begin
  inherited Create;
  FRepo := TsigoRepoServico.Create;
end;

destructor TsigoCtrlServico.Destroy;
begin
  FreeAndNil(FRepo);
  inherited Destroy;
end;

procedure TsigoCtrlServico.Salvar(const AServico: TsigoModelServico);
begin
  if AServico.Nome = '' then
    raise Exception.Create('Nome do serviço é obrigatório');
  FRepo.Salvar(AServico);
end;

procedure TsigoCtrlServico.Atualizar(const AServico: TsigoModelServico);
begin
  if AServico.ID <= 0 then
    raise Exception.Create('Serviço inválido');
  FRepo.Atualizar(AServico);
end;

procedure TsigoCtrlServico.Excluir(AServicoID: Integer);
begin
  if AServicoID <= 0 then Exit;
  FRepo.Excluir(AServicoID);
end;

function TsigoCtrlServico.BuscarPorCodigo(const ACodigo: string): TsigoModelServico;
begin
  Result := FRepo.BuscarPorCodigo(ACodigo);
end;

end.
