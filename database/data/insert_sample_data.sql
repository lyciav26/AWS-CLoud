USE UniversityRegistration;
GO

PRINT 'Inserting sample data...';
GO

-- Clear existing data (in correct order)
DELETE FROM AUDIT_LOG;
DELETE FROM GRADE;
DELETE FROM ENROLLMENT;
DELETE FROM COURSE;
DELETE FROM STUDENT;
DELETE FROM LECTURER;
DELETE FROM STAFF;
DELETE FROM [USER];
GO

-- Reset identity seeds
DBCC CHECKIDENT ('[USER]', RESEED, 0);
DBCC CHECKIDENT ('STUDENT', RESEED, 0);
DBCC CHECKIDENT ('LECTURER', RESEED, 0);
DBCC CHECKIDENT ('STAFF', RESEED, 0);
DBCC CHECKIDENT ('COURSE', RESEED, 0);
DBCC CHECKIDENT ('ENROLLMENT', RESEED, 0);
DBCC CHECKIDENT ('GRADE', RESEED, 0);
DBCC CHECKIDENT ('AUDIT_LOG', RESEED, 0);
GO

/*
==============================================================================
INSERT USERS
Password for all users: admin123 (hashed with bcrypt)
==============================================================================
*/
INSERT INTO [USER] (username, email, password_hash, role) VALUES
-- Students (user_id 1-5)
('alice_wong', 'alice.wong@student.mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Student'),
('bob_tan', 'bob.tan@student.mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Student'),
('charlie_lim', 'charlie.lim@student.mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Student'),
('diana_ng', 'diana.ng@student.mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Student'),
('ethan_chua', 'ethan.chua@student.mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Student'),

-- Lecturers (user_id 6-8)
('dr_smith', 'smith@mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Lecturer'),
('prof_johnson', 'johnson@mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Lecturer'),
('dr_lee', 'lee@mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Lecturer'),

-- Staff (user_id 9-12)
('academic_admin', 'admin@mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Academic Admin'),
('exam_staff', 'exam@mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Exam Unit Staff'),
('admin', 'sysadmin@mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'System Admin'),
('jane_doe', 'jane.doe@student.mmu.edu.my', '$2b$10$rZJ3qV7VPQKxH8fF9yEWLOY7nJ3XqKxPLMw8zY4xQ5vN2sT6uH8qK', 'Student');
GO

/*
==============================================================================
INSERT STUDENTS
==============================================================================
*/
INSERT INTO STUDENT (user_id, student_number, program, year_of_study) VALUES
(1, 'S2021001', 'Computer Science', 3),
(2, 'S2021002', 'Data Science', 3),
(3, 'S2021003', 'Software Engineering', 3),
(4, 'S2021004', 'Information Technology', 2),
(5, 'S2021005', 'Computer Science', 2),
(12, 'S2021006', 'Data Science', 1);
GO

/*
==============================================================================
INSERT LECTURERS
==============================================================================
*/
INSERT INTO LECTURER (user_id, employee_number, department) VALUES
(6, 'L2015001', 'Faculty of Computing and Informatics'),
(7, 'L2018001', 'Faculty of Computing and Informatics'),
(8, 'L2019001', 'Faculty of Computing and Informatics');
GO

/*
==============================================================================
INSERT STAFF
==============================================================================
*/
INSERT INTO STAFF (user_id, employee_number, department) VALUES
(9, 'A2020001', 'Academic Affairs'),
(10, 'E2020001', 'Examination Unit'),
(11, 'S2020001', 'IT Department');
GO

/*
==============================================================================
INSERT COURSES
==============================================================================
*/
INSERT INTO COURSE (course_code, course_name, description, credits, semester, lecturer_id) VALUES
('DB101', 'Database Systems', 'Introduction to relational databases and SQL', 3, 'Semester 1 2024/2025', 1),
('WEB201', 'Web Development', 'Full-stack web development with modern frameworks', 3, 'Semester 1 2024/2025', 1),
('DS301', 'Data Structures', 'Advanced data structures and algorithms', 4, 'Semester 1 2024/2025', 2),
('SE401', 'Software Engineering', 'Software development lifecycle and methodologies', 3, 'Semester 1 2024/2025', 3),
('AI501', 'Artificial Intelligence', 'Introduction to AI and machine learning', 4, 'Semester 1 2024/2025', 2);
GO

/*
==============================================================================
INSERT ENROLLMENTS
==============================================================================
*/
INSERT INTO ENROLLMENT (student_id, course_id, enrollment_date, status) VALUES
-- alice_wong (student_id=1)
(1, 1, '2024-09-15 09:00:00', 'Active'),
(1, 2, '2024-09-15 09:30:00', 'Active'),

-- bob_tan (student_id=2)
(2, 1, '2024-09-15 10:00:00', 'Active'),
(2, 3, '2024-09-15 10:15:00', 'Active'),

-- charlie_lim (student_id=3)
(3, 2, '2024-09-15 11:00:00', 'Active'),
(3, 4, '2024-09-15 11:30:00', 'Active'),

-- diana_ng (student_id=4)
(4, 1, '2024-09-15 12:00:00', 'Active'),
(4, 5, '2024-09-15 12:30:00', 'Active'),

-- ethan_chua (student_id=5)
(5, 3, '2024-09-15 13:00:00', 'Active');
GO

/*
==============================================================================
INSERT GRADES
==============================================================================
*/
INSERT INTO GRADE (enrollment_id, assignment_grade, exam_grade, final_grade, letter_grade, status, graded_by) VALUES
(1, NULL, NULL, NULL, NULL, 'Pending', NULL),
(2, NULL, NULL, NULL, NULL, 'Pending', NULL),
(3, NULL, NULL, NULL, NULL, 'Pending', NULL),
(4, NULL, NULL, NULL, NULL, 'Pending', NULL),
(5, NULL, NULL, NULL, NULL, 'Pending', NULL),
(6, NULL, NULL, NULL, NULL, 'Pending', NULL),
(7, NULL, NULL, NULL, NULL, 'Pending', NULL),
(8, NULL, NULL, NULL, NULL, 'Pending', NULL),
(9, NULL, NULL, NULL, NULL, 'Pending', NULL);
GO

/*
==============================================================================
VERIFICATION
==============================================================================
*/
PRINT '';
PRINT '=== DATA INSERTION SUMMARY ===';
PRINT 'Users: ' + CAST((SELECT COUNT(*) FROM [USER]) AS NVARCHAR(10));
PRINT 'Students: ' + CAST((SELECT COUNT(*) FROM STUDENT) AS NVARCHAR(10));
PRINT 'Lecturers: ' + CAST((SELECT COUNT(*) FROM LECTURER) AS NVARCHAR(10));
PRINT 'Staff: ' + CAST((SELECT COUNT(*) FROM STAFF) AS NVARCHAR(10));
PRINT 'Courses: ' + CAST((SELECT COUNT(*) FROM COURSE) AS NVARCHAR(10));
PRINT 'Enrollments: ' + CAST((SELECT COUNT(*) FROM ENROLLMENT) AS NVARCHAR(10));
PRINT 'Grades: ' + CAST((SELECT COUNT(*) FROM GRADE) AS NVARCHAR(10));
PRINT '';
PRINT 'âœ… Sample data inserted successfully!';
PRINT '';
PRINT '=== TEST CREDENTIALS ===';
PRINT 'All passwords: admin123';
PRINT 'Student: alice_wong / admin123';
PRINT 'Lecturer: dr_smith / admin123';
PRINT 'Admin: academic_admin / admin123';
GO