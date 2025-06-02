-- CTE to calculate total transactions, active months, and average transactions per month for each user
WITH P1 AS (
  SELECT
    owner_id,
    
    -- Total number of transactions made by the user
    COUNT(confirmed_amount) AS total_transactions,
    
    -- Count of unique months in which the user made at least one transaction
    COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')) AS active_months,
    
    -- Average number of transactions per active month
    ROUND(
      COUNT(confirmed_amount) / 
      COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m'))
    ) AS avg_transactions_per_month
  FROM
    savings_savingsaccount
  GROUP BY
    owner_id
)

-- Final aggregation: group users into frequency categories
SELECT 
  -- Classify users based on their average monthly transaction frequency
  CASE 
    WHEN A.avg_transactions_per_month >= 10 THEN 'High Frequency'
    WHEN A.avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
    ELSE 'Low Frequency'
  END AS Frequency_Category,

  -- Number of distinct customers in each frequency category
  COUNT(DISTINCT B.id) AS customer_count,

  -- Average transaction frequency within each category
  ROUND(AVG(A.avg_transactions_per_month), 1) AS avg_transactions_per_month

FROM 
  P1 AS A
JOIN users_customuser AS B ON A.owner_id = B.id

GROUP BY 
  Frequency_Category

-- Sort output by average monthly transactions (ascending)
ORDER BY 
  avg_transactions_per_month;
