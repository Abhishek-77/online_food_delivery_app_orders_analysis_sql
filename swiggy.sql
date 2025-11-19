show tables

select * from customers
select * from deliverypartners
select * from deliveryupdates
select * from complaints
select * from feedback
select * from menuitems
select * from orderdelivery
select * from orderitems
select * from orders
select * from payment
select * from restaurants






-- Display all customers who live in 'Delhi'.
select name
from customers
where city = 'Delhi' 

-- Find the average rating of all restaurants in 'Mumbai'

select city,
-- avg(rating) as avg_rating,                     -- gives 4.3
avg(ifnull(rating,0)) as avg_rating2              -- gives 3.2
from restaurants
where city = 'Mumbai'
group by city







-- List all customers who have placed at least one order.
select * from customers;  -- columns are - customer_id,name,email,phone_number,city,address
select * from orders      -- columns are - order_id, customer_id, restaurant_id, order_date, total_amount, status

-- using subquery join

select customer_id,name
from customers
where customer_id in(
select customer_id 
from orders
group by customer_id
having count(order_id) >= 1
)

/*
-- since it is asked at least one order hence we can use distinct in inner query 

💡 Optimization Tip:
You don’t need HAVING COUNT(order_id) >= 1 — just checking that the customer_id exists in orders is enough, 
since every grouped customer_id means at least one order by definition.

So, you can simplify it to:

SELECT customer_id, name
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id 
    FROM orders
);

Or even better (and more efficient in some engines):

SELECT DISTINCT c.customer_id, c.name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

*/

-- using join 

select *,count(order_id)       -- here group by worked even though we use * i.e. all non aggregated columns
from customers c
inner join orders o
on c.customer_id = o.customer_id
group by o.customer_id


select c.customer_id,name,count(order_id)      -- here it worked without using name in group by 
from customers c
inner join orders o
on c.customer_id = o.customer_id
group by o.customer_id
having count(order_id) >= 1


select c.customer_id, c.name, count(order_id)      
from customers c
inner join orders o
on c.customer_id = o.customer_id
where status != 'cancelled'
group by o.customer_id, c.name
having count(order_id) >= 1


-- Standards-compliant version          (chatgpt query above is the same as this one)
SELECT c.customer_id, c.name, COUNT(order_id)
FROM customers c
INNER JOIN orders o 
ON c.customer_id = o.customer_id
where status != 'cancelled'                   -- added this
GROUP BY c.customer_id, c.name
HAVING COUNT(order_id) >= 1;


/*

1. in select can we use o.customer_id in place of c.customer_id as it is common column ?
Yes, ✅ you can use o.customer_id in the SELECT clause instead of c.customer_id — because both c.customer_id and o.customer_id are identical after the JOIN.
👇 So this is also valid and correct:

SELECT o.customer_id, c.name, COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY o.customer_id, c.name
HAVING COUNT(o.order_id) > 2;

✅ Why it works:
You are doing an INNER JOIN, so:
Each row from orders is matched to a customer.
o.customer_id and c.customer_id will be the same value in each row.

💡 Best Practice (optional):
Use the column from the "master" or primary table (customers in this case) when selecting identifiers — for clarity and consistency:

SELECT c.customer_id, c.name, ...

But from a functional perspective, both are fine.



2. if it was left join then we can not use o.customer_id in place of c.customer_id .. as it may change the output.. 
   is my understanding correct? 

Yes, your understanding is absolutely correct ✅ — and that shows a strong grasp of SQL join behavior.

🧠 Here's Why:
In a LEFT JOIN:

You're taking all rows from the left table (customers)
Matching rows from the right table (orders)
If no match is found in orders, then o.customer_id will be NULL



3. in group by we should use all the non aggregating columns.
   here only used customer_id ing group by clause and not name column.. still it worked how?

✅ Short Answer:
Your query works because MySQL allows it — but it's not standard SQL 
and can cause unpredictable results in other databases like PostgreSQL or SQL Server.


💡 Why it worked in your case:
SELECT c.customer_id, name, COUNT(order_id)
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY o.customer_id
HAVING COUNT(order_id) >= 1;

You’re only grouping by customer_id
But you're also selecting name, which is not part of the GROUP BY clause
In standard SQL, this would throw an error:

ERROR: column "name" must appear in the GROUP BY clause or be used in an aggregate function


📌 But MySQL has a lenient default:
MySQL uses a non-standard behavior (enabled by default with ONLY_FULL_GROUP_BY disabled) that allows:

Selecting columns not in GROUP BY, if MySQL can determine they are functionally dependent on the GROUP BY columns.

In your case:
customer_id is unique in the customers table
So name is functionally dependent on customer_id
MySQL lets it through.


🔧 What if ONLY_FULL_GROUP_BY is enabled?

Then this query would throw an error in MySQL too, unless you:
Add name to GROUP BY, or
Wrap it in an aggregate like MAX(name) (if appropriate)

-- Standards-compliant version
SELECT c.customer_id, c.name, COUNT(order_id)
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(order_id) >= 1;



🧠 Summary:


| Behavior                                    | Explanation                                                                                            |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| MySQL default                               | Allows selecting non-aggregated columns if they're functionally dependent on grouped columns           |
| Standard SQL (PostgreSQL, SQL Server, etc.) | Will raise an error unless all selected columns are in `GROUP BY` or aggregated                        |
| Safe practice                               | Always include all non-aggregated selected columns in the `GROUP BY` clause for cross-DB compatibility |

*/




