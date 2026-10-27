

CREATE DATABASE IF NOT EXISTS StudentPerformanceDB;
USE StudentPerformanceDB;

-- STEP 2: DROP EXISTING TABLES
-- WARNING: This resets the project's existing tables.
DROP VIEW IF EXISTS Student_Performance_View;
DROP TABLE IF EXISTS Marks;
DROP TABLE IF EXISTS Attendance;
DROP TABLE IF EXISTS Examinations;
DROP TABLE IF EXISTS Subjects;
DROP TABLE IF EXISTS Students;

-- STEP 3: CREATE STUDENTS TABLE
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10),
    class_name VARCHAR(30)
);

-- STEP 4: CREATE SUBJECTS TABLE
CREATE TABLE Subjects (
    subject_id INT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL
);

-- STEP 5: CREATE EXAMINATIONS TABLE
CREATE TABLE Examinations (
    exam_id INT PRIMARY KEY,
    exam_name VARCHAR(50) NOT NULL,
    exam_date DATE
);

-- STEP 6: CREATE MARKS TABLE
CREATE TABLE Marks (
    mark_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    exam_id INT NOT NULL,
    marks_obtained DECIMAL(5,2) NOT NULL,
    total_marks DECIMAL(5,2) NOT NULL,

    FOREIGN KEY (student_id)
        REFERENCES Students(student_id),

    FOREIGN KEY (subject_id)
        REFERENCES Subjects(subject_id),

    FOREIGN KEY (exam_id)
        REFERENCES Examinations(exam_id),

    UNIQUE (student_id, subject_id, exam_id),

    CHECK (marks_obtained >= 0),
    CHECK (total_marks > 0),
    CHECK (marks_obtained <= total_marks)
);

-- STEP 7: CREATE ATTENDANCE TABLE
CREATE TABLE Attendance (
    student_id INT PRIMARY KEY,
    total_classes INT NOT NULL,
    classes_attended INT NOT NULL,

    FOREIGN KEY (student_id)
        REFERENCES Students(student_id),

    CHECK (total_classes > 0),
    CHECK (classes_attended >= 0),
    CHECK (classes_attended <= total_classes)
);

-- STEP 8: INSERT STUDENT DATA
INSERT INTO Students VALUES
(1, 'Aarav Sharma', 'Male', 'MCA'),
(2, 'Priya Verma', 'Female', 'MCA'),
(3, 'Rahul Singh', 'Male', 'MCA'),
(4, 'Ananya Gupta', 'Female', 'MCA'),
(5, 'Karan Kumar', 'Male', 'MCA'),
(6, 'Simran Kaur', 'Female', 'MCA');

-- STEP 9: INSERT SUBJECT DATA
INSERT INTO Subjects VALUES
(101, 'DBMS'),
(102, 'Python'),
(103, 'Mathematics');

-- STEP 10: INSERT EXAMINATION DATA
INSERT INTO Examinations VALUES
(1, 'Mid Term', '2026-09-15');

-- STEP 11: INSERT MARKS DATA
INSERT INTO Marks
(student_id, subject_id, exam_id,
 marks_obtained, total_marks)
VALUES
(1, 101, 1, 85, 100),
(1, 102, 1, 78, 100),
(1, 103, 1, 92, 100),

(2, 101, 1, 90, 100),
(2, 102, 1, 88, 100),
(2, 103, 1, 95, 100),

(3, 101, 1, 45, 100),
(3, 102, 1, 55, 100),
(3, 103, 1, 40, 100),

(4, 101, 1, 72, 100),
(4, 102, 1, 80, 100),
(4, 103, 1, 76, 100),

(5, 101, 1, 32, 100),
(5, 102, 1, 48, 100),
(5, 103, 1, 35, 100),

(6, 101, 1, 68, 100),
(6, 102, 1, 74, 100),
(6, 103, 1, 82, 100);

-- STEP 12: INSERT ATTENDANCE DATA
INSERT INTO Attendance VALUES
(1, 100, 90),
(2, 100, 96),
(3, 100, 65),
(4, 100, 85),
(5, 100, 55),
(6, 100, 88);

