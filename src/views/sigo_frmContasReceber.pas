unit sigo_frmContasReceber;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, DateTimePicker, LCLType,
  sigo_frmBase, sigo_ModelFinanceiro, sigo_CtrlFinanceiro, sigo_Utils;

type
  { TfrmContasReceber }
  TfrmContasReceber = class(TfrmBase)
    pnlFiltrosCR: TPanel;
    lblFiltroStatusCR: TLabel;
    cmbFiltroStatusCR: TComboBox;
    lblFiltroFormaCR: TLabel;
    cmbFiltroFormaCR: TComboBox;
    lblFiltroDeDtCR: TLabel;
    dtpFiltroDeCR: TDateTimePicker;
    lblFiltroAteDtCR: TLabel;
    dtpFiltroAteCR: TDateTimePicker;
    btnFiltrarCR: TBitBtn;
    grpDadosCR: TGroupBox;
    lblClienteCR: TLabel;
    edtClienteCR: TEdit;
    btnBuscarClienteCR: TBitBtn;
    lblDescricaoCR: TLabel;
    edtDescricaoCR: TEdit;
    lblValorCR: TLabel;
    edtValorCR: TEdit;
    lblDataEmissaoCR: TLabel;
    dtpDataEmissaoCR: TDateTimePicker;
    lblDataVencCR: TLabel;
    dtpDataVencCR: TDateTimePicker;
    lblDataPagCR: TLabel;
    dtpDataPagCR: TDateTimePicker;
    lblStatusCR: TLabel;
    cmbStatusCR: TComboBox;
    lblFormaPgtoCR: TLabel;
    cmbFormaPgtoCR: TComboBox;
    lblValorPagoCR: TLabel;
    edtValorPagoCR: TEdit;
    lblObsCR: TLabel;
    mmObsCR: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnFiltrarCRClick(Sender: TObject);
    procedure btnBuscarClienteCRClick(Sender: TObject);
  protected
    FCtrl: TsigoCtrlFinanceiro;
    FClienteID: Integer;
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    function ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor; override;
  public
    destructor Destroy; override;
  end;

var
  frmContasReceber: TfrmContasReceber;

implementation

{$R *.lfm}

uses
  sqldb, DateUtils, sigo_DBConnection;

{ TfrmContasReceber }

procedure TfrmContasReceber.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlFinanceiro.Create;
  FClienteID := 0;

  dtpFiltroDeCR.Kind := dtkDate;
  dtpFiltroAteCR.Kind := dtkDate;
  dtpFiltroDeCR.Date := StartOfTheMonth(Now);
  dtpFiltroAteCR.Date := EndOfTheMonth(Now);

  dtpDataEmissaoCR.Kind := dtkDate;
  dtpDataVencCR.Kind    := dtkDate;
  dtpDataPagCR.Kind     := dtkDate;
  dtpDataEmissaoCR.Date := Date;
  dtpDataVencCR.Date    := Date;
  dtpDataPagCR.Date     := Date;

  cmbFiltroStatusCR.Items.Text := 'TODAS' + LineEnding + 'ABERTA' + LineEnding +
    'PARCIAL' + LineEnding + 'PAGA' + LineEnding + 'VENCIDA' + LineEnding + 'CANCELADA';
  cmbFiltroStatusCR.ItemIndex := 0;

  cmbStatusCR.Items.Text := 'ABERTA' + LineEnding + 'PARCIAL' + LineEnding +
    'PAGA' + LineEnding + 'CANCELADA';
  cmbStatusCR.ItemIndex := 0;

  cmbFiltroFormaCR.Items.Clear;
  cmbFiltroFormaCR.Items.Add('TODAS');
  cmbFiltroFormaCR.Items.Add('DINHEIRO');
  cmbFiltroFormaCR.Items.Add('PIX');
  cmbFiltroFormaCR.Items.Add('CARTÃO DÉBITO');
  cmbFiltroFormaCR.Items.Add('CARTÃO CRÉDITO');
  cmbFiltroFormaCR.Items.Add('BOLETO');
  cmbFiltroFormaCR.Items.Add('TRANSFERÊNCIA');
  cmbFiltroFormaCR.Items.Add('A PRAZO');
  cmbFiltroFormaCR.ItemIndex := 0;

  cmbFormaPgtoCR.Items.Clear;
  cmbFormaPgtoCR.Items.Add('DINHEIRO');
  cmbFormaPgtoCR.Items.Add('PIX');
  cmbFormaPgtoCR.Items.Add('CARTÃO DÉBITO');
  cmbFormaPgtoCR.Items.Add('CARTÃO CRÉDITO');
  cmbFormaPgtoCR.Items.Add('BOLETO');
  cmbFormaPgtoCR.Items.Add('TRANSFERÊNCIA');
  cmbFormaPgtoCR.Items.Add('A PRAZO');
  cmbFormaPgtoCR.ItemIndex := 0;

  btnFiltrarCR.OnClick := @btnFiltrarCRClick;
  btnBuscarClienteCR.OnClick := @btnBuscarClienteCRClick;
  inherited FormCreate(Sender);
