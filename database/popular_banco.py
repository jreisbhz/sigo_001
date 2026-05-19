"""
Popula o banco sigo.db com dados de demonstracao para testes.
"""
import sqlite3

db_path = r'C:\legado\sigo_001\bin\sigo.db'
con = sqlite3.connect(db_path)
con.execute("PRAGMA foreign_keys = OFF")
con.commit()

try:
    # ------------------------------------------------------------------ CLIENTES
    clientes = [
        ('F','Carlos Eduardo Silva','','123.456.789-00','','1985-03-15','Rua das Flores','123','','Centro','São Paulo','SP','01310-100','(11) 3333-1111','(11) 91234-5678','','carlos.silva@email.com','Cliente VIP',2000.00,1),
        ('F','Ana Paula Souza','','987.654.321-00','','1990-07-22','Av. Paulista','456','Apto 32','Bela Vista','São Paulo','SP','01310-200','(11) 3333-2222','(11) 92345-6789','','ana.souza@email.com','',1000.00,1),
        ('J','Transportes Rápidos Ltda','Trans Rápidos','12.345.678/0001-90','123456789','','Rua Industrial','789','','Distrito Industrial','Guarulhos','SP','07140-000','(11) 4444-1111','(11) 93456-7890','','contato@transrapidos.com.br','Empresa grande frota',5000.00,1),
        ('F','Roberto Martins','','456.789.123-00','','1978-11-05','Rua dos Ipês','321','','Jardim América','Campinas','SP','13010-000','(19) 3333-9999','(19) 94567-8901','','roberto.martins@email.com','',500.00,1),
        ('F','Fernanda Costa','','321.654.987-00','','1995-02-28','Rua Buganvília','654','CS 2','Moema','São Paulo','SP','04522-000','(11) 5555-3333','(11) 95678-9012','','fernanda.costa@email.com','',1500.00,1),
    ]
    con.executemany("""
        INSERT OR IGNORE INTO clientes
          (tipo_pessoa,nome,fantasia,cpf_cnpj,rg_ie,data_nasc,logradouro,numero,
           complemento,bairro,cidade,uf,cep,telefone,celular,celular2,email,
           observacoes,limite_credito,ativo)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, clientes)

    # ----------------------------------------------------------------- VEICULOS
    veiculos = [
        (1,'ABC-1234','Volkswagen','Gol','1.0','2018','2018','Branco','FLEX','','',45000,1),
        (1,'DEF-5678','Ford','Ka','1.5','2020','2020','Prata','FLEX','','',28000,1),
        (2,'GHI-9012','Chevrolet','Onix','1.0 Turbo','2022','2022','Preto','FLEX','','',12000,1),
        (3,'JKL-3456','Mercedes-Benz','Sprinter','2.2 CDI','2019','2019','Branco','DIESEL','','',95000,1),
        (4,'MNO-7890','Toyota','Corolla','2.0','2021','2021','Cinza','FLEX','','',35000,1),
        (5,'PQR-2345','Honda','Civic','1.5 Turbo','2023','2023','Azul','FLEX','','',8000,1),
    ]
    con.executemany("""
        INSERT OR IGNORE INTO veiculos
          (cliente_id,placa,marca,modelo,versao,ano_fabricacao,ano_modelo,cor,
           combustivel,renavam,chassi,km_atual,ativo)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, veiculos)

    # --------------------------------------------------------------- FORNECEDORES
    fornecedores = [
        ('J','Auto Peças Brasil Ltda','APB',    '11.222.333/0001-44','','Rua do Comércio','100','','Centro','São Paulo','SP','01000-000','(11) 3000-1111','(11) 90000-1111','pecas@apbrasil.com.br','João da Silva','Fornecedor principal',1),
        ('J','Distribuidora Motores SA','DistMot','22.333.444/0001-55','','Av. Industrial','200','','Distrito','Osasco','SP','06000-000','(11) 3000-2222','(11) 90000-2222','vendas@distmot.com.br','Maria Santos','',1),
        ('J','Filtros e Cia','FiltrosCia','33.444.555/0001-66','','Rua dos Filtros','300','','Bairro Novo','Barueri','SP','06400-000','(11) 3000-3333','(11) 90000-3333','contato@filtrosecia.com.br','Pedro Lima','Especialista filtros',1),
    ]
    con.executemany("""
        INSERT OR IGNORE INTO fornecedores
          (tipo_pessoa,razao_social,fantasia,cnpj_cpf,ie,logradouro,numero,
           complemento,bairro,cidade,uf,cep,telefone,celular,email,contato,
           observacoes,ativo)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, fornecedores)

    # -------------------------------------------------------------- COLABORADORES
    colaboradores = [
        (None,'Marcos Oliveira','111.222.333-44','MG-111111','1982-06-10','Mecânico','Motor',  '(11) 7777-1111','(11) 97777-1111','marcos@oficina.com','2020-01-10',3500.00,5.0,1),
        (None,'Júlia Ferreira', '222.333.444-55','SP-222222','1991-09-15','Atendente','Balcão','(11) 7777-2222','(11) 97777-2222','julia@oficina.com', '2021-03-01',2800.00,2.0,1),
        (None,'Paulo Henrique', '333.444.555-66','RJ-333333','1988-12-20','Mecânico','Suspensão','(11) 7777-3333','(11) 97777-3333','paulo@oficina.com','2019-05-15',3200.00,5.0,1),
    ]
    con.executemany("""
        INSERT OR IGNORE INTO colaboradores
          (usuario_id,nome,cpf,rg,data_nasc,cargo,especialidade,telefone,celular,
           email,data_admissao,salario,comissao_pct,ativo)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, colaboradores)

    # --------------------------------------------------------------- PECAS
    pecas = [
        (1,1,'FIL-001','','7891234560001','Filtro de Óleo Motor 1.0','UN','A1',  'Bosch',25.0,5.0,50.0,12.50,8.50,10.00,6.00,21.00,22.50,20.50,'',1),
        (1,3,'FIL-002','','7891234560002','Filtro de Ar Motor 1.0', 'UN','A2',  'Mann', 20.0,5.0,40.0,18.00,7.00, 8.50,5.50,25.00,26.50,23.50,'',1),
        (2,1,'FRE-001','','7891234560003','Pastilha de Freio Dianteira','JG','B1','Brembo',10.0,2.0,20.0,45.00,25.00,28.00,20.00,70.00,73.00,65.00,'',1),
        (3,2,'MOT-001','','7891234560004','Óleo Motor 5W30 Sintético 1L','UN','C1','Mobil', 50.0,10.0,100.0,28.00,15.00,17.00,12.00,43.00,45.00,40.00,'',1),
        (6,1,'ARR-001','','7891234560005','Radiador Universal 1.0/1.4','UN','D1','Valeo', 3.0,1.0,10.0,380.00,150.00,170.00,130.00,530.00,550.00,510.00,'',1),
        (4,2,'TRS-001','','7891234560006','Vela de Ignição NGK','UN','E1','NGK',  40.0,10.0,80.0, 8.50,4.50, 5.00, 3.50,13.00,13.50,12.00,'',1),
        (2,None,'FRE-002','','7891234560007','Disco de Freio Dianteiro','UN','B2','TRW',  8.0, 2.0,15.0,120.00,60.00,65.00,50.00,180.00,185.00,170.00,'',1),
        (1,3,'FIL-003','','7891234560008','Filtro de Combustível','UN','A3','Wega', 15.0,3.0,30.0,22.00,12.00,13.50,10.00,34.00,35.50,32.00,'',1),
    ]
    con.executemany("""
        INSERT OR IGNORE INTO pecas
          (categoria_id,fornecedor_id,codigo,codigo_fabricante,codigo_barras,
           descricao,unidade,localizacao,marca,estoque_atual,estoque_minimo,
           estoque_maximo,preco_custo,margem_vista,margem_prazo,margem_atacado,
           preco_vista,preco_prazo,preco_atacado,observacoes,ativo)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, pecas)

    # -------------------------------------------------------------- AGENDA
    agenda = [
        ('2026-05-19','08:00','Segunda-feira','Troca de óleo - Carlos Silva',2,1,'ABC-1234','(11) 91234-5678','',),
        ('2026-05-19','10:00','Segunda-feira','Alinhamento e balanceamento - Ana Souza',2,2,'GHI-9012','(11) 92345-6789','Verificar pneus',),
        ('2026-05-19','14:00','Segunda-feira','Revisão geral - Transportes Rápidos',1,3,'JKL-3456','(11) 93456-7890','Veículo pesado',),
        ('2026-05-20','09:00','Terça-feira', 'Diagnóstico eletrônico - Roberto Martins',1,4,'MNO-7890','(19) 94567-8901','',),
        ('2026-05-20','11:00','Terça-feira', 'Troca de pastilhas - Fernanda Costa',3,5,'PQR-2345','(11) 95678-9012','',),
    ]
    con.executemany("""
        INSERT OR IGNORE INTO agenda
          (data_agendamento,hora,dia_semana,compromisso,atendente_id,cliente_id,
           veiculo_placa,cliente_whatsapp,observacoes)
        VALUES (?,?,?,?,?,?,?,?,?)
    """, agenda)

    # -------------------------------------------- ORDENS DE SERVICO (históricas)
    ordens = [
        ('OS-2026-0001',1,1,1,None,'ENTREGUE',None,'2026-05-01 08:00','2026-05-01 12:00','2026-05-01 14:00','2026-05-01 14:30',45000,'Troca de óleo + filtros','Serviço realizado com sucesso',0.00,45.00,80.00,125.00,'DINHEIRO',125.00),
        ('OS-2026-0002',2,3,2,None,'PRONTO',  None,'2026-05-10 09:00','2026-05-10 18:00','2026-05-12 10:00',None,28000,'Barulho na suspensão dianteira','Trocado amortecedor dianteiro esquerdo',0.00,380.00,150.00,530.00,'PIX',0.00),
        ('OS-2026-0003',3,4,3,None,'EM_ANDAMENTO',None,'2026-05-18 08:00','2026-05-20 18:00',None,None,95000,'Revisão 100.000 km','Em andamento',0.00,0.00,350.00,350.00,'',0.00),
    ]
    con.executemany("""
        INSERT OR IGNORE INTO ordens_servico
          (numero,cliente_id,veiculo_id,colaborador_id,usuario_abriu,status,
           box_prisma,data_abertura,data_previsao,data_conclusao,data_entrega,
           km_entrada,defeito_relatado,servico_executado,desconto,
           total_pecas,total_servicos,total_geral,forma_pagamento,valor_pago)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    """, ordens)

    # ------------------------------------------------- ITENS DAS OS
    # OS 1 — itens servico
    con.execute("""
        INSERT OR IGNORE INTO os_itens_servico
          (os_id,servico_id,colaborador_id,descricao,quantidade,valor_unitario,desconto,total)
        VALUES (1,1,1,'Troca de Óleo',1,80.00,0,80.00)
    """)
    # OS 2 — item servico (amortecedor)
    con.execute("""
        INSERT OR IGNORE INTO os_itens_servico
          (os_id,servico_id,colaborador_id,descricao,quantidade,valor_unitario,desconto,total)
        VALUES (2,4,2,'Troca de Amortecedor Dianteiro',1,150.00,0,150.00)
    """)
    # OS 3 — revisão geral
    con.execute("""
        INSERT OR IGNORE INTO os_itens_servico
          (os_id,servico_id,colaborador_id,descricao,quantidade,valor_unitario,desconto,total)
        VALUES (3,4,3,'Revisão Geral 100.000 km',1,350.00,0,350.00)
    """)

    # ------------------------------------------------- CONTAS A RECEBER
    contas_receber = [
        (2,2,'OS-2026-0002 - Amortecedor dianteiro',530.00,0.00,'2026-05-12','2026-06-12',None,'ABERTA','PIX','',None),
        (None,3,'OS-2026-0003 - Revisão parcial',350.00,0.00,'2026-05-18','2026-05-25',None,'ABERTA','',  'Aguardando conclusão',None),
    ]
    con.executemany("""
        INSERT OR IGNORE INTO contas_receber
          (os_id,cliente_id,descricao,valor,valor_pago,data_emissao,
           data_vencimento,data_pagamento,status,forma_pagamento,observacoes,usuario_id)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
    """, contas_receber)

    # ------------------------------------------------- CONTAS A PAGAR
    contas_pagar = [
        (1,'Compra de peças - APB Maio/2026',1250.00,0.00,'2026-05-05','2026-06-05',None,'ABERTA','BOLETO',''),
        (2,'Compra filtros e óleos - DistMot',820.00,820.00,'2026-05-01','2026-05-15','2026-05-15','PAGA','PIX','Pago em dia'),
        (None,'Aluguel oficina Maio/2026',3500.00,3500.00,'2026-05-01','2026-05-10','2026-05-08','PAGA','TED',''),
        (None,'Energia elétrica Abril/2026',680.00,0.00,'2026-05-10','2026-05-20',None,'VENCIDA','BOLETO','Vencida'),
    ]
    con.executemany("""
        INSERT OR IGNORE INTO contas_pagar
          (fornecedor_id,descricao,valor,valor_pago,data_emissao,
           data_vencimento,data_pagamento,status,forma_pagamento,observacoes)
        VALUES (?,?,?,?,?,?,?,?,?,?)
    """, contas_pagar)

    # ------------------------------------------------- CAIXA MOVIMENTOS
    caixa = [
        (1,None,'ENTRADA','OS','Recebimento OS-2026-0001',125.00,'2026-05-01 14:30','DINHEIRO',None,''),
        (None,None,'SAIDA','FORNECEDOR','Pagamento DistMot',820.00,'2026-05-15 10:00','PIX',None,''),
        (None,None,'SAIDA','FIXO','Aluguel Maio/2026',3500.00,'2026-05-08 09:00','TED',None,''),
        (None,None,'ENTRADA','VENDA','Venda balcão - óleo motor',43.00,'2026-05-16 11:00','DINHEIRO',None,''),
    ]
    con.executemany("""
        INSERT OR IGNORE INTO caixa_movimentos
          (os_id,conta_receber_id,tipo,categoria,descricao,valor,
           data_movimento,forma_pagamento,usuario_id,observacoes)
        VALUES (?,?,?,?,?,?,?,?,?,?)
    """, caixa)

    # ------------------------------------------------- CARTA MODELO
    con.execute("""
        INSERT OR IGNORE INTO cartas_modelos (titulo, corpo) VALUES
        ('Lembrete de Revisão',
         'Prezado(a) {CLIENTE},\n\nGostaríamos de lembrá-lo(a) que seu veículo {PLACA} está próximo da revisão programada.\nEntre em contato conosco para agendar.\n\nAtenciosamente,\n{EMPRESA}')
    """)

    con.execute("PRAGMA foreign_keys = ON")
    con.commit()

    # ------------------------------------------------- RESUMO FINAL
    print("Banco populado com sucesso!\n")
    tabelas = ['clientes','veiculos','fornecedores','colaboradores','pecas',
               'servicos','agenda','ordens_servico','os_itens_servico',
               'contas_receber','contas_pagar','caixa_movimentos','cartas_modelos']
    for t in tabelas:
        cur = con.execute(f"SELECT COUNT(*) FROM {t}")
        print(f"  {t:<25}: {cur.fetchone()[0]} registros")

except Exception as e:
    print('ERRO:', e)
    import traceback; traceback.print_exc()
    con.rollback()
finally:
    con.close()
