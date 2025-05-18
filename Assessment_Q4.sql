-- Step 1: CTE to Calculate the average profit per transaction for each customer
WITH P1 AS (
  SELECT
    owner_id,
    -- Assume 0.1% profit rate on confirmed amount (converted from kobo to Naira by dividing by 100)
    ROUND(AVG(confirmed_amount / 100.0 * 0.001), 0) AS avg_profit_per_transaction
  FROM 
    savings_savingsaccount
  GROUP BY owner_id
),

-- Step 2: CTE to Estimate customer lifetime value (CLV) using average profit and transaction frequency
P2 AS (
  SELECT
    A.id AS customer_id,
    CONCAT(A.first_name, ' ', A.last_name) AS name,
    
    -- Calculate customer's tenure in months, I used GREATEST to avoid dividing by Zero
    GREATEST(TIMESTAMPDIFF(MONTH, MIN(A.created_on), CURDATE()), 1) AS tenure_months,

    -- Count total transactions
    COUNT(B.transaction_reference) AS total_transactions,

    -- Estimate CLV = (avg transactions/month) × 12 months × avg profit per transaction
    ROUND(COUNT(B.transaction_reference) / TIMESTAMPDIFF(MONTH, MIN(A.created_on), CURDATE()) * 12 * C.avg_profit_per_transaction, 0) AS estimated_CLV_numeric
  FROM 
    users_customuser AS A
  JOIN savings_savingsaccount AS B ON A.id = B.owner_id
  JOIN P1 AS C ON C.owner_id = B.owner_id
  GROUP BY A.id, A.first_name, A.last_name, C.avg_profit_per_transaction
)

-- Step 3: Final output of customer CLV
SELECT 
  customer_id,
  name,
  tenure_months,
  FORMAT(total_transactions, 0) AS total_transactions, 
  FORMAT(estimated_CLV_numeric, 0) AS estimated_CLV    
FROM 
  P2
ORDER BY 
  estimated_CLV_numeric DESC; -- Sort customers by highest CLV
