unit sigo_frmBase;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids,
  LCLType, sigo_Utils;

type
  { TfrmBase — formulário pai de todos os CRUDs }
  TfrmBase = class(TForm)
    tlbAcoes: TToolBar;
    btnNovo: TToolButton;
    btnEditar: TToolButton;
    btnExcluir: TToolButton;
    sep1: TToolButton;
    btnSalvar: TToolButton;
    btnCancelar: TToolButton;
    pnlLista: TPanel;
    pnlBusca: TPanel;
    lblBusca: TLabel;
    edtBusca: TEdit;
    btnBuscar: TBitBtn;
    grdLista: TStringGrid;
    pnlForm: TPanel;
    ilAcoes: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure edtBuscaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure grdListaDblClick(Sender: TObject);
    procedure grdListaDrawCell(Sender: TObject; ACol, ARow: Integer;
      ARect: TRect; AState: TGridDrawState);
    procedure grdListaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
    FModoEdicao: Boolean;
    FRegistroID: Integer;
    procedure ConfigurarToolbar; virtual;
    procedure ConfigurarGrid; virtual;
    procedure InicializarFormulario; virtual;
    procedure AtualizarBotoes; virtual;
    procedure SetModoEdicao(AValor: Boolean); virtual;
    function ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor; virtual;
    { Métodos abstratos — implementados pelos filhos }
    procedure LimparFormulario; virtual; abstract;
    procedure PreencherFormulario(ARow: Integer); virtual; abstract;
    procedure CarregarGrid; virtual; abstract;
    procedure SalvarRegistro; virtual; abstract;
    procedure ExcluirRegistro; virtual; abstract;
    procedure PesquisarRegistro; virtual;
  public
    property ModoEdicao: Boolean read FModoEdicao write SetModoEdicao;
    property RegistroID: Integer read FRegistroID write FRegistroID;
  end;

implementation

{$R *.lfm}

{ TfrmBase }

procedure TfrmBase.FormCreate(Sender: TObject);
begin
  KeyPreview := True;
  FModoEdicao := False;
  FRegistroID := 0;

  ConfigurarToolbar;
  ConfigurarGrid;
  InicializarFormulario;
  AtualizarBotoes;
  CarregarGrid;
end;

procedure TfrmBase.ConfigurarToolbar;
begin
  tlbAcoes.Height := 36;
  tlbAcoes.ButtonWidth := 96;
  tlbAcoes.ButtonHeight := 32;
  tlbAcoes.Flat := True;
  tlbAcoes.ShowCaptions := True;

  btnNovo.Caption    := 'Novo  F2';
  btnEditar.Caption  := 'Editar  F3';
  btnExcluir.Caption := 'Excluir  Del';
  btnSalvar.Caption  := 'Salvar';
  btnCancelar.Caption := 'Cancelar  Esc';

  sep1.Style := tbsDivider;
end;

procedure TfrmBase.ConfigurarGrid;
begin
  grdLista.Options := grdLista.Options
    + [goColSizing, goRowSizing, goThumbTracking]
    - [goEditing];
  grdLista.RowCount := 2;
  grdLista.FixedRows := 1;
  grdLista.FixedCols := 0;
  grdLista.DefaultRowHeight := 22;
  grdLista.GridLineWidth := 1;
  grdLista.GridLineColor := $00DDDDDD;
  grdLista.ScrollBars := ssAutoBoth;
end;

procedure TfrmBase.InicializarFormulario;
begin
  pnlLista.Align := alLeft;
  pnlLista.Width := Round(ClientWidth * 0.55);
  pnlForm.Align := alClient;

  pnlBusca.Align := alTop;
  pnlBusca.Height := 36;
  pnlBusca.BevelOuter := bvNone;

  grdLista.Align := alClient;

  lblBusca.Caption := 'Buscar:';
  edtBusca.Width := 200;
  btnBuscar.Caption := 'Buscar  F5';
end;

procedure TfrmBase.AtualizarBotoes;
begin
  btnNovo.Enabled    := not FModoEdicao;
  btnEditar.Enabled  := (not FModoEdicao) and (grdLista.Row > 0) and (grdLista.RowCount > 1);
  btnExcluir.Enabled := (not FModoEdicao) and (grdLista.Row > 0) and (grdLista.RowCount > 1);
  btnSalvar.Enabled  := FModoEdicao;
  btnCancelar.Enabled := FModoEdicao;
