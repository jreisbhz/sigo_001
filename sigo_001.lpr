program sigo_001;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms, Dialogs, SysUtils, Controls,
  sigo_frmLogin,
  sigo_frmMain,
  sigo_frmBase,
  sigo_frmCliente,
  sigo_frmVeiculo,
  sigo_frmFornecedor,
  sigo_frmColaborador,
  sigo_frmPeca,
  sigo_frmServico,
  sigo_frmAgenda,
  sigo_frmOS,
  sigo_frmVenda,
  sigo_frmCaixa,
  sigo_frmContasReceber,
  sigo_frmContasPagar,
  sigo_frmCarta,
  sigo_frmRelatorios,
  sigo_frmConfig;

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.Title := 'SIGO — Gestão de Oficinas';

  try
    frmLogin := TfrmLogin.Create(nil);
    try
      if frmLogin.ShowModal = mrOK then
      begin
        Application.CreateForm(TfrmMain, frmMain);
        frmMain.UsuarioLogado := frmLogin.UsuarioLogado;
      end;
    finally
      FreeAndNil(frmLogin);
    end;
  except
    on E: Exception do
      MessageDlg('Erro de Inicialização',
        'Erro ao iniciar o SIGO:' + LineEnding + E.ClassName + ': ' + E.Message,
        mtError, [mbOK], 0);
  end;

  if Assigned(frmMain) then
    Application.Run;
end.
