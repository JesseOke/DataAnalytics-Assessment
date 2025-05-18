-- Step 1: Calculate average profit per transaction for each customer
WITH P1 AS (
  SELECT
    owner_id,
    -- Assume 0.1% profit margin on confirmed amount (convert from kobo to naira)
    ROUND(AVG(confirmed_amount / 100.0 * 0.001), 0) AS avg_profit_per_transaction
  FROM 
    savings_savingsaccount
  GROUP BY 
    owner_id
),

-- Step 2: Estimate customer lifetime value (CLV)
P2 AS (
  SELECT
    A.id AS customer_id,
    CONCAT(A.first_name, ' ', A.last_name) AS name,

    -- Customer tenure in months (minimum 1 to prevent division by zero)
    GREATEST(TIMESTAMPDIFF(MONTH, MIN(A.created_on), CURDATE()), 1) AS tenure_months,

    -- Total number of transactions
    COUNT(B.transaction_reference) AS total_transactions,

    -- CLV = (avg transactions/month) × 12 × avg profit per transaction
    ROUND(
      COUNT(B.transaction_reference) / TIMESTAMPDIFF(MONTH, MIN(A.created_on), CURDATE()) 
      * 12 * C.avg_profit_per_transaction,
      0
    ) AS estimated_CLV_numeric

  FROM 
    users_customuser AS A
  JOIN 
    savings_savingsaccount AS B ON A.id = B.owner_id
  JOIN 
    P1 AS C ON C.owner_id = B.owner_id
  GROUP BY 
    A.id, A.first_name, A.last_name, C.avg_profit_per_transaction
)

-- Step 3: Final output of estimated CLV per customer
SELECT 
  customer_id,
  name,
  tenure_months,
  FORMAT(total_transactions, 0) AS total_transactions, 
  FORMAT(estimated_CLV_numeric, 0) AS estimated_CLV    
FROM 
  P2
ORDER BY 
  estimated_CLV_numeric DESC;
