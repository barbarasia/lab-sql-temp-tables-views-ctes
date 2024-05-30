-- Creating a Customer Summary Report

-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, 
-- including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

create view v_customer_rental_info as
select sakila.customer.customer_id, sakila.customer.last_name, sakila.customer.email, count(sakila.rental.rental_id) as rental_count
from sakila.customer
left join sakila.rental
	using(customer_id)
group by sakila.customer.customer_id, sakila.customer.last_name, sakila.customer.email;

select * from v_customer_rental_info;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

create temporary table tt_total_paid as
select  customer_id, last_name, email, sum(amount) as total_amount
from v_customer_rental_info
left join sakila.payment
	using(customer_id)
group by customer_id, last_name, email;

select* from tt_total_paid;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.

with rental_summary as (select * from v_customer_rental_info)
, total_paied as (select * from tt_total_paid)
select rental_summary.last_name, rental_summary.email, rental_count, total_amount
from rental_summary 
inner join total_paied
using(customer_id);

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: 
-- customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

with rental_summary as (select * from v_customer_rental_info)
, total_paied as (select * from tt_total_paid)
select rental_summary.last_name, rental_summary.email, rental_count, total_amount, (total_amount/rental_count) as avg_price
from rental_summary 
inner join total_paied
using(customer_id);

