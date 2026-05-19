-- =============================================================================
-- SIGO_001 — DDL COMPLETO SQLite 3
-- Sistema Integrado de Gestão de Oficinas Mecânicas
-- Versão: 1.0.0  |  Data: Maio/2026
-- =============================================================================

PRAGMA foreign_keys  = OFF;
PRAGMA journal_mode  = WAL;       -- Write-Ahead Logging: melhor performance
PRAGMA synchronous   = NORMAL;    -- Balanceia performance x segurança
PRAGMA cache_size    = 10000;     -- Cache em memória (~40 MB)
PRAGMA temp_store    = MEMORY;

-- =============================================================================
-- TABELA: empresa
-- =============================================================================
CREATE TABLE IF NOT EXISTS empresa (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  razao_social  TEXT    NOT NULL,
  fantasia      TEXT,
  cnpj          TEXT,
  cpf           TEXT,
  ie            TEXT,
  im            TEXT,
  logradouro    TEXT,
  numero        TEXT,
  complemento   TEXT,
  bairro        TEXT,
  cidade        TEXT,
  uf            TEXT    DEFAULT 'SP',
  cep           TEXT,
  telefone      TEXT,
  celular       TEXT,
  email         TEXT,
  site          TEXT,
  logo          BLOB,
  ativo         INTEGER NOT NULL DEFAULT 1
);

-- =============================================================================
-- TABELA: usuarios
-- =============================================================================
CREATE TABLE IF NOT EXISTS usuarios (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  nome           TEXT    NOT NULL,
  login          TEXT    NOT NULL UNIQUE COLLATE NOCASE,
  senha_hash     TEXT    NOT NULL,                  -- SHA-256 da senha
  perfil         TEXT    NOT NULL DEFAULT 'ATENDENTE'
                   CHECK (perfil IN ('ADMIN','ATENDENTE','MECANICO')),
  ativo          INTEGER NOT NULL DEFAULT 1,
  criado_em      TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  ultimo_acesso  TEXT
);

-- =============================================================================
-- TABELA: clientes
-- =============================================================================
CREATE TABLE IF NOT EXISTS clientes (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  tipo_pessoa     TEXT    NOT NULL DEFAULT 'F'
                    CHECK (tipo_pessoa IN ('F','J')),
  nome            TEXT    NOT NULL COLLATE NOCASE,
  fantasia        TEXT    COLLATE NOCASE,
  cpf_cnpj        TEXT,
  rg_ie           TEXT,
  data_nasc       TEXT,                              -- formato: yyyy-mm-dd
  logradouro      TEXT,
  numero          TEXT,
  complemento     TEXT,
  bairro          TEXT,
  cidade          TEXT,
  uf              TEXT,
  cep             TEXT,
  telefone        TEXT,
  celular         TEXT,
  celular2        TEXT,
  email           TEXT,
  observacoes     TEXT,
  limite_credito  REAL    NOT NULL DEFAULT 0.00,
  foto            BLOB,
  ativo           INTEGER NOT NULL DEFAULT 1,
  criado_em       TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  atualizado_em   TEXT
);

CREATE INDEX IF NOT EXISTS idx_cliente_nome     ON clientes(nome);
CREATE INDEX IF NOT EXISTS idx_cliente_cpfcnpj  ON clientes(cpf_cnpj);
CREATE INDEX IF NOT EXISTS idx_cliente_celular  ON clientes(celular);

