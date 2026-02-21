/**  Views
VIEW is a relation def'd in terms of stored tables (called base tables)
and other views. Access a VIEW like any base table.

Two types of VIEW: (WE WILL ONLY USE VIRTUAL VIEWS)
    1. Virtual: No tuples are stored; merely a named query for constructing
                the relation on demand.
                * Every query of a VIEW reflects the current state of the DB *
                
    2. Materialized: Actually constructed & stored.
                     Expensive to maintain.
                     * NOT updated w/ current data *

Why use a VIEW ???
------------------
- Break down a large query
- Provide another way of looking at the same data,
  e.g., for one category of user
*/
-- A view for students who earned an 80 or higher in a CSC course
-- I.e., we are defining a table called `topresults`
CREATE VIEW topresults AS
SELECT firstname, surname, cnum
FROM Student, Took, Offering
WHERE Student.sid = Took.sid
  AND Took.oid = Offering.oid
  AND grade >= 90
  AND dept = 'CSC';
-- Now, since topresults is still a relation, it has rows & columns.
-- Use it in SELECT, joins, and subqueries.


/**  Inner Joins
FROM table_1, table_2                   <->  table_1 x table_2
FROM table_1 CROSS JOIN table_2         <->  table_1 x table_2
FROM table_1 NATRUAL JOIN table_2       <->  table_1 ⋈ table_2
FROM table_1 JOIN table_2 ON condition  <->  table_1 ⋈_{condition} table_2

IMPORTANT: Natural joins are brittle, since no syntax/runtime error will warn
           us of incorrect results that will emerge when 2+ tables are modified
           to each contain new columns w/ the same name but for different
           purposes.

           I.e, natural joins are "brittle". DO NOT USE NATURAL JOINS.

ALWAYS WRITE JOINS EXPLICITLY: Never rely on column names implicitly for joins.
*/

-- Use theta-join (JOIN ON) for sensible combos
-- Use WHERE for real filtering
SELECT Student.sID, instructor
FROM Student
    JOIN Took ON Student.sID = Took.sID
    JOIN Offering ON Took.oID = Offering.oID
WHERE grade >= 90;


/**  Outer Joins
Dangling Tuples:
----------------
For joins that require some attributes to match, tuples lacking a match
are left out of the results. These tuples are "dangling".

Note that relational algebra joins are inner joins by default.

- Inner Join: Does NOT preserve dangling tuples. Any rows whose join-columns
              don't match across the two tables are dropped from the results.
- Outer Join: Preserves dangling tuples by padding them w/ NULL
              in the other relation.

Three types of outer joins:
    1. FROM table_1 LEFT JOIN table_2 ON condition:
            Preserves dangling tuples from the relation on the LHS
            by padding w/ NULL's on the RHS.
    2. FROM table_1 RIGHT JOIN table_2 ON condition:
            Does the reverse.
    3. FROM table_1 FULL JOIN table_2 ON condition:
            Does both.

NOTE: You get an outer join IFF you use the keywords LEFT, RIGHT, or FULL.
      Otherwise, you get an inner join.
*/

-- List all customers who have placed at least one order
SELECT c.customer_id, c.name, o.order_id
FROM Customers c
    JOIN Orders o
        ON c.customer_id = o.customer_id;

-- List all customers, including those who never placed an order
SELECT c.customer_id, c.name, o.order_id
FROM Customers c
    LEFT JOIN Orders o
        ON c.customer_id = o.customer_id;

-- Show all orders, even if customer data is missing
SELECT o.order_id, c.name
FROM Customers c
    RIGHT JOIN Orders o
        ON c.customer_id = o.customer_id;

-- Show all students and their grades (if any)
SELECT s.sid, s.name, t.grade
FROM Student s
    LEFT JOIN Took t
        ON s.sid = t.sid;

-- Compare employees in two databases (data auditing & finding mismatches)
-- I.e., Detect which records match and which are missing across two databases
SELECT
    a.emp_id AS in_A,
    b.emp_id AS in_B,
    CASE
        WHEN a.emp_id IS NULL THEN 'Only in B'
        WHEN b.emp_id IS NULL THEN 'Only in A'
        ELSE 'In both'
    END AS status
FROM HR_System_A a
    FULL JOIN HR_System_B b
        ON a.emp_id = b.emp_id;

-- Compute total spending per customer, including those w/ no orders
-- For customers w/ no orders, total_spent is converted from NULL to 0
SELECT c.customer_id, COALESCE(SUM(o.amount), 0) AS total_spent
FROM Customers c
    LEFT JOIN Orders o
        ON c.customer_id = o.customer_id
GROUP BY c.customer_id;
