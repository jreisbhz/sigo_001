unit sigo_CtrlColaborador;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelColaborador, sigo_RepoColaborador;

type
  TsigoCtrlColaborador = class
  private
    FRepo: TsigoRepoColaborador;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Salvar(const AColaborador: TsigoModelColaborador);
    procedure Atualizar(const AColaborador: TsigoModelColaborador);
    procedure Excluir(AColaboradorID: Integer);
  end;

implementation

constructor TsigoCtrlColaborador.Create;
begin
  inherited Create;
  FRepo := TsigoRepoColaborador.Create;
end;

destructor TsigoCtrlColaborador.Destroy;
begin
  FreeAndNil(FRepo);
  inherited Destroy;
end;

procedure TsigoCtrlColaborador.Salvar(const AColaborador: TsigoModelColaborador);
begin
  if AColaborador.Nome = '' then
    raise Exception.Create('Nome do colaborador é obrigatório');
  FRepo.Salvar(AColaborador);
end;

procedure TsigoCtrlColaborador.Atualizar(const AColaborador: TsigoModelColaborador);
begin
  if AColaborador.ID <= 0 then
    raise Exception.Create('Colaborador inválido');
  FRepo.Atualizar(AColaborador);
end;

procedure TsigoCtrlColaborador.Excluir(AColaboradorID: Integer);
begin
  if AColaboradorID <= 0 then Exit;
  FRepo.Excluir(AColaboradorID);
end;

end.
