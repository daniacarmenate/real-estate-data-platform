/*Exercise 10: For each property, show the price of the previous property within the same state when ordered by price.*/
select l.state, p.property_id, p.price,
	lag(p.price) over (partition by l.state order by p.price) as previous_price
from properties p join locations l
on p.location_id = l.location_id;

/*Exercise 11: For each property, show the price of the next property within the same state when ordered by price.*/
select l.state, p.property_id, p.price,
	lead(p.price) over (partition by l.state order by p.price) as next_price
from properties p join locations l
on p.location_id = l.location_id;

/*Exercise 12: For each property, calculate the difference between its price and the previous property's price within the same state.*/
with property_prices as(
select l.state, p.property_id, p.price,
	lag(p.price) over (partition by l.state order by p.price) as previous_price
from properties p join locations l
on p.location_id = l.location_id
)
select *, (price - previous_price) as price_difference
from property_prices;

/*Exercise 13: Show the cheapest property in each state*/
with ranking_price as (
select l.state, p.property_id, p.price,
row_number() over (partition by l.state order by p.price asc) as ranking
from properties p join locations l
on p.location_id = l.location_id
)
select state, property_id, price
from ranking_price 
where ranking = 1;

/*4 location records have a NULL state. Since the source dataset does not provide a valid value, the ETL preserves the missing data instead of imputing an incorrect state.*/
	
/*Exercise 14: Show the cheapest and the most expensive property in each state using FIRST_VALUE() and LAST_VALUE().*/
SELECT
    l.state,
    p.property_id,
    p.price,
    FIRST_VALUE(p.price) OVER (
        PARTITION BY l.state
        ORDER BY p.price ASC, p.property_id
    ) AS cheapest_price_in_state,
    FIRST_VALUE(p.price) OVER (
        PARTITION BY l.state
        ORDER BY p.price DESC, p.property_id
    ) AS most_expensive_price_in_state
FROM properties p
JOIN locations l
    ON p.location_id = l.location_id;

