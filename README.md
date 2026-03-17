# 🏥 Healthcare Analytics dbt Project: Weight Loss & BMI Transformation

## 📌 Project Overview
This dbt project turns raw patient measurement data into actionable insights. It helps track user progress, measure success milestones, and analyze long-term retention.

**Key Questions Answered:**
- **Clinical Efficacy:** What percentage of users achieve ≥5% weight loss?  
- **Health Migration:** Are users moving from high-risk BMI categories (Obese) to lower-risk categories?  
- **Program Stickiness:** How long do users stay active after their first weigh-in?

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
