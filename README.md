# Customer Lifetime Value (CLV) Segmentation — Telecom (SQL)

A beginner-friendly, data-to-insight walkthrough for a telecom provider (NexaSat). This README ties **raw data** → **EDA artifacts** → **segments** → **recommendations**, using downloadable CSVs produced from SQL.

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

This project is organized around a single raw table and derived CSV outputs. Populate the raw CSV, run the SQL, and each **derived CSV** will fall out of the queries.

### Raw table (input)
- **`nexa_sat_template.csv`** — [download](sandbox:/mnt/data/nexa_sat_template.csv)  
  Schema: `customer_id, gender, partner, dependents, senior_citizen, call_duration, data_usage, plan_type, plan_level, monthly_bill_amount, tenure_months, multiple_lines, tech_support, churn`

### Derived tables & analysis outputs
- **Existing users (no churn)**  
  `existing_users_template.csv` — [download](sandbox:/mnt/data/existing_users_template.csv)
- **EDA results**
  - `eda_current_users.csv` — [download](sandbox:/mnt/data/eda_current_users.csv)
  - `eda_users_by_plan_level.csv` — [download](sandbox:/mnt/data/eda_users_by_plan_level.csv)
  - `eda_total_revenue.csv` — [download](sandbox:/mnt/data/eda_total_revenue.csv)
  - `eda_revenue_by_plan_level.csv` — [download](sandbox:/mnt/data/eda_revenue_by_plan_level.csv)
  - `eda_churn_by_plan_type_and_level.csv` — [download](sandbox:/mnt/data/eda_churn_by_plan_type_and_level.csv)
  - `eda_avg_tenure_by_plan_level.csv` — [download](sandbox:/mnt/data/eda_avg_tenure_by_plan_level.csv)
- **Segment & offer artifacts**
  - `segments_avg_bill_and_tenure.csv` — [download](sandbox:/mnt/data/segments_avg_bill_and_tenure.csv)
  - `segments_support_and_lines_pct.csv` — [download](sandbox:/mnt/data/segments_support_and_lines_pct.csv)
  - `segments_revenue.csv` — [download](sandbox:/mnt/data/segments_revenue.csv)
  - `xsell_tech_support_senior_citizens.csv` — [download](sandbox:/mnt/data/xsell_tech_support_senior_citizens.csv)
  - `xsell_multiple_lines_partners_dependents.csv` — [download](sandbox:/mnt/data/xsell_multiple_lines_partners_dependents.csv)
  - `upsell_premium_discount_churn_risk.csv` — [download](sandbox:/mnt/data/upsell_premium_discount_churn_risk.csv)
  - `upsell_basic_to_premium_stats.csv` — [download](sandbox:/mnt/data/upsell_basic_to_premium_stats.csv)

> Prefer a single download? Grab the bundle: **telecom_csv_templates.zip** — [download](sandbox:/mnt/data/telecom_csv_templates.zip)

**Generating these CSVs from SQL** (example PostgreSQL `COPY` commands):
```sql
-- Create "existing_users"
CREATE TABLE existing_users AS
SELECT * FROM nexa_sat WHERE churn = 0;

-- EDA: counts & revenue
\copy (SELECT COUNT(customer_id) AS current_users FROM nexa_sat WHERE churn = 0) TO 'eda_current_users.csv' CSV HEADER;
\copy (SELECT plan_level, COUNT(customer_id) AS total_users FROM nexa_sat WHERE churn = 0 GROUP BY 1) TO 'eda_users_by_plan_level.csv' CSV HEADER;
\copy (SELECT ROUND(SUM(monthly_bill_amount::numeric), 2) AS revenue FROM nexa_sat) TO 'eda_total_revenue.csv' CSV HEADER;
\copy (SELECT plan_level, ROUND(SUM(monthly_bill_amount::numeric),2) AS revenue FROM nexa_sat GROUP BY 1 ORDER BY 2) TO 'eda_revenue_by_plan_level.csv' CSV HEADER;
\copy (
  SELECT plan_level, plan_type, COUNT(*) AS total_customers, SUM(churn) AS churn_count
  FROM nexa_sat GROUP BY 1,2 ORDER BY 1
) TO 'eda_churn_by_plan_type_and_level.csv' CSV HEADER;
\copy (SELECT plan_level, ROUND(AVG(tenure_months),2) AS avg_tenure FROM nexa_sat GROUP BY 1) TO 'eda_avg_tenure_by_plan_level.csv' CSV HEADER;

-- Segment scaffolding (illustrative; engineer your own scoring as needed)
-- Add CLV features/segments to existing_users for downstream exports
ALTER TABLE existing_users ADD COLUMN IF NOT EXISTS clv numeric;
ALTER TABLE existing_users ADD COLUMN IF NOT EXISTS clv_score numeric;
ALTER TABLE existing_users ADD COLUMN IF NOT EXISTS clv_segments text;
```

