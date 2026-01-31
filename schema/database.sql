-- CREATE DATABASE lms;


-- USE lms;

-- CREATE SCHEMA lms;


CREATE TABLE lms.users (
    user_id INT  PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    user_email VARCHAR(150) NOT NULL UNIQUE,
    user_password VARCHAR(255) NOT NULL
);

CREATE TABLE lms.users_stage (
    user_id INT,
    user_name VARCHAR(100),
    user_email VARCHAR(150),
    user_password VARCHAR(255)
);

BULK INSERT lms.users_stage
FROM '/var/opt/mssql/data/lms_csv/users.csv'
WITH (
    FIRSTROW = 2,              
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

WITH deduped_stage AS (
    SELECT
        user_id,
        user_name,
        user_email,
        user_password,
        ROW_NUMBER() OVER (
            PARTITION BY user_email
            ORDER BY user_id
        ) AS rn
    FROM lms.users_stage
)
INSERT INTO lms.users (user_id, user_name, user_email, user_password)
SELECT
    d.user_id,
    d.user_name,
    d.user_email,
    d.user_password
FROM deduped_stage d
WHERE d.rn = 1
  AND NOT EXISTS (
      SELECT 1
      FROM lms.users u
      WHERE u.user_email = d.user_email
         OR u.user_id = d.user_id
  );
------------------------------------------------

CREATE TABLE lms.courses (
    course_id INT  PRIMARY KEY,
    course_name VARCHAR(150) NOT NULL,
    course_duration INT NOT NULL
);

CREATE TABLE lms.courses_stage (
    course_id INT,
    course_name VARCHAR(150),
    course_duration INT
);

BULK INSERT lms.courses_stage
FROM '/var/opt/mssql/data/lms_csv/courses.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY course_id
               ORDER BY course_id
           ) AS rn
    FROM lms.courses_stage
)
DELETE FROM cte WHERE rn > 1;


INSERT INTO lms.courses (course_id, course_name, course_duration)
SELECT
    s.course_id,
    s.course_name,
    s.course_duration
FROM lms.courses_stage s
WHERE NOT EXISTS (
    SELECT 1
    FROM lms.courses c
    WHERE c.course_id = s.course_id
);

UPDATE lms.courses
SET course_name = CASE course_id
    WHEN 101 THEN 'Structured Query Language (SQL)'
    WHEN 102 THEN 'Java Programming'
    WHEN 103 THEN 'Python Programming'
    WHEN 104 THEN 'C Programming'
    WHEN 105 THEN 'C++ Programming'
    WHEN 106 THEN '.NET Development'
    WHEN 107 THEN 'Data Structures and Algorithms'
    WHEN 108 THEN 'Operating Systems'
    WHEN 109 THEN 'Computer Networks'
    WHEN 110 THEN 'Database Management Systems'
    WHEN 111 THEN 'Web Development'
    WHEN 112 THEN 'Software Engineering'
    WHEN 113 THEN 'Machine Learning'
    WHEN 114 THEN 'Cloud Computing'
    WHEN 115 THEN 'Cyber Security'
    ELSE course_name
END;

------------------------------------------------------------------


CREATE TABLE lms.lessons(
    lesson_id INT  PRIMARY KEY,
    lesson_name VARCHAR(150) NOT NULL,
    course_id INT NOT NULL,
    CONSTRAINT fk_lessons_course FOREIGN KEY (course_id)
        REFERENCES lms.courses(course_id)
);

CREATE TABLE lms.lessons_stage (
    lesson_id INT,
    lesson_name VARCHAR(150),
    course_id INT
);

BULK INSERT lms.lessons_stage
FROM '/var/opt/mssql/data/lms_csv/lessons.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY lesson_id
               ORDER BY lesson_id
           ) AS rn
    FROM lms.lessons_stage
)
DELETE FROM cte WHERE rn > 1;

DELETE s
FROM lms.lessons_stage s
LEFT JOIN lms.courses c
       ON c.course_id = s.course_id
WHERE c.course_id IS NULL;

INSERT INTO lms.lessons (lesson_id, lesson_name, course_id)
SELECT
    s.lesson_id,
    s.lesson_name,
    s.course_id
