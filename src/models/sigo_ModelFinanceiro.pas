unit sigo_ModelFinanceiro;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelBase;

type
  TsigoModelCaixaMovimento = class(TsigoModelBase)
  private
    FOSID: Integer;
    FTipo: string;
    FCategoria: string;
    FDescricao: string;
    FValor: Double;
    FDataMovimento: TDateTime;
    FFormaPagamento: string;
    FUsuarioID: Integer;
    FObservacoes: string;
  public
    constructor Create;
    property OSID: Integer read FOSID write FOSID;
    property Tipo: string read FTipo write FTipo;
    property Categoria: string read FCategoria write FCategoria;
    property Descricao: string read FDescricao write FDescricao;
    property Valor: Double read FValor write FValor;
    property DataMovimento: TDateTime read FDataMovimento write FDataMovimento;
    property FormaPagamento: string read FFormaPagamento write FFormaPagamento;
    property UsuarioID: Integer read FUsuarioID write FUsuarioID;
    property Observacoes: string read FObservacoes write FObservacoes;
  end;

  TsigoModelContaReceber = class(TsigoModelBase)
  private
    FOSID: Integer;
    FClienteID: Integer;
    FDescricao: string;
    FValor: Double;
    FValorPago: Double;
    FDataEmissao: TDate;
    FDataVencimento: TDate;
    FDataPagamento: TDate;
    FStatus: string;
    FFormaPagamento: string;
    FObservacoes: string;
    FUsuarioID: Integer;
  public
    constructor Create;
    property OSID: Integer read FOSID write FOSID;
    property ClienteID: Integer read FClienteID write FClienteID;
    property Descricao: string read FDescricao write FDescricao;
    property Valor: Double read FValor write FValor;
    property ValorPago: Double read FValorPago write FValorPago;
    property DataEmissao: TDate read FDataEmissao write FDataEmissao;
    property DataVencimento: TDate read FDataVencimento write FDataVencimento;
    property DataPagamento: TDate read FDataPagamento write FDataPagamento;
    property Status: string read FStatus write FStatus;
    property FormaPagamento: string read FFormaPagamento write FFormaPagamento;
    property Observacoes: string read FObservacoes write FObservacoes;
    property UsuarioID: Integer read FUsuarioID write FUsuarioID;
  end;

  TsigoModelContaPagar = class(TsigoModelBase)
  private
    FFornecedorID: Integer;
    FDescricao: string;
    FValor: Double;
    FValorPago: Double;
    FDataEmissao: TDate;
    FDataVencimento: TDate;
    FDataPagamento: TDate;
    FStatus: string;
    FFormaPagamento: string;
    FObservacoes: string;
  public
    constructor Create;
    property FornecedorID: Integer read FFornecedorID write FFornecedorID;
    property Descricao: string read FDescricao write FDescricao;
    property Valor: Double read FValor write FValor;
    property ValorPago: Double read FValorPago write FValorPago;
    property DataEmissao: TDate read FDataEmissao write FDataEmissao;
    property DataVencimento: TDate read FDataVencimento write FDataVencimento;
    property DataPagamento: TDate read FDataPagamento write FDataPagamento;
    property Status: string read FStatus write FStatus;
    property FormaPagamento: string read FFormaPagamento write FFormaPagamento;
    property Observacoes: string read FObservacoes write FObservacoes;
  end;

implementation

constructor TsigoModelCaixaMovimento.Create;
begin
  inherited Create;
  FOSID := 0;
  FTipo := 'ENTRADA';
  FCategoria := '';
  FDescricao := '';
  FValor := 0;
  FDataMovimento := Now;
  FFormaPagamento := '';
  FUsuarioID := 0;
  FObservacoes := '';
end;

constructor TsigoModelContaReceber.Create;
begin
  inherited Create;
  FOSID := 0;
  FClienteID := 0;
  FDescricao := '';
  FValor := 0;
  FValorPago := 0;
  FDataEmissao := Date;
  FDataVencimento := Date;
  FDataPagamento := 0;
  FStatus := 'ABERTA';
  FFormaPagamento := '';
  FObservacoes := '';
  FUsuarioID := 0;
end;

constructor TsigoModelContaPagar.Create;
begin
  inherited Create;
  FFornecedorID := 0;
  FDescricao := '';
  FValor := 0;
  FValorPago := 0;
  FDataEmissao := Date;
  FDataVencimento := Date;
  FDataPagamento := 0;
  FStatus := 'ABERTA';
  FFormaPagamento := '';
  FObservacoes := '';
end;

end.
