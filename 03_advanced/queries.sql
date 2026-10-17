-- ============================================================
-- LEVEL 03 — ADVANCED  |  Dataset: Sakila (DVD rental)
-- ============================================================
-- We deliberately REUSE Sakila from Level 02 instead of pulling a
-- new dataset. Reason: at this stage the variable we want to isolate
-- is the TECHNIQUE (CTEs, window functions, cohort logic), not the
-- data. Holding the schema constant lets a reader compare Level 02
-- vs Level 03 on identical tables and see exactly what the new tools
-- buy them. That "change one thing at a time" discipline is itself
-- an analytical habit worth demonstrating.
--
-- PORTABILITY NOTE on dates: window functions below are ANSI SQL:2003
-- and run unchanged on SQLite (>=3.25), PostgreSQL and MySQL (>=8).
-- Only month/year EXTRACTION is engine-specific. This file targets
-- SQLite (strftime) because it is the lowest-friction way to run it:
-- download Chinook/Sakila .sqlite, open in DB Browser, go. The
-- equivalents are:
--   PostgreSQL : to_char(d, 'YYYY-MM')   /  EXTRACT(YEAR FROM d)
--   MySQL      : DATE_FORMAT(d, '%Y-%m') /  YEAR(d), MONTH(d)
-- Swap the one expression where marked [DATE-FN] and the rest works.
-- ============================================================


-- ------------------------------------------------------------
-- Q12. CTE: name the intermediate result, read top-to-bottom
-- ------------------------------------------------------------
-- [GOAL] Compute monthly revenue per category without repeating the
--        6-table join chain every time we touch it.
-- [WHY]  A Common Table Expression (WITH ...) materializes a named
--        step. Compare to Level 02 Q11, where the same join chain had
--        to be re-written inline. Here we write the chain ONCE inside
--        `monthly_rev`, then the main SELECT reads it like a table.
--        The payoff is legibility and single-source-of-truth: change
--        the join in one place, every downstream query follows. CTEs
--        are also the refactor that makes Q10's correlated-subquery
--        mean-comparison clean — we do exactly that in Q16.
WITH monthly_rev AS (
    SELECT cat.name                                  AS category,
           strftime('%Y-%m', p.payment_date)         AS pay_month,  -- [DATE-FN]
           SUM(p.amount)                             AS revenue
    FROM payment p
    JOIN rental        r   ON p.rental_id    = r.rental_id
    JOIN inventory     i   ON r.inventory_id = i.inventory_id
    JOIN film          f   ON i.film_id      = f.film_id
    JOIN film_category fc  ON f.film_id      = fc.film_id
    JOIN category      cat ON fc.category_id = cat.category_id
    GROUP BY cat.name, pay_month
)
SELECT category, pay_month, ROUND(revenue, 2) AS revenue
FROM monthly_rev
ORDER BY category, pay_month;


-- ------------------------------------------------------------
-- Q13. ROW_NUMBER vs RANK vs DENSE_RANK: the tie story
-- ------------------------------------------------------------
-- [GOAL] Rank films by revenue WITHIN each category, and understand
--        what happens when two films earn the same amount.
-- [WHY]  All three number rows per partition (PARTITION BY category),
--        but they treat ties differently — and picking the wrong one
--        silently distorts a leaderboard:
--          ROW_NUMBER  -> 1,2,3,4  (forces unique order, ties broken
--                        arbitrarily; good for "pick exactly one")
--          RANK        -> 1,2,2,4  (ties share a rank, next skips)
--          DENSE_RANK  -> 1,2,2,3  (ties share, next does NOT skip)
--        Knowing which to reach for is a judgment call about the
--        question, not syntax. We use RANK here because a "top films"
--        list should show genuine ties as tied, not invent an order.
WITH film_rev AS (
    SELECT f.film_id, f.title, cat.name AS category, SUM(p.amount) AS revenue
    FROM payment p
    JOIN rental        r   ON p.rental_id    = r.rental_id
    JOIN inventory     i   ON r.inventory_id = i.inventory_id
    JOIN film          f   ON i.film_id      = f.film_id
    JOIN film_category fc  ON f.film_id      = fc.film_id
    JOIN category      cat ON fc.category_id = cat.category_id
    GROUP BY f.film_id, f.title, cat.name
)
SELECT category, title, ROUND(revenue, 2) AS revenue,
       ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn,
       RANK()       OVER (PARTITION BY category ORDER BY revenue DESC) AS rk,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS drk
FROM film_rev
ORDER BY category, rk;


