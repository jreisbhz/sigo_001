unit sigo_frmAgenda;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, DateTimePicker, LCLType,
  sigo_frmBase, sigo_Utils;

type
  { TfrmAgenda }
  TfrmAgenda = class(TfrmBase)
    grpDadosAgenda: TGroupBox;
    lblDataAgenda: TLabel;
    dtpDataAgenda: TDateTimePicker;
    lblHoraAgenda: TLabel;
    dtpHoraAgenda: TDateTimePicker;
    lblClienteAgenda: TLabel;
    edtClienteAgenda: TEdit;
    btnBuscarClienteAgenda: TBitBtn;
    lblVeiculoAgenda: TLabel;
    edtVeiculoAgenda: TEdit;
    btnBuscarVeiculoAgenda: TBitBtn;
    lblMecanicoAgenda: TLabel;
    cmbMecanicoAgenda: TComboBox;
    lblStatusAgenda: TLabel;
    cmbStatusAgenda: TComboBox;
    lblObsAgenda: TLabel;
    mmObsAgenda: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarClienteAgendaClick(Sender: TObject);
    procedure btnBuscarVeiculoAgendaClick(Sender: TObject);
  protected
    FClienteID: Integer;
    FVeiculoID: Integer;
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure CarregarMecanicos;
    function ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor; override;
  public
    destructor Destroy; override;
  end;

var
  frmAgenda: TfrmAgenda;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmAgenda }

procedure TfrmAgenda.FormCreate(Sender: TObject);
begin
  FClienteID := 0;
  FVeiculoID := 0;

  dtpDataAgenda.Kind := dtkDate;
  dtpHoraAgenda.Kind := dtkTime;
  dtpDataAgenda.Date := Now;
  dtpHoraAgenda.Time := 0;

  cmbStatusAgenda.Items.Clear;
  cmbStatusAgenda.Items.Add('AGENDADO');
  cmbStatusAgenda.Items.Add('CONFIRMADO');
  cmbStatusAgenda.Items.Add('CONCLUÍDO');
  cmbStatusAgenda.Items.Add('CANCELADO');
  cmbStatusAgenda.ItemIndex := 0;

  CarregarMecanicos;
  btnBuscarClienteAgenda.OnClick := @btnBuscarClienteAgendaClick;
  btnBuscarVeiculoAgenda.OnClick := @btnBuscarVeiculoAgendaClick;
  inherited FormCreate(Sender);
end;

destructor TfrmAgenda.Destroy;
begin
  inherited Destroy;
end;

procedure TfrmAgenda.CarregarMecanicos;
var
  Q: TSQLQuery;
begin
  cmbMecanicoAgenda.Items.Clear;
  cmbMecanicoAgenda.Items.AddObject('(Nenhum)', TObject(PtrInt(0)));
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT id, nome FROM colaboradores WHERE ativo = 1 ORDER BY nome';
    Q.Open;
    while not Q.EOF do
    begin
      cmbMecanicoAgenda.Items.AddObject(Q.Fields[1].AsString, TObject(PtrInt(Q.Fields[0].AsInteger)));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  cmbMecanicoAgenda.ItemIndex := 0;
end;

function TfrmAgenda.ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor;
var
  Status: string;
begin
  Result := inherited ObterCorLinha(AGrid, ARow);
  if (ARow > 0) and (AGrid.ColCount > 5) then
  begin
    Status := UpperCase(AGrid.Cells[5, ARow]);
    if Status = 'CANCELADO' then
      Result := C_COR_LINHA_CRITICA
    else if Status = 'CONFIRMADO' then
      Result := C_COR_LINHA_AVISO
    else if Status = 'CONCLUÍDO' then
      Result := C_COR_LINHA_OK;
  end;
end;

procedure TfrmAgenda.CarregarGrid;
var
  Q: TSQLQuery;
  Filtro, SQL: string;
  Row: Integer;
