USE [TDI_DB]
---Aggregate the orders table
SELECT order_id, order_date, ship_date, customer, customer_id
INTO orders_aggregated
FROM [dbo].[orders ]
GROUP BY order_id, order_date, ship_date, customer, customer_id;
select *
from orders_aggregated
---drop orders table and rename orders_aggregated to 'orders'
select *
from orders
-----DATA CLEANING 
----remove duplicates in orders table --1 duplicate
----USING CTE
WITH deleteduplcates AS (
SELECT *,
ROW_NUMBER () OVER (PARTITION BY order_id, order_date, ship_date, customer ORDER BY customer DESC) AS Rowno
FROM [dbo].[orders ]
)
DELETE FROM deleteduplcates
WHERE Rowno > 1
;

----Add Customer_id to orders table
ALTER TABLE [dbo].[orders ]
ADD customer_Id UNIQUEIDENTIFIER;
UPDATE  O
SET O.customer_Id = C.customer_Id
FROM [dbo].[orders ] O
INNER JOIN Customers C 
ON O.customer = C.customer
 
---verify ids
SELECT O.customer_id, C.customer_id
FROM [dbo].[orders ] O
JOIN [dbo].[customers ] C
ON O.customer = C.customer
WHERE O.customer_id = C.customer_id
;

--make customer_id foreign key on orders table
ALTER TABLE [dbo].[orders ]
ADD CONSTRAINT FK_orders_customers
FOREIGN KEY (Customer_Id) REFERENCES [dbo].[customers ](Customer_Id)
;

---Make orders table primary key
ALTER TABLE [dbo].[orders]
ADD CONSTRAINT PK_orders_order_Id
PRIMARY KEY (order_id);
 
----Remove duplicates in customers table
--check customers table duplicates
SELECT *, COUNT (*) AS CNT
FROM [dbo].[customers ]
GROUP BY customer, segment, region, city, state, country
HAVING COUNT (*) > 1 
; 

--Remove duplicates 
WITH deleteduplcates AS (
SELECT *,
ROW_NUMBER () OVER (PARTITION BY customer, segment, region, city, state, country ORDER BY customer ) AS Rowno
FROM [dbo].[customers ]
)
DELETE FROM deleteduplcates
WHERE Rowno > 1
;
SELECT * FROM [dbo].[customers ]; 


--Assign unique customer_ids to customers table
ALTER TABLE [dbo].[customers ]
ADD Customer_Id UNIQUEIDENTIFIER DEFAULT (NEWSEQUENTIALID()) NOT NULL;

SELECT * FROM [dbo].[customers ];

----Remove duplicates in order details table
--check order details table duplicates
SELECT *, COUNT (*) AS CNT
FROM [dbo].[orders_details ]
GROUP BY order_id, discount, quantity, profit_margin
HAVING COUNT (*) > 1 
; 

--Remove duplicates 
WITH deleteduplcates AS (
SELECT *,
ROW_NUMBER () OVER (PARTITION BY order_id, discount, quantity, profit_margin ORDER BY quantity DESC) AS Rowno
FROM [dbo].[orders_details ]
)
DELETE FROM deleteduplcates
WHERE Rowno > 1
;
SELECT *
FROM [dbo].[orders_details ] 
---9935 rows after removing duplicates

--Assign unique orders_details_ids to orders_details table
ALTER TABLE [dbo].[orders_details ]
ADD orders_details_id UNIQUEIDENTIFIER DEFAULT (NEWSEQUENTIALID()) NOT NULL ;

----Add product_id to orders_details table
ALTER TABLE [dbo].[orders_details ]
ADD products_Id UNIQUEIDENTIFIER;
UPDATE  Od
SET Od.products_Id = P.products_Id
FROM [dbo].[orders_details ] Od
INNER JOIN [dbo].[Products] P
ON Od.order_Id = P.order_id
----verify ids
SELECT Od.products_Id, P.products_Id
FROM [dbo].[orders_details ] Od
INNER JOIN [dbo].[Products] P
ON Od.order_Id = P.order_id
WHERE Od.products_Id = P.products_Id
;

--make order_id & product_Id foreign key on orders table
ALTER TABLE [dbo].[orders_details ]
ALTER TABLE [dbo].[orders_details ]
ADD CONSTRAINT FK_orders_details_orders
FOREIGN KEY (order_id) REFERENCES  [dbo].[orders ](order_id) ;
ALTER TABLE [dbo].[orders_details ]
ADD CONSTRAINT FK_ordersdetails_Products
FOREIGN KEY (products_Id) REFERENCES [dbo].[Products](products_Id)  


---Normalize discount and profit_margin data format in orders_details table
SELECT *
FROM [dbo].[orders_details ]
UPDATE [dbo].[orders_details ]
SET discount = ROUND(discount,2),
profit_margin = ROUND(profit_margin,2);

