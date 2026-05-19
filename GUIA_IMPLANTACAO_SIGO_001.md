# Guia de Implantação — SIGO_001
### Como criar e executar o projeto do zero no Lazarus

**Data:** Maio/2026  
**Pré-requisito:** Lazarus 4.x + FPC 3.2.2+ instalados no Windows

---

## 1. Criar o Projeto no Lazarus

1. Abrir o Lazarus IDE
2. **File → New → Project → Application** → OK
3. Salvar em: `C:\legado\sigo_001\`
4. Nome do projeto: `sigo_001`
5. Arquivos gerados: `sigo_001.lpi`, `sigo_001.lpr`, `sigo_001.res`

---

## 2. Estrutura de Pastas a Criar

```
C:\legado\sigo_001\
├── database\        ← copiar DDL_SIGO_001.sql aqui
├── assets\
│   ├── icons\       ← PNG 16×16 e 24×24 dos ícones
│   └── reports\     ← templates LazReport (.lrf)
├── bin\
│   ├── config\
│   └── logs\
└── src\
    ├── infra\
    ├── models\
    ├── repositories\
    ├── controllers\
    └── views\
```

Criar no terminal PowerShell:
```powershell
$base = "C:\legado\sigo_001"
@("database","assets\icons","assets\reports","bin\config",
  "bin\logs","src\infra","src\models","src\repositories",
  "src\controllers","src\views") | ForEach-Object {
    New-Item -ItemType Directory -Force -Path "$base\$_"
}
```

---

## 3. Criar o Banco de Dados

```powershell
# Opção A: via SQLite3.exe (linha de comando)
cd C:\legado\sigo_001\bin
sqlite3.exe sigo.db < ..\database\DDL_SIGO_001.sql

# Opção B: via código Pascal no FormCreate do projeto
# A unit sigo_DBConnection cria o banco automaticamente se não existir
```

---

## 4. Configurar o sigo.ini

Criar `C:\legado\sigo_001\bin\config\sigo.ini`:

```ini
[Sistema]
NomeSistema=SIGO
Versao=1.0.0
Tema=DARK

[Banco]
Arquivo=sigo.db

[Log]
Diretorio=logs
Detalhado=0

[Sessao]
TimeoutMinutos=60
```

---

## 5. Ordem de Criação das Units (Fase 1)

Criar nesta sequência para evitar dependências circulares:

### 5.1 `src\infra\sigo_Config.pas`
```pascal
unit sigo_Config;
{$mode objfpc}{$H+}
// Singleton: lê sigo.ini, expõe NomeSistema, Versao, Banco, LogDir
```

### 5.2 `src\infra\sigo_Logger.pas`
```pascal
unit sigo_Logger;
{$mode objfpc}{$H+}
// Singleton: grava em bin/logs/sigo_AAAAMMDD.log
// procedure Info(msg), Warn(msg), Error(msg), Debug(msg)
```

### 5.3 `src\infra\sigo_DBConnection.pas`
```pascal
unit sigo_DBConnection;
{$mode objfpc}{$H+}
// Singleton: TSQLite3Connection + TSQLTransaction
// Cria o banco (executa DDL) se não existir
```

### 5.4 `src\infra\sigo_Utils.pas`
```pascal
unit sigo_Utils;
{$mode objfpc}{$H+}
// Funções puras: FormatMoeda, FormatData, FormatCPF, FormatCNPJ,
// SomenteNumeros, SQLiteParaData, DataParaSQLite, GerarNumeroOS
```

### 5.5 `src\infra\sigo_BaseRepository.pas`
```pascal
unit sigo_BaseRepository;
{$mode objfpc}{$H+}
// CRUD genérico com TSQLQuery + parâmetros
```

---

## 6. Adicionar Packages ao Projeto

No Lazarus: **Project → Project Inspector → Required Packages → Add**

| Package | Para que serve |
|---------|----------------|
| `LCLBase` | Componentes básicos LCL |
| `SQLDBLaz` | TSQLite3Connection, TSQLQuery |
| `TAChartLazarusPkg` | TChart, TBarSeries, TPieSeries |
| `lazreport` | TfrReport, TfrDBDataSet |
| `DateTimeCtrls` | TDateTimePicker |

> **Nota:** `SQLDBLaz` exige a `sqlite3.dll` na mesma pasta do executável.  
> Copiar de: `C:\legado\sqlite-dll-win-x86-3530000\sqlite3.dll`  
> Para: `C:\legado\sigo_001\bin\sqlite3.dll`

---

## 7. Configurar o sigo_001.lpr

```pascal
program sigo_001;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Forms, Interfaces,
  sigo_Config, sigo_DBConnection, sigo_Logger, sigo_Utils,
  sigo_frmLogin  in 'src\views\sigo_frmLogin.pas'  {frmLogin},
  sigo_frmMain   in 'src\views\sigo_frmMain.pas'   {frmMain};

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;

  // Verificar/criar banco antes de qualquer form
  DBConnection.Verificar;
  Logger.Info('SIGO_001 iniciado. Versão: ' + Config.Versao);

  Application.CreateForm(TfrmLogin, frmLogin);
  Application.Run;
end.
```

---

## 8. Diferenças do SIGO_LAZARUS → SIGO_001

| Item | SIGO_LAZARUS | SIGO_001 |
|------|-------------|---------|
| Prefixo de units | `mec_` | `sigo_` |
| TfrmBase | Não implementado | Obrigatório — todos os CRUDs herdam |
| Login | Não implementado | Fase 1 — com SHA-256 |
| Dashboard | Não implementado | TAChart nativo |
| Design | Sem tema | Tema escuro com cores semânticas |
| Toolbar | TButton soltos | TToolBar com TImageList |
| Atalhos | Parcial | F2/F3/Del/F5/Esc em todos os CRUDs |
| Backup | Não implementado | FormCloseQuery obrigatório |
| CEP | Não implementado | Cache + ViaCEP com TFPHTTPClient |
| Relatórios | Não implementado | LazReport com templates .lrf |
| Gráficos | Não implementado | TAChart nativo |

---

## 9. Referências Rápidas

| Ação | Onde está |
|------|-----------|
| Spec completa do sistema | `SPEC_SIGO_001.md` |
| DDL do banco de dados | `DDL_SIGO_001.sql` |
| Guia de componentes LCL | `SPEC_COMPONENTES_LAZARUS.md` |
| Projeto legado Delphi | `c:\legado\codigo-legado-*\Rescued\` |
| Projeto base Lazarus | `c:\legado\sigo_lazarus\` |
| Spec detalhada anterior | `c:\legado\criação de spec\SPEC_OFICINA_MECANICA.md` |
