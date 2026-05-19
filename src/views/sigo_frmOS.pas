unit sigo_frmOS;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, DateTimePicker, LCLType,
  sigo_frmBase, sigo_ModelOS, sigo_CtrlOS, sigo_Utils;

type
  { TfrmOS }
  TfrmOS = class(TfrmBase)
    pgcOS: TPageControl;
    tabDadosOS: TTabSheet;
    tabItens: TTabSheet;
    tabFinanceiro: TTabSheet;
    // tabDadosOS
    pnlDadosOSTopo: TPanel;
    lblNumOS: TLabel;
    edtNumOS: TEdit;
    lblStatusOS: TLabel;
    cmbStatusOS: TComboBox;
    lblBoxPrisma: TLabel;
    edtBoxPrisma: TEdit;
    lblPlacaOS: TLabel;
    edtPlacaOS: TEdit;
    btnBuscarVeiculoOS: TBitBtn;
    lblModeloOS: TLabel;
    edtModeloOS: TEdit;
    lblKmOS: TLabel;
    edtKmOS: TEdit;
    lblClienteOS: TLabel;
    edtClienteOS: TEdit;
    lblTelClienteOS: TLabel;
    edtTelClienteOS: TEdit;
    lblMecanicoOS: TLabel;
    cmbMecanicoOS: TComboBox;
    lblDataAberturaOS: TLabel;
    dtpDataAberturaOS: TDateTimePicker;
    lblDataPrevisaoOS: TLabel;
    dtpDataPrevisaoOS: TDateTimePicker;
    lblDefeitoOS: TLabel;
    mmDefeitoOS: TMemo;
    lblServicoExecOS: TLabel;
    mmServicoExecOS: TMemo;
    lblObsOS: TLabel;
    mmObsOS: TMemo;
    // tabItens
    lblPecasOS: TLabel;
    grdPecasOS: TStringGrid;
    pnlBotoesPecas: TPanel;
    btnAddPecaOS: TBitBtn;
    btnRemPecaOS: TBitBtn;
    lblServicosOS: TLabel;
    grdServicosOS: TStringGrid;
    pnlBotoesServicos: TPanel;
    btnAddServOS: TBitBtn;
    btnRemServOS: TBitBtn;
    // tabFinanceiro
    grpFinanceiro: TGroupBox;
    lblTotalPecasOS: TLabel;
    edtTotalPecasOS: TEdit;
    lblTotalServicosOS: TLabel;
    edtTotalServicosOS: TEdit;
    lblDescontoOS: TLabel;
    edtDescontoOS: TEdit;
    lblTotalGeralOS: TLabel;
    edtTotalGeralOS: TEdit;
    lblFormaPgtoOS: TLabel;
    cmbFormaPgtoOS: TComboBox;
    lblValorPagoOS: TLabel;
    edtValorPagoOS: TEdit;
    lblSaldoOS: TLabel;
    edtSaldoOS: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarVeiculoOSClick(Sender: TObject);
    procedure btnAddPecaOSClick(Sender: TObject);
    procedure btnRemPecaOSClick(Sender: TObject);
    procedure btnAddServOSClick(Sender: TObject);
    procedure btnRemServOSClick(Sender: TObject);
    procedure edtDescontoOSExit(Sender: TObject);
    procedure edtValorPagoOSExit(Sender: TObject);
  protected
    FCtrl: TsigoCtrlOS;
    FClienteID: Integer;
    FVeiculoID: Integer;
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure CarregarMecanicos;
    procedure IniciarGridPecas;
    procedure IniciarGridServicos;
    procedure RecalcularTotais;
    function ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor; override;
  public
    destructor Destroy; override;
  end;

var
  frmOS: TfrmOS;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmOS }

