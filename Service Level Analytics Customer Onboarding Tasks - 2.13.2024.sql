

--SERVICE LEVEL ANALYTICS TASKS

USE ROLE SBX_EA_GENERAL_FR;
USE DATABASE SBX_PSAS_DB;
USE SCHEMA SALES_OPS_GOV;
USE WAREHOUSE SBX_EA_GENERAL_FR_WH;

--SHOW TASKS LIKE 'TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_CUST%'
--DESC TASK TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_CUST
-- select *  from table(SBX_PSAS_DB.INFORMATION_SCHEMA.task_history(
--     scheduled_time_range_start=>dateadd('hour',-24,current_timestamp()),
--     result_limit => 10,
--     task_name=>'TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_CUST'));
    
--alter task TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_CUST resume; --It was by default suspended  ( run this command Only first time since by default its suspended)
--execute task TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_CUST 

--TASK
CREATE OR REPLACE TASK TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_CUST

WAREHOUSE = SBX_EA_GENERAL_FR_WH
SCHEDULE = 'USING CRON 51 7 * * 1-5 America/Chicago' 
TIMESTAMP_INPUT_FORMAT = 'YYYY-MM-DD HH24'
AS

--FINAL PULL | ADD GLN DETAILS & SALES REP
CREATE OR REPLACE TABLE SBX_PSAS_DB.SALES_OPS_GOV.T_SERVICE_LEVEL_ONBOARDING_DASHBOARD_CUSTOMERS AS


--COMBINE CUSTOMER DATA FOR CPH & MHS
WITH ONBOARD AS (


SELECT * FROM SBX_PSAS_DB.ANALYTICS.SERVICE_LEVEL_INPUT_CPH
-- UNION ALL

-- SELECT * FROM SBX_PSAS_DB.ANALYTICS.SERVICE_LEVEL_INPUT_MHS;
)

--FIND FIRST ORDER DATE OF AN ACCOUNT
, START_DATE AS (

SELECT  CUST.CUST_ACCT_ID,
        MIN(CAL_CYMD) AS START_DT
FROM    PRD_PSAS_DB.RPT.T_SLA_CUST_ORD_DTL ORD
JOIN    PRD_PSAS_DB.RPT.T_SLA_CUST_ACCT CUST
ON      ORD.CUST_ACCT_SURR_KEY = CUST.CUST_ACCT_SURR_KEY
JOIN    ONBOARD
ON      LTRIM(CUST.CUST_ACCT_ID,'0') = LTRIM(ONBOARD.CUST_ACCT_ID,'0')
WHERE   ORD.ORDR_QTY > 0
AND     CAL_CYMD >= '2022-09-01'
GROUP BY  CUST.CUST_ACCT_ID)


-- CREATE OR REPLACE TEMPORARY TABLE CAL AS 

