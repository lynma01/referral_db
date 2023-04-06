CREATE OR REPLACE TABLE bi_referrals as

    SELECT DISTINCT *
    , COALESCE(tm.Team, 'N/A') as User_Team

    , UPPER("Last Name") || UPPER("First Name") as patient_name

    , UPPER("Last Name") || UPPER("First Name") || "DOB" as patient_id

    , patient_id || coalesce("Plan ID", 'NA') || coalesce("Referring Provider NPI", 'NA') || "Referral Date" || coalesce("Procedure", 'NA') || coalesce(Specialty, 'NA') as Referral_keyid

    , CASE
        WHEN "Approval Status" IN ('No HP Auth Required', 'HP Approved', 'Approved (comments required)', 'Complete/no Auth# needed')  
            AND "Visit Status" IN ('Appointment Scheduled', 'Member to Schedule', 'Unable to Contact', 'Denied', 'Withdrawn')
            THEN 'Completed'
        WHEN "Approval Status" IN ('Denied- Per Insurance Plan', 'Denied- Per Medical Director Review')
            AND "Visit Status" = 'Open'
            THEN 'Completed'
        ELSE "Referral Status" END as "Updated Status"

    , RIGHT("Procedure", 5) as Proc_code
    , pc.code_short_description as Proc_name 

    , FORMAT(
        '({}) {}-{}'
        , substring("Mobile Phone", 1, 3), substring("Mobile Phone", 3, 3), substring("Mobile Phone", 6, 4)
    ) as "Fmt Mobile Phone"

    , FORMAT(
        '({}) {}-{}'
        , substring("Home Phone", 1, 3), substring("Home Phone", 3, 3), substring("Home Phone", 6, 4)
    ) as "Fmt Home Phone"

    , icd.code_long_description AS "Diagnosis Description"

    FROM cln_referrals AS rf

    LEFT JOIN icd10cm AS icd
        ON trim(rf."Diagnosis") = trim(icd.code_value)

    LEFT JOIN hcpcs AS pc
        on RIGHT("Procedure", 5) = pc.code_value

    LEFT JOIN team as tm
        on  "User_FName" = tm.FName
        AND "User_LName" = tm.LName

    WHERE "Visit Status" IS NOT NULL