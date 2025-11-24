SELECT COUNT(*) AS total_rows
FROM clean_master;

SELECT 
    SUM(amount) AS total_sales
FROM clean_master;

SELECT COUNT(DISTINCT order_id) AS total_orders
FROM clean_master;

SELECT 
    SUM(quantity) AS total_quantity
FROM clean_master;

SELECT 
    SUM(promo_flag) AS promo_orders,
    COUNT(*) AS total_rows,
    ROUND( (SUM(promo_flag) / COUNT(*)) * 100 , 2 ) AS promo_usage_percent
FROM clean_master;


SELECT
    SUM(return_flag) AS total_returns,
    SUM(cancel_flag) AS total_cancellations,
    ROUND(SUM(return_flag) / COUNT(*) * 100, 2) AS return_rate_percent,
    ROUND(SUM(cancel_flag) / COUNT(*) * 100, 2) AS cancel_rate_percent
FROM clean_master;


SELECT 
    category_clean,
    COUNT(*) AS order_count,
    SUM(amount) AS revenue
FROM clean_master
GROUP BY category_clean
ORDER BY revenue DESC;


SELECT 
    ship_city,
    COUNT(*) AS order_count,
    SUM(amount) AS revenue
FROM clean_master
GROUP BY ship_city
ORDER BY revenue DESC
LIMIT 20;


SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS order_count,
    SUM(amount) AS revenue
FROM clean_master
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

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
