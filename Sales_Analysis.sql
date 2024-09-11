SELECT *
FROM [Portfolio Database]..customers
ORDER BY 1;

SELECT *
FROM [Portfolio Database]..orders;

SELECT *
FROM [Portfolio Database]..products;

--KPI's to be followed

--Sales Volume by Location (Country)
SELECT c.COUNTRY, ROUND(
	COUNT(c.COUNTRY) * 100 /
	(SELECT COUNT(o.ORDERNUMBER)
	 FROM [Portfolio Database]..orders o), 3
) AS Sales_Volume_Percentage
FROM [Portfolio Database]..customers c
GROUP BY c.COUNTRY
ORDER BY 2 DESC;

--Monthly Sales Growth
WITH CTE AS(
	SELECT o.MONTH_ID AS MONTH, SUM(o.SALES) AS MONTHLY_REVENUE
	FROM [Portfolio Database]..orders o
	GROUP BY o.MONTH_ID
),
CTE2 AS (
	SELECT *, LAG(MONTHLY_REVENUE) OVER (ORDER BY MONTH) AS PREVIOUS_REVENUE
	FROM CTE
)
SELECT *, (MONTHLY_REVENUE - PREVIOUS_REVENUE) * 100 / PREVIOUS_REVENUE AS MONTHLY_SALES_GROWTH
FROM CTE2;

--Average Purchase Value
SELECT ROUND(AVG(o.SALES), 2) AS AVERAGE_PURCHASE_VALUE
FROM [Portfolio Database]..orders o;

--Customer Retention Rate
WITH NEW_USER AS (
	SELECT o.YEAR_ID, MIN(o.MONTH_ID) AS FIRST_MONTH_PURCHASE, MAX(o.MONTH_ID) AS RECENT_MONTH_PURCHASE
	FROM [Portfolio Database]..customers c
	LEFT JOIN [Portfolio Database]..orders o
	ON o.[ORDER ID] = c.[ORDER ID]
	GROUP BY o.YEAR_ID
)
SELECT * FROM NEW_USER ORDER BY 1

--Monthly Recurring Revenue MRR and Annual Recurring Revenue ARR
WITH CTE AS(
	SELECT o.MONTH_ID AS MONTH, AVG(o.SALES) AS SALES_AVERAGE, COUNT(c.CUSTOMERNAME) AS PAYING_CUSTOMERS
	FROM [Portfolio Database]..customers c
	LEFT JOIN [Portfolio Database]..orders o
	ON o.[ORDER ID] = c.[ORDER ID]
	GROUP BY o.MONTH_ID
)
SELECT *, PAYING_CUSTOMERS * 100 / SALES_AVERAGE AS MRR_PERCENTAGE
FROM CTE
ORDER BY 1;

--Average Revenue per Account
SELECT c.CUSTOMERNAME AS CUSTOMER, ROUND(AVG(o.SALES), 2) AS AVERAGE_REVENUE
FROM [Portfolio Database]..customers c
LEFT JOIN [Portfolio Database]..orders o
ON c.[ORDER ID] = o.[ORDER ID]
GROUP BY c.CUSTOMERNAME
ORDER BY 2 DESC OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--Total Product Sales and Most Numbers of Acquisition
SELECT p.PRODUCTLINE, ROUND(SUM(o.SALES), 2) AS TOTAL_SALES, COUNT(*) AS NUMBER_OF_SALES
FROM [Portfolio Database]..orders o
LEFT JOIN [Portfolio Database]..products p
ON o.[ORDER ID] = p.[ORDER ID]
GROUP BY p.PRODUCTLINE
ORDER BY 2 DESC;