-- ------------------------------------------------------------
-- Q14. LAG: month-over-month growth without a self-join
-- ------------------------------------------------------------
-- [GOAL] For each month, compare total revenue to the previous month.
-- [WHY]  Before window functions you'd self-join the table to itself
--        on (month = prev_month) — verbose and easy to get wrong at
--        the boundaries. LAG(col, 1) reaches back one row inside the
--        same partition, ordered by month, so the "previous value"
--        sits right next to the current one. We then derive growth %
--        from the two adjacent values. The first month has no prior
--        row, so LAG returns NULL — which is CORRECT (you cannot
--        compute growth from nothing) and is exactly the kind of
--        boundary case a careful evaluator checks rather than hides.
WITH m AS (
    SELECT strftime('%Y-%m', payment_date) AS pay_month,  -- [DATE-FN]
           SUM(amount)                     AS revenue
    FROM payment
    GROUP BY pay_month
)
SELECT pay_month,
       ROUND(revenue, 2)                                       AS revenue,
       LAG(revenue, 1) OVER (ORDER BY pay_month)               AS prev_revenue,
       ROUND( (revenue - LAG(revenue,1) OVER (ORDER BY pay_month))
              / LAG(revenue,1) OVER (ORDER BY pay_month) * 100, 2) AS growth_pct
FROM m
ORDER BY pay_month;


-- ------------------------------------------------------------
-- Q15. Running total with an explicit window frame
-- ------------------------------------------------------------
-- [GOAL] Show cumulative revenue per category over time.
-- [WHY]  SUM(...) OVER (...) defaults to a frame of "all rows up to
--        current", giving a running total. We write the frame
--        explicitly (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT
--        ROW) to make the intent unmissable — the same number could
--        mean "cumulative" or "moving average" depending on the
--        frame, so spelling it out removes ambiguity. Partitioning by
--        category restarts the accumulation per category, which is
--        what "cumulative within group" should mean. Explicit frames
--        are a readability/auditability choice, not a correctness one
--        — but in collaborative or reviewed work, auditability wins.
SELECT category, pay_month,
       ROUND(monthly_revenue, 2) AS monthly_revenue,
       ROUND( SUM(monthly_revenue) OVER (
                  PARTITION BY category
                  ORDER BY pay_month
                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
              ), 2)             AS cumulative_revenue
FROM (
    SELECT cat.name                          AS category,
           strftime('%Y-%m', p.payment_date) AS pay_month,  -- [DATE-FN]
           SUM(p.amount)                     AS monthly_revenue
    FROM payment p
    JOIN rental        r   ON p.rental_id    = r.rental_id
    JOIN inventory     i   ON r.inventory_id = i.inventory_id
    JOIN film          f   ON i.film_id      = f.film_id
    JOIN film_category fc  ON f.film_id      = fc.film_id
    JOIN category      cat ON fc.category_id = cat.category_id
    GROUP BY cat.name, pay_month
) t
ORDER BY category, pay_month;


-- ------------------------------------------------------------
-- Q16. Cohort retention: the capstone (and a longitudinal lens)
-- ------------------------------------------------------------
-- [GOAL] Group customers by the month of their FIRST purchase (their
--        "cohort"), then measure how many of each cohort were still
--        active N months later. Output = classic retention triangle.
-- [WHY]  This is the analytical peak of the repo, and it mirrors a
--        research instinct directly: a cohort study follows the SAME
--        subjects forward in time to see how a property (here,
--        continued purchasing; in research, continued participation
--        or a measured outcome) evolves — i.e. a longitudinal design
--        expressed in SQL. Mechanically it needs everything combined:
--        two CTEs (one fixes each customer's cohort month via MIN +
--        GROUP BY; one lists every purchase), a join on customer, and
--        integer arithmetic to convert 'YYYY-MM' strings into a flat
--        month index (year*12 + month) so subtraction yields a clean
--        0,1,2,... offset. month_index = 0 is the acquisition month
--        itself (always 100% by construction); the decay across
--        higher indexes is the retention signal. COUNT(DISTINCT ...)
--        guards against double-counting a customer who bought twice
--        in the same month. Reading the resulting grid row-wise tells
--        you whether newer cohorts retain better or worse than older
--        ones — the question every product and every longitudinal
--        study ultimately asks.
WITH first_purchase AS (
    SELECT customer_id,
           strftime('%Y-%m', MIN(payment_date)) AS cohort_month  -- [DATE-FN]
    FROM payment
    GROUP BY customer_id
),
every_purchase AS (
    SELECT customer_id,
           strftime('%Y-%m', payment_date) AS purchase_month     -- [DATE-FN]
    FROM payment
)
SELECT fp.cohort_month,
       ( CAST(substr(ep.purchase_month,1,4) AS INTEGER) * 12
       + CAST(substr(ep.purchase_month,6,2) AS INTEGER) )
     - ( CAST(substr(fp.cohort_month,1,4) AS INTEGER) * 12
       + CAST(substr(fp.cohort_month,6,2) AS INTEGER) )          AS month_index,
       COUNT(DISTINCT ep.customer_id)                            AS active_customers
FROM first_purchase fp
JOIN every_purchase ep ON fp.customer_id = ep.customer_id
GROUP BY fp.cohort_month, month_index
ORDER BY fp.cohort_month, month_index;


-- ============================================================
-- End of Level 03 — and end of the guided progression.
-- The three levels together move from "filter and join rows"
-- (01) to "aggregate and reason about groups" (02) to "shape
-- windows of time and follow subjects forward" (03).
-- ============================================================