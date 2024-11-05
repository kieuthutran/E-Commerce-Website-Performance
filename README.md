# **1. Overview**
This project will leverage SQL to analyze a large eCommerce dataset from Google Analytics Public Dataset. By using SQL queries, I will uncover valuable insights into customer behavior and product performance. The findings from this analysis will be used to answer key business questions and drive data-driven decisions, such as optimizing marketing campaigns and improving product recommendations.

# **2. Tools and Technologies**
   - SQL
   - BigQuery

# **3. Requirements**
   The goal of this project is to write 8 SQL queries to answer specific business questions based on Google Analytics data that leverage the power of BigQuery for data exploration.

# **4. Data Exploration**
   
**Query 01**: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
```php
SELECT 
   FORMAT_DATE("%Y%m",PARSE_DATE('%Y%m%d',date)) AS month
  ,SUM(totals.visits) AS visits
  ,SUM(totals.pageviews) AS pageviews
  ,SUM(totals.transactions) AS transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix BETWEEN '0101' AND '0331'
GROUP BY month
ORDER BY month
```
<img src="https://i.imgur.com/OPc2iY1.png">

**Observe**:

The number of visits and pageviews decreased from January to February, then increased slightly in March. The number of transactions increased from January to March.

**Further Investigation**:

* Were there any marketing campaigns or seasonal events that may have influenced the increase in visits in March?
* Were there any changes to the website structure or content that may have impacted user behavior?
* Were there any changes to the website's checkout process or pricing strategy that may have influenced the increase in conversions in March?

***

**Query 02**: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
```php
SELECT trafficSource.source
  ,SUM(totals.visits) AS total_visits
  ,SUM(totals.bounces) AS total_no_of_bounces
  ,ROUND(100.0 * (SUM(totals.bounces) / SUM(totals.visits)), 3) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY trafficSource.source
ORDER BY total_visits DESC
```
<img src="https://i.imgur.com/4muZn6I.png">

Bounce rate is a web traffic analysis metric that measures the percentage of website visitors who leave after viewing only one page.<br>

**Observe**:

* Google is the top traffic source with the highest number of visits (38400)
* YouTube has the highest bounce rate (66.73%). Direct traffic has a relatively low bounce rate (43.266%)
  
**Recommendations**:
  
* YouTube: Analyze the content on website that is being linked from YouTube. Is it relevant to the audience? Is it engaging and informative?
* Google: Improve website loading speed, optimize website design for better user experience, and ensure that content is relevant to search queries.

***

**Query 3**: Revenue by traffic source by week, by month in June 2017
```php
SELECT 'Month' as time_type
  ,FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS time
  ,trafficSource.source AS source
  ,ROUND(SUM(product.productRevenue)/1000000, 4) as revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
UNNEST (hits) hits,
UNNEST (hits.product) product
WHERE product.productRevenue IS NOT NULL
GROUP BY time, source

UNION ALL

SELECT 'Week' as time_type
  ,FORMAT_DATE("%Y%W", PARSE_DATE("%Y%m%d", date)) AS time
  ,trafficSource.source AS source
  ,ROUND(SUM(product.productRevenue)/1000000, 4) as revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`,
UNNEST (hits) hits,
UNNEST (hits.product) product
WHERE product.productRevenue IS NOT NULL
GROUP BY time, source

