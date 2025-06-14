# sql_mentor_dataset
![SQL Data Analytics](https://github.com/Praveens2912/sql_mentor_dataset/blob/main/Image)

## Project Overview

This project showcases my ability to analyze real-world user activity data using SQL. The dataset, user_submissions, contains records of users submitting content over time. I used PostgreSQL to write queries that reveal insights into user performance, submission patterns, and engagement.


## Objectives

- Learn how to use SQL for data analysis tasks such as aggregation, filtering, and ranking.
- Understand how to calculate and manipulate data in a real-world dataset.
- Gain hands-on experience with SQL functions like `COUNT`, `SUM`, `AVG`, `EXTRACT()`, and `DENSE_RANK()`.
- Develop skills for performance analysis using SQL by solving different types of data problems related to user performance.

## SQL Mentor User Performance Dataset

The dataset consists of information about user submissions for an online learning platform. Each submission includes:
- **User ID**
- **Question ID**
- **Points Earned**
- **Submission Timestamp**
- **Username**

This data allows you to analyze user performance in terms of correct and incorrect submissions, total points earned, and daily/weekly activity.



## Key SQL Concepts Covered

- **Aggregation**: Using `COUNT`, `SUM`, `AVG` to aggregate data.
- **Date Functions**: Using `EXTRACT()` and `TO_CHAR()` for manipulating dates.
- **Conditional Aggregation**: Using `CASE WHEN` to handle positive and negative submissions.
- **Ranking**: Using `DENSE_RANK()` to rank users based on their performance.
- **Group By**: Aggregating results by groups (e.g., by user, by day, by week).


## SQL Problems and Questions

Here are the SQL problems that you will solve as part of this project:

##  Q1:  Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
```sql
SELECT 
	username,
	COUNT(id) as total_submissions,
	SUM(points) as points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC
```

**Description:**
This query returns each distinct user's total number of submissions and total points earned. It provides a summary of user activity and performance by grouping data based on usernames.


## Q2: Calculate the daily average points for each user.
```sql
SELECT 
	 TO_CHAR(submitted_at,'DD-MM') AS  day,
     username,
	 AVG(points) AS avg_points_earned
 FROM user_submissions    
GROUP BY 1,2
ORDER BY day
```

**Description:**
This query calculates the average points earned by each user on a daily basis.It helps track individual user performance trends over time by grouping data by date and username.


## Q3: Find the top 3 users with the most correct submissions for each day.
```sql
WITH daily_submissions
AS
(
	SELECT 
		-- EXTRACT(DAY FROM submitted_at) as day,
		TO_CHAR(submitted_at, 'DD-MM') as daily,
		username,
		SUM(CASE 
			WHEN points > 0 THEN 1 ELSE 0
		END) as correct_submissions
	FROM user_submissions
	GROUP BY 1, 2
),
users_rank
as
(SELECT 
	daily,
	username,
	correct_submissions,
	DENSE_RANK() OVER(PARTITION BY daily ORDER BY correct_submissions DESC) as rank
FROM daily_submissions
)

SELECT 
	daily,
	username,
	correct_submissions
FROM users_rank
WHERE rank <= 3;
```

**Description:**
This query identifies the top 3 users with the highest number of correct submissions (points > 0) for each day.It uses window functions to rank users by daily performance and highlights the most accurate contributors per day.

## Q4. Find the top 2 users with the highest number of submissions on each day
```sql
WITH daily_submissions	
AS
(SELECT 
	  DATE(submitted_at) AS daily,
      username,
      COUNT(*) AS total_submissions
FROM user_submissions
GROUP BY 1,2 
),
rank_users
	AS
(
	SELECT
	      daily,
	      username,
	      total_submissions,
	DENSE_RANK() OVER(PARTITION BY  daily ORDER BY  total_submissions DESC) AS rank
FROM daily_submissions	
)
SELECT 
      daily, 
      username,
      total_submissions
FROM rank_users
WHERE rank <=2

```

**Description:**
This query finds the top 2 users with the highest number of submissions on each day.It uses a window function to rank users by daily submission count and filters the top performers.

## Q5 Find the user with the lowest total points earned on each day
```sql
WITH daily_submittions
	AS
(SELECT 
      DATE(submitted_at) AS daily,
      username,
      SUM(points) As points_earned
FROM user_submissions
GROUP BY 1,2
),
user_rank
	AS
(
	SELECT
	      daily,
	      username,
	      points_earned,
	      RANK() OVER(PARTITION BY daily ORDER BY points_earned )
FROM  daily_submittions
)
SELECT 
	  daily,
      username,
      points_earned
FROM user_rank
WHERE rank = 1
```
## Description:
This query identifies the user with the lowest total points earned on each day.It ranks users daily by points in ascending order to highlight underperformers per day.

## Q6.Show each user’s best day — the day they earned the most points
```sql
WITH daily_submittions
	AS
(
SELECT 
      date(submitted_at) AS daily,
      username,
      SUM(points) AS total_points_earned
FROM  user_submissions
GROUP BY 1,2
 ),       
best_day
AS
(
	SELECT 
	     daily,
	     username,
	     total_points_earned,
	     RANK()OVER(PARTITION BY username ORDER BY total_points_earned DESC ) AS rank
FROM daily_submittions
)
SELECT 
      daily,
	  username,
      total_points_earned
FROM best_day
WHERE rank = 1 
```
**Description:**
This query finds each user's best day based on the highest total points earned. It uses window functions to rank daily performance per user and selects the top-ranked day.

## Q7. Which 3 days had the most total submissions overall?
```sql
SELECT 
      DATE(submitted_at) AS date,
      COUNT(*) AS total_submissions
FROM user_submissions
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3
```

**Description:**
This query identifies the top 3 days with the highest total number of submissions across all users.It groups submissions by date, counts them, and orders the results to highlight peak activity days.

## Q8 Find the top 5 users with the highest number of incorrect submissions.
```sql
SELECT 
      username,
      SUM (CASE 
          WHEN points < 0 THEN 1 ELSE 0
           END) AS incorrect_submissions,
      SUM (CASE 
          WHEN points > 0 THEN 1 ELSE 0
           END) AS correct_submissions,
      SUM (CASE 
          WHEN points < 0 THEN points ELSE 0
           END) AS incorrect_submissions_points,
      SUM (CASE 
          WHEN points > 0 THEN points ELSE 0
           END) AS correct_submissions_points,
      SUM(points) AS total_submissions
FROM user_submissions
GROUP BY 1
ORDER BY incorrect_submissions DESC
```

**Description:**
This query identifies the top 5 users with the most incorrect submissions (where points < 0).It also compares their correct vs. incorrect submission counts and the total points earned from each.

## Q.9 Find the top 10 performers for each week.
```sql
SELECT *
	FROM 
(
SELECT 
      EXTRACT (week from submitted_at) AS weeks,
      username,
      SUM(points) AS total_points_earned,
      DENSE_RANK()OVER(PARTITION BY EXTRACT(week FROM submitted_at) ORDER BY SUM(points) DESC) AS rank
FROM user_submissions
GROUP BY 1,2
)AS weekly_ranked
WHERE rank <=10;
```
**Description:**
This query finds the top 10 performers for each week based on total points earned. It uses DENSE_RANK() to rank users within each week and filters out only the highest scorers.

## 10.Find the top 10 performers for each week.

```sql
SELECT *
FROM (
  SELECT 
      EXTRACT(week FROM submitted_at) AS weeks,
      username,
      SUM(points) AS total_points_earned,
      DENSE_RANK() OVER (PARTITION BY EXTRACT(week FROM submitted_at) ORDER BY SUM(points) DESC) AS rank
  FROM user_submissions
  GROUP BY 1, 2
) AS weekly_ranked
WHERE rank <= 10;
```

**Description:** 
This query identifies the top 10 users each week based on their total points earned.
It uses DENSE_RANK() to rank users within each week and highlights consistent top performers.

## Conclusion

Through this project, I explored user submission behavior using structured SQL queries on a real-world dataset. I applied various analytical techniques such as aggregations, filtering, date functions, and window functions to derive insights like top performers, most active users, daily trends, and quality of submissions.

