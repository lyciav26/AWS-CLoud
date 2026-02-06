USE UniversityRegistration;
GO

PRINT '========================================';
PRINT 'STARTING SECURITY IMPLEMENTATION';
PRINT '========================================';
GO

/*
==============================================================================
PART 1: DROP EXISTING SECURITY OBJECTS (Clean Slate)
==============================================================================
*/
PRINT 'Step 1: Cleaning up existing security objects...';
GO

-- Drop existing security policies
IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'EnrollmentSecurityPolicy')
    DROP SECURITY POLICY EnrollmentSecurityPolicy;
IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'GradeSecurityPolicy')
    DROP SECURITY POLICY GradeSecurityPolicy;
GO

-- Drop existing security functions
IF OBJECT_ID('Security.fn_EnrollmentSecurityPredicate', 'IF') IS NOT NULL
    DROP FUNCTION Security.fn_EnrollmentSecurityPredicate;
IF OBJECT_ID('Security.fn_GradeSecurityPredicate', 'IF') IS NOT NULL
    DROP FUNCTION Security.fn_GradeSecurityPredicate;
GO

-- Drop security schema if exists
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'Security')
    DROP SCHEMA Security;
GO

-- Drop existing stored procedures
IF OBJECT_ID('sp_RegisterCourse', 'P') IS NOT NULL
    DROP PROCEDURE sp_RegisterCourse;
IF OBJECT_ID('sp_DropCourse', 'P') IS NOT NULL
    DROP PROCEDURE sp_DropCourse;
IF OBJECT_ID('sp_EnterGrade', 'P') IS NOT NULL
    DROP PROCEDURE sp_EnterGrade;
IF OBJECT_ID('sp_FinalizeGrade', 'P') IS NOT NULL
    DROP PROCEDURE sp_FinalizeGrade;
GO

-- Drop existing triggers
IF OBJECT_ID('trg_AuditUserChanges', 'TR') IS NOT NULL
    DROP TRIGGER trg_AuditUserChanges;
IF OBJECT_ID('trg_AuditGradeChanges', 'TR') IS NOT NULL
    DROP TRIGGER trg_AuditGradeChanges;
GO

PRINT 'âœ… Cleanup completed';
GO

/*
==============================================================================
PART 2: CREATE DATABASE ROLES
==============================================================================
*/
PRINT 'Step 2: Creating database roles...';
GO

-- Drop roles if they exist
IF DATABASE_PRINCIPAL_ID('student_role') IS NOT NULL
    DROP ROLE student_role;
IF DATABASE_PRINCIPAL_ID('lecturer_role') IS NOT NULL
    DROP ROLE lecturer_role;
IF DATABASE_PRINCIPAL_ID('academic_admin_role') IS NOT NULL
    DROP ROLE academic_admin_role;
IF DATABASE_PRINCIPAL_ID('exam_unit_role') IS NOT NULL
    DROP ROLE exam_unit_role;
GO

-- Create roles
CREATE ROLE student_role;
CREATE ROLE lecturer_role;
CREATE ROLE academic_admin_role;
CREATE ROLE exam_unit_role;
GO

-- Grant permissions to student_role
GRANT SELECT ON [USER] TO student_role;
GRANT SELECT ON STUDENT TO student_role;
GRANT SELECT ON COURSE TO student_role;
GRANT SELECT ON ENROLLMENT TO student_role;
GRANT SELECT ON GRADE TO student_role;
GRANT SELECT ON LECTURER TO student_role;
GRANT EXECUTE ON sp_RegisterCourse TO student_role;
GRANT EXECUTE ON sp_DropCourse TO student_role;

-- Grant permissions to lecturer_role
GRANT SELECT ON [USER] TO lecturer_role;
GRANT SELECT ON STUDENT TO lecturer_role;
GRANT SELECT ON LECTURER TO lecturer_role;
GRANT SELECT ON COURSE TO lecturer_role;
GRANT SELECT ON ENROLLMENT TO lecturer_role;
GRANT SELECT, UPDATE ON GRADE TO lecturer_role;
GRANT EXECUTE ON sp_EnterGrade TO lecturer_role;

-- Grant permissions to academic_admin_role
GRANT SELECT, INSERT, UPDATE, DELETE ON [USER] TO academic_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON STUDENT TO academic_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON LECTURER TO academic_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON STAFF TO academic_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON COURSE TO academic_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ENROLLMENT TO academic_admin_role;
GRANT SELECT ON GRADE TO academic_admin_role;
GRANT SELECT ON AUDIT_LOG TO academic_admin_role;

