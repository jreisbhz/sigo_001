unit sigo_CtrlFornecedor;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelFornecedor, sigo_RepoFornecedor;

type
  TsigoCtrlFornecedor = class
  private
    FRepo: TsigoRepoFornecedor;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Salvar(const AFornecedor: TsigoModelFornecedor);
    procedure Atualizar(const AFornecedor: TsigoModelFornecedor);
    procedure Excluir(AFornecedorID: Integer);
  end;

implementation

constructor TsigoCtrlFornecedor.Create;
begin
  inherited Create;
  FRepo := TsigoRepoFornecedor.Create;
end;

destructor TsigoCtrlFornecedor.Destroy;
begin
  FreeAndNil(FRepo);
  inherited Destroy;
end;

procedure TsigoCtrlFornecedor.Salvar(const AFornecedor: TsigoModelFornecedor);
begin
  if AFornecedor.RazaoSocial = '' then
    raise Exception.Create('Razão social é obrigatória');
  FRepo.Salvar(AFornecedor);
end;

procedure TsigoCtrlFornecedor.Atualizar(const AFornecedor: TsigoModelFornecedor);
begin
  if AFornecedor.ID <= 0 then
    raise Exception.Create('Fornecedor inválido');
  FRepo.Atualizar(AFornecedor);
end;

procedure TsigoCtrlFornecedor.Excluir(AFornecedorID: Integer);
begin
  if AFornecedorID <= 0 then Exit;
  FRepo.Excluir(AFornecedorID);
end;

end.
