/*Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:
link to data : https://github.com/EAtheAnalyst/SQL/blob/main/SQL%20CASE%20STUDY%201%20SCRIPT.sql
*/


-- What is the total amount each customer spent at the restaurant?

Select Customer_id, SUM(price) as total_amount
From danny_data.sales s
join danny_data.menu m on s.product_id = m.product_id
Group by customer_id

--How many days has each customer visited the restaurant?
Select Customer_id, COUNT(distinct order_date) as Visitation
From danny_data.sales 
Group by customer_id

--What was the first item from the menu purchased by each customer?
Select Customer_id,product_name
From
	(Select customer_id, product_name, 
	RANK () Over( partition by customer_id order by order_date) as sales_rank
	From danny_data.sales s
	Join danny_data.menu m on s.product_id=m.product_id) as temp_table
Where sales_rank = 1

-- another method
Select Customer_id,product_name
From
	(Select customer_id, product_name, 
	Row_number () Over( partition by customer_id order by order_date) as sales_rank
	From danny_data.sales s
	Join danny_data.menu m on s.product_id=m.product_id) as temp_table
Where sales_rank = 1

--What is the most purchased item on the menu and how many times was it purchased by all customers?
Select product_name,SUM(price) as sum_of_purchase,COUNT(1) as no_of_purchase
From danny_data.sales s
join danny_data.menu m on s.product_id = m.product_id
Group by product_name
Order by 2 desc

--Which item was the most popular for each customer?
with product_purchased as 
(
	Select customer_id,product_name,COUNT(order_date) as no_of_purchase
	From danny_data.sales s
	join danny_data.menu m on s.product_id = m.product_id
	Group by customer_id,product_name
	--order by customer_id,no_of_purchase desc
)
Select customer_id,product_name
From (
		Select p.*,
		ROW_NUMBER () over(partition by customer_id order by no_of_purchase desc) as rank_of_purchase
		from product_purchased p
) as temp_table
Where rank_of_purchase = 1

--Which item was purchased first by the customer after they became a member?
Select Customer_id,product_name
From
	(Select s.customer_id,m.product_name, 
	Row_number () Over( partition by s.customer_id order by s.order_date) as sales_rank
	From danny_data.sales s
	Join danny_data.menu m on s.product_id=m.product_id
	Left join danny_data.members me on s.customer_id = me.customer_id
	Where s.order_date >= me.join_date
	) as temp_table
Where sales_rank = 1 


--Which item was purchased just before the customer became a member?
Select Customer_id,product_name
From
	(Select s.customer_id,m.product_name, 
	Row_number () Over( partition by s.customer_id order by s.order_date) as sales_rank
	From danny_data.sales s
	Join danny_data.menu m on s.product_id=m.product_id
	Left join danny_data.members me on s.customer_id = me.customer_id 
	Where s.order_date < me.join_date
	) as temp_table
Where sales_rank = 1 


-- What is the total items and amount spent for each member before they became a member?

Select s.customer_id, COUNT(*) as no_Items, sum(price) as total_amount
From danny_data.sales s
Join danny_data.menu m on s.product_id=m.product_id
Join danny_data.members me on s.customer_id=me.customer_id
where s.order_date < me.join_date
Group by s.customer_id 


--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

Select customer_id, SUM(points) as points
FROM(
	Select s.customer_id, m.product_name, m.product_id,
	Case when m.product_id = 1 then price*20 else price*10 end as points
	From danny_data.sales s
	Join danny_data.menu m on s.product_id=m.product_id) as temp_table
Group by customer_id

--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

	Select s.customer_id, m.product_name, m.product_id,
	Case when DATEADD(week,7,s.order_date < me.join_date ) then price*20 
		when m.product_id = 1 Then price*20 else price*10 end as points
	From danny_data.sales s
	Join danny_data.menu m on s.product_id=m.product_id
	Join danny_data.members me on s.customer_id=me.customer_id
