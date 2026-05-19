# Especificação Técnica — SIGO 001
### Sistema Integrado de Gestão de Oficinas Mecânicas

**Projeto:** SIGO_001  
**Versão:** 1.0.0  
**Plataforma:** Lazarus 4.x / Free Pascal (FPC) — LCL Desktop  
**Banco de Dados:** SQLite 3 (100% offline, via SQLDB nativo do Lazarus)  
**Arquitetura:** MVC + Repository  
**Gerado em:** Maio/2026  
**Baseado em:** SIGO_LAZARUS (migração do legado Delphi) + SPEC_OFICINA_MECANICA.md  

---

## 1. Visão Geral

Sistema desktop completo para gestão de oficinas mecânicas e centros automotivos.  
Opera **totalmente offline** com banco SQLite local. Construído com **componentes 100% nativos da LCL do Lazarus**, sem dependências externas de UI.

### Funcionalidades do Sistema

| # | Módulo | Descrição |
|---|--------|-----------|
| 1 | Autenticação | Login com perfis (Admin, Atendente, Mecânico) |
| 2 | Dashboard | Alertas do dia: agenda, aniversariantes, contas |
| 3 | Clientes | Cadastro PF/PJ com endereço, contatos, foto |
| 4 | Veículos | Cadastro com FIPE local (offline) encadeada |
| 5 | Fornecedores | Cadastro com representante e contatos |
| 6 | Colaboradores | Funcionários com especialidade e comissão |
| 7 | Peças/Estoque | Catálogo com 3 margens de lucro e controle de estoque |
| 8 | Serviços | Tabela de serviços com valor padrão |
| 9 | Agenda | Agendamentos por data, hora e mecânico |
| 10 | Ordem de Serviço | OS completa: peças + serviços + financeiro |
| 11 | Vendas Diretas | Comanda de venda sem OS |
| 12 | Financeiro | Caixa, Contas a Pagar e Receber |
| 13 | Cartas | Modelos de carta personalizados por cliente |
| 14 | Relatórios | Impressão com LazReport |
| 15 | Configurações | Dados da empresa, usuários, parâmetros |
| 16 | Backup | Cópia do .db ao fechar (obrigatório) |

---

## 2. Tecnologia e Plataforma

### 2.1 Ambiente de Desenvolvimento

| Item | Versão |
|------|--------|
| Lazarus IDE | 4.x (compatível com 3.x) |
| Free Pascal (FPC) | 3.2.2+ |
| Modo de compilação | `{$mode objfpc}{$H+}` |
| Target | Windows 32/64 bits |
| Banco de dados | SQLite 3.x via `TSQLite3Connection` (SQLDB nativo) |

### 2.2 Pacotes LCL Utilizados (apenas nativos)

| Pacote | Componentes Usados |
|--------|--------------------|
| `LCLBase` | `TForm`, `TPanel`, `TLabel`, `TEdit`, `TButton`, `TComboBox`, `TCheckBox`, `TMemo` |
| `LCL` | `TMainMenu`, `TPopupMenu`, `TToolBar`, `TToolButton`, `TStatusBar`, `TImageList` |
| `LCL` | `TPageControl`, `TTabSheet`, `TSplitter`, `TScrollBox`, `TGroupBox` |
| `LCL` | `TStringGrid`, `TDBGrid`, `TListView`, `TTreeView` |
| `LCL` | `TBitBtn`, `TSpeedButton`, `TColorButton` |
| `LCL` | `TProgressBar`, `TTrackBar`, `TSpinEdit` |
| `DateTimeCtrls` | `TDateTimePicker` |
| `DBCtrls` | `TDBEdit`, `TDBComboBox`, `TDBCheckBox`, `TDBImage`, `TDBMemo`, `TDBText`, `TDBNavigator` |
| `SQLDB` | `TSQLite3Connection`, `TSQLQuery`, `TSQLTransaction`, `TDataSource` |
| `TAChart` | `TChart`, `TBarSeries`, `TLineSeries`, `TPieSeries` (dashboard) |
| `LazReport` | `TfrReport`, `TfrDBDataSet` (impressão de OS e relatórios) |

> **REGRA:** Não usar VCL, FireDAC, UniDAC, DevExpress, Alphaskins, Fastreport, FastReport, ou qualquer componente de terceiros pago. Apenas LCL nativo.

---

## 3. Arquitetura MVC + Repository

### 3.1 Estrutura de Pastas

