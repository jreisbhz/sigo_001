unit sigo_ModelUsuario;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sigo_ModelBase;

type
  TsigoModelUsuario = class(TsigoModelBase)
  private
    FNome: string;
    FLogin: string;
    FSenhaHash: string;
    FPerfil: string;
    FAtivo: Boolean;
    FUltimoAcesso: TDateTime;
  public
    constructor Create;
    property Nome: string read FNome write FNome;
    property Login: string read FLogin write FLogin;
    property SenhaHash: string read FSenhaHash write FSenhaHash;
    property Perfil: string read FPerfil write FPerfil;
    property Ativo: Boolean read FAtivo write FAtivo;
    property UltimoAcesso: TDateTime read FUltimoAcesso write FUltimoAcesso;
  end;

implementation

constructor TsigoModelUsuario.Create;
begin
  inherited Create;
  FNome := '';
  FLogin := '';
  FSenhaHash := '';
  FPerfil := 'ATENDENTE';
  FAtivo := True;
  FUltimoAcesso := 0;
end;

end.
