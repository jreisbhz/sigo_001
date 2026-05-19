unit sigo_frmCaixa;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, Calendar, DateTimePicker, LCLType,
  DateUtils,
  sigo_frmBase, sigo_ModelFinanceiro, sigo_CtrlFinanceiro, sigo_Utils;

type
  { TfrmCaixa }
  TfrmCaixa = class(TfrmBase)
    pnlCaixaLayout: TPanel;
    pnlCalendario: TPanel;
    calDia: TCalendar;
    pnlResumo: TPanel;
    lblEntradas: TLabel;
    edtEntradas: TEdit;
    lblSaidas: TLabel;
    edtSaidas: TEdit;
    lblSaldoCaixa: TLabel;
    edtSaldoCaixa: TEdit;
    grdMovimentos: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure calDiaChange(Sender: TObject);
    procedure grdMovimentosDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
  protected
    FCtrl: TsigoCtrlFinanceiro;
    // TfrmBase exige implementação dessas — no Caixa são no-op pois a tela tem layout próprio
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure CarregarMovimentosDia;
  public
    destructor Destroy; override;
  end;

var
  frmCaixa: TfrmCaixa;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmCaixa }

procedure TfrmCaixa.FormCreate(Sender: TObject);
begin
  FCtrl := TsigoCtrlFinanceiro.Create;

  edtEntradas.ReadOnly  := True;
  edtSaidas.ReadOnly    := True;
  edtSaldoCaixa.ReadOnly := True;
  edtEntradas.Color   := $00CCFFCC;  // verde claro
  edtSaidas.Color     := $00CCCCFF;  // vermelho claro
  edtEntradas.Font.Color  := $00006600;
  edtSaidas.Font.Color    := $00000099;

  // Configurar grid de movimentos (autônomo, não o grdLista herdado)
  grdMovimentos.ColCount := 6;
  grdMovimentos.RowCount := 2;
  grdMovimentos.FixedRows := 1;
  grdMovimentos.FixedCols := 0;
  grdMovimentos.DefaultRowHeight := 22;
  grdMovimentos.Options  := grdMovimentos.Options - [goEditing];
  grdMovimentos.Cells[0, 0] := 'Hora';
  grdMovimentos.Cells[1, 0] := 'Tipo';
  grdMovimentos.Cells[2, 0] := 'Descrição';
  grdMovimentos.Cells[3, 0] := 'Categoria';
  grdMovimentos.Cells[4, 0] := 'Forma Pag.';
  grdMovimentos.Cells[5, 0] := 'Valor';
  grdMovimentos.ColWidths[0] := 50;
  grdMovimentos.ColWidths[1] := 65;
  grdMovimentos.ColWidths[2] := 200;
  grdMovimentos.ColWidths[3] := 100;
  grdMovimentos.ColWidths[4] := 110;
  grdMovimentos.ColWidths[5] := 85;

  calDia.OnChange := @calDiaChange;
  grdMovimentos.OnDrawCell := @grdMovimentosDrawCell;
  inherited FormCreate(Sender);
  CarregarMovimentosDia;
end;

destructor TfrmCaixa.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited Destroy;
end;

procedure TfrmCaixa.calDiaChange(Sender: TObject);
begin
  CarregarMovimentosDia;
end;

procedure TfrmCaixa.CarregarMovimentosDia;
var
  Q: TSQLQuery;
  Row: Integer;
  DataSel: TDateTime;
  TotEntrada, TotSaida: Double;
  Tipo: string;
begin
  DataSel := DateOf(calDia.DateTime);

  grdMovimentos.RowCount := 2;
  grdMovimentos.Rows[1].Clear;
  Row := 1;
  TotEntrada := 0;
  TotSaida   := 0;

  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text :=
      'SELECT strftime(''%H:%M'', data_movimento) as hora, tipo, descricao, ' +
      'categoria, forma_pagamento, valor ' +
      'FROM caixa_movimentos ' +
      'WHERE date(data_movimento) = date(:DT) ' +
      'ORDER BY data_movimento';
    Q.ParamByName('DT').AsDateTime := DataSel;
    Q.Open;
    while not Q.EOF do
    begin
      if Row >= grdMovimentos.RowCount then
        grdMovimentos.RowCount := Row + 1;
      Tipo := Q.Fields[1].AsString;
      grdMovimentos.Cells[0, Row] := Q.Fields[0].AsString;
      grdMovimentos.Cells[1, Row] := Tipo;
      grdMovimentos.Cells[2, Row] := Q.Fields[2].AsString;
      grdMovimentos.Cells[3, Row] := Q.Fields[3].AsString;
      grdMovimentos.Cells[4, Row] := Q.Fields[4].AsString;
      grdMovimentos.Cells[5, Row] := FormatMoeda(Q.Fields[5].AsFloat);
      if UpperCase(Tipo) = 'ENTRADA' then
        TotEntrada := TotEntrada + Q.Fields[5].AsFloat
      else
        TotSaida := TotSaida + Q.Fields[5].AsFloat;
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;

  edtEntradas.Text   := FormatMoeda(TotEntrada);
  edtSaidas.Text     := FormatMoeda(TotSaida);
  edtSaldoCaixa.Text := FormatMoeda(TotEntrada - TotSaida);
  if (TotEntrada - TotSaida) >= 0 then
    edtSaldoCaixa.Color := $00CCFFCC
  else
    edtSaldoCaixa.Color := $00CCCCFF;
end;

procedure TfrmCaixa.grdMovimentosDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  Tipo: string;
  BgColor: TColor;
begin
  if aRow = 0 then
  begin
    grdMovimentos.Canvas.Brush.Color := C_COR_FUNDO_PRINCIPAL;
    grdMovimentos.Canvas.Font.Color  := clWhite;
    grdMovimentos.Canvas.Font.Style  := [fsBold];
    grdMovimentos.Canvas.FillRect(aRect);
    grdMovimentos.Canvas.TextOut(aRect.Left + 2, aRect.Top + 3, grdMovimentos.Cells[aCol, aRow]);
    Exit;
  end;

  if gdSelected in aState then
    BgColor := C_COR_LINHA_SELECIONADA
  else
  begin
    Tipo := UpperCase(grdMovimentos.Cells[1, aRow]);
    if Tipo = 'ENTRADA' then
      BgColor := $00CCFFCC
    else if Tipo = 'SAÍDA' then
      BgColor := $00FFCCCC
    else
      BgColor := IfThen(aRow mod 2 = 0, C_COR_LINHA_PAR, C_COR_LINHA_IMPAR);
  end;

  grdMovimentos.Canvas.Brush.Color := BgColor;
  grdMovimentos.Canvas.Font.Color  := clBlack;
  grdMovimentos.Canvas.Font.Style  := [];
  grdMovimentos.Canvas.FillRect(aRect);
  grdMovimentos.Canvas.TextOut(aRect.Left + 2, aRect.Top + 3, grdMovimentos.Cells[aCol, aRow]);
end;

// Métodos herdados de TfrmBase — sem uso nesta tela

procedure TfrmCaixa.LimparFormulario;
begin
  // sem uso nesta tela
end;

procedure TfrmCaixa.PreencherFormulario(ARow: Integer);
begin
  // sem uso nesta tela
end;

procedure TfrmCaixa.CarregarGrid;
begin
  CarregarMovimentosDia;
end;

procedure TfrmCaixa.SalvarRegistro;
begin
  // sem uso nesta tela
end;

procedure TfrmCaixa.ExcluirRegistro;
begin
  // sem uso nesta tela
end;

end.