```
sigo_001\
├── sigo_001.lpi           ← Arquivo de projeto Lazarus
├── sigo_001.lpr           ← Programa principal
├── sigo_001.res           ← Recursos (ícones)
├── sqlite3.dll            ← DLL SQLite para Windows
│
├── database\
│   ├── sigo_ddl.sql       ← DDL completo de criação do banco
│   ├── sigo_seed.sql      ← Dados iniciais (admin, parâmetros)
│   └── sigo_fipe.sql      ← Dados locais FIPE (marcas/modelos/anos)
│
├── assets\
│   ├── icons\             ← Ícones 16x16 e 32x32 (PNG)
│   └── reports\           ← Templates LazReport (.lrf)
│
├── bin\
│   ├── config\
│   │   └── sigo.ini       ← Configurações do sistema
│   └── logs\
│       └── sigo_AAAAMMDD.log
│
└── src\
    ├── infra\
    │   ├── sigo_Config.pas          ← Singleton de configurações (INI)
    │   ├── sigo_DBConnection.pas    ← Singleton de conexão SQLite
    │   ├── sigo_Logger.pas          ← Log em arquivo texto
    │   ├── sigo_Utils.pas           ← Funções utilitárias globais
    │   ├── sigo_ConsultaCEP.pas     ← Busca CEP (cache local + ViaCEP)
    │   └── sigo_BaseRepository.pas  ← CRUD genérico com TSQLQuery
    │
    ├── models\
    │   ├── sigo_ModelBase.pas       ← Classe base com ID, criado_em
    │   ├── sigo_ModelCliente.pas
    │   ├── sigo_ModelVeiculo.pas
    │   ├── sigo_ModelFornecedor.pas
    │   ├── sigo_ModelColaborador.pas
    │   ├── sigo_ModelPeca.pas
    │   ├── sigo_ModelServico.pas
    │   ├── sigo_ModelOS.pas         ← Inclui TModelOSItemPeca e TModelOSItemServico
    │   ├── sigo_ModelVenda.pas
    │   ├── sigo_ModelFinanceiro.pas
    │   └── sigo_ModelUsuario.pas
    │
    ├── repositories\
    │   ├── sigo_RepoCliente.pas
    │   ├── sigo_RepoVeiculo.pas
    │   ├── sigo_RepoFornecedor.pas
    │   ├── sigo_RepoColaborador.pas
    │   ├── sigo_RepoPeca.pas
    │   ├── sigo_RepoServico.pas
    │   ├── sigo_RepoOS.pas
    │   ├── sigo_RepoVenda.pas
    │   ├── sigo_RepoFinanceiro.pas
    │   └── sigo_RepoUsuario.pas
    │
    ├── controllers\
    │   ├── sigo_CtrlCliente.pas
    │   ├── sigo_CtrlVeiculo.pas
    │   ├── sigo_CtrlFornecedor.pas
    │   ├── sigo_CtrlColaborador.pas
    │   ├── sigo_CtrlPeca.pas
    │   ├── sigo_CtrlServico.pas
    │   ├── sigo_CtrlOS.pas
    │   ├── sigo_CtrlVenda.pas
    │   ├── sigo_CtrlFinanceiro.pas
    │   └── sigo_CtrlUsuario.pas
    │
    └── views\
        ├── sigo_frmLogin.pas / .lfm
        ├── sigo_frmMain.pas  / .lfm    ← TPageControl como MDI adaptado
        ├── sigo_frmBase.pas  / .lfm    ← Formulário pai (herdado por todos os CRUDs)
        ├── sigo_frmCliente.pas / .lfm
        ├── sigo_frmVeiculo.pas / .lfm
        ├── sigo_frmFornecedor.pas / .lfm
        ├── sigo_frmColaborador.pas / .lfm
        ├── sigo_frmPeca.pas / .lfm
        ├── sigo_frmServico.pas / .lfm
        ├── sigo_frmAgenda.pas / .lfm
        ├── sigo_frmOS.pas / .lfm
        ├── sigo_frmVenda.pas / .lfm
        ├── sigo_frmCaixa.pas / .lfm
        ├── sigo_frmContasReceber.pas / .lfm
        ├── sigo_frmContasPagar.pas / .lfm
        ├── sigo_frmCarta.pas / .lfm
        ├── sigo_frmRelatorios.pas / .lfm
        └── sigo_frmConfig.pas / .lfm
```

### 3.2 Convenções de Código

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Unit | prefixo `sigo_` | `sigo_Config` |
| Form class | `TfrmNome` | `TfrmCliente` |
| Controller | `TsigoCtrlNome` | `TsigoCtrlOS` |
| Repository | `TsigoRepoNome` | `TsigoRepoPeca` |
| Model | `TsigoModelNome` | `TsigoModelOS` |
| Variável global form | `frm` + nome | `frmMain`, `frmOS` |
| Prefixo de componente | tipo abreviado | `edt`, `lbl`, `btn`, `cmb`, `grd`, `pnl`, `pgc`, `tab` |

### 3.3 Hierarquia de Formulários

```
TForm (LCL)
├── TfrmLogin        ← modal, sem herdar TfrmBase
├── TfrmMain         ← janela principal, sem herdar TfrmBase
└── TfrmBase         ← pai de todos os CRUDs
    ├── TfrmCliente
    ├── TfrmVeiculo
    ├── TfrmFornecedor
    ├── TfrmColaborador
    ├── TfrmPeca
    ├── TfrmServico
    ├── TfrmAgenda
    ├── TfrmOS
    ├── TfrmVenda
    ├── TfrmCaixa
    ├── TfrmContasReceber
    ├── TfrmContasPagar
    ├── TfrmCarta
    └── TfrmConfig
```

---

## 4. Design da Interface com Componentes Nativos Lazarus

### 4.1 Paleta de Cores (Tema Escuro Profissional)

