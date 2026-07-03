-- ============================================================
-- Sakila Database — SQL Business Analysis (SQLite)
-- Author: Eleazar Soto
-- Business scenario: management requested key performance
-- metrics for a DVD rental business. Five questions answered
-- with documented, tested queries.
-- ============================================================


-- ------------------------------------------------------------
-- Q1: How much revenue do we collect per month?
-- Grouping by '%Y-%m' (year-month) prevents mixing months
-- from different years. strftime works on payment_date;
-- amounts are summed with SUM(amount).
-- Result: 5 active months. Peak: July 2005 ($28,373.89).
-- Sanity check: months sum to $67,416.51, the payment total.
-- ------------------------------------------------------------
SELECT strftime('%Y-%m', payment_date) AS Month,
       ROUND(SUM(amount), 2) AS Revenue
FROM payment
GROUP BY strftime('%Y-%m', payment_date)
ORDER BY Month;


-- ------------------------------------------------------------
-- Q2: Which 5 film categories generate the most revenue?
-- 5-table chain: payment -> rental -> inventory ->
-- film_category -> category. The film table is not needed:
-- inventory already carries film_id.
-- Result: Sports ($5,314) leads, but the top 5 is tight —
-- less than $1,000 separates #1 from #5.
-- ------------------------------------------------------------
SELECT c.name AS Category,
       ROUND(SUM(p.amount), 2) AS Revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY Revenue DESC
LIMIT 5;


-- ------------------------------------------------------------
-- Q3: Which 10 films had the most rentals?
-- Top-N recipe: COUNT to measure, ORDER BY ... DESC to rank,
-- LIMIT to cut. Without ORDER BY, LIMIT returns arbitrary rows.
-- Grouped by film_id (primary key) rather than title.
-- Result: BUCKET BROTHERHOOD leads with 34 rentals.
-- ------------------------------------------------------------
SELECT f.title, COUNT(r.rental_id) AS Rentals
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY Rentals DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q4: Who are our 10 most valuable customers?
-- "Valuable" = total spend -> SUM(amount), not COUNT of visits.
-- Result: KARL SEAL tops the list at $221.55 — roughly 4x the
-- spend of the lowest-spending customers (~$50).
-- ------------------------------------------------------------
SELECT c.first_name || ' ' || c.last_name AS FullName,
       ROUND(SUM(p.amount), 2) AS TotalSpent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY TotalSpent DESC
LIMIT 10;


-- ------------------------------------------------------------
-- Q5: Top 3 films by revenue within the Action and Comedy
-- categories. Six-table chain (film added for the title) plus
-- WHERE ... IN for the two categories. Category names in
-- Sakila are stored in English ('Action', 'Comedy') — verified
-- with SELECT DISTINCT before filtering.
-- Result: the entire podium is Comedy — ZORRO ARK ($214.69),
-- HUSTLER PARTY ($190.78), CAT CONEHEADS ($181.70).
-- ------------------------------------------------------------
SELECT f.title, c.name AS Category,
       ROUND(SUM(p.amount), 2) AS Revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name IN ('Action', 'Comedy')
GROUP BY f.film_id
ORDER BY Revenue DESC
LIMIT 3;
