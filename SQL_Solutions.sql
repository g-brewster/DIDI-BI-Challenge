-- 1. Write the SQL queries necessary to generate a list of the five restaurants that have the highest average number of visitors on holidays. The result table should also contain that average per restaurant.

-- Groups by id only due to needing the TOTAL AVG of visitors by restaurant_id 

SELECT
	vis.id,
	AVG(vis.reserve_visitors)*1.0 AS avg_of_visitors  -- Multiplying by 1.0 se get a decimal
FROM restaurants_visitors vis
	LEFT JOIN date_info dt 
		ON vis.DATE(visit_datetime) = dt.calendar_date -- Joining on DATE(visit_datetime) due to the existance of NULL values in visit_date
WHERE 
	dt.holiday_flg = 1
GROUP BY 
	vis.id
ORDER BY 
	avg_of_visitors DESC
LIMIT 5;
	
		
		
-- 2. Use SQL to discover which day of the week there are usually more visitors on average in restaurants.



WITH AuxTable AS(
	SELECT
		day_of_week,
		AVG(reserve_visitors)*1.0 as avg_of_visitors -- Multiplying by 1.0 se get a decimal
	FROM restaurants_visitors vis
		LEFT JOIN date_info dt 
			ON vis.DATE(visit_datetime) = dt.calendar_date   -- Joining on DATE(visit_datetime) due to the existance of NULL values in visit_date
	GROUP BY 
		day_of_week
	), AuxTable2 AS(
SELECT day_of_week, 
	   ROW_NUMBER() OVER(ORDER BY avg_of_visitors DESC) as ranking   -- Ranking the averages. 
	FROM AuxTable;
	)
SELECT day_of_week FROM AuxTable2 WHERE ranking = 1  -- Just displaying the day of the week since it's not asking for the AVG.



-- 3. How was the percentage of growth of the amount of visitors week over week for the last four weeks of the data? Use SQL too.


WITH ProcessData AS(
	SELECT
		WEEK(DATE(visit_datetime)) as week_number,    -- Grouping by week number. MySQL has the WEEK function.
		SUM(reserve_visitors) as sum_of_visitors
	FROM restaurants_visitors vis
		LEFT JOIN date_info dt 
			ON vis.DATE(visit_datetime) = dt.calendar_date   -- Joining on DATE(visit_datetime) due to the existance of NULL values in visit_date
	WHERE 
		DATE(visit_datetime) BETWEEN '2017-05-01' AND '2017-05-31'    -- May-2017 is the last month 
	GROUP BY WEEK(DATE(visit_datetime))
)
SELECT 
	week_number,
	((LEAD(sum_of_visitors, 1) OVER(ORDER BY week_number)) - sum_of_visitors) / sum_of_visitors * 100.0 AS percent_diff   -- Calculating WoW percent difference. 
FROM 
	ProcessData
ORDER BY week_number ASC
	