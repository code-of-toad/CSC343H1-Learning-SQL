-- =============================================================================
-- PostgreSQL: Create and populate practice database
-- Schema: Student, Course, Offering, Took
-- Run this once to set up; re-run to reset (drops existing tables).
-- =============================================================================

-- Drop in reverse dependency order (so foreign keys don't block)
DROP TABLE IF EXISTS took;
DROP TABLE IF EXISTS offering;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS course;

-- -----------------------------------------------------------------------------
-- Create tables (dependency order)
-- -----------------------------------------------------------------------------

CREATE TABLE course (
    dept    VARCHAR(20) NOT NULL,
    cnum    VARCHAR(10) NOT NULL,
    name    VARCHAR(100),
    breadth VARCHAR(50),
    PRIMARY KEY (dept, cnum)
);

CREATE TABLE student (
    sid       INT PRIMARY KEY,
    surname   VARCHAR(50),
    firstname VARCHAR(50),
    campus    VARCHAR(50),
    email     VARCHAR(100),
    cgpa      DECIMAL(3, 2)
);

CREATE TABLE offering (
    oid     INT PRIMARY KEY,
    dept    VARCHAR(20) NOT NULL,
    cnum    VARCHAR(10) NOT NULL,
    name    VARCHAR(100),
    breadth VARCHAR(50),
    FOREIGN KEY (dept, cnum) REFERENCES course(dept, cnum)
);

CREATE TABLE took (
    sid   INT NOT NULL,
    oid   INT NOT NULL,
    grade DECIMAL(4, 2),
    PRIMARY KEY (sid, oid),
    FOREIGN KEY (sid) REFERENCES student(sid),
    FOREIGN KEY (oid) REFERENCES offering(oid)
);

-- -----------------------------------------------------------------------------
-- Populate (same dependency order)
-- -----------------------------------------------------------------------------

INSERT INTO course (dept, cnum, name, breadth) VALUES
    ('CSC', '343', 'Databases', 'Science'),
    ('CSC', '369', 'Operating Systems', 'Science'),
    ('MAT', '237', 'Calculus II', 'Science'),
    ('ENG', '140', 'Literature', 'Humanities');

INSERT INTO student (sid, surname, firstname, campus, email, cgpa) VALUES
    (101, 'Smith', 'Alice', 'St. George', 'alice.smith@mail.utoronto.ca', 3.82),
    (102, 'Jones', 'Bob', 'St. George', 'bob.jones@mail.utoronto.ca', 3.45),
    (103, 'Lee', 'Carol', 'Mississauga', 'carol.lee@mail.utoronto.ca', 3.91),
    (104, 'Wong', 'Dan', 'St. George', 'dan.wong@mail.utoronto.ca', 2.98);

INSERT INTO offering (oid, dept, cnum, name, breadth) VALUES
    (1, 'CSC', '343', 'Databases', 'Science'),
    (2, 'CSC', '343', 'Databases', 'Science'),
    (3, 'CSC', '369', 'Operating Systems', 'Science'),
    (4, 'MAT', '237', 'Calculus II', 'Science'),
    (5, 'ENG', '140', 'Literature', 'Humanities');

INSERT INTO took (sid, oid, grade) VALUES
    (101, 1, 87.5),
    (101, 4, 92.0),
    (102, 1, 73.0),
    (102, 3, 68.5),
    (103, 1, 91.0),
    (103, 2, 88.0),
    (103, 5, 85.0),
    (104, 4, 55.0);