----Remove duplicates in Products table
--check Products table duplicates
SELECT *, COUNT (*) AS CNT
FROM [dbo].[Products]
GROUP BY order_id, manufactory, product_name, segment, category, subcategory
HAVING COUNT (*) > 1 
; ---8 duplicates records found
--Remove duplicates 
WITH deleteduplcates AS (
SELECT *,
ROW_NUMBER () OVER (PARTITION BY order_id, manufactory, product_name, segment, category, subcategory ORDER BY manufactory DESC) AS Rowno
FROM [dbo].[Products]
)
DELETE FROM deleteduplcates
WHERE Rowno > 1
; 
----9986 rows after removing duplicates

--Assign unique Products_ids to Products table
ALTER TABLE [dbo].[Products]
ADD Products_id UNIQUEIDENTIFIER DEFAULT (NEWSEQUENTIALID()) NOT NULL
;
---make order_id foreign key in the Products table
ALTER TABLE [dbo].[Products]
ADD CONSTRAINT FK_products_orders
FOREIGN KEY (order_id) REFERENCES  [dbo].[orders ](order_id) ;

SELECT *--- p.product_id
FROM [dbo].[Products] p

----2
SELECT *
FROM [dbo].[orders ] ---5009 rows
SELECT *
FROM [dbo].[customers ] ----4688 rows
SELECT *
FROM [dbo].[orders_details ] ---9935 rows
SELECT *
FROM [dbo].[Products] ----9986 rows

---join the required tables together
SELECT od.order_id,o.order_date, o.ship_date, 
c.customer, c.customer_id, c.segment, c.region,	c.city,	c.state, c.country,	
od.discount,od.sales, od.quantity, od.profit, od.profit_margin,	od.products_Id,
p.manufactory,p.product_name,	p.category,	p.Subcategory
GET INTO superstoreDB
FROM  [dbo].[orders] O
INNER JOIN [dbo].[orders_details ] Od
ON O.order_Id = Od.order_id
INNER JOIN [dbo].[customers ] C
ON c.Customer_Id = o.customer_id
INNER JOIN [dbo].[Products] P
ON Od.products_Id = P.Products_id
;
 SELECT * FROM [dbo].[superstoreDB]

---Data analysis
---KPIS
---Total_sales
SELECT ROUND(SUM(sales),2) AS Total_sales
FROM [dbo].[superstoreDB]
---Total profit 
SELECT ROUND(SUM(profit),2) AS Total_profit
FROM [dbo].[superstoreDB]
;
---Total profit margin
SELECT ROUND(SUM(profit_margin),2) AS Total_profit_margin
FROM [dbo].[superstoreDB]
;
---Total orders
SELECT COUNT(DISTINCT order_id) AS Total_orders
FROM [dbo].[superstoreDB]
;
---Total Quantity
SELECT SUM( Quantity) AS Total_Quantity
FROM [dbo].[superstoreDB]
;
---Total customer
SELECT COUNT(DISTINCT customer) AS Total_Customers
FROM [dbo].[superstoreDB]
----Total states
SELECT COUNT(DISTINCT state) AS Total_states
FROM [dbo].[superstoreDB]
-------Total city
SELECT COUNT(DISTINCT city) AS Total_cities
FROM [dbo].[superstoreDB]


---store performance
--sales by month
SELECT YEAR (order_date) AS order_year,
MONTH (order_date) AS Month_no,
DATENAME (MONTH, order_date) AS order_month,
SUM(sales) AS current_year_revenue,
LAG(SUM(sales),1, SUM(sales)) OVER (PARTITION BY DATENAME (MONTH, order_date) ORDER  BY DATENAME (MONTH, order_date), YEAR (order_date)) AS Prev_year_revenue
FROM [dbo].[superstoreDB]
GROUP BY DATENAME (MONTH, order_date), MONTH (order_date),
YEAR (order_date)
ORDER BY Month_no
;
---sales by category
SELECT YEAR (order_date) AS order_year,
category,
ROUND(SUM(sales),2) AS current_year_revenue, 
LAG(SUM(sales),1, SUM(sales)) OVER (PARTITION BY category  ORDER  BY category, YEAR (order_date)) AS Prev_year_revenue
FROM [dbo].[superstoreDB]
GROUP BY YEAR (order_date),
category
ORDER BY category
;

--sales by region
SELECT YEAR (order_date) AS order_year,
region,
SUM(sales) AS current_year_revenue,
LAG(SUM(sales),1, SUM(sales)) OVER (PARTITION BY region  ORDER  BY region, YEAR (order_date)) AS Prev_year_revenue
FROM [dbo].[superstoreDB]
GROUP BY YEAR (order_date),
region
ORDER BY region
;

--sales by segment
SELECT YEAR (order_date) AS order_year,
segment,
SUM(sales) AS current_year_revenue,
LAG(SUM(sales),1, SUM(sales)) OVER (PARTITION BY segment ORDER  BY segment, YEAR (order_date)) AS Prev_year_revenue
FROM [dbo].[superstoreDB]
GROUP BY YEAR (order_date),
segment
ORDER BY segment
;


