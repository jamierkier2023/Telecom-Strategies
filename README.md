# Customer Lifetime Value (CLV) Segmentation — Telecom (SQL-first, Screenshot Edition)

A beginner-friendly, **SQL-forward** walkthrough for a telecom provider (NexaSat). This version mirrors the earlier structure but replaces file downloads with **highlighted SQL blocks** and **mini “screenshot-style” tables** rendered from example outputs.

---

## Table of Contents
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Objective](#objective)
- [Key Findings & Insights](#key-findings--insights)
- [Recommendations](#recommendations)
- [Project Scope Summary](#project-scope-summary)
- [Outcome](#outcome)

---

## Data Sources

All analyses start from a single warehouse table:

```sql
-- Raw table
-- nexa_sat(customer_id, gender, partner, dependents, senior_citizen,
--          call_duration, data_usage, plan_type, plan_level,
--          monthly_bill_amount, tenure_months, multiple_lines,
--          tech_support, churn)
```

Derived table for non-churned users:

```sql
-- Keep active customers only
CREATE TABLE existing_users AS
SELECT *
FROM nexa_sat
WHERE churn = 0;
```
![existing users](sandbox:/mnt/data/shot_existing_users.png)

---

## Tools

- **SQL (PostgreSQL)** for EDA, feature engineering, and segmentation
- Optional notebooks (Python/Pandas) to render result **preview images** like the ones embedded below

---

## Objective

Identify **up-sell** and **cross-sell** opportunities by segmenting customers with a lightweight **CLV lens**, quantifying revenue concentration and churn hotspots, and turning those signals into targeted actions.

---

## Key Findings & Insights

Below, each insight pairs a **concise SQL block** with a **mini table** showing a representative output.

### 1) Active base size

```sql
-- total users
SELECT COUNT(customer_id) AS current_users
FROM nexa_sat
WHERE churn = 0;
```
![current users](sandbox:/mnt/data/shot_current_users.png)

**So what?** Establishes the denominator for rates (adoption, attach, churn).

---

### 2) Plan mix among active users

```sql
-- total users by level
SELECT plan_level, COUNT(customer_id) AS total_users
FROM nexa_sat
WHERE churn = 0
GROUP BY 1;
```
![users by plan](sandbox:/mnt/data/shot_users_by_plan.png)

**So what?** A **Basic-heavy** mix implies **upsell headroom** for Premium packages.

---

### 3) Revenue concentration

```sql
-- total revenue
SELECT ROUND(SUM(monthly_bill_amount::numeric), 2) AS revenue
FROM nexa_sat;
```
![total revenue](sandbox:/mnt/data/shot_total_revenue.png)

```sql
-- revenue by plan level
SELECT plan_level, ROUND(SUM(monthly_bill_amount::numeric), 2) AS revenue
FROM nexa_sat
GROUP BY 1
ORDER BY 2;
```
![revenue by plan](sandbox:/mnt/data/shot_revenue_by_plan.png)

**So what?** If Premium over-indexes on revenue share, expanding Premium adoption can move ARPU quickly.

---

### 4) Churn hotspots

```sql
-- churn count by plan type and plan level
SELECT
  plan_level,
  plan_type,
  COUNT(*) AS total_customers,
  SUM(churn) AS churn_count
FROM nexa_sat
GROUP BY 1, 2
ORDER BY 1;
```
![churn matrix](sandbox:/mnt/data/shot_churn_matrix.png)

**So what?** Concentrated churn in **Postpaid Basic** suggests save-and-upgrade plays (e.g., trial Premium with support).

---

### 5) Loyalty signal by plan

```sql
-- avg tenure by plan level
SELECT plan_level, ROUND(AVG(tenure_months), 2) AS avg_tenure
FROM nexa_sat
GROUP BY 1;
```
![avg tenure](sandbox:/mnt/data/shot_avg_tenure.png)

**So what?** **Premium** users display longer tenure, supporting the case for **guided migrations** from Basic.

---

---

### 6) Plan catalog (context for offers)

```sql
-- Reference product table (illustrative)
-- plan_type, plan_level, base_price, includes, add_ons, lock_in
```
![plan catalog](sandbox:/mnt/data/shot_plan_catalog.png)

**So what?** Understanding included features and lock-ins helps design **migration paths** and price ladders that feel fair.

---

### 7) CLV segment overview (who to target)

```sql
-- Example rollup (your warehouse query may differ)
-- SELECT clv_segment, COUNT(*)/SUM(COUNT(*)) OVER() AS size_pct,
--        SUM(monthly_bill_amount)/SUM(SUM(monthly_bill_amount)) OVER() AS revenue_share_pct,
--        AVG(monthly_bill_amount) AS avg_bill, AVG(tenure_months) AS avg_tenure_mo,
--        AVG(tech_support::int) AS tech_support_pct, AVG(multiple_lines::int) AS multi_line_pct
-- FROM existing_users GROUP BY 1;
```
![segment scores](sandbox:/mnt/data/shot_segment_scores.png)

**So what?** **High Value** merits retention perks and cross-sells; **Moderate** is prime for guided upsell; **Emerging** gets nurturing; **At Risk** receives save-offers and simplified upgrades.


## Recommendations

**Upsell**
- Offer **timeboxed Premium trials/discounts** to Basic cohorts in churn-prone segments.
- Prioritize **high-usage Basic** users first; they are most likely to realize value.

**Cross-sell**
- Attach **Tech Support** to seniors/heavy-callers to reduce friction and perceived risk.
- Promote **Multiple Lines** bundles to partner/dependent households on Basic plans.

**Execution**
- Attach KPIs per offer: **ARPU**, **attach rate**, **offer acceptance**, **30/60/90-day churn**.
- Run A/B or geo-split tests; iterate based on lift and retention.

---

## Project Scope Summary

1. **EDA** — base size, plan mix, revenue concentration, churn hotspots, tenure patterns (queries above).  
2. **Feature Engineering** — add CLV/propensity features (tenure, ARPU, usage, churn risk).  
3. **Segmentation** — bucket by CLV score; create **targetable** cohorts.  
4. **Targeting & Measurement** — launch offers, track KPIs, and refresh dashboards.

---

## Outcome

A self-contained, SQL-first storyline that converts **raw tables** into **actionable marketing plays**, with mini screenshot previews to align data, marketing, and ops around the same facts.
 
