📄 SQL VALIDATION SUMMARY 

Dataset: clean_master
Rows: 128,975
Database: MySQL 8.0.43
Validation Date: (You will add this when uploading)

1. Record Count Validation
SELECT COUNT(*) FROM clean_master;


Result: 128,975 rows 

2. Total Sales Validation
SELECT SUM(amount) FROM clean_master;


Result: ₹78,592,678.30 

3. Distinct Orders
SELECT COUNT(DISTINCT order_id) FROM clean_master;


Result: 120,378 orders 

4. Total Quantity Validation
SELECT SUM(quantity) FROM clean_master;


Result: 116,649 units 

5. Promotion Usage Validation
SELECT 
    SUM(promo_flag) AS promo_orders,
    COUNT(*) AS total_rows,
    (SUM(promo_flag)/COUNT(*)*100) AS promo_usage_percent
FROM clean_master;


Result:

Promo Orders = 79,822

Promo Usage = 61.89%

6. Return & Cancellation Validation
SELECT
    SUM(return_flag) AS total_returns,
    SUM(cancel_flag) AS total_cancellations,
    SUM(return_flag)/COUNT(*)*100 AS return_rate_percent,
    SUM(cancel_flag)/COUNT(*)*100 AS cancel_rate_percent
FROM clean_master;


Results:

Returns = 2,098 (1.63%)

Cancellations = 18,332 (14.21%) 

7. Category Revenue Distribution
SELECT category_clean, COUNT(*) AS order_count, SUM(amount) AS revenue
FROM clean_master
GROUP BY category_clean
ORDER BY revenue DESC;


Top Categories:

Set

Kurta

Western Dress

Top

Ethnic Dress

Clean distribution, logically consistent.

8. City-Level Revenue Distribution
SELECT ship_city, COUNT(*) AS order_count, SUM(amount) AS revenue
FROM clean_master
GROUP BY ship_city
ORDER BY revenue DESC
LIMIT 20;


Top Cities: Bengaluru, Hyderabad, Mumbai, New Delhi, Chennai, Pune…
Realistic metropolitan distribution.

9. Monthly Sales & Order Trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS order_count,
    SUM(amount) AS revenue
FROM clean_master
GROUP BY month
ORDER BY month;


Trend:

Dataset starts: March 2022

Peaks: April–May 2022

Ends: June 2022
No missing or corrupted months.

10. Final Integrity Summary
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,
    SUM(amount) AS total_revenue,
    SUM(quantity) AS total_quantity,
    SUM(promo_flag) AS promo_orders,
    SUM(return_flag) AS total_returns,
    SUM(cancel_flag) AS total_cancellations,
    MIN(order_date) AS min_date,
    MAX(order_date) AS max_date
FROM clean_master;


Integrity Snapshot:

Rows: 128,975

Orders: 120,378

Revenue: ₹78,592,678.30

Quantity: 116,649

Promo Orders: 79,822

Returns: 2,098

Cancellations: 18,332

Date Range: 2022-03-31 → 2022-06-29