-- Grant permissions to exam_unit_role
GRANT SELECT ON [USER] TO exam_unit_role;
GRANT SELECT ON STUDENT TO exam_unit_role;
GRANT SELECT ON LECTURER TO exam_unit_role;
GRANT SELECT ON COURSE TO exam_unit_role;
GRANT SELECT ON ENROLLMENT TO exam_unit_role;
GRANT SELECT, UPDATE ON GRADE TO exam_unit_role;
GRANT SELECT ON AUDIT_LOG TO exam_unit_role;
GRANT EXECUTE ON sp_FinalizeGrade TO exam_unit_role;
GO

PRINT 'âœ… Database roles created and permissions granted';
GO

/*
==============================================================================
PART 3: CREATE SERVER LOGINS (Run in master database context)
==============================================================================
*/
PRINT 'Step 3: Creating server logins...';
GO

USE master;
GO

-- Drop existing logins if they exist
DECLARE @LoginName NVARCHAR(50);
DECLARE login_cursor CURSOR FOR
SELECT name FROM sys.sql_logins 
WHERE name IN ('alice_wong', 'bob_tan', 'charlie_lim', 'diana_ng', 'ethan_chua', 'jane_doe',
               'dr_smith', 'prof_johnson', 'dr_lee',
               'academic_admin', 'exam_staff', 'admin');

OPEN login_cursor;
FETCH NEXT FROM login_cursor INTO @LoginName;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC('DROP LOGIN [' + @LoginName + ']');
    FETCH NEXT FROM login_cursor INTO @LoginName;
END;

CLOSE login_cursor;
DEALLOCATE login_cursor;
GO

-- Create logins for students
CREATE LOGIN alice_wong WITH PASSWORD = 'Student123!';
CREATE LOGIN bob_tan WITH PASSWORD = 'Student123!';
CREATE LOGIN charlie_lim WITH PASSWORD = 'Student123!';
CREATE LOGIN diana_ng WITH PASSWORD = 'Student123!';
CREATE LOGIN ethan_chua WITH PASSWORD = 'Student123!';
CREATE LOGIN jane_doe WITH PASSWORD = 'Student123!';

-- Create logins for lecturers
CREATE LOGIN dr_smith WITH PASSWORD = 'Lecturer123!';
CREATE LOGIN prof_johnson WITH PASSWORD = 'Lecturer123!';
CREATE LOGIN dr_lee WITH PASSWORD = 'Lecturer123!';

-- Create logins for staff
CREATE LOGIN academic_admin WITH PASSWORD = 'Admin123!';
CREATE LOGIN exam_staff WITH PASSWORD = 'ExamStaff123!';
CREATE LOGIN admin WITH PASSWORD = 'SystemAdmin123!';
GO

PRINT 'âœ… Server logins created';
GO

/*
==============================================================================
PART 4: CREATE DATABASE USERS AND ASSIGN ROLES
==============================================================================
*/
USE UniversityRegistration;
GO

PRINT 'Step 4: Creating database users and assigning roles...';
GO

-- Drop existing users if they exist
DECLARE @UserName NVARCHAR(50);
DECLARE user_cursor CURSOR FOR
SELECT name FROM sys.database_principals 
WHERE type = 'S' AND name IN ('alice_wong', 'bob_tan', 'charlie_lim', 'diana_ng', 'ethan_chua', 'jane_doe',
                               'dr_smith', 'prof_johnson', 'dr_lee',
                               'academic_admin', 'exam_staff', 'admin');

OPEN user_cursor;
FETCH NEXT FROM user_cursor INTO @UserName;

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC('DROP USER [' + @UserName + ']');
    FETCH NEXT FROM user_cursor INTO @UserName;
END;

CLOSE user_cursor;
DEALLOCATE user_cursor;
GO

-- Create database users for students
CREATE USER alice_wong FOR LOGIN alice_wong;
CREATE USER bob_tan FOR LOGIN bob_tan;
CREATE USER charlie_lim FOR LOGIN charlie_lim;
CREATE USER diana_ng FOR LOGIN diana_ng;
CREATE USER ethan_chua FOR LOGIN ethan_chua;
CREATE USER jane_doe FOR LOGIN jane_doe;

-- Create database users for lecturers
CREATE USER dr_smith FOR LOGIN dr_smith;
CREATE USER prof_johnson FOR LOGIN prof_johnson;
CREATE USER dr_lee FOR LOGIN dr_lee;

-- Create database users for staff
CREATE USER academic_admin FOR LOGIN academic_admin;
CREATE USER exam_staff FOR LOGIN exam_staff;
CREATE USER admin FOR LOGIN admin;
GO

-- Assign users to roles
ALTER ROLE student_role ADD MEMBER alice_wong;
ALTER ROLE student_role ADD MEMBER bob_tan;
ALTER ROLE student_role ADD MEMBER charlie_lim;
ALTER ROLE student_role ADD MEMBER diana_ng;
ALTER ROLE student_role ADD MEMBER ethan_chua;
ALTER ROLE student_role ADD MEMBER jane_doe;

