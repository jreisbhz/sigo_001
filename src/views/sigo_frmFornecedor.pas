unit sigo_frmFornecedor;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, LCLType,
  sigo_frmBase, sigo_ModelFornecedor, sigo_CtrlFornecedor,
  sigo_ConsultaCEP, sigo_Utils;

type
  { TfrmFornecedor }
  TfrmFornecedor = class(TfrmBase)
    grpDadosFornec: TGroupBox;
    radTipoPF: TRadioButton;
    radTipoPJ: TRadioButton;
    lblRazaoSocial: TLabel;
    edtRazaoSocial: TEdit;
    lblFantasiaF: TLabel;
    edtFantasiaF: TEdit;
    lblCnpjCpf: TLabel;
    edtCnpjCpf: TEdit;
    lblIE: TLabel;
    edtIE: TEdit;
    grpContatoF: TGroupBox;
    lblContatoNome: TLabel;
    edtContatoNome: TEdit;
    lblTelefoneF: TLabel;
    edtTelefoneF: TEdit;
    lblCelularF: TLabel;
    edtCelularF: TEdit;
    lblEmailF: TLabel;
    edtEmailF: TEdit;
    grpEnderecoF: TGroupBox;
    lblCepF: TLabel;
    edtCepF: TEdit;
    btnBuscarCepF: TBitBtn;
    lblLogradouroF: TLabel;
    edtLogradouroF: TEdit;
    lblNumeroF: TLabel;
    edtNumeroF: TEdit;
    lblBairroF: TLabel;
    edtBairroF: TEdit;
    lblCidadeF: TLabel;
    edtCidadeF: TEdit;
    lblUFF: TLabel;
    cmbUFF: TComboBox;
    grpObsF: TGroupBox;
    mmObsF: TMemo;
    chkAtivoF: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarCepFClick(Sender: TObject);
    procedure edtCepFExit(Sender: TObject);
    procedure radTipoPFClick(Sender: TObject);
    procedure radTipoPJClick(Sender: TObject);
  protected
    FCtrl: TsigoCtrlFornecedor;
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure PopularUFs;
    procedure AtualizarLabels;
  public
    destructor Destroy; override;
  end;

var
  frmFornecedor: TfrmFornecedor;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmFornecedor }

procedure TfrmFornecedor.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlFornecedor.Create;
  PopularUFs;
  radTipoPJ.Checked := True;
  AtualizarLabels;
  chkAtivoF.Checked := True;
  btnBuscarCepF.OnClick := @btnBuscarCepFClick;
  edtCepF.OnExit := @edtCepFExit;
  radTipoPF.OnClick := @radTipoPFClick;
  radTipoPJ.OnClick := @radTipoPJClick;
  inherited FormCreate(Sender);
end;

destructor TfrmFornecedor.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

procedure TfrmFornecedor.PopularUFs;
const
  UFs: array[0..26] of string = (
    'AC','AL','AM','AP','BA','CE','DF','ES','GO','MA','MG','MS','MT',
    'PA','PB','PE','PI','PR','RJ','RN','RO','RR','RS','SC','SE','SP','TO');
var
  i: Integer;
begin
  cmbUFF.Items.Clear;
  for i := 0 to High(UFs) do
    cmbUFF.Items.Add(UFs[i]);
  cmbUFF.ItemIndex := cmbUFF.Items.IndexOf('SP');
end;

procedure TfrmFornecedor.AtualizarLabels;
begin
  if radTipoPJ.Checked then
  begin
    lblRazaoSocial.Caption := 'Razão Social:';
    lblCnpjCpf.Caption := 'CNPJ:';
    lblIE.Caption := 'IE:';
  end else
  begin
    lblRazaoSocial.Caption := 'Nome:';
    lblCnpjCpf.Caption := 'CPF:';
    lblIE.Caption := 'RG:';
  end;
end;

procedure TfrmFornecedor.radTipoPFClick(Sender: TObject);
begin
  AtualizarLabels;
end;

procedure TfrmFornecedor.radTipoPJClick(Sender: TObject);
begin
  AtualizarLabels;
end;

procedure TfrmFornecedor.edtCepFExit(Sender: TObject);
begin
  if Trim(edtCepF.Text) <> '' then
    btnBuscarCepFClick(Sender);
end;

procedure TfrmFornecedor.btnBuscarCepFClick(Sender: TObject);
var
  CEP: TsigoConsultaCEP;
  Dados: TsigoCEP;
begin
  CEP := TsigoConsultaCEP.Create;
  try
    if CEP.Buscar(edtCepF.Text, Dados) then
    begin
      edtLogradouroF.Text := Dados.Logradouro;
      edtBairroF.Text := Dados.Bairro;
      edtCidadeF.Text := Dados.Cidade;
      cmbUFF.ItemIndex := cmbUFF.Items.IndexOf(Dados.UF);
      edtNumeroF.SetFocus;
    end;
  finally
    CEP.Free;
  end;
end;

procedure TfrmFornecedor.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL: string;
  Row: Integer;
