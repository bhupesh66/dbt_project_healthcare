# 🏥 Healthcare Analytics dbt Project: Weight Loss & BMI Transformation

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

### 3. Marts Layer (`models/marts/`)

- **fact_weight_and_bmi_progress:**  
  Grain: *one row per user per week*  
  - Calculates weekly BMI  
  - Tracks cumulative weight change from baseline  

- **fct_user_success_outcomes:**  
  Measures clinical success  
  - **pct_clinical_success:** % users with ≥5% weight loss  
  - **pct_category_improvement:** % users moving to a better BMI category  

- **fct_monthly_retention_cohorts:**  
  Cohort model tracking user retention month-over-month  

---

## 📈 Key Analytics Logic

### 🧪 "Success" Definition

We define success using two clinical lenses:

#### 1. Relative Weight Loss


(Current Weight - Initial Weight) / Initial Weight

- A result **≤ -5%** is considered clinical success  

#### 2. BMI Migration
- Tracks transitions between BMI categories  
- Example:

- Obese Class II → Obese Class I

- 
---

### 🔁 Retention Logic

- Users are grouped into **monthly cohorts** based on their first measurement date  
- Retention is calculated by checking if users have at least **one weight log in future months** relative to Month 0  

---

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
