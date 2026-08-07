CREATE DATABASE OLA;

USE OLA;
SELECT * FROM booking;

#-- 1. Retrieve all successful bookings:
CREATE VIEW SUCCESSFUL_BOOKING AS
SELECT * FROM booking WHERE Booking_Status = 'Success';

SELECT * FROM Successful_booking;

#-- 2. Find the average ride distance for each vehicle type:
CREATE View avg_distance AS 
SELECT Vehicle_Type, AVG(Ride_Distance) as avg_distance FROM booking 
GROUP BY Vehicle_Type;

SELECT * FROM AVG_DISTANCE;

#-- 3. Get the total number of cancelled rides by customers:
CREATE VIEW cancelled_rides_by_customers AS 
SELECT COUNT(*) FROM booking WHERE Booking_Status = 'canceled by Customer';

SELECT * FROM  canceled_rides_by_customers;
 
#-- 4. List the top 5 customers who booked the highest number of rides:
CREATE VIEW  TOP5_CUSTOMERS AS
SELECT Customer_ID, COUNT(Booking_ID) as total_rides FROM booking 
GROUP BY Customer_ID ORDER BY total_rides DESC LIMIT 5;

SELECT * FROM TOP5_CUSTOMERS;

#-- 5. Get the number of rides canceled by drivers due to personal and car-related issues:
CREATE VIEW  canceled_rides_by_driver AS
SELECT COUNT(*) FROM booking 
WHERE canceled_Rides_by_Driver = 'Personal & Car-related issue';

SELECT * FROM canceled_rides_by_driver ;

#6 Find the maximun and minimum driver ratings for Prime Sedan booking:
CREATE VIEW max_min_driver_rating as 
SELECT MAX(Driver_Ratings) as MAX_RATINGS,
MIN(DRIVER_RATINGS) as MIN_RATING
FROM booking WHERE Vehicle_Type ='Prime Sedan';

 SELECT * FROM max_min_driver_rating;
 
 #7 Retrive all rides where payment was made using UPI:
 CREATE VIEW PAYMENT_UPI AS 
 SELECT * FROM booking
 WHERE Payment_Method = 'UPI';
 
 SELECT * FROM PAYMENT_UPI;
 
 #8 Find the average customer rating per vehicle type:
 CREATE VIEW avg_cust_rating AS 
 SELECT Vehicle_type, AVG(Customer_rating) as avg_customer_rating
 FROM Booking
 GROUP BY Vehicle_Type;
 
 SELECT * FROM avg_cust_rating;
 
 #9 Calculate the total booking value of rides completed successfully:
 CREATE VIEW successful_booking AS
 SELECT SUM(Booking_Value) as total_successful_value
 FROM booking
 WHERE Booking_Status = 'Success';
 
 SELECT * FROM successful_booking;
 
 #10 List all incomplete rides along with the reason:
 CREATE VIEW incomplete_rides_reason AS 
 SELECT Booking_ID, Incomplete_Rides_Reason
 FROM booking
 WHERE Incomplete_Rides = 'Yes';
 
 SELECT * FROM  incomplete_rides_reason;