procedure TfrmOS.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlOS.Create;
  FClienteID := 0;
  FVeiculoID := 0;

  cmbStatusOS.Items.Clear;
  cmbStatusOS.Items.Add('ABERTA');
  cmbStatusOS.Items.Add('EM ANDAMENTO');
  cmbStatusOS.Items.Add('CONCLUÍDA');
  cmbStatusOS.Items.Add('ENTREGUE');
  cmbStatusOS.Items.Add('CANCELADA');
  cmbStatusOS.ItemIndex := 0;

  cmbFormaPgtoOS.Items.Clear;
  cmbFormaPgtoOS.Items.Add('DINHEIRO');
  cmbFormaPgtoOS.Items.Add('PIX');
  cmbFormaPgtoOS.Items.Add('CARTÃO DÉBITO');
  cmbFormaPgtoOS.Items.Add('CARTÃO CRÉDITO');
  cmbFormaPgtoOS.Items.Add('BOLETO');
  cmbFormaPgtoOS.Items.Add('TRANSFERÊNCIA');
  cmbFormaPgtoOS.Items.Add('A PRAZO');
  cmbFormaPgtoOS.ItemIndex := 0;

  dtpDataAberturaOS.Kind := dtkDate;
  dtpDataPrevisaoOS.Kind := dtkDate;
  dtpDataAberturaOS.Date := Date;
  dtpDataPrevisaoOS.Date := Date;

  edtTotalPecasOS.ReadOnly   := True;
  edtTotalServicosOS.ReadOnly := True;
  edtTotalGeralOS.ReadOnly   := True;
  edtSaldoOS.ReadOnly        := True;
  edtModeloOS.ReadOnly       := True;
  edtClienteOS.ReadOnly      := True;
  edtTelClienteOS.ReadOnly   := True;
  edtNumOS.ReadOnly          := True;

  edtTotalPecasOS.Color   := $00E8E8E8;
  edtTotalServicosOS.Color := $00E8E8E8;
  edtTotalGeralOS.Color   := $00E8E8E8;
  edtNumOS.Color           := $00E8E8E8;
  edtModeloOS.Color        := $00E8E8E8;
  edtClienteOS.Color       := $00E8E8E8;
  edtTelClienteOS.Color    := $00E8E8E8;

  edtTotalGeralOS.Font.Style := [fsBold];
  edtTotalGeralOS.Font.Size  := 12;

  IniciarGridPecas;
  IniciarGridServicos;
  CarregarMecanicos;
  btnBuscarVeiculoOS.OnClick := @btnBuscarVeiculoOSClick;
  btnAddPecaOS.OnClick := @btnAddPecaOSClick;
  btnRemPecaOS.OnClick := @btnRemPecaOSClick;
  btnAddServOS.OnClick := @btnAddServOSClick;
  btnRemServOS.OnClick := @btnRemServOSClick;
  edtDescontoOS.OnExit := @edtDescontoOSExit;
  edtValorPagoOS.OnExit := @edtValorPagoOSExit;
  inherited FormCreate(Sender);
end;

destructor TfrmOS.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

procedure TfrmOS.IniciarGridPecas;
begin
  grdPecasOS.ColCount := 6;
  grdPecasOS.RowCount := 2;
  grdPecasOS.FixedRows := 1;
  grdPecasOS.FixedCols := 0;
  grdPecasOS.DefaultRowHeight := 22;
  grdPecasOS.Options := grdPecasOS.Options + [goEditing];
  grdPecasOS.Cells[0, 0] := 'ID';
  grdPecasOS.Cells[1, 0] := 'Código';
  grdPecasOS.Cells[2, 0] := 'Descrição';
  grdPecasOS.Cells[3, 0] := 'Qtd';
  grdPecasOS.Cells[4, 0] := 'Vlr Unit.';
  grdPecasOS.Cells[5, 0] := 'Total';
  grdPecasOS.ColWidths[0] := 0;  // ID oculto (largura 0)
  grdPecasOS.ColWidths[1] := 70;
  grdPecasOS.ColWidths[2] := 200;
  grdPecasOS.ColWidths[3] := 50;
  grdPecasOS.ColWidths[4] := 70;
  grdPecasOS.ColWidths[5] := 80;
end;

