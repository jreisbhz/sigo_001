unit sigo_frmCliente;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids,
  DateTimePicker, LCLType,
  sigo_frmBase, sigo_ModelCliente, sigo_CtrlCliente,
  sigo_ConsultaCEP, sigo_Utils;

type
  { TfrmCliente }
  TfrmCliente = class(TfrmBase)
    { Tipo de pessoa }
    grpDadosPrincipais: TGroupBox;
    radTipoPF: TRadioButton;
    radTipoPJ: TRadioButton;
    lblNome: TLabel;
    edtNome: TEdit;
    lblFantasia: TLabel;
    edtFantasia: TEdit;
    lblCpfCnpj: TLabel;
    edtCpfCnpj: TEdit;
    lblRgIe: TLabel;
    edtRgIe: TEdit;
    lblDataNasc: TLabel;
    dtpDataNasc: TDateTimePicker;
    { Contato }
    grpContato: TGroupBox;
    lblTelefone: TLabel;
    edtTelefone: TEdit;
    lblCelular: TLabel;
    edtCelular: TEdit;
    lblCelular2: TLabel;
    edtCelular2: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    { Endereço }
    grpEndereco: TGroupBox;
    lblCep: TLabel;
    edtCep: TEdit;
    btnBuscarCep: TBitBtn;
    lblLogradouro: TLabel;
    edtLogradouro: TEdit;
    lblNumero: TLabel;
    edtNumero: TEdit;
    lblComplemento: TLabel;
    edtComplemento: TEdit;
    lblBairro: TLabel;
    edtBairro: TEdit;
    lblCidade: TLabel;
    edtCidade: TEdit;
    lblUF: TLabel;
    cmbUF: TComboBox;
    { Outros }
    grpObs: TGroupBox;
    mmObs: TMemo;
    lblLimite: TLabel;
    edtLimiteCredito: TEdit;
    chkAtivo: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure radTipoPFClick(Sender: TObject);
    procedure radTipoPJClick(Sender: TObject);
    procedure edtCepExit(Sender: TObject);
    procedure btnBuscarCepClick(Sender: TObject);
    procedure edtCpfCnpjExit(Sender: TObject);
  protected
    FCtrl: TsigoCtrlCliente;
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure PesquisarRegistro; override;
    procedure AtualizarLabelCpfCnpj;
    procedure PopularUFs;
  public
    destructor Destroy; override;
  end;

var
  frmCliente: TfrmCliente;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmCliente }

procedure TfrmCliente.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlCliente.Create;
  PopularUFs;
  radTipoPF.Checked := True;
  AtualizarLabelCpfCnpj;
  chkAtivo.Checked := True;
  radTipoPF.OnClick := @radTipoPFClick;
  radTipoPJ.OnClick := @radTipoPJClick;
  edtCep.OnExit := @edtCepExit;
  btnBuscarCep.OnClick := @btnBuscarCepClick;
  edtCpfCnpj.OnExit := @edtCpfCnpjExit;
  inherited FormCreate(Sender);
end;

destructor TfrmCliente.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

procedure TfrmCliente.PopularUFs;
const
  UFs: array[0..26] of string = (
    'AC','AL','AM','AP','BA','CE','DF','ES','GO','MA','MG','MS','MT',
    'PA','PB','PE','PI','PR','RJ','RN','RO','RR','RS','SC','SE','SP','TO');
var
  i: Integer;
begin
  cmbUF.Items.Clear;
  for i := 0 to High(UFs) do
    cmbUF.Items.Add(UFs[i]);
  cmbUF.ItemIndex := cmbUF.Items.IndexOf('SP');
end;

procedure TfrmCliente.AtualizarLabelCpfCnpj;
begin
  if radTipoPF.Checked then
  begin
    lblCpfCnpj.Caption := 'CPF:';
    lblRgIe.Caption := 'RG:';
    lblNome.Caption := 'Nome:';
    lblFantasia.Caption := 'Apelido:';
    lblDataNasc.Visible := True;
    dtpDataNasc.Visible := True;
  end else
  begin
    lblCpfCnpj.Caption := 'CNPJ:';
    lblRgIe.Caption := 'IE:';
    lblNome.Caption := 'Razão Social:';
    lblFantasia.Caption := 'Nome Fantasia:';
    lblDataNasc.Visible := False;
    dtpDataNasc.Visible := False;
  end;
