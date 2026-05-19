unit sigo_frmMain;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, ExtCtrls, StdCtrls, Buttons, ImgList,
  TAGraph, TASeries, TAChartAxis,
  Grids, LCLType,
  sigo_ModelUsuario, sigo_Utils, sigo_Config, sigo_Logger,
  sigo_DBConnection;

type
  { TfrmMain }
  TfrmMain = class(TForm)
    { Topo }
    pnlTopo: TPanel;
    lblNomeSistema: TLabel;
    lblRelogio: TLabel;
    lblUsuarioLogado: TLabel;
    { Menu }
    mnuPrincipal: TMainMenu;
    mnuCadastros: TMenuItem;
    mnuClientes: TMenuItem;
    mnuVeiculos: TMenuItem;
    mnuFornecedores: TMenuItem;
    mnuColaboradores: TMenuItem;
    mnuSep1: TMenuItem;
    mnuPecas: TMenuItem;
    mnuServicos: TMenuItem;
    mnuOS: TMenuItem;
    mnuOSMenu: TMenuItem;
    mnuAgenda: TMenuItem;
    mnuVendas: TMenuItem;
    mnuFinanceiro: TMenuItem;
    mnuCaixa: TMenuItem;
    mnuContasReceber: TMenuItem;
    mnuContasPagar: TMenuItem;
    mnuRelatorios: TMenuItem;
    mnuRelatorioOS: TMenuItem;
    mnuRelatorioEstoque: TMenuItem;
    mnuRelatorioFinanceiro: TMenuItem;
    mnuSistema: TMenuItem;
    mnuCartas: TMenuItem;
    mnuConfig: TMenuItem;
    mnuSepSistema: TMenuItem;
    mnuSair: TMenuItem;
    { Atalhos }
    pnlAtalhos: TPanel;
    btnAtlOS: TSpeedButton;
    btnAtlClientes: TSpeedButton;
    btnAtlVeiculos: TSpeedButton;
    btnAtlPecas: TSpeedButton;
    btnAtlAgenda: TSpeedButton;
    btnAtlCaixa: TSpeedButton;
    btnAtlFornec: TSpeedButton;
    btnAtlRelat: TSpeedButton;
    { Área de trabalho }
    pgcMain: TPageControl;
    tabInicio: TTabSheet;
    { Dashboard }
    pnlDashboard: TPanel;
    grpAgenda: TGroupBox;
    grdAgendaHoje: TStringGrid;
    grpAniversariantes: TGroupBox;
    grdAniversariantes: TStringGrid;
    grpContasReceber: TGroupBox;
    grdContasReceber: TStringGrid;
    grpContasPagar: TGroupBox;
    grdContasPagar: TStringGrid;
    chtResumo: TChart;
    { Rodapé }
    sbStatus: TStatusBar;
    { Timer }
    tmrRelogio: TTimer;
    { ImageList }
    ilSistema: TImageList;
    { Eventos }
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tmrRelogioTimer(Sender: TObject);
    procedure pgcMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    { Menu — Cadastros }
    procedure mnuClientesClick(Sender: TObject);
    procedure mnuVeiculosClick(Sender: TObject);
    procedure mnuFornecedoresClick(Sender: TObject);
    procedure mnuColaboradoresClick(Sender: TObject);
    procedure mnuPecasClick(Sender: TObject);
    procedure mnuServicosClick(Sender: TObject);
    { Menu — OS }
    procedure mnuOSMenuClick(Sender: TObject);
    procedure mnuAgendaClick(Sender: TObject);
    procedure mnuVendasClick(Sender: TObject);
    { Menu — Financeiro }
    procedure mnuCaixaClick(Sender: TObject);
    procedure mnuContasReceberClick(Sender: TObject);
    procedure mnuContasPagarClick(Sender: TObject);
    { Menu — Relatórios }
    procedure mnuRelatorioOSClick(Sender: TObject);
    { Menu — Sistema }
    procedure mnuCartasClick(Sender: TObject);
    procedure mnuConfigClick(Sender: TObject);
    procedure mnuSairClick(Sender: TObject);
    { Atalhos }
    procedure btnAtlOSClick(Sender: TObject);
    procedure btnAtlClientesClick(Sender: TObject);
    procedure btnAtlVeiculosClick(Sender: TObject);
    procedure btnAtlPecasClick(Sender: TObject);
    procedure btnAtlAgendaClick(Sender: TObject);
    procedure btnAtlCaixaClick(Sender: TObject);
    procedure btnAtlFornecClick(Sender: TObject);
    procedure btnAtlRelatClick(Sender: TObject);
  private
    FUsuarioLogado: TsigoModelUsuario;
    procedure ConfigurarLayout;
    procedure ConfigurarMenu;
    procedure InicializarDashboard;
    procedure CarregarAgendaHoje;
    procedure CarregarAniversariantes;
    procedure CarregarContasReceber;
    procedure CarregarContasPagar;
    procedure CarregarGraficoCaixa;
    procedure AbrirModulo(const ATitulo: string; AFormClass: TFormClass);
    procedure AtualizarStatusBar;
  public
    property UsuarioLogado: TsigoModelUsuario read FUsuarioLogado write FUsuarioLogado;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