ALTER ROLE lecturer_role ADD MEMBER dr_smith;
ALTER ROLE lecturer_role ADD MEMBER prof_johnson;
ALTER ROLE lecturer_role ADD MEMBER dr_lee;

ALTER ROLE academic_admin_role ADD MEMBER academic_admin;
ALTER ROLE exam_unit_role ADD MEMBER exam_staff;
ALTER ROLE db_owner ADD MEMBER admin;
GO

PRINT 'âœ… Database users created and assigned to roles';
GO

/*
==============================================================================
PART 5: CREATE SECURITY SCHEMA AND RLS FUNCTIONS
==============================================================================
*/
PRINT 'Step 5: Creating Row-Level Security...';
GO

-- Create Security schema
CREATE SCHEMA Security;
GO

-- RLS Function for ENROLLMENT table
CREATE FUNCTION Security.fn_EnrollmentSecurityPredicate(@student_id INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securitypredicate_result
WHERE 
    IS_MEMBER('db_owner') = 1  -- db_owner can see everything
    OR @student_id = (
        SELECT s.student_id 
        FROM dbo.STUDENT s
        INNER JOIN dbo.[USER] u ON s.user_id = u.user_id
        WHERE u.username = USER_NAME()
    )
    OR IS_MEMBER('lecturer_role') = 1
    OR IS_MEMBER('academic_admin_role') = 1
    OR IS_MEMBER('exam_unit_role') = 1;
GO

-- RLS Function for GRADE table
CREATE FUNCTION Security.fn_GradeSecurityPredicate(@enrollment_id INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_securitypredicate_result
WHERE 
    IS_MEMBER('db_owner') = 1  -- db_owner can see everything
    OR EXISTS (
        SELECT 1 
        FROM dbo.ENROLLMENT e
        INNER JOIN dbo.STUDENT s ON e.student_id = s.student_id
        INNER JOIN dbo.[USER] u ON s.user_id = u.user_id
        WHERE e.enrollment_id = @enrollment_id
        AND u.username = USER_NAME()
    )
    OR IS_MEMBER('lecturer_role') = 1
    OR IS_MEMBER('academic_admin_role') = 1
    OR IS_MEMBER('exam_unit_role') = 1;
GO

-- Create security policies
CREATE SECURITY POLICY EnrollmentSecurityPolicy
ADD FILTER PREDICATE Security.fn_EnrollmentSecurityPredicate(student_id)
ON dbo.ENROLLMENT
WITH (STATE = ON);
GO

CREATE SECURITY POLICY GradeSecurityPolicy
ADD FILTER PREDICATE Security.fn_GradeSecurityPredicate(enrollment_id)
ON dbo.GRADE
WITH (STATE = ON);
GO

PRINT 'âœ… Row-Level Security created and enabled';
GO

/*
==============================================================================
PART 6: CREATE STORED PROCEDURES
==============================================================================
*/
PRINT 'Step 6: Creating stored procedures...';
GO

-- Stored Procedure: Register for Course
CREATE PROCEDURE sp_RegisterCourse
    @student_id INT,
    @course_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if already enrolled
        IF EXISTS (SELECT 1 FROM ENROLLMENT 
                   WHERE student_id = @student_id 
                   AND course_id = @course_id 
                   AND status = 'Active')
        BEGIN
            RAISERROR('Already enrolled in this course', 16, 1);
            RETURN;
        END
        
        -- Insert enrollment
        INSERT INTO ENROLLMENT (student_id, course_id, enrollment_date, status)
        VALUES (@student_id, @course_id, GETDATE(), 'Active');
        
        -- Insert corresponding grade record
        DECLARE @enrollment_id INT = SCOPE_IDENTITY();
        INSERT INTO GRADE (enrollment_id, status)
        VALUES (@enrollment_id, 'Pending');
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Stored Procedure: Drop Course
CREATE PROCEDURE sp_DropCourse
    @enrollment_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        UPDATE ENROLLMENT
        SET status = 'Dropped'
        WHERE enrollment_id = @enrollment_id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Stored Procedure: Enter Grade
CREATE PROCEDURE sp_EnterGrade
    @enrollment_id INT,
    @assignment_grade DECIMAL(5,2),
    @exam_grade DECIMAL(5,2),
    @lecturer_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        DECLARE @final_grade DECIMAL(5,2);
        DECLARE @letter_grade NVARCHAR(2);
        
        -- Calculate final grade (40% assignment, 60% exam)
        SET @final_grade = (@assignment_grade * 0.4) + (@exam_grade * 0.6);
        
        -- Determine letter grade
        SET @letter_grade = CASE
            WHEN @final_grade >= 90 THEN 'A'
            WHEN @final_grade >= 80 THEN 'B'
            WHEN @final_grade >= 70 THEN 'C'
            WHEN @final_grade >= 60 THEN 'D'
            ELSE 'F'
        END;
        
        -- Update grade
        UPDATE GRADE
        SET assignment_grade = @assignment_grade,
            exam_grade = @exam_grade,
            final_grade = @final_grade,
            letter_grade = @letter_grade,
            status = 'Submitted',
            graded_by = @lecturer_id,
            graded_at = GETDATE()
        WHERE enrollment_id = @enrollment_id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Stored Procedure: Finalize Grade
CREATE PROCEDURE sp_FinalizeGrade
    @grade_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        UPDATE GRADE
        SET status = 'Finalized'
        WHERE grade_id = @grade_id
        AND status = 'Submitted';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT 'âœ… Stored procedures created';
GO

/*
==============================================================================
PART 7: CREATE AUDIT TRIGGERS
==============================================================================
*/
PRINT 'Step 7: Creating audit triggers...';
GO

-- Trigger: Audit User Changes
CREATE TRIGGER trg_AuditUserChanges
ON [USER]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @action NVARCHAR(10);
    DECLARE @user_id INT;
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @action = 'UPDATE';
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @action = 'INSERT';
    ELSE
        SET @action = 'DELETE';
    
    INSERT INTO AUDIT_LOG (user_id, action, table_name, record_id, details)
    SELECT 
        COALESCE(i.user_id, d.user_id),
        @action,
        'USER',
        COALESCE(i.user_id, d.user_id),
        'User: ' + COALESCE(i.username, d.username)
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.user_id = d.user_id;
END;
GO

-- Trigger: Audit Grade Changes
CREATE TRIGGER trg_AuditGradeChanges
ON GRADE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @action NVARCHAR(10);
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @action = 'UPDATE';
    ELSE
        SET @action = 'INSERT';
    
    INSERT INTO AUDIT_LOG (user_id, action, table_name, record_id, details)
    SELECT 
        i.graded_by,
        @action,
        'GRADE',
        i.grade_id,
        'Enrollment ID: ' + CAST(i.enrollment_id AS NVARCHAR(10)) + 
        ', Final Grade: ' + ISNULL(CAST(i.final_grade AS NVARCHAR(10)), 'NULL') +
        ', Status: ' + i.status
    FROM inserted i;
END;
GO

PRINT 'âœ… Audit triggers created';
GO

/*
==============================================================================
PART 8: VERIFICATION
==============================================================================
*/
PRINT '';
PRINT '========================================';
PRINT 'SECURITY IMPLEMENTATION SUMMARY';
PRINT '========================================';
GO

-- Count roles
SELECT COUNT(*) AS role_count FROM sys.database_principals WHERE type = 'R' AND name IN 
    ('student_role', 'lecturer_role', 'academic_admin_role', 'exam_unit_role');

-- Count users
SELECT COUNT(*) AS user_count FROM sys.database_principals WHERE type = 'S' AND name IN 
    ('alice_wong', 'bob_tan', 'charlie_lim', 'diana_ng', 'ethan_chua', 'jane_doe',
     'dr_smith', 'prof_johnson', 'dr_lee', 'academic_admin', 'exam_staff', 'admin');

-- Count security policies
SELECT COUNT(*) AS policy_count FROM sys.security_policies;

-- Count stored procedures
SELECT COUNT(*) AS procedure_count FROM sys.procedures WHERE name IN 
    ('sp_RegisterCourse', 'sp_DropCourse', 'sp_EnterGrade', 'sp_FinalizeGrade');

-- Count triggers
SELECT COUNT(*) AS trigger_count FROM sys.triggers WHERE name IN 
    ('trg_AuditUserChanges', 'trg_AuditGradeChanges');

PRINT '';
PRINT 'âœ… DATABASE SECURITY IMPLEMENTATION COMPLETE!';
PRINT '';
PRINT '=== Security Features Implemented ===';
PRINT 'âœ“ 4 Database Roles';
PRINT 'âœ“ 12 Database Users';
PRINT 'âœ“ 2 Row-Level Security Policies';
PRINT 'âœ“ 4 Stored Procedures';
PRINT 'âœ“ 2 Audit Triggers';
PRINT '';
PRINT '=== Database Login Credentials ===';
PRINT 'Students: alice_wong, bob_tan, etc. / Student123!';
PRINT 'Lecturers: dr_smith, prof_johnson, dr_lee / Lecturer123!';
PRINT 'Staff: academic_admin / Admin123!, exam_staff / ExamStaff123!, admin / SystemAdmin123!';
PRINT '';
GO