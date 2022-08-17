/*
    This model retrieves a list of opportunities that are about to churn but have not yet churned. 
    
    The first CTE retrieves the previous stage from each row in the opportunity history table,
    allowing comparison of the old and new stage name values for each row.
    
    Then opportunities are filtered to those where the stage was changed from an customer-related
    opp to Closed Won, and where the service end date is future-dated.
*/

{{ config(materialized='table') }}

WITH previous_opportunity_stage AS (
    SELECT id
        , COALESCE(LAG(stage_name, 1)
            OVER (
                PARTITION BY opportunity_id
                ORDER BY created_date, system_modstamp
            ), 'NA')                                        AS previous_stage_name
    FROM salesforce.opportunity_history
),

churn_opportunities_future AS (
    SELECT o.id                     AS opp_id
        , o.name                    AS opp_name
        , o.amount                  AS opp_amount
        , pos.previous_stage_name   AS previous_stage_name
        , oh.system_modstamp::DATE  AS churn_trigger_date
        , o.service_end_date__c     AS churn_date
    FROM salesforce.opportunity_history oh
    LEFT JOIN previous_opportunity_stage pos
              ON oh.id = pos.id
    INNER JOIN salesforce.opportunity o
               ON o.id = oh.opportunity_id
    WHERE oh.stage_name = 'Closed Lost'
        AND pos.previous_stage_name != oh.stage_name
        AND pos.previous_stage_name NOT IN (
            'Meeting Booked'
            , 'Negotiation'
            , 'Proposal'
            , 'Disco'
            , 'Demo'
            , 'NA'
        )
        AND service_end_date__c >= CURRENT_DATE
    ORDER BY oh.system_modstamp
)

SELECT * FROM churn_opportunities_future