procedure TfrmOS.IniciarGridServicos;
begin
  grdServicosOS.ColCount := 5;
  grdServicosOS.RowCount := 2;
  grdServicosOS.FixedRows := 1;
  grdServicosOS.FixedCols := 0;
  grdServicosOS.DefaultRowHeight := 22;
  grdServicosOS.Options := grdServicosOS.Options + [goEditing];
  grdServicosOS.Cells[0, 0] := 'ID';
  grdServicosOS.Cells[1, 0] := 'Descrição';
  grdServicosOS.Cells[2, 0] := 'Qtd';
  grdServicosOS.Cells[3, 0] := 'Vlr Unit.';
  grdServicosOS.Cells[4, 0] := 'Total';
  grdServicosOS.ColWidths[0] := 0;
  grdServicosOS.ColWidths[1] := 230;
  grdServicosOS.ColWidths[2] := 50;
  grdServicosOS.ColWidths[3] := 70;
  grdServicosOS.ColWidths[4] := 80;
end;

procedure TfrmOS.CarregarMecanicos;
var
  Q: TSQLQuery;
begin
  cmbMecanicoOS.Items.Clear;
  cmbMecanicoOS.Items.AddObject('(Nenhum)', TObject(PtrInt(0)));
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT id, nome FROM colaboradores WHERE ativo = 1 ORDER BY nome';
    Q.Open;
    while not Q.EOF do
    begin
      cmbMecanicoOS.Items.AddObject(Q.Fields[1].AsString, TObject(PtrInt(Q.Fields[0].AsInteger)));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  cmbMecanicoOS.ItemIndex := 0;
end;

function TfrmOS.ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor;
var
  Status: string;
begin
  Result := inherited ObterCorLinha(AGrid, ARow);
  if (ARow > 0) and (AGrid.ColCount > 4) then
  begin
    Status := UpperCase(AGrid.Cells[4, ARow]);
    if Status = 'CANCELADA' then
      Result := C_COR_LINHA_CRITICA
    else if Status = 'EM ANDAMENTO' then
      Result := C_COR_LINHA_AVISO
    else if (Status = 'CONCLUÍDA') or (Status = 'ENTREGUE') then
      Result := C_COR_LINHA_OK;
  end;
end;

procedure TfrmOS.RecalcularTotais;
var
  TotPecas, TotServ, Desconto, TotGeral, ValPago, Saldo: Double;
  i: Integer;
begin
  TotPecas := 0;
  for i := 1 to grdPecasOS.RowCount - 1 do
    TotPecas := TotPecas + StrToFloatDef(StringReplace(grdPecasOS.Cells[5, i], ',', '.', [rfReplaceAll]), 0);

  TotServ := 0;
  for i := 1 to grdServicosOS.RowCount - 1 do
    TotServ := TotServ + StrToFloatDef(StringReplace(grdServicosOS.Cells[4, i], ',', '.', [rfReplaceAll]), 0);

  Desconto := StrToFloatDef(StringReplace(edtDescontoOS.Text, ',', '.', [rfReplaceAll]), 0);
  TotGeral := TotPecas + TotServ - Desconto;
  if TotGeral < 0 then TotGeral := 0;

  ValPago := StrToFloatDef(StringReplace(edtValorPagoOS.Text, ',', '.', [rfReplaceAll]), 0);
  Saldo   := TotGeral - ValPago;

  edtTotalPecasOS.Text    := FormatMoeda(TotPecas);
  edtTotalServicosOS.Text := FormatMoeda(TotServ);
  edtTotalGeralOS.Text    := FormatMoeda(TotGeral);
  edtSaldoOS.Text         := FormatMoeda(Saldo);
  if Saldo > 0 then
    edtSaldoOS.Color := $00CCCCFF  // vermelho claro
  else
    edtSaldoOS.Color := $00CCFFCC; // verde claro
end;

procedure TfrmOS.edtDescontoOSExit(Sender: TObject);
begin
  RecalcularTotais;
end;

procedure TfrmOS.edtValorPagoOSExit(Sender: TObject);
begin
  RecalcularTotais;
end;