---

## Tools

- **SQL (PostgreSQL)** for EDA, feature engineering, and segmentation setup  
- Optional: **Python/Pandas** or BI tools to visualize the CSV outputs

---

## Objective

Identify **up-sell** and **cross-sell** opportunities by segmenting customers with a lightweight **CLV framework**, quantifying where revenue concentrates, and pinpointing churn-prone cohorts that would benefit from targeted offers.

---

## Key Findings & Insights

> These insights are designed to be **read directly from the CSVs** once populated. Below is the narrative thread for interpreting them in order:

1. **Base size & active users** — Start with `eda_current_users.csv`.  
   This anchors the denominator for later rates and segment sizes.
2. **Who’s on which plan?** — Use `eda_users_by_plan_level.csv`.  
   Spot imbalances (e.g., Basic-heavy base) that signal room for **upsell**.
3. **Where does revenue live?** — `eda_total_revenue.csv` + `eda_revenue_by_plan_level.csv`.  
   If Premium contributes a disproportionate share, **Premium expansion** becomes attractive.
4. **Where do we lose customers?** — `eda_churn_by_plan_type_and_level.csv`.  
   Any cluster (e.g., **Postpaid Basic**) with high churn_count is a candidate for **save** and **upgrade** plays.
5. **How loyal are users by plan?** — `eda_avg_tenure_by_plan_level.csv`.  
   Longer tenures in specific plans indicate better product–market fit and can guide **migration paths**.
6. **What defines valuable cohorts?** — Segment views:
   - `segments_revenue.csv`: **size × revenue** per segment
   - `segments_avg_bill_and_tenure.csv`: value/loyalty profile
   - `segments_support_and_lines_pct.csv`: attach-rate white space for **cross-sell**
7. **Who should we talk to next?** — Target lists:
   - `upsell_premium_discount_churn_risk.csv`: Basic users at risk → controlled **premium trials/discounts**
   - `xsell_tech_support_senior_citizens.csv`: Seniors without support → **care & protection** add-on
   - `xsell_multiple_lines_partners_dependents.csv`: Households likely to benefit from **multi-line bundles**
   - `upsell_basic_to_premium_stats.csv`: sanity-check uplift potential between plan levels

Read the CSVs sequentially to go from **“how big is the opportunity?”** to **“which customers do we target first?”**

---

## Recommendations

Based on the CSV reading order above, deploy a two-track plan:

**1) Revenue expansion (Upsell)**  
- Promote **Premium** to high-usage **Basic** users: use `upsell_basic_to_premium_stats.csv` to quantify expected ARPU uplift.
- Offer **timeboxed premium trials** or **discounts** for cohorts in `upsell_premium_discount_churn_risk.csv` to reduce friction and measure uplift vs. control.

**2) Margin-safe cross-sell**  
- **Tech Support** to seniors and heavy-callers (`xsell_tech_support_senior_citizens.csv`), framed as reliability/peace-of-mind.  
- **Multiple Lines** to customers with partners/dependents on Basic plans (`xsell_multiple_lines_partners_dependents.csv`), bundled with modest data add-ons.

**Operationalize**  
- Attach KPIs per campaign: **ARPU**, **attach rate**, **offer acceptance**, **30/60/90-day churn**.  
- Track outcomes by segment using `segments_revenue.csv` and refresh weekly.

---

## Project Scope Summary

1. **EDA (CSV outputs)**  
   `eda_*` files profile base size, plan mix, revenue concentration, churn clusters, and tenure patterns.
2. **Feature Engineering**  
   Add `clv`, `clv_score`, and `clv_segments` to `existing_users_template.csv` after computing scores in SQL/Python.
3. **Segmentation & Targeting**  
   Produce `segments_*` summaries and build **actionable lists** (`xsell_*`, `upsell_*`) for campaigns.
4. **Measurement**  
   Compare targeted cohorts vs. matched controls; update CSVs to monitor lift and retention.

> If you’re starting from scratch, load `nexa_sat_template.csv` into your database, run the SQL in **Data Sources**, and export each result to the corresponding CSV for the full pipeline.

---

## Outcome

A reproducible, CSV-driven storyline that converts **raw telecom data** into **clear go-to-market actions**:
- Stakeholders can open each CSV to understand **what’s happening** (EDA),
- See **who matters most** (segments),
- And **what to do next** (target lists and recommendations).

This structure supports rapid iteration and simple handoffs between data, marketing, and ops.
