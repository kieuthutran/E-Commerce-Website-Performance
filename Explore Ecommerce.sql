--Query 01: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
SELECT 
   FORMAT_DATE("%Y%m",PARSE_DATE('%Y%m%d',date)) AS month
  , SUM(totals.visits) AS visits
  , SUM(totals.pageviews) AS pageviews
  , SUM(totals.transactions) AS transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix BETWEEN '0101' AND '0331'
GROUP BY month
ORDER BY month

--Query 02: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
SELECT trafficSource.source
  , SUM(totals.visits) AS total_visits
  , SUM(totals.bounces) AS total_no_of_bounces
  , ROUND(100.0 * (SUM(totals.bounces) / SUM(totals.visits)), 3) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY trafficSource.source
ORDER BY total_visits DESC

--Query 3: Revenue by traffic source by week, by month in June 2017
SELECT 'Month' as time_type
  , FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS time
  , trafficSource.source AS source
  , ROUND(SUM(product.productRevenue)/1000000, 4) as revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
UNNEST (hits) hits,
UNNEST (hits.product) product
WHERE product.productRevenue IS NOT NULL
GROUP BY time, source

UNION ALL

SELECT 'Week' as time_type
  , FORMAT_DATE("%Y%W", PARSE_DATE("%Y%m%d", date)) AS time
  , trafficSource.source AS source
  , ROUND(SUM(product.productRevenue)/1000000, 4) as revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
UNNEST (hits) hits,
UNNEST (hits.product) product
WHERE product.productRevenue IS NOT NULL
GROUP BY time, source

ORDER BY revenue DESC

--Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017
WITH purchase AS(
  SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
    ,SUM(totals.pageviews) / COUNT(DISTINCT fullVisitorId) AS avg_pageviews_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) hits
    ,UNNEST(hits.product) product
  WHERE _table_suffix BETWEEN '0601' AND '0731'
    AND totals.transactions >= 1
    AND product.productRevenue IS NOT NULL
  GROUP BY month
),

non_purchase AS(
  SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
    ,SUM(totals.pageviews) / COUNT(DISTINCT fullVisitorId) AS avg_pageviews_non_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) hits
    ,UNNEST(hits.product) product
  WHERE _table_suffix BETWEEN '0601' AND '0731'
    AND totals.transactions IS NULL
    AND product.productRevenue IS NULL
  GROUP BY month
)

SELECT purchase.month
  ,avg_pageviews_purchase
  ,avg_pageviews_non_purchase
FROM purchase
FULL JOIN non_purchase USING(month)
ORDER BY purchase.month


--Query 05: Average number of transactions per user that made a purchase in July 2017
SELECT
  FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
  ,SUM(totals.transactions) / COUNT(DISTINCT fullVisitorId) AS avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,UNNEST(hits) hits
  ,UNNEST(hits.product) product
WHERE totals.transactions >=1
  AND productRevenue IS NOT NULL
GROUP BY month

--Query 06: Average amount of money spent per session. Only include purchaser data in July 2017
SELECT 
  FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
  ,ROUND((SUM(product.productRevenue)/1000000) / COUNT(totals.visits), 2) AS avg_revenue_by_user_per_visit
 FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,UNNEST(hits) hits
  ,UNNEST(hits.product) product
 WHERE totals.transactions IS NOT NULL
  AND product.productRevenue IS NOT NULL
 GROUP BY month

/*
Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017.
Output should show product name and the quantity was ordered
*/
WITH full_table AS
(SELECT
  fullVisitorId
  ,product.v2ProductName
  ,productQuantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,UNNEST(hits) hits
  ,UNNEST(hits.product) product
WHERE product.productRevenue IS NOT NULL)

SELECT v2ProductName AS other_purchased_products
  ,SUM(productQuantity) AS quantity
FROM full_table
WHERE fullVisitorId IN 
                    (SELECT fullVisitorId
                    FROM full_table
                    WHERE v2ProductName = "YouTube Men's Vintage Henley")
    AND v2ProductName <> "YouTube Men's Vintage Henley"
GROUP BY other_purchased_products
ORDER BY quantity DESC

/*
Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017.
For example, 100% product view then 40% add_to_cart and 10% purchase.
Add_to_cart_rate = number product add to cart/number product view.
Purchase_rate = number product purchase/number product view.
The output should be calculated in product level.
*/
WITH num_product_view AS(
  SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
    ,COUNT(product.productSKU) AS num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) hits
    ,UNNEST(hits.product) product
  WHERE _table_suffix BETWEEN '0101' AND '0331'
    AND eCommerceAction.action_type = '2'
  GROUP BY month
),

num_addtocart AS(
  SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
    ,COUNT(product.productSKU) AS num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) hits
    ,UNNEST(hits.product) product
  WHERE _table_suffix BETWEEN '0101' AND '0331'
    AND eCommerceAction.action_type = '3'
  GROUP BY month
),

num_purchase AS(
  SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
    ,COUNT(product.productSKU) AS num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) hits
    ,UNNEST(hits.product) product
  WHERE _table_suffix BETWEEN '0101' AND '0331'
    AND product.productRevenue IS NOT NULL
    AND eCommerceAction.action_type = '6'
  GROUP BY month
)

SELECT view.month
  ,num_product_view
  ,num_addtocart
  ,num_purchase
  ,ROUND(100 * num_addtocart / num_product_view, 2) AS add_to_cart_rate
  ,ROUND(100 * num_purchase / num_product_view, 2) AS purchase_rate
FROM num_product_view view
LEFT JOIN num_addtocart cart ON view.month = cart.month
LEFT JOIN num_purchase purchase ON cart.month = purchase.month
ORDER BY view.month

--Another Solution: count(case when) OR sum(case when)

WITH product AS(
  SELECT
      FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS month,
      COUNT(CASE WHEN eCommerceAction.action_type = '2' THEN product.v2ProductName END) AS num_product_view,
      COUNT(CASE WHEN eCommerceAction.action_type = '3' THEN product.v2ProductName END) AS num_add_to_cart,
      COUNT(CASE WHEN eCommerceAction.action_type = '6' AND product.productRevenue IS NOT NULL THEN product.v2ProductName END) AS num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) AS hits
    ,UNNEST (hits.product) AS product
  WHERE _table_suffix BETWEEN '0101' AND '0331'
  AND eCommerceAction.action_type IN ('2','3','6')
  GROUP BY month
  ORDER BY month
)

SELECT
  *
  ,ROUND(100 * num_add_to_cart/num_product_view, 2) AS add_to_cart_rate
  ,ROUND(100 * num_purchase/num_product_view, 2) AS purchase_rate
FROM product