procedure TfrmOS.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL: string;
  Row: Integer;
begin
  grdLista.ColCount := 8;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Nº OS';
  grdLista.Cells[2, 0] := 'Data';
  grdLista.Cells[3, 0] := 'Cliente';
  grdLista.Cells[4, 0] := 'Status';
  grdLista.Cells[5, 0] := 'Placa';
  grdLista.Cells[6, 0] := 'Mecânico';
  grdLista.Cells[7, 0] := 'Total';
  grdLista.ColWidths[0] := 40;
  grdLista.ColWidths[1] := 70;
  grdLista.ColWidths[2] := 75;
  grdLista.ColWidths[3] := 160;
  grdLista.ColWidths[4] := 90;
  grdLista.ColWidths[5] := 70;
  grdLista.ColWidths[6] := 110;
  grdLista.ColWidths[7] := 80;

  Filtro := Trim(edtBusca.Text);
  SQL :=
    'SELECT os.id, os.numero, os.data_abertura, c.nome_razao_social, os.status, ' +
    'v.placa, col.nome, os.total_geral ' +
    'FROM ordens_servico os ' +
    'LEFT JOIN clientes c ON c.id = os.cliente_id ' +
    'LEFT JOIN veiculos v ON v.id = os.veiculo_id ' +
    'LEFT JOIN colaboradores col ON col.id = os.colaborador_id ' +
    'WHERE 1=1 ';
  if Filtro <> '' then
    SQL := SQL + 'AND (os.numero LIKE :F OR c.nome_razao_social LIKE :F OR v.placa LIKE :F) ';
  SQL := SQL + 'ORDER BY os.data_abertura DESC';

  grdLista.RowCount := 2;
  Row := 1;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := SQL;
    if Filtro <> '' then
      Q.ParamByName('F').AsString := '%' + Filtro + '%';
    Q.Open;
    while not Q.EOF do
    begin
      if Row >= grdLista.RowCount then
        grdLista.RowCount := Row + 1;
      grdLista.Cells[0, Row] := Q.Fields[0].AsString;
      grdLista.Cells[1, Row] := Q.Fields[1].AsString;
      grdLista.Cells[2, Row] := FormatDateTime('dd/mm/yyyy', Q.Fields[2].AsDateTime);
      grdLista.Cells[3, Row] := Q.Fields[3].AsString;
      grdLista.Cells[4, Row] := Q.Fields[4].AsString;
      grdLista.Cells[5, Row] := Q.Fields[5].AsString;
      grdLista.Cells[6, Row] := Q.Fields[6].AsString;
      grdLista.Cells[7, Row] := FormatMoeda(Q.Fields[7].AsFloat);
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  AtualizarBotoes;
end;

procedure TfrmOS.LimparFormulario;
begin
  FRegistroID := 0;
  FClienteID  := 0;
  FVeiculoID  := 0;
  edtNumOS.Clear;
  cmbStatusOS.ItemIndex := 0;
  edtBoxPrisma.Clear;
  edtPlacaOS.Clear;
  edtModeloOS.Clear;
  edtKmOS.Text := '0';
  edtClienteOS.Clear;
  edtTelClienteOS.Clear;
  cmbMecanicoOS.ItemIndex := 0;
  dtpDataAberturaOS.Date := Date;
  dtpDataPrevisaoOS.Date := Date;
  mmDefeitoOS.Clear;
  mmServicoExecOS.Clear;
  mmObsOS.Clear;
  // Limpar grids de itens
  grdPecasOS.RowCount    := 2;
  grdPecasOS.Rows[1].Clear;
  grdServicosOS.RowCount := 2;
  grdServicosOS.Rows[1].Clear;
  edtTotalPecasOS.Text    := '0,00';
  edtTotalServicosOS.Text := '0,00';
  edtDescontoOS.Text      := '0,00';
  edtTotalGeralOS.Text    := '0,00';
  edtValorPagoOS.Text     := '0,00';
  edtSaldoOS.Text         := '0,00';
  cmbFormaPgtoOS.ItemIndex := 0;
end;

