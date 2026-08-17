-- ============================================
-- SAMPLE ANALYSIS QUERIES
-- ============================================

-- 1. Most liked posts
SELECT p.post_id, p.content, COUNT(l.like_id) AS total_likes
FROM posts p
LEFT JOIN likes l ON p.post_id = l.post_id
GROUP BY p.post_id
ORDER BY total_likes DESC
LIMIT 10;

-- 2. Most active users (posts + comments + likes given)
SELECT u.username,
       COUNT(DISTINCT p.post_id) AS posts,
       COUNT(DISTINCT c.comment_id) AS comments,
       COUNT(DISTINCT l.like_id) AS likes_given
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
LEFT JOIN comments c ON u.user_id = c.user_id
LEFT JOIN likes l ON u.user_id = l.user_id
GROUP BY u.username
ORDER BY posts DESC;

-- 3. Follower count per user (top 10)
SELECT u.username, COUNT(f.follower_id) AS followers
FROM users u
LEFT JOIN follows f ON u.user_id = f.following_id
GROUP BY u.username
ORDER BY followers DESC
LIMIT 10;

-- 4. Engagement rate per post (likes + comments)
SELECT p.post_id, p.content,
       COUNT(DISTINCT l.like_id) AS likes,
       COUNT(DISTINCT c.comment_id) AS comments,
       (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) AS engagement
FROM posts p
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id
ORDER BY engagement DESC
LIMIT 10;

-- 5. Users who never posted anything
SELECT username FROM users
WHERE user_id NOT IN (SELECT DISTINCT user_id FROM posts);

-- 6. Monthly post count trend
SELECT DATE_FORMAT(post_date, '%Y-%m') AS month, COUNT(*) AS total_posts
FROM posts
GROUP BY month
ORDER BY month;

-- 7. Top country by number of users
SELECT country, COUNT(*) AS total_users
FROM users
GROUP BY country
ORDER BY total_users DESC;

-- 8. Users ranked by engagement using window function
SELECT username, total_engagement,
       RANK() OVER (ORDER BY total_engagement DESC) AS engagement_rank
FROM (
    SELECT u.username,
           (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) AS total_engagement
    FROM users u
    LEFT JOIN posts p ON u.user_id = p.user_id
    LEFT JOIN likes l ON p.post_id = l.post_id
    LEFT JOIN comments c ON p.post_id = c.post_id
    GROUP BY u.username
) t
ORDER BY engagement_rank
LIMIT 10;

-- 9. Mutual followers (users who follow each other)
SELECT f1.follower_id AS user_a, f1.following_id AS user_b
FROM follows f1
JOIN follows f2 ON f1.follower_id = f2.following_id AND f1.following_id = f2.follower_id
WHERE f1.follower_id < f1.following_id;

-- 10. Post type distribution
SELECT post_type, COUNT(*) AS total, ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM posts), 2) AS pct
FROM posts
GROUP BY post_type;