end;

procedure TfrmCliente.radTipoPFClick(Sender: TObject);
begin
  AtualizarLabelCpfCnpj;
end;

procedure TfrmCliente.radTipoPJClick(Sender: TObject);
begin
  AtualizarLabelCpfCnpj;
end;

procedure TfrmCliente.edtCepExit(Sender: TObject);
begin
  if Trim(edtCep.Text) <> '' then
    btnBuscarCepClick(Sender);
end;

procedure TfrmCliente.btnBuscarCepClick(Sender: TObject);
var
  CEP: TsigoConsultaCEP;
  Dados: TsigoCEP;
begin
  CEP := TsigoConsultaCEP.Create;
  try
    if CEP.Buscar(edtCep.Text, Dados) then
    begin
      edtLogradouro.Text := Dados.Logradouro;
      edtBairro.Text := Dados.Bairro;
      edtCidade.Text := Dados.Cidade;
      cmbUF.ItemIndex := cmbUF.Items.IndexOf(Dados.UF);
      edtNumero.SetFocus;
    end;
  finally
    CEP.Free;
  end;
end;

procedure TfrmCliente.edtCpfCnpjExit(Sender: TObject);
var
  Doc: string;
begin
  Doc := SomenteNumeros(edtCpfCnpj.Text);
  if radTipoPF.Checked then
    edtCpfCnpj.Text := FormatCPF(Doc)
  else
    edtCpfCnpj.Text := FormatCNPJ(Doc);
end;

procedure TfrmCliente.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL: string;
  Row: Integer;
begin
  grdLista.ColCount := 7;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Nome / Razão Social';
  grdLista.Cells[2, 0] := 'Tipo';
  grdLista.Cells[3, 0] := 'CPF/CNPJ';
  grdLista.Cells[4, 0] := 'Celular';
  grdLista.Cells[5, 0] := 'E-mail';
  grdLista.Cells[6, 0] := 'Ativo';

  grdLista.ColWidths[0] := 40;
  grdLista.ColWidths[1] := 180;
  grdLista.ColWidths[2] := 40;
  grdLista.ColWidths[3] := 110;
  grdLista.ColWidths[4] := 110;
  grdLista.ColWidths[5] := 150;
  grdLista.ColWidths[6] := 45;

  Filtro := Trim(edtBusca.Text);
  SQL := 'SELECT id, nome, tipo_pessoa, cpf_cnpj, celular, email, ativo ' +
         'FROM clientes WHERE ativo = 1 ';
  if Filtro <> '' then
    SQL := SQL + 'AND (nome LIKE :F OR cpf_cnpj LIKE :F OR celular LIKE :F) ';
  SQL := SQL + 'ORDER BY nome';

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
      grdLista.Cells[6, Row] := IfThen(Q.Fields[6].AsInteger = 1, 'Sim', 'Não');
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  AtualizarBotoes;
end;

procedure TfrmCliente.LimparFormulario;
begin
  FRegistroID := 0;
  radTipoPF.Checked := True;
  edtNome.Clear;
  edtFantasia.Clear;
  edtCpfCnpj.Clear;
  edtRgIe.Clear;
  dtpDataNasc.Date := Date;
  edtTelefone.Clear;
  edtCelular.Clear;
  edtCelular2.Clear;
  edtEmail.Clear;
  edtCep.Clear;
  edtLogradouro.Clear;
  edtNumero.Clear;
  edtComplemento.Clear;
  edtBairro.Clear;
  edtCidade.Clear;
  cmbUF.ItemIndex := cmbUF.Items.IndexOf('SP');
  mmObs.Clear;
  edtLimiteCredito.Text := '0,00';
  chkAtivo.Checked := True;
  AtualizarLabelCpfCnpj;
