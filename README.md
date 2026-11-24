# Zales Jewelry E-Commerce Database

A relational database modeled on the online jewelry store Zales.com, built for the *Databases* course at Ben-Gurion University. The project goes from organizational background and ERD design through a normalized relational model, a populated SQL Server database, advanced T-SQL and a Power BI dashboard.

**Stack:** SQL Server (T-SQL) · Power BI

## What's inside

| Path | Contents |
|---|---|
| `sql/schema.sql` | Tables, keys, foreign keys and the order-status lookup |
| `sql/post_import_normalization.sql` | Run after importing the data: address lookup tables (country, city, street) and a card-number constraint |
| `sql/advanced_objects.sql` | Views, scalar and table-valued functions, a trigger-maintained sales column, a stored procedure, and indexes |
| `queries/analytical_queries.sql` | Analytical queries: joins, nested selects, CTEs, window functions (`RANK`, `ROW_NUMBER`, `LAG`, `LEAD`), plus trigger, view and stored-procedure usage |
| `data/` | Sample data as CSV files (customers, products, orders and more) |
| `powerbi/ZalesDashboard.pbix` | Power BI dashboard built on the `vw_SalesForPowerBI` view |
| `docs/` | Course reports: background, ERD and relational model, implementation |

## Data model

Customers place orders that include catalog products and personalized jewelry (style, engraving, color, stone, material). Orders ship to addresses and are paid with saved cards. Products belong to a hierarchical category tree.

Core tables: `CUSTOMERS`, `ADDRESSES`, `PAYMENTS`, `SAVES`, `ORDERS`, `INCLUDES`, `PRODUCTS`, `CATEGORIES`, `PERSONALIZED`, `INCLUDES_PERSONALIZED`, `PRODUCT_MATERIAL_TYPES`.

## Advanced T-SQL highlights

- **View** `vw_ProductSalesSummary` summarizes sales per product; `vw_SalesForPowerBI` feeds the dashboard.
- **Functions** `fn_CustomerStatus` (customer tier) and `fn_HighRevenueProducts` (products above a revenue threshold).
- **Trigger** `trg_UpdateProductSales` keeps `TotalQuantitySold` on `PRODUCTS` in sync with `INCLUDES`.
- **Stored procedure** `AddProductToOrder` validates input, then inserts a line or increases its quantity.

## Setup

1. Create a database and run `sql/schema.sql`.
2. Import the CSV files from `data/` into the matching tables (parents before children: addresses, payments, categories, customers, products, personalized, material types, orders, includes, includes_personalized, saves).
3. Run `sql/post_import_normalization.sql`, then `sql/advanced_objects.sql`.
4. Run any query from `queries/analytical_queries.sql`, or open the `.pbix` in Power BI Desktop and point it at your database.

## Note on the data

All data is synthetic. Card numbers and CVVs in the published CSVs are placeholders and customer passwords are masked.
