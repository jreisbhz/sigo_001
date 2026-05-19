unit sigo_frmPeca;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, LCLType,
  sigo_frmBase, sigo_ModelPeca, sigo_CtrlPeca, sigo_Utils;

type
  { TfrmPeca }
  TfrmPeca = class(TfrmBase)
    grpCodigoPeca: TGroupBox;
    lblCodPeca: TLabel;
    edtCodPeca: TEdit;
    lblCodFabricante: TLabel;
    edtCodFabricante: TEdit;
    lblCodBarras: TLabel;
    edtCodBarras: TEdit;
    grpDescPeca: TGroupBox;
    lblDescricaoPeca: TLabel;
    edtDescricaoPeca: TEdit;
    lblUnidade: TLabel;
    cmbUnidade: TComboBox;
    lblMarcaPeca: TLabel;
    edtMarcaPeca: TEdit;
    lblLocalizacao: TLabel;
    edtLocalizacao: TEdit;
    lblFornecedorPeca: TLabel;
    edtFornecedorPeca: TEdit;
    btnBuscarFornecPeca: TBitBtn;
    grpEstoque: TGroupBox;
    lblEstoqueAtual: TLabel;
    edtEstoqueAtual: TEdit;
    lblEstoqueMinimo: TLabel;
    edtEstoqueMinimo: TEdit;
    lblEstoqueMaximo: TLabel;
    edtEstoqueMaximo: TEdit;
    grpPrecos: TGroupBox;
    lblPrecoCusto: TLabel;
    edtPrecoCusto: TEdit;
    lblMargemVista: TLabel;
    edtMargemVista: TEdit;
    lblPrecoVista: TLabel;
    edtPrecoVista: TEdit;
    lblMargemPrazo: TLabel;
    edtMargemPrazo: TEdit;
    lblPrecoPrazo: TLabel;
    edtPrecoPrazo: TEdit;
    lblMargemAtacado: TLabel;
    edtMargemAtacado: TEdit;
    lblPrecoAtacado: TLabel;
    edtPrecoAtacado: TEdit;
    grpObsPeca: TGroupBox;
    mmObsPeca: TMemo;
    chkAtivoPeca: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure edtPrecoCustoExit(Sender: TObject);
    procedure edtMargemVistaExit(Sender: TObject);
    procedure edtMargemPrazoExit(Sender: TObject);
    procedure edtMargemAtacadoExit(Sender: TObject);
    procedure btnBuscarFornecPecaClick(Sender: TObject);
  protected
    FCtrl: TsigoCtrlPeca;
    FFornecedorID: Integer;
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure RecalcularPrecos;
    function ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor; override;
  public
    destructor Destroy; override;
  end;

var
  frmPeca: TfrmPeca;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmPeca }

procedure TfrmPeca.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlPeca.Create;
  FFornecedorID := 0;
  chkAtivoPeca.Checked := True;

  cmbUnidade.Items.Clear;
  cmbUnidade.Items.Add('UN');
  cmbUnidade.Items.Add('PC');
  cmbUnidade.Items.Add('KG');
  cmbUnidade.Items.Add('LT');
  cmbUnidade.Items.Add('MT');
  cmbUnidade.Items.Add('CX');
  cmbUnidade.Items.Add('PAR');
  cmbUnidade.Items.Add('JG');
  cmbUnidade.ItemIndex := 0;

  // Campos de preço calculado são somente leitura
  edtPrecoVista.ReadOnly   := True;
  edtPrecoPrazo.ReadOnly   := True;
  edtPrecoAtacado.ReadOnly := True;
  edtPrecoVista.Color      := $00E8E8E8;
  edtPrecoPrazo.Color      := $00E8E8E8;
  edtPrecoAtacado.Color    := $00E8E8E8;

  edtPrecoCusto.OnExit := @edtPrecoCustoExit;
  edtMargemVista.OnExit := @edtMargemVistaExit;
  edtMargemPrazo.OnExit := @edtMargemPrazoExit;
  edtMargemAtacado.OnExit := @edtMargemAtacadoExit;
  btnBuscarFornecPeca.OnClick := @btnBuscarFornecPecaClick;
  inherited FormCreate(Sender);
end;

destructor TfrmPeca.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

function TfrmPeca.ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor;
var
  EstAtual, EstMin: Double;
begin
  Result := inherited ObterCorLinha(AGrid, ARow);
  if (ARow > 0) and (AGrid.ColCount > 5) then
  begin
    EstAtual := StrToFloatDef(AGrid.Cells[4, ARow], 0);
    EstMin   := StrToFloatDef(AGrid.Cells[5, ARow], 0);
    if EstAtual <= 0 then
      Result := C_COR_LINHA_CRITICA
    else if EstAtual <= EstMin then
      Result := C_COR_LINHA_AVISO
    else
      Result := C_COR_LINHA_OK;
  end;
end;

procedure TfrmPeca.RecalcularPrecos;
var
  Custo, MV, MP, MA: Double;
