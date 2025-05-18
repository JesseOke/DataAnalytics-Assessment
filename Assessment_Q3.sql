-- Query to identify inactive savings/investment plans with no transactions in the past 12+ months
SELECT
  A.plan_id,
  A.owner_id,

  -- Classify the plan as either 'Investment', 'Savings', or 'Inactive_Plan'
  CASE 
      WHEN B.is_a_fund = 1 
      OR  B.is_fixed_investment = 1 
      THEN 'Investment'
      WHEN B.is_regular_savings = 1 
      OR  B.open_savings_plan = 1 
      THEN 'Savings'
    ELSE 'Inactive_Plan'
  END AS type,

  -- Get the most recent transaction date for the plan
  MAX(CAST(A.transaction_date AS DATE)) AS last_transaction_date,

  -- Calculate inactivity period in days since the last transaction
  GREATEST(DATEDIFF(CURDATE(), MAX(A.transaction_date)), 1) AS Inactivity_days

FROM 
  savings_savingsaccount AS A
JOIN 
  plans_plan AS B ON A.plan_id = B.id

-- Filter out plans that don't qualify as either 'Savings' or 'Investment'
WHERE 
  CASE 
     WHEN B.is_a_fund = 1 
      OR  B.is_fixed_investment = 1 
      THEN 'Investment'
      WHEN B.is_regular_savings = 1 
      OR  B.open_savings_plan = 1 
      THEN 'Savings'
    ELSE 'Inactive_Plan'
  END != 'Inactive_Plan'

-- Group by plan and owner to aggregate transactions per plan
GROUP BY 
  A.plan_id, A.owner_id, type

-- Only include plans that have been inactive for more than 365 days
HAVING 
  GREATEST(DATEDIFF(CURDATE(), MAX(A.transaction_date)), 1) - 365 >= 1

-- Sort results by most inactive first
ORDER BY 
  Inactivity_days;
