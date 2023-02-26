--дорабатываем представление orders_view согласно изменению
create or replace view analysis.orders_view as

with order_last_status as (
  select
	  order_id,
	  status_id
  from (
	select
		order_id,
		status_id,
		dttm,
		row_number() over( partition by order_id order by dttm desc) as rn
	from production.orderstatuslog o
  ) order_status_ordered
  where rn = 1
)

select
	o.order_id,
    order_ts,
    user_id,
    cost,
    ols.status_id as status
from production.orders o
	join order_last_status ols
		on o.order_id = ols.order_id
    