/* =========================================================
   TABLE OF CONTENTS — SQL DDL: Types & Domains
   =========================================================

1. DDL Overview — Types
   1.1 Requirement: Every Column Must Have a Type
   1.2 Static Typing in SQL
   1.3 Role of Types (Storage + Operations)

2. Built-in Types
   2.1 Character Types (CHAR, VARCHAR, TEXT)
   2.2 Numeric Types (INT, FLOAT)
   2.3 Boolean Type
   2.4 Date/Time Types (DATE, TIME, TIMESTAMP)
   2.5 Example: CREATE TABLE with Built-in Types

3. Values for These Types
   3.1 Literal Syntax Rules
   3.2 String, Numeric, Boolean, Date/Time Examples
   3.3 Example: INSERT with Typed Values

4. User-Defined Types (Domains)
   4.1 Domain Definition from Built-in Type
   4.2 Adding CHECK Constraints
   4.3 Adding DEFAULT Values
   4.4 Example: Grade Domain
   4.5 Example: Campus Domain
   4.6 Using Domains in CREATE TABLE

5. Semantics of Type Constraints
   5.1 When Constraints Are Checked (INSERT / UPDATE)
   5.2 Constraint Violation Example

6. Default Values
   6.1 When Defaults Are Applied
   6.2 INSERT with Missing Columns
   6.3 Example: Column Default in Table

7. Default for Type vs Default for Column
   7.1 Type Default (Global Scope)
   7.2 Column Default (Local Scope)
   7.3 Comparison Table
   7.4 Examples of Each

8. Exam-Level Mental Model
   8.1 Type = Storage + Legal Operations
   8.2 Domain = Reusable Constraint Wrapper
   8.3 CHECK Evaluated on Assignment
   8.4 Default Applied Only When Value Missing
   8.5 Type Default vs Column Default

=========================================================
*/


/**  DDL Overview - Types
SUMMARY:
    - In CREATE TABLE, every column nmust have a type.
    - Types enforce structure, storage, and legal operations.
    - SQL is statically typed -> DB must know how to store & compare values.
*/


/**  Built-in Types
CHAR(n)        -- Fixed-length string (padded)
VARCHAR(n)     -- Variable-length string (<= n)
TEXT           -- Unlimited string (PostgreSQL extension)
INT / INTEGER  -- Whole number
FLOAT / REAL   -- Approximate decimal
BOOLEAN        -- TRUE / FALSE
DATE           -- Date only
TIME           -- Time only
TIMESTAMP      -- Date + Time
*/
CREATE TABLE Student (
    sid        INT,
    firstname  VARCHAR(50),
    cgpa       FLOAT,
    enrolled   BOOLEAN,
    birthdate  DATE,
    created_at TIMESTAMP
);


/**  Values for These Types
RULES:
    - Strings -> single quotes
    - Numbers -> no quotes
    - Boolean -> TRUE, FALSE
    - Date/Time -> quoted strings
*/
INSERT INTO Student
VALUES (12345, 'Alice', 3.85, TRUE, '2003-04-12', '2024-01-10 14:15');


/**  User-Defined Types (Domains)
SUMMARY:
    - Def'd from a built-in type.
    - Add constraints and optional default.
    - Enforces reusable rules.
*/

-- Example: Grade Type
CREATE DOMAIN Grade AS INT
CHECK (VALUE >= 0 AND VALUE <= 100);
-- Now, use it. Any insert violating the range fails.
CREATE TABLE Took (
    sid   INT,
    grade Grade
);

-- Example: Campus Type
CREATE DOMAIN Campus AS VARCHAR(4)
DEFAULT 'StG'
CHECK (VALUE IN ('StG', 'UTM', 'UTSC'));
-- Now, use it.
CREATE TABLE Student (
    sid    INT,
    campus Campus
);


/**  Semantics of Type Constraints
Key Rule: Constraints are checked whenever a value is assigned,
including INSERT, UPDATE.
*/
UPDATE Took
SET grade = 120;  -- ERROR (violates domain constraint)


/**  Default Values
SUMMARY:
    - Default used when no value is provided.
    - Applies automatically during INSERT.
*/
CREATE TABLE Invite (
    name   TEXT,
    campus TEXT DEFAULT 'StG'
);

INSERT INTO Invite (name)
VALUES ('Charlie');
--     Result:
--     -------
--     name   = 'Charlie
--     campus = 'StG'


/**  Default for Type vs Default for Column
-------------------------------------------------------------------------------
              Type Default              |            Column Default
-------------------------------------------------------------------------------
 - Applies to every column of that type |   - Applies only to that column
 - Global behaviour                     |   - Local behaviour
-------------------------------------------------------------------------------
*/

-- Type Default
-- Every Campus column in any table defaults to 'StG'.
CREATE DOMAIN Campus AS VARCHAR(4) DEFAULT 'StG';

-- Column Default
-- Only this column defaults to 'UTM'.
CREATE STUDENT (
    sid    INT,
    campus VARCHAR(4) DEFAULT 'UTM'
);


/**  Exam-Level Mental Moel
1. Type -> storage + operations
2. Domain -> reusable constraint wrapper
3. CHECK runs on assignment
4. Default used only when value missing
5. Type default   = global
6. Column default = local
*/
