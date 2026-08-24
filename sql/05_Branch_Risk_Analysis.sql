USE BankLoanCreditRisk;
GO

-- Q53. How many loan applications were received by each branch?

SELECT
    b.Branch_ID,
    b.Branch_Name,
    COUNT(l.Loan_ID) AS Total_Applications
FROM dbo.Loans AS l
INNER JOIN dbo.Branches AS b
    ON l.Branch_ID = b.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name
ORDER BY Total_Applications DESC;


-- Q54. What is the total loan amount sanctioned by each branch?

SELECT
    b.Branch_ID,
    b.Branch_Name,
    FORMAT(
        SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Loan_Amount
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name
ORDER BY SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q55. What is the average loan amount by branch?

SELECT
    b.Branch_ID,
    b.Branch_Name,
    FORMAT(
        AVG(CAST(al.Loan_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Average_Loan_Amount
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name
ORDER BY AVG(CAST(al.Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q56. How are loans distributed across different risk categories?

SELECT
    Risk_Category,
    COUNT(*) AS Total_Loans
FROM dbo.Approved_Loans
GROUP BY Risk_Category
ORDER BY Total_Loans DESC;


-- Q57. What is the total loan amount for each risk category?

SELECT
    Risk_Category,
    FORMAT(
        SUM(CAST(Loan_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Loan_Amount
FROM dbo.Approved_Loans
GROUP BY Risk_Category
ORDER BY SUM(CAST(Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q58. How many defaulted loans does each branch have?

SELECT
    b.Branch_ID,
    b.Branch_Name,
    COUNT(*) AS Defaulted_Loans
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
WHERE al.Loan_Status = 'Default'
GROUP BY b.Branch_ID, b.Branch_Name
ORDER BY Defaulted_Loans DESC;


-- Q59. How many NPA loans does each branch have?

SELECT
    b.Branch_ID,
    b.Branch_Name,
    COUNT(*) AS NPA_Loans
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
WHERE al.Loan_Status = 'NPA'
GROUP BY b.Branch_ID, b.Branch_Name
ORDER BY NPA_Loans DESC;


-- Q60. What is the total outstanding balance by branch?

SELECT
    b.Branch_ID,
    b.Branch_Name,
    FORMAT(
        SUM(TRY_CAST(al.Outstanding_Balance AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Outstanding_Balance
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name
ORDER BY SUM(TRY_CAST(al.Outstanding_Balance AS DECIMAL(18,2))) DESC;


-- Q61. What is the total loan amount by region?

SELECT
    b.Region,
    FORMAT(
        SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Loan_Amount
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY b.Region
ORDER BY SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q62. How many approved loans were processed by each branch?

SELECT
    b.Branch_ID,
    b.Branch_Name,
    COUNT(*) AS Approved_Loans
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name
ORDER BY Approved_Loans DESC;


-- Q63. What is the approval rate for each branch?

SELECT
    b.Branch_ID,
    b.Branch_Name,
    COUNT(CASE WHEN l.Approval_Status = 'Approved' THEN 1 END) AS Approved_Loans,
    COUNT(*) AS Total_Applications,
    FORMAT(
        COUNT(CASE WHEN l.Approval_Status = 'Approved' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Approval_Rate
FROM dbo.Loans AS l
INNER JOIN dbo.Branches AS b
    ON l.Branch_ID = b.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name
ORDER BY COUNT(CASE WHEN l.Approval_Status = 'Approved' THEN 1 END) * 100.0 / COUNT(*) DESC;


-- Q64. What is the default rate for each branch?

SELECT
    b.Branch_ID,
    b.Branch_Name,
    COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Default_Rate
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name
ORDER BY COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*) DESC;


-- Q65. What is the NPA rate for each branch?

SELECT
    b.Branch_ID,
    b.Branch_Name,
    COUNT(CASE WHEN al.Loan_Status = 'NPA' THEN 1 END) AS NPA_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN al.Loan_Status = 'NPA' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS NPA_Rate
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name
ORDER BY COUNT(CASE WHEN al.Loan_Status = 'NPA' THEN 1 END) * 100.0 / COUNT(*) DESC;


-- Q66. What is the distribution of risk categories across regions?

SELECT
    b.Region,
    al.Risk_Category,
    COUNT(*) AS Total_Loans
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Branches AS b
    ON al.Branch_ID = b.Branch_ID
GROUP BY
    b.Region,
    al.Risk_Category
ORDER BY
    b.Region,
    Total_Loans DESC;


-- Q67. What is the average loan amount for each risk category?

SELECT
    Risk_Category,
    FORMAT(
        AVG(CAST(Loan_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Average_Loan_Amount
FROM dbo.Approved_Loans
GROUP BY Risk_Category
ORDER BY AVG(CAST(Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q68. What is the average interest rate for each risk category?

SELECT
    Risk_Category,
    FORMAT(
        AVG(CAST(Interest_Rate AS DECIMAL(10,2))),
        'N2'
    ) AS Average_Interest_Rate
FROM dbo.Approved_Loans
GROUP BY Risk_Category
ORDER BY AVG(CAST(Interest_Rate AS DECIMAL(10,2))) DESC;


-- Q69. What is the default rate for each risk category?

SELECT
    Risk_Category,
    COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Default_Rate
FROM dbo.Approved_Loans
GROUP BY Risk_Category
ORDER BY COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*) DESC;


-- Q70. What is the NPA rate for each risk category?

SELECT
    Risk_Category,
    COUNT(CASE WHEN Loan_Status = 'NPA' THEN 1 END) AS NPA_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN Loan_Status = 'NPA' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS NPA_Rate
FROM dbo.Approved_Loans
GROUP BY Risk_Category
ORDER BY COUNT(CASE WHEN Loan_Status = 'NPA' THEN 1 END) * 100.0 / COUNT(*) DESC;


-- Q71. Does the interest rate charged for each risk category actually compensate for that category's default rate? (risk-adjusted pricing)

SELECT
    Risk_Category,
    FORMAT(AVG(CAST(Interest_Rate AS DECIMAL(10,2))), 'N2') AS Average_Interest_Rate,
    COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Default_Rate
FROM dbo.Approved_Loans
GROUP BY Risk_Category
ORDER BY AVG(CAST(Interest_Rate AS DECIMAL(10,2))) DESC;


-- Q72. What share of the bank's total NPA exposure sits in each branch?

WITH Branch_NPA AS (
    SELECT
        b.Branch_ID,
        b.Branch_Name,
        COUNT(*) AS NPA_Loans
    FROM dbo.Approved_Loans AS al
    INNER JOIN dbo.Branches AS b
        ON al.Branch_ID = b.Branch_ID
    WHERE al.Loan_Status = 'NPA'
    GROUP BY b.Branch_ID, b.Branch_Name
)
SELECT
    Branch_Name,
    NPA_Loans,
    SUM(NPA_Loans) OVER () AS Total_Bank_NPA,
    FORMAT(NPA_Loans * 100.0 / SUM(NPA_Loans) OVER (), 'N2') + '%' AS Pct_Of_Total_NPA
FROM Branch_NPA
ORDER BY NPA_Loans DESC;


-- Q73. Does each branch's labeled Performance_Tier actually match its observed approval rate, default rate, and NPA rate?

WITH Branch_Approval AS (
    SELECT
        Branch_ID,
        COUNT(CASE WHEN Approval_Status = 'Approved' THEN 1 END) AS Approved_Count,
        COUNT(*) AS Total_Applications
    FROM dbo.Loans
    GROUP BY Branch_ID
),
Branch_Outcomes AS (
    SELECT
        Branch_ID,
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) AS Default_Count,
        COUNT(CASE WHEN Loan_Status = 'NPA' THEN 1 END) AS NPA_Count,
        COUNT(*) AS Approved_Count
    FROM dbo.Approved_Loans
    GROUP BY Branch_ID
)
SELECT
    b.Performance_Tier,
    COUNT(DISTINCT b.Branch_ID) AS Branch_Count,
    FORMAT(
        SUM(ba.Approved_Count) * 100.0 / SUM(ba.Total_Applications),
        'N2'
    ) + '%' AS Approval_Rate,
    FORMAT(
        SUM(bo.Default_Count) * 100.0 / NULLIF(SUM(bo.Approved_Count), 0),
        'N2'
    ) + '%' AS Default_Rate,
    FORMAT(
        SUM(bo.NPA_Count) * 100.0 / NULLIF(SUM(bo.Approved_Count), 0),
        'N2'
    ) + '%' AS NPA_Rate
FROM dbo.Branches AS b
LEFT JOIN Branch_Approval AS ba
    ON b.Branch_ID = ba.Branch_ID
LEFT JOIN Branch_Outcomes AS bo
    ON b.Branch_ID = bo.Branch_ID
GROUP BY b.Performance_Tier
ORDER BY
    CASE b.Performance_Tier WHEN 'High' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Low' THEN 3 ELSE 4 END;
