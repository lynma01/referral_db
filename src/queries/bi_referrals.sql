CREATE OR REPLACE TABLE bi_referrals AS 

WITH main AS (

    SELECT DISTINCT rf.*
    , COALESCE(tm.Team, 'N/A') AS User_Team

    , UPPER("Last Name") || UPPER("First Name") AS patient_name

    , UPPER("Last Name") || UPPER("First Name") || "DOB" AS patient_id

    , patient_id || "Referring Provider NPI" || "Referral Date" || coalesce("Diagnosis", 'NA') || coalesce("Specialty", 'NA') AS Referral_keyid

    , CASE
        WHEN "Approval Status" IN ('No HP Auth Required', 'HP Approved', 'Approved (comments required)', 'Complete/no Auth# needed')  
            AND "Visit Status" IN ('Appointment Scheduled', 'Member to Schedule', 'Unable to Contact', 'Denied', 'Withdrawn')
            THEN 'Completed'
        WHEN "Approval Status" IN ('Denied- Per Insurance Plan', 'Denied- Per Medical Director Review')
            AND "Visit Status" = 'Open'
            THEN 'Completed'
        ELSE "Referral Status" END AS "Updated Status"

    , RIGHT("Procedure", 5) AS Proc_code
    , pc.code_short_description AS Proc_name 

    , FORMAT(
        '({}) {}-{}'
        , substring("Mobile Phone", 1, 3), substring("Mobile Phone", 3, 3), substring("Mobile Phone", 6, 4)
    ) AS "Fmt Mobile Phone"

    , FORMAT(
        '({}) {}-{}'
        , substring("Home Phone", 1, 3), substring("Home Phone", 3, 3), substring("Home Phone", 6, 4)
    ) AS "Fmt Home Phone"

    , REPLACE(REPLACE(REPLACE(REGEXP_REPLACE(UPPER("Health Plan"), '[(*)]', ' ', 'g'), '-', ' '), '  ', ' '), '  ', ' ') AS "Health Plan FMT"

    , regexp_replace(array_slice(Address, -9, -7), '[0-9]', '', 'g') AS STATE

    , array_slice(Address, -5, NULL) as ZIPCODE

    , icd.code_long_description AS "Diagnosis Description"

    FROM cln_referrals AS rf

    LEFT JOIN icd10cm AS icd
        ON trim(rf."Diagnosis") = trim(icd.code_value)

    LEFT JOIN hcpcs AS pc
        ON RIGHT("Procedure", 5) = pc.code_value

    LEFT JOIN team AS tm
        ON "User_FName" = tm.Fname
        AND "User_LName" = tm.Lname

    WHERE "Visit Status" IS NOT NULL
)

, max_updatedt AS (
    SELECT DISTINCT
        Referral_keyid
        , Update_DT
        , MAX(Update_DT) OVER (PARTITION BY Referral_keyid) as Last_UpdateDT

    FROM main 
)

, condense_dates AS (
    SELECT DISTINCT m.* 

    FROM main AS m

    INNER JOIN max_updatedt as dt
        ON m.Update_DT = dt.Last_UpdateDT
        AND m.Referral_keyid = dt.Referral_keyid
)

, gatekeeper as (
    SELECT DISTINCT 
        cd.* 
        , hp.GATEKEEPER

    FROM condense_dates AS cd

    LEFT JOIN health_plan AS hp
        ON cd.STATE = hp.STATE
        AND cd.LOB = hp.LOB
        AND cd."Health Plan FMT" = hp.HEALTH_PLAN
)

SELECT DISTINCT * FROM gatekeeper