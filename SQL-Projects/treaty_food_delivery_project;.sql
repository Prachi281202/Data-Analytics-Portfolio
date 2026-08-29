use treaty;

-- =====================================================
-- TREATY FOOD DELIVERY APP — SQL PRACTICE QUESTIONS
-- Table used: treaty_orders (15 columns, 15000 rows)
-- Run treaty_orders_single_table.sql FIRST to create the DB & data
-- =====================================================

USE treaty;

-- Q1. View the first 10 records of the table.
SELECT *
FROM treaty_orders
LIMIT 10;

-- Q2. Find the total number of orders placed.
SELECT COUNT(*) AS total_orders
FROM treaty_orders;

-- Q3. Find the total revenue generated from delivered orders.
SELECT SUM(total_amount) AS total_revenue
FROM treaty_orders
WHERE order_status = 'Delivered';

-- Q4. Find the number of orders for each order status.
SELECT order_status, COUNT(*) AS total_orders
FROM treaty_orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Q5. Find the top 5 cities with the highest number of orders.
SELECT customer_city, COUNT(*) AS total_orders
FROM treaty_orders
GROUP BY customer_city
ORDER BY total_orders DESC
LIMIT 5;

-- Q6. Find the most popular cuisine type (by number of orders).
SELECT cuisine_type, COUNT(*) AS total_orders
FROM treaty_orders
GROUP BY cuisine_type
ORDER BY total_orders DESC;

-- Q7. Find the most ordered item overall.
SELECT item_name, SUM(quantity) AS total_quantity_sold
FROM treaty_orders
GROUP BY item_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- Q8. Find the most used payment method.
SELECT payment_method, COUNT(*) AS total_uses
FROM treaty_orders
GROUP BY payment_method
ORDER BY total_uses DESC;

-- Q9. Find the average order value.
SELECT ROUND(AVG(total_amount), 2) AS avg_order_value
FROM treaty_orders;

-- Q10. Find the top 10 restaurants by total revenue.
SELECT restaurant_name, SUM(total_amount) AS revenue
FROM treaty_orders
WHERE order_status = 'Delivered'
GROUP BY restaurant_name
ORDER BY revenue DESC
LIMIT 10;

-- Q11. Find the average delivery time (in minutes) for each city.
SELECT customer_city, ROUND(AVG(delivery_time_minutes), 1) AS avg_delivery_time
FROM treaty_orders
GROUP BY customer_city
ORDER BY avg_delivery_time;

-- Q12. Find the cancellation rate (%) of orders.
SELECT
    ROUND(SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM treaty_orders;

-- Q13. Find month-wise total revenue for the year 2025.
SELECT MONTH(order_date) AS month_num, SUM(total_amount) AS monthly_revenue
FROM treaty_orders
WHERE YEAR(order_date) = 2025 AND order_status = 'Delivered'
GROUP BY MONTH(order_date)
ORDER BY month_num;

-- Q14. Find the day of the week with the highest number of orders.
SELECT DAYNAME(order_date) AS day_of_week, COUNT(*) AS total_orders
FROM treaty_orders
GROUP BY DAYNAME(order_date)
ORDER BY total_orders DESC;

-- Q15. Find all orders with total amount greater than 1000.
SELECT order_id, customer_name, restaurant_name, total_amount
FROM treaty_orders
WHERE total_amount > 1000
ORDER BY total_amount DESC
LIMIT 20;

-- Q16. Find customers who have placed more than 3 orders.
SELECT customer_name, COUNT(*) AS total_orders
FROM treaty_orders
GROUP BY customer_name
HAVING COUNT(*) > 3
ORDER BY total_orders DESC;

-- Q17. Find delivery agents who handled more than 20 deliveries.
SELECT delivery_agent_name, COUNT(*) AS total_deliveries
FROM treaty_orders
GROUP BY delivery_agent_name
HAVING COUNT(*) > 20
ORDER BY total_deliveries DESC;

-- Q18. Find the average order value per cuisine type.
SELECT cuisine_type, ROUND(AVG(total_amount), 2) AS avg_order_value
FROM treaty_orders
GROUP BY cuisine_type
ORDER BY avg_order_value DESC;

-- Q19. Classify orders into Low / Medium / High value using CASE.
SELECT order_id, total_amount,
    CASE
        WHEN total_amount < 300 THEN 'Low'
        WHEN total_amount BETWEEN 300 AND 800 THEN 'Medium'
        ELSE 'High'
    END AS order_value_category
FROM treaty_orders
LIMIT 20;

-- Q20. Find orders that took longer than 60 minutes to deliver.
SELECT order_id, customer_name, delivery_time_minutes, order_status
FROM treaty_orders
WHERE delivery_time_minutes > 60
ORDER BY delivery_time_minutes DESC
LIMIT 20;

-- Q21. Rank restaurants by total revenue using a window function.
SELECT restaurant_name, total_revenue,
       RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM (
    SELECT restaurant_name, SUM(total_amount) AS total_revenue
    FROM treaty_orders
    WHERE order_status = 'Delivered'
    GROUP BY restaurant_name
) rev
LIMIT 10;

-- Q22. Find each city's top-selling cuisine type using a window function.
SELECT customer_city, cuisine_type, total_orders
FROM (
    SELECT customer_city, cuisine_type, COUNT(*) AS total_orders,
           RANK() OVER (PARTITION BY customer_city ORDER BY COUNT(*) DESC) AS rnk
    FROM treaty_orders
    GROUP BY customer_city, cuisine_type
) ranked
WHERE rnk = 1;

-- Q23. Find customers who spent more than the overall average order value (subquery).
SELECT customer_name, SUM(total_amount) AS total_spent
FROM treaty_orders
GROUP BY customer_name
HAVING SUM(total_amount) > (SELECT AVG(total_amount) FROM treaty_orders)
ORDER BY total_spent DESC
LIMIT 10;

-- Q24. Find running total of daily revenue (window function).
SELECT order_date, daily_revenue,
       SUM(daily_revenue) OVER (ORDER BY order_date) AS running_total
FROM (
    SELECT order_date, SUM(total_amount) AS daily_revenue
    FROM treaty_orders
    WHERE order_status = 'Delivered'
    GROUP BY order_date
) daily
ORDER BY order_date
LIMIT 30;

-- Q25. Combined KPI summary — total orders, revenue, avg delivery time, cancellation rate.
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'Delivered' THEN total_amount ELSE 0 END) AS total_revenue,
    ROUND(AVG(delivery_time_minutes), 1) AS avg_delivery_time_min,
    ROUND(SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM treaty_orders;