FROM lms.lessons_stage s
WHERE NOT EXISTS (
    SELECT 1
    FROM lms.lessons l
    WHERE l.lesson_id = s.lesson_id
);

UPDATE lms.lessons
SET lesson_name = CASE
    
    WHEN lesson_id = 201 THEN 'Introduction to Databases'
    WHEN lesson_id = 202 THEN 'DDL and DML Commands'
    WHEN lesson_id = 203 THEN 'Joins and Subqueries'

  
    WHEN lesson_id = 204 THEN 'Java Basics and JVM'
    WHEN lesson_id = 205 THEN 'Object Oriented Programming'
    WHEN lesson_id = 206 THEN 'Exception Handling and Collections'


    WHEN lesson_id = 207 THEN 'Python Syntax and Variables'
    WHEN lesson_id = 208 THEN 'Lists, Tuples, Sets, Dictionaries'
    WHEN lesson_id = 209 THEN 'Modules and File Handling'

    
    WHEN lesson_id = 210 THEN 'C Syntax and Control Flow'
    WHEN lesson_id = 211 THEN 'Pointers and Memory Management'
    WHEN lesson_id = 212 THEN 'Structures and File I/O'

  
    WHEN lesson_id = 213 THEN 'C++ Basics and OOP'
    WHEN lesson_id = 214 THEN 'Inheritance and Polymorphism'
    WHEN lesson_id = 215 THEN 'STL and Templates'


    WHEN lesson_id = 216 THEN '.NET Framework and CLR'
    WHEN lesson_id = 217 THEN 'ASP.NET MVC Architecture'
    WHEN lesson_id = 218 THEN 'Entity Framework Core'

    ELSE lesson_name
END;


--------------------------------------------------------------------------------------------------------------------

CREATE TABLE lms.enrollments (
    enroll_id INT  PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL ,
    CONSTRAINT fk_enrollments_user FOREIGN KEY (user_id)
        REFERENCES lms.users(user_id),
    CONSTRAINT fk_enrollments_course FOREIGN KEY (course_id)
        REFERENCES lms.courses(course_id)
);

CREATE TABLE lms.enrollments_stage (
    enroll_id INT,
    user_id INT,
    course_id INT,
    enrolled_date DATE,
    status VARCHAR(20)
);

BULK INSERT lms.enrollments_stage
FROM '/var/opt/mssql/data/lms_csv/enrollments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY enroll_id
               ORDER BY enroll_id
           ) AS rn
    FROM lms.enrollments_stage
)
DELETE FROM cte WHERE rn > 1;

DELETE s
FROM lms.enrollments_stage s
LEFT JOIN lms.users u
       ON u.user_id = s.user_id
LEFT JOIN lms.courses c
       ON c.course_id = s.course_id
WHERE u.user_id IS NULL
   OR c.course_id IS NULL;

INSERT INTO lms.enrollments
    (enroll_id, user_id, course_id, enrolled_date, status)
SELECT
    s.enroll_id,
    s.user_id,
    s.course_id,
    s.enrolled_date,
    s.status
FROM lms.enrollments_stage s
WHERE NOT EXISTS (
    SELECT 1
    FROM lms.enrollments e
    WHERE e.enroll_id = s.enroll_id
);


-------------------------------------------------------------------------------------


CREATE TABLE lms.assessments (
    assign_id INT  PRIMARY KEY,
    assign_name VARCHAR(150) NOT NULL,
    lesson_id INT NOT NULL,
    max_score INT NOT NULL ,
    CONSTRAINT fk_assessments_lesson FOREIGN KEY (lesson_id)
        REFERENCES lms.lessons(lesson_id),
);

CREATE TABLE lms.assessments_stage (
    assign_id INT,
    assign_name VARCHAR(150),
    lesson_id INT,
    max_score INT
);

BULK INSERT lms.assessments_stage
FROM '/var/opt/mssql/data/lms_csv/assessments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY assign_id
               ORDER BY assign_id
           ) AS rn
    FROM lms.assessments_stage
)
DELETE FROM cte WHERE rn > 1;

