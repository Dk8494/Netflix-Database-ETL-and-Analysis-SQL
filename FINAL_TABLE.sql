
CREATE TABLE ALL_SHOW_INFO AS
SELECT
    MISC.show_id,
    MOVIES.title,
    DIRECTOR.director_name,   -- From DIRECTOR table
    CAST.cast_members,        -- From CAST table
    MISC.country_name,
    TIME_INFO.date_added,
    TIME_INFO.release_year,
    RATING.rating_description, -- From RATING table
    MOVIE_INFO.duration,        -- From MOVIE_INFO table
    LISTED_IN.listed_name,     -- From LISTED_IN table
    MOVIE_DESCRIPTIONS.description,
    MISC.type_name
FROM
    MISC
JOIN MOVIES ON MISC.show_id = MOVIES.show_id
LEFT JOIN CASTING ON MISC.show_id = CASTING.show_id
LEFT JOIN DIRECTOR ON CASTING.director_id = DIRECTOR.director_id
LEFT JOIN CAST ON CASTING.cast_id = CAST.cast_id
LEFT JOIN TIME_INFO ON MISC.show_id = TIME_INFO.show_id
LEFT JOIN DATA_RATING ON MISC.show_id = DATA_RATING.show_id
LEFT JOIN RATING ON DATA_RATING.rating_id = RATING.rating_id
LEFT JOIN DATA_LISTED_IN ON MISC.show_id = DATA_LISTED_IN.show_id
LEFT JOIN LISTED_IN ON DATA_LISTED_IN.listed_id = LISTED_IN.listed_id
LEFT JOIN MOVIE_DESCRIPTIONS ON MISC.show_id = MOVIE_DESCRIPTIONS.show_id
LEFT JOIN MOVIE_INFO ON MISC.show_id = MOVIE_INFO.show_id;  -- Join with MOVIE_INFO table
