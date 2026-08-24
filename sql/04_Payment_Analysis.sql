USE BankLoanCreditRisk;
GO

-- Q43. How many payment records are available?

SELECT
    COUNT(*) AS Total_Payments
FROM dbo.Payments;


-- Q44. What is the collection efficiency (payments collected vs. loan amount disbursed) by loan type?

WITH Loan_Payment_Totals AS (
    SELECT
        Loan_ID,
        SUM(TRY_CAST(Payment_Amount AS DECIMAL(18,2))) AS Total_Paid
    FROM dbo.Payments
    GROUP BY Loan_ID
)
SELECT
    lt.Loan_Type_ID,
    lt.Loan_Type_Name,
    FORMAT(SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))), 'N0', 'en-IN') AS Total_Loan_Amount,
    FORMAT(SUM(ISNULL(lpt.Total_Paid, 0)), 'N0', 'en-IN') AS Total_Collected,
    FORMAT(
        SUM(ISNULL(lpt.Total_Paid, 0)) * 100.0 / NULLIF(SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))), 0),
        'N2'
    ) + '%' AS Collection_Efficiency
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Loan_Types AS lt
    ON al.Loan_Type_ID = lt.Loan_Type_ID
LEFT JOIN Loan_Payment_Totals AS lpt
    ON al.Loan_ID = lpt.Loan_ID
GROUP BY lt.Loan_Type_ID, lt.Loan_Type_Name
ORDER BY SUM(ISNULL(lpt.Total_Paid, 0)) * 100.0 / NULLIF(SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))), 0) DESC;


-- Q45. What is the total payment amount collected?

SELECT
    FORMAT(
        SUM(TRY_CAST(Payment_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Total_Payment_Amount
FROM dbo.Payments;


-- Q46. What is the average payment amount?

SELECT
    FORMAT(
        AVG(TRY_CAST(Payment_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Average_Payment_Amount
FROM dbo.Payments;


-- Q47. What is the total payment amount by payment status?

SELECT
    Payment_Status,
    FORMAT(
        SUM(TRY_CAST(Payment_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Total_Payment_Amount
FROM dbo.Payments
GROUP BY Payment_Status
ORDER BY SUM(TRY_CAST(Payment_Amount AS DECIMAL(18,2))) DESC;


-- Q48. What is the total payment amount collected for each loan type?

SELECT
    lt.Loan_Type_ID,
    lt.Loan_Type_Name,
    FORMAT(
        SUM(TRY_CAST(p.Payment_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Total_Payment_Amount
FROM dbo.Payments AS p
INNER JOIN dbo.Loans AS l
    ON p.Loan_ID = l.Loan_ID
INNER JOIN dbo.Loan_Types AS lt
    ON l.Loan_Type_ID = lt.Loan_Type_ID
GROUP BY lt.Loan_Type_ID, lt.Loan_Type_Name
ORDER BY SUM(TRY_CAST(p.Payment_Amount AS DECIMAL(18,2))) DESC;


-- Q49. What is the total payment amount collected from each customer segment?

SELECT
    c.Customer_Segment,
    FORMAT(
        SUM(TRY_CAST(p.Payment_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Total_Payment_Amount
FROM dbo.Payments AS p
INNER JOIN dbo.Loans AS l
    ON p.Loan_ID = l.Loan_ID
INNER JOIN dbo.Customers AS c
    ON l.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY SUM(TRY_CAST(p.Payment_Amount AS DECIMAL(18,2))) DESC;


-- Q50. What are the top 10 highest payments received?

SELECT TOP 10
    Payment_ID,
    Loan_ID,
    CAST(Payment_Date AS DATE) AS Payment_Date,
    Payment_Method,
    FORMAT(
        TRY_CAST(Payment_Amount AS DECIMAL(18,2)),
        'N2',
        'en-IN'
    ) AS Payment_Amount
FROM dbo.Payments
ORDER BY TRY_CAST(Payment_Amount AS DECIMAL(18,2)) DESC;


-- Q51. What is the monthly payment collection trend?

SELECT
    YEAR(Payment_Date) AS Year,
    MONTH(Payment_Date) AS Month_Number,
    DATENAME(MONTH, Payment_Date) AS Month_Name,
    FORMAT(
        SUM(TRY_CAST(Payment_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Total_Payment_Amount
FROM dbo.Payments
GROUP BY
    YEAR(Payment_Date),
    MONTH(Payment_Date),
    DATENAME(MONTH, Payment_Date)
ORDER BY
    Year,
    Month_Number;


-- Q52. How are payments distributed across days-past-due (DPD) buckets?

SELECT
    CASE
        WHEN Days_Past_Due = 0 THEN '1. Current (0)'
        WHEN Days_Past_Due BETWEEN 1 AND 30 THEN '2. 1-30 DPD'
        WHEN Days_Past_Due BETWEEN 31 AND 60 THEN '3. 31-60 DPD'
        WHEN Days_Past_Due BETWEEN 61 AND 90 THEN '4. 61-90 DPD'
        ELSE '5. 90+ DPD'
    END AS DPD_Bucket,
    COUNT(*) AS Total_Payments,
    FORMAT(
        SUM(TRY_CAST(Payment_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Payment_Amount
FROM dbo.Payments
GROUP BY
    CASE
        WHEN Days_Past_Due = 0 THEN '1. Current (0)'
        WHEN Days_Past_Due BETWEEN 1 AND 30 THEN '2. 1-30 DPD'
        WHEN Days_Past_Due BETWEEN 31 AND 60 THEN '3. 31-60 DPD'
        WHEN Days_Past_Due BETWEEN 61 AND 90 THEN '4. 61-90 DPD'
        ELSE '5. 90+ DPD'
    END
ORDER BY DPD_Bucket;
