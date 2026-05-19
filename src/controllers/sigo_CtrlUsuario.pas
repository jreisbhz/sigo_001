unit sigo_CtrlUsuario;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sha256, sigo_ModelUsuario, sigo_RepoUsuario;

type
  TsigoCtrlUsuario = class
  private
    FRepo: TsigoRepoUsuario;
  public
    constructor Create;
    destructor Destroy; override;
    function ValidarLogin(const ALogin, ASenha: string): TsigoModelUsuario;
    function GerarHashSenha(const ASenha: string): string;
    procedure CriarUsuario(const ANome, ALogin, ASenha, APerfil: string);
  end;

implementation

constructor TsigoCtrlUsuario.Create;
begin
  inherited Create;
  FRepo := TsigoRepoUsuario.Create;
end;

destructor TsigoCtrlUsuario.Destroy;
begin
  FreeAndNil(FRepo);
  inherited Destroy;
end;

function TsigoCtrlUsuario.GerarHashSenha(const ASenha: string): string;
begin
  Result := SHA256Print(SHA256String(ASenha));
end;

function TsigoCtrlUsuario.ValidarLogin(const ALogin, ASenha: string): TsigoModelUsuario;
var
  LSenhaHash: string;
begin
  LSenhaHash := GerarHashSenha(ASenha);
  Result := FRepo.BuscarPorLogin(ALogin, LSenhaHash);
end;

procedure TsigoCtrlUsuario.CriarUsuario(const ANome, ALogin, ASenha, APerfil: string);
var
  LUsuario: TsigoModelUsuario;
begin
  LUsuario := TsigoModelUsuario.Create;
  try
    LUsuario.Nome := ANome;
    LUsuario.Login := ALogin;
    LUsuario.SenhaHash := GerarHashSenha(ASenha);
    LUsuario.Perfil := APerfil;
    LUsuario.Ativo := True;
    FRepo.Salvar(LUsuario);
  finally
    LUsuario.Free;
  end;
end;

end.