-- Display the total number of orders placed by each customer

SELECT c.customer_id, c.name, COUNT(order_id) as total_orders
FROM customers c
INNER JOIN orders o 
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
order by total_orders;



select * from customers;  -- columns are - customer_id,name,email,phone_number,city,address
select * from orders      -- columns are - order_id, customer_id, restaurant_id, order_date, total_amount, status





-- Find the total revenue generated by each restaurant

select r.restaurant_id, r.name, sum(total_amount) as revenue_generated
from restaurants r
inner join orders o
on r.restaurant_id = o.restaurant_id
group by r.restaurant_id




select * from restaurants;  -- restaurant_id, name, city, cuisine, rating
select * from orders		-- order_id, customer_id, restaurant_id, order_date, total_amount, status
									
select * 
from restaurants r
inner join orders o
on r.restaurant_id = o.restaurant_id

select r.restaurant_id, r.name, sum(total_amount) as revenue_generated
from restaurants r
inner join orders o
on r.restaurant_id = o.restaurant_id
group by r.restaurant_id



/*

🔧 ✅ Recommended Fix (Best Practice):

SELECT 
    r.restaurant_id, 
    r.name, 
    SUM(o.total_amount) AS revenue_generated
FROM 
    restaurants r
INNER JOIN 
    orders o ON r.restaurant_id = o.restaurant_id
GROUP BY 
    r.restaurant_id, r.name;


🧠 Why Group by r.name Too?
Because:

You're selecting it.
And it's not an aggregate function.
Grouping by both restaurant_id and name ensures your query is portable and SQL-compliant.






*/




-- Find the top 5 restaurants with the highest average rating.

select * 
from restaurants
order by rating desc
limit 5


select * from restaurants
select * from feedback

/*

✅ Optional Improvements
🔹 1. Explicitly Ignore NULL Ratings (Cleaner)
To make your intention clearer, you can explicitly filter out NULL ratings:

SELECT * 
FROM restaurants
WHERE rating IS NOT NULL
ORDER BY rating DESC
LIMIT 5;

This ensures the query works the same even in other SQL engines where NULL ordering behavior might differ

🧠 Summary

| Your Query                 | Works in MySQL? | Ignores NULLs?     | Recommended?           |
| -------------------------- | --------------- | ------------------ | ---------------------- |
| `ORDER BY rating DESC`     | ✅ Yes           | ✅ Yes (by default) | 🔸 Works, but implicit |
| `WHERE rating IS NOT NULL` | ✅ Yes           | ✅ Yes              | ✅ Clear and portable   |


*/



-- Display all customers who have never placed an order

select customer_id,name
from customers
where customer_id not in
(
select customer_id
from orders
)



