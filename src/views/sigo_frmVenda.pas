unit sigo_frmVenda;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, DateTimePicker, LCLType,
  sigo_frmBase, sigo_ModelVenda, sigo_CtrlVenda, sigo_Utils;

type
  { TfrmVenda }
  TfrmVenda = class(TfrmBase)
    grpCabecVenda: TGroupBox;
    lblNumComanda: TLabel;
    edtNumComanda: TEdit;
    lblDataVenda: TLabel;
    dtpDataVenda: TDateTimePicker;
    lblStatusVenda: TLabel;
    cmbStatusVenda: TComboBox;
    lblClienteVenda: TLabel;
    edtClienteVenda: TEdit;
    btnBuscarClienteVenda: TBitBtn;
    lblAtendenteVenda: TLabel;
    cmbAtendenteVenda: TComboBox;
    grpItensVenda: TGroupBox;
    pnlBotoesItensVenda: TPanel;
    btnAddItemVenda: TBitBtn;
    btnRemItemVenda: TBitBtn;
    grdItensVenda: TStringGrid;
    grpTotaisVenda: TGroupBox;
    lblSubtotalVenda: TLabel;
    edtSubtotalVenda: TEdit;
    lblDescontoVenda: TLabel;
    edtDescontoVenda: TEdit;
    lblTotalVenda: TLabel;
    edtTotalVenda: TEdit;
    lblFormaPgtoVenda: TLabel;
    cmbFormaPgtoVenda: TComboBox;
    lblObsVenda: TLabel;
    mmObsVenda: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarClienteVendaClick(Sender: TObject);
    procedure btnAddItemVendaClick(Sender: TObject);
    procedure btnRemItemVendaClick(Sender: TObject);
    procedure edtDescontoVendaExit(Sender: TObject);
  protected
    FCtrl: TsigoCtrlVenda;
    FClienteID: Integer;
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure CarregarAtendentes;
    procedure RecalcularTotalVenda;
    function ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor; override;
  public
    destructor Destroy; override;
  end;

var
  frmVenda: TfrmVenda;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmVenda }

procedure TfrmVenda.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlVenda.Create;
  FClienteID := 0;

  dtpDataVenda.Kind := dtkDate;
  dtpDataVenda.Date := Date;

  cmbStatusVenda.Items.Clear;
  cmbStatusVenda.Items.Add('ABERTA');
  cmbStatusVenda.Items.Add('FINALIZADA');
  cmbStatusVenda.Items.Add('CANCELADA');
  cmbStatusVenda.ItemIndex := 0;

  cmbFormaPgtoVenda.Items.Clear;
  cmbFormaPgtoVenda.Items.Add('DINHEIRO');
  cmbFormaPgtoVenda.Items.Add('PIX');
  cmbFormaPgtoVenda.Items.Add('CARTÃO DÉBITO');
  cmbFormaPgtoVenda.Items.Add('CARTÃO CRÉDITO');
  cmbFormaPgtoVenda.Items.Add('BOLETO');
  cmbFormaPgtoVenda.Items.Add('A PRAZO');
  cmbFormaPgtoVenda.ItemIndex := 0;

  edtNumComanda.ReadOnly := True;
  edtNumComanda.Color    := $00E8E8E8;
  edtSubtotalVenda.ReadOnly := True;
  edtTotalVenda.ReadOnly    := True;
  edtSubtotalVenda.Color    := $00E8E8E8;
  edtTotalVenda.Color       := $00E8E8E8;
  edtTotalVenda.Font.Style  := [fsBold];
  edtTotalVenda.Font.Size   := 12;

  // Grid de itens
  grdItensVenda.ColCount := 6;
  grdItensVenda.RowCount := 2;
  grdItensVenda.FixedRows := 1;
  grdItensVenda.FixedCols := 0;
  grdItensVenda.DefaultRowHeight := 22;
  grdItensVenda.Options := grdItensVenda.Options + [goEditing];
  grdItensVenda.Cells[0, 0] := 'ID';
  grdItensVenda.Cells[1, 0] := 'Código';
  grdItensVenda.Cells[2, 0] := 'Descrição';
  grdItensVenda.Cells[3, 0] := 'Qtd';
  grdItensVenda.Cells[4, 0] := 'Vlr Unit.';
  grdItensVenda.Cells[5, 0] := 'Total';
  grdItensVenda.ColWidths[0] := 0;
  grdItensVenda.ColWidths[1] := 70;
  grdItensVenda.ColWidths[2] := 220;
  grdItensVenda.ColWidths[3] := 50;
  grdItensVenda.ColWidths[4] := 75;
  grdItensVenda.ColWidths[5] := 85;

  CarregarAtendentes;
  btnBuscarClienteVenda.OnClick := @btnBuscarClienteVendaClick;
  btnAddItemVenda.OnClick := @btnAddItemVendaClick;
  btnRemItemVenda.OnClick := @btnRemItemVendaClick;
  edtDescontoVenda.OnExit := @edtDescontoVendaExit;
  inherited FormCreate(Sender);