```pascal
// sigo_Utils.pas — constantes globais de cor
const
  // Cores de fundo
  COR_FUNDO_PRINCIPAL   = $002D2D2D;  // Cinza escuro (painel topo)
  COR_FUNDO_CONTEUDO    = $00F5F5F5;  // Branco suave (área de trabalho)
  COR_FUNDO_RODAPE      = $00404040;  // Cinza médio (barra de status)

  // Cores de destaque
  COR_PRIMARIA          = $00C0392B;  // Vermelho oficina (botões primários)
  COR_PRIMARIA_HOVER    = $00E74C3C;  // Vermelho claro (hover)
  COR_SECUNDARIA        = $002980B9;  // Azul informação
  COR_SUCESSO           = $0027AE60;  // Verde sucesso
  COR_AVISO             = $00F39C12;  // Laranja aviso
  COR_PERIGO            = $00C0392B;  // Vermelho perigo

  // Cores de texto
  COR_TEXTO_CLARO       = $00FFFFFF;  // Branco (em fundo escuro)
  COR_TEXTO_ESCURO      = $00333333;  // Cinza escuro (em fundo claro)
  COR_TEXTO_DESABILITADO = $00999999; // Cinza médio

  // Grid — cores de linha
  COR_LINHA_PAR         = $00FFFFFF;  // Branco
  COR_LINHA_IMPAR       = $00F0F4F8;  // Azul muito claro
  COR_LINHA_SELECIONADA = $00BDE0F7;  // Azul seleção
  COR_LINHA_CRITICA     = $00FFCCCC;  // Rosa — estoque zerado / vencido
  COR_LINHA_AVISO       = $00FFFACD;  // Amarelo — estoque mínimo / próximo vencer
  COR_LINHA_OK          = $00CCFFCC;  // Verde claro — normal
```

### 4.2 TfrmMain — Janela Principal

**Layout:** Topo fixo + Centro (PageControl) + Rodapé (StatusBar)

```
┌─────────────────────────────────────────────────────────────────────┐
│ pnlTopo [cor escura]                                                 │
│  lblLogo  lblNomeSistema           lblRelogio  lblUsuario            │
├─────────────────────────────────────────────────────────────────────┤
│ TMainMenu: Cadastros | OS | Financeiro | Relatórios | Sistema        │
├─────────────────────────────────────────────────────────────────────┤
│ pnlAtalhos [TSpeedButton × 8 com ícones + texto]                    │
│ [OS] [Clientes] [Veículos] [Peças] [Agenda] [Caixa] [Fornec] [...]  │
├─────────────────────────────────────────────────────────────────────┤
│ pgcMain (TPageControl — aba por módulo aberto)                       │
│ ┌──────────────────────────────────────────────────────────────────┐ │
│ │ tabInicio: Dashboard (TAChart + alertas)                         │ │
│ └──────────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────────┤
│ TStatusBar: [Usuário: Admin] [Banco: sigo.db] [18/05/2026 14:32:00] │
└─────────────────────────────────────────────────────────────────────┘
```

**Componentes:**

| Componente | Tipo | Propriedades Relevantes |
|------------|------|------------------------|
| `pnlTopo` | `TPanel` | `Color=COR_FUNDO_PRINCIPAL`, `Height=56`, `BevelOuter=bvNone` |
| `lblLogo` | `TLabel` | `Font.Color=clWhite`, `Font.Size=14`, `Font.Bold=True` |
| `lblRelogio` | `TLabel` | `Font.Color=clWhite`, `Alignment=taRightJustify` |
| `mnuPrincipal` | `TMainMenu` | — |
| `pnlAtalhos` | `TPanel` | `Height=48`, `Color=$00E8E8E8`, `BevelOuter=bvNone` |
| `btnAtlOS` | `TSpeedButton` | `Layout=blGlyphLeft`, `Caption='Nova OS'`, `Flat=True` |
| `pgcMain` | `TPageControl` | `TabPosition=tpTop`, `Align=alClient` |
| `sbStatus` | `TStatusBar` | `Panels[0..2]`, `SimplePanel=False` |
| `tmrRelogio` | `TTimer` | `Interval=1000` |

### 4.3 TfrmBase — Formulário Pai (CRUD Padrão)

Todo formulário de cadastro herda desta classe. Ela provê:
- Barra de ações com `TToolBar`
- Grid de listagem com `TStringGrid`
- Campo de busca rápida
- Navegação por teclado (F2=Novo, F3=Editar, Del=Excluir, Esc=Cancelar)

```
┌─────────────────────────────────────────────────────────────────────┐
│ TToolBar [Incluir F2] [Alterar F3] [Excluir Del] [Salvar] [Cancelar]│
├──────────────────────────────────┬──────────────────────────────────┤
│ pnlLista (Align=alLeft, 55%)     │ pnlForm (Align=alClient, 45%)   │
│                                  │                                  │
│ pnlBusca: [lbl] [edtBusca] [btn] │  (campos do cadastro)            │
│                                  │                                  │
│ TStringGrid (Align=alClient)     │                                  │
│  — linhas alternadas             │                                  │
│  — duplo clique → preenche form  │                                  │
│  — F5 = atualizar listagem       │                                  │
└──────────────────────────────────┴──────────────────────────────────┘
```

**Declaração Pascal:**

```pascal
// src/views/sigo_frmBase.pas
type
  { TfrmBase — pai de todos os formulários CRUD }
  TfrmBase = class(TForm)
    tlbAcoes: TToolBar;
    btnNovo:     TToolButton;
    btnEditar:   TToolButton;
    btnExcluir:  TToolButton;
    sep1:        TToolButton;   // Separador
    btnSalvar:   TToolButton;
    btnCancelar: TToolButton;
    pnlLista:    TPanel;
    pnlBusca:    TPanel;
    lblBusca:    TLabel;
    edtBusca:    TEdit;
    btnBuscar:   TBitBtn;
    grdLista:    TStringGrid;
    pnlForm:     TPanel;
    ilAcoes:     TImageList;    // Ícones da toolbar
  protected
    FModoEdicao: Boolean;
    procedure AtualizarBotoes; virtual;
    procedure LimparFormulario; virtual; abstract;
    procedure PreencherFormulario(ARow: Integer); virtual; abstract;
    procedure CarregarGrid; virtual; abstract;
    procedure AplicarCorLinha(AGrid: TStringGrid; ARow: Integer); virtual;
  public
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;
```

