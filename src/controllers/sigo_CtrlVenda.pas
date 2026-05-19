unit sigo_CtrlVenda;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelVenda, sigo_RepoVenda;

type
  TsigoCtrlVenda = class
  private
    FRepo: TsigoRepoVenda;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Salvar(const AVenda: TsigoModelVenda);
    procedure Atualizar(const AVenda: TsigoModelVenda);
    procedure Excluir(AVendaID: Integer);
    procedure CalcularTotal(var AVenda: TsigoModelVenda);
  end;

implementation

constructor TsigoCtrlVenda.Create;
begin
  inherited Create;
  FRepo := TsigoRepoVenda.Create;
end;

destructor TsigoCtrlVenda.Destroy;
begin
  FreeAndNil(FRepo);
  inherited Destroy;
end;

procedure TsigoCtrlVenda.Salvar(const AVenda: TsigoModelVenda);
var
  LVenda: TsigoModelVenda;
begin
  if AVenda.NumeroComanda = '' then
    raise Exception.Create('Número da comanda é obrigatório');
  LVenda := AVenda;
  CalcularTotal(LVenda);
  FRepo.Salvar(LVenda);
end;

procedure TsigoCtrlVenda.Atualizar(const AVenda: TsigoModelVenda);
var
  LVenda: TsigoModelVenda;
begin
  if AVenda.ID <= 0 then
    raise Exception.Create('Venda inválida');
  LVenda := AVenda;
  CalcularTotal(LVenda);
  FRepo.Atualizar(LVenda);
end;

procedure TsigoCtrlVenda.Excluir(AVendaID: Integer);
begin
  if AVendaID <= 0 then Exit;
  FRepo.Excluir(AVendaID);
end;

procedure TsigoCtrlVenda.CalcularTotal(var AVenda: TsigoModelVenda);
var
  i: Integer;
  LTotal: Double;
begin
  LTotal := 0;
  for i := 0 to AVenda.Itens.Count - 1 do
    LTotal := LTotal + TVendaItem(AVenda.Itens[i]).Total;
  AVenda.Total := LTotal - AVenda.Desconto;
end;

end.
