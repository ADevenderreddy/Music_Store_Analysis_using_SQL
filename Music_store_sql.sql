-- Q1: Who is the senior most employee based on job title?

select * from employee
order by levels desc 
limit 1;

-- Q2: which countries have the most invoices?

select count(*) as c,billing_country 
from invoice
group by billing_country
order by c desc

-- Q3 what are top 3 values of total invoices

select total from invoice
order by total desc
limit 3;

-- Q4 which city has the best customers? we would like to throw a promotional music festival in the city we ade the most money. write a query 
-- that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

select sum(total) as invoice_total, billing_city 
from invoice
group by billing_city
order by invoice_total desc
limit 1


-- Q5: who is the best customer? the customer who has spent the most money will be decleared the best customer. write a query that returns the person who has
-- spent the most money

select customer.customer_id,customer.first_name,customer.last_name ,sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1


-- set2

-- Q1 wwrite query to return the email, first name, last name, and genre of all rock music listeners. return your list ordered alphabetically by email 
-- starting with A


select distinct email,first_name,last_name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email;


-- Q2: let's invite the aritsts who have written the most rock music in out dataset. write a query that returns the artist name and total track count 
-- of the total track count of the top 10 rock band

select artist.name, artist.artist_id, count(artist.artist_id) as no_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by no_of_songs desc
limit 10;



-- Q3: Return all the track name that have a song length longer than average song length.
-- Return the name and milliseconds for eack track. 
-- order by the song length with the longest songs listed first

select name,milliseconds 
from track
where milliseconds > (
select avg(milliseconds) as Avg_track_length from track)
order by milliseconds desc;


-- Advance

-- Q1: Find how much amount spent by eack customer on artist? Write a query to return customer name, artist name and total spent

With best_selling_artist as(
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, sum(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)

select c.customer_id, c.first_name, c.last_name ,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;


-- Q2: we want to find out the most popular music genre for eacj countru.
-- We determine the most popular genre as the genre with the highest amount og purchases. 
-- Write a query that returns each country along with the top genre. 
-- For countries where the maximum number of purchares is shared return all Genres

WITH popular_genre as
(
	select count(invoice_line.quantity) as purchases, customer.country,genre.name ,genre.genre_id,
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
	
)

select * from popular_genre where RowNo <=1



-- Q3: Write a query that determines the customer that has spent the most on music for each country.
-- write a query that returns the country along with the top customer and how much they spent. 
-- for countries where the top amount spent is shared, provide all customers who spent this amount.


with RECURSIVE
	customter_with_country as(
		select customer.customer_id, first_name,last_name,billing_country,sum(total) as total_spending
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 2,3 desc
	),

	country_max_spending as(
		select billing_country,max(total_spending) as max_spending
		from customter_with_country
		group by billing_country
	)

select cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,cc.customer_id
from customter_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1












