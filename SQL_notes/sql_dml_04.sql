/*
===========================================================
TABLE OF CONTENTS — SUBQUERIES (PostgreSQL)
===========================================================

1. Subqueries: Mental Model
   1.1 Three Subquery “Shapes”
       - Relation (FROM)
       - Scalar (single value)
       - Boolean (EXISTS / NOT EXISTS)
   1.2 Cardinality + NULL Exam Traps

2. Subquery in FROM (Derived Tables)
   2.1 Syntax Rules (Parentheses + Alias Required)
   2.2 JOIN vs Derived Table
   2.3 CTE Alternative
   2.4 PostgreSQL LATERAL Restriction

3. Scalar Subqueries (Single-Value)
   3.1 Exactly-One-Row Requirement
   3.2 0 Rows → NULL
   3.3 >1 Row → Runtime Error
   3.4 Aggregate Rewrite Pattern (MAX/MIN)

4. Multi-Row Subqueries (Quantifiers)
   4.1 ANY / SOME (Existential Semantics)
   4.2 ALL (Universal Semantics)
   4.3 Empty-Set Edge Cases

5. IN (Including Row-Value IN)
   5.1 Membership Semantics
   5.2 Row-Value Tuple Comparisons (PostgreSQL)
   5.3 NULL Propagation Behavior

6. NOT IN vs NOT EXISTS (NULL Trap)
   6.1 Why NOT IN Is Dangerous
   6.2 NULL-Safe Anti-Join with NOT EXISTS
   6.3 Explicit NULL Filtering

7. EXISTS / NOT EXISTS (Correlated Subqueries)
   7.1 Boolean Existence Semantics
   7.2 Correlation Mental Model
   7.3 Self-Correlation & Renaming

8. Scope and Aliasing Rules
   8.1 Closest-Scope Name Resolution
   8.2 Correlated vs Non-Correlated Subqueries
   8.3 Explicit Aliasing for Clarity

9. Rewriting IN Without IN
   9.1 EXISTS Rewrite
   9.2 JOIN + DISTINCT Rewrite
   9.3 Duplicate Semantics Considerations

10. Summary: Where Subqueries Can Go
    - As a relation in FROM
    - As a scalar value in WHERE
    - With ANY / ALL / IN / EXISTS
    - As operands to UNION / INTERSECT / EXCEPT

===========================================================
*/


/**  Subqueries: mental model
A subquery is a SELECT used inside another statement to supply:
    1. A relation (table of rows),
    2. A single value,
    3. A boolean test.

The big exam trap is cardinality + NULL behaviour:
    "Did it return 0/1/many rows?" and "Did it return NULL?"
beacuse that changes results or even throws an error.

Three common "shapes" to remember:
    - relation (many rows/cols): Used in FROM
    - scalar (exactly 1 row, 1 col): Used in FROM
    - boolean existence: EXISTS / NOT EXISTS
*/


/**  Subquery in FROM (derived table)
A subquery can stand in for a table in FROM.
It must be paranthesized and given an alis.

Conceptually: "Compute this intermediate relation, then query it."

In PostgreSQL, a derived table in FROM is not allowed to reference earlier
FROM items unless you use LATERAL.
*/

-- Derived table in FROM
SELECT
    t.sid,
    o.dept || o.cnum AS course,
    t.grade
FROM Took AS t
JOIN (
    SELECT *
    FROM Offering
    WHERE instructor = 'Horton'
) AS hoffering
    ON hoffering.oid = t.oid;

-- Another clean version (usually preferable): JOIN + filter (no subquery)
SELECT
    t.sid,
    o.dept || o.cnum AS course,
    t.grade
FROM Took AS t
JOIN Offering AS o
    ON o.oid = t.oid
WHERE o.instructor = 'Horton';

-- Same idea w/ a CTE (still DML; sometimes clearer for multi-step logic)
WITH H AS(
    SELECT oid, dept, cnum
    FROM Offering
    WHERE instructor = 'Horton'
)
SELECT t.sid, h.dept || h.cnum AS course, t.grade
FROM Took AS t
JOIN h ON h.oid = t.oid;


/**  Scalar subquery as a value (must be exactly 1 row)
A scalar subquery is used like a single value (e.g., on the right side of >).

IT MUST RETURN EXACTLY ONE ROW.
Returning 0 rows yields NULL, and returning >1 rows raises an error.

Comparisons with NULL produce NULL (UNKNOWN), which is treated as not passing
the WHERE filter.
*/

-- Compare against one specific student's CGPA
SELECT sid, surname
FROM Student
WHERE cgpa >
    (SELECT cgpa
     FROM Student
     WHERE sid = 99999);

-- Edge Case: If sid=99999 does NOT exist, the subquery return 0 rows --> NULL
-- Then: cgpa > NULL --> NULL, so WHERE filters out every row (empty result).

-- Edge Case: If sid is NOT unique and multiple rows match --> ERROR
-- ERROR: More than one row returned by a subquery used as an expression.

-- Exam-safe pattern to guarantee 1 row: Choose a rule!
SELECT sid, surname
FROM Student
WHERE cgpa >
    (SELECT MAX(cgpa)  -- forces exactly 1 row
     FROM Student
     WHERE sid = 99999);


/**  Multi-row subqueries: ANY/SOME or ALL
When a subquery can return many values, use a quantifier:
    ANY/SOME: "Exists at least one match"
    ALL: "Matches every value"

I.e.,  > ANY (set)  <-->  "Greater than the minimum-ish threhshold"
I.e.,  > ALL (set)  <-->  "Greater than the maximum" (all of them)
*/

