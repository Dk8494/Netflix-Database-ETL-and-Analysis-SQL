"""Extract the raw Netflix CSV into a pandas DataFrame."""

from pathlib import Path
import logging

import pandas as pd


LOGGER = logging.getLogger(__name__)


def extract_data(source_path: Path) -> pd.DataFrame:
    """Read and lightly validate the raw source file."""
    required_columns = {
        "show_id",
        "type",
        "title",
        "director",
        "cast",
        "country",
        "date_added",
        "release_year",
        "rating",
        "duration",
        "listed_in",
        "description",
    }

    try:
        data = pd.read_csv(source_path)
    except FileNotFoundError as error:
        raise FileNotFoundError(f"Source dataset not found: {source_path}") from error
    except (pd.errors.ParserError, UnicodeDecodeError) as error:
        raise ValueError(f"Could not parse source dataset: {source_path}") from error

    missing_columns = required_columns.difference(data.columns)
    if missing_columns:
        missing = ", ".join(sorted(missing_columns))
        raise ValueError(f"Source dataset is missing required columns: {missing}")

    LOGGER.info("Extracted %s rows from %s", len(data), source_path)
    return data