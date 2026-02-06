USE UniversityRegistration;
GO

-- Drop existing tables in correct order (foreign key dependencies)
IF OBJECT_ID('AUDIT_LOG', 'U') IS NOT NULL DROP TABLE AUDIT_LOG;
IF OBJECT_ID('GRADE', 'U') IS NOT NULL DROP TABLE GRADE;
IF OBJECT_ID('ENROLLMENT', 'U') IS NOT NULL DROP TABLE ENROLLMENT;
IF OBJECT_ID('COURSE', 'U') IS NOT NULL DROP TABLE COURSE;
IF OBJECT_ID('STUDENT', 'U') IS NOT NULL DROP TABLE STUDENT;
IF OBJECT_ID('LECTURER', 'U') IS NOT NULL DROP TABLE LECTURER;
IF OBJECT_ID('STAFF', 'U') IS NOT NULL DROP TABLE STAFF;
IF OBJECT_ID('[USER]', 'U') IS NOT NULL DROP TABLE [USER];
GO

/*
==============================================================================
TABLE: USER - Master user table
==============================================================================
*/
CREATE TABLE [USER] (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    role NVARCHAR(50) NOT NULL CHECK (role IN ('Student', 'Lecturer', 'Academic Admin', 'Exam Unit Staff', 'System Admin')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

/*
==============================================================================
TABLE: STUDENT
==============================================================================
*/
CREATE TABLE STUDENT (
    student_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL UNIQUE,
    student_number NVARCHAR(20) NOT NULL UNIQUE,
    program NVARCHAR(100) NOT NULL,
    year_of_study INT NOT NULL CHECK (year_of_study BETWEEN 1 AND 4),
    FOREIGN KEY (user_id) REFERENCES [USER](user_id) ON DELETE CASCADE
);
GO

/*
==============================================================================
TABLE: LECTURER
==============================================================================
*/
CREATE TABLE LECTURER (
    lecturer_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL UNIQUE,
    employee_number NVARCHAR(20) NOT NULL UNIQUE,
    department NVARCHAR(100) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES [USER](user_id) ON DELETE CASCADE
);
GO

/*
==============================================================================
TABLE: STAFF
==============================================================================
*/
CREATE TABLE STAFF (
    staff_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT NOT NULL UNIQUE,
    employee_number NVARCHAR(20) NOT NULL UNIQUE,
    department NVARCHAR(100) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES [USER](user_id) ON DELETE CASCADE
);
GO

/*
==============================================================================
TABLE: COURSE
==============================================================================
*/
CREATE TABLE COURSE (
    course_id INT PRIMARY KEY IDENTITY(1,1),
    course_code NVARCHAR(20) NOT NULL UNIQUE,
    course_name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    credits INT NOT NULL CHECK (credits > 0),
    semester NVARCHAR(20) NOT NULL,
    lecturer_id INT,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (lecturer_id) REFERENCES LECTURER(lecturer_id) ON DELETE SET NULL
);
GO

/*
==============================================================================
TABLE: ENROLLMENT
==============================================================================
*/
CREATE TABLE ENROLLMENT (
    enrollment_id INT PRIMARY KEY IDENTITY(1,1),
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATETIME DEFAULT GETDATE(),
    status NVARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Dropped', 'Completed')),
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id) ON DELETE CASCADE,
    CONSTRAINT UQ_Student_Course UNIQUE (student_id, course_id, status)
);
GO

/*
==============================================================================
TABLE: GRADE
==============================================================================
*/
CREATE TABLE GRADE (
    grade_id INT PRIMARY KEY IDENTITY(1,1),
    enrollment_id INT NOT NULL UNIQUE,
    assignment_grade DECIMAL(5,2) CHECK (assignment_grade >= 0 AND assignment_grade <= 100),
    exam_grade DECIMAL(5,2) CHECK (exam_grade >= 0 AND exam_grade <= 100),
    final_grade DECIMAL(5,2) CHECK (final_grade >= 0 AND final_grade <= 100),
    letter_grade NVARCHAR(2),
    status NVARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Submitted', 'Finalized')),
    graded_by INT,
    graded_at DATETIME,
    FOREIGN KEY (enrollment_id) REFERENCES ENROLLMENT(enrollment_id) ON DELETE CASCADE,
    FOREIGN KEY (graded_by) REFERENCES LECTURER(lecturer_id)
);
GO

/*
==============================================================================
TABLE: AUDIT_LOG
==============================================================================
*/
CREATE TABLE AUDIT_LOG (
    log_id INT PRIMARY KEY IDENTITY(1,1),
    user_id INT,
    action NVARCHAR(100) NOT NULL,
    table_name NVARCHAR(50),
    record_id INT,
    timestamp DATETIME DEFAULT GETDATE(),
    details NVARCHAR(MAX),
    FOREIGN KEY (user_id) REFERENCES [USER](user_id) ON DELETE SET NULL
);
GO

/*
==============================================================================
INDEXES - Performance Optimization
==============================================================================
*/
CREATE INDEX IX_USER_Username ON [USER](username);
CREATE INDEX IX_USER_Email ON [USER](email);
CREATE INDEX IX_USER_Role ON [USER](role);
CREATE INDEX IX_STUDENT_StudentNumber ON STUDENT(student_number);
CREATE INDEX IX_STUDENT_UserId ON STUDENT(user_id);
CREATE INDEX IX_LECTURER_EmployeeNumber ON LECTURER(employee_number);
CREATE INDEX IX_LECTURER_UserId ON LECTURER(user_id);
CREATE INDEX IX_STAFF_EmployeeNumber ON STAFF(employee_number);
CREATE INDEX IX_STAFF_UserId ON STAFF(user_id);
CREATE INDEX IX_COURSE_CourseCode ON COURSE(course_code);
CREATE INDEX IX_COURSE_LecturerId ON COURSE(lecturer_id);
CREATE INDEX IX_COURSE_Semester ON COURSE(semester);
CREATE INDEX IX_ENROLLMENT_StudentId ON ENROLLMENT(student_id);
CREATE INDEX IX_ENROLLMENT_CourseId ON ENROLLMENT(course_id);
CREATE INDEX IX_ENROLLMENT_Status ON ENROLLMENT(status);
CREATE INDEX IX_ENROLLMENT_Date ON ENROLLMENT(enrollment_date);
CREATE INDEX IX_GRADE_EnrollmentId ON GRADE(enrollment_id);
CREATE INDEX IX_GRADE_Status ON GRADE(status);
CREATE INDEX IX_GRADE_GradedBy ON GRADE(graded_by);
CREATE INDEX IX_AUDIT_UserId ON AUDIT_LOG(user_id);
CREATE INDEX IX_AUDIT_Timestamp ON AUDIT_LOG(timestamp);
CREATE INDEX IX_AUDIT_Action ON AUDIT_LOG(action);
GO

PRINT 'âœ… Database schema created successfully!';
GO