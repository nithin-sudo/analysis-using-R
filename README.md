# Salary Survey Analysis Project

## Project Overview

The **Salary Survey Analysis Project** aims to analyze global salary survey data to uncover insights related to various industries, education levels, and years of professional experience. Through data cleaning, visualization, and predictive modeling, this project identifies trends and builds models to understand factors that affect salaries across different demographics.

## Dataset Description

This project uses a dataset containing self-reported salary information from professionals worldwide. Below is a description of each column in the dataset:

- **Timestamp**: Date and time when the survey response was submitted.
- **Age**: Respondent's age.
- **Industry**: Industry in which the respondent is currently employed.
- **JobTitle**: Job title of the respondent.
- **JobContext**: Additional context or clarification for the job title if provided by the respondent.
- **AnnualSalary**: Annual salary of the respondent, provided in either actual or annualized form to reflect a full-time equivalent.
- **AdditionalCompensation**: Any additional monetary compensation (bonuses, overtime, etc.) reported by the respondent, excluding benefits.
- **Currency**: Currency in which the salary and additional compensation amounts are reported.
- **OtherCurrency**: If "Other" was selected as the currency, this field specifies the exact currency.
- **IncomeContext**: Additional context regarding the income, if provided, for clarification purposes.
- **Country**: Country where the respondent works.
- **State**: U.S. state where the respondent works, if applicable.
- **City**: City where the respondent works.
- **YearsExperience**: Total years of professional work experience of the respondent.
- **YearsInField**: Total years of professional experience in the respondent's current field.
- **EducationLevel**: Highest level of education completed by the respondent.
- **Gender**: Gender identity of the respondent.
- **Race**: Race or ethnicity of the respondent, with the option to choose multiple categories.

This dataset allows for an in-depth exploration of how salaries vary by industry, country, and demographics. It also provides a basis for building predictive models to estimate salaries based on experience, education, and location.


## Project Goals

The project aims to achieve the following:

1. **Data Cleaning**: Prepare the dataset by addressing inconsistencies and missing values. This includes standardizing currency values and handling categorical data for analysis.
2. **Data Visualization**: Create meaningful visualizations to identify trends and patterns in salary distributions, industries with high earnings, and the impact of education and experience.
3. **Predictive Modeling**: Build regression and machine learning models to predict annual salary based on experience, education, and industry factors.
4. **Insights and Recommendations**: Derive actionable insights that can guide both employers and professionals in understanding how various factors impact salary levels across industries.

## Key Questions Addressed

The analysis seeks to answer several key questions, including:

1. **Salary Distribution**: What is the overall distribution of salaries in the dataset, and how do outliers impact this distribution?
2. **Industry Comparison**: Which industries offer the highest average salaries, and how do salaries differ across sectors?
3. **Education Impact**: How does education level affect salary outcomes, and are there specific levels that correlate with higher earnings?
4. **Experience and Salary**: How does professional experience impact salary, and is this effect consistent across different industries?
5. **Country and Currency Effects**: How do salaries compare across countries, and how is this reflected when converted to a common currency (USD)?
