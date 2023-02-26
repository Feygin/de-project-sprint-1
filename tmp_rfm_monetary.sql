--создаем временную таблицу, в которую сохраним результат рассчета monetary_value
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

--рассчитываем показатель и добавляем во временную таблицу
insert into analysis.tmp_rfm_monetary_value (user_id, monetary_value)

with result as (
  select
	  user_id,
	  ntile(5) over( order by payment_amount) as monetary_value
  from (
	select
		u.id as user_id,
		coalesce(sum(cost), 0) as payment_amount --для корректной сортировки если оплаты не было и возвращается null
	from orders_view o
	inner join orderstatuses_view os
		on o.status = os.id and
			os."key" = 'Closed'
	right join users_view u --нам нужны все пользователи, даже если у них не было заказов
		on o.user_id = u.id
	group by u.id
  ) user_last_purchase
)

-- select monetary_value, count(*) from result group by monetary_value -- проверяем правильность создания групп 

select * from result