-- test queries
select * from customers
where customer_id in (24,25,26,27,28,29)

select * from orders
where customer_id in (24,25,26,27,28,29)


-- using join

select * 
from customers c
left join orders o
on c.customer_id = o.customer_id
where o.customer_id is null 

/*
Yes ✅ — your query is correct and a very commonly used pattern to find customers who have not placed any orders.

🔍 Explanation of the Query:

SELECT * 
FROM customers c
LEFT JOIN orders o
  ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;


💡 What It's Doing:
LEFT JOIN: Includes all customers, and joins matching orders (if any).
WHERE o.customer_id IS NULL: Filters out those who have no matching order records (i.e., no orders at all).
For these customers, all columns from the orders table will be NULL.

✅ Result:
You’ll get only customers who never placed any order, which is exactly what you want.

🧠 Summary:

| Query Type            | Purpose                          | Handles NULLs?                       | Recommended          |
| --------------------- | -------------------------------- | ------------------------------------ | -------------------- |
| `NOT IN`              | Filters customers not in orders  | ❌ (if orders.customer\_id has NULLs) | ⚠️ Sometimes buggy   |
| `NOT EXISTS`          | Subquery with correlation        | ✅                                    | ✅ Safe and portable  |
| `LEFT JOIN + IS NULL` | Joins and filters nulls directly | ✅                                    | ✅ Easy and intuitive |


✅ Your usage of LEFT JOIN with IS NULL is correct and efficient.
Let me know if you want to include additional customer info or aggregate order data.


*/

select * from customers;  -- columns are - customer_id,name,email,phone_number,city,address
select * from orders      -- columns are - order_id, customer_id, restaurant_id, order_date, total_amount, status

/*

⚠️ One Important Note (Edge Case):
If orders.customer_id has NULL values, then:
The NOT IN may return no results or incorrect results, because NULL comparisons make the whole condition unknown.

Safe alternative: Use NOT EXISTS, which handles NULLs better.                              *****

✅ Safer Version Using NOT EXISTS:

SELECT customer_id, name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


🧠 Summary:

| Method       | Correct? | Safe with NULLs? | Performance |
| ------------ | -------- | ---------------- | ----------- |
| `NOT IN`     | ✅ Yes    | ❌ No             | Good        |
| `NOT EXISTS` | ✅ Yes    | ✅ Yes            | Best choice |


*/;





-- Find the number of orders placed by each customer in 'Mumbai'.
-- using join

select c.customer_id, c.name, count(order_id)
from customers c
inner join orders o
on c.customer_id = o.customer_id
where city = 'Mumbai'
group by c.customer_id



-- using subquery
select customer_id, count(order_id)
from orders
where customer_id in
(
select customer_id
from customers
where city = 'Mumbai'
)
group by customer_id

select * from customers;  -- columns are - customer_id,name,email,phone_number,city,address
select * from orders      -- columns are - order_id, customer_id, restaurant_id, order_date, total_amount, status

