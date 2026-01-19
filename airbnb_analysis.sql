Airbnb Market Analysis Portfolio Project
Author: Ifra Khaleeq
Tools: PostgreSQL (pgAdmin)

Description:
This project performs data cleaning, transformation, and exploratory data analysis (EDA) 
on an open Airbnb dataset to analyze pricing behavior, host segmentation, and neighborhood demand.

1. RAW DATA TABLE (IMPORTED FROM CSV AS TEXT)

CREATE TABLE airbnb_raw (
    id TEXT,
    name TEXT,
    host_id TEXT,
    host_identity_verified TEXT,
    host_name TEXT,
    neighbourhood_group TEXT,
    neighbourhood TEXT,
    lat TEXT,
    long TEXT,
    country TEXT,
    country_code TEXT,
    instant_bookable TEXT,
    cancellation_policy TEXT,
    room_type TEXT,
    construction_year TEXT,
    price TEXT,
    service_fee TEXT,
    minimum_nights TEXT,
    number_of_reviews TEXT,
    last_review TEXT,
    reviews_per_month TEXT,
    review_rate_number TEXT,
    calculated_host_listings_count TEXT,
    availability_365 TEXT,
    house_rules TEXT,
    license TEXT
);

2. DATA TYPE CLEANING & TRANSFORMATION
=>Remove currency symbols and convert price to numeric

UPDATE airbnb_raw
SET price = REPLACE(REPLACE(price, '$', ''), ',', '');

ALTER TABLE airbnb_raw
ALTER COLUMN price TYPE NUMERIC USING price::NUMERIC;

ALTER TABLE airbnb_raw
ALTER COLUMN minimum_nights TYPE INT USING minimum_nights::INT;

ALTER TABLE airbnb_raw
ALTER COLUMN number_of_reviews TYPE INT USING number_of_reviews::INT;

ALTER TABLE airbnb_raw
ALTER COLUMN calculated_host_listings_count TYPE INT USING calculated_host_listings_count::INT;

ALTER TABLE airbnb_raw
ALTER COLUMN availability_365 TYPE INT USING availability_365::INT;

ALTER TABLE airbnb_raw
ALTER COLUMN reviews_per_month TYPE NUMERIC USING reviews_per_month::NUMERIC;

ALTER TABLE airbnb_raw
ALTER COLUMN last_review TYPE DATE USING last_review::DATE;

ALTER TABLE airbnb_raw
ALTER COLUMN host_id TYPE BIGINT USING host_id::BIGINT;

ALTER TABLE airbnb_raw
ALTER COLUMN id TYPE BIGINT USING id::BIGINT;

ALTER TABLE airbnb_raw
ALTER COLUMN lat TYPE NUMERIC USING lat::NUMERIC;

ALTER TABLE airbnb_raw
ALTER COLUMN long TYPE NUMERIC USING long::NUMERIC;

ALTER TABLE airbnb_raw
ALTER COLUMN construction_year TYPE INT USING construction_year::INT;

ALTER TABLE airbnb_raw
ALTER COLUMN review_rate_number TYPE NUMERIC USING review_rate_number::NUMERIC;

UPDATE airbnb_raw
SET service_fee = REPLACE(REPLACE(service_fee, '$', ''), ',', '');

ALTER TABLE airbnb_raw
ALTER COLUMN service_fee TYPE NUMERIC USING service_fee::NUMERIC;


3. DATA QUALITY CHECKS
=>Dataset overview;

SELECT 
    COUNT(*) AS total_listings,
    COUNT(DISTINCT host_id) AS total_hosts,
    COUNT(DISTINCT neighbourhood) AS total_neighbourhoods
FROM airbnb_raw;

=>Missing values check;

SELECT
    COUNT(*) FILTER (WHERE price IS NULL) AS missing_price,
    COUNT(*) FILTER (WHERE neighbourhood IS NULL) AS missing_neighbourhood,
    COUNT(*) FILTER (WHERE room_type IS NULL) AS missing_room_type
FROM airbnb_raw;

4. EXPLORATORY DATA ANALYSIS (EDA)
=>Price distribution

SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price
FROM airbnb_raw
WHERE price IS NOT NULL;

=>Listings by room type

SELECT
    room_type,
    COUNT(*) AS total_listings,
    ROUND(AVG(price), 2) AS avg_price
FROM airbnb_raw
WHERE price IS NOT NULL
GROUP BY room_type
ORDER BY avg_price DESC;

=>Top neighborhoods by listing volume

SELECT
    neighbourhood,
    COUNT(*) AS total_listings,
    ROUND(AVG(price), 2) AS avg_price
FROM airbnb_raw
WHERE price IS NOT NULL
GROUP BY neighbourhood
ORDER BY total_listings DESC
LIMIT 10;

=>Availability vs price

SELECT
    availability_365,
    ROUND(AVG(price), 2) AS avg_price
FROM airbnb_raw
WHERE price IS NOT NULL
GROUP BY availability_365
ORDER BY availability_365;

=>Host segmentation

SELECT
    CASE 
        WHEN calculated_host_listings_count = 1 THEN 'Single Listing Host'
        ELSE 'Multi Listing Host'
    END AS host_type,
    COUNT(*) AS listings,
    ROUND(AVG(price), 2) AS avg_price
FROM airbnb_raw
GROUP BY host_type;

=>Review impact on pricing

SELECT
    review_rate_number,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS listings
FROM airbnb_raw
WHERE review_rate_number IS NOT NULL
GROUP BY review_rate_number
ORDER BY review_rate_number;

