unit sigo_ModelFornecedor;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelBase;

type
  TsigoModelFornecedor = class(TsigoModelBase)
  private
    FTipoPessoa: string;
    FRazaoSocial: string;
    FFantasia: string;
    FCnpjCpf: string;
    FIE: string;
    FLogradouro: string;
    FNumero: string;
    FComplemento: string;
    FBairro: string;
    FCidade: string;
    FUF: string;
    FCEP: string;
    FTelefone: string;
    FCelular: string;
    FEmail: string;
    FContato: string;
    FObservacoes: string;
    FAtivo: Boolean;
  public
    constructor Create;
    property TipoPessoa: string read FTipoPessoa write FTipoPessoa;
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;
    property Fantasia: string read FFantasia write FFantasia;
    property CnpjCpf: string read FCnpjCpf write FCnpjCpf;
    property IE: string read FIE write FIE;
    property Logradouro: string read FLogradouro write FLogradouro;
    property Numero: string read FNumero write FNumero;
    property Complemento: string read FComplemento write FComplemento;
    property Bairro: string read FBairro write FBairro;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write FUF;
    property CEP: string read FCEP write FCEP;
    property Telefone: string read FTelefone write FTelefone;
    property Celular: string read FCelular write FCelular;
    property Email: string read FEmail write FEmail;
    property Contato: string read FContato write FContato;
    property Observacoes: string read FObservacoes write FObservacoes;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

constructor TsigoModelFornecedor.Create;
begin
  inherited Create;
  FTipoPessoa := 'J';
  FRazaoSocial := '';
  FFantasia := '';
  FCnpjCpf := '';
  FIE := '';
  FLogradouro := '';
  FNumero := '';
  FComplemento := '';
  FBairro := '';
  FCidade := '';
  FUF := 'SP';
  FCEP := '';
  FTelefone := '';
  FCelular := '';
  FEmail := '';
  FContato := '';
  FObservacoes := '';
  FAtivo := True;
end;

end.