end;

procedure TfrmCliente.PreencherFormulario(ARow: Integer);
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
    Q.SQL.Text := 'SELECT * FROM clientes WHERE id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    if Q.FieldByName('tipo_pessoa').AsString = 'J' then
      radTipoPJ.Checked := True
    else
      radTipoPF.Checked := True;

    edtNome.Text       := Q.FieldByName('nome').AsString;
    edtFantasia.Text   := Q.FieldByName('fantasia').AsString;
    edtCpfCnpj.Text    := Q.FieldByName('cpf_cnpj').AsString;
    edtRgIe.Text       := Q.FieldByName('rg_ie').AsString;
    dtpDataNasc.Date   := Q.FieldByName('data_nasc').AsDateTime;
    edtTelefone.Text   := Q.FieldByName('telefone').AsString;
    edtCelular.Text    := Q.FieldByName('celular').AsString;
    edtCelular2.Text   := Q.FieldByName('celular2').AsString;
    edtEmail.Text      := Q.FieldByName('email').AsString;
    edtCep.Text        := Q.FieldByName('cep').AsString;
    edtLogradouro.Text := Q.FieldByName('logradouro').AsString;
    edtNumero.Text     := Q.FieldByName('numero').AsString;
    edtComplemento.Text := Q.FieldByName('complemento').AsString;
    edtBairro.Text     := Q.FieldByName('bairro').AsString;
    edtCidade.Text     := Q.FieldByName('cidade').AsString;
    cmbUF.ItemIndex    := cmbUF.Items.IndexOf(Q.FieldByName('uf').AsString);
    mmObs.Text         := Q.FieldByName('observacoes').AsString;
    edtLimiteCredito.Text := FormatMoeda(Q.FieldByName('limite_credito').AsFloat);
    chkAtivo.Checked   := Q.FieldByName('ativo').AsInteger = 1;
    AtualizarLabelCpfCnpj;
  finally
    Q.Free;
  end;
end;

procedure TfrmCliente.SalvarRegistro;
var
  C: TsigoModelCliente;
begin
  if Trim(edtNome.Text) = '' then
    raise Exception.Create('O campo Nome é obrigatório.');

  C := TsigoModelCliente.Create;
  try
    C.ID := FRegistroID;
    C.TipoPessoa := IfThen(radTipoPJ.Checked, 'J', 'F');
    C.Nome       := Trim(edtNome.Text);
    C.Fantasia   := Trim(edtFantasia.Text);
    C.CpfCnpj   := SomenteNumeros(edtCpfCnpj.Text);
    C.RgIe      := Trim(edtRgIe.Text);
    C.DataNasc  := dtpDataNasc.Date;
    C.Telefone  := Trim(edtTelefone.Text);
    C.Celular   := Trim(edtCelular.Text);
    C.Celular2  := Trim(edtCelular2.Text);
    C.Email     := Trim(edtEmail.Text);
    C.CEP       := SomenteNumeros(edtCep.Text);
    C.Logradouro := Trim(edtLogradouro.Text);
    C.Numero    := Trim(edtNumero.Text);
    C.Complemento := Trim(edtComplemento.Text);
    C.Bairro    := Trim(edtBairro.Text);
    C.Cidade    := Trim(edtCidade.Text);
    C.UF        := cmbUF.Text;
    C.Observacoes := Trim(mmObs.Text);
    C.LimiteCredito := StrToFloatDef(StringReplace(edtLimiteCredito.Text, ',', '.', [rfReplaceAll]), 0);
    C.Ativo     := chkAtivo.Checked;

    if FRegistroID = 0 then
      FCtrl.Salvar(C)
    else
      FCtrl.Atualizar(C);
  finally
    C.Free;
  end;
end;

procedure TfrmCliente.ExcluirRegistro;
var
  ID: Integer;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID > 0 then
    FCtrl.Excluir(ID);
end;

procedure TfrmCliente.PesquisarRegistro;
begin
  CarregarGrid;
end;

end.
