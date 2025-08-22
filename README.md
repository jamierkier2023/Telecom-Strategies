# Customer Lifetime Value (CLV) Segmentation — Telecom (SQL)

A beginner-friendly, data-to-insight walkthrough for a telecom provider (NexaSat). This README ties **raw data** → **EDA artifacts** → **segments** → **recommendations**, now using **readable PDF tables** exported from SQL.

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

# ---------- EDA output templates ----------
# total current users (single-value)
df = pd.DataFrame(columns=["current_users"])
p = base / "eda_current_users.csv"
df.to_csv(p, index=False)
assets.append((p.name, "Result of `COUNT(customer_id)` where churn = 0."))

# users by plan level
df = pd.DataFrame(columns=["plan_level","total_users"])
p = base / "eda_users_by_plan_level.csv"
df.to_csv(p, index=False)
assets.append((p.name, "Users by plan level (active users only)."))

# total revenue
df = pd.DataFrame(columns=["revenue"])
p = base / "eda_total_revenue.csv"
df.to_csv(p, index=False)
assets.append((p.name, "Total revenue (sum of monthly_bill_amount)."))

# revenue by plan level
df = pd.DataFrame(columns=["plan_level","revenue"])
p = base / "eda_revenue_by_plan_level.csv"
df.to_csv(p, index=False)
assets.append((p.name, "Revenue by plan level."))

# churn by plan type and level
df = pd.DataFrame(columns=["plan_level","plan_type","total_customers","churn_count"])
p = base / "eda_churn_by_plan_type_and_level.csv"
df.to_csv(p, index=False)
assets.append((p.name, "Churn counts grouped by plan type and level."))

# avg tenure by plan level
df = pd.DataFrame(columns=["plan_level","avg_tenure"])
p = base / "eda_avg_tenure_by_plan_level.csv"
df.to_csv(p, index=False)
assets.append((p.name, "Average tenure by plan level."))

## Data Sources

This project is organized around a single raw table and derived outputs. Populate the raw **PDF-ready** table, run the SQL, and export each **derived PDF**.

### Raw table (input)
- **`nexa_sat_template.pdf`** — [download](sandbox:/mnt/data/nexa_sat_template.pdf)  
  Columns: `customer_id, gender, partner, dependents, senior_citizen, call_duration, data_usage, plan_type, plan_level, monthly_bill_amount, tenure_months, multiple_lines, tech_support, churn`


### Derived tables & analysis outputs (PDF)
- **Existing users (no churn)**  
  `existing_users_template.pdf` — [download](sandbox:/mnt/data/existing_users_template.pdf)
- **EDA results**
  - `eda_current_users.pdf` — [download](sandbox:/mnt/data/eda_current_users.pdf)
  - `eda_users_by_plan_level.pdf` — [download](sandbox:/mnt/data/eda_users_by_plan_level.pdf)
  - `eda_total_revenue.pdf` — [download](sandbox:/mnt/data/eda_total_revenue.pdf)
  - `eda_revenue_by_plan_level.pdf` — [download](sandbox:/mnt/data/eda_revenue_by_plan_level.pdf)
  - `eda_churn_by_plan_type_and_level.pdf` — [download](sandbox:/mnt/data/eda_churn_by_plan_type_and_level.pdf)
  - `eda_avg_tenure_by_plan_level.pdf` — [download](sandbox:/mnt/data/eda_avg_tenure_by_plan_level.pdf)
