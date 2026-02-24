-- Games Metadata Table Structure

CREATE TABLE games (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    release_date DATE,
    team VARCHAR(255),
    rating DECIMAL(3,1),
    times_listed INT,
    number_of_reviews INT,
    genres VARCHAR(255),
    plays INT,
    playing INT,
    backlogs INT,
    wishlist INT
);

-- Sales Data Table Structure

CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255),
    platform VARCHAR(50),
    year INT,
    genre VARCHAR(100),
    publisher VARCHAR(255),
    na_sales DECIMAL(10,2),
    eu_sales DECIMAL(10,2),
    jp_sales DECIMAL(10,2),
    other_sales DECIMAL(10,2),
    global_sales DECIMAL(10,2)
);


-- Top Rated Games by User Reviews

SELECT title, rating
FROM games
ORDER BY rating DESC
LIMIT 10;

-- Developers with Highest Average Ratings

SELECT team,
       ROUND(AVG(rating),2) AS avg_rating,
       COUNT(*) AS total_games
FROM games
GROUP BY team
HAVING COUNT(*) >= 3
ORDER BY avg_rating DESC
LIMIT 10;

-- Most Common Genres

SELECT genres, COUNT(*) AS total_games
FROM games
GROUP BY genres
ORDER BY total_games DESC;

-- Games with Highest Backlog to Wishlist Ratio

SELECT title,
       backlogs,
       wishlist,
       (backlogs / wishlist) AS backlog_ratio
FROM games
WHERE wishlist > 0
ORDER BY backlog_ratio DESC
LIMIT 10;

-- Release Trend by Year

SELECT YEAR(release_date) AS release_year,
       COUNT(*) AS total_games
FROM games
GROUP BY release_year
ORDER BY release_year;

-- Rating Distribution

SELECT rating, COUNT(*) AS total_games
FROM games
GROUP BY rating
ORDER BY rating DESC;

-- Top Wishlisted Games

SELECT title, wishlist
FROM games
ORDER BY wishlist DESC
LIMIT 10;

-- Average Plays per Genre

SELECT genres,
       ROUND(AVG(plays),0) AS avg_plays
FROM games
GROUP BY genres
ORDER BY avg_plays DESC;

-- Most Productive Developers

SELECT team,
       COUNT(*) AS total_games,
       ROUND(AVG(rating),2) AS avg_rating
FROM games
GROUP BY team
ORDER BY total_games DESC
LIMIT 10;

-- Regional Sales Comparison

SELECT 
    SUM(na_sales) AS NA_Total,
    SUM(eu_sales) AS EU_Total,
    SUM(jp_sales) AS JP_Total,
    SUM(other_sales) AS Other_Total
FROM sales;

-- Best Selling Platforms

SELECT platform,
       SUM(global_sales) AS total_sales
FROM sales
GROUP BY platform
ORDER BY total_sales DESC;

-- Sales Trend Over Years

SELECT year,
       SUM(global_sales) AS yearly_sales
FROM sales
GROUP BY year
ORDER BY year;

-- Top Publishers by Sales

SELECT publisher,
       SUM(global_sales) AS total_sales
FROM sales
GROUP BY publisher
ORDER BY total_sales DESC
LIMIT 10;

-- Top 10 Global Best Sellers

SELECT name,
       platform,
       global_sales
FROM sales
ORDER BY global_sales DESC
LIMIT 10;

-- Regional Sales by Platform

SELECT platform,
       SUM(na_sales) AS NA,
       SUM(eu_sales) AS EU,
       SUM(jp_sales) AS JP
FROM sales
GROUP BY platform;

-- Platform Market Evolution

SELECT year,
       platform,
       SUM(global_sales) AS total_sales
FROM sales
GROUP BY year, platform
ORDER BY year;

-- Regional Genre Sales

SELECT genre,
       SUM(na_sales) AS NA,
       SUM(eu_sales) AS EU,
       SUM(jp_sales) AS JP
FROM sales
GROUP BY genre;

-- Yearly Sales by Region

SELECT year,
       SUM(na_sales) AS NA,
       SUM(eu_sales) AS EU,
       SUM(jp_sales) AS JP
FROM sales
GROUP BY year
ORDER BY year;

-- Average Sales per Publisher

SELECT publisher,
       ROUND(AVG(global_sales),2) AS avg_sales
FROM sales
GROUP BY publisher
ORDER BY avg_sales DESC
LIMIT 10;

-- Top 5 Games Per Platform

SELECT *
FROM (
    SELECT name,
           platform,
           global_sales,
           ROW_NUMBER() OVER (PARTITION BY platform ORDER BY global_sales DESC) AS rank_num
    FROM sales
) ranked
WHERE rank_num <= 5;

-- Merged Dataset Creation

CREATE TABLE merged_data AS
SELECT 
    s.name,
    s.platform,
    s.year,
    s.genre,
    s.publisher,
    s.global_sales,
    g.rating,
    g.plays,
    g.wishlist,
    g.backlogs
FROM sales s
LEFT JOIN games g
ON s.name = g.title;

-- Top Genres by Global Sales

SELECT genre,
       SUM(global_sales) AS total_sales
FROM merged_data
GROUP BY genre
ORDER BY total_sales DESC;

-- Rating vs Sales

SELECT rating,
       AVG(global_sales) AS avg_sales
FROM merged_data
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY rating DESC;

-- High Rated Games per Platform

SELECT platform,
       COUNT(*) AS high_rated_games
FROM merged_data
WHERE rating >= 4
GROUP BY platform
ORDER BY high_rated_games DESC;

-- Release vs Sales Trend

SELECT year,
       COUNT(name) AS total_games,
       SUM(global_sales) AS total_sales
FROM merged_data
GROUP BY year
ORDER BY year;

-- Wishlist Impact on Sales

SELECT 
    ROUND(AVG(wishlist),0) AS avg_wishlist,
    ROUND(AVG(global_sales),2) AS avg_sales
FROM merged_data;

-- Engagement vs Sales

SELECT genre,
       AVG(plays) AS avg_plays,
       AVG(global_sales) AS avg_sales
FROM merged_data
GROUP BY genre
ORDER BY avg_plays DESC;

-- Engagement vs Rating

SELECT 
    ROUND(AVG(backlogs),0) AS avg_backlogs,
    ROUND(AVG(wishlist),0) AS avg_wishlist,
    ROUND(AVG(rating),2) AS avg_rating
FROM merged_data;

-- Engagement per Genre

SELECT genre,
       AVG(plays) AS avg_plays,
       AVG(wishlist) AS avg_wishlist
FROM merged_data
GROUP BY genre;

-- Top Genre-Platform Combination

SELECT genre,
       platform,
       SUM(global_sales) AS total_sales
FROM merged_data
GROUP BY genre, platform
ORDER BY total_sales DESC
LIMIT 10;

-- Regional Sales Heatmap Data

SELECT genre,
       SUM(global_sales) AS total_sales
FROM merged_data
GROUP BY genre;
