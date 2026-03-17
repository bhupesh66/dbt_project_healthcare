# 🏥 Healthcare Analytics dbt Project: Weight Loss & BMI Transformation

## 📌 Project Overview
This dbt project turns raw patient measurement data into actionable insights. It helps track user progress, measure success milestones, and analyze long-term retention.

The given data/ source tables ie. users, cases, measurements are append only, meaning everytime a record is updated in production a new row is inserted. Nothing is changed in previous data.

This means a user who has changed their status, let's say 4 times, has 4 rows in users table. The table is ever growing.

Here, we will approach this project with 3 layer architecture, medallion architecture of bronze (staging), silver (intermediate) and gold (marts).

Staging/bronze is where we deduplicate the source table, rename columns, cast types, basically a data cleaning stage. No business logic is written in this stage and is materialised as a View.

Intermediate/ silver is where we write business logics which is the building blocks of the whole project and is also materialised as a view.

Marts/ gold layer is where answer ready facts table are stored and is the answer we are looking for. This layer is consumed by analysts for reporting and BI tools and is materialised as a Table.We have also done dimensional modelling(fact and dimensional table ) here along with all metrics in aggregated fact table.



---

## 🏗 Data Architecture

The project follows a modular dbt structure:  

### 1️⃣ Staging Layer (`models/staging/`)
- **measurements_staging:** Cleans raw weight and height logs  
- **users_staging:** Standardizes user metadata and demographics  

### 2️⃣ Intermediate Layer (`models/intermediate/`)
- **user_initial_bmi:** Establishes the baseline for each user using their first valid weight and height  

### 3️⃣ Marts / Core Layer

#### Star Schema

We use a **Star Schema** for fast queries and data integrity.

**Dimension Tables:**
- **dim_user:** Patient demographics (Gender, Age, Signup Date)  
- **date_dim:** Centralized calendar for time-series analysis and cohort grouping  

**Fact Tables:**
- **fact_weight_and_bmi_progress:** Tracks every measurement event, calculates BMI, and records weight change from baseline. This table powers most analytics and reports.  

---

## 🌟 Core Analytics Models (Marts Layer)

### 1️⃣ Clinical Success Outcomes (`fct_user_success_outcomes.sql`)
- **Metric:** % of Users Achieving Clinical Success  
- **What it Measures:** Users reaching ≥5% weight loss from baseline  
- **Why it Matters:** Demonstrates program effectiveness to stakeholders  

### 2️⃣ Monthly Retention Cohorts (`fct_monthly_retention_cohorts.sql`)
- **Metric:** Retention Rate per Month  
- **What it Measures:** Tracks active users month-over-month from their first measurement  
- **Why it Matters:** Identifies churn points to improve engagement  

### 3️⃣ Gender Health Distribution (`fct_gender_monthly_health_distribution.sql`)
- **Metric:** Average BMI by Gender  
- **What it Measures:** BMI and weight loss trends by gender and program week  
- **Why it Matters:** Helps tailor coaching for specific demographics  

### 4️⃣ Weight Loss Velocity Analysis (`fct_weight_loss_analysis.sql`)
- **Metric:** Average KG Lost per Week  
- **What it Measures:** Tracks the speed of weight loss to ensure healthy progress  
- **Why it Matters:** Detects plateaus or unsafe trends  

### 5️⃣ Member Monthly Snapshot (`member_month.sql`)
- **Metric:** Current Status / Ending BMI  
- **What it Measures:** User weight, BMI, and change at the end of each month  
- **Why it Matters:** Supports financial reporting and monthly active user tracking  

---

## 🚀 How to Run This Project

### Prerequisites
- Snowflake account (or other supported data warehouse)  
- dbt Core or dbt Cloud installed  

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/bhupesh66/dbt_assignment.git
