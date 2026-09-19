# Netflix Data Engineering ETL Project

## Project Objective
This project demonstrates a small, executable data engineering workflow for the Netflix titles dataset. It uses Python and Pandas for extraction and transformation, SQLite for a local SQL load, and SQL for validation and analysis.

The original normalized MySQL schema and reporting queries remain in the repository. The new pipeline is a simple portfolio-friendly path that can run locally without a database server.

## ETL Architecture
```text
CSV -> Python Extract -> Python Transform -> SQL Load -> SQL Analysis
```

The source file is `data/netflix_titles.csv`. The pipeline writes the cleaned CSV to `data/processed/netflix_titles_clean.csv` and the loaded SQLite database to `data/netflix.db`.

## Project Structure
```text
data/netflix_titles.csv       Raw Netflix source dataset
src/extract.py                CSV extraction and source validation
src/transform.py              Cleaning, typing, deduplication, validation
src/load.py                   SQLite schema execution and data loading
src/pipeline.py               ETL orchestration and logging
sql/schema.sql                SQLite tables, constraints, and indexes
sql/analysis.sql              Joins, aggregations, CTEs, and window functions
pipeline.py                   Root command-line entry point
```

## Extract Process
`src/extract.py` reads the CSV with Pandas and checks that the expected Netflix title columns exist. Parsing and missing-file errors are reported through the pipeline logger.

## Transformations
`src/transform.py`:
- Standardizes column names to lowercase snake case.
- Renames `cast` to `cast_members`.
- Removes duplicate records and duplicate `show_id` values.
- Replaces missing text values with empty strings.
- Converts `date_added` to ISO dates and `release_year` to integers.
- Splits duration into numeric `duration_value` and `duration_unit` fields.
- Validates required identifiers, title values, content types, unique IDs, and release-year ranges.

## SQL Database Structure
The SQLite database contains:
- `ratings`: a rating lookup table with a numeric key.
- `netflix_titles`: one row per title with a foreign key to `ratings`.

The schema adds constraints and indexes for content type, release year, and rating joins. The existing MySQL design is defined separately in `ALL_TOGETHER.sql` and is preserved for the original normalized analysis.

## Load Process
`src/load.py` executes `sql/schema.sql`, loads the rating dimension and cleaned title data with Pandas, then runs SQL checks for row-count consistency, unique IDs, and missing titles. The SQLite database is recreated on each pipeline run so the result is repeatable.

## SQL Analysis
Run `sql/analysis.sql` against `data/netflix.db` to see:
- Rating and content-type aggregations using a join.
- Release-year ranking by content type using a window function.
- Average movie durations using a CTE and aggregation.
- Titles added by year and content type.

The existing MySQL reporting queries remain in `Database Queries.sql` and continue to demonstrate the original dataset analysis, including joins, aggregations, CTEs, and window functions.

## How to Run
Install the only external dependency:
```bash
python -m pip install -r requirements.txt
```

Run the complete pipeline from the project root:
```bash
python pipeline.py
```

Inspect the loaded SQLite database with the SQLite command-line client:
```bash
sqlite3 data/netflix.db < sql/analysis.sql
```

The original MySQL scripts require MySQL 8.0 or later and remain available for the normalized SQL project. The reporting queries use common table expressions, window functions, and `REGEXP_SUBSTR`.

## Database Structure
The database consists of multiple tables, each representing a specific aspect of the Netflix dataset. The tables are normalized to reduce redundancy and improve data integrity. The final table, `ALL_SHOW_INFO`, combines data from all these tables to provide a comprehensive overview of the dataset.

### Tables in the Database:
- `MOVIES`: Contains movie titles and their IDs.
- `DIRECTOR`: Stores director names and their IDs.
- `CAST`: Lists cast members and their IDs.
- `MISC`: Includes miscellaneous information like country and type.
- `TIME_INFO`: Contains time-related data such as date added and release year.
- `RATING`: Stores rating descriptions and their IDs.
- `LISTED_IN`: Lists genres/categories and their IDs.
- `MOVIE_DESCRIPTIONS`: Provides descriptions of shows and movies.
- `MOVIE_INFO`: Contains additional movie information like duration.
- `DATA_RATING`: Links shows to their ratings.
- `DATA_LISTED_IN`: Links shows to their genres/categories.
- `CASTING`: Connects shows to their directors and cast members.

