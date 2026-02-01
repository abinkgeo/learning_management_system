-- 26. Propose constraints to ensure a user cannot submit the same assessment more than once

-- To ensure a user cannot submit the same assessment more than once, we can use a UNIQUE constraint on the combination of user_id 
-- and assign_id in the assessment_submission table.

-- ALTER TABLE lms.assessment_submission
-- ADD CONSTRAINT UNIQUE (user_id, assign_id);


-- 27. Ensure that assessment scores do not exceed the defined maximum score.

CREATE TRIGGER trg_check_score
ON lms.assessment_submission
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN lms.assessments a
            ON i.assign_id = a.assign_id
        WHERE i.score > a.max_score
    )
    BEGIN
        RAISERROR ('Score cannot be greater than max score',16,1);
        ROLLBACK;
    END
END;

GO

-- UPDATE  lms.assessment_submission set score=120 where submission_id=2;

-- 28. Prevent users from enrolling in courses that have no lessons.

CREATE TRIGGER trg_check_course_lessons
ON lms.enrollments
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN lms.lessons l
            ON i.course_id = l.course_id
        WHERE l.lesson_id IS NULL
    )
    BEGIN
        RAISERROR ('Cannot enroll in a course with no lessons.', 16, 1);
        ROLLBACK;
    END
END;

-- checking the trigger
-- INSERT INTO lms.courses (course_id, course_name, course_duration)
-- VALUES (202, 'Empty Course', 30);
-- INSERT INTO lms.enrollments (enroll_id, user_id, course_id, enrolled_date, status)
-- VALUES (18199, 3001, 202, GETDATE(), 'active');

-- 29. Ensure that only instructors can create courses.

---adding role created to users---
ALTER TABLE lms.users
ADD role VARCHAR(20);

--adding created_by column to courses --
ALTER TABLE lms.courses
ADD created_by INT;

--adding foreign key--
ALTER TABLE lms.courses
ADD CONSTRAINT fk_course_creator
FOREIGN KEY (created_by)
REFERENCES lms.users(user_id);
GO
--trigger to check instructor create course
CREATE TRIGGER trg_instructor_create_course
ON lms.courses
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN lms.users u
            ON i.created_by = u.user_id
        WHERE u.role <> 'instructor'
    )
    BEGIN
        RAISERROR ('Only instructors can create courses.', 16, 1);
        ROLLBACK;
    END
END;

-- checking the trigger 
-- INSERT INTO lms.users (user_id, user_name, user_email, user_password, role)
-- VALUES (10001, 'Alice Walden', 'alice@gmail.com', 'pass123', 'instructor');

-- INSERT INTO lms.users (user_id, user_name, user_email, user_password, role)
-- VALUES (10002, 'Bob Gates', 'bob@gmail.com', 'pass1232', 'student');

-- INSERT INTO lms.courses (course_id, course_name, course_duration, created_by)
-- VALUES (501, 'Advanced SQL Optimization', 60, 10001);

-- INSERT INTO lms.courses (course_id, course_name, course_duration, created_by)
-- VALUES (502, 'Hacking SQL Basics', 40, 10002);




-- 30. Describe a safe strategy for deleting courses while preserving historical data.

-- A safe strategy is to avoid hard deletes and instead use a soft delete approach. 
-- This means adding a status flag (such as is_active ) to the courses table and marking the course as inactive rather than removing it from the database.
--  This preserves historical data like enrollments, assessments, and user activity while preventing new enrollments.

