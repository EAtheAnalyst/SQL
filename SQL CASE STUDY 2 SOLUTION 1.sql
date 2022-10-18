/* Linkt to data script :https://github.com/EAtheAnalyst/SQL/blob/main/SQL%20CASE%20STUDY%202%20SCRIPT.sql */
-A. Pizza Metrics

Q1
--How many pizzas were ordered?
Select COUNT(1) as Total_Orders
From pizza_runner.customer_orders


Q2
--How many unique customer orders were made?
Select COUNT(distinct order_id) as unique_customer_order
From pizza_runner.customer_orders


Q3
--How many successful orders were delivered by each runner?
Select runner_id,Count(*) as successful_dilervery
From pizza_runner.runner_orders 
--Join pizza_runner.runner_orders ro on co.order_id = ro.order_id
Where distance != 'null'
Group by runner_id


Q4
--How many of each type of pizza was delivered?
Select pizza_id,Count(*) as successful_dilervery
From pizza_runner.customer_orders co
Join pizza_runner.runner_orders ro on co.order_id = ro.order_id
Where distance != 'null'
Group by pizza_id



Q5
--How many Vegetarian and Meatlovers were ordered by each customer?
Select customer_id, pn.pizza_name, COUNT(co.pizza_id) as Total_Orders
From pizza_runner.customer_orders co
Join pizza_runner.pizza_names pn on co.pizza_id = pn.pizza_id
Group by Customer_id, pizza_name

--Correct Solution
SELECT customer_id,
COALESCE(SUM(CASE WHEN pizza_id = 1 THEN 1 END),0) AS meatlovers,
COALESCE(SUM(CASE WHEN pizza_id = 2 THEN 1 END),0) AS vegetarian
FROM pizza_runner.customer_orders
GROUP BY customer_id;


Q6
--What was the maximum number of pizzas delivered in a single order?
Select co.order_id,Count(*) as successful_dilervery
From pizza_runner.customer_orders co
Join pizza_runner.runner_orders ro on co.order_id = ro.order_id
Where distance != 'null'
Group by co.order_id
Order by 2 desc


Q7
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
With temp_table as (
	SELECT co.order_id,customer_id,exclusions,extras,distance,
	CASE WHEN exclusions IN ('null','') THEN 0 ELSE 1 End AS exlusions_change,
	Case when extras IN ('null','') Or extras IS NULL THEN 0 ELSE 1 END as extras_change
	From pizza_runner.customer_orders co
	Join pizza_runner.runner_orders ro on co.order_id = ro.order_id
	Where distance != 'null') 
Select customer_id,
 COUNT (CASE WHEN exlusions_change = 0 and extras_change = 0 THEN 0 END) AS NO_CHANGE,
 COUNT (CASE WHEN exlusions_change = 1 OR extras_change = 1 THEN 1 END) AS Changed_Occured
FROM temp_table
Group by customer_id



Q8
--How many pizzas were delivered that had both exclusions and extras?
With temp_table as (
	SELECT co.order_id,customer_id,exclusions,extras,distance,
	CASE WHEN exclusions IN ('null','') THEN 0 ELSE 1 End AS exlusions_change,
	Case when extras IN ('null','') Or extras IS NULL THEN 0 ELSE 1 END as extras_change
	From pizza_runner.customer_orders co
	Join pizza_runner.runner_orders ro on co.order_id = ro.order_id
	Where distance != 'null') 
Select 
 COUNT (CASE WHEN exlusions_change = 1 and extras_change = 1 THEN 1 END) AS Double_change
-- COUNT (CASE WHEN exlusions_change = 1 OR extras_change = 1 THEN 1 END) AS Changed_Occured
FROM temp_table



Q9
--What was the total volume of pizzas ordered for each hour of the day?
SELECT HOD, COUNT(*) AS pizza_ordered
 FROM(	SELECT DATEPART(hour FROM order_time) AS hod
		FROM pizza_runner.customer_orders) AS temp_table
GROUP BY hod
ORDER BY pizza_ordered DESC


Q10
--What was the volume of orders for each day of the week?
SELECT DOW, COUNT(*) AS pizza_ordered
 FROM(	SELECT DATENAME(WEEKDAY,order_time) AS DOW -- I got to use datename
		FROM pizza_runner.customer_orders) AS temp_table
GROUP BY DOW
ORDER BY 2 DESC