uses
  FileUtil, FileCtrl, sqldb,
  sigo_frmCliente, sigo_frmVeiculo, sigo_frmFornecedor,
  sigo_frmColaborador, sigo_frmPeca, sigo_frmServico,
  sigo_frmAgenda, sigo_frmOS, sigo_frmVenda,
  sigo_frmCaixa, sigo_frmContasReceber, sigo_frmContasPagar,
  sigo_frmCarta, sigo_frmRelatorios, sigo_frmConfig;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  OnCloseQuery := @FormCloseQuery;
  ConfigurarLayout;
  ConfigurarMenu;
  InicializarDashboard;
  tmrRelogio.Enabled := True;
  TsigoLogger.Instancia.Info('Sistema iniciado');
end;

procedure TfrmMain.ConfigurarLayout;
begin
  Caption := 'SIGO — Sistema Integrado de Gestão de Oficinas';
  WindowState := wsMaximized;

  // Topo
  pnlTopo.Height := 56;
  pnlTopo.BevelOuter := bvNone;
  pnlTopo.Color := C_COR_FUNDO_PRINCIPAL;

  lblNomeSistema.Font.Color := C_COR_TEXTO_CLARO;
  lblNomeSistema.Font.Size := 14;
  lblNomeSistema.Font.Bold := True;
  lblNomeSistema.Caption := 'SIGO — Gestão de Oficinas';

  lblRelogio.Font.Color := C_COR_TEXTO_CLARO;
  lblRelogio.Alignment := taRightJustify;

  lblUsuarioLogado.Font.Color := C_COR_TEXTO_CLARO;
  if FUsuarioLogado <> nil then
    lblUsuarioLogado.Caption := 'Usuário: ' + FUsuarioLogado.Nome;

  // Atalhos
  pnlAtalhos.Height := 48;
  pnlAtalhos.BevelOuter := bvNone;
  pnlAtalhos.Color := $00E8E8E8;

  btnAtlOS.Flat := True;
  btnAtlOS.Caption := 'Nova OS';
  btnAtlClientes.Flat := True;
  btnAtlClientes.Caption := 'Clientes';
  btnAtlVeiculos.Flat := True;
  btnAtlVeiculos.Caption := 'Veículos';
  btnAtlPecas.Flat := True;
  btnAtlPecas.Caption := 'Peças';
  btnAtlAgenda.Flat := True;
  btnAtlAgenda.Caption := 'Agenda';
  btnAtlCaixa.Flat := True;
  btnAtlCaixa.Caption := 'Caixa';
  btnAtlFornec.Flat := True;
  btnAtlFornec.Caption := 'Fornecedores';
  btnAtlRelat.Flat := True;
  btnAtlRelat.Caption := 'Relatórios';

  // PageControl
  pgcMain.Options := [nboShowCloseButtons];
  pgcMain.TabPosition := tpTop;
  pgcMain.Align := alClient;

  // Aba inicial
  tabInicio.Caption := 'Início — Dashboard';

  // StatusBar
  sbStatus.SimplePanel := False;
  while sbStatus.Panels.Count < 3 do sbStatus.Panels.Add;
  sbStatus.Panels[0].Width := 260;
  sbStatus.Panels[1].Width := 220;
  sbStatus.Panels[2].Width := 200;
  sbStatus.Panels[2].Alignment := taRightJustify;

  AtualizarStatusBar;
end;

procedure TfrmMain.AtualizarStatusBar;
var
  NomeUsuario, NomeBanco: string;
begin
  if FUsuarioLogado <> nil then
    NomeUsuario := FUsuarioLogado.Nome + ' [' + FUsuarioLogado.Perfil + ']'
  else
    NomeUsuario := '---';

  NomeBanco := ExtractFileName(TsigoConfig.Instancia.Banco);

  sbStatus.Panels[0].Text := 'Usuário: ' + NomeUsuario;
  sbStatus.Panels[1].Text := 'Banco: ' + NomeBanco;
  sbStatus.Panels[2].Text := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
