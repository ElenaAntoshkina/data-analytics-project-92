--смотрим содержание таблиц
select *
from sales s ;
select *
from employees e;
select*
--считаем количество покупателей через их id
from products;SELECT count(customer_id) AS customers_count
FROM customers;
--считаем топ 10 продацов:
with seller as (select employee_id, concat(e.first_name,' ',e.last_name) as seller 
from employees as e)
select se.seller,
count(s.sales_id) as operations,
sum(s.quantity*p.price) as  income  
from sales as s
join seller as se 
on s.sales_person_id =se.employee_id 
join products p 
on s.product_id =p.product_id 
group by se.seller
order by sum(s.quantity*p.price) desc 
limit 10
;
--считаем суммарную выручку продавцов
with seller as (select employee_id, concat(e.first_name,' ',e.last_name) as seller 
from employees as e),
tab as (select se.seller,
count(s.sales_id) as operations,
sum(s.quantity*p.price) as  income  
from sales as s
join seller as se 
on s.sales_person_id =se.employee_id 
join products p 
on s.product_id =p.product_id 
group by se.seller
order by sum(s.quantity*p.price))
select seller as name,income as 
;
--выводим продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
with seller as (
	select 
	concat(e.first_name,' ',e.last_name) as name, 
	round(avg(s.quantity*p.price),0) as average_income ,
	round(sum(s.quantity*p.price),0) as  income
from sales as s
	join products as p
	on s.product_id=p.product_id
	join employees e 
	on s.sales_person_id =e.employee_id
group by concat(e.first_name,' ',e.last_name))
select se.name,
	se.average_income 
	from seller se
where se.average_income<(select avg(average_income) from seller)
order by average_income;
--выводим данные по выручке по каждому продавцу и дню недели
with tab as(select 
	concat(e.first_name,' ',e.last_name) as seller, 
	to_char(s.sale_date, 'Day')as day_of_week,
	to_char(s.sale_date, 'ID')as num_of_week,
	floor(sum(s.quantity*p.price)) as  income
from sales s 
	join employees e
	on s.sales_person_id =e.employee_id
	join products as p
	on s.product_id=p.product_id
group by concat(e.first_name,' ',e.last_name),to_char(s.sale_date, 'Day'),to_char(s.sale_date, 'ID'))
select seller,
	day_of_week,
	income
		from tab
order by seller,num_of_week;
