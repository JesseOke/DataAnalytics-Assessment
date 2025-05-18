-- Identify savings/investment plans with no transactions in the past 12+ months
SELECT
  A.plan_id,
  A.owner_id,

  -- Categorize plan type based on associated flags
  CASE 
    WHEN B.is_a_fund = 1 OR B.is_fixed_investment = 1 THEN 'Investment'
    WHEN B.is_regular_savings = 1 OR B.open_savings_plan = 1 THEN 'Savings'
    ELSE 'Inactive_Plan'
  END AS type,

  -- Latest transaction date for the plan
  MAX(CAST(A.transaction_date AS DATE)) AS last_transaction_date,

  -- Number of days since the last transaction (minimum 1)
  GREATEST(DATEDIFF(CURDATE(), MAX(A.transaction_date)), 1) AS inactivity_days

FROM 
  savings_savingsaccount AS A
JOIN 
  plans_plan AS B ON A.plan_id = B.id

-- Include only valid savings or investment plans
WHERE 
  CASE 
    WHEN B.is_a_fund = 1 OR B.is_fixed_investment = 1 THEN 'Investment'
    WHEN B.is_regular_savings = 1 OR B.open_savings_plan = 1 THEN 'Savings'
    ELSE 'Inactive_Plan'
  END != 'Inactive_Plan'

-- Aggregate by plan and owner
GROUP BY 
  A.plan_id, A.owner_id, type

-- Filter plans inactive for more than 365 days
HAVING 
  GREATEST(DATEDIFF(CURDATE(), MAX(A.transaction_date)), 1) >= 365

-- Sort by longest inactivity period first
ORDER BY 
  inactivity_days DESC;