end;

destructor TfrmVenda.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

procedure TfrmVenda.CarregarAtendentes;
var
  Q: TSQLQuery;
begin
  cmbAtendenteVenda.Items.Clear;
  cmbAtendenteVenda.Items.AddObject('(Nenhum)', TObject(PtrInt(0)));
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT id, nome FROM colaboradores WHERE ativo = 1 ORDER BY nome';
    Q.Open;
    while not Q.EOF do
    begin
      cmbAtendenteVenda.Items.AddObject(Q.Fields[1].AsString, TObject(PtrInt(Q.Fields[0].AsInteger)));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  cmbAtendenteVenda.ItemIndex := 0;
end;

function TfrmVenda.ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor;
var
  Status: string;
begin
  Result := inherited ObterCorLinha(AGrid, ARow);
  if (ARow > 0) and (AGrid.ColCount > 4) then
  begin
    Status := UpperCase(AGrid.Cells[4, ARow]);
    if Status = 'CANCELADA' then
      Result := C_COR_LINHA_CRITICA
    else if Status = 'FINALIZADA' then
      Result := C_COR_LINHA_OK;
  end;
end;

procedure TfrmVenda.RecalcularTotalVenda;
var
  Sub, Desc, Total: Double;
  I: Integer;
begin
  Sub := 0;
  for I := 1 to grdItensVenda.RowCount - 1 do
    Sub := Sub + StrToFloatDef(StringReplace(grdItensVenda.Cells[5, I], ',', '.', [rfReplaceAll]), 0);

  Desc  := StrToFloatDef(StringReplace(edtDescontoVenda.Text, ',', '.', [rfReplaceAll]), 0);
  Total := Sub - Desc;
  if Total < 0 then Total := 0;

  edtSubtotalVenda.Text := FormatMoeda(Sub);
  edtTotalVenda.Text    := FormatMoeda(Total);
end;

procedure TfrmVenda.edtDescontoVendaExit(Sender: TObject);
begin
  RecalcularTotalVenda;
end;

procedure TfrmVenda.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL: string;
  Row: Integer;
begin
  grdLista.ColCount := 7;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Comanda';
  grdLista.Cells[2, 0] := 'Data';
  grdLista.Cells[3, 0] := 'Cliente';
  grdLista.Cells[4, 0] := 'Status';
  grdLista.Cells[5, 0] := 'Forma Pgto';
  grdLista.Cells[6, 0] := 'Total';
  grdLista.ColWidths[0] := 40;
  grdLista.ColWidths[1] := 70;
  grdLista.ColWidths[2] := 80;
  grdLista.ColWidths[3] := 180;
  grdLista.ColWidths[4] := 80;
  grdLista.ColWidths[5] := 110;
  grdLista.ColWidths[6] := 80;

  Filtro := Trim(edtBusca.Text);
  SQL :=
    'SELECT v.id, v.numero_comanda, v.data_venda, c.nome_razao_social, ' +
    'v.status, v.forma_pagamento, v.total ' +
    'FROM vendas v LEFT JOIN clientes c ON c.id = v.cliente_id ' +
    'WHERE 1=1 ';
  if Filtro <> '' then
    SQL := SQL + 'AND (v.numero_comanda LIKE :F OR c.nome_razao_social LIKE :F) ';
  SQL := SQL + 'ORDER BY v.data_venda DESC';

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
      grdLista.Cells[6, Row] := FormatMoeda(Q.Fields[6].AsFloat);
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  AtualizarBotoes;
end;

