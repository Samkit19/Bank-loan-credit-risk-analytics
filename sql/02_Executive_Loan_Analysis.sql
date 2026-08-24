USE BankLoanCreditRisk;
GO

-- Q14. How many loan applications have been received?

SELECT
    COUNT(*) AS Total_Loan_Applications
FROM dbo.Loans;


-- Q15. What is the total loan amount sanctioned?

SELECT
    FORMAT(
        SUM(CAST(Loan_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Loan_Amount
FROM dbo.Approved_Loans;


-- Q16. What is the average loan amount?

SELECT
    FORMAT(
        AVG(CAST(Loan_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Average_Loan_Amount
FROM dbo.Approved_Loans;


-- Q17. What is the average interest rate?

SELECT
    FORMAT(
        AVG(CAST(Interest_Rate AS DECIMAL(10,2))),
        'N2'
    ) AS Average_Interest_Rate
FROM dbo.Approved_Loans;


-- Q18. What is the average loan tenure?

SELECT
    FORMAT(
        AVG(CAST(Loan_Term_Months AS DECIMAL(10,2))),
        'N2'
    ) AS Average_Loan_Term_Months
FROM dbo.Approved_Loans;


-- Q19. What is the overall default rate across the entire loan portfolio?

SELECT
    COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Default_Rate
FROM dbo.Approved_Loans;


-- Q20. What is the overall NPA rate across the entire loan portfolio?

SELECT
    COUNT(CASE WHEN Loan_Status = 'NPA' THEN 1 END) AS NPA_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN Loan_Status = 'NPA' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS NPA_Rate
FROM dbo.Approved_Loans;


-- Q21. What is the total loan amount by loan status?

SELECT
    Loan_Status,
    FORMAT(
        SUM(CAST(Loan_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Loan_Amount
FROM dbo.Approved_Loans
GROUP BY Loan_Status
ORDER BY SUM(CAST(Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q22. What is the total loan amount by loan type?

SELECT
    lt.Loan_Type_ID,
    lt.Loan_Type_Name,
    FORMAT(
        SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Loan_Amount
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Loan_Types AS lt
    ON al.Loan_Type_ID = lt.Loan_Type_ID
GROUP BY lt.Loan_Type_ID, lt.Loan_Type_Name
ORDER BY SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q23. How many applications were received for each loan type?

SELECT
    lt.Loan_Type_ID,
    lt.Loan_Type_Name,
    COUNT(l.Loan_ID) AS Total_Applications
FROM dbo.Loans AS l
INNER JOIN dbo.Loan_Types AS lt
    ON l.Loan_Type_ID = lt.Loan_Type_ID
GROUP BY lt.Loan_Type_ID, lt.Loan_Type_Name
ORDER BY Total_Applications DESC;


-- Q24. What is the average loan amount by loan type?

SELECT
    lt.Loan_Type_ID,
    lt.Loan_Type_Name,
    FORMAT(
        AVG(CAST(al.Loan_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Average_Loan_Amount
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Loan_Types AS lt
    ON al.Loan_Type_ID = lt.Loan_Type_ID
GROUP BY lt.Loan_Type_ID, lt.Loan_Type_Name
ORDER BY AVG(CAST(al.Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q25. What are the top 10 highest-value loans?

SELECT TOP 10
    Loan_ID,
    Customer_ID,
    FORMAT(
        CAST(Loan_Amount AS DECIMAL(18,2)),
        'N0',
        'en-IN'
    ) AS Loan_Amount,
    Loan_Status
FROM dbo.Approved_Loans
ORDER BY CAST(Loan_Amount AS DECIMAL(18,2)) DESC;


-- Q26. What is the monthly trend of loan applications?

SELECT
    YEAR(Application_Date) AS Year,
    MONTH(Application_Date) AS Month_Number,
    DATENAME(MONTH, Application_Date) AS Month_Name,
    COUNT(*) AS Total_Applications
FROM dbo.Loans
GROUP BY
    YEAR(Application_Date),
    MONTH(Application_Date),
    DATENAME(MONTH, Application_Date)
ORDER BY
    Year,
    Month_Number;


-- Q27. What is the monthly trend of loan amount?

SELECT
    YEAR(Application_Date) AS Year,
    MONTH(Application_Date) AS Month_Number,
    DATENAME(MONTH, Application_Date) AS Month_Name,
    FORMAT(
        SUM(CAST(Loan_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Loan_Amount
FROM dbo.Approved_Loans
GROUP BY
    YEAR(Application_Date),
    MONTH(Application_Date),
    DATENAME(MONTH, Application_Date)
ORDER BY
    Year,
    Month_Number;


-- Q28. Vintage analysis: how does default rate vary by loan origination cohort?

SELECT
    YEAR(Application_Date) AS Origination_Year,
    MONTH(Application_Date) AS Origination_Month,
    COUNT(*) AS Total_Loans,
    COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    FORMAT(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Default_Rate
FROM dbo.Approved_Loans
GROUP BY YEAR(Application_Date), MONTH(Application_Date)
ORDER BY Origination_Year, Origination_Month;


-- Q29. How long does loan processing take, on average, from application to approval -- and does it vary by loan type?

SELECT
    lt.Loan_Type_ID,
    lt.Loan_Type_Name,
    FORMAT(
        AVG(CAST(DATEDIFF(DAY, TRY_CAST(al.Application_Date AS DATE), TRY_CAST(al.Approval_Date AS DATE)) AS DECIMAL(10,2))),
        'N2'
    ) AS Avg_Days_To_Approval
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Loan_Types AS lt
    ON al.Loan_Type_ID = lt.Loan_Type_ID
GROUP BY lt.Loan_Type_ID, lt.Loan_Type_Name
ORDER BY AVG(CAST(DATEDIFF(DAY, TRY_CAST(al.Application_Date AS DATE), TRY_CAST(al.Approval_Date AS DATE)) AS DECIMAL(10,2))) DESC;