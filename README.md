#  Learning Management System (LMS) – Database Design

## Description
This project represents the database design of a **Learning Management System (LMS)** built using **Microsoft SQL Server (MSSQL)**.  
The database stores information about users, courses, lessons, enrollments, assessments, submissions, and user activity.

The design follows a **normalized relational structure** and supports course tracking, assessment evaluation, and activity monitoring.

---

##  Tables

### 1️ Users
Stores user (student) details.

users

user_id (PK)

user_name

user_email

user_password


---

### 2️ Courses
Stores course information.

courses

course_id (PK)

course_name

course_duration


---

### 3️ Lessons
Each course consists of multiple lessons.

lessons

lesson_id (PK)

lesson_name

course_id (FK → courses.course_id)


---

### 4️ Enrollments
Links users and courses (many-to-many relationship).

enrollments

enroll_id (PK)

user_id (FK → users.user_id)

course_id (FK → courses.course_id)

enrolled_date

status


---

### 5️ Assessments
Each lesson can have one or more assessments.

assessments

assign_id (PK)

assign_name

lesson_id (FK → lessons.lesson_id)

max_score


---

### 6️ Assessment Submissions
Stores scores submitted by users for assessments.

assessment_submission

submission_id (PK)

assign_id (FK → assessments.assign_id)

user_id (FK → users.user_id)

score

submitted_date

assign_status


---

### 7️ User Activity
Tracks lesson activity performed by users.

user_activity

activity_id (PK)

user_id (FK → users.user_id)

lesson_id (FK → lessons.lesson_id)

activity_status

activity_datetime


---

##  Table Relationships

- **Users ↔ Courses**  
  Many-to-many relationship through **Enrollments**

- **Courses → Lessons**  
  One course can have many lessons

- **Lessons → Assessments**  
  One lesson can have many assessments

- **Assessments → Assessment Submissions**  
  One assessment can have many submissions

- **Users → Assessment Submissions**  
  One user can submit many assessments

- **Users → User Activity**  
  One user can have many activity records

- **Lessons → User Activity**  
  One lesson can be accessed by many users

---

## Summary
The LMS database is designed to:
- Track user enrollments in courses
- Organize courses into lessons
- Manage assessments and submissions
- Monitor user activity and learning progress

This structure supports analytics such as course completion, user performance, and activity tracking.

---