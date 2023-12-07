
-- Задание 1
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


--Задание 2
select
	"Date",
	round(((sum - prev_val)/ prev_val)* 100 ,
	2) as "%"
from
	(
	select
		*,
		lag(sum,
		1,
		sum) over (
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


			
--Задание 3
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


	
	
	
-- Задание 4
	with aircraftseats as (
select
	aircraft_code,
	count(*) as seat_count
from
	seats
group by
	aircraft_code)
select
	departure_airport,
	scheduled_departure::date,
	empty_seat,
	sum(empty_seat) over (partition by departure_airport
order by
	scheduled_departure::date)
from
	(
	select
		tmp.flight_id,
		empty_seat,
		scheduled_departure,
		departure_airport,
		count(*) over (partition by scheduled_departure::date,
		f.departure_airport) as count_empty_aircraft
	from
		(
		select
			tf.flight_id,
			count(*) as empty_seat
		from
			ticket_flights tf
		left join boarding_passes bp on
			tf.flight_id = bp.flight_id
		where
			bp.seat_no is null
		group by
			tf.flight_id) as tmp
	join flights f on
		tmp.flight_id = f.flight_id
	join aircraftseats acs on
		f.aircraft_code = acs.aircraft_code
	where
		empty_seat = seat_count) as tmp2
where
	count_empty_aircraft > 1
order by
	departure_airport,
	scheduled_departure