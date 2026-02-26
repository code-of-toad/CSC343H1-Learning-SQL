/*
 * TABLE OF CONTENTS
 * -----------------
 * 1. 3-Valued Logic (TRUE / FALSE / UNKNOWN)
 * 2. NULL in PostgreSQL (Comparison Rules)
 * 3. WHERE Only Keeps TRUE
 * 4. NOT with NULL
 * 5. AND / OR with NULL (3-Valued Logic)
 * 6. The NOT IN Trap (NULL Poisoning)
 * 7. Aggregates and NULL Behavior
 * 8. DISTINCT and NULL
 * 9. JOIN Behavior with NULL
 * 10. GROUP BY and NULL
 * 11. UNIQUE Constraint and NULL (PostgreSQL)
 */


/**  3-Valued Logic (TRUE / FALSE / UNKNOWN)
Map to numbers:
    TRUE = 1
    FALSE = 0
    UNKNOWN = 0.5
    AND = min
    OR = max
    NOT x = (1 - x)

NOT
 A | NOT A
---+------
 T | F
 F | T
 U | U

AND
 A  B | A AND B
-----+---------
 T  T | T
 T  F | F
 F  T | F
 F  F | F
 T  U | U
 U  T | U
 F  U | F
 U  F | F
 U  U | U

OR
 A  B | A OR B
-----+---------
 T  T | T
 T  F | T
 F  T | T
 F  F | F
 T  U | T
 U  T | T
 F  U | U
 U  F | U
 U  U | U
*/


/**  NULL in PostgreSQL
In SQL, any comparison w/ NULL yields UNKNOWN (U):
  - (x = NULL)    -> U
  - (x <> NULL)   -> U
  - (x < NULL)    -> U
  - (NULL = NULL) -> U

Thus, you MUST always use `IS NULL` or `IS NOT NULL` (never use `= NULL`).
*/

-- All values for the last two columns are UNKNOWN
SELECT id,
       a,
       (a = NULL) AS eq_null,
       (a <> NULL) AS ne_null
FROM Relation;

-- Returns 0 rows (UNKNOWN is rejected by WHERE)
SELECT *
FROM Relation
WHERE a = NULL:

-- Correct NULL checks
SELECT *
FROM Relation
WHERE a IS NULL;

SELECT *
FROM Relation
WHERE a IS NOT NULL;


/**  WHERE only keeps TRUE
A row appears in query results only if the WHERE condition evaluates the TRUE.

If it's FALSE or UNKNOWN, the row is filtered out.
*/

-- Show what the comparison evaluates to per row
SELECT a, b, (a = b) AS eq.result 
FROM Relation;

-- Keep only rows where (a = b) is TRUE
-- UNKNOWN rows vanish
SELECT *
FROM Relation
WHERE a = b;


/**  NOT w/ NULL stays NULL
NOT doesn't "fix" UNKNOWN.

I.e., If P is UNKNOWN, then NOT P is still UNKNOWN.
      So, WHERE NOT(P) still filters the row out.
*/

-- Observe NOT interacts w/ NULL comparisons
SELECT id,
       a,
       (a = 10) AS p,
       NOT (a = 10) AS not_p
FROM Relation;

-- Rows where a is NULL won't appear (condition becomes UNKNOWN)
SELECT *
FROM Relation
WHERE NOT (a = 10);


/**  AND / OR with NULL (3-valued logic)
SQL uses 3-valued logic (TRUE, FALSE, UNKNOWN).

- AND: if any side is FALSE --> TRUE
- OR:  if any side is TRUE  --> TRUE
- UNKNOWN can propagate if no decisive TRUE / FALSE exists.
*/

-- AND
-- Only rows where BOTH conditions are TRUE survive
SELECT *
FROM Relation
WHERE
    (a = 10)   -- may be TRUE or NULL
    AND
    (b = 10);  -- may be TRUE or NULL
-- TRUE AND TRUE  --> TRUE  (kept)
-- TRUE AND NULL  --> NULL  (dropped)
-- FALSE anywhere --> FALSE (dropped)

-- OR
SELECT *
FROM Relation
WHERE
    (a = 10)   -- may be TRUE or NULL
    OR
    (b = 10);  -- may be TRUE or NULL
-- TRUE OR NULL   --> TRUE  (kept)
-- FALSE OR NULL  --> NULL  (dropped)
-- FALSE OR FALSE --> FALSE (dropped)


/**  The `NOT IN` trap (NULL in the list poisons it)
If the subquery contains NULL, then NOT IN can evaluate to UNKNOWN
and filter out rows unexpectedly.
*/

-- Evaluate directly: often returns NULL if Relation contains NULL
SELECT 3 NOT IN (SELECT x FROM Relation) AS result;

-- Returns no row if result is NULL, since WHERE only keeps TRUE
SELECT 3
WHERE 3 NOT IN (SELECT x FROM Relation);
-- Why???
-- 3 NOT IN (1,2,NULL) becomes:
--     3 <> 1 AND 3 <> 2 AND 3 <> NULL
-- Which evaluates to:
--     TRUE AND TRUE AND NULL  -->  NULL

-- SAFE ALTERNATIVE:
-- NOT EXISTS avoids NULL comparison issues
SELECT 3
WHERE NOT EXISTS (
    SELECT 1
    FROM Relation
    WHERE Relation.x = 3
);


/**  Aggregates ignore NULL (except COUNT(*))
Aggregate functions ignore NULL inputs. They operate only on non-NULL values.
*/

-- If all values are NULL, then:
--     SUM, AVG, MIN, MAX --> NULL
--     COUNT(a) --> 0
SELECT
    COUNT(*) AS count_rows,
    COUNT(a) AS count_a,
    SUM(a)   AS sum_a,
    AVG(a)   AS avg_a,
    MIN(a)   AS min_a,
    MAX(a)   AS max_a
FROM Relation;


/**  DISTINCT and NULL
PostgreSQL treats NULl values as duplicates for DISTINCT elimination.
Multiple NULLs collapse into one output row.
*/

-- Even if many rows have NULL, DISCTINCT will show NULL only once.
SELECT DISTINCT a
FROM Relation;


/**  JOIN does not match NULL = NULL
JOIN conditions must evaluate to TRUE.
Since NULL = NULL --> UNKNOWN, NULL keys do not match in normal equality joins.
*/
-- Standard equality join
-- NULL keys will not match
SELECT *
FROM L
JOIN R
  ON L.k = R.k;

-- If you explicitly want NULLs to match, do this...
SELECT *
FROM L
JOIN R
  ON (L.k = R.K)
     OR
     (L.k IS NULL AND R.k IS NULL);


/**  GROUP BY includes a NULL group
GROUP BY does not discard NULL. All NULL values are grouped together
into one group.
*/

-- You will see one row where a is NULL
SELECT a, COUNT(*) AS n
FROM Relation
GROUP BY a
ORDER BY a;


/**  UNIQUE constraint allows multiple NULLs (PostgreSQL)
In PostgreSQL, UNIQUE allows multiple NULL values, since NULL is not considered
equal to NULL.
*/

-- Both inserts succeed in PostgreSQL
-- This works because NULL !== NULL in uniqueness checking
INSERT INTO Relation VALUES (NULL);
INSERT INTO Relation VALUES (NULL);
