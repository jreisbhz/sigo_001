unit sigo_ModelPeca;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelBase;

type
  TsigoModelPeca = class(TsigoModelBase)
  private
    FCategoriaID: Integer;
    FFornecedorID: Integer;
    FCodigo: string;
    FCodigoFabricante: string;
    FCodigoBarras: string;
    FDescricao: string;
    FUnidade: string;
    FLocalizacao: string;
    FMarca: string;
    FEstoqueAtual: Double;
    FEstoqueMinimo: Double;
    FEstoqueMaximo: Double;
    FPrecoCusto: Double;
    FMargemVista: Double;
    FMargemPrazo: Double;
    FMargemAtacado: Double;
    FPrecoVista: Double;
    FPrecoPrazo: Double;
    FPrecoAtacado: Double;
    FObservacoes: string;
    FAtivo: Boolean;
  public
    constructor Create;
    property CategoriaID: Integer read FCategoriaID write FCategoriaID;
    property FornecedorID: Integer read FFornecedorID write FFornecedorID;
    property Codigo: string read FCodigo write FCodigo;
    property CodigoFabricante: string read FCodigoFabricante write FCodigoFabricante;
    property CodigoBarras: string read FCodigoBarras write FCodigoBarras;
    property Descricao: string read FDescricao write FDescricao;
    property Unidade: string read FUnidade write FUnidade;
    property Localizacao: string read FLocalizacao write FLocalizacao;
    property Marca: string read FMarca write FMarca;
    property EstoqueAtual: Double read FEstoqueAtual write FEstoqueAtual;
    property EstoqueMinimo: Double read FEstoqueMinimo write FEstoqueMinimo;
    property EstoqueMaximo: Double read FEstoqueMaximo write FEstoqueMaximo;
    property PrecoCusto: Double read FPrecoCusto write FPrecoCusto;
    property MargemVista: Double read FMargemVista write FMargemVista;
    property MargemPrazo: Double read FMargemPrazo write FMargemPrazo;
    property MargemAtacado: Double read FMargemAtacado write FMargemAtacado;
    property PrecoVista: Double read FPrecoVista write FPrecoVista;
    property PrecoPrazo: Double read FPrecoPrazo write FPrecoPrazo;
    property PrecoAtacado: Double read FPrecoAtacado write FPrecoAtacado;
    property Observacoes: string read FObservacoes write FObservacoes;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

constructor TsigoModelPeca.Create;
begin
  inherited Create;
  FCategoriaID := 0;
  FFornecedorID := 0;
  FCodigo := '';
  FCodigoFabricante := '';
  FCodigoBarras := '';
  FDescricao := '';
  FUnidade := 'UN';
  FLocalizacao := '';
  FMarca := '';
  FEstoqueAtual := 0;
  FEstoqueMinimo := 0;
  FEstoqueMaximo := 0;
  FPrecoCusto := 0;
  FMargemVista := 0;
  FMargemPrazo := 0;
  FMargemAtacado := 0;
  FPrecoVista := 0;
  FPrecoPrazo := 0;
  FPrecoAtacado := 0;
  FObservacoes := '';
  FAtivo := True;
end;

end.