end;

procedure TfrmMain.ConfigurarMenu;
begin
  mnuCadastros.Caption := 'Cadastros';
  mnuClientes.Caption  := 'Clientes';
  mnuVeiculos.Caption  := 'Veículos';
  mnuFornecedores.Caption := 'Fornecedores';
  mnuColaboradores.Caption := 'Colaboradores';
  mnuPecas.Caption     := 'Peças / Estoque';
  mnuServicos.Caption  := 'Serviços';

  mnuOS.Caption        := 'Operacional';
  mnuOSMenu.Caption    := 'Ordens de Serviço';
  mnuAgenda.Caption    := 'Agenda';
  mnuVendas.Caption    := 'Vendas Diretas';

  mnuFinanceiro.Caption    := 'Financeiro';
  mnuCaixa.Caption         := 'Caixa';
  mnuContasReceber.Caption := 'Contas a Receber';
  mnuContasPagar.Caption   := 'Contas a Pagar';

  mnuRelatorios.Caption     := 'Relatórios';
  mnuRelatorioOS.Caption    := 'Ordens de Serviço';
  mnuRelatorioEstoque.Caption := 'Estoque';
  mnuRelatorioFinanceiro.Caption := 'Financeiro';

  mnuSistema.Caption    := 'Sistema';
  mnuCartas.Caption     := 'Cartas / Comunicação';
  mnuConfig.Caption     := 'Configurações';
  mnuSair.Caption       := 'Sair';

  // Conectar eventos via código (complemento ao LFM)
  mnuClientes.OnClick      := @mnuClientesClick;
  mnuVeiculos.OnClick      := @mnuVeiculosClick;
  mnuFornecedores.OnClick  := @mnuFornecedoresClick;
  mnuColaboradores.OnClick := @mnuColaboradoresClick;
  mnuPecas.OnClick         := @mnuPecasClick;
  mnuServicos.OnClick      := @mnuServicosClick;
  mnuOSMenu.OnClick        := @mnuOSMenuClick;
  mnuAgenda.OnClick        := @mnuAgendaClick;
  mnuVendas.OnClick        := @mnuVendasClick;
  mnuCaixa.OnClick         := @mnuCaixaClick;
  mnuContasReceber.OnClick := @mnuContasReceberClick;
  mnuContasPagar.OnClick   := @mnuContasPagarClick;
  mnuRelatorioOS.OnClick   := @mnuRelatorioOSClick;
  mnuCartas.OnClick        := @mnuCartasClick;
  mnuConfig.OnClick        := @mnuConfigClick;
  mnuSair.OnClick          := @mnuSairClick;

  btnAtlOS.OnClick       := @btnAtlOSClick;
  btnAtlClientes.OnClick := @btnAtlClientesClick;
  btnAtlVeiculos.OnClick := @btnAtlVeiculosClick;
  btnAtlPecas.OnClick    := @btnAtlPecasClick;
  btnAtlAgenda.OnClick   := @btnAtlAgendaClick;
  btnAtlCaixa.OnClick    := @btnAtlCaixaClick;
  btnAtlFornec.OnClick   := @btnAtlFornecClick;
  btnAtlRelat.OnClick    := @btnAtlRelatClick;

  pgcMain.OnMouseDown    := @pgcMainMouseDown;
end;

