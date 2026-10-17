# Level 01 — Fundamentals | Fundamentos

**Dataset:** [Chinook Database](https://github.com/lerocha/chinook-database) — a fictional digital music store (customers, employees, artists, albums, tracks, invoices). Public and open, ideal for practicing relational SQL.

**Como obter / How to get it:** download the `Chinook_Sqlite.sqlite` file from the link above and open it in [DB Browser for SQLite](https://sqlitebrowser.org/), or import the SQL script into PostgreSQL/MySQL.

## What these queries teach | O que estas consultas ensinam

| # | Concept | Em poucas palavras |
|---|---|---|
| Q1 | `SELECT` + `WHERE` | Filtrar linhas por condição |
| Q2 | `ORDER BY` + `LIMIT` | Ranking "top N" |
| Q3 | `JOIN` simples | Resolver chave estrangeira em nome |
| Q4 | Multi-`JOIN` + `GROUP BY` + `SUM` | Agregação em cadeia de tabelas |
| Q5 | `LEFT JOIN` | Preservar registros sem correspondência |
| Q6 | `LEFT JOIN` + `COUNT` | Verificar cobertura/lacunas de catálogo |

> Every query in `queries.sql` carries a `[GOAL]` and a `[WHY]` comment. The reasoning is the deliverable, not just the result. | Cada consulta traz comentários `[GOAL]` e `[WHY]`. O raciocínio é a entrega, não apenas o resultado.

➡️ Next: `02_intermediate/` (subqueries, `CASE WHEN`, `HAVING`).