begin
  grdLista.ColCount := 7;
  grdLista.Cells[0, 0] := 'ID';
  grdLista.Cells[1, 0] := 'Data';
  grdLista.Cells[2, 0] := 'Hora';
  grdLista.Cells[3, 0] := 'Cliente';
  grdLista.Cells[4, 0] := 'Placa';
  grdLista.Cells[5, 0] := 'Status';
  grdLista.Cells[6, 0] := 'Mecânico';
  grdLista.ColWidths[0] := 40;
  grdLista.ColWidths[1] := 80;
  grdLista.ColWidths[2] := 55;
  grdLista.ColWidths[3] := 180;
  grdLista.ColWidths[4] := 75;
  grdLista.ColWidths[5] := 80;
  grdLista.ColWidths[6] := 130;

  Filtro := Trim(edtBusca.Text);
  SQL := 'SELECT a.id, a.data_agenda, a.hora_agenda, c.nome_razao_social, ' +
         'v.placa, a.status, col.nome as mecanico ' +
         'FROM agenda a ' +
         'LEFT JOIN clientes c ON c.id = a.cliente_id ' +
         'LEFT JOIN veiculos v ON v.id = a.veiculo_id ' +
         'LEFT JOIN colaboradores col ON col.id = a.colaborador_id ' +
         'WHERE 1=1 ';
  if Filtro <> '' then
    SQL := SQL + 'AND (c.nome_razao_social LIKE :F OR v.placa LIKE :F) ';
  SQL := SQL + 'ORDER BY a.data_agenda DESC, a.hora_agenda';

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
      grdLista.Cells[1, Row] := FormatDateTime('dd/mm/yyyy', Q.Fields[1].AsDateTime);
      grdLista.Cells[2, Row] := FormatDateTime('hh:nn', Q.Fields[2].AsDateTime);
      grdLista.Cells[3, Row] := Q.Fields[3].AsString;
      grdLista.Cells[4, Row] := Q.Fields[4].AsString;
      grdLista.Cells[5, Row] := Q.Fields[5].AsString;
      grdLista.Cells[6, Row] := Q.Fields[6].AsString;
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  AtualizarBotoes;
end;

procedure TfrmAgenda.LimparFormulario;
begin
  FRegistroID := 0;
  FClienteID  := 0;
  FVeiculoID  := 0;
  dtpDataAgenda.Date := Now;
  dtpHoraAgenda.Time := 0;
  edtClienteAgenda.Clear;
  edtVeiculoAgenda.Clear;
  cmbMecanicoAgenda.ItemIndex := 0;
  cmbStatusAgenda.ItemIndex   := 0;
  mmObsAgenda.Clear;
end;

procedure TfrmAgenda.PreencherFormulario(ARow: Integer);
var
  ID, ColIdx: Integer;
  Q: TSQLQuery;
begin
  if ARow < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, ARow], 0);
  if ID <= 0 then Exit;

  FRegistroID := ID;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT a.*, c.nome_razao_social, v.placa FROM agenda a ' +
      'LEFT JOIN clientes c ON c.id = a.cliente_id ' +
      'LEFT JOIN veiculos v ON v.id = a.veiculo_id ' +
      'WHERE a.id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if Q.EOF then Exit;

    FClienteID := Q.FieldByName('cliente_id').AsInteger;
    FVeiculoID := Q.FieldByName('veiculo_id').AsInteger;
    dtpDataAgenda.Date  := Q.FieldByName('data_agenda').AsDateTime;
    dtpHoraAgenda.Time  := Q.FieldByName('hora_agenda').AsDateTime;
    edtClienteAgenda.Text := Q.FieldByName('nome_razao_social').AsString;
    edtVeiculoAgenda.Text := Q.FieldByName('placa').AsString;
    cmbStatusAgenda.ItemIndex := cmbStatusAgenda.Items.IndexOf(Q.FieldByName('status').AsString);
    if cmbStatusAgenda.ItemIndex < 0 then cmbStatusAgenda.ItemIndex := 0;
    mmObsAgenda.Text := Q.FieldByName('observacoes').AsString;

    ColIdx := cmbMecanicoAgenda.Items.IndexOfObject(TObject(PtrInt(Q.FieldByName('colaborador_id').AsInteger)));
    if ColIdx >= 0 then
      cmbMecanicoAgenda.ItemIndex := ColIdx
    else
      cmbMecanicoAgenda.ItemIndex := 0;
  finally
    Q.Free;
  end;
end;

procedure TfrmAgenda.SalvarRegistro;
var
  ColaboradorID: Integer;
  Q: TSQLQuery;
  Trans: TSQLTransaction;