procedure TfrmMain.InicializarDashboard;
begin
  // Grids do dashboard
  grpAgenda.Caption := 'Agenda do Dia';

  grdAgendaHoje.ColCount := 4;
  grdAgendaHoje.Cells[0,0] := 'Hora';
  grdAgendaHoje.Cells[1,0] := 'Cliente';
  grdAgendaHoje.Cells[2,0] := 'Placa';
  grdAgendaHoje.Cells[3,0] := 'Serviço';
  grdAgendaHoje.FixedRows := 1;
  grdAgendaHoje.FixedCols := 0;
  grdAgendaHoje.Options := grdAgendaHoje.Options - [goEditing];

  grpAniversariantes.Caption := 'Aniversariantes';
  grdAniversariantes.ColCount := 3;
  grdAniversariantes.Cells[0,0] := 'Nome';
  grdAniversariantes.Cells[1,0] := 'Telefone';
  grdAniversariantes.Cells[2,0] := 'WhatsApp';
  grdAniversariantes.FixedRows := 1;
  grdAniversariantes.FixedCols := 0;
  grdAniversariantes.Options := grdAniversariantes.Options - [goEditing];

  grpContasReceber.Caption := 'Contas a Receber (Vencendo)';
  grdContasReceber.ColCount := 4;
  grdContasReceber.Cells[0,0] := 'Cliente';
  grdContasReceber.Cells[1,0] := 'Vencimento';
  grdContasReceber.Cells[2,0] := 'Valor';
  grdContasReceber.Cells[3,0] := 'Status';
  grdContasReceber.FixedRows := 1;
  grdContasReceber.FixedCols := 0;
  grdContasReceber.Options := grdContasReceber.Options - [goEditing];

  grpContasPagar.Caption := 'Contas a Pagar (Vencendo)';
  grdContasPagar.ColCount := 4;
  grdContasPagar.Cells[0,0] := 'Fornecedor';
  grdContasPagar.Cells[1,0] := 'Vencimento';
  grdContasPagar.Cells[2,0] := 'Valor';
  grdContasPagar.Cells[3,0] := 'Status';
  grdContasPagar.FixedRows := 1;
  grdContasPagar.FixedCols := 0;
  grdContasPagar.Options := grdContasPagar.Options - [goEditing];

  CarregarAgendaHoje;
  CarregarAniversariantes;
  CarregarContasReceber;
  CarregarContasPagar;
  CarregarGraficoCaixa;
end;

procedure TfrmMain.CarregarAgendaHoje;
var
  Q: TSQLQuery;
  Row: Integer;
begin
  grdAgendaHoje.RowCount := 2;
  Row := 1;
  try
    Q := TsigoDBConnection.Instancia.NovaQuery;
    try
      Q.SQL.Text :=
        'SELECT a.hora_inicio, c.nome, v.placa, a.observacoes ' +
        'FROM agenda a ' +
        'LEFT JOIN clientes c ON c.id = a.cliente_id ' +
        'LEFT JOIN veiculos v ON v.id = a.veiculo_id ' +
        'WHERE DATE(a.data_agenda) = DATE(''now'',''localtime'') ' +
        'AND a.ativo = 1 ORDER BY a.hora_inicio';
      Q.Open;
      while not Q.EOF do
      begin
        if Row >= grdAgendaHoje.RowCount then
          grdAgendaHoje.RowCount := Row + 1;
        grdAgendaHoje.Cells[0, Row] := Copy(Q.Fields[0].AsString, 1, 5);
        grdAgendaHoje.Cells[1, Row] := Q.Fields[1].AsString;
        grdAgendaHoje.Cells[2, Row] := Q.Fields[2].AsString;
        grdAgendaHoje.Cells[3, Row] := Q.Fields[3].AsString;
        Inc(Row);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  except
    on E: Exception do
      TsigoLogger.Instancia.Aviso('Dashboard agenda: ' + E.Message);
  end;
end;

procedure TfrmMain.CarregarAniversariantes;
var
  Q: TSQLQuery;
  Row: Integer;
begin
  grdAniversariantes.RowCount := 2;
  Row := 1;
  try
    Q := TsigoDBConnection.Instancia.NovaQuery;
    try
      Q.SQL.Text :=
        'SELECT nome, telefone, celular FROM clientes ' +
        'WHERE STRFTIME(''%m-%d'', data_nasc) = STRFTIME(''%m-%d'', ''now'',''localtime'') ' +
        'AND ativo = 1 ORDER BY nome';
      Q.Open;
      while not Q.EOF do
      begin
        if Row >= grdAniversariantes.RowCount then
          grdAniversariantes.RowCount := Row + 1;
        grdAniversariantes.Cells[0, Row] := Q.Fields[0].AsString;
        grdAniversariantes.Cells[1, Row] := Q.Fields[1].AsString;
        grdAniversariantes.Cells[2, Row] := Q.Fields[2].AsString;
        Inc(Row);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  except
    on E: Exception do
      TsigoLogger.Instancia.Aviso('Dashboard aniversariantes: ' + E.Message);
  end;
end;

procedure TfrmMain.CarregarContasReceber;
var
  Q: TSQLQuery;
  Row: Integer;
