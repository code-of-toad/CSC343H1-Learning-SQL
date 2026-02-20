SET search_path TO university;

-- Clean insert order: Student -> Course -> Offering -> Took

-- =========================
-- Students (edge cases)
-- =========================
-- Includes:
-- - cgpa at boundaries (0.00, 4.00)
-- - duplicate surnames / first names
-- - ties on cgpa
-- - students with no Took rows
INSERT INTO Student (sID, surName, firstName, campus, email, cgpa) VALUES
  (1001, 'Han',     'Danny',  'UTSG', 'danny.han@example.com',     3.62),
  (1002, 'Patel',   'Riya',   'UTSC', 'riya.patel@example.com',    3.18),
  (1003, 'Nguyen',  'Minh',   'UTM',  'minh.nguyen@example.com',   3.91),
  (1004, 'Chen',    'Ava',    'UTSG', 'ava.chen@example.com',      2.74),
  (1005, 'Singh',   'Arjun',  'UTM',  'arjun.singh@example.com',   3.40),

  -- duplicates / ties
  (1006, 'Singh',   'Ava',    'UTSG', 'ava.singh@example.com',     3.40), -- same first name as 1004, same cgpa as 1005
  (1007, 'Patel',   'Riya',   'UTM',  'riya.patel2@example.com',    3.18), -- same name+cgpa as 1002 but different person
  (1008, 'Li',      'Kai',    'UTSC', 'kai.li@example.com',         4.00), -- max cgpa
  (1009, 'Li',      'Mina',   'UTSC', 'mina.li@example.com',        0.00), -- min cgpa
  (1010, 'Brown',   'Sam',    'UTSG', 'sam.brown@example.com',      3.91), -- cgpa tie with 1003

  -- students with no Took rows (for anti-joins)
  (1011, 'Ibrahim', 'Noor',   'UTM',  'noor.ibrahim@example.com',   2.10),
  (1012, 'Garcia',  'Leo',    'UTSG', 'leo.garcia@example.com',     2.10),

  -- more variety
  (1013, 'Khan',    'Zara',   'UTSC', 'zara.khan@example.com',      3.00),
  (1014, 'Khan',    'Zara',   'UTSG', 'zara.khan2@example.com',     3.00), -- same full name/cgpa diff campus
  (1015, 'Wong',    'Ethan',  'UTM',  'ethan.wong@example.com',     1.25);

-- =========================
-- Courses (edge cases)
-- =========================
-- Includes:
-- - multiple depts and breadths
-- - courses with NO offerings (for LEFT JOIN / NOT EXISTS)
INSERT INTO Course (dept, cNum, name, breadth) VALUES
  ('CSC', 207, 'Software Design',           'Science'),
  ('CSC', 236, 'Theory of Computation',     'Science'),
  ('CSC', 263, 'Data Structures & Analysis','Science'),
  ('MAT', 137, 'Calculus I',                'Science'),
  ('MAT', 223, 'Linear Algebra I',          'Science'),
  ('PHL', 101, 'Intro Philosophy',          'Humanities'),
  ('PHL', 245, 'Philosophy of Mind',        'Humanities'),
  ('ECO', 101, 'Principles of Economics',   'Social Science'),
  ('PSY', 100, 'Intro Psychology',          'Social Science'),

  -- course with no offering (deliberate)
  ('ENG', 140, 'Intro Literary Study',      'Humanities');

