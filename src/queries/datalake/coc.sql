SELECT DISTINCT
  member_id
  , health_plan
  , LEFT(year_month, 4) as year_ym
  , RIGHT(year_month, 2) as month_ym
  , care_partner_name
  , care_partner_group

FROM nh_analytics_reporting.cedargate_coc 

WHERE datasource = 'membership'
  AND year_month like "2023%"