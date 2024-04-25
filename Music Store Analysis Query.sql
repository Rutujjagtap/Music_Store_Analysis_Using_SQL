/* --------------------------------------------------------------------
The following Query is for Analysis of Music Store Database.
The Database is distributed over different tables. 
Concepts such as JOINS, COUNT, SUM, CONCAT, etc are used.

By - Rutuj Jagtap 
----------------------------------------------------------------------- */

--Selecting the Database
USE Music_Store_DB;


/*QUESTION SET 1*/
--1) Senior Most Employee based on Job Title :
SELECT TOP 1 CONCAT(first_name,' ',last_name) as Name, title
FROM employee
ORDER BY levels DESC;


--2) Countries with the most number of invoices :
SELECT TOP 5 billing_country, COUNT(invoice_id) as count_invoices
FROM invoice
GROUP BY billing_country
ORDER BY count_invoices DESC;


--3) Top 3 values of total invoice
SELECT TOP 3 total
FROM invoice


--4) City with the highest invoices
SELECT TOP 1 billing_city, SUM(total) as Sum_total
FROM invoice
GROUP BY billing_city
ORDER BY Sum_total DESC 

--5) Best Customer, who has spent the most money
SELECT TOP 1 i.customer_id, CONCAT(c.first_name,' ',c.last_name) as Customer_Name, SUM(i.total) as invoice_total
FROM invoice as i
INNER JOIN customer as c
ON i.customer_id = c.customer_id
GROUP BY i.customer_id, CONCAT(c.first_name,' ',c.last_name)
ORDER BY invoice_total DESC



/*QUESTION SET 2*/
--1)Email, First Name, Last Name, and Genre of all Rock Music Listners in alphabetical order by email 
SELECT DISTINCT(c.email),c.first_name, c.last_name
FROM customer as c
INNER JOIN invoice as i
ON c.customer_id = i.customer_id
INNER JOIN invoice_line as il
ON i.invoice_id = il.invoice_id
WHERE track_id IN (
SELECT track_id
FROM track as t
INNER JOIN genre as g
ON g.genre_id = t.genre_id
WHERE g.name = 'Rock')
ORDER BY email ASC;


--2)Artist who have written the most Rock Music. Artist Name and total Track Count of Top 10 Rock Bands
SELECT TOP 10 at.name as artist_name, COUNT(*) as track_count
FROM artist as at
INNER JOIN album as al
ON at.artist_id = al.artist_id 
INNER JOIN track as tr
ON tr.album_id = al.album_id
INNER JOIN genre as g
ON tr.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY at.name
ORDER BY track_count DESC;


--3)Tracks that have song length lomger than the average song length. Name and milliseconds of track in Desc order of length
SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECt AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;


/*QUESTION SET 3*/
--1)Amount spent by each customer on artist
SELECT CONCAT(c.first_name,' ',c.last_name) as Customer_name, ar.name as artist_name, SUM(total) as amt_spent
FROM customer as c
INNER JOIN invoice as iv
ON c.customer_id = iv.customer_id
INNER JOIN invoice_line as ivl
ON iv.invoice_id = ivl.invoice_id
INNER JOIN track as tr
ON ivl.track_id = tr.track_id
INNER JOIN album as al
ON tr.album_id = al.album_id
INNER JOIN artist as ar
ON al.artist_id = ar.artist_id
GROUP BY ar.name, CONCAT(c.first_name,' ',c.last_name) 
ORDER BY Customer_name ASC


--2)Most popular Music Genre for each country based on amount of purchases.
WITH CTE AS(
SELECT g.name as genre_name, inv.billing_country as country, ROUND(SUM(inv.total),2) as amt_purchase, DENSE_RANK() OVER(PARTITION BY inv.billing_country ORDER BY SUM(inv.total) DESC) AS rnk
FROM genre as g
INNER JOIN track as tr
ON g.genre_id = tr.genre_id
INNER JOIN album as al
ON tr.album_id = al.album_id
INNER JOIN artist as ar
ON al.artist_id = ar.artist_id
INNER JOIN invoice_line as inl
ON inl.track_id = tr.track_id
INNER JOIN invoice as inv
ON inl.invoice_id = inv.invoice_id
GROUP BY g.name, inv.billing_country)

SELECT genre_name, country, amt_purchase
FROM CTE
WHERE rnk =1 



--3)Customer that has spent most on music for each country
SELECT customer_name, country, total_amount
FROM(SELECT CONCAT(c.first_name,' ',c.last_name) as customer_name, i.billing_country as country, SUM(i.total) as total_amount, DENSE_RANK() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total)) as rnk
FROM customer as c
INNER JOIN invoice as i
ON c.customer_id = i.customer_id
GROUP BY CONCAT(c.first_name,' ',c.last_name), i.billing_country) as new_table
WHERE rnk = 1