unit sigo_frmRelatorios;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, DateTimePicker, LCLType,
  sigo_frmBase, sigo_Utils;

type
  { TfrmRelatorios }
  TfrmRelatorios = class(TfrmBase)
    pnlRelLayout: TPanel;
    pnlListaRel: TPanel;
    grdRelatorios: TStringGrid;
    pnlBotoesRel: TPanel;
    btnVisualizarRel: TBitBtn;
    btnImprimirRel: TBitBtn;
    pnlFiltrosRel: TPanel;
    lblFiltroDeRel: TLabel;
    dtpFiltroDeRel: TDateTimePicker;
    lblFiltroAteRel: TLabel;
    dtpFiltroAteRel: TDateTimePicker;
    lblFiltroStatusRel: TLabel;
    cmbFiltroStatusRel: TComboBox;
    lblGrupoRel: TLabel;
    cmbGrupoRel: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure grdRelatoriosDblClick(Sender: TObject);
    procedure btnVisualizarRelClick(Sender: TObject);
    procedure btnImprimirRelClick(Sender: TObject);
  protected
    // TfrmBase stubs
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure AbrirRelatorio;
  public
    destructor Destroy; override;
  end;

var
  frmRelatorios: TfrmRelatorios;

implementation

{$R *.lfm}

uses
  FileUtil, DateUtils;

type
  TRelatorioInfo = record
    Titulo: string;
    Grupo: string;
    Arquivo: string;
  end;

const
  RELATORIOS: array[0..11] of TRelatorioInfo = (
    (Titulo: 'Ordem de Serviço - Detalhe';          Grupo: 'OS';         Arquivo: 'rel_os_detalhe.lrf'),
    (Titulo: 'Ordens de Serviço por Período';        Grupo: 'OS';         Arquivo: 'rel_os_periodo.lrf'),
    (Titulo: 'OS por Mecânico';                      Grupo: 'OS';         Arquivo: 'rel_os_mecanico.lrf'),
    (Titulo: 'Estoque de Peças';                     Grupo: 'Estoque';    Arquivo: 'rel_estoque_pecas.lrf'),
    (Titulo: 'Peças Abaixo do Mínimo';               Grupo: 'Estoque';    Arquivo: 'rel_estoque_minimo.lrf'),
    (Titulo: 'Movimentação de Estoque';              Grupo: 'Estoque';    Arquivo: 'rel_estoque_movimentacao.lrf'),
    (Titulo: 'Contas a Receber';                     Grupo: 'Financeiro'; Arquivo: 'rel_contas_receber.lrf'),
    (Titulo: 'Contas a Pagar';                       Grupo: 'Financeiro'; Arquivo: 'rel_contas_pagar.lrf'),
    (Titulo: 'Fluxo de Caixa';                       Grupo: 'Financeiro'; Arquivo: 'rel_fluxo_caixa.lrf'),
    (Titulo: 'Vendas por Período';                   Grupo: 'Vendas';     Arquivo: 'rel_vendas_periodo.lrf'),
    (Titulo: 'Clientes Cadastrados';                 Grupo: 'Cadastros';  Arquivo: 'rel_clientes.lrf'),
    (Titulo: 'Veículos Cadastrados';                 Grupo: 'Cadastros';  Arquivo: 'rel_veiculos.lrf')
  );

{ TfrmRelatorios }