end;

procedure TfrmBase.SetModoEdicao(AValor: Boolean);
begin
  FModoEdicao := AValor;
  AtualizarBotoes;
  if not AValor then
    FRegistroID := 0;
end;

function TfrmBase.ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor;
begin
  if Odd(ARow) then
    Result := C_COR_LINHA_IMPAR
  else
    Result := C_COR_LINHA_PAR;
end;

procedure TfrmBase.PesquisarRegistro;
begin
  CarregarGrid;
end;

procedure TfrmBase.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_F2:
    begin
      if btnNovo.Enabled then btnNovo.Click;
      Key := 0;
    end;
    VK_F3:
    begin
      if btnEditar.Enabled then btnEditar.Click;
      Key := 0;
    end;
    VK_DELETE:
    begin
      if btnExcluir.Enabled and (ActiveControl = grdLista) then
        btnExcluir.Click;
    end;
    VK_F5:
    begin
      PesquisarRegistro;
      Key := 0;
    end;
    VK_ESCAPE:
    begin
      if FModoEdicao then btnCancelar.Click;
      Key := 0;
    end;
  end;
end;

procedure TfrmBase.btnNovoClick(Sender: TObject);
begin
  FRegistroID := 0;
  LimparFormulario;
  SetModoEdicao(True);
end;

procedure TfrmBase.btnEditarClick(Sender: TObject);
begin
  if grdLista.Row < 1 then Exit;
  PreencherFormulario(grdLista.Row);
  SetModoEdicao(True);
end;

procedure TfrmBase.btnExcluirClick(Sender: TObject);
begin
  if grdLista.Row < 1 then Exit;
  if MessageDlg('Confirmar exclusão?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      ExcluirRegistro;
      CarregarGrid;
      LimparFormulario;
    except
      on E: Exception do
        ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TfrmBase.btnSalvarClick(Sender: TObject);
begin
  try
    SalvarRegistro;
    SetModoEdicao(False);
    CarregarGrid;
    LimparFormulario;
  except
    on E: Exception do
      ShowMessage('Erro ao salvar: ' + E.Message);
  end;
end;

procedure TfrmBase.btnCancelarClick(Sender: TObject);
begin
  LimparFormulario;
  SetModoEdicao(False);
end;

procedure TfrmBase.btnBuscarClick(Sender: TObject);
begin
  PesquisarRegistro;
end;

procedure TfrmBase.edtBuscaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    PesquisarRegistro;
  end;
end;

procedure TfrmBase.grdListaDblClick(Sender: TObject);
begin
  if grdLista.Row > 0 then
  begin
    PreencherFormulario(grdLista.Row);
    SetModoEdicao(True);
  end;
end;

procedure TfrmBase.grdListaDrawCell(Sender: TObject; ACol, ARow: Integer;
  ARect: TRect; AState: TGridDrawState);
var
  Grid: TStringGrid;
  Cor: TColor;
begin
  Grid := Sender as TStringGrid;

  if ARow = 0 then
  begin
    Grid.Canvas.Brush.Color := C_COR_FUNDO_PRINCIPAL;
    Grid.Canvas.Font.Color  := C_COR_TEXTO_CLARO;
    Grid.Canvas.Font.Style  := [fsBold];
  end
  else if gdSelected in AState then
  begin
    Grid.Canvas.Brush.Color := C_COR_LINHA_SELECIONADA;
    Grid.Canvas.Font.Color  := C_COR_TEXTO_ESCURO;
    Grid.Canvas.Font.Style  := [];
  end
  else
  begin
    Cor := ObterCorLinha(Grid, ARow);
    Grid.Canvas.Brush.Color := Cor;
    Grid.Canvas.Font.Color  := C_COR_TEXTO_ESCURO;
    Grid.Canvas.Font.Style  := [];
  end;

  Grid.Canvas.FillRect(ARect);
  Grid.Canvas.TextRect(ARect,
    ARect.Left + 4, ARect.Top + 3,
    Grid.Cells[ACol, ARow]);
end;

procedure TfrmBase.grdListaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    if grdLista.Row > 0 then
    begin
      PreencherFormulario(grdLista.Row);
      SetModoEdicao(True);
    end;
  end;
end;

end.
