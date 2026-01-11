## Executive summary

Three months after engaging with a marketing specialist, this report aim to analyse the customer acquisition channel. I use SQL to clean and prepare the raw funnel data and Python to analyse trial start dates, activation rates, revenue contribution by source and many more. The analysis show the performance is broadly similar thus unlikely to justify budget reallocation at this time. 

## Business Problem

After raising Series B last year, we want to improve our sales by hiring a marketing agency to supervise and manage our acquisition channel. This report evaluates acquisition channel performance over the past three months to determine whether meaningful differences exist that would justify reallocating marketing spend.

## Methodology

1. **SQL -** Queries that extracts, cleans, and transforms the data from the database.
2. **Python -** Pandas, Matplotlib, Numpy, Writing functions

Data contains 10k users from September 2025 till December 2025 inside 6 acquisition channel namely Google Ads, Facebook Ads, LinkedIn, Referral, Organic and Others.

## 4. Skills

SQL: CTEs, Joins, Case, aggregate functions

Python: Pandas, Matplotlib, Numpy, Writing functions, statistics

## 5. Analysis Result

<img width="630" height="470" alt="download" src="https://github.com/user-attachments/assets/346e9078-7855-4afa-a67b-d6f22cc66a71" />

The perfomance of all 6 channels measured by average MRR per user produced in the past 3 months is relatively similar ranging from RM 52.69 to RM 56.83 indicating limited variance and no clear outperforming channel.

| Acquisition Channel | Average MRR (RM) |
| --- | --- |
| FB ads | 53.07 |
| Google Ads | 54.96 |
| LinkedIn | 52.69 |
| Organic | 56.83 |
| Others | 53.35 |
| Referral | 55.37 |

## 6. Limitation

- Data collected for only 3 months, longer observation is needed.
- This report does not account for potential difference by customer segment and subscription plan.

## 7. Next step

1. Longer timeframe to better understand seasonality of each acquisition channel
2. Segment acquisition performance by customer attribute such as geography to know second-order difference not visible at aggregate level.
