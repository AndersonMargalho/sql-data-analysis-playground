-- ============================================================
-- LEVEL 01 — FUNDAMENTALS  |  Dataset: Chinook (music retail)
-- ============================================================
-- Each query below is annotated with:
--   [GOAL]  the analytical question being answered
--   [WHY]   the reasoning behind the clauses used
-- Run them in order against an imported Chinook database.
-- Schema reference: Customer, Invoice, InvoiceLine, Track,
--                   Album, Artist, Genre, Employee, MediaType
-- ============================================================


-- ------------------------------------------------------------
-- Q1. Basic filtering: list every customer located in Brazil
-- ------------------------------------------------------------
-- [GOAL] Isolate a subset of rows by a categorical condition.
-- [WHY]  SELECT chooses columns; WHERE filters rows BEFORE any
--        aggregation happens. This is the atomic operation of
--        every analysis: "give me only the records that match".
SELECT CustomerId, FirstName, LastName, City, Country
FROM Customer
WHERE Country = 'Brazil';


-- ------------------------------------------------------------
-- Q2. Sorting + limiting: the 10 most expensive tracks
-- ------------------------------------------------------------
-- [GOAL] Rank rows by a numeric column and cap the result set.
-- [WHY]  ORDER BY ... DESC puts the largest values first; LIMIT
--        keeps the output readable. Together they answer "top N"
--        questions, the most common shape in reporting.
SELECT Name, Composer, UnitPrice
FROM Track
ORDER BY UnitPrice DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q3. Single JOIN: invoices enriched with customer names
-- ------------------------------------------------------------
-- [GOAL] Combine two related tables on a shared key.
-- [WHY]  Invoice stores CustomerId (a foreign key) but not the
--        name. JOIN Customer on that key resolves the ID into a
--        human-readable identity. INNER JOIN returns only rows
--        that have a match on BOTH sides.
SELECT i.InvoiceId, i.InvoiceDate, i.Total,
       c.FirstName, c.LastName
FROM Invoice i
JOIN Customer c ON i.CustomerId = c.CustomerId
ORDER BY i.Total DESC
LIMIT 5;


-- ------------------------------------------------------------
-- Q4. Multi-JOIN + aggregation: units sold per artist
-- ------------------------------------------------------------
-- [GOAL] Roll up a metric across a chain of related tables.
-- [WHY]  The path InvoiceLine -> Track -> Album -> Artist links
--        a sale to its creator. GROUP BY collapses many rows per
--        artist into one; SUM(quantity) aggregates the metric.
--        This 4-table join is the classic "sales by category"
--        pattern used everywhere in business analytics.
SELECT ar.Name AS Artist,
       SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
JOIN Track  t  ON il.TrackId = t.TrackId
JOIN Album  al ON t.AlbumId  = al.AlbumId
JOIN Artist ar ON al.ArtistId = ar.ArtistId
GROUP BY ar.Name
ORDER BY UnitsSold DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q5. LEFT JOIN: every customer, even those with no purchases
-- ------------------------------------------------------------
-- [GOAL] Keep all rows from the left table regardless of matches.
-- [WHY]  An INNER JOIN would silently drop customers who never
--        bought anything. LEFT JOIN preserves them (with NULLs on
--        the right side), so COUNT() reveals who is inactive and
--        ROUND(SUM(),2) formats spend cleanly. Recognizing when a
--        JOIN must be OUTER vs INNER is a core analytical skill.
SELECT c.CustomerId, c.FirstName, c.LastName,
       COUNT(i.InvoiceId)        AS NumberOfInvoices,
       ROUND(SUM(i.Total), 2)    AS TotalSpent
FROM Customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY TotalSpent DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q6. Genre coverage: tracks per genre (including empty genres)
-- ------------------------------------------------------------
-- [GOAL] Profile a dimension table against a fact table.
-- [WHY]  Starting FROM Genre and LEFT JOIN Track guarantees that
--        genres with zero tracks still appear (count = 0). This
--        exposes gaps in the catalogue — exactly the kind of
--        completeness check a careful evaluator runs before
--        trusting any downstream statistic.
SELECT g.Name AS Genre,
       COUNT(t.TrackId) AS TrackCount
FROM Genre g
LEFT JOIN Track t ON g.GenreId = t.GenreId
GROUP BY g.Name
ORDER BY TrackCount DESC;


-- ============================================================
-- End of Level 01. Proceed to 02_intermediate/ next.
-- ============================================================