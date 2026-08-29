USE netflix_db;

SELECT * FROM netflix_titles;

-- NETFLIX QUERIES FOR SQL PROJECT -- 

-- Q1. Count total number of Movies vs TV Shows
SELECT type, COUNT(*) AS total
FROM netflix_titles
GROUP BY type;

-- Q2. Find the top 10 countries with the most titles
SELECT country, COUNT(*) AS total_titles
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_titles DESC
LIMIT 10;

-- Q3. List the 10 most recent titles added (by date_added)
SELECT title, type, date_added
FROM netflix_titles
ORDER BY date_added DESC
LIMIT 10;

-- Q4. Find number of titles released each year, sorted by year
SELECT release_year, COUNT(*) AS total_titles
FROM netflix_titles
GROUP BY release_year
ORDER BY release_year;

-- Q5. Find all Movies with duration greater than 150 minutes
SELECT title, duration
FROM netflix_titles
WHERE type = 'Movie'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 150
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC;

-- Q6. Find TV Shows with more than 5 seasons
SELECT title, duration
FROM netflix_titles
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- Q7. Count titles by rating category
SELECT rating, COUNT(*) AS total
FROM netflix_titles
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY total DESC;

-- Q8. Find the most common genre (listed_in) combinations
SELECT listed_in, COUNT(*) AS total
FROM netflix_titles
GROUP BY listed_in
ORDER BY total DESC
LIMIT 10;

-- Q9. Find all titles directed by a specific director (parameterized example)
SELECT title, director, release_year
FROM netflix_titles
WHERE director = 'Wei Suzuki';

-- Q10. Find directors who have directed more than 5 titles
SELECT director, COUNT(*) AS total_titles
FROM netflix_titles
WHERE director IS NOT NULL
GROUP BY director
HAVING COUNT(*) > 5
ORDER BY total_titles DESC;

-- Q11. Find titles that have no director listed
SELECT title, type
FROM netflix_titles
WHERE director IS NULL;

-- Q12. Find how many titles were added to Netflix each year (date_added year)
SELECT YEAR(date_added) AS year_added, COUNT(*) AS total
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY YEAR(date_added)
ORDER BY year_added;

-- Q13. Find the percentage split of Movies vs TV Shows
SELECT
    type,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles), 2) AS percentage
FROM netflix_titles
GROUP BY type;

-- Q14. Find titles released in the last 5 years (relative to max release_year in data)
SELECT title, release_year
FROM netflix_titles
WHERE release_year >= (SELECT MAX(release_year) FROM netflix_titles) - 5
ORDER BY release_year DESC;

-- Q15. Find the longest movie in the dataset
SELECT title, duration
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

-- Q16. Find titles that belong to more than one genre
SELECT title, listed_in
FROM netflix_titles
WHERE listed_in LIKE '%,%';

-- Q17. Find the count of titles per country per type (Movie/TV Show)
SELECT country, type, COUNT(*) AS total
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY country, type
ORDER BY country, type;

-- Q18. Find titles added in a specific month/year (e.g., July 2023)
SELECT title, date_added
FROM netflix_titles
WHERE date_added BETWEEN '2023-07-01' AND '2023-07-31';

-- Q19. Find the top 5 most frequent cast members
-- (splits comma-separated cast_members; MySQL 8+ needed for recursive CTE)
WITH RECURSIVE split_cast AS (
    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(cast_members, ',', 1)) AS actor,
        SUBSTRING(cast_members, LENGTH(SUBSTRING_INDEX(cast_members, ',', 1)) + 2) AS rest
    FROM netflix_titles
    WHERE cast_members IS NOT NULL AND cast_members <> ''
    UNION ALL
    SELECT
        show_id,
        TRIM(SUBSTRING_INDEX(rest, ',', 1)),
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM split_cast
    WHERE rest <> ''
)
SELECT actor, COUNT(*) AS total_titles
FROM split_cast
WHERE actor <> ''
GROUP BY actor
ORDER BY total_titles DESC
LIMIT 5;

-- Q20. Rank titles within each release_year by title alphabetically (window function)
SELECT
    title,
    release_year,
    RANK() OVER (PARTITION BY release_year ORDER BY title) AS title_rank
FROM netflix_titles
ORDER BY release_year, title_rank
LIMIT 50;

-- Q21. Find the running total of titles added over time
SELECT
    date_added,
    COUNT(*) AS titles_that_day,
    SUM(COUNT(*)) OVER (ORDER BY date_added) AS running_total
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY date_added
ORDER BY date_added;

-- Q22. Find each country's most common genre
SELECT country, listed_in, total
FROM (
    SELECT
        country,
        listed_in,
        COUNT(*) AS total,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY COUNT(*) DESC) AS rn
    FROM netflix_titles
    WHERE country IS NOT NULL
    GROUP BY country, listed_in
) ranked
WHERE rn = 1
ORDER BY total DESC;

-- Q23. Find titles where description mentions a keyword (e.g., 'family')
SELECT title, description
FROM netflix_titles
WHERE description LIKE '%family%';

-- Q24. Compare average movie duration by release decade
SELECT
    (release_year DIV 10) * 10 AS decade,
    ROUND(AVG(CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED)), 1) AS avg_duration_min
FROM netflix_titles
WHERE type = 'Movie'
GROUP BY decade
ORDER BY decade;

-- Q25. Find the number of unique genres in the dataset
SELECT COUNT(DISTINCT listed_in) AS unique_genre_combinations
FROM netflix_titles;

