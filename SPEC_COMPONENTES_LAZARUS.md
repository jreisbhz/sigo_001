# Referência de Componentes Nativos — SIGO_001
### Lazarus LCL — Guia de Uso por Tela

**Plataforma:** Lazarus 4.x / FPC  
**Princípio:** 100% componentes LCL nativos. Sem dependências externas de UI.

---

## 1. Mapa Componente × Tela

| Componente LCL | Unit | Usado Em |
|----------------|------|----------|
| `TForm` | `Forms` | Todas as telas |
| `TPanel` | `ExtCtrls` | Todas as telas (topo, rodapé, divisores) |
| `TLabel` | `StdCtrls` | Todos os formulários |
| `TEdit` | `StdCtrls` | Todos os formulários |
| `TButton` | `StdCtrls` | Todos os formulários |
| `TBitBtn` | `Buttons` | Login, diálogos com ícone |
| `TSpeedButton` | `Buttons` | Barra de atalhos no `frmMain` |
| `TMemo` | `StdCtrls` | Defeito/observações na OS, cartas |
| `TComboBox` | `StdCtrls` | Status, UF, combustível, FIPE |
| `TCheckBox` | `StdCtrls` | Campo "Ativo", flags booleanas |
| `TRadioButton` | `StdCtrls` | Tipo PF/PJ, tipo de entrada |
| `TGroupBox` | `StdCtrls` | Agrupamento de campos nos formulários |
| `TScrollBox` | `Forms` | Formulários com muitos campos |
| `TImage` | `ExtCtrls` | Logo empresa, foto do cliente |
| `TPageControl` | `ComCtrls` | Navegação principal (`frmMain`) |
| `TTabSheet` | `ComCtrls` | Cada módulo aberto no `frmMain` |
| `TToolBar` | `ComCtrls` | Barra de ações de cada CRUD |
| `TToolButton` | `ComCtrls` | Botões na `TToolBar` |
| `TMainMenu` | `Menus` | Menu superior do `frmMain` |
| `TPopupMenu` | `Menus` | Menu contextual no grid |
| `TStatusBar` | `ComCtrls` | Rodapé do `frmMain` |
| `TImageList` | `ImgList` | Ícones da toolbar e menus |
| `TSplitter` | `ExtCtrls` | Divisor redimensionável na OS |
| `TStringGrid` | `Grids` | Grid de listagem (CRUD), sub-grids OS |
| `TDBGrid` | `DBGrids` | Grid com DataSource (onde aplicável) |
| `TListView` | `ComCtrls` | Dashboard: lista de alertas |
| `TTreeView` | `ComCtrls` | (Reservado para categorias futuras) |
| `TSpinEdit` | `Spin` | Campos inteiros (KM, estoque) |
| `TDateTimePicker` | `DateTimeCtrls` | Datas e horas (OS, agenda) |
| `TCalendar` | `Calendar` | Tela de caixa (seleção do dia) |
| `TProgressBar` | `ComCtrls` | Dashboard (indicadores) |
| `TTrackBar` | `ComCtrls` | (Reservado) |
| `TChart` | `TAChart` | Dashboard (gráficos nativos) |
| `TBarSeries` | `TAChart` | Gráfico de barras (entradas × saídas) |
| `TPieSeries` | `TAChart` | Gráfico de pizza (OS por status) |
| `TLineSeries` | `TAChart` | Evolução mensal |
| `TfrReport` | `LazReport` | Impressão de OS, recibos, listagens |
| `TfrDBDataSet` | `LazReport` | Dados para o relatório |
| `TSQLite3Connection` | `SQLite3Conn` | Conexão com banco de dados |
| `TSQLQuery` | `SQLDB` | Consultas SQL parametrizadas |
| `TSQLTransaction` | `SQLDB` | Controle de transação |
| `TDataSource` | `DB` | Vínculo dataset ↔ DBControls |
| `TFPHTTPClient` | `fphttpclient` | Consulta CEP online (ViaCEP) |
| `TOpenDialog` | `Dialogs` | Abrir imagens (foto, logo) |
| `TSaveDialog` | `Dialogs` | Exportar / salvar backup |

---

## 2. Configuração da TToolBar (padrão CRUD)

```pascal
// Aplicado em TfrmBase e herdado por todos
procedure ConfigurarToolbar(ATB: TToolBar; AIL: TImageList);
begin
  ATB.Images      := AIL;
  ATB.ButtonWidth := 88;
  ATB.ButtonHeight := 32;
  ATB.Flat        := True;
  ATB.Transparent := True;
  ATB.ShowCaptions := True;
  ATB.EdgeBorders := [];
end;

// Atalhos de teclado (FormKeyDown, KeyPreview=True)
// F2  → btnNovo.Click
// F3  → btnEditar.Click
// Del → btnExcluir.Click (quando grid focado)
// F5  → Recarregar grid
// Esc → btnCancelar.Click
// Enter → avança campo (via OnKeyDown em cada TEdit)
```

---

## 3. TStringGrid — Configuração Padrão

