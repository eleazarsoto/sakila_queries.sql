-- ============================================================
-- Sakila Database — SQL Business Analysis (SQLite)
-- Author: Eleazar Soto
-- 5 business questions covering revenue trends, category
-- performance, rental volume, customer value, and
-- per-group ranking (CTE + window function).
-- All queries tested against sakila.db (SQLite)
-- ============================================================


-- ------------------------------------------------------------
-- Query 1: How much revenue do we collect per month?
-- ------------------------------------------------------------
SELECT strftime('%Y-%m', payment_date) AS Month,
ROUND(SUM(amount), 2) AS Revenue
FROM payment
GROUP BY strftime('%Y-%m', payment_date)
ORDER BY Month;


-- ------------------------------------------------------------
-- Query 2: Which 5 film categories generate the most revenue?
-- ------------------------------------------------------------
SELECT c.name AS Category, ROUND(SUM(p.amount), 2) AS Revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY Revenue DESC
LIMIT 5;


-- ------------------------------------------------------------
-- Query 3: Which 10 films were rented the most?
-- ------------------------------------------------------------
SELECT f.title, COUNT(r.rental_id) AS Rentals
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY Rentals DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Query 4: Who are our 10 most valuable customers?
-- Note: ROUND(..., 2) cleans up floating-point artifacts
-- (e.g. 216.54000000000002) that accumulate when summing
-- many decimal payment amounts.
-- ------------------------------------------------------------
SELECT c.first_name || ' ' || c.last_name AS FullName,
       ROUND(SUM(p.amount), 2) AS TotalSpent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY TotalSpent DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Query 5: Top 3 films by revenue within EACH of the Action
-- and Comedy categories.
-- Notes:
--   * A plain LIMIT 3 would rank both categories combined
--     (global top 3): Comedy outsells Action, so Action
--     disappeared from the result entirely.
--   * ROW_NUMBER() OVER (PARTITION BY c.name ...) restarts
--     the ranking inside each category, so each one keeps
--     its own top 3.
--   * The CTE (Ranking) is required because window function
--     results cannot be filtered in the same SELECT's WHERE.
-- Result: 6 rows (3 Action + 3 Comedy)
-- ------------------------------------------------------------
WITH Ranking AS (
    SELECT f.title,
           c.name AS Category,
           ROUND(SUM(p.amount), 2) AS Revenue,
           ROW_NUMBER() OVER (PARTITION BY c.name ORDER BY SUM(p.amount) DESC) AS Rank
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    WHERE c.name IN ('Action', 'Comedy')
    GROUP BY f.film_id, c.category_id
)
SELECT Category, title, Revenue, Rank
FROM Ranking
WHERE Rank <= 3
ORDER BY Category, Rank;
