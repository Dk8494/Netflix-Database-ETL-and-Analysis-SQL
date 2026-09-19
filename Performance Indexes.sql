USE netflix_database;

CREATE INDEX idx_time_info_release_year
    ON TIME_INFO (release_year);

CREATE INDEX idx_time_info_date_added
    ON TIME_INFO (date_added);

CREATE INDEX idx_data_rating_rating_show
    ON DATA_RATING (rating_id, show_id);

CREATE INDEX idx_data_listed_in_listed_show
    ON DATA_LISTED_IN (listed_id, show_id);

CREATE INDEX idx_misc_country_type_show
    ON MISC (country_name, type_name, show_id);

CREATE INDEX idx_movie_info_show_duration
    ON MOVIE_INFO (show_id, duration);