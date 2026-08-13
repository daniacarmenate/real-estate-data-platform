/*Exercise 1: What is the average property price by state?*/
select l.state, 
	round(avg(p.price):: numeric, 2) as avg_price
from properties p left join locations l
on p.location_id = l.location_id 
group by l.state 
order by avg_price desc;

/*Exercise 2: How many properties are available for each property status?*/
select * from status;
select s.status, count(*) as total_properties
from properties p left join status s
on p.status_id = s.status_id 
group by s.status
order by total_properties desc;

/*Exercise 3: What are the 10 cities with the highest average property price?*/
select l.city,
	l.state, 
	round(avg(p.price):: numeric, 2) as avg_price
from properties p left join locations l
on p.location_id = l.location_id 
group by l.city, l.state 
order by avg_price desc
limit 10;

/*Exercise 4: What are the 10 cities with the highest average property price among cities that have at least 100 properties?*/
select l.city,
	l.state, 
	count(*) as total_properties,
	round(avg(p.price):: numeric, 2) as avg_price
from properties p left join locations l
on p.location_id = l.location_id 
group by l.city, l.state 
having count(*)>=100
order by avg_price desc
limit 10;

/*Exercise 5: Which 10 states have the highest number of properties for sale?*/
select * from status;
select count(*) as total_properties, l.state
from properties p left join status s 
on p.status_id = s.status_id 
left join locations l
on p.location_id=l.location_id
where s.status = 'for_sale'
group by l.state
order by total_properties desc
limit 10;

/*Exercise 6: Which states have an average property price higher than the overall average property price?*/
with total_avg as (
select round(avg(price)::numeric, 2) as total_avg
from properties
)
select l.state, round(avg(p.price)::numeric,2) as state_avg, ta.total_avg 
from properties p join locations l
on p.location_id=l.location_id 
cross join total_avg ta
group by l.state, ta.total_avg 
having avg(p.price)>ta.total_avg 
order by state_avg desc;

/*Exercise 7: What are the 3 most expensive properties in each state?*/
with rank_price_state as (
select l.state, p.property_id, p.price,
row_number() over (partition by l.state order by p.price desc, p.property_id) as price_rank
from properties p join locations l on p.location_id=l.location_id)
select * from rank_price_state where price_rank<=3;

/*Exercise 8: For each property, show its price and the average property price in the same state*/
select l.state, p.property_id, p.price,
	round((AVG(p.price) over (partition by l.state))::numeric, 2) as state_avg_price
from properties p join locations l
on p.location_id = l.location_id;

/*Exercise 9: For each property, calculate the difference between its price and the average property price in its state.*/
WITH state_prices AS (
    SELECT
        l.state,
        p.property_id,
        p.price,
        AVG(p.price) OVER (PARTITION BY l.state) AS state_avg
    FROM properties p
    JOIN locations l
        ON p.location_id = l.location_id
)
SELECT
    state,
    property_id,
    price,
    ROUND(state_avg::numeric,2) AS state_avg_price,
    ROUND((price - state_avg)::numeric,2) AS price_difference
FROM state_prices;

