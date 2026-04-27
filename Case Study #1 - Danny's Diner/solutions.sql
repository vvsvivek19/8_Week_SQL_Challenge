-- Week 1: Danny's Diner - Solutions

-- Q1
SELECT 
    s.customer_id,
    SUM(m.price) AS total_spending
FROM sales s
JOIN menu m 
    ON s.product_id = m.product_id
GROUP BY s.customer_id;


-- Q2
SELECT 
    customer_id,
    COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY customer_id;


-- Q3
WITH first_orders AS (
    SELECT 
        customer_id,
        product_id,
        DENSE_RANK() OVER (
            PARTITION BY customer_id 
            ORDER BY order_date
        ) AS order_rank
    FROM sales
)
SELECT 
    f.customer_id,
    m.product_name
FROM first_orders f
JOIN menu m 
    ON f.product_id = m.product_id
WHERE order_rank = 1;


-- Q4
WITH product_counts AS (
    SELECT 
        m.product_name,
        COUNT(*) AS total_purchase
    FROM sales s
    JOIN menu m 
        ON s.product_id = m.product_id
    GROUP BY m.product_name
),
ranked_products AS (
    SELECT *,
        DENSE_RANK() OVER (ORDER BY total_purchase DESC) AS rank
    FROM product_counts
)
SELECT *
FROM ranked_products
WHERE rank = 1;


-- Q5
WITH product_counts AS (
    SELECT 
        s.customer_id,
        m.product_name,
        COUNT(*) AS total_purchase
    FROM sales s
    JOIN menu m 
        ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
),
ranked_products AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY customer_id 
            ORDER BY total_purchase DESC
        ) AS rank
    FROM product_counts
)
SELECT 
    customer_id,
    product_name
FROM ranked_products
WHERE rank = 1
ORDER BY customer_id;

/*Really good ranking question*/
-- Q6
WITH ranked_orders AS (
    SELECT 
        s.customer_id,
        s.order_date,
        m.product_name,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id 
            ORDER BY s.order_date, s.product_id
        ) AS order_rank
    FROM sales s
    JOIN members mem 
        ON s.customer_id = mem.customer_id
    JOIN menu m 
        ON s.product_id = m.product_id
    WHERE s.order_date >= mem.join_date
)
SELECT 
    customer_id,
    order_date,
    product_name
FROM ranked_orders
WHERE order_rank = 1;


-- Q7
WITH ranked_orders AS (
    SELECT 
        s.customer_id,
        s.order_date,
        m.product_name,
        DENSE_RANK() OVER (
            PARTITION BY s.customer_id 
            ORDER BY s.order_date DESC, s.product_id
        ) AS order_rank
    FROM sales s
    JOIN members mem 
        ON s.customer_id = mem.customer_id
    JOIN menu m 
        ON s.product_id = m.product_id
    WHERE s.order_date < mem.join_date
)
SELECT 
    customer_id,
    order_date,
    product_name
FROM ranked_orders
WHERE order_rank = 1;


-- Q8
SELECT 
    s.customer_id,
    SUM(m.price) AS amount_spent,
    COUNT(*) AS total_items
FROM sales s
JOIN members mem 
    ON s.customer_id = mem.customer_id
JOIN menu m 
    ON s.product_id = m.product_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;


-- Q9
SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS total_points
FROM sales s
JOIN menu m 
    ON s.product_id = m.product_id
GROUP BY s.customer_id;

/*Nice Question to test your if/else logic*/
-- Q10
SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN s.order_date BETWEEN mem.join_date 
                 AND DATE_ADD(mem.join_date, INTERVAL 6 DAY)
                THEN m.price * 20
            WHEN m.product_name = 'sushi'
                THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS total_points
FROM sales s
JOIN members mem 
    ON s.customer_id = mem.customer_id
JOIN menu m 
    ON s.product_id = m.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id;


-- Q11 (Bonus Question): Join All The Things
SELECT 
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE 
        WHEN mem.customer_id IS NOT NULL 
             AND s.order_date >= mem.join_date THEN 'Y'
        ELSE 'N'
    END AS member
FROM sales s
LEFT JOIN members mem 
    ON s.customer_id = mem.customer_id
JOIN menu m 
    ON s.product_id = m.product_id;

-- Q12 (Bonus Question): Rank All The Things
/* ⭐ Frequent Interview Question: Tests ability to combine CTEs, Conditional Logic (CASE), and Window Functions (RANK) ⭐ */

WITH CTE_Membership_record AS
(
	SELECT 
		s.customer_id,
		s.order_date,
		m.product_name,
		m.price,
		CASE 
			WHEN mem.customer_id IS NOT NULL 
				 AND s.order_date >= mem.join_date THEN 'Y'
			ELSE 'N'
		END AS member
	FROM sales s
	LEFT JOIN members mem 
		ON s.customer_id = mem.customer_id
	JOIN menu m 
		ON s.product_id = m.product_id
)
SELECT 
	*,
    CASE 
		WHEN member = 'N' THEN NULL
        WHEN member = 'Y' THEN RANK() OVER(Partition by customer_id, member ORDER BY order_date) 
	END as ranking
FROM CTE_Membership_record;