begin
  if FClienteID <= 0 then
    raise Exception.Create('Selecione um cliente.');
  if FVeiculoID <= 0 then
    raise Exception.Create('Selecione um veículo.');

  ColaboradorID := PtrInt(cmbMecanicoAgenda.Items.Objects[cmbMecanicoAgenda.ItemIndex]);

  Trans := TsigoDBConnection.Instancia.Transacao;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Trans.StartTransaction;
    Q.Transaction := Trans;
    if FRegistroID = 0 then
    begin
      Q.SQL.Text :=
        'INSERT INTO agenda (data_agenda, hora_agenda, cliente_id, veiculo_id, ' +
        'colaborador_id, status, observacoes) ' +
        'VALUES (:DT, :HO, :CLI, :VEI, :COL, :ST, :OBS)';
    end else
    begin
      Q.SQL.Text :=
        'UPDATE agenda SET data_agenda=:DT, hora_agenda=:HO, cliente_id=:CLI, ' +
        'veiculo_id=:VEI, colaborador_id=:COL, status=:ST, observacoes=:OBS ' +
        'WHERE id=:ID';
      Q.ParamByName('ID').AsInteger := FRegistroID;
    end;
    Q.ParamByName('DT').AsDate   := dtpDataAgenda.Date;
    Q.ParamByName('HO').AsTime   := dtpHoraAgenda.Time;
    Q.ParamByName('CLI').AsInteger := FClienteID;
    Q.ParamByName('VEI').AsInteger := FVeiculoID;
    if ColaboradorID > 0 then
      Q.ParamByName('COL').AsInteger := ColaboradorID
    else
      Q.ParamByName('COL').Clear;
    Q.ParamByName('ST').AsString  := cmbStatusAgenda.Text;
    Q.ParamByName('OBS').AsString := Trim(mmObsAgenda.Text);
    try
      Q.ExecSQL;
      Trans.Commit;
    except
      Trans.Rollback;
      raise;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmAgenda.ExcluirRegistro;
var
  ID: Integer;
  Q: TSQLQuery;
  Trans: TSQLTransaction;
begin
  if grdLista.Row < 1 then Exit;
  ID := StrToIntDef(grdLista.Cells[0, grdLista.Row], 0);
  if ID <= 0 then Exit;

  Trans := TsigoDBConnection.Instancia.Transacao;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Trans.StartTransaction;
    Q.Transaction := Trans;
    Q.SQL.Text := 'DELETE FROM agenda WHERE id = :ID';
    Q.ParamByName('ID').AsInteger := ID;
    try
      Q.ExecSQL;
      Trans.Commit;
    except
      Trans.Rollback;
      raise;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmAgenda.btnBuscarClienteAgendaClick(Sender: TObject);
var
  Q: TSQLQuery;
  Busca: string;
begin
  Busca := InputBox('Buscar Cliente', 'Nome ou CPF/CNPJ:', '');
  if Trim(Busca) = '' then Exit;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT id, nome_razao_social FROM clientes WHERE ativo = 1 AND ' +
      '(nome_razao_social LIKE :B OR cpf_cnpj LIKE :B) ORDER BY nome_razao_social LIMIT 1';
    Q.ParamByName('B').AsString := '%' + Busca + '%';
    Q.Open;
    if not Q.EOF then
    begin
      FClienteID := Q.Fields[0].AsInteger;
      edtClienteAgenda.Text := Q.Fields[1].AsString;
      // Carrega veículos do cliente automaticamente
      FVeiculoID := 0;
      edtVeiculoAgenda.Clear;
    end else
      ShowMessage('Cliente não encontrado.');
  finally
    Q.Free;
  end;
end;

procedure TfrmAgenda.btnBuscarVeiculoAgendaClick(Sender: TObject);
var
  Q: TSQLQuery;
  Busca: string;
begin
  Busca := InputBox('Buscar Veículo', 'Placa:', '');
  if Trim(Busca) = '' then Exit;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT v.id, v.placa FROM veiculos v ' +
      'WHERE v.placa LIKE :B ';
    if FClienteID > 0 then
    begin
      Q.SQL.Text := Q.SQL.Text + 'AND v.cliente_id = :CLI ';
      Q.ParamByName('CLI').AsInteger := FClienteID;
    end;
    Q.SQL.Text := Q.SQL.Text + 'ORDER BY v.placa LIMIT 1';
    Q.ParamByName('B').AsString := '%' + Busca + '%';
    Q.Open;
    if not Q.EOF then
    begin
      FVeiculoID := Q.Fields[0].AsInteger;
      edtVeiculoAgenda.Text := Q.Fields[1].AsString;
    end else
      ShowMessage('Veículo não encontrado.');
  finally
    Q.Free;
  end;
end;

end.
