
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


--Задание 2 OK
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


	
	
	
-- Задание 4 Задача переработана
with cte1 as (
select
	aircraft_code,
	count(*) as seat_cnt
from
	seats s
group by
	aircraft_code)
select
	tmp1.departure_airport,
	tmp1.actual_departure::date,
	sum(seat_cnt) over (partition by tmp1.departure_airport,
	tmp1.actual_departure::date
order by
	tmp1.actual_departure) as itog
from
	(
	select
		f.departure_airport,
		f.actual_departure,
		cte1.seat_cnt,
		count(*) over(partition by f.departure_airport,
		f.actual_departure::date) as aircr_cnt
	from
		flights f
	left join ticket_flights tf on
		f.flight_id = tf.flight_id
	join cte1 on
		f.aircraft_code = cte1.aircraft_code
	where
		status = 'Arrived'
		and tf.flight_id is null) as tmp1
where
	aircr_cnt > 1

	
	
	
	
	

-- Задание 5 
--1.Учтено количетсво перелетов, а не рейсов.
--2.В выборку выведены наименования аэропортов.
select
	dep_port,
	arr_port,
	(flight_count / sum_flight_count)* 100 as "%"
from
	(
	select
		a.airport_name as dep_port,
		a2.airport_name as arr_port,
		count(*) as flight_count,
		sum(count(*)) over () as sum_flight_count
	from
		flights f
	join ticket_flights tf on
		f.flight_id = tf.flight_id
	join airports a on
		f.departure_airport = a.airport_code
	join airports a2 on
		f.arrival_airport = a2.airport_code
	where
		f.status = 'Arrived'
	group by
		a.airport_name,
		a2.airport_name) as tmp1
		

-- Задание 6 OK
select
	substring(contact_data ->> 'phone',
	3,
	3) as phone_code,
	count(*) as cnt
from
	tickets t
group by
	phone_code

	
	
-- Задание 7 OK
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

			
-- Задание 8 OK
with med1 as (
select
	percentile_cont(0.5) within group (
	order by bookings.total_amount) as med_book
from
	bookings),
med2 as (
select
	percentile_cont(0.5) within group (
	order by amount) as med_flight
from
	ticket_flights tf)
select
	(
	select
		*
	from
		med1),
	(
	select
		*
	from
		med2),
	round(((select * from med1)/( select * from	med2))::numeric, 2)

	
	
	
--Задание 9
---create extension cube
---create extension earthdistance
--1.Исправлена долгота и ширина в функции ll_to_earth.
--2.В итоговую выборку выведено только значение минимальной стоимости одного километра полета.
with tmp as (
select
	f.flight_id,
	a.airport_name as dep_port,
	a2.airport_name as arr_port,
	ll_to_earth(a.latitude,
	a.longitude) as dep_earth,
	ll_to_earth(a2.latitude,
	a2.longitude) as arr_earth
from
	flights f
join airports a on
	f.departure_airport = a.airport_code
join airports a2 on
	f.arrival_airport = a2.airport_code),
	cte2 as(select
	*
from
	(
	select
		flight_id,
		dep_port,
		arr_port,
		amount/dist as am_km
	from
		(
		select
			tf.*,
			tmp.dep_port,
			tmp.arr_port,
			round(((earth_distance(dep_earth,
			arr_earth))/ 1000)::numeric,
			2) as dist
		from
			tmp
		join ticket_flights tf on
			tmp.flight_id = tf.flight_id) as tmp2 ) as tmp3)
select min(am_km) from cte2