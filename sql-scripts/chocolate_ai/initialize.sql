/*##################################################################################
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###################################################################################*/

/*
Author: Adam Paternostro 

Use Cases:
    - Initializes the system (you can re-run this)

Description: 
    - Loads all tables from the public storage account
    - Uses AVRO so we can bring in JSON and GEO types

References:
    - 

Clean up / Reset script:
    -  n/a

*/


------------------------------------------------------------------------------------------------------------
-- Create GenAI / Vertex AI connections
------------------------------------------------------------------------------------------------------------
CREATE MODEL IF NOT EXISTS `${project_id}.${bigquery_chocolate_ai_dataset}.gemini_model`
  REMOTE WITH CONNECTION `${project_id}.us.vertex-ai`
  OPTIONS (endpoint = 'gemini-2.5-flash');

CREATE MODEL IF NOT EXISTS `${project_id}.${bigquery_chocolate_ai_dataset}.textembedding_model`
  REMOTE WITH CONNECTION `${project_id}.us.vertex-ai`
  OPTIONS (endpoint = 'text-embedding-005');

------------------------------------------------------------------------------------------------------------
-- Load all data
------------------------------------------------------------------------------------------------------------
LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.campaign` 
CLUSTER BY campaign_id 
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/campaign/campaign_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.campaign_abcd_results` 
CLUSTER BY assessment_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/campaign_abcd_results/campaign_abcd_results_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.campaign_name_suggestion` 
CLUSTER BY media
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/campaign_name_suggestion/campaign_name_suggestion_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.campaign_performance` 
CLUSTER BY campaign_id 
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/campaign_performance/campaign_performance_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.customer` 
CLUSTER BY customer_id 
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/customer/customer_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.customer_geo_location` 
CLUSTER BY customer_id, event_timestamp_millis
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/customer_geo_location/customer_geo_location_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.customer_geo_location_results` 
CLUSTER BY customer_id, event_timestamp_millis
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/customer_geo_location_results/customer_geo_location_results_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.customer_hyper_personalized_email` 
CLUSTER BY customer_id 
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/customer_hyper_personalized_email/customer_hyper_personalized_email_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile`
CLUSTER BY customer_id  
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/customer_marketing_profile/customer_marketing_profile_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.customer_review` 
CLUSTER BY customer_id 
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/customer_review/customer_review_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.data_insights` 
CLUSTER BY data_insights_scan_name
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/data_insights/data_insights_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.event` 
CLUSTER BY event_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/event/event_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.looker_ad_events` 
CLUSTER BY id, keyword_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/looker_ad_events/looker_ad_events_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.looker_ad_groups` 
CLUSTER BY ad_id, campaign_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/looker_ad_groups/looker_ad_groups_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.looker_campaigns` 
CLUSTER BY id, advertising_channel
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/looker_campaigns/looker_campaigns_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.looker_derived_sessions` 
CLUSTER BY session_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/looker_derived_sessions/looker_derived_sessions_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.looker_derived_sessions_purchase_facts` 
CLUSTER BY session_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/looker_derived_sessions_purchase_facts/looker_derived_sessions_purchase_facts_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.looker_derived_user_product_sales` 
CLUSTER BY user_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/looker_derived_user_product_sales/looker_derived_user_product_sales_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.looker_discounts` 
CLUSTER BY product_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/looker_discounts/looker_discounts_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.looker_events` 
CLUSTER BY id, session_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/looker_events/looker_events_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.looker_keywords` 
CLUSTER BY keyword_id, ad_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/looker_keywords/looker_keywords_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.looker_users` 
CLUSTER BY id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/looker_users/looker_users_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.order`
CLUSTER BY order_id, store_id 
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/order/order_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.order_item` 
CLUSTER BY order_item_id, order_id 
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/order_item/order_item_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.spanner_social_data` 
CLUSTER BY customer_id 
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/spanner_social_data/spanner_social_data_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.store` 
CLUSTER BY store_id 
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v1/Data-Export/store/store_*.avro']);

