
-- Задание 1 OK
select
	model
from
	aircrafts a
join (
	select
		aircraft_code,
		count(*) as seat_numb
	from
		seats s
	group by
		aircraft_code) as j1 on
	a.aircraft_code = j1.aircraft_code
where
	j1.seat_numb < 50


--Задание 2 Исправлено форматирование LAG
select
	"Date",
	round(((sum - prev_val)/ prev_val)* 100 ,
	2) as "%"
from
	(
	select
		*, lag(sum,	1,sum) 
		over (
	order by
		"Date") as prev_val
	from
		(
		select
			date_trunc('month',
			book_date) as "Date",
			sum(total_amount) as sum
		from
			bookings b
		group by
			"Date"
		order by
			"Date") as tmp) as tmp2


			
--Задание 3  OK
select
	a.model
from
	(
	select
		tmp.aircraft_code,
		array_agg(tmp.fare_conditions) as classes
	from
		(
		select
			s.aircraft_code,
			s.fare_conditions
		from
			seats s
		group by
			s.aircraft_code,
			s.fare_conditions) as tmp
	group by
		tmp.aircraft_code) as tmp2
join aircrafts a on
	tmp2.aircraft_code = a.aircraft_code
where
	not ('Business' = any(tmp2.classes))


	
	
	
-- Задание 4 В разработке
	
	
-- Задание 5
select
	departure_airport,
	arrival_airport,
	round((flight_count / total_flight)* 100,
	3) as "%"
from
	(
	select
		*,
		sum(flight_count) over () as total_flight
	from
		(
		select
			departure_airport,
			arrival_airport,
			count(*) as flight_count
		from
			flights f
		where
			status = 'Arrived'
		group by
			departure_airport,
			arrival_airport
		order by
			departure_airport,
			arrival_airport) as tmp) as tmp2
			

-- Задание 6
select
	substring(contact_data ->> 'phone',
	3,
	3) as phone_code,
	count(*) as cnt
from
	tickets t
group by
	phone_code

-- Задание 7
select
	amount_class,
	count(*)
from
	(
	select
		*,
		case
			when total_amount_flight < 50000000 then 'low'
			when total_amount_flight >= 50000000
			and total_amount_flight < 150000000 then 'middle'
			when total_amount_flight >= 150000000 then 'high'
		end as amount_class
	from
		(
		select
			f.departure_airport,
			f.arrival_airport,
			sum(tf.amount) as total_amount_flight
		from
			flights f
		join ticket_flights tf on
			f.flight_id = tf.flight_id
		group by
			f.departure_airport,
			f.arrival_airport
		order by
			f.departure_airport,
			f.arrival_airport) as tmp) as tmp2
			group by amount_class
			