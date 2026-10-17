# Level 03 — Advanced | Avançado

**Dataset:** [Sakila](https://dev.mysql.com/doc/sakila/en/) — *reused from Level 02 on purpose.* At this stage the variable we isolate is the technique (CTEs, window functions, cohort logic), not the data, so holding the schema constant lets you compare Level 02 vs Level 03 on identical tables and see exactly what the new tools buy. Import it the same way as Level 02 (MySQL / PostgreSQL / SQLite).

**Portability:** window functions are ANSI and run unchanged on SQLite (≥3.25), PostgreSQL and MySQL (≥8). Only month/year extraction is engine-specific — the file targets SQLite (`strftime`) for lowest friction; swap the one expression marked `[DATE-FN]` for `to_char(...)` (Postgres) or `DATE_FORMAT(...)` (MySQL) and everything else works as-is.

## What these queries teach | O que estas consultas ensinam

| # | Concept | Em poucas palavras |
|---|---|---|
| Q12 | CTE (`WITH`) | Nomear o passo intermediário; escrever o join uma vez só |
| Q13 | `ROW_NUMBER` / `RANK` / `DENSE_RANK` | Ranquear por partição e decidir como tratar empates |
| Q14 | `LAG` | Comparar com a linha anterior sem self-join; NULL na borda é correto |
| Q15 | Frame explícito (`ROWS BETWEEN ...`) | Total acumulado com intenção auditável |
| Q16 | Análise de coorte + aritmética de mês | Seguir os MESMOS sujeitos no tempo = estudo longitudinal em SQL |

> Q16 is the capstone and the bridge to research work: a cohort follows the same subjects forward to watch an outcome evolve — exactly a longitudinal design, expressed as SQL. The retention triangle it produces answers "do newer cohorts stick better than older ones?", the question product and longitudinal studies ultimately share. | Q16 é o ápice e a ponte com a pesquisa: uma coorte acompanha os MESMOS sujeitos no tempo para observar a evolução de um desfecho — um delineamento longitudinal, expresso em SQL.

Same contract as Levels 01–02: every query carries a `[GOAL]` and a `[WHY]`. The reasoning is the deliverable. | Mesmo contrato dos níveis 01–02: cada consulta traz `[GOAL]` e `[WHY]`. O raciocínio é a entrega.

✅ Progression complete: 01 fundamentals → 02 intermediate → 03 advanced.