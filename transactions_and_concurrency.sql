-- 31. Design a transaction flow for enrolling a user into a course.

-- A transaction is a group of operations that must follow ACID rules:
-- A – Atomicity → All or nothing
-- C – Consistency → Data remains valid
-- I – Isolation → No interference
-- D – Durability → Changes persist

BEGIN TRY
    BEGIN TRANSACTION;

        DECLARE @user_id int =1;
        DECLARE @course_id int=37;


    --CHECK USER
    IF NOT EXISTS (SELECT 1 FROM lms.users WHERE user_id = @user_id)
    BEGIN
        THROW 50001,'User doesnt exist',1 ;
    END

    IF NOT EXISTS (SELECT 1 FROM lms.courses WHERE course_id=@course_id)
    BEGIN
        THROW 50002,'Course not found',2;
    END

    IF EXISTS (SELECT 1 FROM lms.enrollments WHERE course_id=@course_id AND user_id=@user_id)
    BEGIN
        THROW 50003,'User is already entrolled to the same course',3;
    END

    INSERT INTO lms.enrollments(enroll_id,user_id,course_id,status,enrolled_date) 
    VALUES(18201,@user_id,@course_id,'active',GETDATE());

    COMMIT TRANSACTION;
    PRINT 'Entrollment succesfull';

END TRY

BEGIN CATCH
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- 32. Explain how to handle concurrent assessment submissions safely.

/*
Concurrent assessment submissions happen when multiple users submit at the same time, 
or when the same user accidentally submits twice due to network delay or double-clicking. 
To handle this safely, the system must prevent duplicate submissions and inconsistent data.
BY
1. Use database constraints
Add a UNIQUE constraint on (user_id, assign_id) so the database itself prevents a user from submitting the same assessment more than once. 

2. Use transactions
Wrap the submission logic inside a transaction so that checks (already submitted or not) and the insert happen as a single atomic operation. 
If anything fails, the transaction is rolled back.
*/

-- 33. Describe how partial failures should be handled during assessment submission.
/*
When certain steps of an assessment submission are successful but others are not (for eg, the submission row is inserted but score validation fails), 
this is known as a partial failure. The complete submission process should be carried out inside a transaction in order to handle this safely.

To ensure that no incomplete or inconsistent data is saved, the transaction should be rolled back if any step fails,
such as due to validation errors, duplicate submissions, or system problems. 
The user should then be made fully aware of the error so they can retry if necessary and know the submission was unsuccessful.
*/

-- 34. Recommend suitable transaction isolation levels for enrollments and submissions.
/*
For enrollments, READ COMMITTED is a suitable transaction isolation level because it prevents dirty reads while allowing good concurrency
for a high-traffic operation;duplicate enrollments can be safely handled using validation logic and a unique constraint on (user_id, course_id). 
For assessment submissions,a stricter isolation level such as SERIALIZABLE is recommended, since submissions
are critical one-time actions and must prevent race conditions and duplicate entries. 
This approach balances performance for frequent operations with strong consistency for sensitive actions.*/


-- 35. Explain how phantom reads could affect analytics queries and how to prevent them.
/*
Phantom reads happen when a transaction re-executes a query and observes new or missing rows based on inserts or deletes by other transactions. 
In analytics queries, this can lead to inconsistent results such as varying counts or incorrect aggregations during the execution of a report. 
To avoid phantom reads, a higher level of isolation such as SERIALIZABLE can be employed, 
which will prevent any new rows that satisfy the query condition from being inserted during the transaction.*/

