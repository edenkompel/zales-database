
--ללא קינון
--שאילתה 1 – 10 המוצרים הפופולריים ביותר
SELECT TOP 10
    P.ProductID,
    P.Name,
    C.Name AS CategoryName,
    SUM(I.Quantity) AS TotalQuantitySold
FROM PRODUCTS P
JOIN INCLUDES I
    ON P.ProductID = I.ProductID
JOIN CATEGORIES C
    ON P.CategoryID = C.CategoryID
WHERE P.Availability = 1
GROUP BY P.ProductID, P.Name, C.Name
HAVING SUM(I.Quantity) > 1
ORDER BY TotalQuantitySold DESC;

--שאילתה 2 – עשרת המוצרים המותאמים האישית הנמכרים ביותר
SELECT TOP 10
    P.Name AS ProductName,
    PE.Style,
    PE.Material,
    SUM(IP.Quantity) AS TotalQuantityOrdered
FROM PERSONALIZED PE
JOIN INCLUDES_PERSONALIZED IP
    ON PE.ProductID = IP.ProductID
   AND PE.PersonalizedID = IP.PersonalizedID
JOIN PRODUCTS P
    ON PE.ProductID = P.ProductID
WHERE PE.Style IS NOT NULL
GROUP BY
    P.Name,
    PE.Style,
    PE.Material
ORDER BY TotalQuantityOrdered DESC;

-- SELECT מקוננות 
--שאילתה 1 – קטגוריות שמכרו מעל ממוצע הכמויות הכללי
SELECT
    P.CategoryID,
    C.Name AS CategoryName,
    SUM(I.Quantity) AS TotalQuantitySold
FROM PRODUCTS P
JOIN CATEGORIES C
    ON P.CategoryID = C.CategoryID
JOIN INCLUDES I
    ON P.ProductID = I.ProductID
GROUP BY
    P.CategoryID,
    C.Name
HAVING SUM(I.Quantity) >
(
    SELECT AVG(CategorySales.TotalSold)
    FROM
    (
        SELECT
            P2.CategoryID,
            SUM(I2.Quantity) AS TotalSold
        FROM PRODUCTS P2
        JOIN INCLUDES I2
            ON P2.ProductID = I2.ProductID
        GROUP BY P2.CategoryID
    ) AS CategorySales
)
ORDER BY TotalQuantitySold DESC;

--שאילתה 2-לקוחות שביצעו הזמנות של מוצרים מותאמים אישית
SELECT
    CustomerID,
    Name_First,
    Name_Last,
    Email
FROM CUSTOMERS
WHERE CustomerID IN (
    SELECT O.CustomerID
    FROM ORDERS O
    JOIN INCLUDES_PERSONALIZED IP
        ON O.OrderID = IP.OrderID
)
ORDER BY Name_Last, Name_First;

--שאילתה המשלבת Window Functions
--שאילתה 1- דירוג המוצרים הנמכרים ביותר בכל קטגוריה
SELECT
    C.Name AS CategoryName,
    P.ProductID,
    P.Name AS ProductName,
    SUM(I.Quantity) AS TotalSold,
    RANK() OVER (
        PARTITION BY C.CategoryID
        ORDER BY SUM(I.Quantity) DESC
    ) AS ProductRankInCategory
FROM PRODUCTS P
JOIN CATEGORIES C
    ON P.CategoryID = C.CategoryID
JOIN INCLUDES I
    ON P.ProductID = I.ProductID
GROUP BY
    C.CategoryID,
    C.Name,
    P.ProductID,
    P.Name
ORDER BY
    C.Name,
    ProductRankInCategory;

--שאילתה 2- ניתוח רצף ההזמנות של לקוחות
SELECT
    O.CustomerID,
    O.OrderID,
    O.Date,
    ROW_NUMBER() OVER (
        PARTITION BY O.CustomerID
        ORDER BY O.Date
    ) AS OrderNumber,
    LAG(O.Date) OVER (
        PARTITION BY O.CustomerID
        ORDER BY O.Date
    ) AS PreviousOrderDate,
    LEAD(O.Date) OVER (
        PARTITION BY O.CustomerID
        ORDER BY O.Date
    ) AS NextOrderDate
FROM ORDERS O
ORDER BY O.CustomerID, O.Date;

