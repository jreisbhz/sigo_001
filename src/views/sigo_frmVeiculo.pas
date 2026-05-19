unit sigo_frmVeiculo;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids,
  Spin, LCLType,
  sigo_frmBase, sigo_ModelVeiculo, sigo_CtrlVeiculo, sigo_Utils;

type
  { TfrmVeiculo }
  TfrmVeiculo = class(TfrmBase)
    grpDadosVeiculo: TGroupBox;
    lblPlaca: TLabel;
    edtPlaca: TEdit;
    lblMarca: TLabel;
    cmbMarca: TComboBox;
    lblModelo: TLabel;
    cmbModelo: TComboBox;
    lblAno: TLabel;
    cmbAno: TComboBox;
    lblCor: TLabel;
    edtCor: TEdit;
    lblCombustivel: TLabel;
    cmbCombustivel: TComboBox;
    lblKmAtual: TLabel;
    seKmAtual: TSpinEdit;
    lblRenavam: TLabel;
    edtRenavam: TEdit;
    lblChassi: TLabel;
    edtChassi: TEdit;
    grpProprietario: TGroupBox;
    lblClienteVeiculo: TLabel;
    edtClienteNome: TEdit;
    btnBuscarCliente: TBitBtn;
    lblClienteID: TLabel;
    grpObsVeiculo: TGroupBox;
    mmObsVeiculo: TMemo;
    chkAtivoVeiculo: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure cmbMarcaChange(Sender: TObject);
    procedure cmbModeloChange(Sender: TObject);
    procedure btnBuscarClienteClick(Sender: TObject);
    procedure edtPlacaExit(Sender: TObject);
  protected
    FCtrl: TsigoCtrlVeiculo;
    FClienteID: Integer;
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure PopularMarcas;
    procedure PopularCombustiveis;
  public
    destructor Destroy; override;
  end;

var
  frmVeiculo: TfrmVeiculo;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmVeiculo }

procedure TfrmVeiculo.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlVeiculo.Create;
  FClienteID := 0;
  PopularMarcas;
  PopularCombustiveis;
  chkAtivoVeiculo.Checked := True;
  cmbMarca.OnChange := @cmbMarcaChange;
  cmbModelo.OnChange := @cmbModeloChange;
  btnBuscarCliente.OnClick := @btnBuscarClienteClick;
  edtPlaca.OnExit := @edtPlacaExit;
  inherited FormCreate(Sender);
end;

destructor TfrmVeiculo.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

procedure TfrmVeiculo.PopularMarcas;
var
  Q: TSQLQuery;
begin
  cmbMarca.Items.Clear;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT id, nome FROM fipe_marcas ORDER BY nome';
    Q.Open;
    while not Q.EOF do
    begin
      cmbMarca.Items.AddObject(Q.Fields[1].AsString,
        TObject(PtrInt(Q.Fields[0].AsInteger)));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmVeiculo.PopularCombustiveis;
begin
  cmbCombustivel.Items.Clear;
  cmbCombustivel.Items.Add('GASOLINA');
  cmbCombustivel.Items.Add('ETANOL');
  cmbCombustivel.Items.Add('FLEX');
  cmbCombustivel.Items.Add('DIESEL');
  cmbCombustivel.Items.Add('GNV');
  cmbCombustivel.Items.Add('ELÉTRICO');
  cmbCombustivel.Items.Add('HÍBRIDO');
  cmbCombustivel.ItemIndex := 2; // FLEX padrão
end;

procedure TfrmVeiculo.cmbMarcaChange(Sender: TObject);
var
  MarcaID: Integer;
  Q: TSQLQuery;
begin
  cmbModelo.Items.Clear;
  cmbAno.Items.Clear;
  if cmbMarca.ItemIndex < 0 then Exit;

  MarcaID := PtrInt(cmbMarca.Items.Objects[cmbMarca.ItemIndex]);
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT id, nome FROM fipe_modelos WHERE marca_id = :MID ORDER BY nome';
    Q.ParamByName('MID').AsInteger := MarcaID;
    Q.Open;
    while not Q.EOF do
    begin
      cmbModelo.Items.AddObject(Q.Fields[1].AsString,
        TObject(PtrInt(Q.Fields[0].AsInteger)));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmVeiculo.cmbModeloChange(Sender: TObject);
