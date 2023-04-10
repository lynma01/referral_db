CREATE OR REPLACE TABLE team as 

SELECT DISTINCT * FROM read_csv_auto('../data/reference/user_list.csv', header=True)