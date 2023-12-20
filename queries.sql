--Мы возвращаем агрегированные значение всех строк
SELECT COUNT(*) AS customers_count FROM customers;
--Шаг №5, задание 1
-- Возвращаем конкатенацию имени и фамилии, подстчет всех операций и суммарную выручку
SELECT CONCAT(first_name, ' ', last_name) AS name, COUNT(sales_person_id) AS operations, FLOOR(SUM(sales.quantity * price)) AS income
FROM sales
-- Так как у нас ограничение по первым десяти, то можем использовать два LEFT JOIN
-- но если бы было необходимо показать всех сотрудник, я бы использовал RIGHT
-- так как есть сотрудник с NULL
LEFT JOIN employees ON
sales_person_id = employee_id
LEFT JOIN products ON
sales.product_id = products.product_id
--группируем относительно имени и фамилии
GROUP BY first_name, last_name
--сортировка по убыванию
ORDER BY income DESC
-- ограничение выборки
LIMIT 10;
--Шаг №5, задание 2
--Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. Таблица отсортирована по выручке по возрастанию.
-- Сделаем выборку по имени и фамилии и посчтием средний доход
SELECT CONCAT(first_name, ' ', last_name) AS name, ROUND(AVG(sales.quantity * price)) AS average_income 
FROM sales
LEFT JOIN employees ON
sales_person_id = employee_id
LEFT JOIN products ON
sales.product_id = products.product_id
GROUP BY first_name, last_name
-- Добавим в HAVING (фильтрация после группировки) сравнение средней выручки каждого работника к общей средней выручке
-- Общую среднюю выручку вычисляем использую подзапрос
HAVING AVG(sales.quantity * price) < (SELECT AVG(sales.quantity * products.price) FROM sales JOIN products ON sales.product_id = products.product_id)  
ORDER BY average_income ASC;
--Шаг №5, задание 3
--Третий отчет содержит информацию о выручке по дням недели. Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку.
--Используем функцию to_char со значением 'day' чтобы вывести название дня
SELECT CONCAT(first_name, ' ', last_name) AS name, to_char(sale_date, 'day') AS weekday, ROUND(SUM(sales.quantity * price), 0) AS income 
FROM sales
LEFT JOIN employees ON
sales_person_id = employee_id
LEFT JOIN products ON
sales.product_id = products.product_id
GROUP BY sale_date, first_name, last_name;
--Шаг №6 задание 1
--Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
SELECT age_range, COUNT(*)
FROM (SELECT CASE
WHEN age BETWEEN 16 AND 25 THEN '16-25'
WHEN age BETWEEN 26 AND 40 THEN '26-40'
ELSE '40+'
END AS age_range FROM customers) AS age_range
GROUP BY age_range
ORDER BY age_range 
--Шаг №6 задача 2
--Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке, которую они принесли.
select distinct date, 
count(customer_id) over(partition by date) as total_customers, 
sum(quantity * price) OVER(partition by date) as income 
from (select *, to_char(sale_date, 'YYYY-MM') as date from sales
join products on sales.product_id = products.product_id) as t
group by date, customer_id, quantity, price
order by date
--Третий отчет следует составить о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0)
select concat(c.first_name, ' ', c.last_name)  as customer, s.sale_date, concat(e.first_name, ' ', e.last_name) as seller
from customers c 
left join sales s 
on c.customer_id = s.customer_id
left join employees e
on s.sales_person_id = e.employee_id 
left join products p 
on s.product_id = p.product_id
where price = 0