-- =============================================================================
-- TABELA: fornecedores
-- =============================================================================
CREATE TABLE IF NOT EXISTS fornecedores (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  tipo_pessoa   TEXT    NOT NULL DEFAULT 'J'
                  CHECK (tipo_pessoa IN ('F','J')),
  razao_social  TEXT    NOT NULL COLLATE NOCASE,
  fantasia      TEXT    COLLATE NOCASE,
  cnpj_cpf      TEXT,
  ie            TEXT,
  logradouro    TEXT,
  numero        TEXT,
  complemento   TEXT,
  bairro        TEXT,
  cidade        TEXT,
  uf            TEXT,
  cep           TEXT,
  telefone      TEXT,
  celular       TEXT,
  email         TEXT,
  contato       TEXT,                               -- nome do representante
  observacoes   TEXT,
  ativo         INTEGER NOT NULL DEFAULT 1,
  criado_em     TEXT    NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE INDEX IF NOT EXISTS idx_fornecedor_nome ON fornecedores(razao_social);

-- =============================================================================
-- TABELA: colaboradores
-- =============================================================================
CREATE TABLE IF NOT EXISTS colaboradores (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario_id     INTEGER,
  nome           TEXT    NOT NULL COLLATE NOCASE,
  cpf            TEXT,
  rg             TEXT,
  data_nasc      TEXT,
  cargo          TEXT,
  especialidade  TEXT,
  telefone       TEXT,
  celular        TEXT,
  email          TEXT,
  data_admissao  TEXT,
  salario        REAL    DEFAULT 0.00,
  comissao_pct   REAL    NOT NULL DEFAULT 0.00,
  ativo          INTEGER NOT NULL DEFAULT 1,
  criado_em      TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

-- =============================================================================
-- TABELA: fipe_marcas
-- =============================================================================
CREATE TABLE IF NOT EXISTS fipe_marcas (
  id    INTEGER PRIMARY KEY,
  nome  TEXT    NOT NULL COLLATE NOCASE,
  tipo  TEXT    NOT NULL DEFAULT 'carros'
          CHECK (tipo IN ('carros','motos','caminhoes'))
);

-- =============================================================================
-- TABELA: fipe_modelos
-- =============================================================================
CREATE TABLE IF NOT EXISTS fipe_modelos (
  id        INTEGER PRIMARY KEY,
  marca_id  INTEGER NOT NULL,
  nome      TEXT    NOT NULL COLLATE NOCASE,
  FOREIGN KEY (marca_id) REFERENCES fipe_marcas(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_fipe_modelo_marca ON fipe_modelos(marca_id);

-- =============================================================================
-- TABELA: fipe_anos
-- =============================================================================
CREATE TABLE IF NOT EXISTS fipe_anos (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  modelo_id  INTEGER NOT NULL,
  codigo     TEXT    NOT NULL,
  nome       TEXT    NOT NULL,
  FOREIGN KEY (modelo_id) REFERENCES fipe_modelos(id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_fipe_ano_modelo ON fipe_anos(modelo_id);

-- =============================================================================
-- TABELA: veiculos
-- =============================================================================
CREATE TABLE IF NOT EXISTS veiculos (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  cliente_id      INTEGER NOT NULL,
  placa           TEXT    NOT NULL COLLATE NOCASE,
  marca           TEXT,
  modelo          TEXT,
  versao          TEXT,
  ano_fabricacao  INTEGER,
  ano_modelo      INTEGER,
  cor             TEXT,
  combustivel     TEXT    DEFAULT 'FLEX'
                    CHECK (combustivel IN
                      ('GASOLINA','ETANOL','FLEX','DIESEL','GNV','ELETRICO','HIBRIDO')),
  renavam         TEXT,
  chassi          TEXT,
  km_atual        INTEGER NOT NULL DEFAULT 0,
  observacoes     TEXT,
  ativo           INTEGER NOT NULL DEFAULT 1,
  criado_em       TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  FOREIGN KEY (cliente_id) REFERENCES clientes(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_veiculo_placa   ON veiculos(placa);
CREATE INDEX IF NOT EXISTS idx_veiculo_cliente ON veiculos(cliente_id);

-- =============================================================================
-- TABELA: categorias_peca
-- =============================================================================
CREATE TABLE IF NOT EXISTS categorias_peca (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  nome      TEXT    NOT NULL COLLATE NOCASE,
  descricao TEXT,
  ativo     INTEGER NOT NULL DEFAULT 1
);

-- =============================================================================
-- TABELA: pecas
-- =============================================================================
CREATE TABLE IF NOT EXISTS pecas (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  categoria_id       INTEGER,
  fornecedor_id      INTEGER,
  codigo             TEXT    NOT NULL UNIQUE COLLATE NOCASE,
  codigo_fabricante  TEXT,
  codigo_barras      TEXT,
  descricao          TEXT    NOT NULL COLLATE NOCASE,
  unidade            TEXT    NOT NULL DEFAULT 'UN',
  localizacao        TEXT,
  marca              TEXT,
  estoque_atual      REAL    NOT NULL DEFAULT 0.000,
  estoque_minimo     REAL    NOT NULL DEFAULT 0.000,
  estoque_maximo     REAL    NOT NULL DEFAULT 0.000,
  preco_custo        REAL    NOT NULL DEFAULT 0.00,
  margem_vista       REAL    NOT NULL DEFAULT 0.00,   -- R$ sobre custo
  margem_prazo       REAL    NOT NULL DEFAULT 0.00,
  margem_atacado     REAL    NOT NULL DEFAULT 0.00,
  preco_vista        REAL    NOT NULL DEFAULT 0.00,   -- custo + margem_vista
  preco_prazo        REAL    NOT NULL DEFAULT 0.00,
  preco_atacado      REAL    NOT NULL DEFAULT 0.00,
  observacoes        TEXT,
  ativo              INTEGER NOT NULL DEFAULT 1,
  criado_em          TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  atualizado_em      TEXT,
  FOREIGN KEY (categoria_id)  REFERENCES categorias_peca(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_peca_codigo    ON pecas(codigo);
CREATE INDEX IF NOT EXISTS idx_peca_descricao ON pecas(descricao);
CREATE INDEX IF NOT EXISTS idx_peca_barras    ON pecas(codigo_barras);

-- =============================================================================
-- TABELA: servicos
-- =============================================================================
CREATE TABLE IF NOT EXISTS servicos (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo          TEXT    UNIQUE COLLATE NOCASE,
  nome            TEXT    NOT NULL COLLATE NOCASE,
  descricao       TEXT,
  valor_padrao    REAL    NOT NULL DEFAULT 0.00,
  tempo_estimado  INTEGER,                           -- minutos
  ativo           INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_servico_nome ON servicos(nome);

-- =============================================================================
-- TABELA: agenda
-- =============================================================================
CREATE TABLE IF NOT EXISTS agenda (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  data_agendamento  TEXT    NOT NULL,                -- yyyy-mm-dd
  hora              TEXT    NOT NULL,                -- HH:MM
  dia_semana        TEXT,
  compromisso       TEXT    NOT NULL,
  atendente_id      INTEGER,
  cliente_id        INTEGER,
  veiculo_placa     TEXT,
  cliente_whatsapp  TEXT,
  observacoes       TEXT,
  criado_em         TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  FOREIGN KEY (atendente_id) REFERENCES colaboradores(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (cliente_id)   REFERENCES clientes(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_agenda_data ON agenda(data_agendamento);

-- =============================================================================
-- TABELA: ordens_servico
-- =============================================================================
CREATE TABLE IF NOT EXISTS ordens_servico (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  numero            TEXT    NOT NULL UNIQUE,          -- ex: OS-2026-0001
  cliente_id        INTEGER NOT NULL,
  veiculo_id        INTEGER NOT NULL,
  colaborador_id    INTEGER,
  usuario_abriu     INTEGER,
  usuario_fechou    INTEGER,
  status            TEXT    NOT NULL DEFAULT 'ABERTA'
                      CHECK (status IN
                        ('ORCAMENTO','ABERTA','EM_ANDAMENTO',
                         'AGUARDANDO_PECA','PRONTO','ENTREGUE','CANCELADA')),
  box_prisma        TEXT,
  data_abertura     TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  data_previsao     TEXT,
  data_conclusao    TEXT,
  data_entrega      TEXT,
  km_entrada        INTEGER NOT NULL DEFAULT 0,
  km_saida          INTEGER,
  defeito_relatado  TEXT,
  servico_executado TEXT,
  observacoes       TEXT,
  desconto          REAL    NOT NULL DEFAULT 0.00,
  total_pecas       REAL    NOT NULL DEFAULT 0.00,
  total_servicos    REAL    NOT NULL DEFAULT 0.00,
  total_geral       REAL    NOT NULL DEFAULT 0.00,
  forma_pagamento   TEXT,
  valor_pago        REAL    NOT NULL DEFAULT 0.00,
  criado_em         TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  atualizado_em     TEXT,
  FOREIGN KEY (cliente_id)     REFERENCES clientes(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (veiculo_id)     REFERENCES veiculos(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (colaborador_id) REFERENCES colaboradores(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_os_numero  ON ordens_servico(numero);
CREATE INDEX IF NOT EXISTS idx_os_status  ON ordens_servico(status);
CREATE INDEX IF NOT EXISTS idx_os_cliente ON ordens_servico(cliente_id);
CREATE INDEX IF NOT EXISTS idx_os_placa   ON ordens_servico(veiculo_id);

-- =============================================================================
-- TABELA: os_itens_servico
-- =============================================================================
CREATE TABLE IF NOT EXISTS os_itens_servico (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  os_id           INTEGER NOT NULL,
  servico_id      INTEGER,
  colaborador_id  INTEGER,
  descricao       TEXT    NOT NULL,
  quantidade      REAL    NOT NULL DEFAULT 1.00,
  valor_unitario  REAL    NOT NULL DEFAULT 0.00,
  desconto        REAL    NOT NULL DEFAULT 0.00,
  total           REAL    NOT NULL DEFAULT 0.00,
  FOREIGN KEY (os_id)          REFERENCES ordens_servico(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (servico_id)     REFERENCES servicos(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (colaborador_id) REFERENCES colaboradores(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_os_serv_os ON os_itens_servico(os_id);

-- =============================================================================
-- TABELA: os_itens_peca
-- =============================================================================
CREATE TABLE IF NOT EXISTS os_itens_peca (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  os_id           INTEGER NOT NULL,
  peca_id         INTEGER,
  descricao       TEXT    NOT NULL,
  quantidade      REAL    NOT NULL DEFAULT 1.000,
  valor_unitario  REAL    NOT NULL DEFAULT 0.00,
  valor_custo     REAL    NOT NULL DEFAULT 0.00,     -- para cálculo de margem
  desconto        REAL    NOT NULL DEFAULT 0.00,
  total           REAL    NOT NULL DEFAULT 0.00,
  FOREIGN KEY (os_id)   REFERENCES ordens_servico(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (peca_id) REFERENCES pecas(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_os_peca_os ON os_itens_peca(os_id);

-- =============================================================================
-- TABELA: estoque_movimentos
-- =============================================================================
CREATE TABLE IF NOT EXISTS estoque_movimentos (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  peca_id         INTEGER NOT NULL,
  os_id           INTEGER,
  tipo            TEXT    NOT NULL
                    CHECK (tipo IN ('ENTRADA','SAIDA','AJUSTE','DEVOLUCAO')),
  data_movimento  TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  quantidade      REAL    NOT NULL,
  valor_unitario  REAL    NOT NULL DEFAULT 0.00,
  estoque_antes   REAL    NOT NULL DEFAULT 0.00,
  estoque_depois  REAL    NOT NULL DEFAULT 0.00,
  motivo          TEXT,
  usuario_id      INTEGER,
  FOREIGN KEY (peca_id)    REFERENCES pecas(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (os_id)      REFERENCES ordens_servico(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_estmov_peca ON estoque_movimentos(peca_id);
CREATE INDEX IF NOT EXISTS idx_estmov_data ON estoque_movimentos(data_movimento);

-- =============================================================================
-- TABELA: vendas
-- =============================================================================
CREATE TABLE IF NOT EXISTS vendas (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  numero_comanda   TEXT    NOT NULL UNIQUE,
  data_venda       TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  cliente_id       INTEGER,
  atendente_id     INTEGER,
  desconto         REAL    NOT NULL DEFAULT 0.00,
  total            REAL    NOT NULL DEFAULT 0.00,
  data_entrega     TEXT,
  status           TEXT    NOT NULL DEFAULT 'ABERTA'
                     CHECK (status IN ('ABERTA','ENTREGUE','CANCELADA')),
  forma_pagamento  TEXT,
  observacoes      TEXT,
  criado_em        TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  FOREIGN KEY (cliente_id)   REFERENCES clientes(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (atendente_id) REFERENCES colaboradores(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

-- =============================================================================
-- TABELA: venda_itens
-- =============================================================================
CREATE TABLE IF NOT EXISTS venda_itens (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  venda_id        INTEGER NOT NULL,
  peca_id         INTEGER,
  descricao       TEXT    NOT NULL,
  quantidade      REAL    NOT NULL DEFAULT 1.000,
  valor_unitario  REAL    NOT NULL DEFAULT 0.00,
  desconto        REAL    NOT NULL DEFAULT 0.00,
  total           REAL    NOT NULL DEFAULT 0.00,
  FOREIGN KEY (venda_id) REFERENCES vendas(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (peca_id)  REFERENCES pecas(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

-- =============================================================================
-- TABELA: caixa_movimentos
-- =============================================================================
CREATE TABLE IF NOT EXISTS caixa_movimentos (
  id                INTEGER PRIMARY KEY AUTOINCREMENT,
  os_id             INTEGER,
  conta_receber_id  INTEGER,
  tipo              TEXT    NOT NULL
                      CHECK (tipo IN ('ENTRADA','SAIDA')),
  categoria         TEXT,
  descricao         TEXT    NOT NULL,
  valor             REAL    NOT NULL,
  data_movimento    TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  forma_pagamento   TEXT,
  usuario_id        INTEGER,
  observacoes       TEXT,
  FOREIGN KEY (os_id) REFERENCES ordens_servico(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_caixa_data ON caixa_movimentos(data_movimento);
CREATE INDEX IF NOT EXISTS idx_caixa_tipo ON caixa_movimentos(tipo);

-- =============================================================================
-- TABELA: contas_receber
-- =============================================================================
CREATE TABLE IF NOT EXISTS contas_receber (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  os_id            INTEGER,
  cliente_id       INTEGER NOT NULL,
  descricao        TEXT    NOT NULL,
  valor            REAL    NOT NULL,
  valor_pago       REAL    NOT NULL DEFAULT 0.00,
  data_emissao     TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  data_vencimento  TEXT    NOT NULL,
  data_pagamento   TEXT,
  status           TEXT    NOT NULL DEFAULT 'ABERTA'
                     CHECK (status IN ('ABERTA','PARCIAL','PAGA','CANCELADA','VENCIDA')),
  forma_pagamento  TEXT,
  observacoes      TEXT,
  usuario_id       INTEGER,
  FOREIGN KEY (os_id)       REFERENCES ordens_servico(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (cliente_id)  REFERENCES clientes(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_cr_cliente     ON contas_receber(cliente_id);
CREATE INDEX IF NOT EXISTS idx_cr_vencimento  ON contas_receber(data_vencimento);
CREATE INDEX IF NOT EXISTS idx_cr_status      ON contas_receber(status);

-- =============================================================================
-- TABELA: contas_pagar
-- =============================================================================
CREATE TABLE IF NOT EXISTS contas_pagar (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  fornecedor_id    INTEGER,
  descricao        TEXT    NOT NULL,
  valor            REAL    NOT NULL,
  valor_pago       REAL    NOT NULL DEFAULT 0.00,
  data_emissao     TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  data_vencimento  TEXT    NOT NULL,
  data_pagamento   TEXT,
  status           TEXT    NOT NULL DEFAULT 'ABERTA'
                     CHECK (status IN ('ABERTA','PARCIAL','PAGA','CANCELADA','VENCIDA')),
  forma_pagamento  TEXT,
  observacoes      TEXT,
  FOREIGN KEY (fornecedor_id) REFERENCES fornecedores(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_cp_vencimento ON contas_pagar(data_vencimento);
CREATE INDEX IF NOT EXISTS idx_cp_status     ON contas_pagar(status);

-- =============================================================================
-- TABELA: cep_cache
-- =============================================================================
CREATE TABLE IF NOT EXISTS cep_cache (
  cep            TEXT    PRIMARY KEY,
  logradouro     TEXT,
  bairro         TEXT,
  cidade         TEXT,
  uf             TEXT,
  consultado_em  TEXT    NOT NULL DEFAULT (datetime('now','localtime'))
);

-- =============================================================================
-- TABELA: cartas_modelos
-- =============================================================================
CREATE TABLE IF NOT EXISTS cartas_modelos (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo TEXT    NOT NULL,
  corpo  TEXT    NOT NULL,
  ativo  INTEGER NOT NULL DEFAULT 1
);

-- =============================================================================
-- TABELA: cartas_emitidas
-- =============================================================================
CREATE TABLE IF NOT EXISTS cartas_emitidas (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  modelo_id     INTEGER,
  titulo        TEXT    NOT NULL,
  cliente_id    INTEGER,
  corpo         TEXT    NOT NULL,
  data_emissao  TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
  FOREIGN KEY (modelo_id)  REFERENCES cartas_modelos(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  FOREIGN KEY (cliente_id) REFERENCES clientes(id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

-- =============================================================================
-- TABELA: parametros
-- =============================================================================
CREATE TABLE IF NOT EXISTS parametros (
  chave     TEXT PRIMARY KEY,
  valor     TEXT,
  descricao TEXT
);

-- =============================================================================
-- TRIGGERS: Recálculo de Totais da OS
-- =============================================================================

-- ---- Serviços ---------------------------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_os_serv_after_ins
AFTER INSERT ON os_itens_servico
BEGIN
  UPDATE ordens_servico SET
    total_servicos = (SELECT COALESCE(SUM(total),0) FROM os_itens_servico WHERE os_id = NEW.os_id),
    total_geral    = (SELECT COALESCE(SUM(total),0) FROM os_itens_servico WHERE os_id = NEW.os_id)
                   + total_pecas - desconto,
    atualizado_em  = datetime('now','localtime')
  WHERE id = NEW.os_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_os_serv_after_upd
AFTER UPDATE ON os_itens_servico
BEGIN
  UPDATE ordens_servico SET
    total_servicos = (SELECT COALESCE(SUM(total),0) FROM os_itens_servico WHERE os_id = NEW.os_id),
    total_geral    = (SELECT COALESCE(SUM(total),0) FROM os_itens_servico WHERE os_id = NEW.os_id)
                   + total_pecas - desconto,
    atualizado_em  = datetime('now','localtime')
  WHERE id = NEW.os_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_os_serv_after_del
AFTER DELETE ON os_itens_servico
BEGIN
  UPDATE ordens_servico SET
    total_servicos = (SELECT COALESCE(SUM(total),0) FROM os_itens_servico WHERE os_id = OLD.os_id),
    total_geral    = (SELECT COALESCE(SUM(total),0) FROM os_itens_servico WHERE os_id = OLD.os_id)
                   + total_pecas - desconto,
    atualizado_em  = datetime('now','localtime')
  WHERE id = OLD.os_id;
END;

-- ---- Peças + Baixa de Estoque -----------------------------------------------
CREATE TRIGGER IF NOT EXISTS trg_os_peca_after_ins
AFTER INSERT ON os_itens_peca
BEGIN
  -- Recalcula totais da OS
  UPDATE ordens_servico SET
    total_pecas   = (SELECT COALESCE(SUM(total),0) FROM os_itens_peca WHERE os_id = NEW.os_id),
    total_geral   = total_servicos
                  + (SELECT COALESCE(SUM(total),0) FROM os_itens_peca WHERE os_id = NEW.os_id)
                  - desconto,
    atualizado_em = datetime('now','localtime')
  WHERE id = NEW.os_id;

  -- Registra movimentação de saída no estoque
  INSERT INTO estoque_movimentos
    (peca_id, os_id, tipo, quantidade, valor_unitario, estoque_antes, estoque_depois, motivo)
  SELECT
    NEW.peca_id, NEW.os_id, 'SAIDA', NEW.quantidade, NEW.valor_custo,
    estoque_atual,
    estoque_atual - NEW.quantidade,
    'Baixa automática OS ' || NEW.os_id
  FROM pecas WHERE id = NEW.peca_id;

  -- Atualiza estoque da peça
  UPDATE pecas SET
    estoque_atual = estoque_atual - NEW.quantidade,
    atualizado_em = datetime('now','localtime')
  WHERE id = NEW.peca_id;
END;

CREATE TRIGGER IF NOT EXISTS trg_os_peca_after_del
AFTER DELETE ON os_itens_peca
BEGIN
  -- Recalcula totais
  UPDATE ordens_servico SET
    total_pecas   = (SELECT COALESCE(SUM(total),0) FROM os_itens_peca WHERE os_id = OLD.os_id),
    total_geral   = total_servicos
                  + (SELECT COALESCE(SUM(total),0) FROM os_itens_peca WHERE os_id = OLD.os_id)
                  - desconto,
    atualizado_em = datetime('now','localtime')
  WHERE id = OLD.os_id;

  -- Estorno de estoque
  INSERT INTO estoque_movimentos
    (peca_id, os_id, tipo, quantidade, valor_unitario, estoque_antes, estoque_depois, motivo)
  SELECT
    OLD.peca_id, OLD.os_id, 'DEVOLUCAO', OLD.quantidade, OLD.valor_custo,
    estoque_atual,
    estoque_atual + OLD.quantidade,
    'Estorno automático OS ' || OLD.os_id
  FROM pecas WHERE id = OLD.peca_id;

  UPDATE pecas SET
    estoque_atual = estoque_atual + OLD.quantidade,
    atualizado_em = datetime('now','localtime')
  WHERE id = OLD.peca_id;
END;

-- Trigger: atualiza status de contas vencidas automaticamente ao consultar
CREATE TRIGGER IF NOT EXISTS trg_cr_vencimento
AFTER UPDATE OF status ON contas_receber
WHEN NEW.status = 'ABERTA'
  AND date(NEW.data_vencimento) < date('now','localtime')
BEGIN
  UPDATE contas_receber SET status = 'VENCIDA' WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS trg_cp_vencimento
AFTER UPDATE OF status ON contas_pagar
WHEN NEW.status = 'ABERTA'
  AND date(NEW.data_vencimento) < date('now','localtime')
BEGIN
  UPDATE contas_pagar SET status = 'VENCIDA' WHERE id = NEW.id;
END;

-- =============================================================================
-- VIEWS
-- =============================================================================

CREATE VIEW IF NOT EXISTS vw_os_completa AS
SELECT
  os.id,
  os.numero,
  os.status,
  os.box_prisma,
  os.data_abertura,
  os.data_previsao,
  os.data_conclusao,
  os.data_entrega,
  c.id           AS cliente_id,
  c.nome         AS cliente_nome,
  c.celular      AS cliente_celular,
  v.id           AS veiculo_id,
  v.placa        AS veiculo_placa,
  v.marca        AS veiculo_marca,
  v.modelo       AS veiculo_modelo,
  v.ano_modelo   AS veiculo_ano,
  col.nome       AS mecanico_nome,
  os.km_entrada,
  os.km_saida,
  os.total_pecas,
  os.total_servicos,
  os.desconto,
  os.total_geral,
  os.valor_pago,
  (os.total_geral - os.valor_pago) AS saldo_devedor,
  os.forma_pagamento
FROM ordens_servico os
JOIN clientes c      ON c.id   = os.cliente_id
JOIN veiculos v      ON v.id   = os.veiculo_id
LEFT JOIN colaboradores col ON col.id = os.colaborador_id;

-- --

CREATE VIEW IF NOT EXISTS vw_estoque_critico AS
SELECT
  p.id,
  p.codigo,
  p.descricao,
  p.estoque_atual,
  p.estoque_minimo,
  CASE
    WHEN p.estoque_atual <= 0          THEN 'ZERADO'
    WHEN p.estoque_atual <= p.estoque_minimo THEN 'MINIMO'
    ELSE 'OK'
  END AS situacao,
  p.preco_vista,
  c.nome AS categoria
FROM pecas p
LEFT JOIN categorias_peca c ON c.id = p.categoria_id
WHERE p.ativo = 1
  AND p.estoque_atual <= p.estoque_minimo
ORDER BY p.estoque_atual ASC;

-- --

CREATE VIEW IF NOT EXISTS vw_agenda_hoje AS
SELECT
  a.id,
  a.hora,
  a.compromisso,
  a.veiculo_placa,
  a.cliente_whatsapp,
  c.nome   AS cliente_nome,
  col.nome AS atendente_nome
FROM agenda a
LEFT JOIN clientes     c   ON c.id   = a.cliente_id
LEFT JOIN colaboradores col ON col.id = a.atendente_id
WHERE a.data_agendamento = date('now','localtime')
ORDER BY a.hora;

-- --

CREATE VIEW IF NOT EXISTS vw_contas_vencidas AS
SELECT 'RECEBER' AS tipo, cr.id, cr.descricao, cr.valor,
       cr.data_vencimento, c.nome AS parte, cr.status
FROM contas_receber cr
JOIN clientes c ON c.id = cr.cliente_id
WHERE cr.status IN ('ABERTA','VENCIDA','PARCIAL')
  AND date(cr.data_vencimento) <= date('now','localtime')
UNION ALL
SELECT 'PAGAR' AS tipo, cp.id, cp.descricao, cp.valor,
       cp.data_vencimento, f.razao_social AS parte, cp.status
FROM contas_pagar cp
LEFT JOIN fornecedores f ON f.id = cp.fornecedor_id
WHERE cp.status IN ('ABERTA','VENCIDA','PARCIAL')
  AND date(cp.data_vencimento) <= date('now','localtime')
ORDER BY data_vencimento;

-- =============================================================================
-- DADOS INICIAIS (SEED)
-- =============================================================================

-- Usuário padrão: master / 123456
-- SHA-256("123456") = 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
INSERT OR IGNORE INTO usuarios (nome, login, senha_hash, perfil)
VALUES ('Administrador', 'master',
        '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
        'ADMIN');

-- Empresa padrão
INSERT OR IGNORE INTO empresa (razao_social, fantasia)
VALUES ('Minha Oficina Mecânica Ltda', 'Minha Oficina');

-- Parâmetros padrão do sistema
INSERT OR IGNORE INTO parametros (chave, valor, descricao) VALUES
  ('VERSAO_SISTEMA',   '1.0.0',               'Versão do SIGO'),
  ('NOME_SISTEMA',     'SIGO',                 'Nome exibido no sistema'),
  ('SEQUENCIA_OS',     '1',                    'Próximo número de OS'),
  ('SEQUENCIA_COMANDA','1',                    'Próximo número de comanda'),
  ('BACKUP_LEMBRAR',   '1',                    'Exibir lembrete de backup ao fechar'),
  ('TEMA_COR',         'DARK',                 'Tema de cores: DARK ou LIGHT'),
  ('OS_PREFIXO',       'OS-2026-',             'Prefixo do número da OS'),
  ('COMANDA_PREFIXO',  'CMD-2026-',            'Prefixo do número de comanda');

-- Categorias de peça padrão
INSERT OR IGNORE INTO categorias_peca (nome) VALUES
  ('Filtros'),('Freios'),('Motor'),('Suspensão'),('Elétrica'),
  ('Arrefecimento'),('Transmissão'),('Escapamento'),('Iluminação'),('Outros');

-- Serviços mais comuns
INSERT OR IGNORE INTO servicos (codigo, nome, valor_padrao, tempo_estimado) VALUES
  ('SV001','Troca de Óleo',          80.00,  30),
  ('SV002','Alinhamento',           120.00,  60),
  ('SV003','Balanceamento',          60.00,  60),
  ('SV004','Revisão Geral',         350.00, 180),
  ('SV005','Troca de Pastilhas',    150.00,  90),
  ('SV006','Troca de Correia Dentada',250.00,120),
  ('SV007','Diagnóstico Eletrônico', 100.00, 45),
  ('SV008','Lavagem Completa',        80.00,  60),
  ('SV009','Troca de Filtro de Ar',   40.00,  20),
  ('SV010','Recarga de Ar-condicionado',180.00,60);

PRAGMA foreign_keys = ON;
