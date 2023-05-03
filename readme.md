# Local Datalake - Referrals
This repository is a demonstration of how to create a localized datalake for referrals data. This repository *only* includes the python and sql code required to extract, transform, and load the data into a reportable format.

## Data Refresh Process:
1. Run ![clean_to_file.ipynb](src/clean_to_file.ipynb) which
    - ingests all excel referral files within 'data/raw_referrals/excels'
        - sequentially runs all .sql files in 'src/queries'
    - creates Apache Spark parquet snapshot files in 'data/clean_referrals'
    - combines and synthesizes all parquet files into 'data/report_data' [YYYY-MM-DD].parquet files for reporting within PowerBI

## Querying/Adding Transformations
1. Use the ![jupysql.ipynb](src/jupysql.ipynb) as a notebook for querying data within the ![DuckDB database file](data/referral.db). 