unit sigo_frmContasPagar;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, DateTimePicker, LCLType,
  sigo_frmBase, sigo_ModelFinanceiro, sigo_CtrlFinanceiro, sigo_Utils;

type
  { TfrmContasPagar }
  TfrmContasPagar = class(TfrmBase)
    pnlFiltrosCP: TPanel;
    lblFiltroStatusCP: TLabel;
    cmbFiltroStatusCP: TComboBox;
    lblFiltroFormaCP: TLabel;
    cmbFiltroFormaCP: TComboBox;
    lblFiltroDeDtCP: TLabel;
    dtpFiltroDe: TDateTimePicker;
    lblFiltroAteDtCP: TLabel;
    dtpFiltroAte: TDateTimePicker;
    btnFiltrarCP: TBitBtn;
    grpDadosCP: TGroupBox;
    lblFornecedorCP: TLabel;
    edtFornecedorCP: TEdit;
    btnBuscarFornecCP: TBitBtn;
    lblDescricaoCP: TLabel;
    edtDescricaoCP: TEdit;
    lblValorCP: TLabel;
    edtValorCP: TEdit;
    lblDataEmissaoCP: TLabel;
    dtpDataEmissaoCP: TDateTimePicker;
    lblDataVencCP: TLabel;
    dtpDataVencCP: TDateTimePicker;
    lblDataPagCP: TLabel;
    dtpDataPagCP: TDateTimePicker;
    lblStatusCP: TLabel;
    cmbStatusCP: TComboBox;
    lblFormaPgtoCP: TLabel;
    cmbFormaPgtoCP: TComboBox;
    lblValorPagoCP: TLabel;
    edtValorPagoCP: TEdit;
    lblObsCP: TLabel;
    mmObsCP: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnFiltrarCPClick(Sender: TObject);
    procedure btnBuscarFornecCPClick(Sender: TObject);
  protected
    FCtrl: TsigoCtrlFinanceiro;
    FFornecedorID: Integer;
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
  frmContasPagar: TfrmContasPagar;

implementation

{$R *.lfm}

uses
  sqldb, DateUtils, sigo_DBConnection;

{ TfrmContasPagar }

procedure TfrmContasPagar.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlFinanceiro.Create;
  FFornecedorID := 0;

  dtpFiltroDe.Kind := dtkDate;
  dtpFiltroAte.Kind := dtkDate;
  dtpFiltroDe.Date := StartOfTheMonth(Now);
  dtpFiltroAte.Date := EndOfTheMonth(Now);

  dtpDataEmissaoCP.Kind := dtkDate;
  dtpDataVencCP.Kind    := dtkDate;
  dtpDataPagCP.Kind     := dtkDate;
  dtpDataEmissaoCP.Date := Date;
  dtpDataVencCP.Date    := Date;
  dtpDataPagCP.Date     := Date;

  cmbFiltroStatusCP.Items.Text := 'TODAS' + LineEnding + 'ABERTA' + LineEnding +
    'PARCIAL' + LineEnding + 'PAGA' + LineEnding + 'VENCIDA' + LineEnding + 'CANCELADA';
  cmbFiltroStatusCP.ItemIndex := 0;

  cmbStatusCP.Items.Text := 'ABERTA' + LineEnding + 'PARCIAL' + LineEnding +
    'PAGA' + LineEnding + 'CANCELADA';
  cmbStatusCP.ItemIndex := 0;

  cmbFiltroFormaCP.Items.Clear;
  cmbFiltroFormaCP.Items.Add('TODAS');
  cmbFiltroFormaCP.Items.Add('DINHEIRO');
  cmbFiltroFormaCP.Items.Add('PIX');
  cmbFiltroFormaCP.Items.Add('CARTÃO DÉBITO');
  cmbFiltroFormaCP.Items.Add('CARTÃO CRÉDITO');
  cmbFiltroFormaCP.Items.Add('BOLETO');
  cmbFiltroFormaCP.Items.Add('TRANSFERÊNCIA');
  cmbFiltroFormaCP.Items.Add('A PRAZO');
  cmbFiltroFormaCP.ItemIndex := 0;

  cmbFormaPgtoCP.Items.Clear;
  cmbFormaPgtoCP.Items.Add('DINHEIRO');
  cmbFormaPgtoCP.Items.Add('PIX');
  cmbFormaPgtoCP.Items.Add('CARTÃO DÉBITO');
  cmbFormaPgtoCP.Items.Add('CARTÃO CRÉDITO');
  cmbFormaPgtoCP.Items.Add('BOLETO');
  cmbFormaPgtoCP.Items.Add('TRANSFERÊNCIA');
  cmbFormaPgtoCP.Items.Add('A PRAZO');
  cmbFormaPgtoCP.ItemIndex := 0;

  btnFiltrarCP.OnClick := @btnFiltrarCPClick;
  btnBuscarFornecCP.OnClick := @btnBuscarFornecCPClick;
  inherited FormCreate(Sender);
