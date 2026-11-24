-- Views, functions, trigger and stored procedure

CREATE VIEW vw_ProductSalesSummary
AS
SELECT
    P.ProductID,
    P.Name AS ProductName,
    C.Name AS CategoryName,
    SUM(I.Quantity) AS TotalQuantitySold,
    SUM(I.Quantity * P.Price) AS TotalRevenue
FROM PRODUCTS P
JOIN CATEGORIES C
    ON P.CategoryID = C.CategoryID
JOIN INCLUDES I
    ON P.ProductID = I.ProductID
GROUP BY
    P.ProductID,
    P.Name,
    C.Name;

GO

CREATE FUNCTION dbo.fn_CustomerStatus
(
    @CustomerID INT
)
RETURNS VARCHAR(30)
AS
BEGIN
    DECLARE @OrdersCount INT;
    DECLARE @PersonalizedOrders INT;

GO

CREATE FUNCTION dbo.fn_HighRevenueProducts
(
@MinRevenue DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN
(
SELECT
ProductID,
ProductName,
CategoryName,
TotalQuantitySold,
TotalRevenue
FROM vw_ProductSalesSummary
WHERE TotalRevenue >= @MinRevenue
);

GO

ALTER TABLE PRODUCTS
ADD TotalQuantitySold INT DEFAULT 0;

GO

UPDATE P
SET TotalQuantitySold =
ISNULL((
    SELECT SUM(I.Quantity)
    FROM INCLUDES I
    JOIN ORDERS O
        ON I.OrderID = O.OrderID
    WHERE I.ProductID = P.ProductID
      AND O.Status = 'Completed'
),0)
FROM PRODUCTS P;

GO

CREATE TRIGGER trg_UpdateProductSales
ON INCLUDES
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE PRODUCTS
    SET TotalQuantitySold =
        ISNULL((
            SELECT SUM(I.Quantity)
            FROM INCLUDES I
            JOIN ORDERS O ON I.OrderID = O.OrderID
            WHERE I.ProductID = PRODUCTS.ProductID
              AND O.Status = 'Completed'
        ), 0)
    WHERE ProductID IN (
        SELECT ProductID FROM inserted
        UNION
        SELECT ProductID FROM deleted
    );
END;

GO

CREATE PROCEDURE AddProductToOrder
    @OrderID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    IF @Quantity <= 0
    BEGIN
        PRINT 'Quantity must be positive';
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM ORDERS
        WHERE OrderID = @OrderID
    )
    BEGIN
        PRINT 'Order does not exist';
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM PRODUCTS
        WHERE ProductID = @ProductID
          AND Availability = 1
    )
    BEGIN
        PRINT 'Product does not exist or is not available';
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM INCLUDES
        WHERE OrderID = @OrderID
          AND ProductID = @ProductID
    )
    BEGIN
        UPDATE INCLUDES
        SET Quantity = Quantity + @Quantity
        WHERE OrderID = @OrderID
          AND ProductID = @ProductID;

        PRINT 'Product quantity updated in order';
    END
    ELSE
    BEGIN
        INSERT INTO INCLUDES (OrderID, ProductID, Quantity)
        VALUES (@OrderID, @ProductID, @Quantity);

        PRINT 'Product added to order';
    END;
END;

GO

CREATE VIEW vw_SalesForPowerBI AS
SELECT
    O.OrderID,
    O.Date,
    O.Status,
    C.CustomerID,
    C.Name_First,
    C.Name_Last,
    A.Country,
    A.City,
    P.ProductID,
    P.Name AS ProductName,
    CAT.Name AS CategoryName,
    I.Quantity,
    P.Price,
    I.Quantity * P.Price AS TotalAmount
FROM ORDERS O
JOIN CUSTOMERS C ON O.CustomerID = C.CustomerID
JOIN ADDRESSES A ON O.AddressID = A.AddressID
JOIN INCLUDES I ON O.OrderID = I.OrderID
JOIN PRODUCTS P ON I.ProductID = P.ProductID
JOIN CATEGORIES CAT ON P.CategoryID = CAT.CategoryID
WHERE O.Status = 'Completed';

GO

CREATE INDEX IX_Orders_CustomerID
ON ORDERS(CustomerID);

GO

CREATE INDEX IX_IncludesPersonalized_OrderID
ON INCLUDES_PERSONALIZED(OrderID);

GO

CREATE INDEX IX_Includes_ProductID
ON INCLUDES(ProductID);

GO

CREATE INDEX IX_IncludesPersonalized_ProductID
ON INCLUDES_PERSONALIZED(ProductID);

GO

CREATE INDEX IX_Products_ProductID_CategoryID
ON PRODUCTS(ProductID, CategoryID);