-- =========================
-- Offerings (edge cases)
-- =========================
-- Includes:
-- - multiple offerings per course (same dept/cNum, different oID)
-- - some offerings with NO Took rows
INSERT INTO Offering (oID, dept, cNum, name, breadth) VALUES
  -- CSC207 (3 offerings)
  (5001, 'CSC', 207, 'Software Design',            'Science'),
  (5002, 'CSC', 207, 'Software Design',            'Science'),
  (5003, 'CSC', 207, 'Software Design',            'Science'),

  -- CSC236 (2 offerings)
  (5010, 'CSC', 236, 'Theory of Computation',      'Science'),
  (5011, 'CSC', 236, 'Theory of Computation',      'Science'),

  -- CSC263 (1 offering)
  (5020, 'CSC', 263, 'Data Structures & Analysis', 'Science'),

  -- MAT
  (5030, 'MAT', 137, 'Calculus I',                 'Science'),
  (5031, 'MAT', 137, 'Calculus I',                 'Science'),
  (5040, 'MAT', 223, 'Linear Algebra I',           'Science'),

  -- PHL
  (5050, 'PHL', 101, 'Intro Philosophy',           'Humanities'),
  (5060, 'PHL', 245, 'Philosophy of Mind',         'Humanities'),

  -- ECO / PSY
  (5070, 'ECO', 101, 'Principles of Economics',    'Social Science'),
  (5080, 'PSY', 100, 'Intro Psychology',           'Social Science'),

  -- offering with NO Took rows (deliberate)
  (5099, 'PSY', 100, 'Intro Psychology',           'Social Science');

-- =========================
-- Took (edge cases)
-- =========================
-- Includes:
-- - NULL grades (in progress)
-- - 0 and 100
-- - decimals
-- - many-to-many patterns for self-join practice:
--   "students who took the same offering"
--   "students who share >=2 offerings"
-- - students who take multiple offerings of same course (e.g., 207 twice) to simulate repeats
--   (allowed because key is (sID,oID), not (sID,dept,cNum))
INSERT INTO Took (sID, oID, grade) VALUES
  -- Danny (1001): takes multiple CSC, plus MAT
  (1001, 5001, 85.00),
  (1001, 5010, 78.50),
  (1001, 5030, 92.00),

  -- Riya (1002): overlaps with 1001 on 5001, overlaps with others on PHL101
  (1002, 5001, 67.00),
  (1002, 5050, 88.00),
  (1002, 5070, 73.25),

  -- Minh (1003): high performer, overlaps on CSC236 offering 5010
  (1003, 5010, 92.00),
  (1003, 5020, 95.00),
  (1003, 5040, 90.00),

  -- Ava Chen (1004): in-progress + low grade edge
  (1004, 5002, NULL),
  (1004, 5031, 54.00),
  (1004, 5070, 0.00),

  -- Arjun (1005): overlaps with multiple students on ECO101 and PHL101
  (1005, 5070, 74.00),
  (1005, 5050, 81.00),
  (1005, 5080, 69.50),

  -- Ava Singh (1006): simulates repeating CSC207 (different offering), plus CSC236
  (1006, 5001, 90.00),
  (1006, 5003, 96.00),
  (1006, 5011, 89.00),

  -- Riya Patel #2 (1007): same name as 1002; overlaps on 5050 + 5070 for "shared courses" queries
  (1007, 5050, 88.00),
  (1007, 5070, 73.25),
  (1007, 5030, 61.00),

  -- Kai Li (1008): cgpa 4.00, includes 100 grade edge + NULL grade
  (1008, 5010, 100.00),
  (1008, 5060, 93.00),
  (1008, 5080, NULL),

  -- Mina Li (1009): cgpa 0.00 but still can have mixed grades
  (1009, 5030, 12.00),
  (1009, 5050, 35.50),

  -- Sam Brown (1010): cgpa ties with Minh (1003); overlaps on CSC263 offering 5020
  (1010, 5020, 95.00),
  (1010, 5011, 76.00),
  (1010, 5040, 84.00),

  -- Zara Khan (1013): overlaps with multiple in PSY100 offering 5080
  (1013, 5080, 77.00),
  (1013, 5070, 68.00),

  -- Zara Khan (1014): same full name as 1013, different campus; takes same offering 5080 for "same-name classmates"
  (1014, 5080, 77.00),
  (1014, 5050, 82.00),

  -- Ethan (1015): lots of "lower tail" grades
  (1015, 5031, 49.00),
  (1015, 5070, 58.00);