/*

is this correct?
can group by be used in inner query like this?

Yes ✅ — your query is correct and the use of GROUP BY in the outer query only (as you've written it) 
is completely appropriate for this task.

🔍 How It Works:
1. Inner Query:

SELECT customer_id
FROM customers
WHERE city = 'Mumbai'


Returns all customer_ids of customers who live in Mumbai.
No need for GROUP BY here, unless you're doing aggregation — which you aren't.

Outer Query:
Filters the orders table to only include orders from those Mumbai customers.
Then groups by customer_id to count how many orders each one placed.

❓Can GROUP BY be used in the inner query?
Yes, if you need to aggregate in the inner query. For example:

SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 2


But in your case — since you're only filtering by city — GROUP BY is not needed in the subquery.

✅ Final Tip (Alternative with JOIN — for clarity and optimization):

SELECT o.customer_id, COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.city = 'Mumbai'
GROUP BY o.customer_id;

This gives the same result but avoids a subquery, and can be more readable.

-- ---------------
if we want to fetch customer name as well.. then will subquery work?
tables and columns are as below

Great question! The subquery version you're using will work for counting orders, 
but it becomes limiting if you want to also fetch the customer name or other details from the customers table.


❌ Problem with Subquery + Aggregation:
In this version:

SELECT customer_id, COUNT(order_id)
FROM orders
WHERE customer_id IN (
    SELECT customer_id
    FROM customers
    WHERE city = 'Mumbai'
)
GROUP BY customer_id;

You’re only selecting customer_id from the subquery, 
so in the outer query, you have no direct access to customer.name — only the ID.


✅ Correct Way: Use a JOIN Instead
To include the customer name and other info (like city), use an INNER JOIN:

SELECT 
    c.customer_id, 
    c.name, 
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE c.city = 'Mumbai'
GROUP BY c.customer_id, c.name;


✅ Why This Is Better:
	You filter customers by city (Mumbai).
	You join orders to count them.
	You can select c.name directly because you joined the customers table.


🧠 Summary:

| Task                           | Subquery ✅ | Join ✅ |
| ------------------------------ | ---------- | ------ |
| Count orders for Mumbai        | ✅          | ✅      |
| Get customer name/city/address | ❌          | ✅      |
| Cleaner and more flexible      | ❌          | ✅      |


*/;




-- Display all orders placed in the last 30 days.

select order_id,date(order_date) as order_date
from orders
where order_date >= (select max(order_date) from orders) - interval 30 day



-- using between

SELECT *
FROM orders
WHERE order_date BETWEEN 
    (SELECT MAX(order_date) FROM orders) - INTERVAL 30 DAY
    AND (SELECT MAX(order_date) FROM orders);

-- using curdate() .. for live data

SELECT *
FROM orders
WHERE order_date >= CURDATE() - INTERVAL 30 DAY;




-- rough work
select * from customers;  -- columns are - customer_id,name,email,phone_number,city,address
select * from orders      -- columns are - order_id, customer_id, restaurant_id, order_date, total_amount, status

select max(order_date)
from orders

select order_id,order_date, month(order_date), day(order_date)
from orders


/*

To display all orders placed in the last 30 days, 
you can use the orders.order_date field with the CURRENT_DATE (or NOW()) function in MySQL.











*/




-- List all delivery partners who have completed more than 1 delivery

select dp.partner_id, dp.name, count(order_delivery_id) as total_delivered
from deliverypartners dp
inner join orderdelivery od
on dp.partner_id = od.partner_id
inner join deliveryupdates du
on od.order_id = du.order_id
where du.status = 'Delivered'
group by dp.partner_id, dp.name


select dp.partner_id, dp.name, count(*) as total_delivered           -- using count(*)
from deliverypartners dp
inner join orderdelivery od
on dp.partner_id = od.partner_id
inner join deliveryupdates du
on od.order_id = du.order_id
where du.status = 'Delivered'
group by dp.partner_id, dp.name


-- only used where clause as per chat gpt group by mandetory here
select distinct name
from deliverypartners dp
inner join orderdelivery od
on dp.partner_id = od.partner_id
inner join deliveryupdates du
on od.order_id = du.order_id
where du.status = 'Delivered'
-- group by name