procedure TfrmOS.PreencherFormulario(ARow: Integer);
var
  ID, ColIdx: Integer;
  Q, QI: TSQLQuery;
  Row: Integer;
begin
  if ARow < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, ARow], 0);
  if ID <= 0 then Exit;

  FRegistroID := ID;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT os.*, c.nome_razao_social, c.celular as tel_cli, v.placa, ' +
      'v.modelo || '' '' || v.ano_modelo as modelo_ano ' +
      'FROM ordens_servico os ' +
      'LEFT JOIN clientes c ON c.id = os.cliente_id ' +
      'LEFT JOIN veiculos v ON v.id = os.veiculo_id ' +
      'WHERE os.id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    FClienteID := Q.FieldByName('cliente_id').AsInteger;
    FVeiculoID := Q.FieldByName('veiculo_id').AsInteger;
    edtNumOS.Text         := Q.FieldByName('numero').AsString;
    cmbStatusOS.ItemIndex := cmbStatusOS.Items.IndexOf(Q.FieldByName('status').AsString);
    if cmbStatusOS.ItemIndex < 0 then cmbStatusOS.ItemIndex := 0;
    edtBoxPrisma.Text     := Q.FieldByName('box_prisma').AsString;
    edtPlacaOS.Text       := Q.FieldByName('placa').AsString;
    edtModeloOS.Text      := Q.FieldByName('modelo_ano').AsString;
    edtKmOS.Text          := Q.FieldByName('km_entrada').AsString;
    edtClienteOS.Text     := Q.FieldByName('nome_razao_social').AsString;
    edtTelClienteOS.Text  := Q.FieldByName('tel_cli').AsString;
    dtpDataAberturaOS.Date := Q.FieldByName('data_abertura').AsDateTime;
    dtpDataPrevisaoOS.Date := Q.FieldByName('data_previsao').AsDateTime;
    mmDefeitoOS.Text      := Q.FieldByName('defeito_relatado').AsString;
    mmServicoExecOS.Text  := Q.FieldByName('servico_executado').AsString;
    mmObsOS.Text          := Q.FieldByName('observacoes').AsString;
    edtTotalPecasOS.Text    := FormatMoeda(Q.FieldByName('total_pecas').AsFloat);
    edtTotalServicosOS.Text := FormatMoeda(Q.FieldByName('total_servicos').AsFloat);
    edtDescontoOS.Text      := FormatMoeda(Q.FieldByName('desconto').AsFloat);
    edtTotalGeralOS.Text    := FormatMoeda(Q.FieldByName('total_geral').AsFloat);
    edtValorPagoOS.Text     := FormatMoeda(Q.FieldByName('valor_pago').AsFloat);
    cmbFormaPgtoOS.ItemIndex := cmbFormaPgtoOS.Items.IndexOf(Q.FieldByName('forma_pagamento').AsString);
    if cmbFormaPgtoOS.ItemIndex < 0 then cmbFormaPgtoOS.ItemIndex := 0;

    ColIdx := cmbMecanicoOS.Items.IndexOfObject(TObject(PtrInt(Q.FieldByName('colaborador_id').AsInteger)));
    if ColIdx >= 0 then cmbMecanicoOS.ItemIndex := ColIdx else cmbMecanicoOS.ItemIndex := 0;
  finally
    Q.Free;
  end;

  // Carregar peças da OS
  grdPecasOS.RowCount := 2;
  Row := 1;
  QI := TsigoDBConnection.Instancia.NovaQuery;
  try
    QI.SQL.Text :=
      'SELECT oi.id, p.codigo, oi.descricao, oi.quantidade, oi.valor_unitario, oi.total ' +
      'FROM os_itens_peca oi LEFT JOIN pecas p ON p.id = oi.peca_id ' +
      'WHERE oi.os_id = :ID';
    QI.ParamByName('ID').AsInteger := ID;
    QI.Open;
    while not QI.EOF do
    begin
      if Row >= grdPecasOS.RowCount then grdPecasOS.RowCount := Row + 1;
      grdPecasOS.Cells[0, Row] := QI.Fields[0].AsString;
      grdPecasOS.Cells[1, Row] := QI.Fields[1].AsString;
      grdPecasOS.Cells[2, Row] := QI.Fields[2].AsString;
      grdPecasOS.Cells[3, Row] := FormatFloat('0.##', QI.Fields[3].AsFloat);
      grdPecasOS.Cells[4, Row] := FormatMoeda(QI.Fields[4].AsFloat);
      grdPecasOS.Cells[5, Row] := FormatMoeda(QI.Fields[5].AsFloat);
      Inc(Row);
      QI.Next;
    end;
  finally
    QI.Free;
  end;

  // Carregar serviços da OS
  grdServicosOS.RowCount := 2;
  Row := 1;
  QI := TsigoDBConnection.Instancia.NovaQuery;
  try
    QI.SQL.Text :=
      'SELECT oi.id, oi.descricao, oi.quantidade, oi.valor_unitario, oi.total ' +
      'FROM os_itens_servico oi WHERE oi.os_id = :ID';
    QI.ParamByName('ID').AsInteger := ID;
    QI.Open;
    while not QI.EOF do
    begin
      if Row >= grdServicosOS.RowCount then grdServicosOS.RowCount := Row + 1;
      grdServicosOS.Cells[0, Row] := QI.Fields[0].AsString;
      grdServicosOS.Cells[1, Row] := QI.Fields[1].AsString;
      grdServicosOS.Cells[2, Row] := FormatFloat('0.##', QI.Fields[2].AsFloat);
      grdServicosOS.Cells[3, Row] := FormatMoeda(QI.Fields[3].AsFloat);
      grdServicosOS.Cells[4, Row] := FormatMoeda(QI.Fields[4].AsFloat);
      Inc(Row);
      QI.Next;
    end;
  finally
    QI.Free;
  end;

  RecalcularTotais;
