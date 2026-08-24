USE BankLoanCreditRisk;
GO



-- Q1. How many records are available in each table?

SELECT 'Customers' AS Table_Name, COUNT(*) AS Total_Records
FROM dbo.Customers

UNION ALL

SELECT 'Loans', COUNT(*)
FROM dbo.Loans

UNION ALL

SELECT 'Payments', COUNT(*)
FROM dbo.Payments

UNION ALL

SELECT 'Branches', COUNT(*)
FROM dbo.Branches

UNION ALL

SELECT 'Loan Types', COUNT(*)
FROM dbo.Loan_Types;


-- Q2. What are the different loan statuses and their counts?

SELECT
    Loan_Status,
    COUNT(*) AS Total_Loans
FROM dbo.Loans
GROUP BY Loan_Status
ORDER BY Total_Loans DESC;


-- Q3. What are the different approval statuses and their counts?

SELECT
    Approval_Status,
    COUNT(*) AS Total_Applications
FROM dbo.Loans
GROUP BY Approval_Status
ORDER BY Total_Applications DESC;


-- Q4. What are the different payment statuses and their counts?

SELECT
    Payment_Status,
    COUNT(*) AS Total_Payments
FROM dbo.Payments
GROUP BY Payment_Status
ORDER BY Total_Payments DESC;


-- Q5. How many customers belong to each customer segment?

SELECT
    Customer_Segment,
    COUNT(*) AS Total_Customers
FROM dbo.Customers
GROUP BY Customer_Segment
ORDER BY Total_Customers DESC;


-- Q6. How many loan types are available and how many applications belong to each loan type?

SELECT
    lt.Loan_Type_ID,
    lt.Loan_Type_Name,
    COUNT(l.Loan_ID) AS Total_Applications
FROM dbo.Loans AS l
INNER JOIN dbo.Loan_Types AS lt
    ON l.Loan_Type_ID = lt.Loan_Type_ID
GROUP BY lt.Loan_Type_ID, lt.Loan_Type_Name
ORDER BY Total_Applications DESC;


-- Q7. How many branches are present in each region?

SELECT
    Region,
    COUNT(*) AS Total_Branches
FROM dbo.Branches
GROUP BY Region
ORDER BY Total_Branches DESC;


-- Q8. What is the total number of branches?

SELECT
    COUNT(*) AS Total_Branches
FROM dbo.Branches;


-- Q9. Are there any orphaned records -- rows referencing a parent ID that doesn't exist in the parent table?

SELECT 'Loans with missing Customer' AS Issue, COUNT(*) AS Row_Count
FROM dbo.Loans AS l
LEFT JOIN dbo.Customers AS c ON l.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL

UNION ALL

SELECT 'Loans with missing Branch', COUNT(*)
FROM dbo.Loans AS l
LEFT JOIN dbo.Branches AS b ON l.Branch_ID = b.Branch_ID
WHERE b.Branch_ID IS NULL

UNION ALL

SELECT 'Loans with missing Loan_Type', COUNT(*)
FROM dbo.Loans AS l
LEFT JOIN dbo.Loan_Types AS lt ON l.Loan_Type_ID = lt.Loan_Type_ID
WHERE lt.Loan_Type_ID IS NULL

UNION ALL

SELECT 'Payments with missing Loan', COUNT(*)
FROM dbo.Payments AS p
LEFT JOIN dbo.Loans AS l ON p.Loan_ID = l.Loan_ID
WHERE l.Loan_ID IS NULL;


-- Q10. Are there any duplicate primary keys in the core tables?

SELECT 'Duplicate Customer_ID' AS Issue, COUNT(*) AS Duplicate_Count
FROM (
    SELECT Customer_ID
    FROM dbo.Customers
    GROUP BY Customer_ID
    HAVING COUNT(*) > 1
) AS dup

UNION ALL

SELECT 'Duplicate Loan_ID', COUNT(*)
FROM (
    SELECT Loan_ID
    FROM dbo.Loans
    GROUP BY Loan_ID
    HAVING COUNT(*) > 1
) AS dup;


-- Q11. Do any loans have missing, zero, or negative Loan_Amount / Interest_Rate?

SELECT
    SUM(CASE WHEN Loan_Amount IS NULL THEN 1 ELSE 0 END) AS Null_Loan_Amount,
    SUM(CASE WHEN TRY_CAST(Loan_Amount AS DECIMAL(18,2)) <= 0 THEN 1 ELSE 0 END) AS Zero_Or_Negative_Loan_Amount,
    SUM(CASE WHEN Interest_Rate IS NULL THEN 1 ELSE 0 END) AS Null_Interest_Rate,
    SUM(CASE WHEN TRY_CAST(Interest_Rate AS DECIMAL(10,2)) <= 0 THEN 1 ELSE 0 END) AS Zero_Or_Negative_Interest_Rate
FROM dbo.Loans;


-- Q12. What loan statuses occur for each approval status?

SELECT
    Approval_Status,
    Loan_Status,
    COUNT(*) AS Total_Loans
FROM dbo.Loans
GROUP BY Approval_Status, Loan_Status
ORDER BY Approval_Status, Total_Loans DESC;


-- Approved_Loans view: loans that were actually funded (see Q12). Used by
-- every portfolio-level query below; application-funnel queries still use
-- dbo.Loans directly.

GO

CREATE OR ALTER VIEW dbo.Approved_Loans AS
SELECT *
FROM dbo.Loans
WHERE Approval_Status = 'Approved';
GO


-- Q13. Does Amount_Repaid on each loan reconcile with the sum of its actual payment transactions?

WITH Loan_Payment_Totals AS (
    SELECT
        Loan_ID,
        SUM(TRY_CAST(Payment_Amount AS DECIMAL(18,2))) AS Total_Paid
    FROM dbo.Payments
    GROUP BY Loan_ID
)
SELECT
    COUNT(*) AS Approved_Loans_Checked,
    SUM(CASE
        WHEN ABS(ISNULL(al.Amount_Repaid, 0) - ISNULL(lpt.Total_Paid, 0)) > 1
        THEN 1 ELSE 0
    END) AS Loans_With_Mismatch,
    FORMAT(
        SUM(CASE
            WHEN ABS(ISNULL(al.Amount_Repaid, 0) - ISNULL(lpt.Total_Paid, 0)) > 1
            THEN 1 ELSE 0
        END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Pct_Mismatched
FROM dbo.Approved_Loans AS al
LEFT JOIN Loan_Payment_Totals AS lpt
    ON al.Loan_ID = lpt.Loan_ID;