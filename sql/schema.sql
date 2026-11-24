-- Zales database: schema (SQL Server)

CREATE TABLE ADDRESSES (
    AddressID INT PRIMARY KEY,
    Country VARCHAR(50),
    City VARCHAR(50),
    Street VARCHAR(100),
    HouseNumber INT,
    ZipCode VARCHAR(20)
);

CREATE TABLE PAYMENTS (
    CardNumber VARCHAR(20) PRIMARY KEY,
    ExpiredDate DATE,
    CVV VARCHAR(4)
);

CREATE TABLE CATEGORIES (
    CategoryID INT PRIMARY KEY,
    ParentCategoryID INT,
    Name VARCHAR(50),
    FOREIGN KEY (ParentCategoryID) REFERENCES CATEGORIES(CategoryID)
);

CREATE TABLE CUSTOMERS (
    CustomerID INT PRIMARY KEY,
    Email VARCHAR(100),
    Name_First VARCHAR(50),
    Name_Last VARCHAR(50),
    Password VARCHAR(100),
    Username VARCHAR(50),
    Phone VARCHAR(20),
    AddressID INT,
    FOREIGN KEY (AddressID) REFERENCES ADDRESSES(AddressID)
);

CREATE TABLE PRODUCTS (
    ProductID INT PRIMARY KEY,
    Name VARCHAR(100),
    Price DECIMAL(10,2),
    Description VARCHAR(500),
    Availability BIT,
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES CATEGORIES(CategoryID)
);

CREATE TABLE PERSONALIZED (
    ProductID INT,
    PersonalizedID INT,
    Style VARCHAR(50),
    Engraving VARCHAR(200),
    Color VARCHAR(50),
    Stone VARCHAR(50),
    Material VARCHAR(50),
    PRIMARY KEY (ProductID, PersonalizedID),
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID)
);

CREATE TABLE PRODUCT_MATERIAL_TYPES (
    ProductID INT,
    MaterialType VARCHAR(50),
    PRIMARY KEY (ProductID, MaterialType),
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID)
);

CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY,
    Date DATE,
    Status VARCHAR(30),
    CustomerID INT,
    CardNumber VARCHAR(20),
    AddressID INT,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID),
    FOREIGN KEY (CardNumber) REFERENCES PAYMENTS(CardNumber),
    FOREIGN KEY (AddressID) REFERENCES ADDRESSES(AddressID)
); 


CREATE TABLE INCLUDES (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID),
    FOREIGN KEY (ProductID) REFERENCES PRODUCTS(ProductID)
);

CREATE TABLE INCLUDES_PERSONALIZED (
    OrderID INT,
    ProductID INT,
    PersonalizedID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID, PersonalizedID),
    FOREIGN KEY (OrderID) REFERENCES ORDERS(OrderID),
    FOREIGN KEY (ProductID, PersonalizedID) REFERENCES PERSONALIZED(ProductID, PersonalizedID)
);

CREATE TABLE SAVES (
    CustomerID INT,
    CardNumber VARCHAR(20),
    PRIMARY KEY (CustomerID, CardNumber),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMERS(CustomerID),
    FOREIGN KEY (CardNumber) REFERENCES PAYMENTS(CardNumber)
);

CREATE TABLE ORDER_STATUS (
    Status VARCHAR(30) PRIMARY KEY
);

INSERT INTO ORDER_STATUS VALUES
('Pending'),
('Processing'),
('Shipped'),
('Delivered'),
('Cancelled'),
('Completed');

ALTER TABLE ORDERS
ADD CONSTRAINT FK_Orders_Status
FOREIGN KEY (Status)
REFERENCES ORDER_STATUS(Status);
