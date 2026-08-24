USE BankLoanCreditRisk;
GO

-- Q30. How many customers are available?

SELECT
    COUNT(*) AS Total_Customers
FROM dbo.Customers;


-- Q31. What is the default rate for each customer segment?

SELECT
    c.Customer_Segment,
    COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    COUNT(*) AS Total_Loans,
    FORMAT(
        COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Default_Rate
FROM dbo.Customers AS c
INNER JOIN dbo.Approved_Loans AS al
    ON c.Customer_ID = al.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*) DESC;


-- Q32. What is the average annual income of each customer segment?

SELECT
    Customer_Segment,
    FORMAT(
        AVG(TRY_CAST(Annual_Income AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Average_Annual_Income
FROM dbo.Customers
GROUP BY Customer_Segment
ORDER BY AVG(TRY_CAST(Annual_Income AS DECIMAL(18,2))) DESC;


-- Q33. How many customers belong to each occupation?

SELECT
    Occupation,
    COUNT(*) AS Total_Customers
FROM dbo.Customers
GROUP BY Occupation
ORDER BY Total_Customers DESC;


-- Q34. How many customers belong to each education level?

SELECT
    Education,
    COUNT(*) AS Total_Customers
FROM dbo.Customers
GROUP BY Education
ORDER BY Total_Customers DESC;


-- Q35. What is the average annual income by occupation?

SELECT
    Occupation,
    FORMAT(
        AVG(TRY_CAST(Annual_Income AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Average_Annual_Income
FROM dbo.Customers
GROUP BY Occupation
ORDER BY AVG(TRY_CAST(Annual_Income AS DECIMAL(18,2))) DESC;


-- Q36. What is the total loan amount by customer segment?

SELECT
    c.Customer_Segment,
    FORMAT(
        SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Loan_Amount
FROM dbo.Customers AS c
INNER JOIN dbo.Approved_Loans AS al
    ON c.Customer_ID = al.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q37. What is the total loan amount by occupation?

SELECT
    c.Occupation,
    FORMAT(
        SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Loan_Amount
FROM dbo.Customers AS c
INNER JOIN dbo.Approved_Loans AS al
    ON c.Customer_ID = al.Customer_ID
GROUP BY c.Occupation
ORDER BY SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q38. What is the total loan amount by education level?

SELECT
    c.Education,
    FORMAT(
        SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))),
        'N0',
        'en-IN'
    ) AS Total_Loan_Amount
FROM dbo.Customers AS c
INNER JOIN dbo.Approved_Loans AS al
    ON c.Customer_ID = al.Customer_ID
GROUP BY c.Education
ORDER BY SUM(CAST(al.Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q39. Which customers have the highest loan amount?

SELECT TOP 10
    c.Customer_ID,
    c.Name,
    c.Customer_Segment,
    c.Occupation,
    FORMAT(
        CAST(al.Loan_Amount AS DECIMAL(18,2)),
        'N0',
        'en-IN' ) AS Loan_Amount,
    lt.Loan_Type_Name
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Customers AS c
    ON al.Customer_ID = c.Customer_ID
INNER JOIN dbo.Loan_Types AS lt
    ON al.Loan_Type_ID = lt.Loan_Type_ID
ORDER BY CAST(al.Loan_Amount AS DECIMAL(18,2)) DESC;


-- Q40. What is the average loan amount by customer segment?

SELECT
    c.Customer_Segment,
    FORMAT(
        AVG(CAST(al.Loan_Amount AS DECIMAL(18,2))),
        'N2',
        'en-IN'
    ) AS Average_Loan_Amount
FROM dbo.Customers AS c
INNER JOIN dbo.Approved_Loans AS al
    ON c.Customer_ID = al.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY AVG(CAST(al.Loan_Amount AS DECIMAL(18,2))) DESC;


-- Q41. What is the approval status distribution across customer segments?

SELECT
    c.Customer_Segment,
    l.Approval_Status,
    COUNT(*) AS Total_Applications
FROM dbo.Customers AS c
INNER JOIN dbo.Loans AS l
    ON c.Customer_ID = l.Customer_ID
GROUP BY
    c.Customer_Segment,
    l.Approval_Status
ORDER BY
    c.Customer_Segment,
    Total_Applications DESC;


-- Q42. What is the default and NPA rate by credit score band?

SELECT
    CASE
        WHEN c.Credit_Score < 580 THEN '1. Poor (<580)'
        WHEN c.Credit_Score < 670 THEN '2. Fair (580-669)'
        WHEN c.Credit_Score < 740 THEN '3. Good (670-739)'
        WHEN c.Credit_Score < 800 THEN '4. Very Good (740-799)'
        ELSE '5. Exceptional (800+)'
    END AS Credit_Score_Band,
    COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) AS Defaulted_Loans,
    FORMAT(
        COUNT(CASE WHEN al.Loan_Status = 'Default' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS Default_Rate,
    COUNT(CASE WHEN al.Loan_Status = 'NPA' THEN 1 END) AS NPA_Loans,
    FORMAT(
        COUNT(CASE WHEN al.Loan_Status = 'NPA' THEN 1 END) * 100.0 / COUNT(*),
        'N2'
    ) + '%' AS NPA_Rate,
    COUNT(*) AS Total_Loans
FROM dbo.Approved_Loans AS al
INNER JOIN dbo.Customers AS c
    ON al.Customer_ID = c.Customer_ID
GROUP BY
    CASE
        WHEN c.Credit_Score < 580 THEN '1. Poor (<580)'
        WHEN c.Credit_Score < 670 THEN '2. Fair (580-669)'
        WHEN c.Credit_Score < 740 THEN '3. Good (670-739)'
        WHEN c.Credit_Score < 800 THEN '4. Very Good (740-799)'
        ELSE '5. Exceptional (800+)'
    END
ORDER BY Credit_Score_Band;
