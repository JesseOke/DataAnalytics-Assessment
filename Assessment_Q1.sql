-- CTE to count number of savings and investment plans per user
WITH P1 AS (
  SELECT
    owner_id,
    -- Count all types of savings plans
    SUM(is_regular_savings) + SUM(open_savings_plan) AS savings_count,
    -- Count all types of investment plans
    SUM(is_a_fund) + SUM(is_fixed_investment) AS investment_count
  FROM 
    plans_plan
  GROUP BY 
    owner_id
  HAVING 
    -- Only include users who have at least one savings and one investment plan
    SUM(is_regular_savings) + SUM(open_savings_plan)  >= 1
    AND SUM(is_a_fund) + SUM(is_fixed_investment)  >= 1
),

-- CTE to calculate total deposits per user
P2 AS (
  SELECT
    owner_id,
    -- Convert from base unit (e.g., kobo) to full currency and format with 2 decimal places
    FORMAT(SUM(confirmed_amount) / 100.0, 2) AS total_deposits
  FROM 
    savings_savingsaccount
  GROUP BY 
    owner_id
)

-- Final result: combine user info with savings/investment counts and total deposits
SELECT
  A.owner_id,
  CONCAT(C.first_name, ' ', C.last_name) AS name,
  A.savings_count,
  A.investment_count,
  B.total_deposits
FROM 
  users_customuser AS C
  JOIN P1 AS A ON A.owner_id = C.id
  JOIN P2 AS B ON B.owner_id = C.id
-- Order users by total deposit amount in descending order (converted to numeric for sorting)
ORDER BY
  CAST(REPLACE(B.total_deposits, ',', '') AS DECIMAL) DESC;