end;

procedure TfrmOS.btnBuscarVeiculoOSClick(Sender: TObject);
var
  Q: TSQLQuery;
  Placa: string;
begin
  Placa := InputBox('Buscar Veículo', 'Placa:', '');
  if Trim(Placa) = '' then Exit;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT v.id, v.placa, v.marca || '' '' || v.modelo || '' '' || v.ano_modelo as modelo_ano, ' +
      'v.km_atual, v.cliente_id, c.nome_razao_social, c.celular ' +
      'FROM veiculos v LEFT JOIN clientes c ON c.id = v.cliente_id ' +
      'WHERE v.placa LIKE :P ORDER BY v.placa LIMIT 1';
    Q.ParamByName('P').AsString := '%' + Trim(Placa) + '%';
    Q.Open;
    if not Q.EOF then
    begin
      FVeiculoID := Q.Fields[0].AsInteger;
      FClienteID := Q.Fields[4].AsInteger;
      edtPlacaOS.Text      := Q.Fields[1].AsString;
      edtModeloOS.Text     := Q.Fields[2].AsString;
      edtKmOS.Text         := Q.Fields[3].AsString;
      edtClienteOS.Text    := Q.Fields[5].AsString;
      edtTelClienteOS.Text := Q.Fields[6].AsString;
    end else
      ShowMessage('Veículo não encontrado.');
  finally
    Q.Free;
  end;
end;

procedure TfrmOS.btnAddPecaOSClick(Sender: TObject);
var
  Q: TSQLQuery;
  Busca, Qtd, Vlr: string;
  Row: Integer;
  PecaID: Integer;
  QtdF, VlrF: Double;
