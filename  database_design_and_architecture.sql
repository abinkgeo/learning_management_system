-- 36. Propose schema changes to support course completion certificates.

/*
To support course completion certificates, I would create a new table named course_certificates, 
which would hold the user information, course information, completion date, and certificate information. 
This would enable the creation of one certificate per user per course,  preserves historical records, 
and keeps certificate logic independent of enrollments and courses.
Foreign keys and unique constraints would be used to maintain data integrity and avoid duplicate certificates.
*/

-- 37. Describe how you would track video progress efficiently at scale.

-- 38. Discuss normalization versus denormalization trade-offs for user activity data.
/*
Normalization ensures data consistency and avoids redundancy by storing user activity references separately from users, lessons, and courses. 
However, highly normalized user activity data can lead to complex joins and slower performance for analytics queries on large datasets.
Denormalization improves query performance by storing frequently accessed information together, reducing joins and speeding up reporting, 
but at the cost of increased storage and potential data inconsistency.
In practice, a balanced approach is used—normalized tables for transactional integrity and denormalized or aggregated structures for analytics and reporting.
*/

-- 39. Design a reporting-friendly schema for analytics dashboards.
/*
A reporting-friendly schema is a database design that is optimized for analytics and dashboards, not for day-to-day transactions.
 A Star Schema organizes data into a central fact table linked to multiple dimension tables, forming a layout that visually resembles a star. 
This structure makes analytical queries fast, simple, and efficient making it one of the most commonly used data modeling techniques in data warehousing.
Fact tables store measurable events such as user activity and assessment results, while dimension tables store descriptive information like users, courses, and dates. 
This structure reduces complex joins, improves query performance, and supports fast aggregations for dashboards. 
Dashboards need facts for numbers and dimensions for context.
Dimension Tables (small, stable)
dim_user
user_id
user_name
role
country

dim_course
course_id
course_name
category
difficulty_level

dim_date
date_id
date
day
month
year

Fact Tables

fact_user_activity
user_id
course_id
lesson_id
date_id
activity_count
time_spent

fact_assessment_results
user_id
course_id
assessment_id
date_id
score
passed_flag
*/

-- 40. Explain how this schema should evolve to support millions of users.
/*
To support millions of users, the schema should evolve by partitioning large tables such as user activity and submissions, 
separating transactional and analytical schemas, and introducing summary tables or materialized views for frequently used metrics. 
Selective denormalization can be applied to improve read performance, while strong indexing and constraints ensure data integrity 
under high concurrency. Archiving historical data further helps maintain performance as the system scales.*/