# **1. Overview**
This project will leverage SQL to analyze a large eCommerce dataset from Google Analytics Public Dataset. By using SQL queries, I will uncover valuable insights into customer behavior and product performance. The findings from this analysis will be used to answer key business questions and drive data-driven decisions, such as optimizing marketing campaigns and improving product recommendations.

# **2. Tools and Technologies**
   - SQL
   - BigQuery

# **3. Requirements**
   The goal of this project is to write 8 SQL queries to answer specific business questions based on Google Analytics data that leverage the power of BigQuery for data exploration.

# **4. Data Exploration**
   
**Query 01**: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
<img src="https://i.imgur.com/MVVdmAU.png">
***
**Query 02**: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
<img src="https://i.imgur.com/upKJswi.png">
***
**Query 3**: Revenue by traffic source by week, by month in June 2017
<img src="https://i.imgur.com/cOgkfU6.png">
***
**Query 04**: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.
<img src="https://i.imgur.com/xr8JFCY.png">
***
**Query 05**: Average number of transactions per user that made a purchase in July 2017
<img src="https://i.imgur.com/A7ocsuQ.png">
***
**Query 06**: Average amount of money spent per session. Only include purchaser data in July 2017
<img src="https://i.imgur.com/FpsOb0k.png">
***
**Query 07**: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
<img src="https://i.imgur.com/B9iyMLY.png">
***
**Query 08**: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase.
Add_to_cart_rate = number product  add to cart/number product view. Purchase_rate = number product purchase/number product view. The output should be calculated in product level.
<img src="https://i.imgur.com/LvwKKM0.png">
