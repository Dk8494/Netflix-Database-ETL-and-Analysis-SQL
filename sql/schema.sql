PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS netflix_titles;
DROP TABLE IF EXISTS ratings;

CREATE TABLE ratings (
    rating_id INTEGER PRIMARY KEY,
    rating TEXT NOT NULL UNIQUE
);

CREATE TABLE netflix_titles (
    show_id TEXT PRIMARY KEY,
    type TEXT NOT NULL CHECK (type IN ('Movie', 'TV Show')),
    title TEXT NOT NULL,
    director TEXT NOT NULL,
    cast_members TEXT NOT NULL,
    country TEXT NOT NULL,
    date_added TEXT,
    release_year INTEGER,
    rating_id INTEGER,
    duration TEXT NOT NULL,
    duration_value INTEGER,
    duration_unit TEXT NOT NULL,
    listed_in TEXT NOT NULL,
    description TEXT NOT NULL,
    FOREIGN KEY (rating_id) REFERENCES ratings (rating_id)
);

CREATE INDEX idx_netflix_titles_type ON netflix_titles (type);
CREATE INDEX idx_netflix_titles_release_year ON netflix_titles (release_year);
CREATE INDEX idx_netflix_titles_rating_id ON netflix_titles (rating_id);