### 4.4 Toolbar de Ações (TToolBar)

```pascal
// Configuração padrão da toolbar em TfrmBase
procedure TfrmBase.ConfigurarToolbar;
begin
  tlbAcoes.Height := 36;
  tlbAcoes.ButtonWidth := 90;
  tlbAcoes.ButtonHeight := 32;
  tlbAcoes.Flat := True;

  // Ícones via TImageList (PNG 24x24)
  ilAcoes.Width  := 24;
  ilAcoes.Height := 24;

  btnNovo.ImageIndex    := 0;  // ícone: plus.png
  btnEditar.ImageIndex  := 1;  // ícone: edit.png
  btnExcluir.ImageIndex := 2;  // ícone: delete.png
  btnSalvar.ImageIndex  := 3;  // ícone: save.png
  btnCancelar.ImageIndex := 4; // ícone: cancel.png

  btnNovo.Caption    := 'Novo  F2';
  btnEditar.Caption  := 'Editar  F3';
  btnExcluir.Caption := 'Excluir  Del';
  btnSalvar.Caption  := 'Salvar';
  btnCancelar.Caption := 'Cancelar  Esc';

  // Separador visual entre grupos
  sep1.Style := tbsDivider;
end;
```

### 4.5 TStringGrid — Grid com Linhas Alternadas e Coloridas

```pascal
// Aplicado em TODOS os grids do sistema via TfrmBase
procedure TfrmBase.grdListaDrawCell(Sender: TObject; ACol, ARow: Integer;
  ARect: TRect; AState: TGridDrawState);
var
  Grid: TStringGrid;
  Cor: TColor;
begin
  Grid := Sender as TStringGrid;

  if ARow = 0 then  // Cabeçalho
  begin
    Grid.Canvas.Brush.Color := COR_FUNDO_PRINCIPAL;
    Grid.Canvas.Font.Color  := COR_TEXTO_CLARO;
    Grid.Canvas.Font.Style  := [fsBold];
  end
  else if gdSelected in AState then
    Grid.Canvas.Brush.Color := COR_LINHA_SELECIONADA
  else
  begin
    // Cor semântica (sobrescrita pelo form filho se necessário)
    Cor := ObterCorLinha(Grid, ARow);
    Grid.Canvas.Brush.Color := Cor;
    Grid.Canvas.Font.Color  := COR_TEXTO_ESCURO;
  end;

  Grid.Canvas.FillRect(ARect);
  Grid.Canvas.TextRect(ARect,
    ARect.Left + 4, ARect.Top + 3,
    Grid.Cells[ACol, ARow]);
end;

// Padrão: linhas par/ímpar alternadas
function TfrmBase.ObterCorLinha(AGrid: TStringGrid; ARow: Integer): TColor;
begin
  if Odd(ARow) then
    Result := COR_LINHA_IMPAR
  else
    Result := COR_LINHA_PAR;
end;
```

### 4.6 TPageControl — Navegação por Abas

```pascal
// TfrmMain: cada módulo aberto vira uma TTabSheet no pgcMain
// Evita abrir a mesma tela duas vezes
procedure TfrmMain.AbrirModulo(const ATitulo: string; AForm: TForm);
var
  Tab: TTabSheet;
  i: Integer;
begin
  // Verifica se já está aberto
  for i := 0 to pgcMain.PageCount - 1 do
    if pgcMain.Pages[i].Caption = ATitulo then
    begin
      pgcMain.ActivePage := pgcMain.Pages[i];
      Exit;
    end;

  // Cria nova aba
  Tab := TTabSheet.Create(pgcMain);
  Tab.Caption  := ATitulo;
  Tab.PageControl := pgcMain;

  AForm.Parent  := Tab;
  AForm.Align   := alClient;
  AForm.BorderStyle := bsNone;
  AForm.Visible := True;

  pgcMain.ActivePage := Tab;
end;

// Fechar aba com botão × ou Ctrl+W
procedure TfrmMain.pgcMainMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TabIndex: Integer;
begin
  if Button = mbMiddle then  // Clique do meio fecha a aba
  begin
    TabIndex := pgcMain.IndexOfTabAt(X, Y);
    if (TabIndex > 0) then   // Não fecha a aba inicial (dashboard)
      pgcMain.Pages[TabIndex].Free;
  end;
end;
```

### 4.7 TStatusBar — Barra de Rodapé

```pascal
// 3 painéis: usuário | banco | data/hora
sbStatus.Panels[0].Text  := 'Usuário: ' + FUsuarioLogado.Nome + ' [' + FUsuarioLogado.Perfil + ']';
sbStatus.Panels[0].Width := 250;
sbStatus.Panels[1].Text  := 'Banco: ' + ExtractFileName(Config.Banco);
sbStatus.Panels[1].Width := 200;
sbStatus.Panels[2].Text  := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
sbStatus.Panels[2].Width := 180;
sbStatus.Panels[2].Alignment := taRightJustify;
```

---

## 5. Módulos — Especificação Detalhada

### 5.1 Login (sigo_frmLogin)

- Modal centralizado, `BorderStyle=bsDialog`
- Logo da empresa (se cadastrada) em `TImage` 200×80
- `TEdit` para usuário, `TEdit` com `PasswordChar='*'` para senha
- `TBitBtn` OK e Cancelar
- Hash SHA-256 da senha antes de comparar com banco
- Credenciais padrão: `master` / `123456`
- 3 tentativas erradas → bloqueia e fecha o sistema

