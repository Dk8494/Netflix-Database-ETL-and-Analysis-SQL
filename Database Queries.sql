-- 1. Trend Analysis of Genres Over Time
WITH genre_counts AS (
    SELECT
        t.release_year,
        l.listed_name,
        COUNT(*) AS total_titles
    FROM DATA_LISTED_IN AS dli
    JOIN LISTED_IN AS l ON dli.listed_id = l.listed_id
    JOIN TIME_INFO AS t ON dli.show_id = t.show_id
    GROUP BY t.release_year, l.listed_name
)
SELECT
    release_year,
    listed_name,
    total_titles,
    RANK() OVER (
        PARTITION BY release_year
        ORDER BY total_titles DESC
    ) AS genre_rank
FROM genre_counts
ORDER BY release_year, genre_rank, listed_name;

-- 2. Rating Distribution by Genre and Release Year
SELECT
    t.release_year,
    l.listed_name AS genre,
    r.rating_description,
    COUNT(DISTINCT dr.show_id) AS total_titles
FROM DATA_RATING AS dr
JOIN RATING AS r ON dr.rating_id = r.rating_id
JOIN TIME_INFO AS t ON dr.show_id = t.show_id
JOIN DATA_LISTED_IN AS dli ON dr.show_id = dli.show_id
JOIN LISTED_IN AS l ON dli.listed_id = l.listed_id
GROUP BY t.release_year, l.listed_name, r.rating_description
ORDER BY t.release_year DESC, total_titles DESC, l.listed_name;

-- 3. Average Movie Duration by Genre
SELECT
    l.listed_name AS genre,
    ROUND(AVG(CAST(REGEXP_SUBSTR(mi.duration, '^[0-9]+') AS UNSIGNED)), 1)
        AS average_duration_minutes
FROM MOVIE_INFO AS mi
JOIN MISC AS m ON mi.show_id = m.show_id AND m.type_name = 'Movie'
JOIN DATA_LISTED_IN AS dli ON mi.show_id = dli.show_id
JOIN LISTED_IN AS l ON dli.listed_id = l.listed_id
WHERE mi.duration REGEXP '^[0-9]+[[:space:]]+min$'
GROUP BY l.listed_name
ORDER BY average_duration_minutes DESC, l.listed_name;

-- 4. Content Volume by Genre and Release Year
SELECT
    l.listed_name AS genre,
    t.release_year,
    COUNT(*) AS total_titles
FROM DATA_LISTED_IN AS dli
JOIN LISTED_IN AS l ON dli.listed_id = l.listed_id
JOIN TIME_INFO AS t ON dli.show_id = t.show_id
GROUP BY l.listed_name, t.release_year
ORDER BY t.release_year DESC, total_titles DESC, l.listed_name;

-- 5. Detailed Market Analysis
SELECT
    country_name,
    type_name,
    COUNT(*) AS total_titles
FROM MISC
WHERE country_name IS NOT NULL
GROUP BY country_name, type_name
ORDER BY total_titles DESC, country_name;

-- 6. Release Timing Optimization with Genre Focus
SELECT
    MONTH(t.date_added) AS release_month,
    l.listed_name AS genre,
    COUNT(*) AS total_releases
FROM TIME_INFO AS t
JOIN DATA_LISTED_IN AS dli ON t.show_id = dli.show_id
JOIN LISTED_IN AS l ON dli.listed_id = l.listed_id
WHERE t.date_added IS NOT NULL
GROUP BY MONTH(t.date_added), l.listed_name
ORDER BY total_releases DESC, release_month, l.listed_name;

-- 7. Content Longevity Analysis
SELECT
    t.release_year,
    YEAR(t.date_added) AS year_added,
    COUNT(*) AS total_titles,
    ROUND(AVG(YEAR(t.date_added) - t.release_year), 1) AS average_years_to_add
FROM TIME_INFO AS t
WHERE t.date_added IS NOT NULL
GROUP BY t.release_year, YEAR(t.date_added)
ORDER BY t.release_year, year_added;

-- 8. In-Depth Localization Strategy
SELECT
    m.country_name,
    l.listed_name AS genre,
    COUNT(*) AS total_titles
FROM MISC AS m
JOIN DATA_LISTED_IN AS dli ON m.show_id = dli.show_id
JOIN LISTED_IN AS l ON dli.listed_id = l.listed_id
WHERE m.country_name IS NOT NULL
GROUP BY m.country_name, l.listed_name
ORDER BY m.country_name, total_titles DESC, l.listed_name;

-- 9. Budget Allocation for Movie Genres
SELECT
    l.listed_name AS genre,
    COUNT(*) AS total_movies,
    ROUND(AVG(CAST(REGEXP_SUBSTR(mi.duration, '^[0-9]+') AS UNSIGNED)), 1)
        AS average_duration_minutes
FROM DATA_LISTED_IN AS dli
JOIN LISTED_IN AS l ON dli.listed_id = l.listed_id
JOIN MOVIE_INFO AS mi ON dli.show_id = mi.show_id
JOIN MISC AS m ON dli.show_id = m.show_id AND m.type_name = 'Movie'
WHERE mi.duration REGEXP '^[0-9]+[[:space:]]+min$'
GROUP BY l.listed_name
ORDER BY total_movies DESC, average_duration_minutes DESC, l.listed_name;
