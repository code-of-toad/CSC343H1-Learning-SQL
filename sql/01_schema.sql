DROP SCHEMA IF EXISTS university CASCADE;
CREATE SCHEMA university;
SET search_path TO university;

-- Student(sID, surName, firstName, campus, email, cgpa), key: (sID)
CREATE TABLE Student (
    sID       INTEGER PRIMARY KEY,
    surName   TEXT    NOT NULL,
    firstName TEXT    NOT NULL,
    campus    TEXT    NOT NULL,
    email     TEXT    NOT NULL UNIQUE,
    cgpa      NUMERIC(3, 2) NOT NULL CHECK (cgpa >= 0.00 AND cgpa <= 4.00)
);

-- Course(dept, cNum, name, breadth), key: (dept, cNum)
CREATE TABLE Course (
    dept    TEXT    NOT NULL,
    cNum    INTEGER NOT NULL,
    name    TEXT    NOT NULL,
    breadth TEXT    NOT NULL,
    PRIMARY KEY (dept, cNum)
);

-- Offering(oID, dept, cNum, name, breadth), key: (oID)
-- FOREIGN KEY (dept, cNum) REFERENCES Course(dept, cNum)
CREATE TABLE Offering (
    oID     INTEGER PRIMARY KEY,
    dept    TEXT    NOT NULL,
    cNum    INTEGER NOT NULL,
    name    TEXT    NOT NULL,
    breadth TEXT    NOT NULL,
    CONSTRAINT fk_offering_course
      FOREIGN KEY (dept, cNum)
      REFERENCES Course(dept, cNum)
      ON UPDATE CASCADE
      ON DELETE RESTRICT
);

-- Took(sID, oID, grade), key: (sID, oID)
-- FOREIGN KEY (sID) REFERENCES Student(sID)
-- FOREIGN KEY (oID) REFERENCES Offering(oID)
CREATE TABLE Took (
    sID   INTEGER NOT NULL,
    oID   INTEGER NOT NULL,
    grade NUMERIC(5, 2) CHECK (grade IS NULL OR (grade >= 0.00 AND grade <= 100.00)),
    PRIMARY KEY (sID, oID),
    CONSTRAINT fk_took_student
      FOREIGN KEY (sID)
      REFERENCES Student(sID)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
    CONSTRAINT fk_took_offering
      FOREIGN KEY (oID)
      REFERENCES Offering(oID)
      ON UPDATE CASCADE
      ON DELETE CASCADE
);

-- Helpful indexes for joins (Postgres auto-indexes PK/UNIQUE, not FKs)
CREATE INDEX idx_offering_dept_cnum ON Offering(dept, cNum);
CREATE INDEX idx_took_oid           ON Took(oID);