/*

select * from deliverypartners; 	--  columns partner_id, name, phone_number, city
select * from deliveryupdates;		--  delivery_id, order_id, status, update_time
select * from orderdelivery         --  order_delivery_id, order_id, partner_id, delivery_time

✅ To Get Delivery Partners Who Completed More Than 1 Delivery:
You need to:
	1. Join the three tables correctly.
	2. Filter only for 'Delivered' status.
	3. Group by the delivery partner.
	4. Use HAVING COUNT(*) > 1 to filter those who have more than 1 delivery.


SELECT dp.partner_id, dp.name, COUNT(*) AS deliveries_completed
FROM deliverypartners dp
INNER JOIN orderdelivery od ON dp.partner_id = od.partner_id
INNER JOIN deliveryupdates du ON od.order_id = du.order_id
WHERE du.status = 'Delivered'
GROUP BY dp.partner_id, dp.name
HAVING COUNT(*) > 1;


🔍 Explanation:
- INNER JOIN connects:
	Partners to their deliveries (orderdelivery)
	Deliveries to delivery updates (deliveryupdates)
- WHERE du.status = 'Delivered' filters to only completed deliveries.
- GROUP BY dp.partner_id, dp.name groups records per delivery partner.
- HAVING COUNT(*) > 1 ensures only those with more than 1 delivery are shown.

-- ----------
-- I assumed if  du.status = 'Delivered' then it is one delivery so used only where du.status = 'Delivered'
   and did not use count and group by + having

Great observation — you're on the right track, and your assumption:
	“If du.status = 'Delivered' then it is one delivery”
is technically correct, per row. However:

🚫 Why WHERE du.status = 'Delivered' alone is not sufficient:
It only filters the rows to show each individual delivery marked as "Delivered".

If you want to know:

Which delivery partners have done more than 1 delivery,
you need to count how many times each partner appears with 'Delivered' status.

🔁 Your Current Query (Recap):
This:   

SELECT DISTINCT name
FROM deliverypartners dp
JOIN orderdelivery od ON dp.partner_id = od.partner_id
JOIN deliveryupdates du ON od.order_id = du.order_id
WHERE du.status = 'Delivered';


joins the relevant tables correctly ✅
filters only 'Delivered' status ✅
but does not count the number of deliveries per partner ❌

So:
Even if a partner has delivered once, they will appear.
You’ll get all partners who made at least one delivery — not more than one.


✅ What You Should Do:
To answer:

“Partners who completed more than 1 delivery”
You need to group and count, like:

SELECT dp.partner_id, dp.name, COUNT(*) AS total_deliveries
FROM deliverypartners dp
JOIN orderdelivery od ON dp.partner_id = od.partner_id
JOIN deliveryupdates du ON od.order_id = du.order_id
WHERE du.status = 'Delivered'
GROUP BY dp.partner_id, dp.name
HAVING COUNT(*) > 1;




Summary

| Clause                     | Purpose                                    |
| -------------------------- | ------------------------------------------ |
| `WHERE status='Delivered'` | Filters individual rows (1 per delivery)   |
| `GROUP BY`                 | Groups rows by partner                     |
| `HAVING COUNT(*) > 1`      | Ensures partner had *more than 1* delivery |



-- ----------
-- should we use  COUNT(*) or  COUNT(order_delivery_id) or count(order_id)

Excellent question! Choosing between COUNT(*), COUNT(order_delivery_id), or COUNT(order_id) 
depends on the data structure and your goal. Let’s break it down based on your schema:


✅ 1. COUNT(*)
Counts all rows after joins and filters.
Best when you're sure each row in the final result represents one unique delivery.
Simple and works safely if no duplicates are introduced from joins.

🟢 Recommended in most cases if your join is tight and each "Delivered" row represents one delivery.


✅ 2. COUNT(order_delivery_id)
Counts non-NULL values in order_delivery_id.
Use this if you're worried about duplicate order_ids from joins (like if deliveryupdates has multiple updates per order).
Slightly safer when you're joining with a table that might create row multiplication.


✅ 3. COUNT(order_id)
This could lead to overcounting if:
	There are multiple status updates per order.
	Each order_id appears more than once in deliveryupdates.
Unless order_id is unique per delivery status 'Delivered', this is not recommended.

💡 Recommendation:
If you want to be 100% safe against row duplication:

-- Use COUNT(DISTINCT od.order_id)
SELECT dp.partner_id, dp.name, COUNT(DISTINCT od.order_id) AS total_deliveries
FROM deliverypartners dp
JOIN orderdelivery od ON dp.partner_id = od.partner_id
JOIN deliveryupdates du ON od.order_id = du.order_id
WHERE du.status = 'Delivered'
GROUP BY dp.partner_id, dp.name
HAVING COUNT(DISTINCT od.order_id) > 1;


Summary Table

| Expression                 | Safe to Use? | Notes                                                           |
| -------------------------- | ------------ | --------------------------------------------------------------- |
| `COUNT(*)`                 | ✅            | Simple and safe if no duplicate joins                           |
| `COUNT(order_delivery_id)` | ✅            | Safe if `order_delivery_id` is unique and not null              |
| `COUNT(order_id)`          | ⚠️           | Risky if `order_id` repeats (multiple status updates per order) |
| `COUNT(DISTINCT order_id)` | ✅            | Safest option if `order_id` may appear multiple times in joins  |






*/