- **Segment & offer artifacts**
  - `segments_avg_bill_and_tenure.pdf` — [download](sandbox:/mnt/data/segments_avg_bill_and_tenure.pdf)
  - `segments_support_and_lines_pct.pdf` — [download](sandbox:/mnt/data/segments_support_and_lines_pct.pdf)
  - `segments_revenue.pdf` — [download](sandbox:/mnt/data/segments_revenue.pdf)
  - `xsell_tech_support_senior_citizens.pdf` — [download](sandbox:/mnt/data/xsell_tech_support_senior_citizens.pdf)
  - `xsell_multiple_lines_partners_dependents.pdf` — [download](sandbox:/mnt/data/xsell_multiple_lines_partners_dependents.pdf)
  - `upsell_premium_discount_churn_risk.pdf` — [download](sandbox:/mnt/data/upsell_premium_discount_churn_risk.pdf)
  - `upsell_basic_to_premium_stats.pdf` — [download](sandbox:/mnt/data/upsell_basic_to_premium_stats.pdf)

> Prefer a single download? Get **telecom_pdf_tables.zip** — [download](sandbox:/mnt/data/telecom_pdf_tables.zip)

**Generating these PDFs from SQL**  
Export CSVs from your warehouse with `COPY TO`, then convert to PDF in your preferred tool (or reuse the included notebook scripts).

---

## Tools

- **SQL (PostgreSQL)** for EDA, feature engineering, and segmentation setup  
- Optional: **Python/Pandas + Matplotlib** to convert query results into the provided PDF tables

---

## Objective

Identify **up-sell** and **cross-sell** opportunities by segmenting customers with a lightweight **CLV framework**, quantifying where revenue concentrates, and pinpointing churn-prone cohorts that would benefit from targeted offers.

---

## Key Findings & Insights

Read the PDFs in this sequence to move from **base sizing** to **actionable targets**:

1. **Base size & active users** — `eda_current_users.pdf` establishes the active denominator.
2. **Plan mix** — `eda_users_by_plan_level.pdf` surfaces Basic-vs-Premium distribution (upsell headroom).
3. **Revenue concentration** — `eda_total_revenue.pdf` + `eda_revenue_by_plan_level.pdf` show where money pools.
4. **Churn hotspots** — `eda_churn_by_plan_type_and_level.pdf` pinpoints risky clusters (e.g., Postpaid Basic).
5. **Loyalty signal** — `eda_avg_tenure_by_plan_level.pdf` highlights stickier configurations.
6. **Value definition** — Segment summaries:
   - `segments_revenue.pdf` → size × revenue by segment
   - `segments_avg_bill_and_tenure.pdf` → value/loyalty profile
   - `segments_support_and_lines_pct.pdf` → attach-rate white space
7. **Actionable lists** — Prioritize outreach by the target PDFs:
   - `upsell_premium_discount_churn_risk.pdf`
   - `xsell_tech_support_senior_citizens.pdf`
   - `xsell_multiple_lines_partners_dependents.pdf`
   - `upsell_basic_to_premium_stats.pdf` (uplift sanity check)

---

## Recommendations

**Upsell — Premium migration**
- Timeboxed trials/discounts for churn-risk Basic users (`upsell_premium_discount_churn_risk.pdf`).
- Guided upgrades for high-usage Basic cohorts; validate uplift vs. control with `upsell_basic_to_premium_stats.pdf`.

**Cross-sell — High-utility add-ons**
- Tech Support to seniors / heavy-callers (`xsell_tech_support_senior_citizens.pdf`).
- Multi-line bundles for partner/dependent households (`xsell_multiple_lines_partners_dependents.pdf`).

**Ops**
- Track **ARPU**, **attach rate**, **offer acceptance**, **30/60/90-day churn** by segment; refresh the PDFs weekly.

---

## Project Scope Summary

1. **EDA PDFs** quantify base, mix, revenue, churn, and tenure.
2. **Feature Engineering** adds `clv`, `clv_score`, `clv_segments` to `existing_users`.
3. **Segmentation & Targeting** produce segment summaries and target lists (PDFs).
4. **Measurement** compares campaign cohorts vs. controls; iterate offers and re-export PDFs.

---

## Outcome

A compact, review-ready package: stakeholders can open the PDFs to see **what’s happening**, **who matters**, and **what to do next**, forming a clear bridge from **raw data** to **marketing action**.

