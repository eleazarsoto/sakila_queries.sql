# Sakila SQL Analysis 🎬

Business-driven SQL analysis of the **Sakila database** — a DVD rental store dataset (SQLite). Framed as a real stakeholder request: management asked for five key performance metrics, answered here with documented, tested queries.

> Part of my Data Analytics portfolio. Also see my [Chinook SQL Analysis](https://github.com/eleazarsoto/chinook-sql-analysis) (17 queries) and [Northwind SQL Analysis](https://github.com/eleazarsoto/sql-northwind-analysis) (39 queries).

## 📊 Dataset

Sakila models a DVD rental business with 16 tables:

| Area | Tables |
|---|---|
| Catalog | `film` (1,000) → `film_category` ↔ `category` (16), `film_actor` ↔ `actor` (200) |
| Operations | `inventory` (4,581 physical copies) → `rental` (16,044) → `payment` (16,049 / $67,416.51) |
| Customers | `customer` (599) with full address chain (`address` → `city` → `country`) |
| Stores | `store` (2) and `staff` (2) |

Key modeling detail: films are rented through **inventory** (physical copies), so revenue queries chain `payment → rental → inventory → film` — a step closer to real-world retail schemas.

## ❓ Business questions answered

1. **Monthly revenue** — grouped by year-month to avoid mixing years; peak in July 2005 ($28,373.89)
2. **Top 5 categories by revenue** — 5-table JOIN; Sports leads a tightly packed top 5
3. **Top 10 most-rented films** — the Top-N recipe: COUNT + ORDER BY DESC + LIMIT
4. **Top 10 most valuable customers** — "valuable" translated to total spend (SUM), not visit count
5. **Top 3 films by revenue in Action & Comedy** — 6-table JOIN with `WHERE ... IN`; the podium turned out to be all Comedy

## 🛠️ Skills demonstrated

- Multi-table JOINs up to 6 tables through an inventory-based rental chain
- Translating business language into metrics ("most valuable" → SUM of payments)
- The Top-N pattern and why LIMIT without ORDER BY returns arbitrary rows
- Date grouping with `strftime('%Y-%m', ...)` to keep months from different years separate
- Data exploration before filtering (`SELECT DISTINCT` revealed category names stored in English)
- Cross-validation of results against table grand totals

## 💡 Selected findings

- **Revenue is highly seasonal**: July 2005 generated ~6x the revenue of May 2005; February 2006 shows only residual activity ($514).
- **No dominant category**: less than $1,000 separates the #1 (Sports, $5,314) from the #5 (Comedy, $4,383) — income is well distributed across the catalog.
- **Customer value spread**: the top customer (Karl Seal, $221.55) spends ~4x more than the lowest-spending customers (~$50) — a clear segmentation opportunity.
- **Comedy sweeps the podium**: in the Action vs Comedy face-off, the top 3 revenue films are all Comedy.

## 📁 Files

- [`sakila_queries.sql`](sakila_queries.sql) — all queries, commented, with expected results and business notes
- `sqlite-sakila.sqlite` — SQLite database (source: [Sakila sample database](https://dev.mysql.com/doc/sakila/en/), SQLite port)

## 🔧 Tools

SQLite · SQLiteViz · Git/GitHub

---
**Eleazar Soto** — Data Analyst | Music Producer
[LinkedIn](https://www.linkedin.com/in/eleazar-soto-data/) · [GitHub](https://github.com/eleazarsoto)
