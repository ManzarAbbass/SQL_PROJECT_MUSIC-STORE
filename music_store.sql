---Q1: WHO IS THE MOST SENIOR EMPLOYEE BASED ON JOB TITLE ?
select * from employee
order by levels desc
limit 1

---Q2: WHICH COUNTRY HAVE THE MOST INVOICES?
select count(*) as c ,billing_country 
from invoice
group by billing_country
order by c desc

---Q3: WHAT ARE TOP 3 VALUES OF TOTAL INVOICE?
select total from invoice
order by total desc
limit 3

---Q4: WHICH CITY HAS THE BEST CUSTOMERS?WE WOULD LIKE TO THROW A PROMOTIONAL MUSIC
--FESTIVAL IN THE CITY WE MADE THE MOST MONEY.WRITE A RETURN QUERY THAT RETURNS ONE CITY 
--THAT HAS THE HIGHEST SUM OF INVOICE TOTALS .RETURN BOTH THE CITY NAME,SUM OF ALL 
--INVOICE TOTALS?

select billing_city,sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc

---Q5: WHO IS THE BEST CUSTOMER?THE CUSTOMER WHO HAS SPENT THE MOST MONEY WILL BE 
--DECLARED THE BEST CUSTOMER. WRITE A QUERY THAT RETURNS THE PERSON WHO HAS SPENT 
--THE MOST MONEY
select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total)
as Most_moneyspent  
from customer
join invoice
on customer.customer_id=invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name
order by Most_moneyspent desc
limit 1

---Q6:WRITE A QUERY TO RETURN THE EMAIL,FIRST NAME,LAST NAME,GENRE OF ALL ROCK MUSIC 
--LISTNERS. RETURN YOUR LIST ORDERED ALPHABATICALLY BY EMAIL STARTING WITH A?

select distinct email,first_name,last_name 
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id 
IN(select track_id from track 
   join genre on track.genre_id=genre.genre_id
   where genre.name like 'Rock')
order by email   


---Q7:LETS INVITE THE ARTISTS WHO HAVE WRITTEN THE MOST ROCK MUSIC IN OUR DATASETS.WRITE
--A QUERY THAT RETURNS THE ARTIST NAME AND TOTAL TRACK COUNT OF THE TOP 10 ROCK BANDS?
 
select artist.artist_id,artist.name,count(artist.artist_id)as number_songs 
from track
join album on track.album_id=album.album_id
join artist on album.artist_id=artist.artist_id
join genre on track.genre_id=genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_songs desc
limit 10

---Q8: RETURN ALL THE TRACK NAMES THAT HAVE A SONG LENGTH LONGER THAN THE AVERAGE SONG 
--LENGTH.RETURN THE NAME AND MILLISECONDS FOR EACH TRACK.ORDER BY THE SONG LENGTH WITH
--THE LONGEST SONG LISTED FIRST.?

select name,milliseconds
from track
where milliseconds > (select avg(milliseconds) as track_sales 
					 from track)
order by milliseconds desc					 


---Q9:FIND HOW MUCH AMOUNT SPENT BY EACH CUSTOMER ON ARTIST? WRITE A QUERY TO RETURN 
--CUSTOMER NAME,ARTIST NAME AND TOTAL SPENT?
with best_artist as(
select artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_spending
from invoice_line
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by 1,2
order by 3 desc 
limit 1
)
select c.customer_id as customer_id,c.first_name as first_name,
c.last_name as last_name,ba.artist_name,sum(il.unit_price*il.quantity) as amount_spent 
from invoice  as i
join customer as c on c.customer_id=i.customer_id
join invoice_line as il on il.invoice_id=i.invoice_id
join track as t on t.track_id=il.track_id
join album as alb on alb.album_id=t.album_id
join best_artist as ba on ba.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc;

---Q10:WE WANT TO FIND OUT THE MOST POPULAR MUSIC GENRE FOR EACH COUNTRY.WE DETERMINE THE
--MOST POPULAR GENRE AS THE GENRE WITH THE HIGHEST AMOUNT OF PURCHASES.WRITE A QUERY THAT
--RETURNS EACH COUNTRY ALONG WITH THE TOP GENRE.FOR COUNTRIES WHERE THE MAX NO OF PURCHASES
--IS SHARED RETURN ALL GENRES?

with popular_genre as (
select count(invoice_line.quantity) as purchases,customer.country,genre.name,
genre.genre_id,
row_number () over (partition by customer.country order by count(invoice_line.quantity)desc)
as RowNo
from invoice_line
join invoice on invoice.invoice_id=invoice_line.invoice_id
join customer on customer.customer_id=invoice.customer_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
group by 2,3,4
order by 2 asc,1 desc 	
)
select * from popular_genre where RowNo <=1

--Q11: WRITE A QUERY THAT DETERMINES THE CUSTOMER THAT HAS SPENT THE MOST ON MUSIC FOR EACH
--COUNTRY.WRITE A QUERY THAT RETURNS THE COUNTRY ALONG WITH THE TOP CUSTOMER AND HOW MUCH
--THEY SPENT.FOR COUNTRIES WHERE THE TOP AMOUNT SPENT IS SHARED,PROVIDE ALL CUSTOMER WHO 
--SPENT THIS AMOUNT?

with customer_country as (
select customer.customer_id,customer.first_name,customer.last_name,billing_country,
sum(total) as total_spending,
row_number() over (partition by billing_country order by sum(total) desc) as RowNo	
from invoice
join customer on customer.customer_id=invoice.customer_id
group by 1,2,3,4
order by 4 asc,5 desc	
)
select * from customer_country where RowNo <=1


