unit sigo_ModelVeiculo;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelBase;

type
  TsigoModelVeiculo = class(TsigoModelBase)
  private
    FClienteID: Integer;
    FPlaca: string;
    FMarca: string;
    FModelo: string;
    FVersao: string;
    FAnoFabricacao: Integer;
    FAnoModelo: Integer;
    FCor: string;
    FCombustivel: string;
    FRenavam: string;
    FChassi: string;
    FKmAtual: Integer;
    FObservacoes: string;
    FAtivo: Boolean;
  public
    constructor Create;
    property ClienteID: Integer read FClienteID write FClienteID;
    property Placa: string read FPlaca write FPlaca;
    property Marca: string read FMarca write FMarca;
    property Modelo: string read FModelo write FModelo;
    property Versao: string read FVersao write FVersao;
    property AnoFabricacao: Integer read FAnoFabricacao write FAnoFabricacao;
    property AnoModelo: Integer read FAnoModelo write FAnoModelo;
    property Cor: string read FCor write FCor;
    property Combustivel: string read FCombustivel write FCombustivel;
    property Renavam: string read FRenavam write FRenavam;
    property Chassi: string read FChassi write FChassi;
    property KmAtual: Integer read FKmAtual write FKmAtual;
    property Observacoes: string read FObservacoes write FObservacoes;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

constructor TsigoModelVeiculo.Create;
begin
  inherited Create;
  FClienteID := 0;
  FPlaca := '';
  FMarca := '';
  FModelo := '';
  FVersao := '';
  FAnoFabricacao := 0;
  FAnoModelo := 0;
  FCor := '';
  FCombustivel := 'FLEX';
  FRenavam := '';
  FChassi := '';
  FKmAtual := 0;
  FObservacoes := '';
  FAtivo := True;
end;

end.
