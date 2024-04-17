--считаем количество покупателей через их id
SELECT count(customer_id) AS customers_count
FROM customers;

--считаем топ 10 продацов с наибольшей выручкой:
WITH seller AS (
    SELECT
        employee_id,
        concat(first_name, ' ', last_name) AS seller
    FROM employees
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

--выводим продавцов, чья средняя выручка меньше средней выручки.
WITH seller AS (
    SELECT
        concat(e.first_name, ' ', e.last_name) AS seller,
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
    se.seller AS seller,
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
WITH tab_age AS (
    SELECT
        CASE
            WHEN age >= 16 AND age <= 25 THEN '16-25'
            WHEN age >= 26 AND age <= 40 THEN '26-40'
            WHEN age >= 41 THEN '40+'
        END AS age_category
    FROM customers
)

SELECT
    age_category,
    count(age_category) AS age_count
FROM tab_age
GROUP BY age_category ORDER BY age_category;

--выводим данные о количестве уникальных покупателей и выручке по месяцам
WITH tab AS (
    SELECT
        s.customer_id,
        to_char(s.sale_date, 'YYYY-MM') AS selling_month,
        count(s.customer_id) AS total_customers,
        sum(s.quantity * p.price) AS income
    FROM sales AS s
    INNER JOIN products AS p
        ON s.product_id = p.product_id
    GROUP BY s.customer_id, to_char(s.sale_date, 'YYYY-MM')
)

SELECT
    selling_month,
    count(customer_id) AS total_customers,
    floor(sum(income)) AS income
FROM tab
GROUP BY selling_month ORDER BY selling_month;


--выводим покупателей, у которых первая покупка была акционная
WITH tab AS (
    SELECT
        s.sale_date,
        s.customer_id,
        s.sales_id,
        c.first_name || ' ' || c.last_name AS customer,
        e.first_name || ' ' || e.last_name AS seller,
        (s.quantity * p.price) AS purchase,
        row_number()
            OVER (PARTITION by s.customer_id ORDER BY s.sale_date ASC)
        AS rn
    FROM sales AS s
    INNER JOIN customers AS c
        ON s.customer_id = c.customer_id
    INNER JOIN employees AS e
        ON s.sales_person_id = e.employee_id
    INNER JOIN products AS p
        ON s.product_id = p.product_id
)

SELECT
    customer,
    sale_date,
    seller
FROM tab
WHERE rn = 1 AND purchase = 0
ORDER BY customer_id;
