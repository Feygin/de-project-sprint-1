--загружаем данные в витрину
insert into dm_rfm_segments (
  	user_id,
	recency,
  	frequency,
  	monetary
)

select
	trr.user_id,
	trr.recency,
	trf.frequency,
	trmv.monetary_value
from tmp_rfm_recency trr 
	inner join	tmp_rfm_frequency trf
		on trr.user_id = trf.user_id
	inner join tmp_rfm_monetary_value trmv
		on trr.user_id = trmv.user_id

--выводим первые 10 строк витрины
--select * from dm_rfm_segments order by user_id limit 10 

| user_id | recency | frequency | monetary |
| ------- | ------- | --------- | -------- |
| 0       | 1       | 3         | 4        |
| 1       | 4       | 3         | 3        |
| 2       | 2       | 3         | 5        |
| 3       | 2       | 3         | 3        |
| 4       | 4       | 3         | 3        |
| 5       | 5       | 5         | 5        |
| 6       | 1       | 3         | 5        |
| 7       | 4       | 2         | 2        |
| 8       | 1       | 2         | 3        |
| 9       | 1       | 2         | 2        |