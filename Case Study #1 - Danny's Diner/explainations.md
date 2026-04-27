# Week 1: Danny's Diner - Explanations

---

## Q1. Total Amount Spent

### Approach
- Joined `sales` with `menu` to get price
- Aggregated total spending using `SUM(price)` per customer

### Key Concept
- JOIN + GROUP BY aggregation

### Pattern Used
- Aggregation with dimension table

### Edge Case
- None

---

## Q2. Number of Visits

### Approach
- Counted distinct `order_date` per customer

### Key Concept
- COUNT(DISTINCT)

### Pattern Used
- Deduplicating before aggregation

### Edge Case
- Multiple orders on same day should count as one visit

---

## Q3. First Item Purchased

### Approach
- Ranked orders per customer using `DENSE_RANK()` on `order_date`
- Selected rows where rank = 1

### Key Concept
- Window function (DENSE_RANK)

### Pattern Used
- First event per group

### Edge Case
- Multiple items purchased on the same first day are all returned

---

## Q4. Most Purchased Item Overall

### Approach
- Counted total purchases per product
- Applied `DENSE_RANK()` on purchase count (descending)
- Selected rank = 1

### Key Concept
- Aggregation + window ranking

### Pattern Used
- Top-N with ties

### Edge Case
- Multiple items with same highest count are all returned

---

## Q5. Most Popular Item Per Customer

### Approach
- Counted purchases per customer and product
- Used `DENSE_RANK()` partitioned by customer
- Selected rank = 1 for each customer

### Key Concept
- Window function with PARTITION BY

### Pattern Used
- Top-N per group

### Edge Case
- Customers can have multiple equally popular items

---

## Q6. First Item After Becoming a Member

### Approach
- Filtered orders after membership join date
- Ranked orders per customer by date and product_id
- Selected rank = 1

### Key Concept
- Conditional filtering + window function

### Pattern Used
- First event after condition

### Edge Case
- Tie-breaking handled using product_id to ensure deterministic result

---

## Q7. Last Item Before Becoming a Member

### Approach
- Filtered orders before membership join date
- Ranked orders per customer in descending order of date
- Selected rank = 1

### Key Concept
- Window function with DESC ordering

### Pattern Used
- Last event before condition

### Edge Case
- Tie-breaking handled using product_id for deterministic result

---

## Q8. Spending Before Membership

### Approach
- Filtered orders before membership
- Aggregated total amount using SUM(price)
- Counted total items using COUNT(*)

### Key Concept
- Multi-metric aggregation

### Pattern Used
- Aggregation after filtering

### Edge Case
- Grouping should be only by customer (not product)

---

## Q9. Points Calculation

### Approach
- Joined sales with menu to get price
- Used CASE to apply 2x multiplier for sushi
- Aggregated total points per customer

### Key Concept
- Conditional aggregation using CASE

### Pattern Used
- Conditional scoring logic

### Edge Case
- No need to join members table (points apply to all customers)

---

## Q10. Points with Weekly Bonus

### Approach
- Filtered data till end of January
- Applied CASE logic for:
  - First week after join → 2x on all items
  - After first week → sushi gets 2x, others normal
- Aggregated total points per customer

### Key Concept
- CASE with date conditions

### Pattern Used
- Time-based conditional logic

### Edge Case
- First week includes join date (join_date + 6 days)
- Avoid overlapping CASE conditions

---

## Q11. Join All The Things

### Approach
- Joined sales with menu and members
- Used LEFT JOIN to retain all customers
- Used CASE to assign member status (Y/N)

### Key Concept
- LEFT JOIN + conditional flag

### Pattern Used
- Building derived dataset

### Edge Case
- Customers not in members table should be marked as 'N'

---

## Q12. Rank All The Things

### Approach
- Here we first use the previous query and create it into a CTE named CTE_Membership_record
- Here first apply a case when statement on membership, if its N then null rank and if its Y then we apply ranking.
- Now within this ranking is the main game. Here we partition by customer id and membership. This will create partition like this
  - Main partition is customer id
  - Sub partition is membership (Y and N) - this is the key. 
- Now for the value where ranking is N we have already put value NULL as per first when condition so we dont need to do anything.
- Now for the value where ranking is Y we have to apply ranking. here we partition by customer id and membership and apply ranking based on order date. so for each customer we will have two ranking one for N and one for Y.
- Now we can select everything from the CTE and we will get our answer.

### Key Concept
- Conditional window function

### Pattern Used
- Selective ranking
