-- CTE to count the number of savings and investment plans per user
WITH P1 AS (
  SELECT
    owner_id,
    -- Count savings plans (e.g., regular and open savings plans)
    SUM(is_regular_savings) + SUM(open_savings_plan) AS savings_count,
    -- Count investment plans (e.g., fund and fixed investment types)
    SUM(is_a_fund) + SUM(is_fixed_investment) AS investment_count
  FROM 
    plans_plan
  GROUP BY 
    owner_id
  HAVING 
    -- Include only users who have at least one savings AND one investment plan
    SUM(is_regular_savings) + SUM(open_savings_plan) >= 1
    AND SUM(is_a_fund) + SUM(is_fixed_investment) >= 1
),

-- CTE to calculate total confirmed deposits per user
P2 AS (
  SELECT
    owner_id,
    -- Convert from base unit (e.g., kobo) to full currency and format to 2 decimal places
    FORMAT(SUM(confirmed_amount) / 100.0, 2) AS total_deposits
  FROM 
    savings_savingsaccount
  GROUP BY 
    owner_id
)

-- Final output: combine user info with savings/investment counts and total deposits
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
-- Sort users by total deposit amount in descending order (convert formatted value to numeric)
ORDER BY
  CAST(REPLACE(B.total_deposits, ',', '') AS DECIMAL) DESC;