procedure TfrmVenda.LimparFormulario;
begin
  FRegistroID := 0;
  FClienteID  := 0;
  edtNumComanda.Clear;
  dtpDataVenda.Date := Date;
  cmbStatusVenda.ItemIndex := 0;
  edtClienteVenda.Clear;
  cmbAtendenteVenda.ItemIndex := 0;
  grdItensVenda.RowCount := 2;
  grdItensVenda.Rows[1].Clear;
  edtDescontoVenda.Text  := '0,00';
  edtSubtotalVenda.Text  := '0,00';
  edtTotalVenda.Text     := '0,00';
  cmbFormaPgtoVenda.ItemIndex := 0;
  mmObsVenda.Clear;
end;

procedure TfrmVenda.PreencherFormulario(ARow: Integer);
var
  ID, ColIdx: Integer;
  Q: TSQLQuery;
  Row: Integer;
begin
  if ARow < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, ARow], 0);
  if ID <= 0 then Exit;

  FRegistroID := ID;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT v.*, c.nome_razao_social FROM vendas v ' +
      'LEFT JOIN clientes c ON c.id = v.cliente_id WHERE v.id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    FClienteID := Q.FieldByName('cliente_id').AsInteger;
    edtNumComanda.Text   := Q.FieldByName('numero_comanda').AsString;
    dtpDataVenda.Date    := Q.FieldByName('data_venda').AsDateTime;
    cmbStatusVenda.ItemIndex := cmbStatusVenda.Items.IndexOf(Q.FieldByName('status').AsString);
    if cmbStatusVenda.ItemIndex < 0 then cmbStatusVenda.ItemIndex := 0;
    edtClienteVenda.Text := Q.FieldByName('nome_razao_social').AsString;
    edtDescontoVenda.Text := FormatMoeda(Q.FieldByName('desconto').AsFloat);
    cmbFormaPgtoVenda.ItemIndex := cmbFormaPgtoVenda.Items.IndexOf(Q.FieldByName('forma_pagamento').AsString);
    if cmbFormaPgtoVenda.ItemIndex < 0 then cmbFormaPgtoVenda.ItemIndex := 0;
    mmObsVenda.Text := Q.FieldByName('observacoes').AsString;

    ColIdx := cmbAtendenteVenda.Items.IndexOfObject(TObject(PtrInt(Q.FieldByName('atendente_id').AsInteger)));
    if ColIdx >= 0 then cmbAtendenteVenda.ItemIndex := ColIdx else cmbAtendenteVenda.ItemIndex := 0;
  finally
    Q.Free;
  end;

  // Carregar itens
  grdItensVenda.RowCount := 2;
  Row := 1;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT vi.id, p.codigo, vi.descricao, vi.quantidade, vi.valor_unitario, vi.total ' +
      'FROM venda_itens vi LEFT JOIN pecas p ON p.id = vi.peca_id ' +
      'WHERE vi.venda_id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    while not Q.EOF do
    begin
      if Row >= grdItensVenda.RowCount then grdItensVenda.RowCount := Row + 1;
      grdItensVenda.Cells[0, Row] := Q.Fields[0].AsString;
      grdItensVenda.Cells[1, Row] := Q.Fields[1].AsString;
      grdItensVenda.Cells[2, Row] := Q.Fields[2].AsString;
      grdItensVenda.Cells[3, Row] := FormatFloat('0.##', Q.Fields[3].AsFloat);
      grdItensVenda.Cells[4, Row] := FormatMoeda(Q.Fields[4].AsFloat);
      grdItensVenda.Cells[5, Row] := FormatMoeda(Q.Fields[5].AsFloat);
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  RecalcularTotalVenda;
end;

procedure TfrmVenda.btnBuscarClienteVendaClick(Sender: TObject);
var
  Q: TSQLQuery;
  Busca: string;
begin
  Busca := InputBox('Buscar Cliente', 'Nome ou CPF/CNPJ:', '');
  if Trim(Busca) = '' then Exit;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT id, nome_razao_social FROM clientes WHERE ativo=1 AND ' +
      '(nome_razao_social LIKE :B OR cpf_cnpj LIKE :B) ORDER BY nome_razao_social LIMIT 1';
    Q.ParamByName('B').AsString := '%' + Busca + '%';
    Q.Open;
    if not Q.EOF then
    begin
      FClienteID := Q.Fields[0].AsInteger;
      edtClienteVenda.Text := Q.Fields[1].AsString;
    end else
      ShowMessage('Cliente não encontrado.');
  finally
    Q.Free;
  end;
end;

