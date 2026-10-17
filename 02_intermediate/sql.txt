-- ============================================================
-- LEVEL 02 — INTERMEDIATE  |  Dataset: Sakila (DVD rental)
-- ============================================================
-- Builds on Level 01. New instruments introduced here:
--   * HAVING        -> filter AFTER aggregation
--   * subqueries    -> uncorrelated (NOT EXISTS) + correlated
--   * CASE WHEN     -> derive labels / bin continuous values
--   * derived table -> subquery in FROM, to group by an alias
-- Annotated with [GOAL] (the question) and [WHY] (the reasoning).
-- Schema used: film, actor, film_actor, category, film_category,
--              inventory, rental, payment, customer.
-- ============================================================


-- ------------------------------------------------------------
-- Q7. HAVING: customers whose lifetime spend exceeds a threshold
-- ------------------------------------------------------------
-- [GOAL] Keep only groups (customers) whose aggregated total passes
--        a bar — e.g. "who are our high-value renters?".
-- [WHY]  WHERE filters rows BEFORE grouping; HAVING filters groups
--        AFTER aggregation. You cannot put SUM() in a WHERE clause,
--        because the sum does not exist until GROUP BY collapses the
--        rows. This distinction (row-level vs group-level filtering)
--        is the single most misunderstood idea in SQL — mastering it
--        is what makes HAVING worth its own level.
SELECT c.customer_id, c.first_name, c.last_name,
       ROUND(SUM(p.amount), 2) AS total_spent
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(p.amount) > 150          -- illustrative threshold
ORDER BY total_spent DESC;


-- ------------------------------------------------------------
-- Q8. Uncorrelated subquery via NOT EXISTS: films never rented
-- ------------------------------------------------------------
-- [GOAL] Find catalogue items with zero demand (dead stock).
-- [WHY]  The inner query asks, per outer film, "does ANY rental row
--        reach this film through its inventory?". NOT EXISTS returns
--        TRUE only when that inner set is empty. We deliberately use
--        NOT EXISTS instead of NOT IN: with NOT IN, a single NULL in
--        the subquery result makes the whole predicate UNKNOWN and the
--        query silently returns nothing. NOT EXISTS is NULL-safe and
--        usually faster, because it stops scanning at the first match.
--        Recognising the NULL trap in NOT IN is a hallmark of careful
--        data work — exactly the vigilance an evaluator needs.
SELECT f.film_id, f.title
FROM film f
WHERE NOT EXISTS (
    SELECT 1
    FROM inventory i
    JOIN rental  r ON r.inventory_id = i.inventory_id
    WHERE i.film_id = f.film_id
);


-- ------------------------------------------------------------
-- Q9. CASE WHEN inside a derived table: bin film lengths
-- ------------------------------------------------------------
-- [GOAL] Turn a continuous measure (length in minutes) into ordered
--        categories, then count films per bucket — i.e. histogram.
-- [WHY]  CASE WHEN is SQL's if/elif/else. We compute the bucket in an
--        inner "derived table" (subquery in FROM) so the outer query
--        can GROUP BY the alias; most engines forbid grouping by a
--        SELECT alias directly, so the wrapper keeps this portable
--        across SQLite/Postgres/MySQL. Note the '1_', '2_' prefixes:
--        they force alphabetical ORDER BY to follow logical order —
--        a tiny, reusable trick for any ranked/binned output.
--        Binning continuous variables before grouping mirrors how we
--        bucket Likert scores or latency ms into bands in research.
SELECT length_bucket, COUNT(*) AS films_in_bucket
FROM (
    SELECT CASE
        WHEN length < 60               THEN '1_Short (<60 min)'
        WHEN length BETWEEN 60 AND 99  THEN '2_Medium (60-99 min)'
        WHEN length BETWEEN 100 AND 149 THEN '3_Long (100-149 min)'
        ELSE                                '4_Epic (150+ min)'
    END AS length_bucket
    FROM film
) AS binned
GROUP BY length_bucket
ORDER BY length_bucket;


-- ------------------------------------------------------------
-- Q10. Correlated subquery: films with more actors than average
-- ------------------------------------------------------------
-- [GOAL] Compare each row against a global aggregate (the mean number
--        of actors per film) and keep the above-average ones.
-- [WHY]  The SELECT-list subquery is *correlated*: it references f.film_id
--        from the outer row, so it re-runs per film to count its cast.
--        The WHERE subquery is *uncorrelated*: it computes one scalar —
--        the average of those per-film counts — via a derived table that
--        first collapses film_actor into one row per film, then AVGs it.
--        Mixing correlated + scalar subqueries in one statement is the
--        pattern behind "above/below benchmark" analyses everywhere.
--        (A CTE would let us compute the per-film count once and reuse
--        it — that refactor is precisely Level 03's topic.)
SELECT f.film_id, f.title,
       (SELECT COUNT(*)
        FROM film_actor fa
        WHERE fa.film_id = f.film_id) AS actor_count
FROM film f
WHERE (SELECT COUNT(*)
       FROM film_actor fa
       WHERE fa.film_id = f.film_id)
      > (SELECT AVG(cnt)
         FROM (SELECT COUNT(*) AS cnt
               FROM film_actor
               GROUP BY film_id) AS per_film)
ORDER BY actor_count DESC;


-- ------------------------------------------------------------
-- Q11. Capstone: revenue per category (6-table chain + HAVING)
-- ------------------------------------------------------------
-- [GOAL] Rank content categories by the money they actually generated.
-- [WHY]  This walks the full relational chain payment -> rental ->
--        inventory -> film -> film_category -> category, aggregating
--        amount at the category grain. Two deliberate choices teach
--        real-world caution: (a) we INNER JOIN rental on p.rental_id,
--        which drops the few payments not tied to a rental — correct
--        here because we only want rental-driven revenue, but a choice
--        you must make consciously (LEFT JOIN would keep them as NULL);
--        (b) HAVING COUNT(*) >= 50 suppresses thin categories whose
--        average would be noise, not signal — filtering low-N groups
--        before trusting a ranking is basic statistical hygiene.
SELECT cat.name                AS category,
       COUNT(*)                AS rentals,
       ROUND(SUM(p.amount), 2) AS revenue
FROM payment p
JOIN rental        r   ON p.rental_id    = r.rental_id
JOIN inventory     i   ON r.inventory_id = i.inventory_id
JOIN film          f   ON i.film_id      = f.film_id
JOIN film_category fc  ON f.film_id      = fc.film_id
JOIN category      cat ON fc.category_id = cat.category_id
GROUP BY cat.name
HAVING COUNT(*) >= 50           -- ignore statistically thin groups
ORDER BY revenue DESC;


-- ============================================================
-- End of Level 02. Proceed to 03_advanced/ next
-- (window functions, CTEs, cohort analysis).
-- ============================================================