```pascal
// Aplicado pelo TfrmBase em todos os grids de listagem
procedure ConfigurarGrid(AGrd: TStringGrid);
begin
  AGrd.Options  := AGrd.Options
    + [goColSizing, goRowSizing, goThumbTracking]
    - [goEditing];                         // Grid somente leitura
  AGrd.RowCount    := 2;                   // 1 cabeçalho + 1 linha vazia
  AGrd.FixedRows   := 1;
  AGrd.FixedCols   := 0;
  AGrd.DefaultRowHeight := 22;
  AGrd.GridLineWidth    := 1;
  AGrd.GridLineColor    := $00DDDDDD;
  AGrd.ScrollBars  := ssAutoBoth;
  AGrd.OnDrawCell  := @GridDrawCell;       // Método em TfrmBase
  AGrd.OnDblClick  := @GridDblClick;       // Duplo clique → preenche form
end;
```

---

## 4. TPageControl — Abas de Módulos

```pascal
// frmMain: cada módulo é uma TTabSheet no pgcMain
// Regra: não abre a mesma tela duas vezes
// Fechar aba: clique do meio (mbMiddle) ou botão × na aba
// Aba 0 (tabInicio/Dashboard) não pode ser fechada

pgcMain.Options := [nboShowCloseButtons];  // Habilita botão × em cada aba
pgcMain.TabPosition := tpTop;
pgcMain.Align   := alClient;
```

---

## 5. TDateTimePicker — Datas e Horas

```pascal
// Campos de data: Kind=dtkDate, Format='dd/mm/yyyy'
// Campos de hora: Kind=dtkTime, Format='HH:mm'
// Campos data+hora (OS): dois TDateTimePicker lado a lado

dtpDataAbertura.Kind := dtkDate;
dtpDataAbertura.DateFormat := 'dd/mm/yyyy';
dtpDataAbertura.Date := Date;    // data atual como padrão

dtpHoraAbertura.Kind := dtkTime;
dtpHoraAbertura.Time := Time;    // hora atual como padrão
```

---

## 6. TCalendar — Seleção de Dia no Caixa

```pascal
// Tela de caixa: clicar em um dia carrega os movimentos daquele dia
procedure TfrmCaixa.calDiaChange(Sender: TObject);
begin
  FDataSelecionada := calDia.DateTime;
  CarregarMovimentos(FDataSelecionada);
  AtualizarResumo;
end;

// calDia: TCalendar (unit Calendar) — nativo LCL
// Propriedades: DateTime, OnChange
```

---

## 7. TAChart — Dashboard de Gráficos

```pascal
// Pacote TAChart já incluso no Lazarus — basta adicionar ao uses
uses TAGraph, TASeries, TAChartAxis;

// Gráfico de barras: Entradas x Saídas (últimas 4 semanas)
procedure TfrmMain.CarregarGraficoCaixa;
begin
  with chtCaixa do
  begin
    Series[0].Clear;  // TBarSeries 'Entradas' (cor verde)
    Series[1].Clear;  // TBarSeries 'Saídas'   (cor vermelha)
    // Adicionar pontos com AddXY(semana, valor)
  end;
end;

// Gráfico de pizza: OS por status
procedure TfrmMain.CarregarGraficoOS;
begin
  with chtStatusOS do
  begin
    Series[0].Clear;  // TPieSeries
    // Adicionar fatias com Add(quantidade, 'ABERTA', corAberta)
  end;
end;
```

---

## 8. LazReport — Impressão

```pascal
// sigo_frmOS.pas — imprimir OS
procedure TfrmOS.ImprimirOS;
var
  Rep: TfrReport;
begin
  Rep := TfrReport.Create(nil);
  try
    Rep.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'reports\os_impressa.lrf');
    // Passa variáveis para o relatório
    Rep.Variables['OS_NUMERO']   := edtNumOS.Text;
    Rep.Variables['CLIENTE']     := edtClienteOS.Text;
    Rep.Variables['PLACA']       := edtPlacaOS.Text;
    Rep.Variables['TOTAL_GERAL'] := edtTotalGeral.Text;
    Rep.ShowReport;   // Exibe preview
    // Rep.PrintReport; // Imprime direto sem preview
  finally
    Rep.Free;
  end;
end;
```

---

## 9. TFPHTTPClient — Consulta CEP (nativo FPC)

```pascal
// unit: fphttpclient (já inclusa no FPC — sem instalação extra)
// Apenas para consulta online ao ViaCEP quando não há cache local
uses fphttpclient, fpjson, jsonparser, opensslsockets;

function TsigoConsultaCEP.BuscarOnline(const ACEP: string): Boolean;
var
  CLI: TFPHTTPClient;
  JSON: TJSONObject;
  Raw: string;
begin
  Result := False;
  CLI := TFPHTTPClient.Create(nil);
  try
    try
      CLI.ConnectTimeout := 5000;  // 5 segundos
      CLI.ReadTimeout    := 5000;
      Raw  := CLI.Get('https://viacep.com.br/ws/'
                      + StringReplace(ACEP,'-','',[rfReplaceAll])
                      + '/json/');
      JSON := GetJSON(Raw) as TJSONObject;
      try
        if not JSON.Find('erro', jtBoolean) then
        begin
          FLogradouro := JSON.Get('logradouro','');
          FBairro     := JSON.Get('bairro','');
          FCidade     := JSON.Get('localidade','');
          FUF         := JSON.Get('uf','');
          Result      := True;
        end;
      finally
        JSON.Free;
      end;
    except
      // Falha de rede → continua offline silenciosamente
    end;
  finally
    CLI.Free;
  end;
end;
```