var
  ModeloID: Integer;
  Q: TSQLQuery;
begin
  cmbAno.Items.Clear;
  if cmbModelo.ItemIndex < 0 then Exit;

  ModeloID := PtrInt(cmbModelo.Items.Objects[cmbModelo.ItemIndex]);
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT id, ano_modelo FROM fipe_anos WHERE modelo_id = :MID ORDER BY ano_modelo DESC';
    Q.ParamByName('MID').AsInteger := ModeloID;
    Q.Open;
    while not Q.EOF do
    begin
      cmbAno.Items.AddObject(Q.Fields[1].AsString,
        TObject(PtrInt(Q.Fields[0].AsInteger)));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmVeiculo.btnBuscarClienteClick(Sender: TObject);
var
  Q: TSQLQuery;
  Busca: string;
begin
  Busca := InputBox('Buscar Cliente', 'Digite o nome ou CPF/CNPJ:', '');
  if Trim(Busca) = '' then Exit;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT id, nome FROM clientes WHERE ativo = 1 AND ' +
                  '(nome LIKE :B OR cpf_cnpj LIKE :B) ORDER BY nome LIMIT 1';
    Q.ParamByName('B').AsString := '%' + Busca + '%';
    Q.Open;
    if not Q.EOF then
    begin
      FClienteID := Q.Fields[0].AsInteger;
      edtClienteNome.Text := Q.Fields[1].AsString;
    end else
      ShowMessage('Cliente não encontrado.');
  finally
    Q.Free;
  end;
end;

procedure TfrmVeiculo.edtPlacaExit(Sender: TObject);
begin
  edtPlaca.Text := UpperCase(Trim(edtPlaca.Text));
end;

procedure TfrmVeiculo.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL: string;
  Row: Integer;
begin
  grdLista.ColCount := 8;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Placa';
  grdLista.Cells[2, 0] := 'Marca';
  grdLista.Cells[3, 0] := 'Modelo';
  grdLista.Cells[4, 0] := 'Ano';
  grdLista.Cells[5, 0] := 'Cliente';
  grdLista.Cells[6, 0] := 'KM';
  grdLista.Cells[7, 0] := 'Combustível';

  grdLista.ColWidths[0] := 40;
  grdLista.ColWidths[1] := 70;
  grdLista.ColWidths[2] := 100;
  grdLista.ColWidths[3] := 140;
  grdLista.ColWidths[4] := 50;
  grdLista.ColWidths[5] := 160;
  grdLista.ColWidths[6] := 60;
  grdLista.ColWidths[7] := 80;

  Filtro := Trim(edtBusca.Text);
  SQL :=
    'SELECT v.id, v.placa, v.marca, v.modelo, v.ano_modelo, c.nome, v.km_atual, v.combustivel ' +
    'FROM veiculos v LEFT JOIN clientes c ON c.id = v.cliente_id ' +
    'WHERE v.ativo = 1 ';
  if Filtro <> '' then
    SQL := SQL + 'AND (v.placa LIKE :F OR v.modelo LIKE :F OR c.nome LIKE :F) ';
  SQL := SQL + 'ORDER BY v.placa';

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
      grdLista.Cells[4, Row] := Q.Fields[4].AsString;
      grdLista.Cells[5, Row] := Q.Fields[5].AsString;
      grdLista.Cells[6, Row] := Q.Fields[6].AsString;
      grdLista.Cells[7, Row] := Q.Fields[7].AsString;
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  AtualizarBotoes;
end;

