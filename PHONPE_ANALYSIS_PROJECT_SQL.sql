CREATE DATABASE phonepe_analytics;

USE phonepe_analytics;

SELECT * FROM users;
SELECT * FROM transactions;
SELECT * FROM recharge_bills;
SELECT * FROM money_transfer;
SELECT * FROM loans;
SELECT * FROM insurance;

-- BASIC LEVEL Queries:

 #1. Display all users:
 SELECT * FROM users;
 
 #2. Find the total number of users:
 SELECT COUNT(*) AS total_users
FROM users;

#3. Find the average age of users:
SELECT ROUND(AVG(age), 2) AS average_age
FROM users;

#4. Find the youngest and oldest users:
SELECT
    MIN(age) AS youngest_age,
    MAX(age) AS oldest_age
FROM users;

#5. Find the total number of transactions:
SELECT COUNT(*) AS total_transactions
FROM transactions;

#6. Calculate total transaction amount:
SELECT
    ROUND(SUM(amount), 2) AS total_transaction_value
FROM transactions;

#7. Calculate average transaction amount:
SELECT
    ROUND(AVG(amount), 2) AS average_transaction_value
FROM transactions;

#8. Find successful vs failed transactions:
SELECT
    payment_status,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY payment_status;

#9. Find transactions by service:
SELECT
    service,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY service
ORDER BY transaction_count DESC;

#10. Find total transaction amount by service:
SELECT
    service,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY service
ORDER BY total_amount DESC;

#11. Find the highest transaction:
SELECT *
FROM transactions
ORDER BY amount DESC
LIMIT 1;

#12. Find the top 10 transactions:
SELECT *
FROM transactions
ORDER BY amount DESC
LIMIT 10;

-- INTERMEDIATE LEVEL QUERIES:

