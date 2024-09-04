-- Create database

CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create table

CREATE TABLE IF NOT EXISTS salesdata(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL,
    rating FLOAT
);

-- Feature Engineering:

-- Add a new column named 'time_of_day' to give insight of sales in the Morning, Afternoon and Evening. 
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM salesdata;

ALTER TABLE salesdata ADD COLUMN time_of_day VARCHAR(20);

UPDATE salesdata
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

-- Add a new column named 'day_name' that contains the extracted days of the week on which the given transaction took place 
-- (Monday, Tuesday, Wednesday, Thursday, Friday)
ALTER TABLE salesdata ADD COLUMN day_name VARCHAR(10);

UPDATE salesdata
SET day_name = DAYNAME(Date);

-- Add a new column named 'month_name' that contains the extracted months of the year on which the given transaction took place.
ALTER TABLE salesdata ADD COLUMN month_name VARCHAR(10);

UPDATE salesdata
SET month_name = MONTHNAME(Date);

-- Exploratory Data Analysis (EDA):
-- How many unique cities does the data have?
SELECT DISTINCT(City)
FROM salesdata;

SELECT DISTINCT(Branch)
FROM salesdata;

-- In which city is each branch?
SELECT DISTINCT(City), Branch
FROM salesdata;

-- Product based questions
-- How many unique product lines does the data have?
SELECT DISTINCT(product_line)
FROM salesdata;

-- What is the most common payment method?
SELECT payment, COUNT(payment) count
FROM salesdata
GROUP BY payment
ORDER BY payment DESC;

-- What is the most selling product line?
SELECT product_line, COUNT(product_line) AS count
FROM salesdata
GROUP BY product_line
ORDER BY product_line DESC;

-- What is the total revenue by month?
SELECT month_name AS month, SUM(total) AS revenue
FROM salesdata
GROUP BY month_name
ORDER BY revenue DESC;

-- What month had the largest COGS?
SELECT month_name AS month, SUM(cogs) AS COGS
FROM salesdata
GROUP BY month
ORDER BY COGS DESC;

-- What product line had the largest revenue?
SELECT product_line, SUM(total) AS revenue
FROM salesdata
GROUP BY product_line
ORDER BY revenue DESC;

-- What is the city with the largest revenue?
SELECT city, SUM(total) AS total_revenue
FROM salesdata
GROUP BY city
ORDER BY total_revenue;

-- What product line had the largest VAT?
SELECT product_line, SUM(tax_pct) AS VAT
FROM salesdata
GROUP BY product_line
ORDER BY VAT;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
WITH CTE_Sub_Table AS (
SELECT ROUND(AVG(Total),2) Avg_Total_Sales
FROM salesdata
)
SELECT product_line, ROUND(SUM(total),2) AS total_sales,ROUND(AVG(total),2) AS avg_sales, 
CASE
WHEN AVG(total) > (SELECT * FROM CTE_Sub_Table) THEN 'Good'
ELSE 'Bad'
END AS status_of_sales
FROM salesdata
GROUP BY product_line
ORDER BY 2 DESC; 

-- Which branch sold more products than average product sold?
SELECT branch 
FROM salesdata 
WHERE quantity < (SELECT AVG(quantity) FROM salesdata)
GROUP BY branch;

-- What is the most common product line by gender?
SELECT product_line, gender, count(gender) AS cnt
FROM salesdata
GROUP BY gender, product_line
ORDER BY cnt DESC;

-- What is the average rating of each product line?
SELECT ROUND(AVG(rating),2) as avg_rating, product_line
FROM salesdata
GROUP BY product_line
ORDER BY avg_rating DESC; 

-- Sales based questions
select * from salesdata;
-- Number of sales made in each time of the day per weekday
SELECT time_of_day, COUNT(*) as sales
FROM salesdata
WHERE day_name = "Sunday"
GROUP BY time_of_day
ORDER BY sales DESC;

-- Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS most_revenue 
FROM salesdata
GROUP BY customer_type
ORDER BY most_revenue;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, ROUND(AVG(tax_pct),2) as vat
FROM salesdata
GROUP BY city
ORDER BY vat DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type, ROUND(AVG(tax_pct),2) AS VAT
FROM salesdata
GROUP BY customer_type
ORDER BY VAT DESC;

-- Customer based questions

-- How many unique customer types does the data have?
SELECT DISTINCT(customer_type)
FROM salesdata;

-- How many unique payment methods does the data have?
SELECT DISTINCT(payment)
FROM salesdata;

-- What is the most common customer type?
SELECT customer_type, COUNT(*) AS CNT
FROM salesdata
GROUP BY customer_type
ORDER BY CNT DESC;

-- Which customer type buys the most?
SELECT customer_type, COUNT(*) AS purchase
FROM salesdata
GROUP BY customer_type
ORDER BY purchase DESC;

-- What is the gender of most of the customers?
SELECT gender, COUNT(*) AS customers
FROM salesdata
GROUP BY gender
ORDER BY customers DESC;

-- What is the gender distribution per branch?
SELECT gender, COUNT(*) AS customers
FROM salesdata
WHERE branch = "C"
GROUP BY gender
ORDER BY customers DESC;

-- Which time of the day do customers give most ratings?
SELECT time_of_day, ROUND(AVG(rating),1) as most_rating
FROM salesdata
GROUP BY time_of_day
ORDER BY most_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day, ROUND(AVG(rating),1) as most_rating
FROM salesdata
WHERE branch = "B"
GROUP BY time_of_day
ORDER BY most_rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT day_name, ROUND(AVG(rating),1) as best_rating
FROM salesdata
GROUP BY day_name
ORDER BY best_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT day_name, ROUND(AVG(rating),1) as best_rating
FROM salesdata
WHERE branch = "A"
GROUP BY day_name
ORDER BY best_rating DESC;