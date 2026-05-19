unit sigo_ModelServico;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelBase;

type
  TsigoModelServico = class(TsigoModelBase)
  private
    FCodigo: string;
    FNome: string;
    FDescricao: string;
    FValorPadrao: Double;
    FTempoEstimado: Integer;
    FAtivo: Boolean;
  public
    constructor Create;
    property Codigo: string read FCodigo write FCodigo;
    property Nome: string read FNome write FNome;
    property Descricao: string read FDescricao write FDescricao;
    property ValorPadrao: Double read FValorPadrao write FValorPadrao;
    property TempoEstimado: Integer read FTempoEstimado write FTempoEstimado;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

constructor TsigoModelServico.Create;
begin
  inherited Create;
  FCodigo := '';
  FNome := '';
  FDescricao := '';
  FValorPadrao := 0;
  FTempoEstimado := 0;
  FAtivo := True;
end;

end.