#1. Calculate success rate:
SELECT
    ROUND(
        100.0 * SUM(CASE
            WHEN payment_status = 'Successful' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS success_rate
FROM transactions;

#2. Calculate failure rate by service:
SELECT
    service,
    COUNT(*) AS total_transactions,
    SUM(CASE
        WHEN payment_status = 'Failed' THEN 1
        ELSE 0
    END) AS failed_transactions,
    ROUND(
        100.0 * SUM(CASE
            WHEN payment_status = 'Failed' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS failure_rate
FROM transactions
GROUP BY service
ORDER BY failure_rate DESC;

#3. Find the most popular service:
SELECT
    service,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY service
ORDER BY transaction_count DESC
LIMIT 1;

#4. Find the most profitable/highest-value service:
SELECT
    service,
    ROUND(SUM(amount), 2) AS total_transaction_value
FROM transactions
GROUP BY service
ORDER BY total_transaction_value DESC
LIMIT 1;

#5. Find monthly transaction performance:
SELECT
    YEAR(transaction_date) AS year,
    MONTH(transaction_date) AS month,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS transaction_value
FROM transactions
GROUP BY
    YEAR(transaction_date),
    MONTH(transaction_date)
ORDER BY year, month;

#6. Find daily transaction volume:
SELECT
    transaction_date,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY transaction_date
ORDER BY transaction_date;

#7. Find top 10 customers by transaction value:
SELECT
    u.user_id,
    u.name,
    COUNT(t.transaction_id) AS transaction_count,
    ROUND(SUM(t.amount), 2) AS total_spent
FROM users u
JOIN transactions t
    ON u.user_id = t.user_id
GROUP BY
    u.user_id,
    u.name
ORDER BY total_spent DESC
LIMIT 10;

#8. Find customers with more than 10 transactions:
SELECT
    user_id,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY user_id
HAVING COUNT(*) > 10
ORDER BY transaction_count DESC;

#9. Find average transaction amount by service:
SELECT
    service,
    ROUND(AVG(amount), 2) AS average_transaction_amount
FROM transactions
GROUP BY service
ORDER BY average_transaction_amount DESC;

#10. Find transaction failure reasons:
SELECT
    reason,
    COUNT(*) AS failure_count
FROM transactions
WHERE payment_status = 'Failed'
GROUP BY reason
ORDER BY failure_count DESC;

#11. Find failure rate by reason:
SELECT
    reason,
    COUNT(*) AS failures,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM transactions
         WHERE payment_status = 'Failed'),
        2
    ) AS percentage_of_failures
FROM transactions
WHERE payment_status = 'Failed'
GROUP BY reason
ORDER BY failures DESC;

#12. Analyze users by age group:
SELECT
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    COUNT(*) AS users
FROM users
GROUP BY
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END
ORDER BY users DESC;

#13. Find transaction value by age group:
SELECT
    CASE
        WHEN u.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN u.age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    COUNT(t.transaction_id) AS transactions,
    ROUND(SUM(t.amount), 2) AS total_value
FROM users u
JOIN transactions t
    ON u.user_id = t.user_id
GROUP BY
    CASE
        WHEN u.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN u.age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END
ORDER BY total_value DESC;

-- ADVANCED LEVEL QUERIES:

#1. Rank customers by transaction value:
SELECT
    user_id,
    ROUND(SUM(amount), 2) AS total_value,
    RANK() OVER (
        ORDER BY SUM(amount) DESC
    ) AS customer_rank
FROM transactions
GROUP BY user_id;

#2. Rank services by transaction value:
SELECT
    service,
    ROUND(SUM(amount), 2) AS total_value,
    RANK() OVER (
        ORDER BY SUM(amount) DESC
    ) AS service_rank
FROM transactions
GROUP BY service;

#3. Find each customer's first transaction:
SELECT
    user_id,
    MIN(transaction_date) AS first_transaction_date
FROM transactions
GROUP BY user_id;

#4. Find customers who used multiple services:
SELECT
    user_id,
    COUNT(DISTINCT service) AS services_used
FROM transactions
GROUP BY user_id
HAVING COUNT(DISTINCT service) > 1
ORDER BY services_used DESC;

#5. Find customers who used multiple services:
SELECT
    user_id,
    COUNT(DISTINCT service) AS services_used
FROM transactions
GROUP BY user_id
HAVING COUNT(DISTINCT service) > 1
ORDER BY services_used DESC;

#6. Find customers who used ALL four services:
SELECT
    user_id
FROM transactions
GROUP BY user_id
HAVING COUNT(DISTINCT service) = 4;

#7. Find the top 3 customers in each service:
WITH customer_service AS (
    SELECT
        user_id,
        service,
        SUM(amount) AS total_amount
    FROM transactions
    GROUP BY user_id, service
),

ranked AS (
    SELECT
        user_id,
        service,
        total_amount,
        DENSE_RANK() OVER (
            PARTITION BY service
            ORDER BY total_amount DESC
        ) AS rnk
    FROM customer_service
)

SELECT
    user_id,
    service,
    ROUND(total_amount, 2) AS total_amount,
    rnk
FROM ranked
WHERE rnk <= 3
ORDER BY service, rnk;

#8. Find month-over-month transaction growth:
WITH monthly AS (
    SELECT
        DATE_FORMAT(transaction_date, '%Y-%m') AS month,
        SUM(amount) AS total_amount
    FROM transactions
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
)

SELECT
    month,
    ROUND(total_amount, 2) AS current_month,
    ROUND(
        LAG(total_amount) OVER (ORDER BY month),
        2
    ) AS previous_month,
    ROUND(
        100 * (
            total_amount -
            LAG(total_amount) OVER (ORDER BY month)
        ) /
        NULLIF(LAG(total_amount) OVER (ORDER BY month), 0),
        2
    ) AS growth_percentage
FROM monthly
ORDER BY month;

#9. Find customers with failed transactions but no successful transactions:
SELECT
    user_id
FROM transactions
GROUP BY user_id
HAVING
    SUM(CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END) > 0
    AND
    SUM(CASE WHEN payment_status = 'Successful' THEN 1 ELSE 0 END) = 0;
    
    #10. Find the percentage contribution of each service:
    SELECT
    service,
    ROUND(SUM(amount), 2) AS service_value,
    ROUND(
        100 * SUM(amount) /
        (SELECT SUM(amount) FROM transactions),
        2
    ) AS contribution_percentage
FROM transactions
GROUP BY service
ORDER BY contribution_percentage DESC;

#11. Find the highest-value transaction for each service:
WITH ranked AS (
    SELECT
        transaction_id,
        user_id,
        service,
        amount,
        transaction_date,
        ROW_NUMBER() OVER (
            PARTITION BY service
            ORDER BY amount DESC
        ) AS rn
    FROM transactions
)

SELECT
    transaction_id,
    user_id,
    service,
    amount,
    transaction_date
FROM ranked
WHERE rn = 1;

