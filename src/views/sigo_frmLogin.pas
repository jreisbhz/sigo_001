unit sigo_frmLogin;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  sigo_CtrlUsuario, sigo_ModelUsuario, sigo_Utils;

type
  { TfrmLogin }
  TfrmLogin = class(TForm)
    pnlTopo: TPanel;
    imgLogo: TImage;
    lblSistema: TLabel;
    lblSubtitulo: TLabel;
    pnlForm: TPanel;
    lblUsuario: TLabel;
    edtUsuario: TEdit;
    lblSenha: TLabel;
    edtSenha: TEdit;
    pnlBotoes: TPanel;
    btnOK: TBitBtn;
    btnCancelar: TBitBtn;
    lblTentativas: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure edtSenhaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtUsuarioKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FCtrl: TsigoCtrlUsuario;
    FTentativas: Integer;
    FUsuarioLogado: TsigoModelUsuario;
    procedure TentarLogin;
  public
    destructor Destroy; override;
    property UsuarioLogado: TsigoModelUsuario read FUsuarioLogado;
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.lfm}

uses
  LCLType;

{ TfrmLogin }

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlUsuario.Create;
  FTentativas := 0;
  FUsuarioLogado := nil;

  // Layout
  pnlTopo.Color := C_COR_FUNDO_PRINCIPAL;
  pnlTopo.BevelOuter := bvNone;
  lblSistema.Font.Color := C_COR_TEXTO_CLARO;
  lblSistema.Font.Size := 18;
  lblSistema.Font.Bold := True;
  lblSubtitulo.Font.Color := C_COR_TEXTO_CLARO;
  lblSubtitulo.Font.Size := 10;

  pnlForm.Color := C_COR_FUNDO_CONTEUDO;
  pnlForm.BevelOuter := bvNone;

  btnOK.Kind := bkOK;
  btnOK.Caption := 'Entrar';
  btnOK.Default := True;

  btnCancelar.Kind := bkCancel;
  btnCancelar.Caption := 'Cancelar';

  lblTentativas.Caption := '';
  lblTentativas.Font.Color := C_COR_PERIGO;

  edtSenha.PasswordChar := '*';
  edtUsuario.Text := '';
  edtSenha.Text := '';
  edtUsuario.SetFocus;
end;

destructor TfrmLogin.Destroy;
begin
  FreeAndNil(FCtrl);
  // Nota: FUsuarioLogado é propriedade — não liberar aqui; caller responsável
  inherited Destroy;
end;

procedure TfrmLogin.TentarLogin;
begin
  if Trim(edtUsuario.Text) = '' then
  begin
    ShowMessage('Informe o usuário.');
    edtUsuario.SetFocus;
    Exit;
  end;
  if Trim(edtSenha.Text) = '' then
  begin
    ShowMessage('Informe a senha.');
    edtSenha.SetFocus;
    Exit;
  end;

  try
    FUsuarioLogado := FCtrl.ValidarLogin(Trim(edtUsuario.Text), edtSenha.Text);
  except
    on E: Exception do
    begin
      FUsuarioLogado := nil;
      Inc(FTentativas);
      lblTentativas.Caption := Format('Tentativa %d de 3 — %s', [FTentativas, E.Message]);
      edtSenha.Clear;
      edtSenha.SetFocus;

      if FTentativas >= 3 then
      begin
        ShowMessage('Número máximo de tentativas atingido. O sistema será encerrado.');
        Application.Terminate;
      end;
      Exit;
    end;
  end;

  if FUsuarioLogado <> nil then
    ModalResult := mrOk
  else
  begin
    Inc(FTentativas);
    lblTentativas.Caption := Format('Usuário ou senha inválidos. Tentativa %d de 3.', [FTentativas]);
    edtSenha.Clear;
    edtSenha.SetFocus;
    if FTentativas >= 3 then
    begin
      ShowMessage('Número máximo de tentativas atingido. O sistema será encerrado.');
      Application.Terminate;
    end;
  end;
end;

procedure TfrmLogin.btnOKClick(Sender: TObject);
begin
  TentarLogin;
end;

procedure TfrmLogin.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmLogin.edtSenhaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    TentarLogin;
  end;
end;

procedure TfrmLogin.edtUsuarioKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    edtSenha.SetFocus;
  end;
end;

end.
