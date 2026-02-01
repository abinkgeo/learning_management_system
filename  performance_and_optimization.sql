-- 21. Suggest appropriate indexes for improving performance of:
-- Course dashboards
-- User activity analytics

CREATE INDEX idx_enrollments_course
ON lms.enrollments (course_id);

CREATE INDEX idx_enrollments_user
ON lms.enrollments (user_id);

CREATE INDEX idx_lessons_course
ON lms.lessons (course_id);

CREATE INDEX idx_assessments_lesson
ON lms.assessments (lesson_id);
 
CREATE INDEX idx_submission_assign
ON lms.assessment_submission (assign_id);

CREATE INDEX idx_user_activity_user_time
ON lms.user_activity (user_id, activity_date);


-- 22. Identify potential performance bottlenecks in queries involving user activity.

-- user_activity is a high-volume table that grows rapidly, which can cause performance issues. 
-- Common bottlenecks include full table scans due to missing indexes, expensive GROUP BY operations on large datasets, 
-- and slow joins with other tables when foreign key columns are not indexed. 
-- Date-based filtering without proper indexing and the use of window functions or DISTINCT can also increase CPU and memory usage. 
-- As data grows, it impacts query performance.


-- 23.Explain how you would optimize queries when the user activity table grows to millions of rows.

-- When user_activity becomes very large, we need to add proper indexes on commonly used columns like user_id, lesson_id, and activity_date to avoid full table scans. 
-- and also use date-based partitioning so queries only scan relevant data. 
-- For frequent analytics,and avoid unnecessary joins and window functions on raw data instead use views

-- 24. Describe scenarios where materialized views would be useful for this schema.

-- Materialized views(INDEX VIEWS) would be useful in this LMS schema when the same analytical queries are run frequently on large tables like user_activity. 
-- For example, dashboards showing daily active users, course-wise activity counts, or user progress summaries can be expensive to calculate repeatedly. 
-- By using materialized views, these results can be precomputed and stored, allowing reports to load faster without scanning millions of activity records each time. 


-- 25. Explain how partitioning could be applied to user activity.

-- Partitioning can be applied to the user_activity table by splitting the data based on time, usually using the activity_date column. 
-- Since user_activity grows continuously, partitioning it by day, month, or year allows SQL Server to store data in separate partitions instead of one large table.
-- When queries filter by date, SQL Server scans only the relevant partitions instead of the entire table, which improves performance.
-- Partitioning also makes it easier to manage old data, such as archiving or deleting historical activity.
