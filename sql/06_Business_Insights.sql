USE BankLoanCreditRisk;
GO

-- ==========================================================================
-- Business insights: cross-dimensional risk views, trend analysis, and
-- portfolio-level summaries. All scoped to Approved_Loans (see file 01).
-- ==========================================================================


-- Q74. What is the default rate for each region?

SELECT
    b.Region,
    COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Default_Rate
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY b.Region
ORDER BY COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*) DESC;


-- Q75. What is the default rate for each loan type?

SELECT
    lt.Loan_Type_ID,
    lt.Loan_Type_Name,
    COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Default_Rate
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Loan_Types AS lt
    ON al.Loan_Type_ID = lt.Loan_Type_ID
GROUP BY lt.Loan_Type_ID, lt.Loan_Type_Name
ORDER BY COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*) DESC;


-- Q76. What is the default rate for each branch, broken down by risk category?

SELECT
    b.Branch_Name,
    al.Risk_Category,
    COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Default_Rate
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY b.Branch_Name, al.Risk_Category
ORDER BY b.Branch_Name, COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*) DESC;


-- Q77. Who are the top 10 high-risk customers by total outstanding balance?

SELECT TOP 10
    c.Customer_ID,
    c.Name,
    COUNT(al.Loan_ID) AS Critical_Risk_Loan_Count,
    FORMAT(
        SUM(TRY_CAST(al.Outstanding_Balance AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Total_Outstanding_Balance
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Customers AS c
    ON al.Customer_ID = c.Customer_ID
WHERE al.Risk_Category = 'Critical'
GROUP BY c.Customer_ID, c.Name
ORDER BY SUM(TRY_CAST(al.Outstanding_Balance AS DECIMAL(18,2))) DESC;


-- Q78. Who are the top 3 highest-risk customers PER BRANCH (not just overall)?

SELECT
    Branch_Name,
    Customer_ID,
    Name,
    Outstanding_Balance,
    Risk_Rank
FROM (
    SELECT
        b.Branch_Name,
        c.Customer_ID,
        c.Name,
        TRY_CAST(al.Outstanding_Balance AS DECIMAL(18,2)) AS Outstanding_Balance,
        RANK() OVER (
            PARTITION BY b.Branch_Name
            ORDER BY TRY_CAST(al.Outstanding_Balance AS DECIMAL(18,2)) DESC
        ) AS Risk_Rank
    FROM dbo.Approved_Loans AS al
    INNER JOIN dbo.Customers AS c ON al.Customer_ID = c.Customer_ID
    INNER JOIN dbo.Branches AS b ON al.Branch_ID = b.Branch_ID
    WHERE al.Risk_Category = 'Critical'
) AS ranked
WHERE Risk_Rank <= 3
ORDER BY Branch_Name, Risk_Rank;


-- Q79. How has the monthly default rate changed month-over-month?

WITH Monthly_Default_Rate AS (
    SELECT
        YEAR(Application_Date) AS Origination_Year,
        MONTH(Application_Date) AS Origination_Month,
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*) AS Default_Rate
    FROM dbo.Approved_Loans
    GROUP BY YEAR(Application_Date), MONTH(Application_Date)
)
SELECT
    Origination_Year,
    Origination_Month,
    FORMAT(Default_Rate, 'N2') + '%' AS Default_Rate,
    FORMAT(
        LAG(Default_Rate) OVER (ORDER BY Origination_Year, Origination_Month),
        'N2'
    ) + '%' AS Prior_Month_Default_Rate,
    FORMAT(
        Default_Rate - LAG(Default_Rate) OVER (ORDER BY Origination_Year, Origination_Month),
        'N2'
    ) + ' pts' AS Change_Vs_Prior_Month
FROM Monthly_Default_Rate
ORDER BY Origination_Year, Origination_Month;


-- Q80. What is the total loan amount by region, with a grand total?

SELECT
    CASE WHEN GROUPING(b.Region) = 1 THEN 'ALL REGIONS' ELSE b.Region END AS Region,
    FORMAT(SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))), 'N0', 'en-IN') AS Total_Loan_Amount
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY ROLLUP(b.Region)
ORDER BY GROUPING(b.Region), SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q81. Portfolio & Executive KPI Summary. Total_Approved_Loans here means the funded portfolio -- compare against Q14's Total_Loan_Applications (file 02) to see the full application funnel.

SELECT
    COUNT(*) AS Total_Approved_Loans,
    FORMAT(SUM(CAST(Loan_Amount AS DECIMAL(18,2))), 'N0', 'en-IN') AS Total_Loan_Amount,
    FORMAT(AVG(CAST(Loan_Amount AS DECIMAL(18,2))), 'N2', 'en-IN') AS Average_Loan_Amount,
    FORMAT(AVG(CAST(Interest_Rate AS DECIMAL(10,2))), 'N2') AS Average_Interest_Rate,
    COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    FORMAT(COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*), 'N2') + '%' AS Default_Rate,
    COUNT(CASE WHEN Loan_Status = 'NPA' THEN 1 END) AS NPA_Loans,
    FORMAT(COUNT(CASE WHEN Loan_Status = 'NPA' THEN 1 END) * 100.0 / COUNT(*), 'N2') + '%' AS NPA_Rate
FROM dbo.Approved_Loans;


-- Q82. What is the bank's overall financial performance summary?

WITH Loan_Payments AS (
    SELECT
        Loan_ID,
        SUM(TRY_CAST(Payment_Amount AS DECIMAL(18,2))) AS Total_Payment_Amount
    FROM dbo.Payments
    GROUP BY Loan_ID
)
SELECT
    FORMAT(SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))), 'N0', 'en-IN') AS Total_Loan_Disbursed,
    FORMAT(SUM(ISNULL(lp.Total_Payment_Amount, 0)), 'N2', 'en-IN') AS Total_Payment_Collected,
    FORMAT(SUM(TRY_CAST(al.Outstanding_Balance AS DECIMAL(18,2))), 'N2', 'en-IN') AS Outstanding_Balance
FROM dbo.Approved_Loans AS al
LEFT JOIN Loan_Payments AS lp
    ON al.Loan_ID = lp.Loan_ID;
