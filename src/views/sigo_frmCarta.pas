unit sigo_frmCarta;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, LCLType,
  sigo_frmBase, sigo_Utils;

type
  { TfrmCarta }
  TfrmCarta = class(TfrmBase)
    pnlCabecCarta: TPanel;
    lblModeloCarta: TLabel;
    cmbModeloCarta: TComboBox;
    lblClienteCarta: TLabel;
    edtClienteCarta: TEdit;
    btnBuscarClienteCarta: TBitBtn;
    btnGerarCarta: TBitBtn;
    btnImprimirCarta: TBitBtn;
    grpTextoCarta: TGroupBox;
    mmTextoCarta: TMemo;
    grpHistorico: TGroupBox;
    grdHistoricoCarta: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure cmbModeloCartaChange(Sender: TObject);
    procedure btnBuscarClienteCartaClick(Sender: TObject);
    procedure btnGerarCartaClick(Sender: TObject);
    procedure btnImprimirCartaClick(Sender: TObject);
  protected
    FClienteID: Integer;
    // TfrmBase stubs
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure SubstituirPlaceholders;
  public
    destructor Destroy; override;
  end;

var
  frmCarta: TfrmCarta;

implementation

{$R *.lfm}

uses
  Printers, sqldb, sigo_DBConnection;

{ TfrmCarta }

const
  MODELOS_CARTA: array[0..3] of string = (
    'Comunicado de OS Concluída',
    'Lembrete de Revisão',
    'Carta de Cobrança',
    'Agradecimento de Visita'
  );

  TEMPLATES_CARTA: array[0..3] of string = (
    'Prezado(a) {CLIENTE},' + LineEnding + LineEnding +
    'Informamos que a Ordem de Serviço referente ao veículo {PLACA} - {MODELO} ' +
    'foi concluída e o veículo está disponível para retirada.' + LineEnding + LineEnding +
    'Atenciosamente,' + LineEnding + '{EMPRESA}',
    'Prezado(a) {CLIENTE},' + LineEnding + LineEnding +
    'Gostaríamos de lembrá-lo(a) que seu veículo {PLACA} - {MODELO} ' +
    'está com {KM} km rodados e pode estar precisando de revisão.' + LineEnding + LineEnding +
    'Entre em contato conosco para agendamento.' + LineEnding + LineEnding +
    'Atenciosamente,' + LineEnding + '{EMPRESA}',
    'Prezado(a) {CLIENTE},' + LineEnding + LineEnding +
    'Notificamos que há um débito pendente em nosso sistema.' + LineEnding +
    'Por favor, entre em contato para regularização.' + LineEnding + LineEnding +
    'Atenciosamente,' + LineEnding + '{EMPRESA}',
    'Prezado(a) {CLIENTE},' + LineEnding + LineEnding +
    'Agradecemos sua visita e confiança em nossos serviços.' + LineEnding +
    'Estamos sempre à disposição para melhor atendê-lo(a).' + LineEnding + LineEnding +
    'Atenciosamente,' + LineEnding + '{EMPRESA}'
  );

procedure TfrmCarta.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FClienteID := 0;

  cmbModeloCarta.Items.Clear;
  for I := 0 to High(MODELOS_CARTA) do
    cmbModeloCarta.Items.Add(MODELOS_CARTA[I]);
  cmbModeloCarta.ItemIndex := 0;

  // Grid de histórico de cartas geradas
  grdHistoricoCarta.ColCount := 4;
  grdHistoricoCarta.RowCount := 2;
  grdHistoricoCarta.FixedRows := 1;
  grdHistoricoCarta.FixedCols := 0;
  grdHistoricoCarta.DefaultRowHeight := 22;
  grdHistoricoCarta.Options := grdHistoricoCarta.Options - [goEditing];
  grdHistoricoCarta.Cells[0, 0] := 'Data';
  grdHistoricoCarta.Cells[1, 0] := 'Cliente';
  grdHistoricoCarta.Cells[2, 0] := 'Modelo';
  grdHistoricoCarta.Cells[3, 0] := 'Usuário';
  grdHistoricoCarta.ColWidths[0] := 80;
  grdHistoricoCarta.ColWidths[1] := 200;
  grdHistoricoCarta.ColWidths[2] := 180;
  grdHistoricoCarta.ColWidths[3] := 100;

  mmTextoCarta.Text := TEMPLATES_CARTA[0];
  cmbModeloCarta.OnChange := @cmbModeloCartaChange;
  btnBuscarClienteCarta.OnClick := @btnBuscarClienteCartaClick;
  btnGerarCarta.OnClick := @btnGerarCartaClick;
  btnImprimirCarta.OnClick := @btnImprimirCartaClick;
  inherited FormCreate(Sender);
end;

destructor TfrmCarta.Destroy;
begin
  inherited Destroy;
end;

