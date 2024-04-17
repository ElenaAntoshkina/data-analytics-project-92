--смотрим содержание таблиц
select *
from sales s ;
select *
from employees e;
select*
from products;
select *
from customers;

--считаем количество покупателей через их id
SELECT 
	count(customer_id) AS customers_count
FROM customers;

--считаем топ 10 продацов с наибольшей выручкой:
with seller as (
    select
        employee_id,
        concat(e.first_name, ' ', e.last_name) as seller
    from employees as e
)
select
    se.seller,
    count(s.sales_id) as operations,
    floor(sum(s.quantity * p.price)) as income
from sales as s
inner join seller as se
    on s.sales_person_id = se.employee_id
inner join products as p
    on s.product_id = p.product_id
group by se.seller
order by floor(sum(s.quantity * p.price)) desc
limit 10;

--выводим продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
with seller as (
    select
        concat(e.first_name, ' ', e.last_name) as name,
        floor (avg(s.quantity * p.price)) as average_income,
        floor (sum(s.quantity * p.price)) as income
    from sales as s
    inner join products as p
        on s.product_id = p.product_id
    inner join employees as e
        on s.sales_person_id = e.employee_id
    group by concat(e.first_name, ' ', e.last_name)
)
select
    se.name as seller,
    se.average_income
from seller as se
where se.average_income < (select avg(average_income) from seller)
order by se.average_income;
--выводим данные по выручке по каждому продавцу и дню недели
with tab as (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
        to_char(s.sale_date, 'day') as day_of_week,
        to_char(s.sale_date, 'ID') as num_of_week,
        floor(sum(s.quantity * p.price)) as income
    from sales as s
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
    group by
        concat(e.first_name, ' ', e.last_name),
        to_char(s.sale_date, 'day'),
        to_char(s.sale_date, 'ID')
)
select
    seller,
    day_of_week,
    income
from tab
order by num_of_week, seller;


--считаем количество покупателей в разных возрастных группах
with tab_age as (
    select
        case
            when age >= 16 and age <= 25 then '16-25'
            when age >= 26 and age <= 40 then '26-40'
            when age >= 41 then '40+'
        end as age_category
    from customers
)
select
    age_category,
    count(age_category) as age_count
from tab_age
group by age_category order by age_category;


--выводим данные о количестве уникальных покупателей и выручке, которую они принесли по месяцам
with tab as (
    select
        s.customer_id,
        to_char(s.sale_date, 'YYYY-MM') as selling_month,
        count(s.customer_id) as total_customers,
        sum(s.quantity * p.price) as income
    from sales as s
    inner join products as p
        on s.product_id = p.product_id
    group by s.customer_id, to_char(s.sale_date, 'YYYY-MM')
)
select
    selling_month,
    count(customer_id) as total_customers,
    floor(sum(income)) as income
from tab
group by selling_month order by selling_month;


--выводим покупателей, у которых первая покупка была акционная
with tab as (
    select
        s.sale_date,
        s.customer_id,
        s.sales_id,
        c.first_name || ' ' || c.last_name as customer,
        e.first_name || ' ' || e.last_name as seller,
        (s.quantity * p.price) as purchase,
        row_number()
            over (partition by s.customer_id order by s.sale_date asc)
        as rn
    from sales as s
    inner join customers as c
        on s.customer_id = c.customer_id
    inner join employees as e
        on s.sales_person_id = e.employee_id
    inner join products as p
        on s.product_id = p.product_id
)
select
    customer,
    sale_date,
    seller
from tab
where rn = 1 and purchase = 0
order by customer_id;