/*Exercise 15: Calculate the cumulative property price within each state ordered by price.*/
select l.state, p.property_id, p.price,
	SUM(p.price) OVER (partition by l.state
	ORDER BY p.price ASC, p.property_id
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as cumulative_price
from properties p join locations l
on p.location_id = l.location_id;

/*Exercise 16: Calculate a moving average of the current property and the two previous properties within each state, ordered by price.*/
select l.state, p.property_id, p.price,
	ROUND(
    AVG(p.price) OVER (
        PARTITION BY l.state
        ORDER BY p.price, p.property_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)::numeric,2) AS moving_avg_price
from properties p join locations l
on p.location_id = l.location_id;

/*Exercise 17: Divide the properties within each state into four equally sized groups based on price using NTILE().*/
select l.state, p.property_id, p.price,
    NTILE(4) OVER (
        PARTITION BY l.state
        ORDER BY p.price, p.property_id) AS price_quartile
from properties p join locations l
on p.location_id = l.location_id;

/*Exercise 18: Calcule the percentile rank of each property within its state based on price*/
select l.state, p.property_id, p.price,
    percent_rank() OVER (
        PARTITION BY l.state
        ORDER BY p.price, p.property_id) AS percent_rank
from properties p join locations l
on p.location_id = l.location_id;

/*Exercise 19: Find all properties whose price is higher than the average price of their own state*/
with avg_state as (
select l.state, p.property_id, p.price,
AVG(p.price) over (partition by l.state) as state_avg
from properties p join locations l on p.location_id=l.location_id
)
select state, property_id, price, round(state_avg:: numeric, 2) as state_avg_price from avg_state where price > state_avg;

/*Exercise 20: Find the top 5 most expensive properties in each state whose price is above the average price of that state*/
with avg_state as (
select l.state, p.property_id, p.price,
AVG(p.price) over (partition by l.state) as state_avg
from properties p join locations l on p.location_id=l.location_id
),
rank_properties as (
select state, property_id, price, round(state_avg:: numeric, 2) as state_avg_price,
row_number() over (partition by state order by price desc, property_id asc) as price_rank
from avg_state where price > state_avg
)
select * from rank_properties where price_rank in (1,2,3,4,5);

/*Exercise 21: Find all states that have at least one property priced above 5000000*/
SELECT DISTINCT l.state
FROM locations l
WHERE EXISTS (
    SELECT 1
    FROM properties p
    WHERE p.location_id = l.location_id
      AND p.price > 5000000
);

/*Exercise 22: Find all brokers who have listed at least one property in Claifornia*/
SELECT
    b.broker_id
FROM brokers b
WHERE EXISTS (
    SELECT 1
    FROM properties p
    JOIN locations l
        ON p.location_id = l.location_id
    WHERE p.broker_id = b.broker_id
      AND l.state = 'California'
);

/*Exercise 23: Find all brockers who have never listed a property in Texas*/
select b.broker_id from brokers b 
where not exists (select 1 from properties p 
join locations l on p.location_id=l.location_id 
where l.state='Texas' and p.broker_id=b.broker_id);

/*Exercise 24: Find all states where every property is listed for sale*/
SELECT DISTINCT l.state
FROM locations l
WHERE NOT EXISTS (
    SELECT 1
    FROM properties p
    JOIN locations l2
        ON p.location_id = l2.location_id
    JOIN status s
        ON p.status_id = s.status_id
    WHERE l2.state = l.state
      AND s.status <> 'for_sale'
);

/*Exercise 25: Find all brokers who have listed properties in more than one state*/
SELECT
    p.broker_id,
    COUNT(DISTINCT l.state) AS total_states
FROM properties p
JOIN locations l
    ON p.location_id = l.location_id
GROUP BY p.broker_id
HAVING COUNT(DISTINCT l.state) > 1;

/*Exercise 26: Find the most expensive property for each broker*/
with price_broker_id as (
select broker_id, property_id, price,
row_number() over (partition by broker_id order by price desc, property_id) as price_rank
from properties)
select broker_id, property_id, price
from price_broker_id
where price_rank=1;

/*Exercise 27: Find all properties whose price is higher than the average price of their broker.*/
with avg_price_broker as (
select p.broker_id, p.property_id, l.state, p.price,
avg(p.price) over (partition by p.broker_id) as avg_price
from properties p join locations l
on p.location_id=l.location_id)
select broker_id, property_id, state, price, round(avg_price:: numeric, 2) as avg_price_broker 
from avg_price_broker 
where price > avg_price;

/*Exercise 28: Find the broker with the highest average property price*/
SELECT
    broker_id,
    ROUND(AVG(price)::numeric, 2) AS avg_price
FROM properties
GROUP BY broker_id
ORDER BY avg_price DESC
LIMIT 1;

/*Exercise 29: Find the top 3 brokers with the highest number of properties listed*/
SELECT broker_id, count(*) AS total_properties
FROM properties
GROUP BY broker_id
ORDER BY total_properties DESC
LIMIT 3;

/*Exercise 30: Find the top 3 most expensive properties in each state, but only for brokers who have listed properties in more than one state*/
with brokers_state as (
select p.broker_id from properties p 
join locations l on p.location_id=l.location_id
group by p.broker_id 
having count(distinct l.state) > 1
),
rank_price_state as (
select l.state, p.broker_id, p.property_id, p.price,
row_number() over (partition by l.state order by p.price desc, p.property_id) as price_rank
from properties p join locations l
on p.location_id=l.location_id 
inner join brokers_state bs on p.broker_id=bs.broker_id)
select * from rank_price_state where price_rank <= 3;


/*EXPLAIN ANALYZE*/
create index idx_properties_broker_id on properties (broker_id);
explain ANALYZE
SELECT *
FROM properties
WHERE broker_id = 100;

CREATE INDEX idx_properties_price ON properties (price);
EXPLAIN ANALYZE
SELECT *
FROM properties
WHERE price > 4000000;

EXPLAIN ANALYZE
SELECT *
FROM properties
WHERE price > 1000000;

SELECT
    indexrelname AS index_name,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE relname = 'properties';

SELECT
    pg_size_pretty(pg_relation_size('properties')) AS table_size;

EXPLAIN ANALYZE
SELECT *
FROM properties
WHERE property_id = 100;

EXPLAIN ANALYZE
SELECT property_id
FROM properties
WHERE property_id = 100;

/*JOIN*/
EXPLAIN ANALYZE
SELECT
    p.property_id,
    p.price,
    l.state
FROM properties p
JOIN locations l
    ON p.location_id = l.location_id
WHERE p.price > 4000000;

EXPLAIN ANALYZE
SELECT
    p.property_id,
    p.location_id,
    l.city,
    l.state
FROM properties p
JOIN locations l
    ON p.location_id = l.location_id;


EXPLAIN ANALYZE
SELECT
    l.state,
    COUNT(*) AS total_properties
FROM properties p
JOIN locations l
    ON p.location_id = l.location_id
GROUP BY l.state
ORDER BY total_properties DESC;

SHOW work_mem;

SET work_mem = '64MB';

EXPLAIN ANALYZE
SELECT
    l.state,
    COUNT(*) AS total_properties
FROM properties p
JOIN locations l
    ON p.location_id = l.location_id
GROUP BY l.state
ORDER BY total_properties DESC;