"""Clean and validate the extracted Netflix data."""

import logging
import re

import pandas as pd


LOGGER = logging.getLogger(__name__)


def _standardize_column_names(data: pd.DataFrame) -> pd.DataFrame:
    cleaned = data.copy()
    cleaned.columns = [
        re.sub(r"[^a-z0-9]+", "_", column.strip().lower()).strip("_")
        for column in cleaned.columns
    ]
    return cleaned.rename(columns={"cast": "cast_members"})


def transform_data(data: pd.DataFrame) -> pd.DataFrame:
    """Return a deduplicated, typed, analytics-ready DataFrame."""
    cleaned = _standardize_column_names(data)
    original_count = len(cleaned)

    cleaned = cleaned.drop_duplicates()
    cleaned = cleaned.drop_duplicates(subset=["show_id"], keep="first")

    text_columns = [
        "director",
        "cast_members",
        "country",
        "rating",
        "duration",
        "listed_in",
        "description",
    ]
    for column in text_columns:
        cleaned[column] = cleaned[column].fillna("").astype(str).str.strip()

    cleaned["date_added"] = pd.to_datetime(
        cleaned["date_added"], errors="coerce"
    ).dt.strftime("%Y-%m-%d")
    cleaned["release_year"] = pd.to_numeric(
        cleaned["release_year"], errors="coerce"
    ).astype("Int64")
    cleaned["duration_value"] = pd.to_numeric(
        cleaned["duration"].str.extract(r"^(\d+)")[0], errors="coerce"
    ).astype("Int64")
    cleaned["duration_unit"] = (
        cleaned["duration"].str.extract(r"\d+\s*(min|season|seasons)\b", expand=False)
        .fillna("unknown")
        .str.lower()
        .replace({"seasons": "season"})
    )

    validation_errors = []
    if cleaned["show_id"].isna().any() or cleaned["show_id"].eq("").any():
        validation_errors.append("show_id contains null or empty values")
    if cleaned["title"].isna().any() or cleaned["title"].eq("").any():
        validation_errors.append("title contains null or empty values")
    if not cleaned["show_id"].is_unique:
        validation_errors.append("show_id values are not unique")
    if not cleaned["type"].isin(["Movie", "TV Show"]).all():
        validation_errors.append("type contains values other than Movie or TV Show")
    if cleaned["release_year"].notna().any() and not cleaned["release_year"].dropna().between(1900, 2100).all():
        validation_errors.append("release_year contains values outside 1900-2100")

    if validation_errors:
        raise ValueError("Data validation failed: " + "; ".join(validation_errors))

    LOGGER.info(
        "Transformed %s rows into %s unique analytics-ready rows",
        original_count,
        len(cleaned),
    )
    return cleaned