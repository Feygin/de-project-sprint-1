
проверить качество данных ?

# 1.3. Качество данных

## Оцените, насколько качественные данные хранятся в источнике.
Опишите, как вы проверяли исходные данные и какие выводы сделали.

В таблице orders не задан foreign key для полей user_id и status. Нао проверить, что ссылочная целостность не нарушена. Иначе есть риск того, что при сборе витрины может потеряться часть данных. Для проверки используем следующий sql запрос:

    '''sql
    -- проверяем ссылочную целосность в таблице orders
    select
        o.order_id,
        o.user_id,
        o.status,
        case
            when u.id is null then 'missing user'
        end as check_user,
        case
            when os.id is null then 'missing status'
        end as check_status
    from production.orders o 
        left join production.users u
            on o.user_id = u.id
        left join production.orderstatuses os
            on o.status = os.id
    where u.id is null or os.id is null
    '''
Нарушение связей не обнаружено.

Проверим глубину данных:

    '''sql
    --проеряем глубину данных
    select
        date_trunc('month', order_ts)::date,
        count(*) as total_orders
    from production.orders o
    group by 1
    order by 1 desc
    '''
Данные о покупках предоставлены только за ферваль и март 2022 года. Эту информацию надо сообщить заказчику, чтобы не возникло недоразумений.

Проверим статистические показатели для суммы и количества заказов:

    '''sql
    select
        min(coalesce(user_orders,0)) as orders_min,
        avg(coalesce(user_orders,0)) as orders_avg,
        max(coalesce(user_orders,0)) as orders_max,
        count(case when coalesce(user_orders,0) = 0 then 1 end)::float
            / count(coalesce(user_orders,0))::float * 100 as orders_null_pct, 
        min(coalesce(user_payment,0)) as payment_min,
        avg(coalesce(user_payment,0)) as payment_avg,
        max(coalesce(user_payment,0)) as payment_max,
            count(case when coalesce(user_payment,0) = 0 then 1 end)::float
            / count(coalesce(user_payment,0))::float * 100 as payment_null_pct
    from (
    select
        u.id as user_id,
        count(o.order_id) as user_orders,
        sum(coalesce(cost, 0)) as user_payment
    from production.orders o
        right join production.users u
            on o.user_id = u.id
    group by u.id
    ) user_metrics
    '''
Значимые отклонения не выявлены. 

## Укажите, какие инструменты обеспечивают качество данных в источнике.
Ответ запишите в формате таблицы со следующими столбцами:
- `Наименование таблицы` - наименование таблицы, объект которой рассматриваете.
- `Объект` - Здесь укажите название объекта в таблице, на который применён инструмент. Например, здесь стоит перечислить поля таблицы, индексы и т.д.
- `Инструмент` - тип инструмента: первичный ключ, ограничение или что-то ещё.
- `Для чего используется` - здесь в свободной форме опишите, что инструмент делает.

Пример ответа:

| Таблицы                   | Объект                                                                               | Инструмент      | Для чего используется                                                |
| ------------------------- | ------------------------------------------------------------------------------------ | --------------- | -------------------------------------------------------------------- |
| production.orderitems     | id int4 NOT NULL PRIMARY KEY                                                         | Первичный ключ  | Идентификатор строки товара в заказе                                 |
| production.orderitems     | product_id int4 NOT NULL FOREIGN KEY                                                 | Внешний ключ    | Обеспечивает ссылочную целостность записей о товарах                 |
| production.orderitems     | order_id int4 NOT NULL FOREIGN KEY                                                   | Внешний ключ    | Обеспечивает ссылочную целостность записей о заказах                 |
| production.orderitems     | order_id, product_id UNIQUE                                                          | Уникальность    | Обеспечивает уникальность комбинации номера заказа и товара          |
| production.orderitems     | name varchar(2048) NOT NULL                                                          | NOT NULL        | Имя товара всегда заполнено                                          |
| production.orderitems     | price numeric(19, 5) NOT NULL DEFAULT 0 CHECK price >= (0)                           | NOT NULL, CHECK | Цена всегда заполнена и больше 0                                     |
| production.orderitems     | discount numeric(19, 5) NOT NULL DEFAULT 0 CHECK discount >= 0 AND discount <= price | NOT NULL, CHECK | Скидка всегда заполнена и не может быть больше цены товара           |
| production.orderitems     | quantity int4 NOT NULL CHECK quantity > 0                                            | NOT NULL, CHECK | Количество товара всегд заполнено и больше 0                         |
| production.orders         | order_id int4 PRIMARY KEY                                                            | Первичный ключ  | Идентификатор заказа                                                 |
| production.orders         | order_ts timestamp NOT NULL                                                          | NOT NULL        | Дата заказа всегда заполнена                                         |
| production.orders         | user_id int4 NOT NULL                                                                | NOT NULL        | Идентификатор пользователя всегда заполнен                           |
| production.orders         | bonus_payment numeric(19, 5) NOT NULL DEFAULT 0                                      | NOT NULL        | Бонус всегда заполнен                                                |
| production.orders         | payment numeric(19, 5) NOT NULL DEFAULT 0                                            | NOT NULL        | Платеж всегда заполнен                                               |
| production.orders         | cost numeric(19, 5) NOT NULL DEFAULT 0 CHECK cost = (payment + bonus_payment)        | NOT NULL, CHECK | Стоимость всегда заполнена и равна сумме платежа и бонусного платежа |
| production.orders         | bonus_grant numeric(19, 5) NOT NULL DEFAULT 0                                        | NOT NULL        | Бонус всегда заполнен                                                |
| production.orders         | status int4 NOT NULL                                                                 | NOT NULL        | Статус всегда заполнен                                               |
| production.orderstatuses  | id int4 NOT NULL PRIMARY KEY                                                         | Первичный ключ  | Идентификатор статуса                                                |
| production.orderstatuses  | key varchar(255) NOT NULL                                                            | NOT NULL        | Статус всегда заполнен                                               |
| production.orderstatuslog | id int4 NOT NULL PRIMARY KEY                                                         | Первичный ключ  | Идентифиатор статуса заказа                                          |
| production.orderstatuslog | order_id int4 NOT NULL FOREIGN KEY                                                   | Внешний ключ    | Обеспечивает ссылочную целостность записей о заказах                 |
| production.orderstatuslog | status_id int4 NOT NULL FOREIGN KEY                                                  | Внешний ключ    | Обеспечивает ссылочную целостность записей о статусе заказа          |
| production.orderstatuslog | order_id, status_id UNIQUE                                                           | Уникальность    | Комбинация заказа и статуса уникальна                                |
| production.orderstatuslog | dttm timestamp NOT NULL                                                              | NOT NULL        | Время обновлния статуса заказа всегда заполнено                      |
| production.products       | id int4 NOT NULL PRIMARY KEY                                                         | Первичный ключ  | Идентификатор продукта                                               |
| production.products       | name NOT NULL                                                                        | NOT NULL        | Имя продукта всегда заполнено                                        |
| production.products       | price numeric(19, 5) NOT NULL DEFAULT 0 CHECK price >= 0                             | NOT NULL, CHECK | Цена продукта всегда заполнена и равна или больше 0                  |
| production.users          | id int4 NOT NULL PRIMARY KEY                                                         | Первичный ключ  | Идентификатор пользователя                                           |
| production.users          | name varchar(2048) NULL                                                              | -               | Поле с именем опциональное                                           |
| production.users          | login varchar(2048) NOT NULL                                                         | NOT NULL        | Логин всегда заполнен                                                |
|                           |                                                                                      |                 |                                                                      |