-- Find the customers who have placed orders on exactly three different days.

select c.customer_id,c.name						
from customers c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_id,c.name
having count(distinct date(order_date)) >= 3



select * 										-- did not return any data
from customers c
inner join orders o
on c.customer_id = o.customer_id
where datediff(order_date, order_date -1) = 1    


?/*

select * from customers; -- customer_id, name, email, phone_number, city, address
select * from orders     -- order_id, customer_id, restaurant_id, order_date, total_amount, status

You're on the right path in terms of wanting to identify customers who have placed orders on exactly three different days, but the query you've written is not correct for this requirement.

❌ Problem with This Line:
WHERE DATEDIFF(order_date, order_date - 1) = 1

This condition doesn’t make sense because:

order_date - 1 is not valid syntax — it’s not subtracting a day.

Even if it worked, it would just check if a date is one day apart from itself, which is always false.

✅ Correct Logic
You need to:

Group by customer.
Count the number of distinct dates on which they placed orders.
Filter customers who have placed orders on exactly 3 different dates.


Great! Here's how you can list the customers who placed orders on exactly 3 different days 
and also show those 3 distinct order dates. 		

-- Step 1: Find customers who ordered on exactly 3 different days
WITH customers_with_3_days AS (
  SELECT customer_id
  FROM orders
  GROUP BY customer_id
  HAVING COUNT(DISTINCT DATE(order_date)) = 3
)

-- Step 2: Join with customers and orders to get the 3 order dates
SELECT c.customer_id, c.name, DATE(o.order_date) AS order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN customers_with_3_days c3 ON c.customer_id = c3.customer_id
GROUP BY c.customer_id, c.name, DATE(o.order_date)
ORDER BY c.customer_id, order_date;


-- ---------

Perfect! Here's how you can pivot the result so that each customer who 
placed orders on exactly three distinct days appears in one row, with three separate columns for the dates.


WITH ranked_orders AS (
  SELECT 
    c.customer_id, 
    c.name, 
    DATE(o.order_date) AS order_date,
    ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY DATE(o.order_date)) AS rn
  FROM customers c
  JOIN orders o ON c.customer_id = o.customer_id
  WHERE c.customer_id IN (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(DISTINCT DATE(order_date)) = 3
  )
)

SELECT 
  customer_id,
  name,
  MAX(CASE WHEN rn = 1 THEN order_date END) AS order_date_1,
  MAX(CASE WHEN rn = 2 THEN order_date END) AS order_date_2,
  MAX(CASE WHEN rn = 3 THEN order_date END) AS order_date_3
FROM ranked_orders
GROUP BY customer_id, name
ORDER BY customer_id;

🔍 Explanation:

| Clause                            | Description                                                               |
| --------------------------------- | ------------------------------------------------------------------------- |
| `ROW_NUMBER()`                    | Assigns a number to each order date per customer (sorted chronologically) |
| `CASE WHEN rn = ... THEN ... END` | Pulls specific row number to separate columns                             |
| `MAX(...)`                        | Converts row values into columns (pivot)                                  |
| `GROUP BY`                        | Groups back to one row per customer                                       |


*/




-- Find the delivery partner who has worked with the most different customers.

select dp.partner_id,dp.name, count(distinct o.customer_id) as customers_count
from orders o
inner join orderdelivery od
on od.order_id = o.order_id
inner join deliverypartners dp
on od.partner_id = dp.partner_id
group by partner_id,dp.name
order by customers_count desc
limit 1


select dp.partner_id,dp.name, count(distinct o.customer_id) as customers_count
from customers c										-- removed customers column as it is not necessary
inner join orders o
on c.customer_id = o.customer_id
inner join orderdelivery od
on od.order_id = o.order_id
inner join deliverypartners dp
on od.partner_id = dp.partner_id
group by partner_id,dp.name
order by customers_count desc
limit 1




