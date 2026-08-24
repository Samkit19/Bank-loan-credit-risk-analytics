# Bank Loan Credit Risk Analytics

Credit risk analysis of a bank's loan portfolio — 6,985 applications, 4,500 customers, 66 branches. SQL Server for data validation and 82 business questions, Power BI for the dashboard, and a written report aimed at a leadership audience.

## The main finding

Before building anything on top of the data, I checked whether it actually held together. It didn't, in one important place: `Amount_Repaid` on the Loans table doesn't match the real payment history in Payments — not for a handful of loans, for all 4,068 approved ones. The dashboard's recovery rate reads 28.2%; going by what Payments actually shows was collected, it's closer to 5.4%. Full breakdown is in the report, Section 2.4.

## Project snapshot

| Metric | Value |
|---|---|
| Loan applications | 6,985 |
| Customers | 4,500 |
| Approved loans | 4,068 (58.2% approval rate) |
| Total approved loan amount | ₹418 Cr |
| Branches | 66 |
| Payment records | 13,000 |
| Default + NPA rate | 7.47% |
| Credit-score risk gradient | 40x, Poor band vs. Exceptional band |

## Tools

SQL Server for validation and the 82 business questions across 6 scripts. Power BI for the 4-page dashboard. Excel for the source data. Word for the report.

## Repository structure

```
bank-loan-credit-risk-analytics/
│
├── README.md
│
├── report/
│   └── Strategic_Credit_Risk_Portfolio_Analytics_Report.pdf
│
├── dashboard/
│   ├── Bank_Loan_Credit_Risk_Dashboard.pbix
│   └── screenshots/
│       ├── 01_executive_overview.png
│       ├── 02_customer_analysis.png
│       ├── 03_risk_analysis.png
│       └── 04_branch_analysis.png
│
├── sql/
│   ├── 01_Database_Setup_Validation.sql
│   ├── 02_Executive_Loan_Analysis.sql
│   ├── 03_Customer_Analysis.sql
│   ├── 04_Payment_Analysis.sql
│   ├── 05_Branch_Risk_Analysis.sql
│   └── 06_Business_Insights.sql
│
└── data/
    ├── Customers.xlsx
    ├── Loans.xlsx
    ├── Payments.xlsx
    ├── Branches.xlsx
    ├── Loan_Types.xlsx
    └── Analysis_Table.xlsx
```

## What's in each folder

`sql/` has the 82 business questions, Q1 through Q82 — database validation first, then executive KPIs, customer segmentation, payment behavior, branch risk, and cross-dimensional insights. `dashboard/` has the interactive Power BI file plus static PNGs of all 4 pages, so it's viewable without opening Power BI. `data/` is the 5 source tables plus a pre-joined `Analysis_Table` for faster charting. `report/` is the full write-up — findings, data quality checks, and recommendations, written for a leadership audience.

## Dashboard preview

**Executive Overview**
<img width="1004" height="556" alt="01_executive_overview" src="https://github.com/user-attachments/assets/6504645b-be94-470b-98a5-a3bb0c50a494" />

**Customer Analysis**
<img width="1009" height="556" alt="02_customer_analysis" src="https://github.com/user-attachments/assets/b4be42dc-1fdb-4c84-816a-ecde3257f7f1" />

**Risk Analysis**
<img width="1015" height="562" alt="03_risk_analysis" src="https://github.com/user-attachments/assets/f9d525a1-f1a6-4963-992d-899b04f8bed1" />

**Branch Analysis**
<img width="1007" height="566" alt="04_branch_analysis" src="https://github.com/user-attachments/assets/d679f021-3232-42ae-b115-2522c52686e7" />

## A few findings

Default-plus-NPA rate climbs from 0.78% in the top credit band to 31.6% in the bottom one, a 40x spread. Sub-Prime customers default at 19.2%, more than three times the Regular segment. Two-Wheeler and Personal loans carry the largest share of Critical-risk exposure by loan type.

## How to use it

1. Run the SQL scripts in order, `01` through `06`, against a SQL Server instance loaded with the tables in `data/`.
2. Open the `.pbix` in Power BI Desktop to explore it directly, or just look at the screenshots.
3. `report/` has the full narrative — findings and recommendations, not just numbers.

## Author

**Samkit Jain**<br>
📧 [samkitjain035@gmail.com](mailto:samkitjain035@gmail.com)<br>
💼 LinkedIn: [https://www.linkedin.com/in/samkit-jain-825232361](https://www.linkedin.com/in/samkit-jain-825232361)