begin
  grdContasReceber.RowCount := 2;
  Row := 1;
  try
    Q := TsigoDBConnection.Instancia.NovaQuery;
    try
      Q.SQL.Text :=
        'SELECT c.nome, cr.data_vencimento, cr.valor, cr.status ' +
        'FROM contas_receber cr ' +
        'LEFT JOIN clientes c ON c.id = cr.cliente_id ' +
        'WHERE cr.status IN (''ABERTA'',''PARCIAL'') ' +
        'AND DATE(cr.data_vencimento) <= DATE(''now'',''localtime'',''+7 days'') ' +
        'ORDER BY cr.data_vencimento LIMIT 20';
      Q.Open;
      while not Q.EOF do
      begin
        if Row >= grdContasReceber.RowCount then
          grdContasReceber.RowCount := Row + 1;
        grdContasReceber.Cells[0, Row] := Q.Fields[0].AsString;
        grdContasReceber.Cells[1, Row] := FormatData(Q.Fields[1].AsDateTime);
        grdContasReceber.Cells[2, Row] := FormatMoeda(Q.Fields[2].AsFloat);
        grdContasReceber.Cells[3, Row] := Q.Fields[3].AsString;
        Inc(Row);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  except
    on E: Exception do
      TsigoLogger.Instancia.Aviso('Dashboard CR: ' + E.Message);
  end;
end;

procedure TfrmMain.CarregarContasPagar;
var
  Q: TSQLQuery;
  Row: Integer;
begin
  grdContasPagar.RowCount := 2;
  Row := 1;
  try
    Q := TsigoDBConnection.Instancia.NovaQuery;
    try
      Q.SQL.Text :=
        'SELECT f.nome, cp.data_vencimento, cp.valor, cp.status ' +
        'FROM contas_pagar cp ' +
        'LEFT JOIN fornecedores f ON f.id = cp.fornecedor_id ' +
        'WHERE cp.status IN (''ABERTA'',''PARCIAL'') ' +
        'AND DATE(cp.data_vencimento) <= DATE(''now'',''localtime'',''+7 days'') ' +
        'ORDER BY cp.data_vencimento LIMIT 20';
      Q.Open;
      while not Q.EOF do
      begin
        if Row >= grdContasPagar.RowCount then
          grdContasPagar.RowCount := Row + 1;
        grdContasPagar.Cells[0, Row] := Q.Fields[0].AsString;
        grdContasPagar.Cells[1, Row] := FormatData(Q.Fields[1].AsDateTime);
        grdContasPagar.Cells[2, Row] := FormatMoeda(Q.Fields[2].AsFloat);
        grdContasPagar.Cells[3, Row] := Q.Fields[3].AsString;
        Inc(Row);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  except
    on E: Exception do
      TsigoLogger.Instancia.Aviso('Dashboard CP: ' + E.Message);
  end;
end;

procedure TfrmMain.CarregarGraficoCaixa;
begin
  // TAChart — gráfico de barras Entradas × Saídas (stub)
end;

procedure TfrmMain.AbrirModulo(const ATitulo: string; AFormClass: TFormClass);
var
  Tab: TTabSheet;
  Frm: TForm;
  i: Integer;
begin
  // Verifica se já está aberto
  for i := 0 to pgcMain.PageCount - 1 do
    if pgcMain.Pages[i].Caption = ATitulo then
    begin
      pgcMain.ActivePage := pgcMain.Pages[i];
      Exit;
    end;

  // Cria nova aba
  Tab := TTabSheet.Create(pgcMain);
  Tab.Caption := ATitulo;
  Tab.PageControl := pgcMain;

  Frm := AFormClass.Create(Tab);
  Frm.Parent := Tab;
  Frm.Align := alClient;
  Frm.BorderStyle := bsNone;
  Frm.Visible := True;

  pgcMain.ActivePage := Tab;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Resp: Integer;
  Destino, Origem, ArqDestino: string;
begin
  Resp := MessageDlg(
    'Deseja fazer backup antes de fechar?' + LineEnding +
    'Recomendamos salvar em um pen drive ou pasta segura.',
    mtConfirmation, [mbYes, mbNo, mbCancel], 0);

  case Resp of
    mrYes:
    begin
      if SelectDirectory('Selecione a pasta de backup:', '', Destino) then
      begin
        Origem     := TsigoConfig.Instancia.Banco;
        ArqDestino := IncludeTrailingPathDelimiter(Destino) +
                      'backup_sigo_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.db';
        if CopyFile(Origem, ArqDestino) then
          ShowMessage('Backup realizado com sucesso!' + LineEnding + ArqDestino)
        else
          ShowMessage('Erro ao realizar o backup!');
        CanClose := True;
      end else
        CanClose := False;
    end;
    mrNo:     CanClose := True;
    mrCancel: CanClose := False;
  end;

  if CanClose then
    TsigoLogger.Instancia.Info('Sistema encerrado');