/*

select * from customers; 			 -- customer_id, name, email, phone_number, city, address
select * from orders    			 -- order_id, customer_id, restaurant_id, order_date, total_amount, status
select * from deliverypartners ;     -- partner_id, name, phone_number, city
select * from orderdelivery          -- order_delivery_id, order_id, partner_id, delivery_time

✅ Goal:
Find the delivery partner who has worked with the most different customers.

This means:
Count the number of distinct customers (o.customer_id) per partner (dp.partner_id)
Then get the partner with the maximum such count.


✅ Your Query:
🔍 What’s correct:
Correct use of joins.

Correct COUNT(DISTINCT o.customer_id) to count unique customers per partner.
Joins properly link orders → orderdelivery → deliverypartners.


⚠️ Minor Improvement:
You're ordering in ascending order. Since the goal is the partner with the most customers,
you should order in descending order and limit to top 1 (if needed).



✅ Final Version (Most Helpful Partner Only):

SELECT dp.partner_id, dp.name, COUNT(DISTINCT o.customer_id) AS customers_count
FROM orders o
JOIN orderdelivery od ON od.order_id = o.order_id
JOIN deliverypartners dp ON od.partner_id = dp.partner_id
GROUP BY dp.partner_id, dp.name
ORDER BY customers_count DESC
LIMIT 1;


🔸 Removed unnecessary customers table join, since customer_id is already in orders.
🔸 Used DESC to get highest first.
🔸 LIMIT 1 to return just the top partner.

*/




-- Identify customers who have the same city and have placed orders at the same restaurants, but on different dates.

select c1.customer_id as customer1_id,
	   c2.customer_id as customer2_id,
	   c1.city, 
	   o1.restaurant_id,
	   o1.order_date as date1,
	   o2.order_date as date2
from customers c1
	inner join orders o1 on c1.customer_id = o1.customer_id
	inner join customers c2 on c1.city = c2.city and c1.customer_id < c2.customer_id
	join orders o2 on c2.customer_id = o2.customer_id
where o1.restaurant_id = o2.restaurant_id
and o1.order_date <> o2.order_date







select * from customers; 			 -- customer_id, name, email, phone_number, city, address
select * from orders;				 -- order_id, customer_id, restaurant_id, order_date, total_amount, status
select * from restaurants            -- restaurant_id, name, city, cuisine, rating


select * 
from customers c
inner join orders o
on c.customer_id = o.customer_id
inner join restaurants r
on o.restaurant_id = r.restaurant_id 
group by c.city, r.restaurant_id


/*

Issues:
No customer-to-customer comparison is done.
GROUP BY is grouping by city and restaurant, which doesn't help identify pairs of customers from the same city.
No filtering to ensure different customers, and different dates.

✅ Correct Approach:
You need to self-join the orders and customers tables to compare two different customers.


✅ Query:

SELECT DISTINCT c1.customer_id AS customer1_id,
                c2.customer_id AS customer2_id,
                c1.city,
                o1.restaurant_id,
                o1.order_date AS date1,
                o2.order_date AS date2
FROM customers c1
JOIN orders o1 ON c1.customer_id = o1.customer_id
JOIN customers c2 ON c1.city = c2.city AND c1.customer_id < c2.customer_id
JOIN orders o2 ON c2.customer_id = o2.customer_id
WHERE o1.restaurant_id = o2.restaurant_id
  AND o1.order_date <> o2.order_date;


🔍 Explanation:

c1.customer_id < c2.customer_id: Ensures we only compare different customers, and avoid duplicate pairs like (A, B) and (B, A).
c1.city = c2.city: Customers are from the same city.
o1.restaurant_id = o2.restaurant_id: They ordered from the same restaurant.
o1.order_date <> o2.order_date: But on different dates.




*/
















-- swiggy

select * from customers;  -- columns are - customer_id,name,email,phone_number,city,address
select * from orders      -- columns are - order_id, customer_id, restaurant_id, order_date, total_amount, status























