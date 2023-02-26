--создаем представление orderitems в схеме analysis
--не используется в построении витрины
create view analysis.orderitems_view as
select
    id,
    product_id,
    order_id,
    name,
    price,
    discount,
    quantity
from production.orderitems;

--создаем представление orders в схеме analysis
--оставляем аттрибуты, которые используются при построении витрины
create view analysis.orders_view as
select 
    order_id,
    order_ts,
    user_id,
    cost,
    status
from production.orders;

--создаем представление orderstatuses в схеме analysis
--оставляем аттрибуты, которые используются при построении витрины
create view analysis.orderstatuses_view as
select 
    id,
    key
from production.orderstatuses;

--создаем представление orderstatuslog в схеме analysis
create view analysis.orderstatuslog_view as
select
    id,
    order_id,
    status_id,
    dttm
from production.orderstatuslog;

--создаем представление products в схеме analysis
--не используется в построении витрины
create view analysis.products_view as
select
    id,
    name,
    price
from production.products;

--создаем представление users в схеме analysis
--оставляем аттрибуты, которые используются при построении витрины
create view analysis.users_view as
select 
    id
from production.users;

