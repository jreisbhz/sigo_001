unit sigo_ModelColaborador;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelBase;

type
  TsigoModelColaborador = class(TsigoModelBase)
  private
    FUsuarioID: Integer;
    FNome: string;
    FCPF: string;
    FRG: string;
    FDataNasc: TDate;
    FCargo: string;
    FEspecialidade: string;
    FTelefone: string;
    FCelular: string;
    FEmail: string;
    FDataAdmissao: TDate;
    FSalario: Double;
    FComissaoPct: Double;
    FAtivo: Boolean;
  public
    constructor Create;
    property UsuarioID: Integer read FUsuarioID write FUsuarioID;
    property Nome: string read FNome write FNome;
    property CPF: string read FCPF write FCPF;
    property RG: string read FRG write FRG;
    property DataNasc: TDate read FDataNasc write FDataNasc;
    property Cargo: string read FCargo write FCargo;
    property Especialidade: string read FEspecialidade write FEspecialidade;
    property Telefone: string read FTelefone write FTelefone;
    property Celular: string read FCelular write FCelular;
    property Email: string read FEmail write FEmail;
    property DataAdmissao: TDate read FDataAdmissao write FDataAdmissao;
    property Salario: Double read FSalario write FSalario;
    property ComissaoPct: Double read FComissaoPct write FComissaoPct;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

constructor TsigoModelColaborador.Create;
begin
  inherited Create;
  FUsuarioID := 0;
  FNome := '';
  FCPF := '';
  FRG := '';
  FDataNasc := 0;
  FCargo := '';
  FEspecialidade := '';
  FTelefone := '';
  FCelular := '';
  FEmail := '';
  FDataAdmissao := Date;
  FSalario := 0;
  FComissaoPct := 0;
  FAtivo := True;
end;

end.
