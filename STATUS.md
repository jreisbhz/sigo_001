# SIGO_001 — Status do Projeto

**Data:** 19/05/2026  
**Commit:** `3336ba8` — feat: commit inicial — SIGO 001 v1.0.0  
**GitHub:** https://github.com/jreisbhz/sigo_001  
**Projeto local:** `C:\legado\sigo_001`

---

## Estado Atual

### ✅ O que está funcionando
- **Compilação:** 6606 linhas, zero erros (lazbuild + FPC 3.2.2 / i386-win32)
- **Binário:** `C:\legado\sigo_001\bin\sigo_001.exe`
- **Banco de dados:** `C:\legado\sigo_001\bin\sigo.db` conecta (SQLite, 27 tabelas)
- **Login:** janela `TfrmLogin` exibe, autenticação SHA-256 funcionando
- **Usuário padrão:** login `master` / senha `123456`
- **Formulário principal:** `TfrmMain` abre após login com menus e speed buttons
- **Eventos base:** todos wired via `sigo_frmBase.lfm` (botões CRUD, grid, busca)
- **Eventos derivados:** todos os 15 forms derivados têm eventos wired no FormCreate
- **Git:** repositório no GitHub com 1 commit (master)

### ⏳ O que falta (próximos passos)
- **Teste funcional real de cada módulo** (nenhum foi testado com dados ainda):
  - [ ] Clientes — CRUD completo, busca CEP, CPF/CNPJ
  - [ ] Veículos — busca por marca/modelo/placa, vinculação ao cliente
  - [ ] Ordens de Serviço (OS) — peças, serviços, mecânico, desconto
  - [ ] Peças — cálculo de preços por margem
  - [ ] Serviços
  - [ ] Colaboradores
  - [ ] Fornecedores — busca CEP, tipo PF/PJ
  - [ ] Vendas — itens, desconto
  - [ ] Contas a Pagar / Contas a Receber — filtros por data
  - [ ] Caixa — movimento por dia, calendário
  - [ ] Agenda
  - [ ] Cartas — templates, geração, impressão
  - [ ] Relatórios — visualizar, imprimir
  - [ ] Configurações — empresa, usuários, logo
- **Impressão de relatórios** (não implementado — usa LazReport ou FastReport?)
- **Consulta CEP** (`sigo_ConsultaCEP.pas`) — testar integração online
- **Exportação/Importação de dados**

### ⚠️ Pendências técnicas conhecidas
- `bin/units/sigo_frm*.o/.ppu` são gerados na compilação e ignorados pelo git
- Se mudar apenas um `.lfm`, **deletar o `.o` correspondente** antes de recompilar:
  ```powershell
  Remove-Item "C:\legado\sigo_001\bin\units\sigo_frmXxx.o"
  Remove-Item "C:\legado\sigo_001\bin\units\sigo_frmXxx.ppu"
  ```
- Para rebuild completo das views:
  ```powershell
  Remove-Item "C:\legado\sigo_001\bin\units\sigo_frm*.o" -ErrorAction SilentlyContinue
  Remove-Item "C:\legado\sigo_001\bin\units\sigo_frm*.ppu" -ErrorAction SilentlyContinue
  ```

---

## Comandos Essenciais

### Compilar
```powershell
cd C:\legado\sigo_001
$p = Start-Process -FilePath "C:\lazarus\lazbuild.exe" -ArgumentList ("--pcp=C:\lazarus","sigo_001.lpi") -WorkingDirectory "C:\legado\sigo_001" -Wait -PassThru -NoNewWindow -RedirectStandardOutput "build_out.txt" -RedirectStandardError "build_err.txt"
Write-Host "Exit: $($p.ExitCode)"
Get-Content build_out.txt | Select-Object -Last 5
```

### Rodar
```powershell
Start-Process -FilePath "C:\legado\sigo_001\bin\sigo_001.exe" -WorkingDirectory "C:\legado\sigo_001\bin"
```

### Ver log
```powershell
Get-ChildItem "C:\legado\sigo_001\bin\logs\" | Sort-Object LastWriteTime | Select-Object -Last 1 | Get-Content
```

### Git push após mudanças
```powershell
git add -A
git commit -m "fix: descrição"
git push
```

---

## Arquitetura Resumida

```
sigo_001.lpr  →  TfrmLogin (ShowModal)
                   └─ mrOK → Application.CreateForm(TfrmMain) → Application.Run
                   
TfrmMain      →  AbrirModulo(TfrmXxx)  [tabs no TPageControl]

TfrmBase      →  FormCreate: ConfigurarToolbar + ConfigurarGrid + InicializarFormulario
                              + AtualizarBotoes + CarregarGrid
              ←  herdado por todos os 15 forms CRUD
```

**Camadas:**
- `src/views/` — Forms (LFM + PAS)
- `src/controllers/` — TsigoCtrl* (lógica de negócio)
- `src/repositories/` — TsigoRepo* (acesso ao banco)
- `src/models/` — TsigoModel* (entidades)
- `src/infra/` — DBConnection, Config, Logger, Utils, ConsultaCEP

**Banco:** SQLite via FPC SQLDB (`sqlite3conn`, `sqldb`, `db`)  
**Auth:** SHA-256 (`src/infra/sha256.pas`)  
**Config:** `bin/config/sigo.ini`

---

## Ferramentas

| Ferramenta | Caminho |
|---|---|
| FPC 3.2.2 | `C:\lazarus\fpc\3.2.2\bin\i386-win32\fpc.exe` |
| Lazarus 4.6 | `C:\lazarus\` |
| lazbuild | `C:\lazarus\lazbuild.exe` |
| SQLite DLL | `C:\legado\sigo_001\bin\sqlite3.dll` (x86) |
| Banco de dados | `C:\legado\sigo_001\bin\sigo.db` |