ORDER BY revenue DESC
```
<img src="https://i.imgur.com/1Z12yhA.png">

**Observe**:

* Direct traffic was the top revenue driver in June 2017, generating the highest total revenue.
* Google contributed significantly to revenue, indicating the effectiveness of organic search and paid advertising.
* dfa contributed a smaller portion of the revenue, but it is still a valuable source of traffic.
* Some weeks had higher revenue than others, possibly due to specific marketing campaigns or events.
  
**Recommendations**:

* Implement strategies to maintain and increase direct traffic, such as email marketing, loyalty programs, and social media engagement.
* Identify the factors that influenced the weekly variations in revenue and leverage these insights to optimize future marketing efforts.

***

**Query 04**: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.
```php
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
```
<img src="https://i.imgur.com/X2zXmy0.png">

**Observe**:

* Increased Engagement: The average number of pageviews for purchasers increased from June to July
* Stable Engagement: The average number of pageviews for non-purchasers remained relatively stable between June and July.
* While the average pageviews for non-purchasers are higher than for purchasers, there is still room for improvement in converting them into customers.
  
**Recommendations**:

* Leverage Increased Engagement: Consider personalized recommendations, exclusive offers, or loyalty programs.
* Improve Non-Purchaser Conversion: Analyze the pages that non-purchasers frequently visit to identify opportunities for improvement, such as more persuasive content, or smoother checkout processes.

***

**Query 05**: Average number of transactions per user that made a purchase in July 2017
```php
SELECT
  FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
  ,SUM(totals.transactions) / COUNT(DISTINCT fullVisitorId) AS avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,UNNEST(hits) hits
  ,UNNEST(hits.product) product
WHERE totals.transactions >=1
  AND productRevenue IS NOT NULL
GROUP BY month
```
<img src="https://i.imgur.com/nNlW9BE.png">

**Observe**:

* Based on the query result, each customer who made a purchase during that month made 4.16 transactions on average.
* The high average number of transactions suggests that the business has successfully retained customers, which may come from successful product recommendations or effective marketing campaigns.
  
**Recommendations**:

* Implement strategies to maintain and enhance customer loyalty, such as personalized offers, loyalty programs, and exceptional customer service.
* Further analyze the data to identify the most effective product combinations and optimize recommendations.

***

**Query 06**: Average amount of money spent per session. Only include purchaser data in July 2017
```php
SELECT 
  FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
  ,ROUND((SUM(product.productRevenue)/1000000) / COUNT(totals.visits), 2) AS avg_revenue_by_user_per_visit
 FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,UNNEST(hits) hits
  ,UNNEST(hits.product) product
 WHERE totals.transactions IS NOT NULL
  AND product.productRevenue IS NOT NULL
 GROUP BY month
```
<img src="https://i.imgur.com/BbzD6oV.png">

**Observe**:

* Based on the query result, the average revenue generated per user per visit in July 2017 was $43.86.
* The relatively high average revenue per visit suggests that customers were making significant purchases during their sessions, which may come from the effectiveness of the website's conversion funnel or charging premium prices for its products.
  
**Recommendations**:

* Continuously analyze website performance to make improvements to the conversion funnel and use data to personalize product recommendations and marketing messages.
* Regularly review pricing strategy to ensure it aligns with customer value perception and market trends.

***

**Query 07**: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
```php
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
```
<img src="https://i.imgur.com/3PGfqL3.png">

**Observe**:

* Google Sunglasses: This product was purchased most frequently with the "YouTube Men's Vintage Henley," indicating a strong affinity between the two. This suggests potential cross-selling opportunities, such as bundling the products or promoting sunglasses to customers who purchased the Henley.
* Products like "Google Women's Vintage Hero Tee Black" and "SPF-15 Slim & Slender Lip Balm" were also frequently purchased with the Henley.
  
**Recommendations**:

Based on the co-purchase patterns, optimize inventory levels for products that are frequently purchased with the Henley and forecast future demand for these products.

***

**Query 08**: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017.<br>For example, 100% product view then 40% add_to_cart and 10% purchase.<br>Add_to_cart_rate = number product  add to cart/number product view.
<br>Purchase_rate = number product purchase/number product view. The output should be calculated in product level.
```php
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
```
<img src="https://i.imgur.com/qeDbNOH.png">

**Observe**:

The conversion rates increased month-over-month, which may be due to effectiveness from marketing campaigns, website design, or product offerings.

**Recommendations**:

* Improve product descriptions, images, and customer reviews to increase product views and add-to-cart rates.
* Simplify the checkout process and reduce friction to increase purchase rates.
* Use data on customer behavior to personalize product recommendations and increase conversion rates.
* Implement retargeting campaigns to re-engage users who abandoned their carts or viewed products without making a purchase.

