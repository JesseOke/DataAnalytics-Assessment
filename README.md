
---

## Per-Question Explanations

 Question 1: Dual Product Customers with Total Deposits

**Objective**: Identify customers who have both savings and investment plans and show their total deposit amount.

**Approach**:
- Created a temporary table `P1` to count savings and investment plan types per customer using the `plans_plan` table.
- Filtered to include only users who have at least one of each (savings & investment).
- Joined with the `savings_savingsaccount` table (P2) to aggregate confirmed deposit amounts.
- Final output includes name, savings/investment counts, and total deposits, sorted by deposit volume.

---

 Question 2: Frequency Segmentation

**Objective**: Segment users by how frequently they perform transactions.

**Approach**:
- Calculated each user's transaction activity over active months to derive their average monthly transactions (`avg_transactions_per_month`).
- Applied logic to classify customers into:
  - High Frequency (≥ 10/month)
  - Medium Frequency (3–9/month)
  - Low Frequency (< 3/month)
- Displayed segment size (`customer_count`) and average transaction frequency per segment.

---

 Question 3: Inactive Plans

**Objective**: Identify investment or savings plans with no transaction activity for over 365 days.

**Approach**:
- Classified plans using logic based on flags (`is_a_fund`, `is_fixed_investment`, etc.).
- Excluded inactive plan types via `WHERE` clause.
- Used `MAX(transaction_date)` and `DATEDIFF` to compute inactivity period.
- Filtered to only show plans with inactivity of more than 365 days.

---

Question 4: Customer Lifetime Value (CLV)

**Objective**: Estimate the CLV of customers based on transaction data.

**Approach**:
- Assumed an average profit of **0.1%** per transaction.
- Calculated average profit per transaction per customer (`P1`).
- Computed tenure and transaction frequency, then used:
  
  ROUND(COUNT(B.transaction_reference) / TIMESTAMPDIFF(MONTH, MIN(A.created_on), CURDATE()) * 12 * C.avg_profit_per_transaction, 0)

- Final output includes tenure, transaction count, and estimated CLV (formatted with commas).

---

## Challenges & Resolutions

- **Filtering with Derived Columns**: My early use of `WHERE` on computed columns (e.g., `Inactivity_days`) resulted in errors. Resolved by moving conditions to the `HAVING` clause.
- **CASE Logic Filtering**: Filtering using `CASE` inside `WHERE` was tricky. Fixed it by repeating logical conditions separately for filters and for label generation.
- **Divide-by-Zero in Tenure Calculations**: Resolved potential division errors by wrapping tenure calculations with `GREATEST(..., 1)` to ensure a minimum denominator of 1.
- **Currency Formatting**: Used `FORMAT()` to add commas and improve readability for monetary values like `total_deposits` and `estimated_CLV`.

---


Jesse Momoh 
Data & FinOps Analyst 
📧  momoh.jesse.oke@gmail.com
🔗  https://www.linkedin.com/in/jesse-momoh-o-01010101010/

---

