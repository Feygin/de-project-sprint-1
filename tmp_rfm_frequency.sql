--создаем временную таблицу, в которую сохраним результат рассчета frequency
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);

--рассчитываем показатель и добавляем во временную таблицу
insert into analysis.tmp_rfm_frequency (user_id, frequency)

with result as (
  select
	  user_id,
	  ntile(5) over( order by total_orders) as frequency 
  from (
	select
		u.id as user_id,
		coalesce(count(order_id),0) as total_orders --для корректной сортировки если заказов не было и возвращается null
	from orders_view o
	inner join orderstatuses_view os
		on o.status = os.id and
			os."key" = 'Closed'
	right join users_view u --нам нужны все пользователи, даже если у них не было заказов
		on o.user_id = u.id
	group by u.id
  ) user_last_purchase
)

--select frequency, count(*) from result group by frequency -- проверяем правильность создания групп 

select * from result




