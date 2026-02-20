-- =============================================================================
-- SQL DML Notes — Syntax & Query Reference
-- =============================================================================
-- Use -- for single-line notes.
-- Use /* ... */ for multi-line notes or to temporarily disable blocks of code.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. SELECT — Basic retrieval
-- -----------------------------------------------------------------------------
-- Syntax: SELECT columns FROM table [WHERE condition] [ORDER BY col]
-- * means "all columns"

SELECT * FROM my_table;

-- Specific columns, with optional alias (AS can be omitted)
SELECT id, name AS customer_name, created_at
FROM my_table;


-- -----------------------------------------------------------------------------
-- 2. Filtering — WHERE, AND, OR, IN, LIKE, BETWEEN
-- -----------------------------------------------------------------------------
-- WHERE: filter rows before grouping/aggregation

SELECT * FROM my_table
WHERE status = 'active'
  AND created_at >= '2024-01-01'
  AND id IN (1, 2, 3);

-- LIKE: pattern matching. % = any chars, _ = one char
SELECT * FROM my_table WHERE name LIKE 'John%';

-- BETWEEN: inclusive on both ends
SELECT * FROM my_table WHERE price BETWEEN 10 AND 20;


-- -----------------------------------------------------------------------------
-- 3. Aggregation — GROUP BY, HAVING
-- -----------------------------------------------------------------------------
-- Aggregate functions: COUNT, SUM, AVG, MIN, MAX
-- GROUP BY: one row per distinct value of grouped columns
-- HAVING: filter on aggregated values (after GROUP BY)

SELECT category, COUNT(*) AS num_items, AVG(price) AS avg_price
FROM products
GROUP BY category
HAVING COUNT(*) > 5;


-- -----------------------------------------------------------------------------
-- 4. JOINs
-- -----------------------------------------------------------------------------
-- INNER JOIN: only rows that match in both tables
-- LEFT JOIN: all from left, match from right (NULL if no match)
-- RIGHT JOIN: all from right
-- FULL OUTER JOIN: all from both (NULL where no match)

SELECT o.id, o.amount, c.name
FROM orders o
INNER JOIN customers c ON o.customer_id = c.id;


-- -----------------------------------------------------------------------------
-- 5. Subqueries
-- -----------------------------------------------------------------------------
-- In WHERE (must return one column; IN for multiple values)
SELECT * FROM products
WHERE category_id IN (SELECT id FROM categories WHERE active = true);

-- Scalar subquery (single value)
SELECT name, (SELECT COUNT(*) FROM orders WHERE orders.customer_id = customers.id) AS order_count
FROM customers;


-- -----------------------------------------------------------------------------
-- 6. INSERT, UPDATE, DELETE (modify data)
-- -----------------------------------------------------------------------------
-- INSERT
-- INSERT INTO table (col1, col2) VALUES (val1, val2);
-- INSERT INTO table SELECT ... (from another table);

-- UPDATE
-- UPDATE table SET col = value WHERE condition;

-- DELETE
-- DELETE FROM table WHERE condition;


-- =============================================================================
-- Add your own sections below (e.g. window functions, CTEs, set ops)
-- =============================================================================
