-- 11. For each course, calculate: Total number of enrolled users Total number of lessons Average lesson duration
/* 
WHY LEFT JOIN: 
- LEFT JOIN with enrollments ensures courses with zero enrollments are  included.
- LEFT JOIN with lessons ensures courses with zero lessons are also included.

ASSUMPTIONS:
- lesson_duration represents total duration of the course.
- Average lesson duration = total course duration / number of lessons.
- NULLIF is used to avoid division by zero.
*/
SELECT c.course_id,c.course_name,
COUNT(DISTINCT e.user_id) AS total_enrolled_users,
COUNT(DISTINCT l.lesson_id) AS total_lessons,
c.course_duration *1.0 / NULLIF(COUNT(DISTINCT l.lesson_id),0) as avg_lesson_duration
FROM lms.courses c LEFT JOIN lms.enrollments e
ON c.course_id = e.course_id
LEFT JOIN lms.lessons l
ON c.course_id = l.course_id
GROUP BY c.course_id,c.course_name,course_duration;


-- 12. Identify the top three most active users based on total activity count.
/* 
WHY LEFT JOIN:
- LEFT JOIN ensures users with zero activity are still considered.

WHY TOP:
- TOP 3 is used to fetch only the three users with the highest activity count.

ASSUMPTIONS:
- Each row in user_activity represents one activity performed by a user.
- Higher activity count means more active user.
*/
SELECT TOP 3 u.user_id,u.user_name , COUNT(ua.activity_id) as total_activity_count
FROM lms.users u   LEFT JOIN lms.user_activity ua 
ON u.user_id = ua.user_id
GROUP BY u.user_id,u.user_name;

-- 13. Calculate course completion percentage per user based on lesson activity.
/* 
WHY INNER JOIN:
- Only lessons that have user activity are relevant for completion calculation.

ASSUMPTIONS:
- activity_status = 'completed' indicates lesson completion.
- Completion percentage = completed lessons / total lessons in course * 100.
*/
SELECT ua.user_id, l.course_id,
COUNT(DISTINCT CASE WHEN ua.activity_status = 'completed' THEN ua.lesson_id END) * 100.0
/ COUNT(DISTINCT l.lesson_id) AS completion_percentage
FROM lms.user_activity ua
JOIN lms.lessons l
    ON ua.lesson_id = l.lesson_id
GROUP BY ua.user_id,l.course_id;

-- .14 Find users whose average assessment score is higher than the course average.
/* 
WHY CTE:
- First CTE calculates average score per user per course.
- Second CTE calculates average score per course.
- Final query compares both values cleanly and readably.

ASSUMPTIONS:
- Each assessment belongs to a lesson.
- Each lesson belongs to a course.
- Average score represents performance level.
*/
WITH user_avg AS (
    SELECT s.user_id,l.course_id,AVG(s.score) AS user_avg_score
    FROM lms.assessment_submission s
    JOIN lms.assessments a
    ON s.assign_id = a.assign_id
    JOIN lms.lessons l
    ON a.lesson_id = l.lesson_id
    GROUP BY s.user_id,l.course_id
),
course_avg AS (
    SELECT l.course_id,AVG(s.score) AS course_avg_score
    FROM lms.assessment_submission s
    JOIN lms.assessments a
    ON s.assign_id = a.assign_id
    JOIN lms.lessons l
    ON a.lesson_id = l.lesson_id
    GROUP BY
    l.course_id
)
SELECT ua.user_id,ua.course_id,ua.user_avg_score
FROM user_avg ua
JOIN course_avg ca
ON ua.course_id = ca.course_id
WHERE ua.user_avg_score > ca.course_avg_score;

-- 15. List courses where lessons are frequently accessed but assessments are never attempted.
/* 
WHY JOIN:
- JOIN with lessons ensures courses with lesson access are considered.
- LEFT JOIN with assessments and submissions , identifies  missing assessment.

ASSUMPTIONS:
- If assessment submission is NULL, no assessment was attempted.
*/
SELECT c.course_id,c.course_name
FROM lms.courses c JOIN lms.lessons l 
ON c.course_id=l.lesson_id
LEFT JOIN lms.assessments a
ON l.lesson_id=a.lesson_id
LEFT JOIN lms.assessment_submission s
ON a.assign_id=s.assign_id
WHERE s.assign_id IS NULL;