The `ALL_SHOW_INFO` table is a comprehensive table that combines data from all the above tables using SQL joins. It includes fields like show ID, title, director name, cast members, country, date added, release year, rating description, duration, genre, description, and type.

## Usage Instructions
1. **ALL_TOGETHER.sql**: Run this file first to create the entire database with all the individual tables.
2. **Performance Indexes.sql**: Run this after the schema and data load to add indexes used by the reporting joins.
3. **final_TABLE.sql**: Execute this file to create the `ALL_SHOW_INFO` table, which consolidates all fields into a single table.
4. **Database_queries.sql**: Run the analysis queries after the database and indexes have been created.

This README is intended to provide a comprehensive guide to understanding and navigating the database created from the Netflix dataset. Each step is crucial for the proper setup and viewing of the data within the SQL environment.

## Performance Notes

`Performance Indexes.sql` adds indexes for release-year and date-added reports, the two many-to-many bridge tables, country/type aggregation, and movie-duration analysis. Apply these indexes after loading the data so the joins in `Database Queries.sql` can use the indexed keys.

## Reporting Query Catalog

The first three reports cover genre trends, rating distribution, and average movie duration. The genre trend report pre-aggregates counts before applying its window ranking, while the duration report excludes TV seasons from movie-minute averages.

Reports four through six cover content volume by release year, market distribution by country and type, and release timing by month and genre. Null countries and dates are excluded where they cannot support a meaningful comparison.

Reports seven through nine cover time-to-platform analysis, localization by country and genre, and movie-duration planning by genre. Rating IDs are treated as categorical keys and are joined to `RATING` when a rating label is needed.

The Entity-Relationship Diagram (ERD) below visually represents the structure and interconnections of the various tables within the database. This diagram illustrates how data is organized and related across different aspects of the Netflix shows and movies dataset. (Once I have time I will combine several tables into one such as a single MOVIES table which would contain show_id, title, description, duration, etc.)  
  
<img width="1728" alt="image" src="https://github.com/miniquinox/Netflix-Database-SQL/assets/63688331/d9f5a8b6-50ba-4197-b7a5-fb48fd73a552">  
  
## Potential Business Questions

This Netflix shows and movies database can address various business problems. Below are some potential business questions and the corresponding SQL queries that can provide insights:

### Content Strategy Development
- **Problem**: Determining which genres or types of content are most popular to inform future content acquisition or production.
- **Query**: Analyze the distribution of shows/movies across different genres (`LISTED_IN`) and ratings (`RATING`) to identify popular categories.

### Market Analysis
- **Problem**: Understanding the distribution of content across different countries to tailor marketing strategies.
- **Query**: Aggregate the number of shows/movies by country (`MISC.country_name`) to see which regions have the most content.

### Release Timing Optimization
- **Problem**: Identifying the best time of year to release new content.
- **Query**: Examine trends in `date_added` (from `TIME_INFO`) to see which months or seasons have historically had the most releases.

### Director and Cast Analysis
- **Problem**: Finding successful director and cast combinations for future projects.
- **Query**: Analyze the past collaborations between directors (`DIRECTOR`) and cast members (`CAST`) that led to highly-rated or popular shows/movies.

### Viewer Preferences Study
- **Problem**: Understanding viewer preferences based on historical data.
- **Query**: Correlate the genres (`LISTED_IN`) and ratings (`RATING`) of shows/movies with their release years (`TIME_INFO.release_year`) to spot trends over time.

### Content Longevity Analysis
- **Problem**: Assessing which types of content remain relevant or popular for longer periods.
- **Query**: Compare the release year (`TIME_INFO.release_year`) and the date added to the platform (`TIME_INFO.date_added`) to determine content longevity.

### Localization Strategy
- **Problem**: Tailoring content and marketing strategies for specific countries.
- **Query**: Identify the most common genres (`LISTED_IN`) and types (`MISC.type_name`) of shows/movies in specific countries (`MISC.country_name`).

### Budget Allocation for New Productions
- **Problem**: Determining which types of content warrant higher investment.
- **Query**: Assess the correlation between content genres (`LISTED_IN`) and their ratings/popularity to allocate budget effectively.

These queries leverage the rich data available in this Netflix shows and movies database to guide decision-making in content strategy, marketing, production, and more.

