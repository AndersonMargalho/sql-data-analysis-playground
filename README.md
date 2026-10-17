<h1 align="center">🗄️ SQL Data Analysis Playground</h1>
<p align="center">
  <img src="https://img.shields.io/badge/SQL-ANSI%20standard-336791?logo=postgresql&logoColor=white" alt="SQL"/>
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"/>
  <img src="https://img.shields.io/badge/Datasets-Public%20%26%20Open-blue" alt="Datasets"/>
</p>

<p align="center"><b>(English version below | Versão em português abaixo)</b></p>

---

## 🇺🇸 US English Version

A hands-on demonstration of SQL analytical thinking, organized in three progressive complexity levels and built on real-world public datasets. Each query is commented line by line to explain not just *what* it does, but *why* each clause is there — because in research and data work, the reasoning behind a query matters as much as its result.

### 📂 Structure & progress

| Level | Folder | Dataset | Focus | Status |
|---|---|---|---|---|
| 1 | `01_fundamentals/` | Chinook (music retail) | SELECT, WHERE, ORDER BY, LIMIT, JOIN, GROUP BY, aggregates, LEFT JOIN | ✅ Ready |
| 2 | `02_intermediate/` | Sakila / Northwind | Subqueries, CASE WHEN, multi-table aggregation, HAVING | 🚧 Next |
| 3 | `03_advanced/` | Public health / e-commerce | Window functions, CTEs, cohort analysis, optimization | 🚧 Planned |

### 🛠 How to run

    1. Download a dataset (links inside each level's README)
    2. Import it into SQLite Browser, PostgreSQL (pgAdmin) or MySQL
    3. Open the .sql files and execute the queries in order
    4. Read the comments — they are the point of this repo

> Queries use ANSI-standard SQL and run on SQLite, PostgreSQL and MySQL with minimal or no changes. Local database files (`*.db`, `*.sqlite`) are excluded via `.gitignore`.

### ⚖️ Data attribution

All datasets used are public and open (Chinook, Sakila, etc.). This repository is for educational and portfolio purposes only.

---

## 🇧🇷 BR Versão em Português

Uma demonstração prática de raciocínio analítico em SQL, organizada em três níveis progressivos de complexidade e construída sobre datasets públicos reais. Cada consulta é comentada linha a linha para explicar não apenas *o que* ela faz, mas *por que* cada cláusula está ali — porque, em pesquisa e trabalho com dados, o raciocínio por trás de uma consulta importa tanto quanto o seu resultado.

### 📂 Estrutura & progresso

| Nível | Pasta | Dataset | Foco | Status |
|---|---|---|---|---|
| 1 | `01_fundamentals/` | Chinook (varejo de música) | SELECT, WHERE, ORDER BY, LIMIT, JOIN, GROUP BY, agregações, LEFT JOIN | ✅ Pronto |
| 2 | `02_intermediate/` | Sakila / Northwind | Subqueries, CASE WHEN, agregação multi-tabela, HAVING | 🚧 Próximo |
| 3 | `03_advanced/` | Saúde pública / e-commerce | Window functions, CTEs, análise de coorte, otimização | 🚧 Planejado |

### 🛠 Como executar

    1. Baixe um dataset (links no README de cada nível)
    2. Importe no SQLite Browser, PostgreSQL (pgAdmin) ou MySQL
    3. Abra os arquivos .sql e execute as consultas em ordem
    4. Leia os comentários — eles são o objetivo deste repositório

> As consultas usam SQL padrão ANSI e rodam em SQLite, PostgreSQL e MySQL com mudanças mínimas ou nenhuma. Arquivos locais de banco (`*.db`, `*.sqlite`) são excluídos via `.gitignore`.

### ⚖️ Atribuição de dados

Todos os datasets usados são públicos e abertos (Chinook, Sakila, etc.). Este repositório tem fins educacionais e de portfólio apenas.

---
<p align="center">Maintained by <b>Anderson Margalho</b> — Freelance Software Engineer & IT Consultant (Belém, Brazil).<br/>Open to research collaborations and freelance projects.</p>