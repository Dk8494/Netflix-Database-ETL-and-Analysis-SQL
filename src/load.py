"""Load transformed data into SQLite using the SQL schema."""

from pathlib import Path
import logging
import sqlite3

import pandas as pd


LOGGER = logging.getLogger(__name__)


def load_data(data: pd.DataFrame, database_path: Path, schema_path: Path) -> None:
    """Create the database tables and insert the transformed records."""
    database_path.parent.mkdir(parents=True, exist_ok=True)
    schema = schema_path.read_text(encoding="utf-8")

    ratings = (
        data[["rating"]]
        .drop_duplicates()
        .sort_values("rating")
        .reset_index(drop=True)
    )
    ratings.insert(0, "rating_id", ratings.index + 1)
    titles = data.merge(ratings, on="rating", how="left").drop(columns=["rating"])
    titles = titles.rename(columns={"rating_id": "rating_id"})

    with sqlite3.connect(database_path) as connection:
        connection.executescript(schema)
        ratings.to_sql("ratings", connection, if_exists="append", index=False)
        titles.to_sql("netflix_titles", connection, if_exists="append", index=False)

        checks = connection.execute(
            """
            SELECT
                COUNT(*) AS row_count,
                COUNT(DISTINCT show_id) AS unique_show_ids,
                SUM(CASE WHEN title IS NULL OR title = '' THEN 1 ELSE 0 END) AS missing_titles
            FROM netflix_titles
            """
        ).fetchone()
        if checks[0] != checks[1] or checks[2] != 0:
            raise ValueError(f"SQL validation failed: {checks}")

    LOGGER.info("Loaded %s title rows into %s", len(titles), database_path)