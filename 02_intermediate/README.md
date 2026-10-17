# Level 02 — Intermediate | Intermediário

**Dataset:** [Sakila](https://dev.mysql.com/doc/sakila/en/) — a fictional DVD-rental chain with a rich relational schema (films, actors, categories, inventory, rentals, payments, customers). Public and open. Portable copies for SQLite/PostgreSQL exist (e.g. the [jOOQ/sakila](https://github.com/jOOQ/sakila) repo).

**Como obter / How to get it:** download the Sakila schema+data script from the links above and import it into MySQL, PostgreSQL (pgAdmin) or SQLite Browser. The queries in `queries.sql` are written in portable ANSI SQL and run on all three with little or no change.

## What these queries teach | O que estas consultas ensinam

| # | Concept | Em poucas palavras |
|---|---|---|
| Q7 | `HAVING` | Filtrar grupos DEPOIS da agregação (vs `WHERE`, que filtra antes) |
| Q8 | `NOT EXISTS` (subquery não-correlacionada) | Estoque morto; evita a armadilha de `NULL` do `NOT IN` |
| Q9 | `CASE WHEN` + tabela derivada | Transformar valor contínuo em faixa ordenada (histograma) |
| Q10 | Subquery correlacionada vs agregado global | Comparar cada linha contra a média (acima/abaixo do benchmark) |
| Q11 | Cadeia de 6 tabelas + `HAVING` | Receita por categoria, suprimindo grupos de N baixo (higiene estatística) |

> Same contract as Level 01: every query carries a `[GOAL]` and a `[WHY]`. The reasoning is the deliverable. | Mesmo contrato do Nível 01: cada consulta traz `[GOAL]` e `[WHY]`. O raciocínio é a entrega.

➡️ Next: `03_advanced/` — window functions (`ROW_NUMBER`, `RANK`), CTEs and cohort analysis.