------------------------------------------------------------------------------------------------------------
-- v2 - Oracle update
------------------------------------------------------------------------------------------------------------
LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.generated_customer_allergy_information` 
CLUSTER BY customer_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/generated_customer_allergy_information/generated_customer_allergy_information_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.generated_ingredients` 
CLUSTER BY menu_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/generated_ingredients/generated_ingredients_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.generated_inventory` 
CLUSTER BY inventory_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/generated_inventory/generated_inventory_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.menu` 
CLUSTER BY menu_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/menu/menu_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.menu_embeddings_allergy` 
CLUSTER BY menu_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/menu_embeddings_allergy/menu_embeddings_allergy_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.menu_embeddings_description` 
CLUSTER BY menu_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/menu_embeddings_description/menu_embeddings_description_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.menu_embeddings_name` 
CLUSTER BY menu_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/menu_embeddings_name/menu_embeddings_name_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.oracle_customer` 
CLUSTER BY customer_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/oracle_customer/oracle_customer_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.oracle_ingredients` 
CLUSTER BY ingredient_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/oracle_ingredients/oracle_ingredients_*.avro']);

LOAD DATA OVERWRITE `${project_id}.${bigquery_chocolate_ai_dataset}.oracle_inventory` 
CLUSTER BY inventory_id
FROM FILES ( format = 'AVRO', enable_logical_types = true, uris = ['gs://data-analytics-golden-demo/chocolate-ai/v2/Data-Export/oracle_inventory/oracle_inventory_*.avro']);


------------------------------------------------------------------------------------------------------------
-- Create Views
------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW `${project_id}.${bigquery_chocolate_ai_dataset}.chocolate_insights`(
          store_name OPTIONS (DESCRIPTION='Name of the Store'),
          store_address OPTIONS (DESCRIPTION='The address of the store'),
          store_latitude OPTIONS (DESCRIPTION='Latitude of the store'),
          store_longitude OPTIONS (DESCRIPTION='Longitude of the store'),
          customer_name OPTIONS (DESCRIPTION='Name of the customer'),
          customer_email OPTIONS (DESCRIPTION='Email address of the customer'),
          customer_inception_date OPTIONS (DESCRIPTION='Date when the customer first joined'),
          customer_yob OPTIONS (DESCRIPTION='Year of birth of the customer'),
          order_datetime OPTIONS (DESCRIPTION='Timestamp when the order was placed'),
          order_completion_datetime OPTIONS (DESCRIPTION='Timestamp when the order was completed'),
          menu_name OPTIONS (DESCRIPTION='Name of the item on the menu'),
          menu_price OPTIONS (DESCRIPTION='Price of the menu item'),
          menu_size OPTIONS (DESCRIPTION='Size of the menu item (e.g., small, medium, large)'),
          menu_description OPTIONS (DESCRIPTION='Description of the menu item'),
          quantity OPTIONS (DESCRIPTION='Quantity of the menu item ordered'),
          item_total OPTIONS (DESCRIPTION='Total price of the item (quantity * menu_price)'),
          item_price OPTIONS (DESCRIPTION='Price of the individual item'), 
          item_size OPTIONS (DESCRIPTION='Size of the individual item')) AS 
   SELECT store_name,
          store_address,
          store_latitude,
          store_longitude,
          customer_name,
          customer_email,
          customer_inception_date,
          customer_yob,
          order_datetime,
          order_completion_datetime,
          menu_name,
          menu_price,
          menu_size,
          menu_description,
          quantity,
          item_total,
          item_price,
          item_size
  FROM `${project_id}.${bigquery_chocolate_ai_dataset}.store` store
       INNER JOIN `${project_id}.${bigquery_chocolate_ai_dataset}.order` orders
               ON store.store_id = orders.store_id
       INNER JOIN `${project_id}.${bigquery_chocolate_ai_dataset}.order_item` order_item
               ON order_item.order_id=orders.order_id
       INNER JOIN `${project_id}.${bigquery_chocolate_ai_dataset}.menu` menu
               ON menu.menu_id=order_item.menu_id
       INNER JOIN `${project_id}.${bigquery_chocolate_ai_dataset}.customer` customer
               ON customer.customer_id=orders.customer_id;


CREATE OR REPLACE VIEW `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile_data`
AS
SELECT
    customer_id,
    JSON_VALUE(customer_profile_data.children) AS children,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_profile_data.chocolate_preferences), ",") AS chocolate_preferences,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_profile_data.content_interaction), ",") AS content_interaction,
    CAST(JSON_VALUE(customer_profile_data.customer_age) AS INT64) AS customer_age,
    JSON_VALUE(customer_profile_data.education) AS education,
    JSON_VALUE(customer_profile_data.facebook_bio) AS facebook_bio,
    JSON_VALUE(customer_profile_data.facebook_engagement) AS facebook_engagement,
    JSON_VALUE(customer_profile_data.facebook_handle) AS facebook_handle,
    JSON_VALUE(customer_profile_data.instagram_bio) AS instagram_bio,
    JSON_VALUE(customer_profile_data.instagram_engagement) AS instagram_engagement,
    JSON_VALUE(customer_profile_data.instagram_handle) AS instagram_handle,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_profile_data.interests), ",") AS interests,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_profile_data.lifestyle), ",") AS lifestyle,
    JSON_VALUE(customer_profile_data.linkedin_bio) AS linkedin_bio,
    JSON_VALUE(customer_profile_data.linkedin_engagement) AS linkedin_engagement,
    JSON_VALUE(customer_profile_data.linkedin_handle) AS linkedin_handle,
    JSON_VALUE(customer_profile_data.martial_status) AS martial_status,
    JSON_VALUE(customer_profile_data.occupation) AS occupation,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_profile_data.solicated_buying_habits), ",") AS solicated_buying_habits,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_profile_data.sports), ",") AS sports,
    JSON_VALUE(customer_profile_data.tiktok_bio) AS tiktok_bio,
    JSON_VALUE(customer_profile_data.tiktok_handle) AS tiktok_handle,
    JSON_VALUE(customer_profile_data.twitter_bio) AS twitter_bio,
    JSON_VALUE(customer_profile_data.twitter_engagement) AS twitter_engagement,
    JSON_VALUE(customer_profile_data.twitter_handle) AS twitter_handle,
    JSON_VALUE(customer_profile_data.youtube_bio) AS youtube_bio,
    JSON_VALUE(customer_profile_data.youtube_handle) AS youtube_handle,
    (
        SELECT STRING_AGG(CONCAT(
            'contact_reason:', JSON_VALUE(interaction, '$.contact_reason'), '; ',
            'resolution_time:', JSON_VALUE(interaction, '$.resolution_time'), '; ',
            'sentiment_analysis:', JSON_VALUE(interaction, '$.sentiment_analysis')
        ), ' | ') 
        FROM UNNEST(JSON_QUERY_ARRAY(customer_profile_data, '$.customer_service_interactions')) AS interaction
    ) AS customer_service_interactions
  FROM
    `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile`;


CREATE OR REPLACE VIEW `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile_loyalty`
AS
SELECT
    customer_id,
    CAST(JSON_VALUE(customer_loyalty_data.average_amount_spent_per_order) AS BIGNUMERIC) AS average_amount_spent_per_order,
    CAST(JSON_VALUE(customer_loyalty_data.last_order_date) AS TIMESTAMP) AS last_order_date,
    JSON_VALUE(customer_loyalty_data.latest_review_sentiment) AS latest_review_sentiment,
    CAST(JSON_VALUE(customer_loyalty_data.most_frequent_purchase_location) AS INT64) AS most_frequent_purchase_location,
    CAST(JSON_VALUE(customer_loyalty_data.negative_review_percentage) AS NUMERIC) AS negative_review_percentage,
    CAST(JSON_VALUE(customer_loyalty_data.neutral_review_percentage) AS NUMERIC) AS neutral_review_percentage,
    CAST(JSON_VALUE(customer_loyalty_data.positive_review_percentage) AS NUMERIC) AS positive_review_percentage,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_loyalty_data.purchase_locations), ",") AS purchase_locations,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_loyalty_data.top_3_favorite_menu_items), ",") AS top_3_favorite_menu_items,
    CAST(JSON_VALUE(customer_loyalty_data.total_amount_spent) AS BIGNUMERIC) AS total_amount_spent,
    CAST(JSON_VALUE(customer_loyalty_data.total_orders) AS INT64) AS total_orders,
    CAST(JSON_VALUE(customer_loyalty_data.total_reviews) AS INT64) AS total_reviews
  FROM
    `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile`;


CREATE OR REPLACE VIEW `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile_segments`
AS
SELECT
    customer_id,
    REPLACE(JSON_VALUE(customer_segmentation_data.customer_segments.behavioral_segmentation.`Benefits Sought`), " ", "") AS benefits_sought,
    JSON_VALUE(customer_segmentation_data.customer_segments.behavioral_segmentation.`Browsing Behavior`) AS browsing_behavior,
    JSON_VALUE(customer_segmentation_data.customer_segments.behavioral_segmentation.`Loyalty Status`) AS loyalty_status,
    JSON_VALUE(customer_segmentation_data.customer_segments.behavioral_segmentation.`Occasion/Timing`) AS occasion_timing,
    JSON_VALUE(customer_segmentation_data.customer_segments.behavioral_segmentation.`Purchase History`) AS purchase_history,
    JSON_VALUE(customer_segmentation_data.customer_segments.behavioral_segmentation.`Spending Habits`) AS spending_habits,
    JSON_VALUE(customer_segmentation_data.customer_segments.behavioral_segmentation.`Usage Frequency`) AS usage_frequency,
    JSON_VALUE(customer_segmentation_data.customer_segments.behavioral_segmentation.`User Status`) AS user_status,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_segmentation_data.customer_segments.customer_lifecycle_segmentation.`At-Risk Customers`), ",") AS at_risk_customers,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_segmentation_data.customer_segments.customer_lifecycle_segmentation.`First-Time Customers`), ",") AS first_time_customers,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_segmentation_data.customer_segments.customer_lifecycle_segmentation.`Former Customers`), ",") AS former_customers,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_segmentation_data.customer_segments.customer_lifecycle_segmentation.`Inactive Customers`), ",") AS inactive_customers,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_segmentation_data.customer_segments.customer_lifecycle_segmentation.`Loyal Advocates`), ",") AS loyal_advocates,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_segmentation_data.customer_segments.customer_lifecycle_segmentation.`New Leads`), ",") AS new_leads,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_segmentation_data.customer_segments.customer_lifecycle_segmentation.`Potential Customers`), ",") AS potential_customers,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_segmentation_data.customer_segments.customer_lifecycle_segmentation.`Repeat Customers`), ",") AS repeat_customers,
    JSON_VALUE(customer_segmentation_data.customer_segments.demographic_segmentation.`Age`) AS age,
    JSON_VALUE(customer_segmentation_data.customer_segments.demographic_segmentation.`Education`) AS education,
    JSON_VALUE(customer_segmentation_data.customer_segments.demographic_segmentation.`Ethnicity`) AS ethnicity,
    JSON_VALUE(customer_segmentation_data.customer_segments.demographic_segmentation.`Family Size`) AS family_size,
    JSON_VALUE(customer_segmentation_data.customer_segments.demographic_segmentation.`Gender`) AS gender,
    JSON_VALUE(customer_segmentation_data.customer_segments.demographic_segmentation.`Generation`) AS generation,
    JSON_VALUE(customer_segmentation_data.customer_segments.demographic_segmentation.`Income`) AS income,
    JSON_VALUE(customer_segmentation_data.customer_segments.demographic_segmentation.`Language`) AS language,
    JSON_VALUE(customer_segmentation_data.customer_segments.demographic_segmentation.`Marital Status`) AS marital_status,
    JSON_VALUE(customer_segmentation_data.customer_segments.demographic_segmentation.`Occupation`) AS occupation,
    JSON_VALUE(customer_segmentation_data.customer_segments.geographic_segmentation.`City`) AS city,
    JSON_VALUE(customer_segmentation_data.customer_segments.geographic_segmentation.`Climate`) AS climate,
    JSON_VALUE(customer_segmentation_data.customer_segments.geographic_segmentation.`Country`) AS country,
    JSON_VALUE(customer_segmentation_data.customer_segments.geographic_segmentation.`Population Density`) AS population_density,
    JSON_VALUE(customer_segmentation_data.customer_segments.geographic_segmentation.`Region`) AS region,
    JSON_VALUE(customer_segmentation_data.customer_segments.geographic_segmentation.`Time Zone`) AS time_zone,
    JSON_VALUE(customer_segmentation_data.customer_segments.geographic_segmentation.`Urban/Rural`) AS urban_rural,
    JSON_VALUE(customer_segmentation_data.customer_segments.needs_based_segmentation.`Challenges`) AS challenges,
    JSON_VALUE(customer_segmentation_data.customer_segments.needs_based_segmentation.`Goals`) AS goals,
    JSON_VALUE(customer_segmentation_data.customer_segments.needs_based_segmentation.`Pain Points`) AS pain_points,
    JSON_VALUE(customer_segmentation_data.customer_segments.needs_based_segmentation.`Priorities`) AS priorities,
    JSON_VALUE(customer_segmentation_data.customer_segments.needs_based_segmentation.`Specific Needs`) AS specific_needs,
    JSON_VALUE(customer_segmentation_data.customer_segments.psychographic_segmentation.`Attitudes`) AS attitudes,
    ARRAY_TO_STRING(JSON_VALUE_ARRAY(customer_segmentation_data.customer_segments.psychographic_segmentation.`Hobbies`), ",") AS hobbies,
    JSON_VALUE(customer_segmentation_data.customer_segments.psychographic_segmentation.`Interests`) AS interests,
    JSON_VALUE(customer_segmentation_data.customer_segments.psychographic_segmentation.`Lifestyle`) AS lifestyle,
    JSON_VALUE(customer_segmentation_data.customer_segments.psychographic_segmentation.`Motivations`) AS motivations,
    JSON_VALUE(customer_segmentation_data.customer_segments.psychographic_segmentation.`Personality`) AS personality,
    JSON_VALUE(customer_segmentation_data.customer_segments.psychographic_segmentation.`Social Class`) AS social_class,
    JSON_VALUE(customer_segmentation_data.customer_segments.psychographic_segmentation.`Values`) AS customer_values,
    JSON_VALUE(customer_segmentation_data.customer_segments.technographic_segmentation.`Adoption Rate`) AS adoption_rate,
    JSON_VALUE(customer_segmentation_data.customer_segments.technographic_segmentation.`Browsers`) AS browsers,
    JSON_VALUE(customer_segmentation_data.customer_segments.technographic_segmentation.`Devices`) AS devices,
    JSON_VALUE(customer_segmentation_data.customer_segments.technographic_segmentation.`Internet Connectivity`) AS internet_connectivity,
    JSON_VALUE(customer_segmentation_data.customer_segments.technographic_segmentation.`Operating Systems`) AS operating_systems,
    JSON_VALUE(customer_segmentation_data.customer_segments.technographic_segmentation.`Social Media Platforms`) AS social_media_platforms,
    JSON_VALUE(customer_segmentation_data.customer_segments.technographic_segmentation.`Software`) AS software,
    JSON_VALUE(customer_segmentation_data.customer_segments.technographic_segmentation.`Tech Savviness`) AS tech_savviness,
    JSON_VALUE(customer_segmentation_data.customer_segments.value_based_segmentation.`Cost-Benefit Analysis`) AS cost_benefit_analysis,
    JSON_VALUE(customer_segmentation_data.customer_segments.value_based_segmentation.`Perceived Value`) AS perceived_value,
    JSON_VALUE(customer_segmentation_data.customer_segments.value_based_segmentation.`Price Sensitivity`) AS price_sensitivity,
    JSON_VALUE(customer_segmentation_data.customer_segments.value_based_segmentation.`Willingness to Pay`) AS willingness_to_pay
FROM `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile`;

CREATE OR REPLACE VIEW `${project_id}.${bigquery_chocolate_ai_dataset}.customer_360`
AS
SELECT
    mp.customer_id,
    -- Customer Marketing Profile Summary
    cmp.customer_marketing_insights,
    -- Customer Marketing Profile Segments
    mp.benefits_sought,
    mp.browsing_behavior,
    mp.loyalty_status,
    mp.occasion_timing,
    mp.purchase_history,
    mp.spending_habits,
    mp.usage_frequency,
    mp.user_status,
    mp.at_risk_customers,
    mp.first_time_customers,
    mp.former_customers,
    mp.inactive_customers,
    mp.loyal_advocates,
    mp.new_leads,
    mp.potential_customers,
    mp.repeat_customers,
    mp.age,
    mp.education,
    mp.ethnicity,
    mp.family_size,
    mp.gender,
    mp.generation,
    mp.income,
    mp.language,
    mp.marital_status,
    mp.occupation,
    mp.city,
    mp.climate,
    mp.country,
    mp.population_density,
    mp.region,
    mp.time_zone,
    mp.urban_rural,
    mp.challenges,
    mp.goals,
    mp.pain_points,
    mp.priorities,
    mp.specific_needs,
    mp.attitudes,
    mp.hobbies,
    mp.interests,
    mp.lifestyle,
    mp.motivations,
    mp.personality,
    mp.social_class,
    mp.customer_values,
    mp.adoption_rate,
    mp.browsers,
    mp.devices,
    mp.internet_connectivity,
    mp.operating_systems,
    mp.social_media_platforms,
    mp.software,
    mp.tech_savviness,
    mp.cost_benefit_analysis,
    mp.perceived_value,
    mp.price_sensitivity,
    mp.willingness_to_pay,
    -- Customer Profile
    cp.children,
    cp.chocolate_preferences,
    cp.content_interaction,
    cp.customer_age,
    cp.facebook_bio,
    cp.facebook_engagement,
    cp.facebook_handle,
    cp.instagram_bio,
    cp.instagram_engagement,
    cp.instagram_handle,
    cp.linkedin_bio,
    cp.linkedin_engagement,
    cp.linkedin_handle,
    cp.martial_status,
    cp.solicated_buying_habits,
    cp.sports,
    cp.tiktok_bio,
    cp.tiktok_handle,
    cp.twitter_bio,
    cp.twitter_engagement,
    cp.twitter_handle,
    cp.youtube_bio,
    cp.youtube_handle,
    cp.customer_service_interactions,
    -- Customer Loyalty
    cl.average_amount_spent_per_order,
    cl.last_order_date,
    cl.latest_review_sentiment,
    cl.most_frequent_purchase_location,
    cl.negative_review_percentage,
    cl.neutral_review_percentage,
    cl.positive_review_percentage,
    cl.purchase_locations,
    cl.top_3_favorite_menu_items,
    cl.total_amount_spent,
    cl.total_orders,
    cl.total_reviews
  FROM
    `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile_segments` AS mp
    INNER JOIN `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile_data` AS cp ON mp.customer_id = cp.customer_id
    INNER JOIN `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile_loyalty` AS cl ON mp.customer_id = cl.customer_id
    INNER JOIN `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile` AS cmp ON mp.customer_id = cmp.customer_id;

CREATE VECTOR INDEX customer_marketing_insights_embedding_ivf
ON `${project_id}.${bigquery_chocolate_ai_dataset}.customer_marketing_profile`(customer_marketing_insights_embedding)
OPTIONS (index_type = 'IVF', distance_type = 'COSINE');