begin
  Custo := StrToFloatDef(StringReplace(edtPrecoCusto.Text, ',', '.', [rfReplaceAll]), 0);
  MV    := StrToFloatDef(StringReplace(edtMargemVista.Text, ',', '.', [rfReplaceAll]), 0);
  MP    := StrToFloatDef(StringReplace(edtMargemPrazo.Text, ',', '.', [rfReplaceAll]), 0);
  MA    := StrToFloatDef(StringReplace(edtMargemAtacado.Text, ',', '.', [rfReplaceAll]), 0);

  edtPrecoVista.Text   := FormatMoeda(Custo + MV);
  edtPrecoPrazo.Text   := FormatMoeda(Custo + MP);
  edtPrecoAtacado.Text := FormatMoeda(Custo + MA);
end;

procedure TfrmPeca.edtPrecoCustoExit(Sender: TObject);
begin
  RecalcularPrecos;
end;

procedure TfrmPeca.edtMargemVistaExit(Sender: TObject);
begin
  RecalcularPrecos;
end;

procedure TfrmPeca.edtMargemPrazoExit(Sender: TObject);
begin
  RecalcularPrecos;
end;

procedure TfrmPeca.edtMargemAtacadoExit(Sender: TObject);
begin
  RecalcularPrecos;
end;

procedure TfrmPeca.btnBuscarFornecPecaClick(Sender: TObject);
var
  Q: TSQLQuery;
  Busca: string;
begin
  Busca := InputBox('Buscar Fornecedor', 'Nome ou CNPJ:', '');
  if Trim(Busca) = '' then Exit;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT id, razao_social FROM fornecedores WHERE ativo = 1 AND ' +
                  '(razao_social LIKE :B OR cnpj_cpf LIKE :B) ORDER BY razao_social LIMIT 1';
    Q.ParamByName('B').AsString := '%' + Busca + '%';
    Q.Open;
    if not Q.EOF then
    begin
      FFornecedorID := Q.Fields[0].AsInteger;
      edtFornecedorPeca.Text := Q.Fields[1].AsString;
    end else
      ShowMessage('Fornecedor não encontrado.');
  finally
    Q.Free;
  end;
end;

procedure TfrmPeca.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL: string;
  Row: Integer;
begin
  // ColCount inclui colunas ocultas de estoque para coloração semântica
  grdLista.ColCount := 8;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Código';
  grdLista.Cells[2, 0] := 'Descrição';
  grdLista.Cells[3, 0] := 'Un';
  grdLista.Cells[4, 0] := 'Estoque';
  grdLista.Cells[5, 0] := 'Mín.';
  grdLista.Cells[6, 0] := 'Preço Vista';
  grdLista.Cells[7, 0] := 'Ativo';
  grdLista.ColWidths[0] := 40;
  grdLista.ColWidths[1] := 80;
  grdLista.ColWidths[2] := 200;
  grdLista.ColWidths[3] := 40;
  grdLista.ColWidths[4] := 60;
  grdLista.ColWidths[5] := 40;
  grdLista.ColWidths[6] := 80;
  grdLista.ColWidths[7] := 45;

  Filtro := Trim(edtBusca.Text);
  SQL := 'SELECT id, codigo, descricao, unidade, estoque_atual, estoque_minimo, ' +
         'preco_vista, ativo ' +
         'FROM pecas WHERE 1=1 ';
  if Filtro <> '' then
    SQL := SQL + 'AND (codigo LIKE :F OR descricao LIKE :F OR codigo_barras LIKE :F) ';
  SQL := SQL + 'ORDER BY descricao';

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
      grdLista.Cells[2, Row] := Q.Fields[2].AsString;
      grdLista.Cells[3, Row] := Q.Fields[3].AsString;
      grdLista.Cells[4, Row] := FormatFloat('0.##', Q.Fields[4].AsFloat);
      grdLista.Cells[5, Row] := FormatFloat('0.##', Q.Fields[5].AsFloat);
      grdLista.Cells[6, Row] := FormatMoeda(Q.Fields[6].AsFloat);
      grdLista.Cells[7, Row] := IfThen(Q.Fields[7].AsInteger = 1, 'Sim', 'Não');
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  AtualizarBotoes;
end;

procedure TfrmPeca.LimparFormulario;
begin
  FRegistroID   := 0;
  FFornecedorID := 0;
  edtCodPeca.Clear;
  edtCodFabricante.Clear;
  edtCodBarras.Clear;
  edtDescricaoPeca.Clear;
  cmbUnidade.ItemIndex := 0;
  edtMarcaPeca.Clear;
  edtLocalizacao.Clear;
  edtFornecedorPeca.Clear;
  edtEstoqueAtual.Text  := '0';
  edtEstoqueMinimo.Text := '0';
  edtEstoqueMaximo.Text := '0';
  edtPrecoCusto.Text    := '0,00';
  edtMargemVista.Text   := '0,00';
  edtMargemPrazo.Text   := '0,00';
  edtMargemAtacado.Text := '0,00';
  edtPrecoVista.Text    := '0,00';
  edtPrecoPrazo.Text    := '0,00';
  edtPrecoAtacado.Text  := '0,00';
  mmObsPeca.Clear;
  chkAtivoPeca.Checked := True;
