/**
SQL has 2 subparts:
  1. DDL (Data Definition Language):   Define schemas
  2. DML (Data Manipulation Language): Write queries & modify database
*/

-- Query w/ 1 relation
-- π_{name}(σ_{dept='CSC'}Course);
SELECT name
FROM Course
WHERE dept = 'CSC';

-- Query w/ multiple relations
-- π_{name}(σ_{Offering.id=Took.id ^ dept='CSC'}(Offering X Took));
SELECT name
FROM Offering, Took
WHERE Offering.id = Took.id
  AND dept = 'CSC';

-- Re-naming tables (just for the duration of the statement)
SELECT e.name, d.name          -- SELECT employee.name, department.name
FROM employee e, department d  -- FROM employee, department
WHERE d.name = 'marketing'     -- WHERE department.name = 'marketing'
  AND e.name = 'Horton';       --   AND employee.name = 'Horton';

-- Self-Joins: Re-naming is REQUIRED for self-joins
SELECT e1.name, e2.name
FROM employee e1, employee e2
WHERE e1.salary < e2.salary;

-- Re-naming Attributes: Use `AS <<new name>>` to re-name a resulting attribute
SELECT name AS title, dept
FROM Course
WHERE breadth;

-- * in SELECT clauses ("all attributes of this relation")
SELECT *
FROM Course
WHERE dept = 'CSC';


/**  Complex WHERE Conditions
Build boolean expressions with operators that produce boolean results.
  - Comparison Operators: =, <>, <, >, <=, >=
  - Many other operators... Refer to Chapter 9 of the PostgreSQL documentation

Combine boolean expressions with Boolean Operators: AND, OR, NOT
*/
-- E.g., find 3rd and 4th year CSC courses
SELECT *
FROM Course
WHERE dept = 'CSC'
  AND cnum >= 300;


/**  ORDER BY
To put tuplies in order, add this as the final clause:
    ORDER BY <<attribute list>> DESC
`DESC` overrides the default ascending order.

Attribute list can include expressions:
    ORDER BY sales + rentals

*** IMPORTANT ***
-----------------
Ordering is the last thing done before SELECT,
so all attributes are still available.

Execution Order:
    FROM --> WHERE --> ORDER BY --> SELECT
*/
SELECT name, salary
FROM employee
ORDER BY salary DESC;

-- First, sort by dept (ASC)
-- Then, within each dept, sort by salary (DESC)
SELECT name, dept, salary
FROM employee
ORDER BY dept, salary DESC;

-- Sorts by the computed value: sales + rentals
SELECT title, sales, rentals
FROM Movies
ORDER BY sales + rentals DESC;

-- Ordering by a column NOT in SELECT
SELECT name
FROM employee
ORDER BY salary DESC;

-- Ordering w/ renamed columns
SELECT name AS title, salary
FROM employee
ORDER BY salary;

SELECT name AS title, salary
FROM employee
ORDER BY title;


/**  Expressions in SELECT Clauses
- Operands:  attributes, constants
- Operators: arithmetic ops, string ops
*/
SELECT sid, grade+10 AS adjusted
FROM Took;

SELECT dept || cnum
FROM Course;


/**  Expressions That Are a Constant
Sometimes, it makes sense for the whole expression to be a constant
(something that does NOT involve any attributes)
*/
-- Create a new column called `breadthRequirement` whose every row is 'satisfies'
SELECT dept, cNum, 'satisfies' AS breadthRequirements
FROM Courses
WHERE breadth;


/**  Pattern Operators
Two ways to compare a string to a pattern, by:
  1. <<attribute>> LIKE <<pattern>>
  2. <<attribute>> NOT LIKE <<pattern>>

Pattern is a quoted string.
  %  <--  any string
  _  <--  any single character
*/
SELECT *
FROM Course
WHERE name LIKE '%Comp%';


/**  Aggregation: Computing on a Column
We want to compute something across across the values in a column.
    SUM, AVG, COUNT, MIN, MAX  <--  applied to a column in a SELECT clause
    COUNT(*) counts the number of tuples

NOTE: To stop duplicates from contributing to the aggregation,
      use DISTINCT inside the brackets (does NOT affect MIN or MAX).
*/
-- Removes duplicate (dept, salary) pairs
SELECT DISTINCT dept, salary  -- DISTINCT applies to the entire row, not just one column
FROM employee;                -- It removes duplicate tuples, not individual values