-- 16. Rank users within each course based on their total assessment score.
/* 
WHY WINDOW FUNCTION:
- RANK() assigns ranking without collapsing rows.
- PARTITION BY course_id ensures ranking is per course.

ASSUMPTIONS:
- Total score = sum of all assessment scores for a user in a course.
*/
SELECT user_id,course_id,total_score,
    RANK() OVER (
        PARTITION BY course_id
        ORDER BY total_score DESC
    ) AS course_rank
FROM (
    SELECT s.user_id, l.course_id,SUM(s.score) AS total_score
    FROM lms.assessment_submission s
    JOIN lms.assessments a
        ON s.assign_id = a.assign_id
    JOIN lms.lessons l
        ON a.lesson_id = l.lesson_id
    GROUP BY
        s.user_id,
        l.course_id
)t

--17. Identify the first lesson accessed by each user for every course.
/* 
WHY ROW_NUMBER:
- ROW_NUMBER helps identify the first activity based on date.

ASSUMPTIONS:
- activity_date stores when a lesson was accessed.
- Earliest activity date means first lesson accessed.
*/
SELECT user_id,course_id,lesson_id, activity_date
FROM(
SELECT ua.user_id,l.lesson_id,l.course_id,ua.activity_date,
ROW_NUMBER() OVER(PARTITION BY ua.user_id,l.course_id ORDER BY ua.activity_date) as rn
FROM lms.user_activity ua   JOIN lms.lessons l
ON ua.lesson_id = l.lesson_id)t

where rn=1;

-- 18. Find users with activity recorded on at least five consecutive days.
/* 
WHY SUBQUERY:
- ROW_NUMBER with date difference technique identifies consecutive days.

ASSUMPTIONS:
- activity_datetime stores timestamp of user activity.
*/
SELECT user_id
FROM (
    SELECT DISTINCT user_id, CAST(activity_datetime AS DATE) AS activity_date,
    ROW_NUMBER() OVER ( PARTITION BY user_id ORDER BY CAST(activity_datetime AS DATE)
        ) AS rn
    FROM lms.user_activity
) t                                 
GROUP BY
    user_id,
    DATEADD(DAY, -rn, activity_date)
HAVING COUNT(*) >= 5;

-- 19 Retrieve users who enrolled in a course but never submitted any assessment.
/* 
WHY LEFT JOIN:
- LEFT JOIN allows detection of users with no assessment submissions.

ASSUMPTIONS:
- submission_id identifies assessment.
- COUNT = 0 means no assessments submitted.
*/
SELECT DISTINCT u.user_id, u.user_name
FROM lms.users u
JOIN lms.enrollments e
ON u.user_id = e.user_id
LEFT JOIN lms.assessment_submission s
ON u.user_id = s.user_id
GROUP BY u.user_id, u.user_name
HAVING COUNT(s.submission_id) = 0;


-- 20. List courses where every enrolled user has submitted at least one assessment.
/*
WHY EXISTS / NOT EXISTS:
- EXISTS checks if the course has enrollments.
- NOT EXISTS ensures there is no enrolled user without an assessment submission.

ASSUMPTIONS:
- Every enrolled user must have at least one assessment submission for the course.
*/
SELECT c.course_id, c.course_name
FROM lms.courses c
WHERE EXISTS (

    SELECT 1
    FROM lms.enrollments e
    WHERE e.course_id = c.course_id
)
AND NOT EXISTS (
    SELECT 1
    FROM lms.enrollments e
    WHERE e.course_id = c.course_id
      AND NOT EXISTS (
          SELECT 1
          FROM lms.assessment_submission s
          JOIN lms.assessments a
          ON s.assign_id = a.assign_id
          JOIN lms.lessons l
          ON a.lesson_id = l.lesson_id
          WHERE s.user_id = e.user_id
          AND l.course_id = c.course_id
      )
);