end;

procedure TfrmMain.tmrRelogioTimer(Sender: TObject);
begin
  lblRelogio.Caption := FormatDateTime('dd/mm/yyyy  hh:nn:ss', Now);
  sbStatus.Panels[2].Text := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
end;

procedure TfrmMain.pgcMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TabIndex: Integer;
begin
  if Button = mbMiddle then
  begin
    TabIndex := pgcMain.IndexOfTabAt(X, Y);
    if TabIndex > 0 then // Não fecha aba inicial
      pgcMain.Pages[TabIndex].Free;
  end;
end;

{ Handlers de menu }

procedure TfrmMain.mnuClientesClick(Sender: TObject);
begin
  AbrirModulo('Clientes', TfrmCliente);
end;

procedure TfrmMain.mnuVeiculosClick(Sender: TObject);
begin
  AbrirModulo('Veículos', TfrmVeiculo);
end;

procedure TfrmMain.mnuFornecedoresClick(Sender: TObject);
begin
  AbrirModulo('Fornecedores', TfrmFornecedor);
end;

procedure TfrmMain.mnuColaboradoresClick(Sender: TObject);
begin
  AbrirModulo('Colaboradores', TfrmColaborador);
end;

procedure TfrmMain.mnuPecasClick(Sender: TObject);
begin
  AbrirModulo('Peças / Estoque', TfrmPeca);
end;

procedure TfrmMain.mnuServicosClick(Sender: TObject);
begin
  AbrirModulo('Serviços', TfrmServico);
end;

procedure TfrmMain.mnuOSMenuClick(Sender: TObject);
begin
  AbrirModulo('Ordens de Serviço', TfrmOS);
end;

procedure TfrmMain.mnuAgendaClick(Sender: TObject);
begin
  AbrirModulo('Agenda', TfrmAgenda);
end;

procedure TfrmMain.mnuVendasClick(Sender: TObject);
begin
  AbrirModulo('Vendas Diretas', TfrmVenda);
end;

procedure TfrmMain.mnuCaixaClick(Sender: TObject);
begin
  AbrirModulo('Caixa', TfrmCaixa);
end;

procedure TfrmMain.mnuContasReceberClick(Sender: TObject);
begin
  AbrirModulo('Contas a Receber', TfrmContasReceber);
end;

procedure TfrmMain.mnuContasPagarClick(Sender: TObject);
begin
  AbrirModulo('Contas a Pagar', TfrmContasPagar);
end;

procedure TfrmMain.mnuRelatorioOSClick(Sender: TObject);
begin
  AbrirModulo('Relatórios', TfrmRelatorios);
end;

procedure TfrmMain.mnuCartasClick(Sender: TObject);
begin
  AbrirModulo('Cartas / Comunicação', TfrmCarta);
end;

procedure TfrmMain.mnuConfigClick(Sender: TObject);
begin
  AbrirModulo('Configurações', TfrmConfig);
end;

procedure TfrmMain.mnuSairClick(Sender: TObject);
begin
  Close;
end;

{ Handlers dos botões de atalho }

procedure TfrmMain.btnAtlOSClick(Sender: TObject);
begin
  AbrirModulo('Ordens de Serviço', TfrmOS);
end;

procedure TfrmMain.btnAtlClientesClick(Sender: TObject);
begin
  AbrirModulo('Clientes', TfrmCliente);
end;

procedure TfrmMain.btnAtlVeiculosClick(Sender: TObject);
begin
  AbrirModulo('Veículos', TfrmVeiculo);
end;

procedure TfrmMain.btnAtlPecasClick(Sender: TObject);
begin
  AbrirModulo('Peças / Estoque', TfrmPeca);
end;

procedure TfrmMain.btnAtlAgendaClick(Sender: TObject);
begin
  AbrirModulo('Agenda', TfrmAgenda);
end;

procedure TfrmMain.btnAtlCaixaClick(Sender: TObject);
begin
  AbrirModulo('Caixa', TfrmCaixa);
end;

procedure TfrmMain.btnAtlFornecClick(Sender: TObject);
begin
  AbrirModulo('Fornecedores', TfrmFornecedor);
end;

procedure TfrmMain.btnAtlRelatClick(Sender: TObject);
begin
  AbrirModulo('Relatórios', TfrmRelatorios);
end;

end.