DELETE s
FROM lms.assessments_stage s
LEFT JOIN lms.lessons l
       ON l.lesson_id = s.lesson_id
WHERE l.lesson_id IS NULL;

INSERT INTO lms.assessments
    (assign_id, assign_name, lesson_id, max_score)
SELECT
    s.assign_id,
    s.assign_name,
    s.lesson_id,
    s.max_score
FROM lms.assessments_stage s
WHERE NOT EXISTS (
    SELECT 1
    FROM lms.assessments a
    WHERE a.assign_id = s.assign_id
);

UPDATE lms.assessments
SET assign_name = CONCAT('Lesson ', lesson_id, ' Assignment');


--------------------------------------------------------------------------

CREATE TABLE lms.assessment_submission (
    submission_id INT  PRIMARY KEY,
    assign_id INT NOT NULL,
    user_id INT NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    submitted_date DATETIME NOT NULL,
    assign_status VARCHAR(20) ,
    CONSTRAINT fk_submission_assessment FOREIGN KEY (assign_id)
        REFERENCES lms.assessments(assign_id),
    CONSTRAINT fk_submission_user FOREIGN KEY (user_id)
        REFERENCES lms.users(user_id)
);


CREATE TABLE lms.assessment_submission_stage (
    submission_id INT,
    assign_id INT,
    user_id INT,
    score DECIMAL(5,2),
    submitted_date DATETIME,
    assign_status VARCHAR(20)
);

BULK INSERT lms.assessment_submission_stage
FROM '/var/opt/mssql/data/lms_csv/assessment_submission.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY submission_id
               ORDER BY submission_id
           ) AS rn
    FROM lms.assessment_submission_stage
)
DELETE FROM cte WHERE rn > 1;

DELETE s
FROM lms.assessment_submission_stage s
LEFT JOIN lms.assessments a
       ON a.assign_id = s.assign_id
LEFT JOIN lms.users u
       ON u.user_id = s.user_id
WHERE a.assign_id IS NULL
   OR u.user_id IS NULL;

INSERT INTO lms.assessment_submission
    (submission_id, assign_id, user_id, score, submitted_date, assign_status)
SELECT
    s.submission_id,
    s.assign_id,
    s.user_id,
    s.score,
    s.submitted_date,
    s.assign_status
FROM lms.assessment_submission_stage s
WHERE NOT EXISTS (
    SELECT 1
    FROM lms.assessment_submission m
    WHERE m.submission_id = s.submission_id
);

-------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE lms.user_activity (
    activity_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    activity_status VARCHAR(20) NOT NULL DEFAULT 'notstarted',
    lesson_id INT NOT NULL,
    activity_datetime DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_UserActivity_User FOREIGN KEY (user_id)
        REFERENCES lms.users(user_id),
    CONSTRAINT FK_UserActivity_Lesson FOREIGN KEY (lesson_id)
        REFERENCES lms.lessons(lesson_id),
    CONSTRAINT CK_ActivityStatus
        CHECK (activity_status IN ('notstarted','started','completed'))
);

CREATE TABLE lms.user_activity_stage (
    activity_id INT,
    user_id INT,
    activity_status VARCHAR(20),
    lesson_id INT,
    activity_datetime DATETIME
);

BULK INSERT lms.user_activity_stage
FROM '/var/opt/mssql/data/lms_csv/user_activity.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY activity_id
               ORDER BY activity_id
           ) AS rn
    FROM lms.user_activity_stage
)
DELETE FROM cte WHERE rn > 1;

DELETE s
FROM lms.user_activity_stage s
LEFT JOIN lms.users u
       ON u.user_id = s.user_id
LEFT JOIN lms.lessons l
       ON l.lesson_id = s.lesson_id
WHERE u.user_id IS NULL
   OR l.lesson_id IS NULL;

INSERT INTO lms.user_activity(activity_id, user_id, activity_status, lesson_id, activity_datetime)
SELECT
    s.activity_id,
    s.user_id,
    s.activity_status,
    s.lesson_id,
    s.activity_datetime
FROM lms.user_activity_stage s
WHERE NOT EXISTS (
    SELECT 1
    FROM lms.user_activity a
    WHERE a.activity_id = s.activity_id
);