---customer segmentation
---who are top customers by revenue?
SELECT TOP (10) customer,
SUM(sales) AS total_revenue
FROM [dbo].[superstoreDB]
GROUP BY customer
ORDER BY total_revenue DESC;

---Total purchase by customers
SELECT TOP (10) customer, customer_Id,
COUNT (*) AS Total_purchase
FROM [dbo].[superstoreDB]
GROUP BY customer, customer_Id
ORDER BY Total_purchase DESC;

---Total number of customers in each state
SELECT state,
COUNT(DISTINCT Customer_Id) AS customer_count
FROM [dbo].[superstoreDB]
GROUP BY state
ORDER BY customer_count DESC;

---Total number of customers in each cities
SELECT TOP (10)  city,
COUNT(DISTINCT Customer_Id) AS customer_count
FROM [dbo].[superstoreDB]
GROUP BY city
ORDER BY customer_count DESC;

---Total number of customers in each region
SELECT region,
COUNT(DISTINCT Customer_Id) AS customer_count
FROM [dbo].[superstoreDB]
GROUP BY region
ORDER BY customer_count DESC;

---Recent customer purchase
SELECT TOP (10) customer,
MAX (order_date) AS recent_purchase_date
FROM [dbo].[superstoreDB]
GROUP BY customer
ORDER BY recent_purchase_date DESC
;

---Top products manufactory by purchase frequency
SELECT TOP (10) manufactory,
COUNT (order_id) AS purchase_frequency
FROM [dbo].[superstoreDB] 
GROUP BY manufactory
ORDER BY purchase_frequency DESC
;
------- year-over-year revenue growth from 2019-2022
WITH Yearly_revenue
AS
(
	SELECT 
		YEAR (order_date) AS order_year,
		ROUND(SUM(sales),2) AS current_year_revenue, 
		LAG(ROUND(SUM(sales),2),1, ROUND(SUM(sales),2)) OVER (ORDER BY YEAR (order_date)) AS Prev_year_revenue
		FROM [dbo].[superstoreDB]
GROUP BY YEAR (order_date)
)	
	SELECT 
		order_year,
		current_year_revenue,
		Prev_year_revenue,
	 ROUND((( current_year_revenue - Prev_year_revenue)/ Prev_year_revenue * 100), 2)
	 AS YOY_growth_rate
	FROM Yearly_revenue
;


------- year-over-year profit_margin growth from 2019-2022
WITH Yearly_profit_margin
AS
(
	SELECT 
		YEAR (o.order_date) AS order_year,
		SUM(od.profit_margin) AS current_year_profit_margin,
		LAG(SUM(od.profit_margin),1, SUM(od.profit_margin)) OVER (ORDER BY YEAR (o.order_date)) AS Prev_year_profit_margin
		FROM [dbo].[orders] o   
		JOIN [dbo].[orders_details ] od
		ON od.order_id = o.order_id
GROUP BY YEAR (o.order_date)
)	
	SELECT 
		order_year,
		current_year_profit_margin,
		Prev_year_profit_margin,
	   (( current_year_profit_margin - Prev_year_profit_margin)/ Prev_year_profit_margin * 100) AS YOY_profit_margin_growth
	FROM Yearly_profit_margin
;

------- year-over-year order growth from 2019-2022
WITH Yearly_orders
AS
(
	SELECT 
		YEAR (o.order_date) AS order_year,
		COUNT(od.order_id) AS current_year_orders,
		LAG(COUNT(od.order_id),1, COUNT(od.order_id)) OVER (ORDER BY YEAR (o.order_date)) AS Prev_year_orders
		FROM [dbo].[orders] o   
		JOIN [dbo].[orders_details ] od
		ON od.order_id = o.order_id
GROUP BY YEAR (o.order_date)
),
Order_growth AS
(
	SELECT 
		order_year,
		current_year_orders,
		Prev_year_orders,
	   ( current_year_orders - Prev_year_orders) * 100 AS YOY ---- 
	FROM Yearly_orders
)
SELECT 
		order_year,
		current_year_orders,
		Prev_year_orders,
		YOY/Prev_year_orders AS YOY_orders_growth
FROM    Order_growth
;

------- year-over-year quantity growth from 2019-2022
WITH Yearly_quantity
AS
(
	SELECT 
		YEAR (o.order_date) AS order_year,
		SUM(quantity) AS current_year_quantity,
		LAG(SUM(quantity),1, SUM(quantity)) OVER (ORDER BY YEAR (o.order_date)) AS Prev_year_quantity
		FROM [dbo].[orders] o   
		JOIN [dbo].[orders_details ] od
		ON od.order_id = o.order_id
GROUP BY YEAR (o.order_date)
),

Quantity_growth AS
(
	SELECT 
		order_year,
		current_year_quantity,
		Prev_year_quantity,
	   ( current_year_quantity - Prev_year_quantity) * 100 AS YOY  
	FROM Yearly_quantity
)
SELECT 
		order_year,
		current_year_quantity,
		Prev_year_quantity,
		YOY/Prev_year_quantity AS YOY_quantity_growth
FROM    quantity_growth
;