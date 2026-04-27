-- ======================================================================================================================================
--                                                                     Week 1
-- ======================================================================================================================================

-- CREATE TABLE sales (
--  customer_id VARCHAR(1),
--  order_date DATE,
--  product_id INTEGER
-- );

-- INSERT INTO sales
--  (customer_id, order_date, product_id)
-- VALUES
--  ('A', '2021-01-01', '1'),
--  ('A', '2021-01-01', '2'),
--  ('A', '2021-01-07', '2'),
--  ('A', '2021-01-10', '3'),
--  ('A', '2021-01-11', '3'),
--  ('A', '2021-01-11', '3'),
--  ('B', '2021-01-01', '2'),
--  ('B', '2021-01-02', '2'),
--  ('B', '2021-01-04', '1'),
--  ('B', '2021-01-11', '1'),
--  ('B', '2021-01-16', '3'),
--  ('B', '2021-02-01', '3'),
--  ('C', '2021-01-01', '3'),
--  ('C', '2021-01-01', '3'),
--  ('C', '2021-01-07', '3');
--  

-- CREATE TABLE menu (
--  product_id INTEGER,
--  product_name VARCHAR(5),
--  price INTEGER
-- );

-- INSERT INTO menu
--  (product_id,product_name,price)
-- VALUES
--  ('1', 'sushi', '10'),
--  ('2', 'curry', '15'),
--  ('3', 'ramen', '12');
--   

-- CREATE TABLE members (
--  customer_id VARCHAR(1),
--  join_date DATE
-- );

-- INSERT INTO members
--  (customer_id, join_date)
-- VALUES
--  ('A', '2021-01-07'),
--  ('B', '2021-01-09');

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Data exploration
use dannys_diner;
SELECT * FROM members;
SELECT * FROM menu;
SELECT * from sales;

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
	sales.customer_id,
	SUM(menu.price) total_spending
FROM sales 
JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) as days_visited
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT * FROM sales;
SELECT * FROM menu;
-- Solution using basic techniques
SELECT customer_id, product_name FROM (
SELECT temp.customer_id, menu.product_name
FROM menu 
JOIN (
		SELECT sales.customer_id, sales.product_id
		FROM sales
		JOIN (
			SELECT customer_id, MIN(order_date) as first_order_date 
			FROM sales 
			GROUP BY customer_id
		) t
		ON sales.customer_id = t.customer_id 
		AND sales.order_date = t.first_order_date
	)temp
ON temp.product_id = menu.product_id)temp_table
GROUP BY customer_id,product_name;
-- Advance Solution
WITH ctas_order_sales AS (
SELECT
	sales.customer_id, sales.order_date, menu.product_name,
    dense_rank() OVER(partition by sales.customer_id order by sales.order_date) as order_rank
FROM sales
JOIN menu ON sales.product_id = menu.product_id)
SELECT customer_id, product_name FROM ctas_order_sales WHERE order_rank = 1 GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH ctas_product_rank as (
SELECT product_name, total_purchase, dense_rank() OVER(ORDER BY total_purchase DESC) as total_rank FROM
(
	SELECT menu.product_name as product_name, count(*) as total_purchase 
	FROM sales 
	JOIN menu ON sales.product_id = menu.product_id
	GROUP BY menu.product_name
)t)
SELECT * FROM ctas_product_rank where total_rank = 1;

-- 5. Which item was the most popular for each customer?
-- First_solution
WITH ctas_customer_product_rank AS
(
SELECT customer_id, product_id, total_purchase, 
	dense_rank() OVER(partition by customer_id order by total_purchase desc) as total_rank
FROM
(
	SELECT customer_id, product_id, count(*) as total_purchase 
	FROM sales
	GROUP BY customer_id, product_id
)t
)
SELECT customer_id, menu.product_name
FROM ctas_customer_product_rank
JOIN menu ON menu.product_id = ctas_customer_product_rank.product_id
WHERE total_rank = 1 ORDER BY Customer_id;

-- Second solution
WITH product_counts AS (
	SELECT s.customer_id,
    m.product_name,
    count(*) as total_purchase
    FROM sales s JOIN menu m ON m.product_id = s.product_id
    GROUP BY s.customer_id, m.product_name
),
ranked_products AS (
	SELECT *, 
    dense_rank() OVER(partition by customer_id order by total_purchase desc) as total_rank
    FROM product_counts
)
SELECT customer_id, product_name
FROM ranked_products 
WHERE total_rank = 1
order by customer_id;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT customer_id, order_date, product_name
FROM
(
	SELECT s.customer_id, s.order_date, men.product_name, mem.join_date,
		dense_rank() over(partition by s.customer_id order by s.order_date, s.product_id) as first_order
	FROM sales as s
	JOIN members as mem ON s.customer_id = mem.customer_id
	JOIN menu as men ON s.product_id = men.product_id
	WHERE s.order_date >= mem.join_date)t
WHERE first_order = 1;

-- 7. Which item was purchased just before the customer became a member?
SELECT customer_id, order_date, product_name
FROM
(
	SELECT s.customer_id, s.order_date, men.product_name,
		dense_rank() over(partition by s.customer_id order by s.order_date desc, s.product_id) as prev_order
	FROM sales as s
	JOIN members as mem ON s.customer_id = mem.customer_id
	JOIN menu as men ON s.product_id = men.product_id
	WHERE s.order_date < mem.join_date
)t
WHERE prev_order = 1;


-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
	customer_id, sum(price) as amount_spent, count(*) as total_items
FROM
(
	SELECT s.customer_id, men.product_name, men.price
	FROM sales as s
	JOIN members as mem ON s.customer_id = mem.customer_id
	JOIN menu as men ON s.product_id = men.product_id
	WHERE s.order_date < mem.join_date
	ORDER BY s.customer_id
)t
GROUP BY customer_id
ORDER BY customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
	customer_id, sum(points) as total_points
FROM
(
	SELECT s.customer_id, men.product_name, men.price,
	CASE 
		WHEN men.product_name = 'sushi' THEN price * 20
        ELSE price * 10
	END as points
	FROM sales as s
	JOIN menu as men ON s.product_id = men.product_id
	ORDER BY s.customer_id
)t
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT customer_id, SUM(points) as total_points
FROM
(
	SELECT s.customer_id, s.order_date, men.product_name, men.price, mem.join_date, date_add(mem.join_date, INTERVAL 7 Day) as '2x_points_offer',
	CASE 
		WHEN s.order_date BETWEEN mem.join_date AND date_add(mem.join_date, INTERVAL 6 Day) THEN price * 20
		WHEN men.product_name = 'sushi' THEN price * 20
		ELSE price * 10
		END as points
	FROM sales as s
	JOIN members as mem ON s.customer_id = mem.customer_id
	JOIN menu as men ON s.product_id = men.product_id
	WHERE s.order_date >= mem.join_date AND s.order_date <= '2021-01-31'
)t
GROUP BY customer_id;

/*
Bonus challenge: Join All things
*/
SELECT s.customer_id, s.order_date, men.product_name, men.price,
	CASE 
		WHEN mem.customer_id IS NOT NULL AND s.order_date >= mem.join_date THEN 'Y'
        WHEN mem.customer_id IS NOT NULL AND s.order_date < mem.join_date THEN 'N'
        WHEN mem.customer_id IS NULL THEN 'N'
	END AS 'member'
FROM sales as s
LEFT JOIN members as mem ON s.customer_id = mem.customer_id
LEFT JOIN menu as men ON s.product_id = men.product_id;

SELECT * FROM members;













