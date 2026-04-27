# Week 1: Danny's Diner

## Case Study Questions

### Q1. Total Amount Spent
What is the total amount each customer spent at the restaurant?

---

### Q2. Number of Visits
How many days has each customer visited the restaurant?

---

### Q3. First Item Purchased
What was the first item from the menu purchased by each customer?

---

### Q4. Most Purchased Item Overall
What is the most purchased item on the menu and how many times was it purchased by all customers?

---

### Q5. Most Popular Item Per Customer
Which item was the most popular for each customer?

---

### Q6. First Item After Becoming a Member
Which item was purchased first by the customer after they became a member?

---

### Q7. Last Item Before Becoming a Member
Which item was purchased just before the customer became a member?

---

### Q8. Spending Before Membership
What is the total items and amount spent for each member before they became a member?

---

### Q9. Points Calculation
If each $1 spent equates to 10 points and sushi has a 2x points multiplier, how many points would each customer have?

---

### Q10. Points with Weekly Bonus
In the first week after a customer joins the program (including their join date), they earn 2x points on all items (not just sushi).  
How many points do customer A and B have at the end of January?

---

## 🔹 Bonus Questions

### Q11. Join All The Things
Recreate a combined dataset using the available tables with the following columns:

- customer_id  
- order_date  
- product_name  
- price  
- member (Y/N indicating whether the customer was a member at the time of purchase)

---

### Q12. Rank All The Things
Extend the previous result by adding a ranking column:

- Rank customer purchases **only after they become members**
- Ranking should be done per customer based on order_date
- For non-member purchases, ranking should be NULL