procedure TfrmVeiculo.LimparFormulario;
begin
  FRegistroID := 0;
  FClienteID  := 0;
  edtPlaca.Clear;
  cmbMarca.ItemIndex := -1;
  cmbModelo.Items.Clear;
  cmbAno.Items.Clear;
  edtCor.Clear;
  cmbCombustivel.ItemIndex := 2;
  seKmAtual.Value := 0;
  edtRenavam.Clear;
  edtChassi.Clear;
  edtClienteNome.Clear;
  mmObsVeiculo.Clear;
  chkAtivoVeiculo.Checked := True;
end;

procedure TfrmVeiculo.PreencherFormulario(ARow: Integer);
var
  ID: Integer;
  Q: TSQLQuery;
  IdxMarca: Integer;
begin
  if ARow < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, ARow], 0);
  if ID <= 0 then Exit;

  FRegistroID := ID;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT v.*, c.nome as cliente_nome ' +
      'FROM veiculos v LEFT JOIN clientes c ON c.id = v.cliente_id ' +
      'WHERE v.id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    edtPlaca.Text  := Q.FieldByName('placa').AsString;
    edtCor.Text    := Q.FieldByName('cor').AsString;
    cmbCombustivel.ItemIndex := cmbCombustivel.Items.IndexOf(Q.FieldByName('combustivel').AsString);
    seKmAtual.Value := Q.FieldByName('km_atual').AsInteger;
    edtRenavam.Text := Q.FieldByName('renavam').AsString;
    edtChassi.Text  := Q.FieldByName('chassi').AsString;
    FClienteID     := Q.FieldByName('cliente_id').AsInteger;
    edtClienteNome.Text := Q.FieldByName('cliente_nome').AsString;
    mmObsVeiculo.Text := Q.FieldByName('observacoes').AsString;
    chkAtivoVeiculo.Checked := Q.FieldByName('ativo').AsInteger = 1;

    // Marca — buscar índice
    IdxMarca := -1;
    if cmbMarca.Items.Count > 0 then
    begin
      // Encontra pela marca salva como texto
      IdxMarca := cmbMarca.Items.IndexOf(Q.FieldByName('marca').AsString);
      if IdxMarca >= 0 then
      begin
        cmbMarca.ItemIndex := IdxMarca;
        cmbMarcaChange(nil);
        cmbModelo.ItemIndex := cmbModelo.Items.IndexOf(Q.FieldByName('modelo').AsString);
        if cmbModelo.ItemIndex >= 0 then
        begin
          cmbModeloChange(nil);
          cmbAno.ItemIndex := cmbAno.Items.IndexOf(Q.FieldByName('ano_modelo').AsString);
        end;
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmVeiculo.SalvarRegistro;
var
  V: TsigoModelVeiculo;
begin
  if Trim(edtPlaca.Text) = '' then
    raise Exception.Create('A Placa é obrigatória.');
  if FClienteID <= 0 then
    raise Exception.Create('Selecione o cliente proprietário.');

  V := TsigoModelVeiculo.Create;
  try
    V.ID := FRegistroID;
    V.Placa := UpperCase(Trim(edtPlaca.Text));
    V.ClienteID := FClienteID;
    if cmbMarca.ItemIndex >= 0 then V.Marca := cmbMarca.Text;
    if cmbModelo.ItemIndex >= 0 then V.Modelo := cmbModelo.Text;
    if cmbAno.ItemIndex >= 0 then
    begin
      V.AnoModelo := StrToIntDef(cmbAno.Text, 0);
      V.AnoFabricacao := V.AnoModelo;
    end;
    V.Cor := Trim(edtCor.Text);
    V.Combustivel := cmbCombustivel.Text;
    V.KmAtual := seKmAtual.Value;
    V.Renavam := Trim(edtRenavam.Text);
    V.Chassi  := Trim(edtChassi.Text);
    V.Observacoes := Trim(mmObsVeiculo.Text);
    V.Ativo := chkAtivoVeiculo.Checked;

    if FRegistroID = 0 then
      FCtrl.Salvar(V)
    else
      FCtrl.Atualizar(V);
  finally
    V.Free;
  end;
end;

procedure TfrmVeiculo.ExcluirRegistro;
var
  ID: Integer;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID > 0 then
    FCtrl.Excluir(ID);
end;

end.
