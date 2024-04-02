CREATE DATABASE codebasics;
USE codebasics;

SELECT * FROM dim_date;
SELECT * FROM dim_hotels;
SELECT * FROM dim_rooms;
SELECT * FROM fact_aggregated_bookings;
SELECT * FROM fact_bookings;



# What is the total revenue of the data
SELECT SUM(revenue_generated) AS Total_Revenue_Generated, SUM(revenue_realized) AS Total_Revenue_Realized,
ROUND(SUM(revenue_generated) / SUM(revenue_realized), 2) AS Percentage_Difference
FROM fact_bookings;


# What is the revenue of room categories for individual rooms
SELECT room_id, room_class, revenue_generated, revenue_realized, (revenue_generated - revenue_realized) AS difference
FROM fact_bookings f
JOIN dim_rooms r
ON f.room_category = r.room_id;


# What is the total Revenue by room categories
SELECT room_class, SUM(revenue_generated) AS revenue_generated, SUM(revenue_realized) AS revenue_generalized, 
SUM(revenue_generated - revenue_realized) AS difference
FROM fact_bookings b
JOIN dim_rooms r
ON b.room_category = r.room_id
GROUP BY room_class
ORDER BY room_class;


# What is the total revenue by Booking platforms
SELECT booking_platform, SUM(revenue_generated) AS revenue_generated, SUM(revenue_realized) AS revenue_generalized, 
SUM(revenue_generated - revenue_realized) AS difference
FROM fact_bookings
GROUP BY booking_platform
ORDER BY revenue_generated DESC;


# Total revenue by City and Category of hotels 
SELECT city, category,
    SUM(CASE WHEN category = 'Business' THEN revenue_generated ELSE 0 END) AS Revenue_Generated,
    SUM(CASE WHEN category = 'Business' THEN revenue_realized ELSE 0 END) AS Revenue_Realized,
    SUM(CASE WHEN category = 'Business' THEN revenue_generated - revenue_realized ELSE 0 END) AS Revenue_Difference,
    SUM(CASE WHEN category = 'Luxury' THEN revenue_generated ELSE 0 END) AS Revenue_Generated,
    SUM(CASE WHEN category = 'Luxury' THEN revenue_realized ELSE 0 END) AS Revenue_Realized,
    SUM(CASE WHEN category = 'Luxury' THEN revenue_generated - revenue_realized ELSE 0 END) AS Revenue_Difference
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY city, category
ORDER BY city DESC;


# Ratings > 3 and is not a blank value
SELECT *
FROM fact_bookings
WHERE ratings_given > 3.0 AND ratings_given IS NOT NULL;


# What is the count categories of Booking status
SELECT booking_status, COUNT(booking_status) AS Count
FROM fact_bookings
GROUP BY booking_status;


# What is the revenue by type of Week day
SELECT day_type, 
	SUM(CASE WHEN day_type = 'weekeday' THEN revenue_generated ELSE 0 END) AS Revenue_Generated,
	SUM(CASE WHEN day_type = 'weekeday' THEN revenue_realized ELSE 0 END) AS Revenue_Realized,
    SUM(CASE WHEN day_type = 'weekeday' THEN revenue_generated - revenue_realized ELSE 0 END) AS Revenue_Difference,
    SUM(CASE WHEN day_type = 'weekend' THEN revenue_generated ELSE 0 END) AS Revenue_Generated,
    SUM(CASE WHEN day_type = 'weekend' THEN revenue_realized ELSE 0 END) AS Revenue_Realized,
    SUM(CASE WHEN day_type= 'weekend' THEN revenue_generated - revenue_realized ELSE 0 END) AS Revenue_Difference
FROM fact_bookings b
JOIN dim_date d
ON b.check_in_date = d.date
GROUP BY day_type
ORDER BY day_type DESC;


# What is the revenue by Month
SELECT MONTHNAME(check_in_date) AS Month, SUM(revenue_generated) AS revenue_generated, 
SUM(revenue_realized) AS revenue_realized, SUM(revenue_generated - revenue_realized) AS difference
FROM fact_bookings f
GROUP BY Month;


# Which are the top performing properties
SELECT DISTINCT(property_name), city, revenue_generated
FROM fact_bookings f
JOIN dim_hotels h
ON f.property_id = h.property_id
ORDER BY revenue_generated DESC;


# What is the popular room type booked by the guest
SELECT d.room_class AS Room_Category, COUNT(f.room_category) AS Total_Bookings 
FROM fact_bookings f
JOIN dim_rooms d
ON f.room_category = d.room_id
GROUP BY d.room_class
ORDER BY Total_Bookings DESC ;


# Which is the most used platform for booking 
SELECT booking_platform AS Platform, COUNT(booking_platform) AS Total_Bookings
FROM fact_bookings
GROUP BY Platform
ORDER BY Total_Bookings DESC
LIMIT 5;


# What is the average stay duration 
SELECT ROUND(AVG(DATEDIFF(checkout_date, check_in_date)), 0) AS Average_Stay_Duration
FROM fact_bookings;


