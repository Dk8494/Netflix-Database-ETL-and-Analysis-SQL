-- 1. Content volume by type and rating. Demonstrates a dimension join and aggregation.
SELECT
    t.type,
    r.rating,
    COUNT(*) AS title_count
FROM netflix_titles AS t
JOIN ratings AS r ON r.rating_id = t.rating_id
GROUP BY t.type, r.rating
ORDER BY title_count DESC, t.type, r.rating;

-- 2. Rank the most productive release years within each content type.
WITH yearly_titles AS (
    SELECT type, release_year, COUNT(*) AS title_count
    FROM netflix_titles
    WHERE release_year IS NOT NULL
    GROUP BY type, release_year
)
SELECT
    type,
    release_year,
    title_count,
    RANK() OVER (PARTITION BY type ORDER BY title_count DESC) AS year_rank
FROM yearly_titles
ORDER BY type, year_rank, release_year;

-- 3. Average movie duration by rating using a common table expression.
WITH movie_durations AS (
    SELECT rating_id, duration_value
    FROM netflix_titles
    WHERE type = 'Movie' AND duration_unit = 'min' AND duration_value IS NOT NULL
)
SELECT
    r.rating,
    COUNT(*) AS movie_count,
    ROUND(AVG(m.duration_value), 1) AS average_duration_minutes
FROM movie_durations AS m
JOIN ratings AS r ON r.rating_id = m.rating_id
GROUP BY r.rating
ORDER BY average_duration_minutes DESC, r.rating;

-- 4. Titles added to the platform by year.
SELECT
    substr(date_added, 1, 4) AS added_year,
    type,
    COUNT(*) AS title_count
FROM netflix_titles
WHERE date_added IS NOT NULL
GROUP BY added_year, type
ORDER BY added_year, type;