```pascal
// Validação com SHA-256 nativo do FPC
uses sha256;  // unit da FPC padrão

function TsigoCtrlUsuario.ValidarLogin(ALogin, ASenha: string): TsigoModelUsuario;
var
  SenhaHash: string;
begin
  SenhaHash := SHA256Print(SHA256String(ASenha));
  Result := FRepo.BuscarPorLogin(ALogin, SenhaHash);
end;
```

### 5.2 Dashboard (sigo_frmMain — tab inicial)

Na aba `tabInicio` do `pgcMain`, exibir:

**Painéis de Alerta (TGroupBox com cor de borda)**

| Painel | Cor | Conteúdo |
|--------|-----|----------|
| Agenda do Dia | Azul `COR_SECUNDARIA` | TStringGrid com hora, cliente, placa |
| Aniversariantes | Rosa `$00FF69B4` | TStringGrid com nome, telefone, WhatsApp |
| Contas a Receber | Laranja `COR_AVISO` | TStringGrid com cliente, valor, vencimento |
| Contas a Pagar | Vermelho `COR_PERIGO` | TStringGrid com fornecedor, valor, vencimento |

**Gráfico Resumo com TAChart**

```pascal
// TChart (TAChart nativo do Lazarus) no painel central
// Série: Entradas x Saídas do mês corrente
procedure TfrmMain.CarregarGraficoCaixa;
begin
  chtResumo.Series[0].Clear; // TBarSeries — Entradas
  chtResumo.Series[1].Clear; // TBarSeries — Saídas
  // Popular com dados de caixa_movimentos agrupados por semana
end;
```

### 5.3 Clientes (sigo_frmCliente)

Herda de `TfrmBase`.

**Grid (colunas):** ID | Nome/Razão Social | Tipo | CPF/CNPJ | Celular | E-mail | Ativo

**Formulário (campos):**

```
pnlDadosPrincipais (TGroupBox "Dados Principais")
  ├── radTipoPF / radTipoPJ (TRadioButton — altera label CPF↔CNPJ)
  ├── edtNome        TEdit    (obrigatório)
  ├── edtFantasia    TEdit
  ├── edtCpfCnpj     TEdit    (máscara: 999.999.999-99 ou 99.999.999/9999-99)
  ├── edtRgIe        TEdit
  ├── edtDataNasc    TDateTimePicker
  └── imgFoto        TImage   (foto do cliente, click → abrir diálogo)

pnlContato (TGroupBox "Contato")
  ├── edtTelefone    TEdit
  ├── edtCelular     TEdit    (WhatsApp)
  ├── edtCelular2    TEdit
  └── edtEmail       TEdit

pnlEndereco (TGroupBox "Endereço") — com auto-completar CEP
  ├── edtCep         TEdit    (OnExit → ConsultaCEP)
  ├── edtLogradouro  TEdit
  ├── edtNumero      TEdit
  ├── edtComplemento TEdit
  ├── edtBairro      TEdit
  ├── edtCidade      TEdit
  └── cmbUF          TComboBox (27 estados)

pnlObs (TGroupBox "Observações")
  └── mmObs          TMemo
```

### 5.4 Veículos (sigo_frmVeiculo)

**Grid:** Placa | Marca | Modelo | Ano | Cliente | KM | Cor | Combustível

**FIPE local (offline) — ComboBoxes encadeados:**

```pascal
// Evento cmbMarcaChange: recarrega modelos
procedure TfrmVeiculo.cmbMarcaChange(Sender: TObject);
var
  MarcaID: Integer;
begin
  cmbModelo.Items.Clear;
  cmbAno.Items.Clear;
  if cmbMarca.ItemIndex < 0 then Exit;

  MarcaID := Integer(cmbMarca.Items.Objects[cmbMarca.ItemIndex]);
  FCtrl.CarregarModelosPorMarca(MarcaID, cmbModelo.Items);
end;

// Evento cmbModeloChange: recarrega anos
procedure TfrmVeiculo.cmbModeloChange(Sender: TObject);
var
  ModeloID: Integer;
begin
  cmbAno.Items.Clear;
  if cmbModelo.ItemIndex < 0 then Exit;

  ModeloID := Integer(cmbModelo.Items.Objects[cmbModelo.ItemIndex]);
  FCtrl.CarregarAnosPorModelo(ModeloID, cmbAno.Items);
end;
```

**Campos adicionais:** Placa, KM atual, Cor, Combustível (`TComboBox`: Gasolina/Etanol/Flex/Diesel/GNV/Elétrico), Renavam, Chassi, Observações.

### 5.5 Peças / Estoque (sigo_frmPeca)

**Grid com cores semânticas:**

| Condição | Cor da linha |
|----------|-------------|
| Estoque zerado (≤ 0) | `COR_LINHA_CRITICA` (rosa) |
| Estoque ≤ mínimo | `COR_LINHA_AVISO` (amarelo) |
| Estoque OK | `COR_LINHA_OK` (verde) |

**Precificação automática (3 margens):**

```pascal
// Evento OnChange dos campos de custo/margem
procedure TfrmPeca.RecalcularPrecos;
var
  Custo, MargemV, MargemP, MargemA: Double;
begin
  Custo   := StrToFloatDef(edtCusto.Text, 0);
  MargemV := StrToFloatDef(edtMargemVista.Text, 0);
  MargemP := StrToFloatDef(edtMargemPrazo.Text, 0);
  MargemA := StrToFloatDef(edtMargemAtacado.Text, 0);

  // Margem em R$ (não percentual — conforme especificação original)
  edtPrecoVista.Text   := FormatFloat('#,##0.00', Custo + MargemV);
  edtPrecoPrazo.Text   := FormatFloat('#,##0.00', Custo + MargemP);
  edtPrecoAtacado.Text := FormatFloat('#,##0.00', Custo + MargemA);
end;
```