end;

procedure TfrmPeca.PreencherFormulario(ARow: Integer);
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
      'SELECT p.*, f.razao_social as fornec_nome ' +
      'FROM pecas p LEFT JOIN fornecedores f ON f.id = p.fornecedor_id ' +
      'WHERE p.id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    edtCodPeca.Text       := Q.FieldByName('codigo').AsString;
    edtCodFabricante.Text := Q.FieldByName('codigo_fabricante').AsString;
    edtCodBarras.Text     := Q.FieldByName('codigo_barras').AsString;
    edtDescricaoPeca.Text := Q.FieldByName('descricao').AsString;
    cmbUnidade.ItemIndex  := cmbUnidade.Items.IndexOf(Q.FieldByName('unidade').AsString);
    edtMarcaPeca.Text     := Q.FieldByName('marca').AsString;
    edtLocalizacao.Text   := Q.FieldByName('localizacao').AsString;
    FFornecedorID         := Q.FieldByName('fornecedor_id').AsInteger;
    edtFornecedorPeca.Text := Q.FieldByName('fornec_nome').AsString;
    edtEstoqueAtual.Text  := FormatFloat('0.##', Q.FieldByName('estoque_atual').AsFloat);
    edtEstoqueMinimo.Text := FormatFloat('0.##', Q.FieldByName('estoque_minimo').AsFloat);
    edtEstoqueMaximo.Text := FormatFloat('0.##', Q.FieldByName('estoque_maximo').AsFloat);
    edtPrecoCusto.Text    := FormatMoeda(Q.FieldByName('preco_custo').AsFloat);
    edtMargemVista.Text   := FormatMoeda(Q.FieldByName('margem_vista').AsFloat);
    edtMargemPrazo.Text   := FormatMoeda(Q.FieldByName('margem_prazo').AsFloat);
    edtMargemAtacado.Text := FormatMoeda(Q.FieldByName('margem_atacado').AsFloat);
    edtPrecoVista.Text    := FormatMoeda(Q.FieldByName('preco_vista').AsFloat);
    edtPrecoPrazo.Text    := FormatMoeda(Q.FieldByName('preco_prazo').AsFloat);
    edtPrecoAtacado.Text  := FormatMoeda(Q.FieldByName('preco_atacado').AsFloat);
    mmObsPeca.Text        := Q.FieldByName('observacoes').AsString;
    chkAtivoPeca.Checked  := Q.FieldByName('ativo').AsInteger = 1;
  finally
    Q.Free;
  end;
end;

procedure TfrmPeca.SalvarRegistro;
var
  P: TsigoModelPeca;
  function ToFloat(S: string): Double;
  begin
    Result := StrToFloatDef(StringReplace(S, ',', '.', [rfReplaceAll]), 0);
  end;
begin
  if Trim(edtDescricaoPeca.Text) = '' then
    raise Exception.Create('A descrição da peça é obrigatória.');

  P := TsigoModelPeca.Create;
  try
    P.ID               := FRegistroID;
    P.Codigo           := Trim(edtCodPeca.Text);
    P.CodigoFabricante := Trim(edtCodFabricante.Text);
    P.CodigoBarras     := Trim(edtCodBarras.Text);
    P.Descricao        := Trim(edtDescricaoPeca.Text);
    P.Unidade          := cmbUnidade.Text;
    P.Marca            := Trim(edtMarcaPeca.Text);
    P.Localizacao      := Trim(edtLocalizacao.Text);
    P.FornecedorID     := FFornecedorID;
    P.EstoqueAtual     := ToFloat(edtEstoqueAtual.Text);
    P.EstoqueMinimo    := ToFloat(edtEstoqueMinimo.Text);
    P.EstoqueMaximo    := ToFloat(edtEstoqueMaximo.Text);
    P.PrecoCusto       := ToFloat(edtPrecoCusto.Text);
    P.MargemVista      := ToFloat(edtMargemVista.Text);
    P.MargemPrazo      := ToFloat(edtMargemPrazo.Text);
    P.MargemAtacado    := ToFloat(edtMargemAtacado.Text);
    P.PrecoVista       := ToFloat(edtPrecoVista.Text);
    P.PrecoPrazo       := ToFloat(edtPrecoPrazo.Text);
    P.PrecoAtacado     := ToFloat(edtPrecoAtacado.Text);
    P.Observacoes      := Trim(mmObsPeca.Text);
    P.Ativo            := chkAtivoPeca.Checked;

    if FRegistroID = 0 then
      FCtrl.Salvar(P)
    else
      FCtrl.Atualizar(P);
  finally
    P.Free;
  end;
end;

procedure TfrmPeca.ExcluirRegistro;
var
  ID: Integer;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID > 0 then
    FCtrl.Excluir(ID);
end;

end.
