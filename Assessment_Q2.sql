-- CTE to calculate total transactions, active months, and average transactions per month for each user
WITH P1 AS (
  SELECT
    owner_id,
    COUNT(*) AS total_transactions,
    
    -- Calculate the number of months between first and last transaction (minimum of 1 to avoid division by zero)
    GREATEST(TIMESTAMPDIFF(MONTH, MIN(transaction_date), MAX(transaction_date)), 1) AS active_months,
    
    -- Average number of transactions per active month
    ROUND(COUNT(*) / GREATEST(TIMESTAMPDIFF(MONTH, MIN(transaction_date), MAX(transaction_date)), 1), 1) AS avg_transactions_per_month
  FROM
    savings_savingsaccount
  GROUP BY
    owner_id
)

-- Final aggregation to group customers by frequency category
SELECT 
  -- Categorize users based on their transaction frequency
  CASE 
    WHEN A.avg_transactions_per_month >= 10 THEN 'High Frequency'
    WHEN A.avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
    ELSE 'Low Frequency'
  END AS Frequency_Category,

  -- Count of unique customers in each frequency category
  COUNT(DISTINCT B.id) AS customer_count,

  -- Average transaction frequency for the category
  ROUND(AVG(A.avg_transactions_per_month), 1) AS avg_transactions_per_month

FROM 
  P1 AS A
JOIN users_customuser AS B ON A.owner_id = B.id

GROUP BY 
  Frequency_Category

-- Sort by average frequency per category (ascending)
ORDER BY 
  avg_transactions_per_month;
