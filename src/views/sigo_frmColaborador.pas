unit sigo_frmColaborador;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids,
  DateTimePicker, LCLType,
  sigo_frmBase, sigo_ModelColaborador, sigo_CtrlColaborador, sigo_Utils;

type
  { TfrmColaborador }
  TfrmColaborador = class(TfrmBase)
    grpDadosColab: TGroupBox;
    lblNomeColab: TLabel;
    edtNomeColab: TEdit;
    lblCPFColab: TLabel;
    edtCPFColab: TEdit;
    lblRGColab: TLabel;
    edtRGColab: TEdit;
    lblDataNascColab: TLabel;
    dtpDataNascColab: TDateTimePicker;
    grpProfissional: TGroupBox;
    lblCargo: TLabel;
    edtCargo: TEdit;
    lblEspecialidade: TLabel;
    cmbEspecialidade: TComboBox;
    lblDataAdmissao: TLabel;
    dtpDataAdmissao: TDateTimePicker;
    lblSalario: TLabel;
    edtSalario: TEdit;
    lblComissaoPct: TLabel;
    edtComissaoPct: TEdit;
    grpContatoColab: TGroupBox;
    lblTelefoneColab: TLabel;
    edtTelefoneColab: TEdit;
    lblCelularColab: TLabel;
    edtCelularColab: TEdit;
    lblEmailColab: TLabel;
    edtEmailColab: TEdit;
    chkAtivoColab: TCheckBox;
    procedure FormCreate(Sender: TObject);
  protected
    FCtrl: TsigoCtrlColaborador;
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure PopularEspecialidades;
  public
    destructor Destroy; override;
  end;

var
  frmColaborador: TfrmColaborador;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmColaborador }

procedure TfrmColaborador.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlColaborador.Create;
  PopularEspecialidades;
  dtpDataAdmissao.Date := Date;
  dtpDataNascColab.Date := Date;
  chkAtivoColab.Checked := True;
  inherited FormCreate(Sender);
end;

destructor TfrmColaborador.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

procedure TfrmColaborador.PopularEspecialidades;
begin
  cmbEspecialidade.Items.Clear;
  cmbEspecialidade.Items.Add('MECÂNICO GERAL');
  cmbEspecialidade.Items.Add('ELETRICISTA');
  cmbEspecialidade.Items.Add('FUNILEIRO');
  cmbEspecialidade.Items.Add('PINTOR');
  cmbEspecialidade.Items.Add('ALINHAMENTO/BALANCEAMENTO');
  cmbEspecialidade.Items.Add('BORRACHEIRO');
  cmbEspecialidade.Items.Add('ATENDENTE');
  cmbEspecialidade.Items.Add('GERENTE');
  cmbEspecialidade.Items.Add('OUTRO');
  cmbEspecialidade.ItemIndex := 0;
end;

procedure TfrmColaborador.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL: string;
  Row: Integer;
begin
  grdLista.ColCount := 6;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Nome';
  grdLista.Cells[2, 0] := 'Cargo';
  grdLista.Cells[3, 0] := 'Especialidade';
  grdLista.Cells[4, 0] := 'Celular';
  grdLista.Cells[5, 0] := 'Ativo';
  grdLista.ColWidths[0] := 40;
  grdLista.ColWidths[1] := 180;
  grdLista.ColWidths[2] := 120;
  grdLista.ColWidths[3] := 150;
  grdLista.ColWidths[4] := 110;
  grdLista.ColWidths[5] := 45;

  Filtro := Trim(edtBusca.Text);
  SQL := 'SELECT id, nome, cargo, especialidade, celular, ativo ' +
         'FROM colaboradores WHERE 1=1 ';
  if Filtro <> '' then
    SQL := SQL + 'AND (nome LIKE :F OR especialidade LIKE :F) ';
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
      grdLista.Cells[5, Row] := IfThen(Q.Fields[5].AsInteger = 1, 'Sim', 'Não');
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  AtualizarBotoes;
end;

procedure TfrmColaborador.LimparFormulario;
begin
  FRegistroID := 0;
  edtNomeColab.Clear;
  edtCPFColab.Clear;
  edtRGColab.Clear;
  dtpDataNascColab.Date := Date;
  edtCargo.Clear;
  cmbEspecialidade.ItemIndex := 0;
  dtpDataAdmissao.Date := Date;
  edtSalario.Text := '0,00';
  edtComissaoPct.Text := '0,00';
  edtTelefoneColab.Clear;
  edtCelularColab.Clear;
  edtEmailColab.Clear;
  chkAtivoColab.Checked := True;
end;

procedure TfrmColaborador.PreencherFormulario(ARow: Integer);
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
    Q.SQL.Text := 'SELECT * FROM colaboradores WHERE id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    edtNomeColab.Text     := Q.FieldByName('nome').AsString;
    edtCPFColab.Text      := Q.FieldByName('cpf').AsString;
    edtRGColab.Text       := Q.FieldByName('rg').AsString;
    dtpDataNascColab.Date := Q.FieldByName('data_nasc').AsDateTime;
    edtCargo.Text         := Q.FieldByName('cargo').AsString;
    cmbEspecialidade.ItemIndex := cmbEspecialidade.Items.IndexOf(Q.FieldByName('especialidade').AsString);
    dtpDataAdmissao.Date  := Q.FieldByName('data_admissao').AsDateTime;
    edtSalario.Text       := FormatMoeda(Q.FieldByName('salario').AsFloat);
    edtComissaoPct.Text   := FormatFloat('0.00', Q.FieldByName('comissao_pct').AsFloat);
    edtTelefoneColab.Text := Q.FieldByName('telefone').AsString;
    edtCelularColab.Text  := Q.FieldByName('celular').AsString;
    edtEmailColab.Text    := Q.FieldByName('email').AsString;
    chkAtivoColab.Checked := Q.FieldByName('ativo').AsInteger = 1;
  finally
    Q.Free;
  end;
end;

procedure TfrmColaborador.SalvarRegistro;
var
  C: TsigoModelColaborador;
begin
  if Trim(edtNomeColab.Text) = '' then
    raise Exception.Create('O nome do colaborador é obrigatório.');

  C := TsigoModelColaborador.Create;
  try
    C.ID            := FRegistroID;
    C.Nome          := Trim(edtNomeColab.Text);
    C.CPF           := SomenteNumeros(edtCPFColab.Text);
    C.RG            := Trim(edtRGColab.Text);
    C.DataNasc      := dtpDataNascColab.Date;
    C.Cargo         := Trim(edtCargo.Text);
    C.Especialidade := cmbEspecialidade.Text;
    C.DataAdmissao  := dtpDataAdmissao.Date;
    C.Salario       := StrToFloatDef(StringReplace(edtSalario.Text, ',', '.', [rfReplaceAll]), 0);
    C.ComissaoPct   := StrToFloatDef(StringReplace(edtComissaoPct.Text, ',', '.', [rfReplaceAll]), 0);
    C.Telefone      := Trim(edtTelefoneColab.Text);
    C.Celular       := Trim(edtCelularColab.Text);
    C.Email         := Trim(edtEmailColab.Text);
    C.Ativo         := chkAtivoColab.Checked;

    if FRegistroID = 0 then
      FCtrl.Salvar(C)
    else
      FCtrl.Atualizar(C);
  finally
    C.Free;
  end;
end;

procedure TfrmColaborador.ExcluirRegistro;
var
  ID: Integer;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID > 0 then
    FCtrl.Excluir(ID);
end;

end.
