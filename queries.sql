--считаем количество покупателей через их id
SELECT count(customer_id) AS customers_count
FROM customers;

--считаем топ 10 продацов с наибольшей выручкой:
WITH seller AS (
    SELECT
        employee_id,
        concat(e.first_name, ' ', e.last_name) AS seller
    FROM employees AS e
)

SELECT
    se.seller,
    count(s.sales_id) AS operations,
    floor(sum(s.quantity * p.price)) AS income
FROM sales AS s
INNER JOIN seller AS se
    ON s.sales_person_id = se.employee_id
INNER JOIN products AS p
    ON s.product_id = p.product_id
GROUP BY se.seller
ORDER BY floor(sum(s.quantity * p.price)) DESC
LIMIT 10;

--выводим продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
WITH seller AS (
    SELECT
        concat(e.first_name, ' ', e.last_name) AS name,
        floor(avg(s.quantity * p.price)) AS average_income,
        floor(sum(s.quantity * p.price)) AS income
    FROM sales AS s
    INNER JOIN products AS p
        ON s.product_id = p.product_id
    INNER JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    GROUP BY concat(e.first_name, ' ', e.last_name)
)

SELECT
    se.name AS seller,
    se.average_income
FROM seller AS se
WHERE se.average_income < (SELECT avg(average_income) FROM seller)
ORDER BY se.average_income;
--выводим данные по выручке по каждому продавцу и дню недели
WITH tab AS (
    SELECT
        concat(e.first_name, ' ', e.last_name) AS seller,
        to_char(s.sale_date, 'day') AS day_of_week,
        to_char(s.sale_date, 'ID') AS num_of_week,
        floor(sum(s.quantity * p.price)) AS income
    FROM sales AS s
    INNER JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    INNER JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY
        concat(e.first_name, ' ', e.last_name),
        to_char(s.sale_date, 'day'),
        to_char(s.sale_date, 'ID')
)

SELECT
    seller,
    day_of_week,
    income
FROM tab
ORDER BY num_of_week, seller;
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