end;

destructor TfrmContasReceber.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

function TfrmContasReceber.ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor;
var
  Status: string;
  DtVenc: TDateTime;
  DiasRestantes: Integer;
begin
  Result := inherited ObterCorLinha(AGrid, ARow);
  if (ARow > 0) and (AGrid.ColCount > 5) then
  begin
    Status := UpperCase(AGrid.Cells[5, ARow]);
    if (Status = 'VENCIDA') or (Status = 'ABERTA') then
    begin
      // Verifica se realmente está vencida (data no grid col 4)
      DtVenc := StrToDateDef(AGrid.Cells[4, ARow], 0);
      if (DtVenc > 0) and (DtVenc < Date) and (Status = 'ABERTA') then
        Result := C_COR_LINHA_CRITICA
      else if (DtVenc > 0) and (DtVenc <= Date + 3) and (DtVenc >= Date) then
        Result := C_COR_LINHA_AVISO;
    end else if Status = 'VENCIDA' then
      Result := C_COR_LINHA_CRITICA
    else if Status = 'PARCIAL' then
      Result := $00FFE4B5
    else if (Status = 'PAGA') or (Status = 'CANCELADA') then
      Result := C_COR_LINHA_IMPAR;
  end;
end;

procedure TfrmContasReceber.btnFiltrarCRClick(Sender: TObject);
begin
  CarregarGrid;
end;

procedure TfrmContasReceber.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL, StatusFiltro, FormaFiltro: string;
  Row: Integer;
begin
  grdLista.ColCount := 8;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Cliente';
  grdLista.Cells[2, 0] := 'Descrição';
  grdLista.Cells[3, 0] := 'Emissão';
  grdLista.Cells[4, 0] := 'Vencimento';
  grdLista.Cells[5, 0] := 'Status';
  grdLista.Cells[6, 0] := 'Valor';
  grdLista.Cells[7, 0] := 'Pago';
  grdLista.ColWidths[0] := 40;
  grdLista.ColWidths[1] := 160;
  grdLista.ColWidths[2] := 160;
  grdLista.ColWidths[3] := 75;
  grdLista.ColWidths[4] := 75;
  grdLista.ColWidths[5] := 70;
  grdLista.ColWidths[6] := 75;
  grdLista.ColWidths[7] := 75;

  Filtro       := Trim(edtBusca.Text);
  StatusFiltro := cmbFiltroStatusCR.Text;
  FormaFiltro  := cmbFiltroFormaCR.Text;

  SQL :=
    'SELECT cr.id, c.nome_razao_social, cr.descricao, cr.data_emissao, ' +
    'cr.data_vencimento, cr.status, cr.valor, cr.valor_pago ' +
    'FROM contas_receber cr LEFT JOIN clientes c ON c.id = cr.cliente_id ' +
    'WHERE cr.data_vencimento BETWEEN date(:DE) AND date(:ATE) ';

  if (StatusFiltro <> '') and (StatusFiltro <> 'TODAS') then
    SQL := SQL + 'AND cr.status = :ST ';
  if (FormaFiltro <> '') and (FormaFiltro <> 'TODAS') then
    SQL := SQL + 'AND cr.forma_pagamento = :FP ';
  if Filtro <> '' then
    SQL := SQL + 'AND (c.nome_razao_social LIKE :F OR cr.descricao LIKE :F) ';
  SQL := SQL + 'ORDER BY cr.data_vencimento';

  grdLista.RowCount := 2;
  Row := 1;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := SQL;
    Q.ParamByName('DE').AsDate  := dtpFiltroDeCR.Date;
    Q.ParamByName('ATE').AsDate := dtpFiltroAteCR.Date;
    if (StatusFiltro <> '') and (StatusFiltro <> 'TODAS') then
      Q.ParamByName('ST').AsString := StatusFiltro;
    if (FormaFiltro <> '') and (FormaFiltro <> 'TODAS') then
      Q.ParamByName('FP').AsString := FormaFiltro;
    if Filtro <> '' then
      Q.ParamByName('F').AsString := '%' + Filtro + '%';
    Q.Open;
    while not Q.EOF do
    begin
      if Row >= grdLista.RowCount then grdLista.RowCount := Row + 1;
      grdLista.Cells[0, Row] := Q.Fields[0].AsString;
      grdLista.Cells[1, Row] := Q.Fields[1].AsString;
      grdLista.Cells[2, Row] := Q.Fields[2].AsString;
      grdLista.Cells[3, Row] := FormatDateTime('dd/mm/yyyy', Q.Fields[3].AsDateTime);
      grdLista.Cells[4, Row] := FormatDateTime('dd/mm/yyyy', Q.Fields[4].AsDateTime);
      grdLista.Cells[5, Row] := Q.Fields[5].AsString;
      grdLista.Cells[6, Row] := FormatMoeda(Q.Fields[6].AsFloat);
      grdLista.Cells[7, Row] := FormatMoeda(Q.Fields[7].AsFloat);
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  AtualizarBotoes;
end;

