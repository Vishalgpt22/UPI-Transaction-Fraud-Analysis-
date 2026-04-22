create database UPI_Analysis ;

use UPI_Analysis;

SELECT COUNT(*) AS total_transactions FROM upi_data;

SELECT COUNT(DISTINCT sender_bank) FROM upi_data;

SELECT MIN(timestamp), MAX(timestamp) FROM upi_data;


# Change Column Name 
ALTER TABLE upi_data CHANGE `amount_(inr)` `amount_inr` DECIMAL(10,2);

# Transactions by Hour
SELECT hour_of_day,
       COUNT(*) AS txn_count,
       SUM(amount_inr) AS total_amount
FROM upi_data
GROUP BY hour_of_day
ORDER BY hour_of_day;

# Fraud Rate by Hour
SELECT hour_of_day,
       COUNT(*) AS total_txn,
       SUM(fraud_flag) AS fraud_cases,
       ROUND(SUM(fraud_flag)*100.0/COUNT(*),2) AS fraud_rate
FROM upi_data
GROUP BY hour_of_day
ORDER BY fraud_rate desc;

# raud on Weekend vs Weekday
SELECT is_weekend,
       COUNT(*) AS total_txn,
       round(AVG(amount_inr),0) AS avg_amount,
      ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY is_weekend;

# Age Group Behavior
SELECT sender_age_group,
       COUNT(*) AS txn_count,
       round(avg(amount_inr),0) AS avg_amount,
       round(SUM(amount_inr),0) AS total_amount
FROM upi_data
GROUP BY sender_age_group
ORDER BY sender_age_group;

# Age Group Risk
SELECT sender_age_group,
       ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY sender_age_group
ORDER BY fraud_rate DESC;

# State-Level Analysis
SELECT sender_state,
       COUNT(*) AS total_txn,
        round(SUM(amount_inr)) AS total_amount,
      ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY sender_state
ORDER BY total_amount DESC;

# Bank Performance
SELECT sender_bank,
       COUNT(*) AS total_txn,
       round(SUM(amount_inr)) AS total_amount,
      ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY sender_bank
ORDER BY fraud_rate DESC;

# Bank-to-Bank Flow Analysis
SELECT sender_bank,
       receiver_bank,
       round(SUM(amount_inr)) AS total_flow
FROM upi_data
GROUP BY sender_bank, receiver_bank
ORDER BY total_flow DESC;

# Transaction Type Analysis
SELECT transaction_type,
       COUNT(*) AS total_txn,
       round(AVG(amount_inr)) AS avg_amount,
       ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY transaction_type;

# Merchant Category Analysis
SELECT merchant_category,
       COUNT(*) AS total_txn,
       round(SUM(amount_inr)) AS total_amount,
      ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY merchant_category
ORDER BY total_amount DESC;

# High-Risk Combinations Fraud Analysis
SELECT transaction_type,
       device_type,
       network_type,
       COUNT(*) AS total,
       ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY transaction_type, device_type, network_type
ORDER BY fraud_rate DESC
LIMIT 10;

# Fraud by Device
SELECT device_type,
       COUNT(*) AS total_txn,
       ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY device_type;

# Fraud by Network
SELECT network_type,
       COUNT(*) AS total_txn,
       ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY network_type;

# Rolling Fraud Trend
SELECT 
    DATE(timestamp) AS date,
    AVG(fraud_flag) AS daily_fraud_rate,
    AVG(AVG(fraud_flag)) OVER (
        ORDER BY DATE(timestamp)
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS rolling_fraud_rate
FROM upi_data
GROUP BY DATE(timestamp);

# Rank of High-Risk States
SELECT sender_state,
       ROUND(AVG(fraud_flag)*100,2) AS fraud_rate,
       RANK() OVER (ORDER BY AVG(fraud_flag) DESC) AS risk_rank
FROM upi_data
GROUP BY sender_state;

# PEAK vs NON-PEAK Hour Fraud Analysis
SELECT 
    CASE 
        WHEN hour_of_day BETWEEN 18 AND 23 THEN 'Peak Hours'
        ELSE 'Non-Peak Hours'
    END AS time_segment,
    COUNT(*) AS total_txn,
    ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY time_segment;

# High Values Transactions Risk
SELECT 
    CASE 
        WHEN amount_inr > 10000 THEN 'High Value'
        ELSE 'Normal'
    END AS txn_type,
    COUNT(*) AS total_txn,
    ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY txn_type;

# Failure Analysis
SELECT transaction_status,
       COUNT(*) AS total_txn,
       ROUND(AVG(amount_inr),0) AS avg_amount
FROM upi_data
GROUP BY transaction_status;

# Failure by Network + Device
SELECT network_type,
       device_type,
       COUNT(*) AS failed_txn
FROM upi_data
WHERE transaction_status != 'SUCCESS'
GROUP BY network_type, device_type
ORDER BY failed_txn DESC;

# Day Wise Trend
SELECT day_of_week,
       COUNT(*) AS total_txn,
       ROUND(SUM(amount_inr),0) AS total_amount,
       ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY day_of_week
ORDER BY total_txn DESC;

# TOP RISKY SEGMENTS
SELECT sender_age_group,
       sender_state,
       COUNT(*) AS total_txn,
       ROUND(AVG(fraud_flag)*100,2) AS fraud_rate
FROM upi_data
GROUP BY sender_age_group, sender_state
HAVING COUNT(*) > 50
ORDER BY fraud_rate DESC
LIMIT 10;

# Fraud Contribution Analysis
SELECT sender_bank,
       SUM(fraud_flag) AS total_fraud_cases,
      ROUND(SUM(fraud_flag)*100.0 / (SELECT SUM(fraud_flag) FROM upi_data),2) AS contribution_pct
FROM upi_data
GROUP BY sender_bank
ORDER BY contribution_pct DESC;

# Transaction Intensity
SELECT hour_of_day,
       COUNT(*) AS txn_count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),2) AS percentage_share
FROM upi_data
GROUP BY hour_of_day 
order by percentage_share desc;

# Anomaly Detection Query
SELECT *
FROM upi_data
WHERE amount_inr > (
    SELECT AVG(amount_inr) + 2 * STDDEV(amount_inr)
    FROM upi_data
);

# Moving Avg Transaction Trend
SELECT 
    DATE(timestamp) AS date,
    COUNT(*) AS txn_count,
    AVG(COUNT(*)) OVER (
        ORDER BY DATE(timestamp)
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS moving_avg
FROM upi_data
GROUP BY DATE(timestamp);


