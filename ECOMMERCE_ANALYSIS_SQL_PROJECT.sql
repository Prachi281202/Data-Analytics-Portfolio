USE ecommerce_analytics;

---- SECTION 1: BEGINNER LEVEL
-- Goal: SELECT, WHERE, GROUP BY, ORDER BY, basic JOINs, aggregates

-- Q1. How many total customers do we have?
SELECT COUNT(*) AS total_customers
FROM customers;

-- Q2. List all products priced above ₹3000, sorted by price descending.
SELECT product_name, category, price
FROM products
WHERE price > 3000
ORDER BY price DESC;

-- Q3. How many orders fall into each order_status?
SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Q4. List all customers from Maharashtra.
SELECT customer_id, customer_name, city, state
FROM customers
WHERE state = 'Maharashtra';

-- Q5. What is the average product price per category?
SELECT category, ROUND(AVG(price), 2) AS avg_price
FROM products
GROUP BY category
ORDER BY avg_price DESC;

-- Q6. How many orders were placed using each payment type?
SELECT payment_type, COUNT(*) AS num_orders
FROM orders
GROUP BY payment_type
ORDER BY num_orders DESC;

 -- Q7. Find all orders placed in January 2024.
SELECT order_id, customer_id, order_date, order_status
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Q8. What is the most expensive product in each category?
SELECT category, MAX(price) AS max_price
FROM products
GROUP BY category;

-- Q9. Count how many products exist per category.
SELECT category, COUNT(*) AS product_count
FROM products
GROUP BY category
ORDER BY product_count DESC;

-- Q10. List the 10 most recently signed-up customers.
SELECT customer_id, customer_name, signup_date
FROM customers
ORDER BY signup_date DESC
LIMIT 10;
 
 -- SECTION 2: INTERMEDIATE
-- Goal: multi-table JOINs, subqueries, CASE, HAVING, date functions

-- Q1. What is the total revenue generated from delivered orders?
SELECT ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';
 
 -- Q2. Top 10 customers by total spend (delivered orders only).
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(oi.quantity * p.price), 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 10;

-- Q3. Average delivery time (in days) by state, delivered orders only.
SELECT c.state,
       ROUND(AVG(DATEDIFF(o.delivery_date, o.order_date)), 1) AS avg_delivery_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.state
ORDER BY avg_delivery_days;
 
 -- Q4. Customers who have placed more than 1 order (repeat customers).
SELECT customer_id, COUNT(order_id) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1
ORDER BY order_count DESC;

-- Q5. Categorize each order by size using CASE:
--     'Small' if order value < 1000, 'Medium' if 1000-5000, 'Large' if > 5000
SELECT o.order_id,
       SUM(oi.quantity * p.price) AS order_value,
       CASE
           WHEN SUM(oi.quantity * p.price) < 1000 THEN 'Small'
           WHEN SUM(oi.quantity * p.price) BETWEEN 1000 AND 5000 THEN 'Medium'
           ELSE 'Large'
       END AS order_size
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id
ORDER BY order_value DESC;

-- Q6. Which category generates the highest revenue?
SELECT p.category, ROUND(SUM(oi.quantity * p.price), 2) AS category_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.category
ORDER BY category_revenue DESC;
 
 -- Q7. Month-wise order trend (how many orders placed each month).
SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month,
       COUNT(*) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;
 
 -- Q8. Customers who have never placed an order (using subquery / LEFT JOIN).
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Q9. Cancellation rate (%) by payment type.
SELECT payment_type,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN order_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
       ROUND(SUM(CASE WHEN order_status = 'cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM orders
GROUP BY payment_type
ORDER BY cancellation_rate_pct DESC;
 
 -- Q10. Products that have never been ordered.
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;
 
 -- SECTION 3: ADVANCED

-- Q1 Detect potential duplicate/suspicious orders — same customer,
--     same day, same payment type (data quality / audit-style check).
SELECT customer_id, order_date, payment_type, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id, order_date, payment_type
HAVING COUNT(*) > 1;