procedure TfrmContasReceber.LimparFormulario;
begin
  FRegistroID := 0;
  FClienteID  := 0;
  edtClienteCR.Clear;
  edtDescricaoCR.Clear;
  edtValorCR.Text      := '0,00';
  edtValorPagoCR.Text  := '0,00';
  dtpDataEmissaoCR.Date := Date;
  dtpDataVencCR.Date    := Date;
  dtpDataPagCR.Date     := Date;
  cmbStatusCR.ItemIndex := 0;
  cmbFormaPgtoCR.ItemIndex := 0;
  mmObsCR.Clear;
end;

procedure TfrmContasReceber.PreencherFormulario(ARow: Integer);
var
  ID: Integer;
  Q: TSQLQuery;
begin
  if ARow < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, ARow], 0);
  if ID <= 0 then Exit;

  FRegistroID := ID;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT cr.*, c.nome_razao_social FROM contas_receber cr ' +
      'LEFT JOIN clientes c ON c.id = cr.cliente_id WHERE cr.id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    FClienteID := Q.FieldByName('cliente_id').AsInteger;
    edtClienteCR.Text  := Q.FieldByName('nome_razao_social').AsString;
    edtDescricaoCR.Text := Q.FieldByName('descricao').AsString;
    edtValorCR.Text    := FormatMoeda(Q.FieldByName('valor').AsFloat);
    edtValorPagoCR.Text := FormatMoeda(Q.FieldByName('valor_pago').AsFloat);
    dtpDataEmissaoCR.Date := Q.FieldByName('data_emissao').AsDateTime;
    dtpDataVencCR.Date    := Q.FieldByName('data_vencimento').AsDateTime;
    dtpDataPagCR.Date     := Q.FieldByName('data_pagamento').AsDateTime;
    cmbStatusCR.ItemIndex := cmbStatusCR.Items.IndexOf(Q.FieldByName('status').AsString);
    if cmbStatusCR.ItemIndex < 0 then cmbStatusCR.ItemIndex := 0;
    cmbFormaPgtoCR.ItemIndex := cmbFormaPgtoCR.Items.IndexOf(Q.FieldByName('forma_pagamento').AsString);
    if cmbFormaPgtoCR.ItemIndex < 0 then cmbFormaPgtoCR.ItemIndex := 0;
    mmObsCR.Text := Q.FieldByName('observacoes').AsString;
  finally
    Q.Free;
  end;
end;

procedure TfrmContasReceber.btnBuscarClienteCRClick(Sender: TObject);
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
      edtClienteCR.Text := Q.Fields[1].AsString;
    end else
      ShowMessage('Cliente não encontrado.');
  finally
    Q.Free;
  end;
end;

procedure TfrmContasReceber.SalvarRegistro;
var
  CR: TsigoModelContaReceber;
begin
  if Trim(edtDescricaoCR.Text) = '' then
    raise Exception.Create('A descrição é obrigatória.');

  CR := TsigoModelContaReceber.Create;
  try
    CR.ID           := FRegistroID;
    CR.ClienteID    := FClienteID;
    CR.Descricao    := Trim(edtDescricaoCR.Text);
    CR.Valor        := StrToFloatDef(StringReplace(edtValorCR.Text, ',', '.', [rfReplaceAll]), 0);
    CR.ValorPago    := StrToFloatDef(StringReplace(edtValorPagoCR.Text, ',', '.', [rfReplaceAll]), 0);
    CR.DataEmissao    := dtpDataEmissaoCR.Date;
    CR.DataVencimento := dtpDataVencCR.Date;
    CR.DataPagamento  := dtpDataPagCR.Date;
    CR.Status         := cmbStatusCR.Text;
    CR.FormaPagamento := cmbFormaPgtoCR.Text;
    CR.Observacoes    := Trim(mmObsCR.Text);

    if FRegistroID = 0 then
      FCtrl.SalvarContaReceber(CR)
    else
      FCtrl.AtualizarContaReceber(CR);
  finally
    CR.Free;
  end;
end;

procedure TfrmContasReceber.ExcluirRegistro;
var
  ID: Integer;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID > 0 then
    FCtrl.ExcluirContaReceber(ID);
end;

end.