**Campos do formulário:** Código, Código Fabricante, Código de Barras, Descrição, Unidade, Categoria, Fornecedor, Localização, Estoque atual/mínimo/máximo, Preço custo, Margens (V/P/A), Preços calculados (somente leitura), Observações.

### 5.6 Ordem de Serviço (sigo_frmOS)

**Layout em dois painéis com `TSplitter`:**

```
┌──────────────────────────┬─────────────────────────────────────────┐
│ pnlListaOS (TSplitter)   │ pnlDetalheOS                            │
│                          │                                          │
│ Filtros:                 │ TPageControl (Aba OS)                    │
│ [Data De] [Data Até]     │  ┌─────────────────────────────────────┐ │
│ [Status ▼] [Cliente]     │  │tabDadosOS: dados gerais da OS        │ │
│ [Placa]   [Buscar]       │  │tabItens: sub-grid peças + serviços   │ │
│                          │  │tabFinanceiro: totais e pagamento      │ │
│ TStringGrid (Listagem)   │  └─────────────────────────────────────┘ │
│ Num | Status | Cliente   │                                          │
│ Placa| Abertura | Total  │  TToolBar:                               │
│                          │  [Nova OS][Salvar][Cancelar OS]          │
│ Badges de contagem:      │  [Encerrar][Entregar][Imprimir]          │
│ [Abertas: 5]             │                                          │
│ [Em Andamento: 3]        │                                          │
│ [Prontas: 2]             │                                          │
└──────────────────────────┴─────────────────────────────────────────┘
```

**Campos da OS (tabDadosOS):**
- Número OS (auto-gerado), Status, Box/Prisma
- Placa (busca rápida com `F4` → lookup veículos)
- Modelo veículo (auto-preenchido), KM entrada/saída
- Cliente (auto-preenchido pelo veículo), Telefone
- Mecânico responsável (`TComboBox` carregado de colaboradores)
- Data abertura, Data previsão, Data conclusão
- Defeito relatado (`TMemo`), Serviço executado (`TMemo`)

**Sub-grid de itens (tabItens):**

```pascal
// Estrutura do TStringGrid de peças na OS
// Colunas: # | Código | Descrição | Qtd | Vlr Unit | Desconto | Total
// Botões: [+ Peça] [-] [Buscar Peça F4]
// Ao pressionar F4 → TfrmBuscaPeca modal (TStringGrid filtrável)

// Estrutura do TStringGrid de serviços na OS
// Colunas: # | Código | Descrição | Mecânico | Qtd | Vlr Unit | Desconto | Total
// Botões: [+ Serviço] [-] [Buscar Serviço F4]
```

**Rodapé financeiro (tabFinanceiro):**
- Total Peças (somente leitura), Total Serviços (somente leitura)
- Desconto (editável)
- **Total Geral** (em destaque, fonte maior)
- Forma de pagamento (`TComboBox`)
- Valor pago
- **Saldo** = Total Geral - Valor Pago (negrito vermelho se > 0)

### 5.7 Financeiro

#### Caixa (sigo_frmCaixa)

```
┌──────────────────────────┬─────────────────────────────────────────┐
│ Seleção de Data          │ Resumo do Dia                           │
│ TCalendar (nativo LCL)   │  lblEntradas: R$ 1.250,00 (verde)       │
│                          │  lblSaidas:   R$   380,00 (vermelho)    │
│                          │  lblSaldo:    R$   870,00 (azul)        │
├──────────────────────────┴─────────────────────────────────────────┤
│ TToolBar: [Incluir] [Alterar] [Excluir] | [Gerar Recibo] [Transferir]│
├─────────────────────────────────────────────────────────────────────┤
│ TStringGrid (movimentos do dia)                                     │
│ # | Tipo | Categoria | Descrição | Forma Pag | Valor                │
│ — linhas ENTRADA em verde, SAÍDA em vermelho                        │
└─────────────────────────────────────────────────────────────────────┘
```

#### Contas a Receber / Pagar

**Filtros:** Busca por nome, forma de pagamento (`TComboBox`), data de (`TDateTimePicker`) / até, status (`TComboBox`).

**Grid com cores por status:**

| Status | Cor |
|--------|-----|
| VENCIDA | `COR_LINHA_CRITICA` (rosa) |
| ABERTA próxima ao vencer (≤ 3 dias) | `COR_LINHA_AVISO` (amarelo) |
| PARCIAL | Laranja suave `$00FFE4B5` |
| PAGA / CANCELADA | `COR_LINHA_IMPAR` (cinza) |

---

## 6. Infraestrutura

### 6.1 Conexão com SQLite (sigo_DBConnection)

```pascal
// Singleton de conexão — TSQLite3Connection nativo do Lazarus
unit sigo_DBConnection;

type
  TsigoDBConnection = class
  private
    class var FInstancia: TsigoDBConnection;
    FCon: TSQLite3Connection;
    FTran: TSQLTransaction;
    procedure Conectar;
  public
    class function Instancia: TsigoDBConnection;
    function NovaQuery: TSQLQuery;
    procedure ExecutarSQL(const ASQL: string);
    procedure Commit;
    procedure Rollback;
    property Conexao: TSQLite3Connection read FCon;
    property Transacao: TSQLTransaction  read FTran;
  end;
```