-- SELECT  CAL_DT 
-- FROM    SBX_PSAS_DB.GX_DA.T_CAL
-- WHERE   CAL_DT BETWEEN (SELECT MIN(START_DT FROM START_DATE) AND DATEADD(day,-1,CURRENT_DATE);


SELECT  'CPH' AS SEGMENT, 
        SERVICE_LEVEL_INPUT_CPH.*,  
        START_DATE.START_DT AS FIRST_ORDER_DATE,
        CASE WHEN START_DATE.START_DT IS NULL THEN START_DATE_NOTED ELSE START_DATE.START_DT END START_DT,
        CASE WHEN START_DATE.START_DT IS NULL THEN 'PENDING' ELSE 'ACTIVE' END START_DT_STATUS
FROM    SBX_PSAS_DB.ANALYTICS.SERVICE_LEVEL_INPUT_CPH
LEFT JOIN START_DATE
ON      LTRIM(SERVICE_LEVEL_INPUT_CPH.CUST_ACCT_ID,'0') = LTRIM(START_DATE.CUST_ACCT_ID,'0');

-- UNION ALL

-- SELECT  SELECT  'MHS' AS SEGMENT, SERVICE_LEVEL_INPUT_MHS.*,  START_DATE.START_DT
-- FROM    SBX_PSAS_DB.ANALYTICS.SERVICE_LEVEL_INPUT_MHS
-- LEFT JOIN START_DATE
-- ON      LTRIM(SERVICE_LEVEL_INPUT_MHS.CUST_ACCT_ID,'0') = LTRIM(START_DATE.CUST_ACCT_ID,'0');



---------------------------------------------------------------------------------------------


USE ROLE SBX_EA_GENERAL_FR;
USE DATABASE SBX_PSAS_DB;
USE SCHEMA SALES_OPS_GOV;
USE WAREHOUSE SBX_EA_GENERAL_FR_WH;
ALTER SESSION SET WEEK_START = 6;

--SHOW TASKS LIKE 'TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_DETAIL%'
--DESC TASK TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_DETAIL
 select *  from table(SBX_PSAS_DB.INFORMATION_SCHEMA.task_history(
     scheduled_time_range_start=>dateadd('hour',-24,current_timestamp()),
     result_limit => 10,
     task_name=>'TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_DETAIL'));
    
--alter task TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_DETAIL resume; --It was by default suspended  ( run this command Only first time since by default its suspended)
--execute task TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_DETAIL 

--TASK
CREATE OR REPLACE TASK TSK_KEVIN_B_SERVICE_LEVEL_ANALYTICS_ONBOARDING_DASHBOARD_DETAIL

WAREHOUSE = SBX_EA_GENERAL_FR_WH
SCHEDULE = 'USING CRON 57 7 * * 1-5 America/Chicago' 
TIMESTAMP_INPUT_FORMAT = 'YYYY-MM-DD HH24'
AS

--FINAL PULL | ADD GLN DETAILS & SALES REP
CREATE OR REPLACE TABLE SBX_PSAS_DB.SALES_OPS_GOV.T_SERVICE_LEVEL_ONBOARDING_DASHBOARD_DETAIL AS


--COMBINE CUSTOMER DATA FOR CPH & MHS
WITH ONBOARD AS (


SELECT * FROM SBX_PSAS_DB.ANALYTICS.SERVICE_LEVEL_INPUT_CPH
-- UNION ALL

-- SELECT * FROM SBX_PSAS_DB.ANALYTICS.SERVICE_LEVEL_INPUT_MHS;
)

--FIND FIRST ORDER DATE OF AN ACCOUNT
, START_DATE AS (

SELECT  CUST.CUST_ACCT_ID,
        MIN(CAL_CYMD) AS START_DT
FROM    PRD_PSAS_DB.RPT.T_SLA_CUST_ORD_DTL ORD
JOIN    PRD_PSAS_DB.RPT.T_SLA_CUST_ACCT CUST
ON      ORD.CUST_ACCT_SURR_KEY = CUST.CUST_ACCT_SURR_KEY
JOIN    ONBOARD
ON      LTRIM(CUST.CUST_ACCT_ID,'0') = LTRIM(ONBOARD.CUST_ACCT_ID,'0')
WHERE   ORD.ORDR_QTY > 0
AND     CAL_CYMD >= '2022-09-01'
GROUP BY  CUST.CUST_ACCT_ID)


SELECT  ORD.CAL_CYMD,
        --DATEDIFF(day, START_DATE.START_DT::DATE, ORD.CAL_CYMD::DATE) DAYS_FROM_START,
        DATEDIFF(day, START_DATE.START_DT::DATE, ORD.CAL_CYMD::DATE)+1 AS DAYS_FROM_START,
        LAST_DAY(ORD.CAL_CYMD, 'week') LAST_DAY,
        CUST.CUST_ACCT_ID,
        CUST.CUST_ACCT_NAM,
        CUST_ACCT.HOME_DC_ID,
        CUST_ACCT.PRI_FILL_DC_ID,
        FILL_ITEM.EM_ITEM_NUM AS FILL_EM_ITEM_NUM,
        FILL_ITEM.NDC_NUM AS FILL_NDC_NUM,
        FILL_ITEM.SPLR_ACCT_NAM AS FILL_SPLR_NAM,
        FILL_ITEM.GNRC_IND AS FILL_GNRC_IND,
        FILL_ITEM.GNRC_TYP_CD AS GNRC_TYP_CD,
        FILL_ITEM.SELL_DSCR AS FILL_SELL_DSCR,
        FILL_ITEM.SVC_LVL_CTGY_CD AS FILL_SVC_LVL_CTGY_CD,
        FILL_ITEM.RXDA_CD AS FILL_RXDA_CD,
        FILL_ITEM.GNRC_ITEM_CD AS FILL_GNRC_ITEM_CD,
        FILL_ITEM.ITEM_ACTVY_CD AS FILL_ITEM_ACTVY_CD,
        FILL_MCNS.RESOLUTION AS FILL_MCNS_RESOLUTION,
        FILL_MCNS.SPECIFICS AS FILL_MCNS_SPECIFICS,
        FILL_MCNS.MORE_INFO AS FILL_MCNS_MORE_INFO,
        FILL_MCNS.BEG_EFF_CCYYMMDD_DT AS FILL_MCNS_BEG_DT,
        FILL_MCNS.END_EFF_CCYYMMDD_DT AS FILL_MCNS_END_DT,
        ORDR_ITEM.EM_ITEM_NUM AS ORDR_EM_ITEM_NUM,
        ORDR_ITEM.SELL_DSCR AS ORDR_SELL_DSCR,
        ORDR_ITEM.NDC_NUM AS ORDR_NDC_NUM,
        ORDR_MCNS.RESOLUTION AS ORDR_MCNS_RESOLUTION,
        ORDR_MCNS.SPECIFICS AS ORDR_MCNS_SPECIFICS,
        ORDR_MCNS.MORE_INFO AS ORDR_MCNS_MORE_INFO,
        ORDR_MCNS.BEG_EFF_CCYYMMDD_DT AS ORDR_MCNS_BEG_DT,
        ORDR_MCNS.END_EFF_CCYYMMDD_DT AS ORDR_MCNS_END_DT,
        SUM(ORD.ORDR_QTY) ORDR_QTY,
        SUM(ORD.FILL_QTY) FILL_QTY,
        SUM(ORD.OMIT_QTY) OMIT_QTY,
        SUM(ORD.MUS_QTY) MCS_OMIT_QTY,
        SUM(ORD.CNTRL_OMIT_QTY) CSMP_OMIT_QTY,
        SUM(SLS_EXT_AMT) INVC_AMT
        -- SUM(ORD.FILL_QTY) / NULLIF(SUM(ORD.ORDR_QTY),0) RAW_PIECE_SL,
        -- NULLIF(SUM(ORD.FILL_QTY),0) / (SUM(ORD.ORDR_QTY) - SUM(ORD.MUS_QTY)) ADJ_PIECE_SL, 
FROM    PRD_PSAS_DB.RPT.T_SLA_CUST_ORD_DTL ORD
JOIN    PRD_PSAS_DB.RPT.T_SLA_CUST_ACCT CUST
ON      ORD.CUST_ACCT_SURR_KEY = CUST.CUST_ACCT_SURR_KEY
JOIN    PRD_PSAS_DB.RPT.DIM_CUST_ACCT_CURR CUST_ACCT
ON      CUST.CUST_ACCT_ID = CUST_ACCT.CUST_ACCT_ID
JOIN    ONBOARD
ON      LTRIM(CUST_ACCT.CUST_ACCT_ID,'0') = LTRIM(ONBOARD.CUST_ACCT_ID,'0')
JOIN    PRD_PSAS_DB.RPT.T_SLA_EM_ITEM FILL_ITEM
ON      FILL_ITEM.ITEM_SURR_KEY = ORD.FILL_ITEM_SURR_KEY
JOIN    PRD_PSAS_DB.RPT.T_SLA_EM_ITEM ORDR_ITEM
ON      ORDR_ITEM.ITEM_SURR_KEY = ORD.ORIG_ITEM_SURR_KEY
JOIN    START_DATE
ON      START_DATE.CUST_ACCT_ID = CUST.CUST_ACCT_ID
AND     CAL_CYMD >= START_DATE.START_DT
AND     CAL_CYMD <= DATEADD(day,90,START_DATE.START_DT)
LEFT JOIN PRD_PSAS_DB.RPT.T_ITEM_MCNS FILL_MCNS
ON      FILL_MCNS.EM_ITEM_NUM = FILL_ITEM.EM_ITEM_NUM
AND     FILL_MCNS.CURR_IND = 'Y'
LEFT JOIN PRD_PSAS_DB.RPT.T_ITEM_MCNS ORDR_MCNS
ON      ORDR_MCNS.EM_ITEM_NUM = ORDR_ITEM.EM_ITEM_NUM
AND     ORDR_MCNS.CURR_IND = 'Y'
-- LEFT JOIN CAL
-- ON      CAL.CAL_DT = ORD.CAL_CYMD
GROUP BY ORD.CAL_CYMD,
        DATEDIFF(day, START_DATE.START_DT::DATE, ORD.CAL_CYMD::DATE) +1,
        LAST_DAY(ORD.CAL_CYMD, 'week'),
        CUST.CUST_ACCT_ID,
        CUST.CUST_ACCT_NAM,
        CUST_ACCT.HOME_DC_ID,
        CUST_ACCT.PRI_FILL_DC_ID,
        FILL_ITEM.EM_ITEM_NUM,
        FILL_ITEM.NDC_NUM,
        FILL_ITEM.SPLR_ACCT_NAM,
        FILL_ITEM.GNRC_IND,
        FILL_ITEM.GNRC_TYP_CD,
        FILL_ITEM.SELL_DSCR,
        FILL_ITEM.SVC_LVL_CTGY_CD,
        FILL_ITEM.RXDA_CD,
        FILL_ITEM.GNRC_ITEM_CD,
        FILL_ITEM.ITEM_ACTVY_CD,
        FILL_MCNS.RESOLUTION,
        FILL_MCNS.SPECIFICS,
        FILL_MCNS.MORE_INFO,
        FILL_MCNS.BEG_EFF_CCYYMMDD_DT,
        FILL_MCNS.END_EFF_CCYYMMDD_DT,
        ORDR_ITEM.EM_ITEM_NUM,
        ORDR_ITEM.SELL_DSCR,
        ORDR_ITEM.NDC_NUM,
        ORDR_MCNS.RESOLUTION,
        ORDR_MCNS.SPECIFICS,
        ORDR_MCNS.MORE_INFO,
        ORDR_MCNS.BEG_EFF_CCYYMMDD_DT,
        ORDR_MCNS.END_EFF_CCYYMMDD_DT;

        