# Annie-Superstore-Sales (2019-2022)

## Table of contents
- [Project Overview](#Project-Overview)
- [Data Sources](#Data-Sources)
- [Tools](#Tools)
- [Exploratory Data Analysis](#Exploratory-Data-Analysis)
- [Data Analysis](#Data-Analysis)
- [Findings](#Findings)
- [Recommendation](#Recommendation)
- [Conclusion](#Conclusion)


### Project Overview

Annie Superstore dataset provides a comprehensive sales record spanning from 2019 to 2022, featuring a diverse range of products including furniture, office supplies, and technology. This dataset encompasses detailed information on order specifics, anonymized customer data, product details, and key financial metrics, offering valuable insights into sales trends and customer behavior.

### Data Sources
Annie superstore dataset was obtained from Kaggle and it contained 9,994 entries across 19 distinct fields but after data cleaning, it contained 9,935 entries across 21 distinct fields with 4 obtainable tables which includes:

- **Orders data:** This holds detailed information about orders like the order ID, order date, ship date.

- **Customer data:** Contains demographic information about customers, including names, locations, and customer ID numbers.

- **Order details data:** This holds records of sales including the year-to-year sales, the profits, profit margin, and discount made from these transactions, and the quantities sold.

- **Product Data:** Contains details about the product Inventory, including product categories, names, sub-categories, and manufactory. 

### Tools
-	Excel – Data reporting 
-	SQL Server – Data cleaning and analysis
  
### Data cleaning/Preparation
The sales dataset was loaded into SQL, and data cleaning and transformation were performed using ETL (Extract, Transform, Load) processes in MS SQL to prepare the data for exploration and modeling and performed the following:

- Handling Missing Data Points: The missing values were removed upon data importation since it was merely significant.
  
- Normalizing Inconsistent Data: Standardize formats for dates and other fields to ensure consistency.
  
- Ensuring Data Integrity: Validate relationships between tables and rectify any referential integrity issues.
  
- Filtering Irrelevant Data: The columns or rows that are not necessarily needed for the analysis were removed.
  
- Renaming Tables and Columns to Meaningful Names: Used descriptive names for tables and columns to enhance clarity.
  
- Documentation: A detailed record of all the processes is duly documented.

### Exploratory Data Analysis
EDA is involved in exploring the sales data to answer questions such as;

- What are the overall sales trends and patterns from 2019 to 2022?

- Which regions, segments, and categories have experienced the most significant growth or decline in sales from 2019 to 2022?

- Which segments are most profitable, and how do sales trends vary within each segment?

- What are the most popular products/manufactory among customers?

- Which customer segments are most profitable? 

- Who are our top customers?

### Data Analysis
The following are some of the queries used for the analysis.
``` sql
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
```
``` Sql
------- Year-over-year revenue growth from 2019-2022
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
```
### Results/ Findings
The analysis results are summarized as follows;

- Total Revenue generated over 4 years: $2.29M.

- Revenue declined in 2020 due to the  COVID-19 pandemic.

- 29% revenue growth in 2021 after pandemic measures eased.

- 20% revenue growth in 2022, slightly lower than 2021 

*Possible reason for slower growth in 2022:*

*-Russia-Ukraine war*

*-Inflation in the United States*

*-Impact on consumer purchasing power and business costs.*

- Superstore sales experienced volatility in sales month. 

- September, October, November, and December performing better than the rest of the months this might be due to sales event like Black Friday and Cyber Monday during this period of festivities.

- An average of $320K in revenue in the furniture category (the highest sought-after category) 

*Possible reason: furniture market is larger and more diverse, as it offers many other product varieties and customizations, unlike the office supply and technology categories, which accrued an average of $199K and $54K respectively, lower than the furniture category.*

- Central region emerged region with the highest revenue raised with an average of $220K in revenue with the South, East, and West trailing behind at $111K, $141K, and $99K respectively.

*Possible reason: larger populations, presence of many manufacturing industries.*

- The Consumer segment emerges as the strongest segment in terms of revenue generated, with a whopping average of $289K whereas the Corporate and Home Office segments each amassed mere averages above $170K and $100K respectively.

*Possible reason: Consumer segment generally surpasses both segments in size and market share across many industries*

### Recommendation
- The company should review the communication strategy during the 2020 lockdown. 

- Implementing strategies to retain the customers gained during the 2021 growth spurt 

- Employ loyalty programs, personalized offers, and excellent customer service to influence customers who made more purchases and generated more revenue for the company like Sean Miller And William Brown.

- Review pricing strategies by offering a wider range of price points or promotional offers to maintain sales volume despite reduced consumer purchasing power. 

- Since the furniture is the most sought-after category consider further investment, given its high revenue generation and market diversity. This could include expanding product lines, improving customization options, or enhancing the customer experience.

### Conclusion
  The past four years paint a compelling picture of resilience and opportunity for the superstore. Despite the seismic shock of a global pandemic and the ripple effects of geopolitical instability, the company has demonstrated an underlying strength, culminating in a total revenue of $2.29M. While external forces introduced periods of contraction, the remarkable 29% surge in 2021 stresses the potential for significant growth when conditions align.  The insights gathered are not merely historical data points, but crucial indications guiding the journey of Annie Store towards a more resilient and prosperous future.

Click [here](https://medium.com/@obendeefi/annie-superstore-sales-analysis-2019-2022-8d4488308165?source=user_profile_page---------0-------------324819dc805e----------------------) for more info and to view the Dashboard!