### 6.2 BaseRepository

```pascal
// Operações CRUD genéricas com TSQLQuery
type
  TsigoBaseRepository = class
  protected
    FDB: TsigoDBConnection;
    FTabela: string;
    function NovaQuery: TSQLQuery;
    procedure ExecutarSQL(const ASQL: string; AParams: array of Variant);
  public
    constructor Create(const ATabela: string);
    function BuscarPorID(AID: Integer): TSQLQuery;
    function Listar(const AFiltro: string = ''): TSQLQuery;
    procedure Excluir(AID: Integer);
  end;
```

### 6.3 Logger

```pascal
// Log em arquivo texto rotacionado por dia
// Arquivo: bin/logs/sigo_AAAAMMDD.log
// Nível: DEBUG, INFO, WARN, ERROR
procedure TsigoLogger.Registrar(ANivel, AMensagem: string);
var
  F: TextFile;
  NomeArq: string;
begin
  NomeArq := ExtractFilePath(ParamStr(0)) + 'logs\sigo_'
           + FormatDateTime('yyyymmdd', Date) + '.log';
  AssignFile(F, NomeArq);
  if FileExists(NomeArq) then Append(F) else Rewrite(F);
  try
    WriteLn(F, Format('[%s] [%s] %s',
      [FormatDateTime('hh:nn:ss', Now), ANivel, AMensagem]));
  finally
    CloseFile(F);
  end;
end;
```

### 6.4 Consulta de CEP (sigo_ConsultaCEP)

```pascal
// 1. Busca cache local (cep_cache)
// 2. Se não encontrou E tem internet → ViaCEP API
// 3. Salva no cache para uso offline
// Usa TFPHTTPClient (nativo do FPC — unit fphttpclient)
uses fphttpclient, fpjson, jsonparser;

procedure TsigoConsultaCEP.Buscar(const ACEP: string;
  out ALgr, ABairro, ACidade, AUF: string);
var
  Cliente: TFPHTTPClient;
  JSON: TJSONObject;
  Resposta: string;
begin
  // 1. Cache
  if BuscarCache(ACEP, ALgr, ABairro, ACidade, AUF) then Exit;

  // 2. Online
  Cliente := TFPHTTPClient.Create(nil);
  try
    Resposta := Cliente.Get('https://viacep.com.br/ws/' + ACEP + '/json/');
    JSON := GetJSON(Resposta) as TJSONObject;
    try
      ALgr   := JSON.Get('logradouro', '');
      ABairro := JSON.Get('bairro', '');
      ACidade := JSON.Get('localidade', '');
      AUF    := JSON.Get('uf', '');
      SalvarCache(ACEP, ALgr, ABairro, ACidade, AUF);
    finally
      JSON.Free;
    end;
  finally
    Cliente.Free;
  end;
end;
```

### 6.5 Backup ao Fechar

```pascal
// TfrmMain.FormCloseQuery — backup obrigatório
procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Resp: Integer;
  Destino, Origem, ArqDestino: string;
begin
  Resp := MessageDlg(
    'Deseja fazer backup antes de fechar?' + LineEnding +
    'Recomendamos salvar em um pen drive.',
    mtConfirmation, [mbYes, mbNo, mbCancel], 0);

  case Resp of
    mrYes:
    begin
      if SelectDirectory('Selecione a pasta de backup:', '', Destino) then
      begin
        Origem     := Config.Banco;
        ArqDestino := Destino + PathDelim + 'backup_sigo_'
                    + FormatDateTime('yyyymmdd_hhnnss', Now) + '.db';
        if CopyFile(PChar(Origem), PChar(ArqDestino), False) then
          ShowMessage('Backup realizado com sucesso!')
        else
          ShowMessage('Erro ao realizar backup!');
        CanClose := True;
      end else
        CanClose := False;
    end;
    mrNo:     CanClose := True;
    mrCancel: CanClose := False;
  end;
end;
```

---

## 7. Banco de Dados

> DDL completo em `DDL_SIGO_001.sql`

### 7.1 Tabelas do Sistema

| Tabela | Descrição |
|--------|-----------|
| `empresa` | Dados da oficina (razão social, CNPJ, logo BLOB) |
| `usuarios` | Login com hash SHA-256, perfis ADMIN/ATENDENTE/MECANICO |
| `clientes` | PF/PJ, endereço completo, foto BLOB |
| `fornecedores` | Dados do fornecedor com representante |
| `colaboradores` | Funcionários com especialidade e % comissão |
| `veiculos` | Associado a cliente, com FIPE local |
| `fipe_marcas` | Marcas FIPE offline (tipo: carros/motos/caminhoes) |
| `fipe_modelos` | Modelos vinculados à marca |
| `fipe_anos` | Anos/versões por modelo |
| `categorias_peca` | Grupos de peças |
| `pecas` | Catálogo com 3 preços e controle de estoque |
| `servicos` | Tabela de serviços com valor padrão |
| `agenda` | Agendamentos com hora, cliente, placa |
| `ordens_servico` | OS principal (status, datas, KM, totais) |
| `os_itens_peca` | Peças da OS (baixa automática via trigger) |
| `os_itens_servico` | Serviços da OS |
| `estoque_movimentos` | Rastreio de entradas e saídas |
| `vendas` | Vendas diretas (comanda) |
| `venda_itens` | Itens de cada venda |
| `caixa_movimentos` | Lançamentos diários de caixa |
| `contas_receber` | Financeiro a receber |
| `contas_pagar` | Financeiro a pagar |
| `cep_cache` | Cache offline de CEPs consultados |
| `cartas_modelos` | Modelos de carta reutilizáveis |
| `cartas_emitidas` | Histórico de cartas enviadas |
| `parametros` | Configurações chave-valor do sistema |