procedure TfrmCarta.cmbModeloCartaChange(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := cmbModeloCarta.ItemIndex;
  if (Idx >= 0) and (Idx <= High(TEMPLATES_CARTA)) then
  begin
    mmTextoCarta.Text := TEMPLATES_CARTA[Idx];
    SubstituirPlaceholders;
  end;
end;

procedure TfrmCarta.SubstituirPlaceholders;
var
  Texto, NomeCliente, Empresa: string;
  Q: TSQLQuery;
begin
  Texto := mmTextoCarta.Text;

  // Buscar nome do cliente
  NomeCliente := '';
  if FClienteID > 0 then
  begin
    Q := TsigoDBConnection.Instancia.NovaQuery;
    try
      Q.SQL.Text := 'SELECT nome_razao_social FROM clientes WHERE id = :ID';
      Q.ParamByName('ID').AsInteger := FClienteID;
      Q.Open;
      if not Q.EOF then NomeCliente := Q.Fields[0].AsString;
    finally
      Q.Free;
    end;
  end;

  // Buscar nome da empresa nas configurações
  Empresa := 'Nossa Empresa';
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT valor FROM configuracoes WHERE chave = ''empresa_nome'' LIMIT 1';
    Q.Open;
    if not Q.EOF then Empresa := Q.Fields[0].AsString;
  finally
    Q.Free;
  end;

  if NomeCliente <> '' then
    Texto := StringReplace(Texto, '{CLIENTE}', NomeCliente, [rfReplaceAll]);
  Texto := StringReplace(Texto, '{EMPRESA}', Empresa, [rfReplaceAll]);

  mmTextoCarta.Text := Texto;
end;

procedure TfrmCarta.btnBuscarClienteCartaClick(Sender: TObject);
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
      edtClienteCarta.Text := Q.Fields[1].AsString;
      SubstituirPlaceholders;
    end else
      ShowMessage('Cliente não encontrado.');
  finally
    Q.Free;
  end;
end;

procedure TfrmCarta.btnGerarCartaClick(Sender: TObject);
begin
  SubstituirPlaceholders;
  ShowMessage('Carta gerada com sucesso. Use "Imprimir" para enviar à impressora.');
end;

procedure TfrmCarta.btnImprimirCartaClick(Sender: TObject);
var
  I: Integer;
  Linhas: TStringList;
begin
  if Trim(mmTextoCarta.Text) = '' then
  begin
    ShowMessage('Nenhum texto para imprimir.');
    Exit;
  end;

  Printer.BeginDoc;
  try
    Linhas := TStringList.Create;
    try
      Linhas.Text := mmTextoCarta.Text;
      Printer.Canvas.Font.Name := 'Arial';
      Printer.Canvas.Font.Size := 12;
      for I := 0 to Linhas.Count - 1 do
        Printer.Canvas.TextOut(200, 300 + I * 200, Linhas[I]);
    finally
      Linhas.Free;
    end;
    Printer.EndDoc;
  except
    Printer.Abort;
    raise;
  end;
end;

// TfrmBase stubs

procedure TfrmCarta.CarregarGrid;
var
  Q: TSQLQuery;
  Row: Integer;
begin
  grdHistoricoCarta.RowCount := 2;
  grdHistoricoCarta.Rows[1].Clear;
  Row := 1;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT ch.data_emissao, c.nome_razao_social, ch.modelo, u.login ' +
      'FROM cartas_historico ch ' +
      'LEFT JOIN clientes c ON c.id = ch.cliente_id ' +
      'LEFT JOIN usuarios u ON u.id = ch.usuario_id ' +
      'ORDER BY ch.data_emissao DESC LIMIT 100';
    Q.Open;
    while not Q.EOF do
    begin
      if Row >= grdHistoricoCarta.RowCount then grdHistoricoCarta.RowCount := Row + 1;
      grdHistoricoCarta.Cells[0, Row] := FormatDateTime('dd/mm/yyyy', Q.Fields[0].AsDateTime);
      grdHistoricoCarta.Cells[1, Row] := Q.Fields[1].AsString;
      grdHistoricoCarta.Cells[2, Row] := Q.Fields[2].AsString;
      grdHistoricoCarta.Cells[3, Row] := Q.Fields[3].AsString;
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmCarta.LimparFormulario;
begin
  FClienteID := 0;
  edtClienteCarta.Clear;
  if cmbModeloCarta.ItemIndex >= 0 then
    mmTextoCarta.Text := TEMPLATES_CARTA[cmbModeloCarta.ItemIndex]
  else
    mmTextoCarta.Clear;
end;

procedure TfrmCarta.PreencherFormulario(ARow: Integer);
begin
  // sem uso
end;

procedure TfrmCarta.SalvarRegistro;
begin
  // sem uso
end;

procedure TfrmCarta.ExcluirRegistro;
begin
  // sem uso
end;

end.
