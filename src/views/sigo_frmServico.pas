unit sigo_frmServico;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, Spin, LCLType,
  sigo_frmBase, sigo_ModelServico, sigo_CtrlServico, sigo_Utils;

type
  { TfrmServico }
  TfrmServico = class(TfrmBase)
    grpDadosServico: TGroupBox;
    lblCodServico: TLabel;
    edtCodServico: TEdit;
    lblNomeServico: TLabel;
    edtNomeServico: TEdit;
    lblDescricaoServico: TLabel;
    mmDescricaoServico: TMemo;
    lblValorPadrao: TLabel;
    edtValorPadrao: TEdit;
    lblTempoEstimado: TLabel;
    seTempoEstimado: TSpinEdit;
    lblMinutos: TLabel;
    chkAtivoServico: TCheckBox;
    procedure FormCreate(Sender: TObject);
  protected
    FCtrl: TsigoCtrlServico;
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
  public
    destructor Destroy; override;
  end;

var
  frmServico: TfrmServico;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmServico }

procedure TfrmServico.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlServico.Create;
  chkAtivoServico.Checked := True;
  inherited FormCreate(Sender);
end;

destructor TfrmServico.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

procedure TfrmServico.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL: string;
  Row: Integer;
begin
  grdLista.ColCount := 5;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Código';
  grdLista.Cells[2, 0] := 'Nome';
  grdLista.Cells[3, 0] := 'Valor Padrão';
  grdLista.Cells[4, 0] := 'Ativo';
  grdLista.ColWidths[0] := 40;
  grdLista.ColWidths[1] := 80;
  grdLista.ColWidths[2] := 250;
  grdLista.ColWidths[3] := 90;
  grdLista.ColWidths[4] := 45;

  Filtro := Trim(edtBusca.Text);
  SQL := 'SELECT id, codigo, nome, valor_padrao, ativo FROM servicos WHERE 1=1 ';
  if Filtro <> '' then
    SQL := SQL + 'AND (nome LIKE :F OR codigo LIKE :F) ';
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
      grdLista.Cells[3, Row] := FormatMoeda(Q.Fields[3].AsFloat);
      grdLista.Cells[4, Row] := IfThen(Q.Fields[4].AsInteger = 1, 'Sim', 'Não');
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  AtualizarBotoes;
end;

procedure TfrmServico.LimparFormulario;
begin
  FRegistroID := 0;
  edtCodServico.Clear;
  edtNomeServico.Clear;
  mmDescricaoServico.Clear;
  edtValorPadrao.Text := '0,00';
  seTempoEstimado.Value := 0;
  chkAtivoServico.Checked := True;
end;

procedure TfrmServico.PreencherFormulario(ARow: Integer);
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
    Q.SQL.Text := 'SELECT * FROM servicos WHERE id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    edtCodServico.Text       := Q.FieldByName('codigo').AsString;
    edtNomeServico.Text      := Q.FieldByName('nome').AsString;
    mmDescricaoServico.Text  := Q.FieldByName('descricao').AsString;
    edtValorPadrao.Text      := FormatMoeda(Q.FieldByName('valor_padrao').AsFloat);
    seTempoEstimado.Value    := Q.FieldByName('tempo_estimado').AsInteger;
    chkAtivoServico.Checked  := Q.FieldByName('ativo').AsInteger = 1;
  finally
    Q.Free;
  end;
end;

procedure TfrmServico.SalvarRegistro;
var
  S: TsigoModelServico;
begin
  if Trim(edtNomeServico.Text) = '' then
    raise Exception.Create('O nome do serviço é obrigatório.');

  S := TsigoModelServico.Create;
  try
    S.ID           := FRegistroID;
    S.Codigo       := Trim(edtCodServico.Text);
    S.Nome         := Trim(edtNomeServico.Text);
    S.Descricao    := Trim(mmDescricaoServico.Text);
    S.ValorPadrao  := StrToFloatDef(StringReplace(edtValorPadrao.Text, ',', '.', [rfReplaceAll]), 0);
    S.TempoEstimado := seTempoEstimado.Value;
    S.Ativo        := chkAtivoServico.Checked;

    if FRegistroID = 0 then
      FCtrl.Salvar(S)
    else
      FCtrl.Atualizar(S);
  finally
    S.Free;
  end;
end;

procedure TfrmServico.ExcluirRegistro;
var
  ID: Integer;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID > 0 then
    FCtrl.Excluir(ID);
end;

end.