--שאילתה מקוננת תוך שימוש ב-CTE 
--קטגוריות בעלות הכנסות מעל הממוצע
WITH
CombinedSales AS (
    SELECT ProductID, Quantity FROM INCLUDES
    UNION ALL
    SELECT ProductID, Quantity FROM INCLUDES_PERSONALIZED
),
ProductRevenue AS (
    SELECT p.ProductID, p.CategoryID, SUM(cs.Quantity * p.Price) AS TotalProdRev
    FROM PRODUCTS p 
    JOIN CombinedSales cs ON p.ProductID = cs.ProductID
    GROUP BY p.ProductID, p.CategoryID
),
CategoryRevenue AS (
    SELECT CategoryID, SUM(TotalProdRev) AS TotalCatRev, MAX(TotalProdRev) AS BestProdRev
    FROM ProductRevenue 
    GROUP BY CategoryID
)
SELECT c.Name AS CategoryName, cr.TotalCatRev, cr.BestProdRev
FROM CATEGORIES c 
JOIN CategoryRevenue cr ON c.CategoryID = cr.CategoryID
WHERE cr.TotalCatRev > (SELECT AVG(TotalCatRev) FROM CategoryRevenue)
ORDER BY cr.TotalCatRev DESC;

-- שימוש בview של סיכום מכירות לפי מוצר
SELECT *
FROM vw_ProductSalesSummary
WHERE TotalRevenue > 1000
ORDER BY TotalRevenue DESC;

--הפעלה של פונקציה 1 
SELECT dbo.fn_CustomerStatus(5) AS CustomerStatus;

--הפעלה של פונקציה 2
SELECT *
FROM dbo.fn_HighRevenueProducts(1000);

--לפני הפעלת טריגר עדכון בINCLUDES
-- למצוא מוצר שנמצא בהזמנה שהושלמה
SELECT TOP 1
    I.OrderID,
    I.ProductID,
    I.Quantity,
    P.TotalQuantitySold
FROM INCLUDES I
JOIN ORDERS O
    ON I.OrderID = O.OrderID
JOIN PRODUCTS P
    ON I.ProductID = P.ProductID
WHERE O.Status = 'Completed';

--מצב לפני
SELECT
    ProductID,
    Name,
    TotalQuantitySold
FROM PRODUCTS
WHERE ProductID = 88;

--  הפעלת הטריגר
UPDATE INCLUDES
SET Quantity = Quantity + 1
WHERE OrderID = 1
  AND ProductID = 88;

--  מצב אחרי
SELECT
    ProductID,
    Name,
    TotalQuantitySold
FROM PRODUCTS
WHERE ProductID = 88;


--הפעלת פרוצדורה שמורה
--מוצר קיים מתווסף להזמנה
--לפני ההפעלה
--SELECT *
--FROM INCLUDES;
SELECT *
FROM INCLUDES 
Where OrderID=3 AND 
ProductID = 5;

--הפעלה-
EXEC AddProductToOrder
    @OrderID = 3,
    @ProductID = 5,
    @Quantity = 2;
    
    
--אחרי ההפעלה
SELECT *
FROM INCLUDES 
Where OrderID=3 AND 
ProductID = 5;


--שאילתה 1 של חלק 4
SELECT DISTINCT
    C.CustomerID,
    C.Name_First,
    C.Name_Last,
    C.Email
FROM CUSTOMERS C
JOIN ORDERS O
    ON C.CustomerID = O.CustomerID
JOIN INCLUDES_PERSONALIZED IP
    ON O.OrderID = IP.OrderID
ORDER BY C.Name_Last, C.Name_First;

--שאילתה 2 של חלק 4
WITH CombinedSales AS
(
    SELECT ProductID, Quantity
    FROM INCLUDES

    UNION ALL

    SELECT ProductID, Quantity
    FROM INCLUDES_PERSONALIZED
),
CategoryRevenue AS
(
    SELECT
        P.CategoryID,
        SUM(CS.Quantity * P.Price) AS TotalCatRev,
        MAX(ProductTotal.ProductRevenue) AS BestProdRev
    FROM PRODUCTS P
    JOIN CombinedSales CS
        ON P.ProductID = CS.ProductID
    JOIN
    (
        SELECT
            P2.ProductID,
            SUM(CS2.Quantity * P2.Price) AS ProductRevenue
        FROM PRODUCTS P2
        JOIN CombinedSales CS2
            ON P2.ProductID = CS2.ProductID
        GROUP BY P2.ProductID
    ) ProductTotal
        ON P.ProductID = ProductTotal.ProductID
    GROUP BY P.CategoryID
)
SELECT
    C.Name AS CategoryName,
    CR.TotalCatRev,
    CR.BestProdRev
FROM CATEGORIES C
JOIN CategoryRevenue CR
    ON C.CategoryID = CR.CategoryID
CROSS JOIN
(
    SELECT AVG(TotalCatRev) AS AvgRevenue
    FROM CategoryRevenue
) A
WHERE CR.TotalCatRev > A.AvgRevenue
ORDER BY CR.TotalCatRev DESC;
















