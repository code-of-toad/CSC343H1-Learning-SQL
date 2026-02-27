/* =========================================================
   TABLE OF CONTENTS — Modifying a Database
   =========================================================

1. Modifying a Database (Overview)

2. INSERT — Adding Tuples
   2.1 Purpose and Mental Model
   2.2 INSERT with Explicit VALUES
   2.3 INSERT ... SELECT (Copy from Query Result)

3. INSERT — Naming Attributes
   3.1 DEFAULT and NULL Behavior
   3.2 Partial Column Inserts
   3.3 Overriding Defaults Explicitly

4. DELETE — Removing Tuples
   4.1 DELETE with WHERE (Selective Deletion)
   4.2 DELETE without WHERE (Remove All Rows)
   4.3 Mental Model of DELETE

5. DELETE with Correlated Subqueries
   5.1 NOT EXISTS Pattern
   5.2 Deleting Rows Based on Missing Related Data

6. UPDATE — Modifying Existing Tuples
   6.1 UPDATE Syntax and Mental Model
   6.2 Updating a Single Row
   6.3 Updating Multiple Rows

7. UPDATE — Expressions in SET
   7.1 Using Existing Column Values
   7.2 Expression Evaluation Rules
   7.3 Example: Curving Grades
   7.4 Example: Capping Values with LEAST

8. Modification Safety Notes (Exam-Relevant)
   8.1 WHERE Keeps Only TRUE
   8.2 Dangers of Missing WHERE
   8.3 Subquery Cardinality + NULL Rules
   8.4 INSERT ... SELECT Column Matching Requirements

=========================================================
*/


/**  Modifying a Database
*/


/**  INSERT - Adding Tuples
INSERT adds new rows to a table.
It does NOT return a relation; it modifies state.

Two forms:
    1. Explicit VALUES
    2. INSERT ... SELECT (copy from a query result)

Mental Model: INSERT takes a set of tuples and appends them to the relation.
*/

-- Insert explicit rows
INSERT INTO Student (sid, firstname, campus)
VALUES
    (12345, 'Alice', 'UTM'),
    (67890, 'Bob',   'StG');

-- Insert from a query result
-- Copy high-CGOA students into Invite table
INSERT INTO Invite (name, email)
SELECT firstname, email
FROM Student
WHERE cgpa > 3.4;


/**  INSERT - Naming Attributes
If you provide only some columns, PostgreSQL:
    - Uses DEFAULT if defined
    - Otherwise inserts NULL

You should always name columns unless providing all of them.
*/

-- Suppose Invite(name TEXT, campus TEXT DEFAULT 'StG', email TEXT, age INT)
--     Result:
--     -------
--     name   = 'Charlie'
--     campus = 'StG'  <-- (default)
--     email  = 'charlie@mail.utoronto.ca'
--     age    = NULL
INSERT INTO Invite (name, email)
VALUES ('Charlie', 'charlie@mail.utoronto.ca');

-- Instead, explicitly override default
--     Result:
--     -------
--     name   = 'Charlie'
--     campus = 'UTM'
--     email  = 'charlie@mail.utoronto.ca'
--     age    = NULL
INSERT INTO Invite (name, campus, email)
VALUES ('Charlie', 'UTM', 'charlie@mail.utoronto.ca');


/**  DELETE - Removing Tuples
DELETE removes rows satisfying a condition.
Without WHERE, it removes ALL rows (but keeps the table structure).

Mental Model: DELETE filters rows and removes those that evaluate TRUE.
*/

-- Delete specific rows
DELETE FROM Student
WHERE campus = 'UTM';

-- Delete all rows (table remains)
DELETE FROM Student;


/**  DELETE w/ Correlated Subquery
DELETE can use subqueries (including correlated ones).

Common Pattern: DELETE rows for which no related row exists.
*/

-- Delete courses that no student passed (>50)
-- Mental Model: For each course row, check if a passing record exists.
--               If non exists, then delete that course.
DELETE FROM Course c
WHERE NOT EXISTS (
    SELECT 1
    FROM Took t
    JOIN Offering o ON t.oid = o.oid
    WHERE t.grade > 50
      AND o.dept = c.dept
      AND o.cnum = c.cnum
);


/**  UPDATE - Modifying Existing Tuples
UPDATE changes attribute values for rows that satisfy WHERE.
Without WHERE -> Updates ALL rows.

Mental Model:
    1. Identify target rows (WHERE)
    2. Apply attribute assignments (SET)
*/

-- Update one row
UPDATE Student
SET campus = 'UTM'
WHERE sid = 99999;

-- Update multiple rows
UPDATE Took
SET grade = 50
WHERE grade >= 47
  AND grade < 50;


/**  UPDATE - Expressions in SET
SET can use expressions involving existing column values.
Evaluation uses the old tuple values.
*/

-- Curve all grades by +5
UPDATE Took
SET grade = grade + 5
WHERE grade IS NOT NULL;

-- Curve all grades by +5 AND cap grades at 100
UPDATE Took
SET grade = LEAST(grade + 5, 100)
WHERE grade IS NOT NULL;


/* =========================================================
   Modification Safety Notes (Exam-Relevant)
   ========================================================= */

/*
1) WHERE only keeps rows where condition = TRUE.
   FALSE and UNKNOWN rows are unaffected.

2) Forgetting WHERE in UPDATE or DELETE affects every row.

3) Subqueries in UPDATE/DELETE obey same cardinality + NULL rules
   as in SELECT.

4) INSERT ... SELECT must match number and type of columns.
*/
