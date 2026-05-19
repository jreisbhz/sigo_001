import sqlite3, os

db_path = r'C:\legado\sigo_001\bin\sigo.db'
sql_path = r'C:\legado\sigo_001\DDL_SIGO_001.sql'

if os.path.exists(db_path):
    os.remove(db_path)
    print('Banco anterior removido.')

with open(sql_path, 'r', encoding='utf-8') as f:
    ddl = f.read()

con = sqlite3.connect(db_path)
try:
    con.executescript(ddl)
    con.commit()
    print('Banco criado com sucesso!')

    # Verificar tabelas
    cur = con.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
    tabelas = [r[0] for r in cur.fetchall()]
    print(f'Tabelas ({len(tabelas)}): ' + ', '.join(tabelas))

    # Seed
    cur = con.execute('SELECT nome, login, perfil FROM usuarios')
    print('Usuarios:', cur.fetchall())

    cur = con.execute('SELECT COUNT(*) FROM servicos')
    print('Servicos seed:', cur.fetchone()[0])

    cur = con.execute('SELECT COUNT(*) FROM categorias_peca')
    print('Categorias peca:', cur.fetchone()[0])

    cur = con.execute('SELECT COUNT(*) FROM parametros')
    print('Parametros:', cur.fetchone()[0])

    cur = con.execute('SELECT razao_social FROM empresa')
    print('Empresa:', cur.fetchone())

    print(f'\nBanco em: {db_path}')
    print(f'Tamanho: {os.path.getsize(db_path):,} bytes')

except Exception as e:
    print('ERRO:', e)
    import traceback; traceback.print_exc()
finally:
    con.close()