procedure TfrmVenda.btnAddItemVendaClick(Sender: TObject);
var
  Q: TSQLQuery;
  Busca, Qtd, Vlr: string;
  Row: Integer;
  PecaID: Integer;
  QtdF, VlrF: Double;
begin
  Busca := InputBox('Adicionar Item', 'Código ou Descrição:', '');
  if Trim(Busca) = '' then Exit;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT id, codigo, descricao, preco_vista FROM pecas WHERE ativo=1 AND ' +
      '(codigo LIKE :B OR descricao LIKE :B OR codigo_barras LIKE :B) ORDER BY descricao LIMIT 1';
    Q.ParamByName('B').AsString := '%' + Busca + '%';
    Q.Open;
    if Q.EOF then
    begin
      ShowMessage('Item não encontrado.');
      Exit;
    end;
    PecaID := Q.Fields[0].AsInteger;
    Qtd := InputBox('Quantidade', 'Quantidade:', '1');
    Vlr := InputBox('Valor Unitário', 'Valor (R$):', FormatMoeda(Q.Fields[3].AsFloat));
    Row := grdItensVenda.RowCount;
    grdItensVenda.RowCount := Row + 1;
    grdItensVenda.Cells[0, Row] := '0';
    grdItensVenda.Cells[1, Row] := Q.Fields[1].AsString;
    grdItensVenda.Cells[2, Row] := Q.Fields[2].AsString;
  finally
    Q.Free;
  end;
  QtdF := StrToFloatDef(StringReplace(Qtd, ',', '.', [rfReplaceAll]), 1);
  VlrF := StrToFloatDef(StringReplace(Vlr, ',', '.', [rfReplaceAll]), 0);
  grdItensVenda.Cells[3, Row] := FormatFloat('0.##', QtdF);
  grdItensVenda.Cells[4, Row] := FormatMoeda(VlrF);
  grdItensVenda.Cells[5, Row] := FormatMoeda(QtdF * VlrF);
  RecalcularTotalVenda;
end;

procedure TfrmVenda.btnRemItemVendaClick(Sender: TObject);
begin
  if grdItensVenda.Row < 1 then Exit;
  grdItensVenda.DeleteRow(grdItensVenda.Row);
  if grdItensVenda.RowCount < 2 then grdItensVenda.RowCount := 2;
  RecalcularTotalVenda;
end;

procedure TfrmVenda.SalvarRegistro;
var
  V: TsigoModelVenda;
  AtendenteID, I: Integer;
  Item: TVendaItem;
begin
  if FClienteID <= 0 then
    raise Exception.Create('Selecione um cliente.');

  AtendenteID := PtrInt(cmbAtendenteVenda.Items.Objects[cmbAtendenteVenda.ItemIndex]);

  V := TsigoModelVenda.Create;
  try
    V.ID            := FRegistroID;
    V.ClienteID     := FClienteID;
    V.AtendenteID   := AtendenteID;
    V.DataVenda     := dtpDataVenda.Date;
    V.Status        := cmbStatusVenda.Text;
    V.Desconto      := StrToFloatDef(StringReplace(edtDescontoVenda.Text, ',', '.', [rfReplaceAll]), 0);
    V.FormaPagamento := cmbFormaPgtoVenda.Text;
    V.Observacoes   := Trim(mmObsVenda.Text);

    for I := 1 to grdItensVenda.RowCount - 1 do
    begin
      if Trim(grdItensVenda.Cells[2, I]) = '' then Continue;
      Item := TVendaItem.Create;
      Item.ID           := StrToIntDef(grdItensVenda.Cells[0, I], 0);
      Item.Descricao    := grdItensVenda.Cells[2, I];
      Item.Quantidade   := StrToFloatDef(StringReplace(grdItensVenda.Cells[3, I], ',', '.', [rfReplaceAll]), 0);
      Item.ValorUnitario := StrToFloatDef(StringReplace(grdItensVenda.Cells[4, I], ',', '.', [rfReplaceAll]), 0);
      Item.Total        := StrToFloatDef(StringReplace(grdItensVenda.Cells[5, I], ',', '.', [rfReplaceAll]), 0);
      V.Itens.Add(Item);
    end;

    if FRegistroID = 0 then
      FCtrl.Salvar(V)
    else
      FCtrl.Atualizar(V);
  finally
    V.Free;
  end;
end;

procedure TfrmVenda.ExcluirRegistro;
var
  ID: Integer;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID > 0 then
    FCtrl.Excluir(ID);
end;

end.
