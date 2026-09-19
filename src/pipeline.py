"""Run the complete Netflix extract, transform, and load workflow."""

from pathlib import Path
import argparse
import logging

from .extract import extract_data
from .load import load_data
from .transform import transform_data


LOGGER = logging.getLogger(__name__)


def main() -> None:
    project_root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description="Run the Netflix ETL pipeline")
    parser.add_argument(
        "--source", type=Path, default=project_root / "data" / "netflix_titles.csv"
    )
    parser.add_argument(
        "--database", type=Path, default=project_root / "data" / "netflix.db"
    )
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s - %(message)s",
    )

    try:
        extracted = extract_data(args.source)
        transformed = transform_data(extracted)
        processed_path = project_root / "data" / "processed" / "netflix_titles_clean.csv"
        processed_path.parent.mkdir(parents=True, exist_ok=True)
        transformed.to_csv(processed_path, index=False)
        load_data(transformed, args.database, project_root / "sql" / "schema.sql")
        LOGGER.info("ETL pipeline completed successfully")
    except (FileNotFoundError, ValueError, OSError) as error:
        LOGGER.error("ETL pipeline failed: %s", error)
        raise SystemExit(1) from error