-- "Greater than at least one StG CGPA" (usually easier to satisfy)
SELECT sid, surname
FROM Student
WHERE cgpa > ANY (
    SELECT cgpa
    FROM Student
    WHERE campus = 'StG'
);

-- "Greater than every StG CGPA" (must beat the max)
SELECT sid, surname
FROM Student
WHERE cgpa > ALL (
    SELECT cgpa
    FROM Student
    WHERE campus = 'StG'
);

-- Empty-set edge case (exam favorite):
---------------------------------------
--   1.  x > ALL (empty set)  --> TRUE (vacuously)
--   2.  x > ANY (empty set)  --> FALSE


/**  IN (including row-value IN)
IN (subquery) tests membership in the set of returned rows.

PostgreSQL supports row-value IN, so you can match multiple tuples
like (cnum, dept) IN (SELECT cnum, dept ...).

It's often the simplest way to express "belongs to the same (cnum,dept) pair."
*/

-- Row-value IN to match a (cnum,dept)
SELECT sid, dept || cnum AS course, grade
FROM Took NATURAL JOIN Offering
WHERE grade >= 80
    AND (cnum, dept) IN (
        SELECT cnum, dept
        FROM Took NATURAL JOIN Offering NATURAL JOIN Student
        WHERE surname = 'Lakemeyer'
    );

-- Key NULL edge case:
----------------------
-- x IN ( ... NULL ...) can become NULL (UNKNOWN) if no definite match is found.
--
-- Mental Model: IN is like a big OR; NULLs can poison the OR into UNKNOWN.


/**  NOT IN vs NOT EXISTS (the NULL trap)
NOT IN looks like the negation of IN, but NULL makes it dangerous.

If the subquery returns any NULL, then x NOT IN (subquery) can evaluate to NULL
for many x, filtering out everything.

NOT EXISTS is usually the exam-safe anti-join, because it doesn't have that
"NULL poisons the whole predicate" behaviour.
*/

-- BAD (can collapse to "returns nothing" if S.b contains NULLs)
SELECT a
FROM R
WHERE b NOT IN (SELECT b FROM S);

-- GOOD: NOT EXISTS anti-join (NULL-safe)
SELECT R.a
FROM R AS r
WHERE NOT EXISTS (
    SELECT 1
    FROM S AS s
    WHERE s.b = r.b
);

-- If you *must* use NOT IN, filter NULLs explicitly
SELECT r.a
FROM R AS r
WHERE r.b NOT IN (
    SELECT s.b
    FROM S AS s
    WHERE s.b IS NOT NULL
);


/**  EXISTS / NOT EXISTS (correlated subqueries)
EXISTS (subquery) is true if the subquery returns at least one row;
it's a boolean test, not a value.

Correlated subqueries reference columns from the outer query; conceptually
they run "per outer row" (even if the optimizer rewrites it)

Use EXISTS for "there is at least one related row satisfying ..."
Use NOT EXISTS for "there is no related row sayisfying ..."
*/

-- Students w/ at least one grade > 85
SELECT s.surname, s.cgpa
FROM Student AS s
WHERE EXISTS (
    SELECT 1
    FROM Took AS t
    WHERE t.sid = s.sid
      AND t.grade > 85
);

-- NOT EXISTS + renaming
-- "Instructors who have NO other offering (different oid) w/ the same instructor"
SELECT off1.instructor
FROM Offering AS off1
WHERE NOT EXISTS (
    SELECT 1
    FROM Offering AS off2
    WHERE off2.oid <> off1.oid
      AND off2.instructor = off1.instructor
);

-- EXISTS w/ correlation + extra joins
SELECT DISTINCT took_outer.oid
FROM Took AS took_outer
WHERE EXISTS (
    SELECT 1
    FROM Took AS t
    JOIN Offering AS o
        ON o.oid = t.oid
    WHERE t.oid = o.oid
      AND t.oid <> took_outer.oid
      AND o.dept = 'CSC'
      AND took_outer.sid = t.sid
);


/**  Scope + aliasing rules (how to avoid "which table did you mean?" bugs)
Name resolution is "closest scope wins":
    - If an identifier exists in the subquery and outer query,
      then the inner one is used, unless you qualify w/ an alias.
    - If a subquery references only names def'd inside it, then it can be
      evaluated once and reused;
      if it references outer names, then it's correlated (logically per outer row).

Always alias when the same table appears twice (self-joins / self-subqueries),
and qualify columns (off1.instructor) to make intent unambiguous.
*/

-- Make scope explicit via renaming (off1 vs off2), then qualify
SELECT off1.instructor
FROM Offering AS off1
WHERE NOT EXISTS (
    SELECT 1
    FROM Offering AS off2
    WHERE off2.instructor = off1.instructor
      AND off2.oid <> off1.oid
);


/**  Rewriting "IN" without IN (common equivalences)
x IN (SELECT y FROM S) is often equivalent to a join + distinct, or to EXISTS
w/ a correlation.

Prefer EXISTS when duplicates don't matter and you want a clear "there exists"
meaning.
*/

-- EXISTS rewrite (boolean "there exists an S row w/ matching b")
SELECT r.a
FROM R AS r
WHERE EXISTS (
    SELECT 1
    FROM S AS s
    WHERE s.b = r.b
);

-- JOIN rewrite (watch duplicates; use DISTINCT if needed)
SELECT DISTINCT r.a
FROM R AS r
JOIN S AS s
    ON s.b = r.b;


/**  SUMMARY: Where subqueries can go
1. As a relation in a FROM clause
2. As a value in a WHERE clause
3. With ANY, ALL, IN, or EXISTS in a WHERE clause
4. As operands to a UNION, INTERSECT, or EXCEPT
*/