# What is the Occupancy rate % of the hotels 
SELECT h.property_name, h.category, h.city, ROUND((a.successful_bookings) / (a.capacity) * (100), 0) AS Occupancy_Rate
FROM fact_aggregated_bookings a
JOIN dim_hotels h
ON a.property_id = h.property_id
ORDER BY Occupancy_Rate DESC;



# How many bookings were made by each month based on booking date field
SELECT MONTHNAME(booking_date) AS Month, COUNT(booking_date) AS Bookings
FROM fact_bookings
GROUP BY Month;


# Which hotel category (e.g., Business, Luxury) has the highest revenue
SELECT h.category, SUM(f.revenue_generated) AS Total_Revenue
FROM fact_bookings f
JOIN dim_hotels h
ON f.property_id = h.property_id
GROUP BY category
ORDER BY Total_Revenue DESC
LIMIT 1;


# How many successful bookings were made by each customer which were not cancelled
SELECT booking_id AS Customer_id, COUNT(booking_date) AS Bookings
FROM fact_bookings
WHERE booking_status != "Cancelled"
GROUP BY Customer_id;


# Which customer has generated the highest revenue
SELECT booking_id AS Customer_id, SUM(revenue_generated) AS Revenue
FROM fact_bookings
GROUP BY Customer_id
ORDER BY Revenue DESC
LIMIT 1;


# What is the cancellation rate, no show rate for bookings
SELECT ROUND(SUM(CASE WHEN booking_status = "No Show" THEN 1 ELSE 0 END) / COUNT(*) * (100), 0) AS No_Show_Rate,
       ROUND(SUM(CASE WHEN booking_status = "Cancelled" THEN 1 ELSE 0 END) / COUNT(*) * (100), 0) AS Cancellation_Rate       
FROM fact_bookings;


# What is the total revenue generated by each hotel property 
SELECT h.property_id, h.property_name, SUM(b.revenue_generated) AS Total_Revenue
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.property_id, h.property_name;


# Which hotel property had the highest occupancy rate 
SELECT h.property_id, h.property_name, (a.successful_bookings) / (a.capacity) AS Occupancy_Rate
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
JOIN fact_aggregated_bookings a 
ON a.property_id = h.property_id
GROUP BY h.property_id, h.property_name, Occupancy_Rate
ORDER BY Occupancy_Rate DESC
LIMIT 1;


# What is the average rating given by guests for each hotel category
SELECT h.category, ROUND(AVG(b.ratings_given), 1) AS Average_Rating
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.category;


# How many bookings were made on each day of the week for a specific hotel 
SELECT h.property_id, h.property_name, d.day_type, COUNT(*) AS Total_Bookings
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
JOIN dim_date d 
ON b.booking_date = d.date
WHERE h.property_id = '16560'
GROUP BY h.property_id, h.property_name, d.day_type;


# What is the total revenue generated by room category for each hotel property 
SELECT h.property_id, h.property_name, r.room_class, SUM(b.revenue_generated) AS Total_Revenue
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
JOIN dim_rooms r 
ON b.room_category = r.room_id
GROUP BY h.property_id, h.property_name, r.room_class;


# Which city has the highest total revenue generated from hotel properties 
SELECT h.city, SUM(b.revenue_generated) AS Total_Revenue
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.city
ORDER BY Total_Revenue DESC
LIMIT 1;


# What is the average revenue per guest for each hotel property 
SELECT h.property_id, h.property_name,
ROUND(SUM(b.revenue_generated) / SUM(b.no_guests), 0) AS Average_Revenue_Per_Guest
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.property_id, h.property_name;


# Which hotel property has the highest revenue per available room (RevPAR) 
SELECT h.property_id, h.property_name,
SUM(b.revenue_generated) / SUM(a.capacity) AS RevPAR
FROM fact_bookings b
JOIN fact_aggregated_bookings a
ON b.property_id = a.property_id 
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.property_id, h.property_name
ORDER BY RevPAR DESC
LIMIT 1;


# What is the total revenue generated by each hotel property for bookings made through online platforms
SELECT h.property_id, h.property_name, SUM(b.revenue_generated) AS Total_Revenue_Online
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
WHERE b.booking_platform != "others"
GROUP BY h.property_id, h.property_name;


# How many bookings were made by customers from each city for a specific hotel property 
SELECT h.property_id, h.property_name, h.city, COUNT(*) AS Total_Bookings
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
WHERE h.property_id = '18560'
GROUP BY h.property_id, h.property_name, h.city;


# What is the percentage of bookings that were canceled for each hotel property
SELECT h.property_id, h.property_name,
ROUND((COUNT(CASE WHEN b.booking_status = 'Cancelled' THEN 1 END) / COUNT(*)) * (100), 0) AS Cancellation_Percentage
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.property_id, h.property_name;

select * from fact_bookings;
# What is the average room rate for each hotel property 
SELECT h.property_id, h.property_name, ROUND(AVG(b.revenue_generated), 0) AS Average_Room_Rate
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.property_id, h.property_name;


