CREATE TABLE RETAILS (
	ORDER_ID INT NOT NULL,
	ORDER_DATE DATE,
	SHIP_MODE VARCHAR(50),
	SEGMENT VARCHAR(50),
	COUNTRY VARCHAR(50),
	CITY VARCHAR(50),
	STATE VARCHAR(50),
	POSTAL_CODE BIGINT,
	REGION VARCHAR(20),
	CATEGORY VARCHAR(50),
	SUB_CATEGORY VARCHAR(50),
	PRODUCT_ID VARCHAR(50),
	QUANTITY SMALLINT,
	DISCOUNT_VALUE NUMERIC(10, 2),
	SALE NUMERIC(10, 2),
	PROFIT NUMERIC(10, 2)
)
SELECT
	*
FROM
	RETAILS
	-- find top 10 highest revenue generating products
SELECT
	PRODUCT_ID,
	SUM(SALE) AS REVENUE
FROM
	RETAILS
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT
	10
	-- top 5 highest selling product in each region
WITH
	CTES AS (
		SELECT
			REGION,
			PRODUCT_ID,
			SUM(SALE) AS SALES,
			ROW_NUMBER() OVER (
				PARTITION BY
					REGION
				ORDER BY
					SUM(SALE) DESC
			) AS RANK
		FROM
			RETAILS
		GROUP BY
			1,
			2
	)
SELECT
	*
FROM
	CTES
WHERE
	RANK <= 5
SELECT
	*
FROM
	RETAILS
	-- find mmonth over month  comparisn of 2022 and 2023 sales ex jan 2022 to jan 2023
WITH
	CTES AS (
		SELECT
			EXTRACT(
				MONTH
				FROM
					ORDER_DATE
			) AS MONTH_NUMBER,
			TO_CHAR(ORDER_DATE, 'Mon') AS MONTH_NAME,
			SUM(
				CASE
					WHEN EXTRACT(
						YEAR
						FROM
							ORDER_DATE
					) = 2022 THEN SALE
				END
			) AS SALE2022,
			SUM(
				CASE
					WHEN EXTRACT(
						YEAR
						FROM
							ORDER_DATE
					) = 2023 THEN SALE
				END
			) AS SALE2023
		FROM
			RETAILS
		GROUP BY
			1,
			2
		ORDER BY
			1
	)
SELECT
	*,
	((SALE2023 - SALE2022) * 100.0 / SALE2022)::NUMERIC(10, 2) AS MOMPERECNT
FROM
	CTES
	-- for each category which month has highest sale
WITH
	CTES AS (
		SELECT
			EXTRACT(
				MONTH
				FROM
					ORDER_DATE
			) AS MONTH,
			EXTRACT(
				YEAR
				FROM
					ORDER_DATE
			) AS YEAR,
			CATEGORY,
			SUM(SALE) AS SALES
		FROM
			RETAILS
		GROUP BY
			1,
			2,
			3
		ORDER BY
			3 DESC
	)
SELECT
	*
FROM
	(
		SELECT
			*,
			ROW_NUMBER() OVER (
				PARTITION BY
					CATEGORY
				ORDER BY
					SALES DESC
			) AS RANK
		FROM
			CTES
	) RN
WHERE
	RANK = 1
	-- which subcategory has highest growth by profit in 2023 compre to 2022
WITH
	CTES AS (
		SELECT DISTINCT
			SUB_CATEGORY,
			SUM(
				CASE
					WHEN EXTRACT(
						YEAR
						FROM
							ORDER_DATE
					) = 2022 THEN SALE
					ELSE 0
				END
			) AS SALE22,
			SUM(
				CASE
					WHEN EXTRACT(
						YEAR
						FROM
							ORDER_DATE
					) = 2023 THEN SALE
					ELSE 0
				END
			) AS SALE23
		FROM
			RETAILS
		GROUP BY
			1
	)
SELECT
	*,
	((SALE23 - SALE22) * 100.0 / SALE22)::NUMERIC(10, 2) AS GROWTHPERCENT
FROM
	CTES
ORDER BY
	GROWTHPERCENT DESC
LIMIT
	5