-- Counts the number of rows in the table
SELECT COUNT(*)
FROM employee;

-- Counts rows where salary is NOT NULL
SELECT COUNT(salary)
FROM employee;

-- Counts how many unique departments exist
SELECT COUNT(DISTINCT dept)
FROM employee;

-- Adds up all salaries
SELECT SUM(salary)
FROM employee;

-- Adds only unique salary values (no duplicates counted)
SELECT SUM(DISTINCT salary)
FROM employee;

-- Computes average salary
SELECT AVG(salary)
FROM employee;

-- Removes duplicate salaries before averaging
SELECT AVG(DISTINCT salary)
FROM employee;

-- Average salary only for CSC department
SELECT AVG(salary)
FROM employee
WHERE dept = 'CSC';

-- Returns a single row with multiple computed values
SELECT COUNT(*), AVG(salary), MIN(salary), MAX(salary)
FROM employee;


/**  Aggregation: GROUP BY
GROUP BY partitions rows into groups, and aggregation gives one value per group.

I.e., if we follow a SELECT-FROM-WHERE expression w/ GROUP BY <attributes>...
... 1. Tuples are grouped according to the values of those attributes,
    2. Any aggregation gives us a single value per group.

-------------------------------------------------------------------------------
*** IMPORTANT RULE ***
If you use aggregation, then every column in SELECT must be:
    1. aggregated, or...
    2. listed in GROUP BY.

Invalid Example:
----------------
SELECT dept, name, COUNT(*)   <-- name is neither grouped nor aggregated
FROM employee
GROUP BY dept;
-------------------------------------------------------------------------------
*/
-- Groups employees by dept & gives employee count per dept
SELECT, dept, COUNT(*)
FROM employee
GROUP BY dept;  --> Example Result:
                --   dept    count  --
                ----------------------
                --   CS      3      --
                --   Math    2      --
                --   HR      4      --
                ----------------------

-- Average salary per dept
SELECT dept, AVG(salary)
FROM employee
GROUP BY dept;


/**  Aggregation: HAVING
 WHERE lets you decide which TUPLES to keep
HAVING lets you decide witch GROUPS to keep

  ...
  GROUP BY <<attributes>>
  HAVING <<condition>>

-------------------------------------------------------------------------------
*** IMPORTANT RULE ***
Outside subqueries, HAVING may refer to attributes only if they are either:
    1. aggregated, or...
    2. listed in GROUP BY
(Same requirement as w/ SELECT clauses w/ aggregation)

Invalid Example:
----------------
SELECT dept, COUNT(*)
FROM employee
GROUP BY dept;
HAVING name = 'Alice';
-------------------------------------------------------------------------------
*/
-- Only keep departments w/ more than 2 employees
SELECT dept, COUNT(*)
FROM employee
GROUP BY dept
HAVING COUNT(*) > 2;

-- WHERE filters rows before grouping
-- Then, GROUP BY groups remaining rows
SELECT dept, COUNT(*)
FROM employee
WHERE salary > 50000
GROUP BY dept;

-- WHERE + HAVING:
-- Filter rows w/ WHERE
-- Form groups w/ GROUP BY
-- Filter groups w/ HAVING
SELECT dept, COUNT(*)
FROM employee
WHERE salary > 50000
GROUP BY dept
HAVING COUNT(*) > 2;

-- Only keep departments w/ high average salary
SELECT dept, AVG(salary)
FROM employee
GROUP BY dept
HAVING AVG(salary) > 70000;


/**  Set Operations
  UNION, INTERSECT, EXCEPT

Requirements: Both queries MUST have: 1. Same number of columns
                                      2. Compatible types

IMPORTANT: Set operations REMOVES DUPLICATES.
           You can override this with ALL. See below for example.
*/
-- Students who got very high OR very low grades
(SELECT sid FROM Took WHERE grade > 95)
UNION
(SELECT sid FROM Took WHERE grade < 50);

-- Students who got very high grades in CSC343
(SELECT sid FROM Took WHERE grade > 90)
INTERSECT
(SELECT sid FROM Took WHERE course = 'CSC343');

-- Students who got >90 but NOT in CSC343
(SELECT sid FROM Took WHERE grade > 90)
EXCEPT
(SELECT sid FROM Took WHERE course = 'CSC343');

-- Normally, set operations remove duplicates.
-- BUT: You can keep duplicates w/ ALL.
(SELECT sid FROM Took)
UNION ALL
(SELECT sid FROM TOOK);
