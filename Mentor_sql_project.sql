-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)

SELECT 
	username,
	COUNT(id) as total_submissions,
	SUM(points) as points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC



-- -- Q.2 Calculate the daily average points for each user.


SELECT 
     --EXTRACT (year from submitted_at) AS day,
	 TO_CHAR(submitted_at,'DD-MM') AS  day,
     username,
	 AVG(points) AS avg_points_earned
 FROM user_submissions    
GROUP BY 1,2
ORDER BY day



-- Q.3 Find the top 3 users with the most correct submissions for each day.

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





--Q4. Find the top 2 users with the highest number of submissions on each day
SELECT * FROM user_submissions

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


--Q5. Find the user with the lowest total points earned on each day
SELECT * FROM user_submissions

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

-- Q6.Show each user’s best day — the day they earned the most points
SELECT * FROM user_submissions

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

--Q7. Which 3 days had the most total submissions overall?
SELECT * FROM user_submissions
	
SELECT 
      DATE(submitted_at) AS date,
      COUNT(*) AS total_submissions
FROM user_submissions
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3

-- Q5. Find users whose best day (by points) had more than 5 correct submissions
SELECT * FROM user_submissions
	
WITH daily_submissions
	AS
(
SELECT 
      DATE(submitted_at) AS daily,
      Username,
      SUM(CASE
	      WHEN points > 0 THEN 1 ELSE 0
      END)  AS correct_submissions
FROM user_submissions
GROUP BY 1,2
),
user_rank
	AS
(
SELECT 
	  daily,
	  username,
	  correct_submissions,
	  RANK()OVER(PARTITION BY daily ORDER BY correct_submissions DESC) AS rank
FROM daily_submissions
)
SELECT
      daily,
      username,
      correct_submissions
FROM user_rank
WHERE  rank <= 3 AND correct_submissions > 5

---- Q.8 Find the top 5 users with the highest number of incorrect submissions.

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

--- Q.9 Find the top 10 performers for each week.
SELECT * FROM user_submissions

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


--10.Find the top 10 performers for each week.

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