end;

destructor TfrmContasPagar.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

function TfrmContasPagar.ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor;
var
  Status: string;
  DtVenc: TDateTime;
begin
  Result := inherited ObterCorLinha(AGrid, ARow);
  if (ARow > 0) and (AGrid.ColCount > 5) then
  begin
    Status := UpperCase(AGrid.Cells[5, ARow]);
    if Status = 'VENCIDA' then
      Result := C_COR_LINHA_CRITICA
    else if Status = 'ABERTA' then
    begin
      DtVenc := StrToDateDef(AGrid.Cells[4, ARow], 0);
      if (DtVenc > 0) and (DtVenc < Date) then
        Result := C_COR_LINHA_CRITICA
      else if (DtVenc > 0) and (DtVenc <= Date + 3) then
        Result := C_COR_LINHA_AVISO;
    end else if Status = 'PARCIAL' then
      Result := $00FFE4B5
    else if (Status = 'PAGA') or (Status = 'CANCELADA') then
      Result := C_COR_LINHA_IMPAR;
  end;
end;

procedure TfrmContasPagar.btnFiltrarCPClick(Sender: TObject);
begin
  CarregarGrid;
end;

procedure TfrmContasPagar.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL, StatusFiltro, FormaFiltro: string;
  Row: Integer;
begin
  grdLista.ColCount := 8;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Fornecedor';
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
  StatusFiltro := cmbFiltroStatusCP.Text;
  FormaFiltro  := cmbFiltroFormaCP.Text;

  SQL :=
    'SELECT cp.id, f.razao_social, cp.descricao, cp.data_emissao, ' +
    'cp.data_vencimento, cp.status, cp.valor, cp.valor_pago ' +
    'FROM contas_pagar cp LEFT JOIN fornecedores f ON f.id = cp.fornecedor_id ' +
    'WHERE cp.data_vencimento BETWEEN date(:DE) AND date(:ATE) ';

  if (StatusFiltro <> '') and (StatusFiltro <> 'TODAS') then
    SQL := SQL + 'AND cp.status = :ST ';
  if (FormaFiltro <> '') and (FormaFiltro <> 'TODAS') then
    SQL := SQL + 'AND cp.forma_pagamento = :FP ';
  if Filtro <> '' then
    SQL := SQL + 'AND (f.razao_social LIKE :F OR cp.descricao LIKE :F) ';
  SQL := SQL + 'ORDER BY cp.data_vencimento';

  grdLista.RowCount := 2;
  Row := 1;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := SQL;
    Q.ParamByName('DE').AsDate  := dtpFiltroDe.Date;
    Q.ParamByName('ATE').AsDate := dtpFiltroAte.Date;
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

procedure TfrmContasPagar.LimparFormulario;
begin
  FRegistroID   := 0;
  FFornecedorID := 0;
  edtFornecedorCP.Clear;
  edtDescricaoCP.Clear;
  edtValorCP.Text     := '0,00';
  edtValorPagoCP.Text := '0,00';
  dtpDataEmissaoCP.Date := Date;
  dtpDataVencCP.Date    := Date;
  dtpDataPagCP.Date     := Date;
  cmbStatusCP.ItemIndex := 0;
  cmbFormaPgtoCP.ItemIndex := 0;
  mmObsCP.Clear;