begin
  Busca := InputBox('Adicionar Peça', 'Código ou Descrição:', '');
  if Trim(Busca) = '' then Exit;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT id, codigo, descricao, preco_vista FROM pecas WHERE ativo=1 AND ' +
      '(codigo LIKE :B OR descricao LIKE :B) ORDER BY descricao LIMIT 1';
    Q.ParamByName('B').AsString := '%' + Busca + '%';
    Q.Open;
    if Q.EOF then
    begin
      ShowMessage('Peça não encontrada.');
      Exit;
    end;

    PecaID := Q.Fields[0].AsInteger;
    Qtd    := InputBox('Quantidade', 'Quantidade:', '1');
    Vlr    := InputBox('Valor Unitário', 'Valor Unitário (R$):', FormatMoeda(Q.Fields[3].AsFloat));
  finally
    Q.Free;
  end;

  QtdF := StrToFloatDef(StringReplace(Qtd, ',', '.', [rfReplaceAll]), 1);
  VlrF := StrToFloatDef(StringReplace(Vlr, ',', '.', [rfReplaceAll]), 0);

  Row := grdPecasOS.RowCount;
  grdPecasOS.RowCount := Row + 1;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT codigo, descricao FROM pecas WHERE id = :ID';
    Q.ParamByName('ID').AsInteger := PecaID;
    Q.Open;
    grdPecasOS.Cells[0, Row] := '0';
    grdPecasOS.Cells[1, Row] := Q.Fields[0].AsString;
    grdPecasOS.Cells[2, Row] := Q.Fields[1].AsString;
  finally
    Q.Free;
  end;
  grdPecasOS.Cells[3, Row] := FormatFloat('0.##', QtdF);
  grdPecasOS.Cells[4, Row] := FormatMoeda(VlrF);
  grdPecasOS.Cells[5, Row] := FormatMoeda(QtdF * VlrF);
  RecalcularTotais;
end;

procedure TfrmOS.btnRemPecaOSClick(Sender: TObject);
begin
  if grdPecasOS.Row < 1 then Exit;
  grdPecasOS.DeleteRow(grdPecasOS.Row);
  if grdPecasOS.RowCount < 2 then grdPecasOS.RowCount := 2;
  RecalcularTotais;
end;

procedure TfrmOS.btnAddServOSClick(Sender: TObject);
var
  Q: TSQLQuery;
  Busca, Qtd, Vlr: string;
  Row: Integer;
  QtdF, VlrF: Double;
begin
  Busca := InputBox('Adicionar Serviço', 'Código ou Nome:', '');
  if Trim(Busca) = '' then Exit;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT id, nome, valor_padrao FROM servicos WHERE ativo=1 AND ' +
      '(nome LIKE :B OR codigo LIKE :B) ORDER BY nome LIMIT 1';
    Q.ParamByName('B').AsString := '%' + Busca + '%';
    Q.Open;
    if Q.EOF then
    begin
      ShowMessage('Serviço não encontrado.');
      Exit;
    end;
    Busca := Q.Fields[1].AsString;
    Vlr   := InputBox('Valor', 'Valor do Serviço (R$):', FormatMoeda(Q.Fields[2].AsFloat));
  finally
    Q.Free;
  end;

  QtdF := 1;
  VlrF := StrToFloatDef(StringReplace(Vlr, ',', '.', [rfReplaceAll]), 0);
  Qtd  := InputBox('Quantidade', 'Quantidade:', '1');
  QtdF := StrToFloatDef(StringReplace(Qtd, ',', '.', [rfReplaceAll]), 1);

  Row := grdServicosOS.RowCount;
  grdServicosOS.RowCount := Row + 1;
  grdServicosOS.Cells[0, Row] := '0';
  grdServicosOS.Cells[1, Row] := Busca;
  grdServicosOS.Cells[2, Row] := FormatFloat('0.##', QtdF);
  grdServicosOS.Cells[3, Row] := FormatMoeda(VlrF);
  grdServicosOS.Cells[4, Row] := FormatMoeda(QtdF * VlrF);
  RecalcularTotais;
end;

procedure TfrmOS.btnRemServOSClick(Sender: TObject);
begin
  if grdServicosOS.Row < 1 then Exit;
  grdServicosOS.DeleteRow(grdServicosOS.Row);
  if grdServicosOS.RowCount < 2 then grdServicosOS.RowCount := 2;
  RecalcularTotais;
end;