# Which hotel property had the highest revenue realized compared to revenue generated 
SELECT h.property_id, h.property_name, SUM(b.revenue_generated) AS Revenue_Generated,
SUM(b.revenue_realized) AS Revenue_Realized
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.property_id, h.property_name
ORDER BY (SUM(b.revenue_realized) - SUM(b.revenue_generated)) DESC
LIMIT 1;


# How many successful bookings were made for each room category in a specific hotel property 
SELECT h.property_id, h.property_name, r.room_class,
SUM(a.successful_bookings) AS Successful_Bookings
FROM fact_aggregated_bookings a
JOIN dim_hotels h 
ON a.property_id = h.property_id
JOIN dim_rooms r 
ON a.room_category = r.room_id
WHERE h.property_id = '17560'
GROUP BY h.property_id, h.property_name, r.room_class;


# What is the trend of revenue generated by a specific hotel property over the past months 
SELECT h.property_id, h.property_name, MONTHNAME(b.check_in_date) AS Month,
SUM(b.revenue_generated) AS Total_Revenue
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
WHERE h.property_name = 'Atliq %'
GROUP BY h.property_id, h.property_name, Month
ORDER BY Month;


# Which hotel property had the highest increase in revenue compared to the previous month
WITH revenue_comparison AS (
    SELECT h.property_id, h.property_name,
	MONTHNAME(b.booking_date) AS Month,
	SUM(b.revenue_generated) AS Total_Revenue
    FROM fact_bookings b
    JOIN dim_hotels h 
    ON b.property_id = h.property_id
    GROUP BY h.property_id, h.property_name, Month
)
SELECT property_id, property_name,
Total_Revenue - LAG(Total_Revenue) OVER (PARTITION BY property_id ORDER BY Month) AS Revenue_Increase
FROM revenue_comparison
ORDER BY Revenue_Increase DESC
LIMIT 1;


# What is the percentage of revenue generated by each hotel category out of the total revenue
SELECT h.category,
ROUND(SUM(b.revenue_generated) / (SELECT SUM(revenue_generated) FROM fact_bookings) * 100, 2) AS Revenue_Percentage
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.category;


# How many unique customers have booked rooms in each hotel property
SELECT h.property_id, h.property_name, COUNT(DISTINCT b.booking_id) AS Unique_Customers
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.property_id, h.property_name;


# Which hotel category has the highest average revenue per booking
SELECT h.category, ROUND(AVG(b.revenue_generated), 0) AS Average_Revenue_Per_Booking
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.category
ORDER BY Average_Revenue_Per_Booking DESC
LIMIT 1;


# What is the total revenue generated from bookings made on each day of the week for a specific hotel property 
SELECT h.property_id, h.property_name, d.day_type, SUM(b.revenue_generated) AS Total_Revenue
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
JOIN dim_date d 
ON b.booking_date = d.date
WHERE h.property_id = 17560
GROUP BY h.property_id, h.property_name, d.day_type;


# Which hotel property has the highest ratio of revenue realized to revenue generated
SELECT h.property_id, h.property_name, h.city,
ROUND(SUM(b.revenue_realized) / SUM(b.revenue_generated), 2) AS Revenue_Realized_to_Generated_Ratio
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.property_id, h.property_name, h.city
ORDER BY Revenue_Realized_to_Generated_Ratio DESC
LIMIT 1;


# What is the average length of stay for each hotel property
SELECT h.property_id, h.property_name, h.city,
ROUND(AVG(DATEDIFF(checkout_date, check_in_date)), 0) AS Average_Length_of_Stay
FROM fact_bookings b
JOIN dim_hotels h 
ON b.property_id = h.property_id
GROUP BY h.property_id, h.property_name, h.city;


# What is the trend of revenue generated by a specific hotel property, compared to the overall trend of revenue in the city where the hotel is located
WITH property_revenue AS (
    SELECT h.property_id, h.property_name, MONTHNAME(b.check_in_date) AS Month,
	SUM(b.revenue_generated) AS Total_Revenue
    FROM fact_bookings b
    JOIN dim_hotels h 
    ON b.property_id = h.property_id
	WHERE h.property_id = '17560'
    GROUP BY h.property_id, h.property_name, MONTHNAME(b.check_in_date)
),
city_revenue AS (
    SELECT h.city, MONTHNAME(b.check_in_date) AS Month,
	SUM(b.revenue_generated) AS Total_Revenue
    FROM fact_bookings b
    JOIN dim_hotels h 
    ON b.property_id = h.property_id
    WHERE h.city = (SELECT city 
				   FROM dim_hotels 
                   WHERE property_id = '17560')
    GROUP BY h.city, MONTHNAME(b.check_in_date)
)
SELECT pr.property_id, pr.property_name, pr.Month,
pr.Total_Revenue AS Property_Revenue,
cr.Total_Revenue AS City_Revenue,
ROUND((pr.Total_Revenue) / (cr.Total_Revenue) * (100), 1) AS Percent_Contribution
FROM property_revenue pr
JOIN city_revenue cr 
ON pr.Month = cr.Month;
