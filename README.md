
---

## Per-Question Explanations

 Question 1: High-Value Customers with Multiple Products

**Objective**: Identify customers who have both savings and investment plans and show their total deposit amount.

**Approach**:
- Created a temporary table `P1` to count savings and investment plan types per customer using the `plans_plan` table.
- Filtered to include only users who have at least one of each (savings & investment).
- Joined with the `savings_savingsaccount` table (P2) to aggregate confirmed deposit amounts.
- Final output includes name, savings/investment counts, and total deposits, sorted by deposit volume.

---

 Question 2: Transaction Frequency Analysis

**Objective**: Segment users by how frequently they perform transactions.

**Approach**:
- Calculated each user’s total transaction count using COUNT(transaction_reference) on savings_savingsaccount.
  Determined active months by counting the distinct year–month combinations in which a transaction occurred:
  COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')) AS active_months
- Applied logic to classify customers into:
  - High Frequency (≥ 10/month)
  - Medium Frequency (3–9/month)
  - Low Frequency (< 3/month)
- Displayed segment size (`customer_count`) and average transaction frequency per segment.

---

 Question 3: Account Inactivity Alert

**Objective**: Identify investment or savings plans with no transaction activity for over 365 days.

**Approach**:
- Classified plans using logic based on flags (`is_a_fund`, `is_fixed_investment`, etc.).
- Excluded inactive plan types via `WHERE` clause.
- Used `MAX(transaction_date)` and `DATEDIFF` to compute inactivity period.
- Filtered to only show plans with inactivity of more than 365 days.

---

Question 4: Customer Lifetime Value (CLV) Estimation

**Objective**: Estimate the CLV of customers based on transaction data.

**Approach**:
- Assumed an average profit of **0.1%** per transaction.
- Calculated average profit per transaction per customer (`P1`).
- Computed tenure and transaction frequency, then used:
  
  ROUND(COUNT(B.transaction_reference) / TIMESTAMPDIFF(MONTH, MIN(A.created_on), CURDATE()) * 12 * C.avg_profit_per_transaction, 0)

- Final output includes tenure, transaction count, and estimated CLV (formatted with commas).

---

## Challenges & Solutions

Inconsistent Data Filtering Logic
**Issue:** Early attempts to filter plan types (`Savings`, `Investment`) in the `WHERE` clause failed due to derived columns.

**Solution:** Moved logic into `CASE` expressions used in both SELECT and WHERE clauses to ensure consistency, used `HAVING` to filter aggregated fields.

---

Zero Division and NULL Handling
**Issue:** Some users had only one transaction month, causing potential divide-by-zero in averages.

**Solution:** Used `GREATEST(..., 1)` to prevent zero division in time-based calculations.

---

CLV Estimation Logic
**Issue:** Estimating profit per user required a standard assumption for profit margins.

**Solution:** Used 0.1% of each `confirmed_amount` as proxy profit. Adjusted in later revisions for realism.




---


Jesse Momoh 
Data Analyst 
📧  momoh.jesse.oke@gmail.com
🔗  https://www.linkedin.com/in/jesse-momoh-o-01010101010/



