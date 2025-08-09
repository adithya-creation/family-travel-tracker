-- Analytical queries to showcase SQL proficiency

-- 1) Top travelers by number of countries visited
SELECT u.name, COUNT(vc.country_code) AS visited_count
FROM users u
JOIN visited_countries vc ON vc.user_id = u.id
GROUP BY u.name
ORDER BY visited_count DESC;

-- 2) Users with zero visits
SELECT u.*
FROM users u
LEFT JOIN visited_countries vc ON vc.user_id = u.id
WHERE vc.user_id IS NULL;

-- 3) Most recently recorded visits
SELECT u.name, vc.country_code, vc.visited_at
FROM visited_countries vc
JOIN users u ON u.id = vc.user_id
ORDER BY vc.visited_at DESC
LIMIT 10;

-- 4) Coverage percentage per user (relative to total known countries)
SELECT
  u.name,
  COUNT(vc.country_code) AS visited,
  (SELECT COUNT(*) FROM countries) AS total,
  ROUND(100.0 * COUNT(vc.country_code) / NULLIF((SELECT COUNT(*) FROM countries), 0), 2) AS percent
FROM users u
LEFT JOIN visited_countries vc ON vc.user_id = u.id
GROUP BY u.name
ORDER BY percent DESC NULLS LAST;

-- 5) Visits by country with visitor counts
SELECT c.country_code, c.country_name, COUNT(vc.user_id) AS visitors
FROM countries c
LEFT JOIN visited_countries vc ON vc.country_code = c.country_code
GROUP BY c.country_code, c.country_name
ORDER BY visitors DESC, c.country_name; 