CREATE OR REPLACE TABLE cln_referrals as 

    SELECT DISTINCT * 
    FROM read_parquet('../data/clean_referrals/*.parquet')