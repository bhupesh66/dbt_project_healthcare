# Healthcare Analytics dbt Project: Weight Loss & BMI Transformation

## 📌 Project Overview
This dbt project transforms raw patient measurement data into actionable clinical insights. It focuses on:
- Tracking user progress through a weight-loss program  
- Identifying medical "success" milestones  
- Analyzing long-term user retention  

### Key Business Questions Answered:
- **Clinical Efficacy:** What percentage of users achieve a 5% weight loss (medical benchmark for success)?  
- **Health Migration:** Are users moving from high-risk BMI categories (Obese) to lower-risk categories (Overweight/Healthy)?  
- **Program Stickiness:** How long do users stay active after their initial weigh-in?  

---

## 🏗 Data Architecture & Lineage

The project follows a modular dbt structure:

### 1. Staging Layer (`models/staging/`)
- **measurements_staging:** Cleans raw weight and height logs  
- **users_staging:** Standardizes user metadata and demographics  

### 2. Intermediate Layer (`models/intermediate/`)
- **user_initial_bmi:**  
  The "Ground Truth" table.  
  Identifies the first valid weight and height for each user to establish a baseline.  

### 3.Mart 

## The Star Schema (Core Layer)

To ensure **data integrity** and **fast queries**, we structure our warehouse using a **Star Schema**.  

---

#  Dimension Tables (The Context)

- **dim_user:** The single source of truth for patient demographics, including **Gender, Age, Signup Date**.  
- **date_dim:** A centralized calendar table that enables smooth **time-series analysis** and **cohort grouping**.  

---

#  Fact Tables (The Observations)

- **fact_weight_and_bmi_progress:** The core fact table that records **every measurement event**.  
  - Calculates the **BMI at each measurement**  
  - Tracks **weight change relative to each user’s baseline**  
  - Serves as the foundation for most analytics and reporting in the project

## 🌟 The Five Core Analytics Models

In the **Marts layer**, raw data transforms into actionable business insights. We've designed **five specialized models** to answer key questions about user progress, health outcomes, and program engagement.  

---

### 1️⃣ Clinical Success Outcomes (`fct_user_success_outcomes.sql`)
- **Metric:** % of Users Achieving Clinical Success  
- **What it Measures:** Tracks the percentage of users who hit the **gold standard of ≥5% weight loss** from their starting weight.  
- **Why it Matters:** Shows stakeholders and health providers the **effectiveness of the program** in delivering meaningful health outcomes.  

---

### 2️⃣ Monthly Retention Cohorts (`fct_monthly_retention_cohorts.sql`)
- **Metric:** Retention Rate per Month  
- **What it Measures:** Groups users by their “birth month” (Month 0) and checks who stays active (logs weight) in subsequent months.  
- **Why it Matters:** Helps identify the **churn cliff** — the point when users typically stop engaging — so we can improve program stickiness.  

---

### 3️⃣ Gender Health Distribution (`fct_gender_monthly_health_distribution.sql`)
- **Metric:** Average BMI by Gender  
- **What it Measures:** Aggregates BMI categories and weight loss trends, broken down by gender and program week.  
- **Why it Matters:** Reveals if certain demographic groups respond better, helping **tailor coaching and content** for maximum impact.  

---

### 4️⃣ Weight Loss Velocity Analysis (`fct_weight_loss_analysis.sql`)
- **Metric:** Average KG Lost per Week  
- **What it Measures:** Calculates the speed of weight loss, monitoring for healthy, sustainable progress versus risky crash-diets.  
- **Why it Matters:** Flags **plateaus or unsafe trends**, ensuring users lose weight safely and consistently.  

---

### 5️⃣ Member Monthly Snapshot (`member_month.sql`)
- **Metric:** Current Status / Ending BMI  
- **What it Measures:** Captures where each user stands at the end of every month — final weight, BMI category, and total change.  
- **Why it Matters:** Supports **financial reporting** and **monthly active user tracking**, helping the business plan and forecast accurately.  

## 🚀 How to Run This Project

### Prerequisites
- Snowflake account (or any supported data warehouse)  
- dbt Core or dbt Cloud installed  

### Setup

#### 1. Clone the repository
```bash
git clone https://github.com/bhupesh66/dbt_assignment.git

Run the pipeline

dbt build
