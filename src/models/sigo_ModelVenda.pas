unit sigo_ModelVenda;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelBase, Classes;

type
  TVendaItem = class
  public
    ID: Integer;
    PecaID: Integer;
    Descricao: string;
    Quantidade: Double;
    ValorUnitario: Double;
    Desconto: Double;
    Total: Double;
    constructor Create;
  end;

  TsigoModelVenda = class(TsigoModelBase)
  private
    FNumeroComanda: string;
    FDataVenda: TDateTime;
    FClienteID: Integer;
    FAtendenteID: Integer;
    FDesconto: Double;
    FTotal: Double;
    FDataEntrega: TDate;
    FStatus: string;
    FFormaPagamento: string;
    FObservacoes: string;
    FItens: TList;
  public
    constructor Create;
    destructor Destroy; override;
    property NumeroComanda: string read FNumeroComanda write FNumeroComanda;
    property DataVenda: TDateTime read FDataVenda write FDataVenda;
    property ClienteID: Integer read FClienteID write FClienteID;
    property AtendenteID: Integer read FAtendenteID write FAtendenteID;
    property Desconto: Double read FDesconto write FDesconto;
    property Total: Double read FTotal write FTotal;
    property DataEntrega: TDate read FDataEntrega write FDataEntrega;
    property Status: string read FStatus write FStatus;
    property FormaPagamento: string read FFormaPagamento write FFormaPagamento;
    property Observacoes: string read FObservacoes write FObservacoes;
    property Itens: TList read FItens;
  end;

implementation

constructor TVendaItem.Create;
begin
  inherited Create;
  ID := 0;
  PecaID := 0;
  Descricao := '';
  Quantidade := 1;
  ValorUnitario := 0;
  Desconto := 0;
  Total := 0;
end;

constructor TsigoModelVenda.Create;
begin
  inherited Create;
  FNumeroComanda := '';
  FDataVenda := Now;
  FClienteID := 0;
  FAtendenteID := 0;
  FDesconto := 0;
  FTotal := 0;
  FDataEntrega := 0;
  FStatus := 'ABERTA';
  FFormaPagamento := '';
  FObservacoes := '';
  FItens := TList.Create;
end;

destructor TsigoModelVenda.Destroy;
var
  i: Integer;
begin
  for i := 0 to FItens.Count - 1 do
    TObject(FItens[i]).Free;
  FItens.Free;
  inherited Destroy;
end;

end.
