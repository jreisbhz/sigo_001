unit sigo_ModelCliente;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelBase;

type
  TsigoModelCliente = class(TsigoModelBase)
  private
    FTipoPessoa: string;
    FNome: string;
    FFantasia: string;
    FCpfCnpj: string;
    FRgIe: string;
    FDataNasc: TDate;
    FLogradouro: string;
    FNumero: string;
    FComplemento: string;
    FBairro: string;
    FCidade: string;
    FUF: string;
    FCEP: string;
    FTelefone: string;
    FCelular: string;
    FCelular2: string;
    FEmail: string;
    FObservacoes: string;
    FLimiteCredito: Double;
    FAtivo: Boolean;
  public
    constructor Create;
    property TipoPessoa: string read FTipoPessoa write FTipoPessoa;
    property Nome: string read FNome write FNome;
    property Fantasia: string read FFantasia write FFantasia;
    property CpfCnpj: string read FCpfCnpj write FCpfCnpj;
    property RgIe: string read FRgIe write FRgIe;
    property DataNasc: TDate read FDataNasc write FDataNasc;
    property Logradouro: string read FLogradouro write FLogradouro;
    property Numero: string read FNumero write FNumero;
    property Complemento: string read FComplemento write FComplemento;
    property Bairro: string read FBairro write FBairro;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write FUF;
    property CEP: string read FCEP write FCEP;
    property Telefone: string read FTelefone write FTelefone;
    property Celular: string read FCelular write FCelular;
    property Celular2: string read FCelular2 write FCelular2;
    property Email: string read FEmail write FEmail;
    property Observacoes: string read FObservacoes write FObservacoes;
    property LimiteCredito: Double read FLimiteCredito write FLimiteCredito;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

constructor TsigoModelCliente.Create;
begin
  inherited Create;
  FTipoPessoa := 'F';
  FNome := '';
  FFantasia := '';
  FCpfCnpj := '';
  FRgIe := '';
  FDataNasc := 0;
  FLogradouro := '';
  FNumero := '';
  FComplemento := '';
  FBairro := '';
  FCidade := '';
  FUF := 'SP';
  FCEP := '';
  FTelefone := '';
  FCelular := '';
  FCelular2 := '';
  FEmail := '';
  FObservacoes := '';
  FLimiteCredito := 0;
  FAtivo := True;
end;

end.