### 7.2 Triggers Automáticos

| Trigger | Ação |
|---------|------|
| `trg_os_peca_ins/upd/del` | Recalcula `total_pecas` e `total_geral` na OS |
| `trg_os_serv_ins/upd/del` | Recalcula `total_servicos` e `total_geral` na OS |
| `trg_baixa_estoque_ins` | Baixa automática de peças ao inserir em `os_itens_peca` |
| `trg_devolucao_estoque_del` | Devolve estoque ao remover item da OS |

### 7.3 Views

| View | Descrição |
|------|-----------|
| `vw_os_completa` | OS com cliente, veículo, mecânico e saldo devedor |
| `vw_estoque_critico` | Peças com estoque ≤ mínimo |
| `vw_contas_vencidas` | Contas a receber/pagar em atraso |
| `vw_agenda_hoje` | Agendamentos do dia atual |

---

## 8. Relatórios com LazReport

Todos os relatórios usam `TfrReport` + `TfrDBDataSet` (LazReport nativo).

| Relatório | Arquivo `.lrf` | Descrição |
|-----------|---------------|-----------|
| OS Impressa | `os_impressa.lrf` | OS completa para entrega ao cliente |
| Recibo de Pagamento | `recibo.lrf` | Recibo de pagamento da OS |
| Ficha do Cliente | `ficha_cliente.lrf` | Histórico de OS e veículos |
| Lista de Peças | `lista_pecas.lrf` | Estoque atual com alertas |
| Agenda do Dia | `agenda_dia.lrf` | Agendamentos por data |
| Caixa Diário | `caixa_diario.lrf` | Movimentos do dia |
| Contas a Receber | `contas_receber.lrf` | Por período e status |
| Contas a Pagar | `contas_pagar.lrf` | Por período e status |

---

## 9. Segurança

| Requisito | Implementação |
|-----------|---------------|
| Senha nunca em texto plano | SHA-256 via FPC `sha256` unit |
| Controle de acesso | Verificar `FUsuarioLogado.Perfil` antes de operações críticas |
| Exclusão lógica | Usar campo `ativo=0` em vez de DELETE físico para registros principais |
| SQL Injection | Sempre usar parâmetros `TSQLQuery.ParamByName` — NUNCA concatenar strings SQL |
| Backup obrigatório | Dialog no `FormCloseQuery` sem possibilidade de ignorar silenciosamente |
| Log de acesso | Registrar login/logout e operações críticas no `sigo_Logger` |

---

## 10. Status Herdado do SIGO_LAZARUS (ponto de partida)

| Módulo | Status no SIGO_LAZARUS | Ação para SIGO_001 |
|--------|----------------------|---------------------|
| Infraestrutura (Config, DB, Logger, Utils) | ✅ Completo | Renomear prefix `mec_` → `sigo_` e revisar |
| BaseRepository | ✅ Completo | Migrar |
| Model Clientes | ✅ Completo | Migrar |
| Repo/Ctrl/View Clientes | ✅ Completo | Migrar + aplicar novo design |
| Model/Repo OS | ✅ Completo | Migrar |
| Ctrl/View OS | ✅ Completo | Migrar + aplicar novo design |
| Model Veículos | ✅ Completo | Migrar |
| Repo/Ctrl/View Veículos | ⚠️ Parcial | Completar |
| Peças, Serviços, Colaboradores | ❌ Pendente | Criar do zero |
| Financeiro (Caixa, CR, CP) | ❌ Pendente | Criar do zero |
| Dashboard (TAChart) | ❌ Pendente | Criar do zero |
| Login | ❌ Pendente | Criar do zero |
| TfrmBase | ❌ Pendente | Criar do zero |
| Relatórios (LazReport) | ❌ Pendente | Criar do zero |
| Backup automático | ❌ Pendente | Criar do zero |

---

## 11. Ordem de Implementação Sugerida

```
Fase 1 — Fundação
  [1.1] sigo_Config, sigo_DBConnection, sigo_Logger, sigo_Utils
  [1.2] DDL do banco (sigo_ddl.sql) + seed inicial
  [1.3] sigo_frmLogin (autenticação SHA-256)
  [1.4] sigo_frmMain (layout principal com PageControl)
  [1.5] sigo_frmBase (pai de CRUDs)

Fase 2 — Cadastros Base
  [2.1] Clientes (Model → Repo → Ctrl → View)
  [2.2] Veículos (com FIPE offline encadeada)
  [2.3] Fornecedores
  [2.4] Colaboradores

Fase 3 — Operacional
  [3.1] Peças/Estoque (com precificação 3 margens)
  [3.2] Serviços
  [3.3] Agenda
  [3.4] Ordem de Serviço (core do sistema)
  [3.5] Vendas Diretas

Fase 4 — Financeiro
  [4.1] Caixa (com TCalendar nativo)
  [4.2] Contas a Receber
  [4.3] Contas a Pagar

Fase 5 — Relatórios e Finalização
  [5.1] LazReport: OS impressa + Recibo
  [5.2] LazReport: Listagens diversas
  [5.3] Dashboard (TAChart)
  [5.4] Cartas/Comunicação
  [5.5] Backup automático ao fechar
  [5.6] Configurações da empresa
```