---

## 10. TImageList — Ícones do Sistema

```pascal
// ilSistema: TImageList global (32×32 para toolbar, 16×16 para menus)
// Índices padrão (devem ser mantidos consistentes em todo o projeto):

// TOOLBAR (32×32)
const
  ICO_NOVO      = 0;   // plus.png        — verde
  ICO_EDITAR    = 1;   // edit.png        — azul
  ICO_EXCLUIR   = 2;   // delete.png      — vermelho
  ICO_SALVAR    = 3;   // save.png        — verde escuro
  ICO_CANCELAR  = 4;   // cancel.png      — cinza
  ICO_BUSCAR    = 5;   // search.png      — azul claro
  ICO_IMPRIMIR  = 6;   // print.png       — cinza escuro
  ICO_ATUALIZAR = 7;   // refresh.png     — azul
  ICO_EXPORTAR  = 8;   // export.png      — laranja

// MENU / STATUS (16×16)
  ICO_OS        = 10;  // wrench.png      — OS
  ICO_CLIENTE   = 11;  // person.png      — Clientes
  ICO_VEICULO   = 12;  // car.png         — Veículos
  ICO_PECA      = 13;  // gear.png        — Peças
  ICO_FINANCEIRO = 14; // dollar.png      — Financeiro
  ICO_RELATORIO = 15;  // chart.png       — Relatórios
  ICO_CONFIG    = 16;  // settings.png    — Configurações
```

---

## 11. Formatação de Valores Monetários e Datas

```pascal
// sigo_Utils.pas — funções globais de formatação

// Moeda: R$ 1.234,56
function FormatMoeda(AValor: Double): string;
begin
  Result := FormatFloat('#,##0.00', AValor);
end;

// Data: 18/05/2026
function FormatData(AData: TDate): string;
begin
  Result := FormatDateTime('dd/mm/yyyy', AData);
end;

// Data+Hora: 18/05/2026 14:32
function FormatDataHora(ADateTime: TDateTime): string;
begin
  Result := FormatDateTime('dd/mm/yyyy hh:nn', ADateTime);
end;

// SQLite → TDate
function SQLiteParaData(const AStr: string): TDate;
begin
  Result := StrToDateDef(
    Copy(AStr,9,2)+'/'+Copy(AStr,6,2)+'/'+Copy(AStr,1,4),
    0);
end;

// TDate → SQLite
function DataParaSQLite(AData: TDate): string;
begin
  Result := FormatDateTime('yyyy-mm-dd', AData);
end;

// Máscara de CPF/CNPJ (OnKeyPress + formatação no OnExit)
function FormatCPF(const ADoc: string): string;
var
  D: string;
begin
  D := SomenteNumeros(ADoc);
  if Length(D) = 11 then
    Result := Copy(D,1,3)+'.'+Copy(D,4,3)+'.'+Copy(D,7,3)+'-'+Copy(D,10,2)
  else
    Result := ADoc;
end;

function FormatCNPJ(const ADoc: string): string;
var
  D: string;
begin
  D := SomenteNumeros(ADoc);
  if Length(D) = 14 then
    Result := Copy(D,1,2)+'.'+Copy(D,3,3)+'.'+Copy(D,6,3)
            +'/'+Copy(D,9,4)+'-'+Copy(D,13,2)
  else
    Result := ADoc;
end;
```

---

## 12. Checklist de Modernização Visual

- [ ] Todas as `TPanel` de cabeçalho com `Color=COR_FUNDO_PRINCIPAL` e texto branco
- [ ] `TToolBar` com `Flat=True` e ícones 24×24 coloridos via `TImageList`
- [ ] `TStringGrid` com `OnDrawCell` para linhas alternadas e cores semânticas
- [ ] `TStatusBar` com 3 painéis: usuário, banco, relógio em tempo real
- [ ] `TPageControl` com abas fecháveis (`nboShowCloseButtons`)
- [ ] Dashboard com `TAChart` (sem bibliotecas externas)
- [ ] Impressão com `LazReport` (sem FastReport ou QuickReport)
- [ ] Consulta CEP com `TFPHTTPClient` + cache local SQLite
- [ ] Backup com `CopyFile` nativo (sem bibliotecas de compressão)
- [ ] Login com SHA-256 via unit `sha256` do FPC
- [ ] Atalhos de teclado: F2/F3/Del/F5/Esc/Enter em todos os CRUDs
- [ ] Campos de data com `TDateTimePicker` (unit `DateTimeCtrls`)
- [ ] Caixa com `TCalendar` (unit `Calendar`)
- [ ] Gráficos com `TChart` (package TAChart nativo do Lazarus)
