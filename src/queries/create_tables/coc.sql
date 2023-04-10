CREATE OR REPLACE TABLE coc as

SELECT DISTINCT * FROM read_csv_auto('../data/reference/coc.csv', header=True)