procedure TfrmRelatorios.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  dtpFiltroDeRel.Kind  := dtkDate;
  dtpFiltroAteRel.Kind := dtkDate;
  dtpFiltroDeRel.Date  := StartOfAMonth(YearOf(Now), MonthOf(Now));
  dtpFiltroAteRel.Date := Now;

  cmbGrupoRel.Items.Clear;
  cmbGrupoRel.Items.Add('TODOS');
  cmbGrupoRel.Items.Add('OS');
  cmbGrupoRel.Items.Add('Estoque');
  cmbGrupoRel.Items.Add('Financeiro');
  cmbGrupoRel.Items.Add('Vendas');
  cmbGrupoRel.Items.Add('Cadastros');
  cmbGrupoRel.ItemIndex := 0;

  cmbFiltroStatusRel.Items.Clear;
  cmbFiltroStatusRel.Items.Add('TODOS');
  cmbFiltroStatusRel.Items.Add('ABERTA');
  cmbFiltroStatusRel.Items.Add('CONCLUÍDA');
  cmbFiltroStatusRel.Items.Add('CANCELADA');
  cmbFiltroStatusRel.ItemIndex := 0;

  // Grid de lista de relatórios
  grdRelatorios.ColCount := 3;
  grdRelatorios.RowCount := 2;
  grdRelatorios.FixedRows := 1;
  grdRelatorios.FixedCols := 0;
  grdRelatorios.DefaultRowHeight := 22;
  grdRelatorios.Options := grdRelatorios.Options - [goEditing];
  grdRelatorios.Cells[0, 0] := '#';
  grdRelatorios.Cells[1, 0] := 'Grupo';
  grdRelatorios.Cells[2, 0] := 'Relatório';
  grdRelatorios.ColWidths[0] := 30;
  grdRelatorios.ColWidths[1] := 90;
  grdRelatorios.ColWidths[2] := 300;

  grdRelatorios.OnDblClick := @grdRelatoriosDblClick;
  btnVisualizarRel.OnClick := @btnVisualizarRelClick;
  btnImprimirRel.OnClick := @btnImprimirRelClick;
  inherited FormCreate(Sender);
  CarregarGrid;
end;

destructor TfrmRelatorios.Destroy;
begin
  inherited Destroy;
end;

procedure TfrmRelatorios.CarregarGrid;
var
  I, Row: Integer;
  GrupoFiltro: string;
begin
  GrupoFiltro := cmbGrupoRel.Text;
  grdRelatorios.RowCount := 2;
  grdRelatorios.Rows[1].Clear;
  Row := 1;

  for I := 0 to High(RELATORIOS) do
  begin
    if (GrupoFiltro = 'TODOS') or (RELATORIOS[I].Grupo = GrupoFiltro) then
    begin
      if Row >= grdRelatorios.RowCount then grdRelatorios.RowCount := Row + 1;
      grdRelatorios.Cells[0, Row] := IntToStr(I);
      grdRelatorios.Cells[1, Row] := RELATORIOS[I].Grupo;
      grdRelatorios.Cells[2, Row] := RELATORIOS[I].Titulo;
      Inc(Row);
    end;
  end;
end;

procedure TfrmRelatorios.grdRelatoriosDblClick(Sender: TObject);
begin
  AbrirRelatorio;
end;

procedure TfrmRelatorios.btnVisualizarRelClick(Sender: TObject);
begin
  AbrirRelatorio;
end;

procedure TfrmRelatorios.btnImprimirRelClick(Sender: TObject);
begin
  AbrirRelatorio;
end;

procedure TfrmRelatorios.AbrirRelatorio;
var
  Row, Idx: Integer;
  ArqRel: string;
begin
  Row := grdRelatorios.Row;
  if Row < 1 then
  begin
    ShowMessage('Selecione um relatório.');
    Exit;
  end;

  Idx := StrToIntDef(grdRelatorios.Cells[0, Row], -1);
  if (Idx < 0) or (Idx > High(RELATORIOS)) then Exit;

  ArqRel := ExtractFilePath(Application.ExeName) + '..' + PathDelim +
            'assets' + PathDelim + 'reports' + PathDelim + RELATORIOS[Idx].Arquivo;

  if not FileExists(ArqRel) then
  begin
    ShowMessage('Arquivo do relatório não encontrado:' + LineEnding + ArqRel);
    Exit;
  end;

  ShowMessage('Relatório: ' + RELATORIOS[Idx].Titulo + LineEnding +
              'Arquivo: ' + ArqRel + LineEnding + LineEnding +
              'Integração com LazReport deve ser configurada no projeto.');
end;

// TfrmBase stubs

procedure TfrmRelatorios.LimparFormulario;
begin
  // sem uso
end;

procedure TfrmRelatorios.PreencherFormulario(ARow: Integer);
begin
  // sem uso
end;

procedure TfrmRelatorios.SalvarRegistro;
begin
  // sem uso
end;

procedure TfrmRelatorios.ExcluirRegistro;
begin
  // sem uso
end;

end.