begin
  grdLista.ColCount := 6;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Razão Social';
  grdLista.Cells[2, 0] := 'Fantasia';
  grdLista.Cells[3, 0] := 'CNPJ/CPF';
  grdLista.Cells[4, 0] := 'Telefone';
  grdLista.Cells[5, 0] := 'Cidade';
  grdLista.ColWidths[0] := 40;
  grdLista.ColWidths[1] := 200;
  grdLista.ColWidths[2] := 140;
  grdLista.ColWidths[3] := 120;
  grdLista.ColWidths[4] := 100;
  grdLista.ColWidths[5] := 120;

  Filtro := Trim(edtBusca.Text);
  SQL := 'SELECT id, razao_social, fantasia, cnpj_cpf, telefone, cidade ' +
         'FROM fornecedores WHERE ativo = 1 ';
  if Filtro <> '' then
    SQL := SQL + 'AND (razao_social LIKE :F OR fantasia LIKE :F OR cnpj_cpf LIKE :F) ';
  SQL := SQL + 'ORDER BY razao_social';

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
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  AtualizarBotoes;
end;

procedure TfrmFornecedor.LimparFormulario;
begin
  FRegistroID := 0;
  radTipoPJ.Checked := True;
  edtRazaoSocial.Clear;
  edtFantasiaF.Clear;
  edtCnpjCpf.Clear;
  edtIE.Clear;
  edtContatoNome.Clear;
  edtTelefoneF.Clear;
  edtCelularF.Clear;
  edtEmailF.Clear;
  edtCepF.Clear;
  edtLogradouroF.Clear;
  edtNumeroF.Clear;
  edtBairroF.Clear;
  edtCidadeF.Clear;
  cmbUFF.ItemIndex := cmbUFF.Items.IndexOf('SP');
  mmObsF.Clear;
  chkAtivoF.Checked := True;
  AtualizarLabels;
end;

procedure TfrmFornecedor.PreencherFormulario(ARow: Integer);
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
    Q.SQL.Text := 'SELECT * FROM fornecedores WHERE id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    if Q.FieldByName('tipo_pessoa').AsString = 'F' then
      radTipoPF.Checked := True
    else
      radTipoPJ.Checked := True;

    edtRazaoSocial.Text  := Q.FieldByName('razao_social').AsString;
    edtFantasiaF.Text    := Q.FieldByName('fantasia').AsString;
    edtCnpjCpf.Text      := Q.FieldByName('cnpj_cpf').AsString;
    edtIE.Text           := Q.FieldByName('ie').AsString;
    edtContatoNome.Text  := Q.FieldByName('contato').AsString;
    edtTelefoneF.Text    := Q.FieldByName('telefone').AsString;
    edtCelularF.Text     := Q.FieldByName('celular').AsString;
    edtEmailF.Text       := Q.FieldByName('email').AsString;
    edtCepF.Text         := Q.FieldByName('cep').AsString;
    edtLogradouroF.Text  := Q.FieldByName('logradouro').AsString;
    edtNumeroF.Text      := Q.FieldByName('numero').AsString;
    edtBairroF.Text      := Q.FieldByName('bairro').AsString;
    edtCidadeF.Text      := Q.FieldByName('cidade').AsString;
    cmbUFF.ItemIndex     := cmbUFF.Items.IndexOf(Q.FieldByName('uf').AsString);
    mmObsF.Text          := Q.FieldByName('observacoes').AsString;
    chkAtivoF.Checked    := Q.FieldByName('ativo').AsInteger = 1;
    AtualizarLabels;
  finally
    Q.Free;
  end;
end;

procedure TfrmFornecedor.SalvarRegistro;
var
  F: TsigoModelFornecedor;
begin
  if Trim(edtRazaoSocial.Text) = '' then
    raise Exception.Create('Razão Social / Nome é obrigatório.');

  F := TsigoModelFornecedor.Create;
  try
    F.ID := FRegistroID;
    F.TipoPessoa  := IfThen(radTipoPF.Checked, 'F', 'J');
    F.RazaoSocial := Trim(edtRazaoSocial.Text);
    F.Fantasia    := Trim(edtFantasiaF.Text);
    F.CnpjCpf     := SomenteNumeros(edtCnpjCpf.Text);
    F.IE          := Trim(edtIE.Text);
    F.Contato     := Trim(edtContatoNome.Text);
    F.Telefone    := Trim(edtTelefoneF.Text);
    F.Celular     := Trim(edtCelularF.Text);
    F.Email       := Trim(edtEmailF.Text);
    F.CEP         := SomenteNumeros(edtCepF.Text);
    F.Logradouro  := Trim(edtLogradouroF.Text);
    F.Numero      := Trim(edtNumeroF.Text);
    F.Bairro      := Trim(edtBairroF.Text);
    F.Cidade      := Trim(edtCidadeF.Text);
    F.UF          := cmbUFF.Text;
    F.Observacoes := Trim(mmObsF.Text);
    F.Ativo       := chkAtivoF.Checked;

    if FRegistroID = 0 then
      FCtrl.Salvar(F)
    else
      FCtrl.Atualizar(F);
  finally
    F.Free;
  end;
end;

procedure TfrmFornecedor.ExcluirRegistro;
var
  ID: Integer;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID > 0 then
    FCtrl.Excluir(ID);
end;

end.