procedure TfrmOS.SalvarRegistro;
var
  OS: TsigoModelOS;
  ColaboradorID: Integer;
  I: Integer;
  Item: TsigoOSItemPeca;
  ItemS: TsigoOSItemServico;
  Q: TSQLQuery;
  Trans: TSQLTransaction;
  OSID: Integer;
begin
  if FVeiculoID <= 0 then
    raise Exception.Create('Selecione um veículo via busca de placa.');
  if FClienteID <= 0 then
    raise Exception.Create('Cliente não identificado. Busque o veículo primeiro.');

  ColaboradorID := PtrInt(cmbMecanicoOS.Items.Objects[cmbMecanicoOS.ItemIndex]);

  OS := TsigoModelOS.Create;
  try
    OS.ID             := FRegistroID;
    OS.ClienteID      := FClienteID;
    OS.VeiculoID      := FVeiculoID;
    OS.ColaboradorID  := ColaboradorID;
    OS.Status         := cmbStatusOS.Text;
    OS.BoxPrisma      := Trim(edtBoxPrisma.Text);
    OS.DataAbertura   := dtpDataAberturaOS.Date;
    OS.DataPrevisao   := dtpDataPrevisaoOS.Date;
    OS.KmEntrada      := StrToIntDef(edtKmOS.Text, 0);
    OS.DefeitoRelatado   := Trim(mmDefeitoOS.Text);
    OS.ServicoExecutado  := Trim(mmServicoExecOS.Text);
    OS.Observacoes       := Trim(mmObsOS.Text);
    OS.Desconto          := StrToFloatDef(StringReplace(edtDescontoOS.Text, ',', '.', [rfReplaceAll]), 0);
    OS.FormaPagamento    := cmbFormaPgtoOS.Text;
    OS.ValorPago         := StrToFloatDef(StringReplace(edtValorPagoOS.Text, ',', '.', [rfReplaceAll]), 0);

    // Coletar itens do grid de peças
    for I := 1 to grdPecasOS.RowCount - 1 do
    begin
      if Trim(grdPecasOS.Cells[2, I]) = '' then Continue;
      Item := TsigoOSItemPeca.Create;
      Item.ID := StrToIntDef(grdPecasOS.Cells[0, I], 0);
      Item.Descricao       := grdPecasOS.Cells[2, I];
      Item.Quantidade      := StrToFloatDef(StringReplace(grdPecasOS.Cells[3, I], ',', '.', [rfReplaceAll]), 0);
      Item.ValorUnitario   := StrToFloatDef(StringReplace(grdPecasOS.Cells[4, I], ',', '.', [rfReplaceAll]), 0);
      Item.Total           := StrToFloatDef(StringReplace(grdPecasOS.Cells[5, I], ',', '.', [rfReplaceAll]), 0);
      OS.Itens.Add(Item);
    end;

    // Coletar itens do grid de serviços
    for I := 1 to grdServicosOS.RowCount - 1 do
    begin
      if Trim(grdServicosOS.Cells[1, I]) = '' then Continue;
      ItemS := TsigoOSItemServico.Create;
      ItemS.ID := StrToIntDef(grdServicosOS.Cells[0, I], 0);
      ItemS.Descricao     := grdServicosOS.Cells[1, I];
      ItemS.Quantidade    := StrToFloatDef(StringReplace(grdServicosOS.Cells[2, I], ',', '.', [rfReplaceAll]), 0);
      ItemS.ValorUnitario := StrToFloatDef(StringReplace(grdServicosOS.Cells[3, I], ',', '.', [rfReplaceAll]), 0);
      ItemS.Total         := StrToFloatDef(StringReplace(grdServicosOS.Cells[4, I], ',', '.', [rfReplaceAll]), 0);
      OS.Servicos.Add(ItemS);
    end;

    if FRegistroID = 0 then
      FCtrl.Salvar(OS)
    else
      FCtrl.Atualizar(OS);
  finally
    OS.Free;
  end;
end;

procedure TfrmOS.ExcluirRegistro;
var
  ID: Integer;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID > 0 then
    FCtrl.Excluir(ID);
end;

end.