end;

procedure TfrmContasPagar.PreencherFormulario(ARow: Integer);
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
      'SELECT cp.*, f.razao_social FROM contas_pagar cp ' +
      'LEFT JOIN fornecedores f ON f.id = cp.fornecedor_id WHERE cp.id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    FFornecedorID := Q.FieldByName('fornecedor_id').AsInteger;
    edtFornecedorCP.Text := Q.FieldByName('razao_social').AsString;
    edtDescricaoCP.Text  := Q.FieldByName('descricao').AsString;
    edtValorCP.Text     := FormatMoeda(Q.FieldByName('valor').AsFloat);
    edtValorPagoCP.Text := FormatMoeda(Q.FieldByName('valor_pago').AsFloat);
    dtpDataEmissaoCP.Date := Q.FieldByName('data_emissao').AsDateTime;
    dtpDataVencCP.Date    := Q.FieldByName('data_vencimento').AsDateTime;
    dtpDataPagCP.Date     := Q.FieldByName('data_pagamento').AsDateTime;
    cmbStatusCP.ItemIndex := cmbStatusCP.Items.IndexOf(Q.FieldByName('status').AsString);
    if cmbStatusCP.ItemIndex < 0 then cmbStatusCP.ItemIndex := 0;
    cmbFormaPgtoCP.ItemIndex := cmbFormaPgtoCP.Items.IndexOf(Q.FieldByName('forma_pagamento').AsString);
    if cmbFormaPgtoCP.ItemIndex < 0 then cmbFormaPgtoCP.ItemIndex := 0;
    mmObsCP.Text := Q.FieldByName('observacoes').AsString;
  finally
    Q.Free;
  end;
end;

procedure TfrmContasPagar.btnBuscarFornecCPClick(Sender: TObject);
var
  Q: TSQLQuery;
  Busca: string;
begin
  Busca := InputBox('Buscar Fornecedor', 'Nome ou CNPJ:', '');
  if Trim(Busca) = '' then Exit;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT id, razao_social FROM fornecedores WHERE ativo=1 AND ' +
      '(razao_social LIKE :B OR cnpj_cpf LIKE :B) ORDER BY razao_social LIMIT 1';
    Q.ParamByName('B').AsString := '%' + Busca + '%';
    Q.Open;
    if not Q.EOF then
    begin
      FFornecedorID := Q.Fields[0].AsInteger;
      edtFornecedorCP.Text := Q.Fields[1].AsString;
    end else
      ShowMessage('Fornecedor não encontrado.');
  finally
    Q.Free;
  end;
end;

procedure TfrmContasPagar.SalvarRegistro;
var
  CP: TsigoModelContaPagar;
begin
  if Trim(edtDescricaoCP.Text) = '' then
    raise Exception.Create('A descrição é obrigatória.');

  CP := TsigoModelContaPagar.Create;
  try
    CP.ID           := FRegistroID;
    CP.FornecedorID := FFornecedorID;
    CP.Descricao    := Trim(edtDescricaoCP.Text);
    CP.Valor        := StrToFloatDef(StringReplace(edtValorCP.Text, ',', '.', [rfReplaceAll]), 0);
    CP.ValorPago    := StrToFloatDef(StringReplace(edtValorPagoCP.Text, ',', '.', [rfReplaceAll]), 0);
    CP.DataEmissao    := dtpDataEmissaoCP.Date;
    CP.DataVencimento := dtpDataVencCP.Date;
    CP.DataPagamento  := dtpDataPagCP.Date;
    CP.Status         := cmbStatusCP.Text;
    CP.FormaPagamento := cmbFormaPgtoCP.Text;
    CP.Observacoes    := Trim(mmObsCP.Text);

    if FRegistroID = 0 then
      FCtrl.SalvarContaPagar(CP)
    else
      FCtrl.AtualizarContaPagar(CP);
  finally
    CP.Free;
  end;
end;

procedure TfrmContasPagar.ExcluirRegistro;
var
  ID: Integer;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID > 0 then
    FCtrl.ExcluirContaPagar(ID);
end;

end.