-- STEP 13: CREATE A VIEW FOR TABLEAU
CREATE VIEW Student_Performance_View AS
SELECT
    s.student_id,
    s.student_name,
    s.gender,
    s.class_name,
    sub.subject_name,
    e.exam_name,
    e.exam_date,
    m.marks_obtained,
    m.total_marks,

    ROUND(
        100.0 * m.marks_obtained / m.total_marks,
        2
    ) AS marks_percentage,

    ROUND(
        100.0 * a.classes_attended / a.total_classes,
        2
    ) AS attendance_percentage,

    CASE
        WHEN m.marks_obtained / m.total_marks >= 0.40
        THEN 'Pass'
        ELSE 'Fail'
    END AS result

FROM Students s
JOIN Marks m
    ON s.student_id = m.student_id
JOIN Subjects sub
    ON m.subject_id = sub.subject_id
JOIN Examinations e
    ON m.exam_id = e.exam_id
JOIN Attendance a
    ON s.student_id = a.student_id;

-- =====================================================
-- STEP 14: ANALYSIS QUERIES
-- =====================================================

-- A. DISPLAY ALL STUDENTS
SELECT * FROM Students;

-- B. DISPLAY ALL TABLES' RECORD COUNTS
SELECT 'Students' AS table_name, COUNT(*) AS total
FROM Students
UNION ALL
SELECT 'Subjects', COUNT(*) FROM Subjects
UNION ALL
SELECT 'Examinations', COUNT(*) FROM Examinations
UNION ALL
SELECT 'Marks', COUNT(*) FROM Marks
UNION ALL
SELECT 'Attendance', COUNT(*) FROM Attendance;

-- C. STUDENT MARKS WITH SUBJECT NAMES
SELECT
    s.student_name,
    sub.subject_name,
    m.marks_obtained,
    m.total_marks
FROM Students s
JOIN Marks m
    ON s.student_id = m.student_id
JOIN Subjects sub
    ON m.subject_id = sub.subject_id
ORDER BY s.student_name, sub.subject_name;

-- D. AVERAGE MARKS PER STUDENT
SELECT
    s.student_id,
    s.student_name,
    ROUND(AVG(100.0 * m.marks_obtained /
                    m.total_marks), 2) AS average_percentage
FROM Students s
JOIN Marks m
    ON s.student_id = m.student_id
GROUP BY s.student_id, s.student_name
ORDER BY average_percentage DESC;

-- E. SUBJECT-WISE AVERAGE PERCENTAGE
SELECT
    sub.subject_name,
    ROUND(AVG(100.0 * m.marks_obtained /
                    m.total_marks), 2) AS average_percentage
FROM Subjects sub
JOIN Marks m
    ON sub.subject_id = m.subject_id
GROUP BY sub.subject_id, sub.subject_name
ORDER BY average_percentage DESC;

-- F. PASS PERCENTAGE BY SUBJECT
-- Pass threshold: 40%
SELECT
    sub.subject_name,
    COUNT(*) AS total_students,
    SUM(
        CASE
            WHEN m.marks_obtained / m.total_marks >= 0.40
            THEN 1 ELSE 0
        END
    ) AS passed,
    SUM(
        CASE
            WHEN m.marks_obtained / m.total_marks < 0.40
            THEN 1 ELSE 0
        END
    ) AS failed,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN m.marks_obtained / m.total_marks >= 0.40
                THEN 1 ELSE 0
            END
        ) / COUNT(*), 2
    ) AS pass_percentage
FROM Subjects sub
JOIN Marks m
    ON sub.subject_id = m.subject_id
GROUP BY sub.subject_id, sub.subject_name;

-- G. ATTENDANCE PERCENTAGE
SELECT
    s.student_name,
    a.classes_attended,
    a.total_classes,
    ROUND(100.0 * a.classes_attended /
                    a.total_classes, 2)
        AS attendance_percentage
FROM Students s
JOIN Attendance a
    ON s.student_id = a.student_id
ORDER BY attendance_percentage DESC;

-- H. STUDENTS WHO SCORED BELOW 40% IN ANY SUBJECT
SELECT
    s.student_name,
    sub.subject_name,
    m.marks_obtained,
    m.total_marks
FROM Students s
JOIN Marks m
    ON s.student_id = m.student_id
JOIN Subjects sub
    ON m.subject_id = sub.subject_id
WHERE m.marks_obtained / m.total_marks < 0.40;

-- I. VIEW DATA FOR TABLEAU EXPORT
SELECT * FROM Student_Performance_View;


USE StudentPerformanceDB;
SELECT * FROM Student_Performance_View;
