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

--SQL SCRIPT
CREATE SCHEMA pizza_runner

go

DROP TABLE IF EXISTS runners;
CREATE TABLE pizza_runner.runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO pizza_runner.runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS pizza_runner.customer_orders;
CREATE TABLE pizza_runner.customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME
);

INSERT INTO pizza_runner.customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE pizza_runner.runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO pizza_runner.runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

DROP TABLE IF EXISTS order_ratings;
CREATE TABLE pizza_runner.order_ratings (
  "rating_id" INT IDENTITY(1,1) PRIMARY KEY,
  "order_id" INTEGER,
  "rating" INTEGER CHECK (rating>0 AND rating<6)
);
INSERT INTO pizza_runner.order_ratings
  ("order_id", "rating")
VALUES
  (1, 4),
  (2, 2),
  (3, 1),
  (4, 5),
  (5, 5),
  (7, 3),
  (8, 2),
  (10, 4);

DROP TABLE IF EXISTS pizza_runner.pizza_names;
CREATE TABLE pizza_runner.pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" VARCHAR(10)
);
INSERT INTO pizza_runner.pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_runner.pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_runner.pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_runner.pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_runner.pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
