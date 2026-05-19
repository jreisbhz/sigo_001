unit sigo_ModelOS;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelBase, Classes;

type
  TsigoOSItemPeca = class
  public
    ID: Integer;
    PecaID: Integer;
    Descricao: string;
    Quantidade: Double;
    ValorUnitario: Double;
    ValorCusto: Double;
    Desconto: Double;
    Total: Double;
    constructor Create;
  end;

  TsigoOSItemServico = class
  public
    ID: Integer;
    ServicoID: Integer;
    ColaboradorID: Integer;
    Descricao: string;
    Quantidade: Double;
    ValorUnitario: Double;
    Desconto: Double;
    Total: Double;
    constructor Create;
  end;

  TsigoModelOS = class(TsigoModelBase)
  private
    FNumero: string;
    FClienteID: Integer;
    FVeiculoID: Integer;
    FColaboradorID: Integer;
    FStatus: string;
    FBoxPrisma: string;
    FDataAbertura: TDateTime;
    FDataPrevisao: TDate;
    FDataConclusao: TDate;
    FDataEntrega: TDate;
    FKmEntrada: Integer;
    FKmSaida: Integer;
    FDefeitoRelatado: string;
    FServicoExecutado: string;
    FObservacoes: string;
    FDesconto: Double;
    FTotalPecas: Double;
    FTotalServicos: Double;
    FTotalGeral: Double;
    FFormaPagamento: string;
    FValorPago: Double;
    FItens: TList;
    FServicos: TList;
  public
    constructor Create;
    destructor Destroy; override;
    property Numero: string read FNumero write FNumero;
    property ClienteID: Integer read FClienteID write FClienteID;
    property VeiculoID: Integer read FVeiculoID write FVeiculoID;
    property ColaboradorID: Integer read FColaboradorID write FColaboradorID;
    property Status: string read FStatus write FStatus;
    property BoxPrisma: string read FBoxPrisma write FBoxPrisma;
    property DataAbertura: TDateTime read FDataAbertura write FDataAbertura;
    property DataPrevisao: TDate read FDataPrevisao write FDataPrevisao;
    property DataConclusao: TDate read FDataConclusao write FDataConclusao;
    property DataEntrega: TDate read FDataEntrega write FDataEntrega;
    property KmEntrada: Integer read FKmEntrada write FKmEntrada;
    property KmSaida: Integer read FKmSaida write FKmSaida;
    property DefeitoRelatado: string read FDefeitoRelatado write FDefeitoRelatado;
    property ServicoExecutado: string read FServicoExecutado write FServicoExecutado;
    property Observacoes: string read FObservacoes write FObservacoes;
    property Desconto: Double read FDesconto write FDesconto;
    property TotalPecas: Double read FTotalPecas write FTotalPecas;
    property TotalServicos: Double read FTotalServicos write FTotalServicos;
    property TotalGeral: Double read FTotalGeral write FTotalGeral;
    property FormaPagamento: string read FFormaPagamento write FFormaPagamento;
    property ValorPago: Double read FValorPago write FValorPago;
    property Itens: TList read FItens;
    property Servicos: TList read FServicos;
  end;

implementation

constructor TsigoOSItemPeca.Create;
begin
  inherited Create;
  ID := 0;
  PecaID := 0;
  Descricao := '';
  Quantidade := 1;
  ValorUnitario := 0;
  ValorCusto := 0;
  Desconto := 0;
  Total := 0;
end;

constructor TsigoOSItemServico.Create;
begin
  inherited Create;
  ID := 0;
  ServicoID := 0;
  ColaboradorID := 0;
  Descricao := '';
  Quantidade := 1;
  ValorUnitario := 0;
  Desconto := 0;
  Total := 0;
end;

constructor TsigoModelOS.Create;
begin
  inherited Create;
  FNumero := '';
  FClienteID := 0;
  FVeiculoID := 0;
  FColaboradorID := 0;
  FStatus := 'ABERTA';
  FBoxPrisma := '';
  FDataAbertura := Now;
  FDataPrevisao := 0;
  FDataConclusao := 0;
  FDataEntrega := 0;
  FKmEntrada := 0;
  FKmSaida := 0;
  FDefeitoRelatado := '';
  FServicoExecutado := '';
  FObservacoes := '';
  FDesconto := 0;
  FTotalPecas := 0;
  FTotalServicos := 0;
  FTotalGeral := 0;
  FFormaPagamento := '';
  FValorPago := 0;
  FItens := TList.Create;
  FServicos := TList.Create;
end;

destructor TsigoModelOS.Destroy;
var
  i: Integer;
begin
  for i := 0 to FItens.Count - 1 do
    TObject(FItens[i]).Free;
  for i := 0 to FServicos.Count - 1 do
    TObject(FServicos[i]).Free;
  FItens.Free;
  FServicos.Free;
  inherited Destroy;
end;

end.
