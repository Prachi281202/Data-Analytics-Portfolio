USE hr_analytics;

SELECT * FROM employees;

-- HR ANALYSIS PROJECT SQL QUERIES:

-- Q1. Overall attrition rate (%)
SELECT
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS 
attrition_rate_pct
FROM employees;

-- Q2. Attrition count and rate by department
SELECT
    department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY department
ORDER BY attrition_rate_pct DESC;

-- Q3. Attrition rate by job role
SELECT
    job_role,
    COUNT(*) AS total_employees,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY job_role
ORDER BY attrition_rate_pct DESC;

-- Q4. Average monthly income by department and attrition status
SELECT department, attrition, ROUND(AVG(monthly_income), 0) AS avg_income
FROM employees
GROUP BY department, attrition
ORDER BY department, attrition;

-- Q5. Does overtime correlate with attrition?
SELECT
    over_time,
    COUNT(*) AS total,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY over_time;

-- Q6. Attrition rate by age group (bucketed)
SELECT
    CASE
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY age_group
ORDER BY age_group;

-- Q7. Average years at company for employees who left vs stayed
SELECT attrition, ROUND(AVG(years_at_company), 1) AS avg_years_at_company
FROM employees
GROUP BY attrition;

-- Q8. Attrition rate by job satisfaction level
SELECT
    job_satisfaction,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY job_satisfaction
ORDER BY job_satisfaction;

-- Q9. Employees who haven't been promoted in 5+ years, by department
SELECT department, COUNT(*) AS overdue_for_promotion
FROM employees
WHERE years_since_last_promotion >= 5
GROUP BY department
ORDER BY overdue_for_promotion DESC;

-- Q10. Top 5 highest paying job roles (avg monthly income)
SELECT job_role, ROUND(AVG(monthly_income), 0) AS avg_income
FROM employees
GROUP BY job_role
ORDER BY avg_income DESC
LIMIT 5;

-- Q11. Attrition rate by marital status
SELECT
    marital_status,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY marital_status
ORDER BY attrition_rate_pct DESC;

-- Q12. Employees earning below the department average (paid below peers)
SELECT e.employee_number, e.job_role, e.department, e.monthly_income
FROM employees e
JOIN (
    SELECT department, AVG(monthly_income) AS dept_avg
    FROM employees
    GROUP BY department
) d ON e.department = d.department
WHERE e.monthly_income < d.dept_avg
ORDER BY e.department, e.monthly_income;

-- Q13. Correlation check: distance from home vs attrition
SELECT
    CASE
        WHEN distance_from_home <= 5 THEN '0-5 km'
        WHEN distance_from_home <= 15 THEN '6-15 km'
        ELSE '16+ km'
    END AS distance_band,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY distance_band
ORDER BY distance_band;

-- Q14. Rank employees within each department by monthly income (window function)
SELECT
    employee_number, department, job_role, monthly_income,
    RANK() OVER (PARTITION BY department ORDER BY monthly_income DESC) AS income_rank
FROM employees
ORDER BY department, income_rank;

-- Q15. Attrition rate by number of companies worked at previously
SELECT
    num_companies_worked,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY num_companies_worked
ORDER BY num_companies_worked;

-- Q16. Work-life balance vs attrition
SELECT
    work_life_balance,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY work_life_balance
ORDER BY work_life_balance;

-- Q17. Gender pay gap check: average income by gender and job role
SELECT job_role, gender, ROUND(AVG(monthly_income), 0) AS avg_income
FROM employees
GROUP BY job_role, gender
ORDER BY job_role, gender;

-- Q18. High performers (rating 4) who still left the company
SELECT employee_number, job_role, department, performance_rating, monthly_income
FROM employees
WHERE performance_rating = 4 AND attrition = 'Yes';

-- Q19. Average training sessions last year, by attrition status
SELECT attrition, ROUND(AVG(training_times_last_year), 2) AS avg_trainings
FROM employees
GROUP BY attrition;

-- Q20. Business travel frequency vs attrition rate
SELECT
    business_travel,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY business_travel
ORDER BY attrition_rate_pct DESC;

-- Q21. Identify a simple "at risk" segment: low satisfaction + overtime + short tenure
SELECT employee_number, department, job_role, job_satisfaction, over_time, years_at_company
FROM employees
WHERE job_satisfaction <= 2
  AND over_time = 'Yes'
  AND years_at_company <= 3
  AND attrition = 'No'
ORDER BY department;

-- Q22. Environment satisfaction distribution among those who left
SELECT environment_satisfaction, COUNT(*) AS total_left
FROM employees
WHERE attrition = 'Yes'
GROUP BY environment_satisfaction
ORDER BY environment_satisfaction;

-- Q23. Average years with current manager, stayed vs left
SELECT attrition, ROUND(AVG(years_with_curr_manager), 1) AS avg_years_with_manager
FROM employees
GROUP BY attrition;

-- Q24. Stock option level vs attrition rate
SELECT
    stock_option_level,
    COUNT(*) AS total,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct
FROM employees
GROUP BY stock_option_level
ORDER BY stock_option_level;

-- Q25. Overall summary dashboard query (single row of key HR metrics)
SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS total_attrition,
    ROUND(SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_pct,
    ROUND(AVG(age), 1) AS avg_age,
    ROUND(AVG(monthly_income), 0) AS avg_monthly_income,
    ROUND(AVG(years_at_company), 1) AS avg_tenure_years
FROM employees;












