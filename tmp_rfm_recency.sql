--создаем временную таблицу, в которую сохраним результат рассчета recency
CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);

--рассчитываем показатель и добавляем во временную таблицу
insert into analysis.tmp_rfm_recency (user_id, recency)

with result as (
  select
	  user_id,
	  ntile(5) over( order by last_purchase_day) as recency
  from (
	select
		u.id as user_id,
		coalesce(max(o.order_ts), '1900-01-01') as last_purchase_day --для корректной сортировки если заказов не было и возвращается null
	from orders_view o
	inner join orderstatuses_view os
		on o.status = os.id and
			os."key" = 'Closed'
	right join users_view u --нам нужны все пользователи, даже если у них не было заказов
		on o.user_id = u.id
	group by u.id
  ) user_last_purchase
)

--select recency, count(*) from result group by recency - проверяем правильность создания групп 

select * from result




