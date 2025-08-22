# Customer Lifetime Value (CLV) Segmentation — Telecom Growth Strategies

A concise, visual walkthrough that turns raw customer data into decisions. This version speaks to business leaders: it highlights the SQL we used to get the facts, shows data tables for fast comprehension, and draws clear implications for growth and retention.

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

We analyze a single warehouse table and a derived active-customer view. The pictures below are sample outputs to illustrate how results will look when you run the queries on live data.

```sql
-- Raw table
-- nexa_sat(customer_id, gender, partner, dependents, senior_citizen,
--          call_duration, data_usage, plan_type, plan_level,
--          monthly_bill_amount, tenure_months, multiple_lines,
--          tech_support, churn)

-- Active customers
CREATE TABLE existing_users AS
SELECT *
FROM nexa_sat
WHERE churn = 0;
```
<img width="1636" height="527" alt="shot_existing_users" src="https://github.com/user-attachments/assets/5a9de03f-1d58-457e-aaaf-dbabd4357459" />

---

## Tools

- **SQL (PostgreSQL)** to compute the metrics and cuts you see in the images.  
- Optional notebooks (Python/Pandas) only for creating the screenshot-like tables shown here.

---

## Objective

Direct growth by identifying **where revenue concentrates**, **which cohorts are churning**, and **who is most likely to respond** to targeted **upsell** and **cross-sell** offers—using a lightweight CLV lens that leaders can track weekly.

---

## Key Findings & Insights

**How large is our active base?**  
We begin by sizing the opportunity among non‑churned customers.

```sql
-- total users
SELECT COUNT(customer_id) AS current_users
FROM nexa_sat
WHERE churn = 0;
```
<img width="1047" height="527" alt="shot_current_users" src="https://github.com/user-attachments/assets/a013cae8-4c3f-4692-aaaa-c6c0c3765413" />

This gives us the denominator for all adoption, attach, and retention rates. Even modest percentage improvements translate into meaningful absolute gains at this scale.

**What is the plan mix among active users?**  
Next, we look at how customers are distributed across plan levels.

```sql
-- total users by level
SELECT plan_level, COUNT(customer_id) AS total_users
FROM nexa_sat
WHERE churn = 0
GROUP BY 1;
```
<img width="1140" height="527" alt="shot_users_by_plan" src="https://github.com/user-attachments/assets/afb04e1a-534d-4e14-83df-c5950c30fcc3" />

A **Basic‑heavy** mix signals clear headroom to move qualified customers to Premium. This is the first, simplest growth lever because it builds on existing relationships and pricing logic.

**Where does the money pool today?**  
We quantify total revenue and its split by plan level.

```sql
-- total revenue
SELECT ROUND(SUM(monthly_bill_amount::numeric), 2) AS revenue
FROM nexa_sat;
```
![Total revenue](sandbox:/mnt/data/shot_total_revenue.png)

```sql
-- revenue by plan level
SELECT plan_level, ROUND(SUM(monthly_bill_amount::numeric), 2) AS revenue
FROM nexa_sat
GROUP BY 1
ORDER BY 2;
```
![Revenue by plan level](sandbox:/mnt/data/shot_revenue_by_plan.png)

If **Premium over‑indexes** on revenue relative to its share of users, accelerating Premium adoption is a high‑confidence path to lift **ARPU** quickly without acquiring new customers.

**Where are the churn hotspots?**  
We drill down by plan type and level to locate risk concentrations.

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
![Churn by plan type & level](sandbox:/mnt/data/shot_churn_matrix.png)

Concentrated churn in **Postpaid Basic** suggests two plays: (1) **save‑offers** to stabilize at‑risk cohorts and (2) **guided upgrades** into Premium (particularly where support and extra lines add clear value).

**Which plans build loyalty?**  
Average tenure by plan level gives a quick read on product–market fit.

```sql
-- avg tenure by plan level
SELECT plan_level, ROUND(AVG(tenure_months), 2) AS avg_tenure
FROM nexa_sat
GROUP BY 1;
```
![Average tenure by plan level](sandbox:/mnt/data/shot_avg_tenure.png)

Longer tenures among **Premium** users—paired with the revenue mix above—support a Premium‑first migration strategy for qualified Basic customers.

**What’s in each plan—why will customers move?**  
A concise product snapshot aligns pricing, feature promises, and lock‑ins with the migration story.
![Plan catalog (illustrative)](sandbox:/mnt/data/shot_plan_catalog.png)

Clarity on included support and multi‑line value helps position upgrades as **reliable** and **fair**, not just more expensive.

**Who should we prioritize by value?**  
A CLV‑style roll‑up helps us focus effort where it compounds.
![CLV segment overview (illustrative)](sandbox:/mnt/data/shot_segment_scores.png)

In most telecom bases we see four practical segments: **High Value** (protect and expand), **Moderate** (prime for upsell), **Emerging** (nurture), and **At Risk** (stabilize fast). The sizes and economics in your live data will guide exact targets and sequencing.

---

## Recommendations

Taken together, the evidence supports a two‑track plan. **First, expand Premium** where the data shows strong tenure and revenue contribution. Start with high‑usage Basic cohorts and at‑risk customers who would benefit most from bundled support—offer **time‑boxed Premium trials** or **limited discounts** to lower friction, then convert based on realized value. **Second, cross‑sell high‑utility add‑ons** to close obvious gaps in the base: prioritize **Tech Support** for seniors and heavy callers to reduce perceived risk and service pain, and **Multi‑Line** bundles for partner/dependent households where the economics make sense. Operationally, manage this through weekly dashboards that track **ARPU**, **attach rate**, **offer acceptance**, and **30/60/90‑day churn** by segment; sunset low‑performing offers quickly and scale the winners.

---

## Project Scope Summary

This project is intentionally lightweight: a handful of SQL queries generate the views you saw in the pictures, which are then translated into clear actions. We start with EDA to size the base and locate revenue and churn patterns; we layer on simple CLV signals to prioritize; and we map those segments to offers that customers are likely to accept. Everything is designed to refresh weekly without dependency on complex modeling or heavy infrastructure.

---

## Outcome

Leaders get a repeatable path from **facts** to **action**: quantify the base, identify the value pools and risks, and deploy targeted upsell and cross‑sell plays with measurable lift. The visuals make it easy to align marketing, product, and care teams on why we’re moving customers, how we’ll do it, and how we’ll know it’s working.

