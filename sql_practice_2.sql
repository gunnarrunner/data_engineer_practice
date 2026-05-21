SELECT count(*) FROM departments;
SELECT count(*) FROM categories;
SELECT count(*) FROM products;
SELECT count(*) FROM orders;
SELECT count(*) FROM order_items;
SELECT count(*) FROM customers;

select c.customer_id, c.first_name, c.last_name, count(*) as total_orders
from customers c
inner join orders o on c.customer_id = o.order_customer_id
where o.order_date >= '2014-01-01' and o.order_date < '2014-02-01'
group by c.customer_id, c.first_name, c.last_name
order by total_orders desc, c.customer_id asc;


select c.customer_id, c.first_name, c.last_name, c.email, c.password, c.street,  c.city, c.state, c.zipcode
from customers
inner join orders on customers.customer_id = orders.order_customer_id
where not in (orders.order_date >= '2014-01-01' and orders.order_date < '2014-02-01')
group by c.customer_id, c.first_name, c.last_name, c.email, c.password, c.street,  c.city, c.state, c.zipcode
order by c.customer_id asc;


select c.customer_id, c.first_name, c.last_name, coalesce(sum(oi.subtotal), 0) as total_spent
from customers c
inner join orders o on c.customer_id = o.order_customer_id
inner join order_items oi on o.order_id = oi.order_item_id
where (o.order_date >= '2014-01-01' and o.order_date < '2014-02-01') AND o.status in ('complete', 'closed')
group by c.customer_id, c.first_name, c.last_name
order by total_spent desc, c.customer_id asc;


select ct.category_id, ct.category_department_id, ct.category_name, coalesce(sum(oi.subtotal), 0) as total_revenue
from categories ct
left join products p on ct.category_id = p.product_category_id
left join order_items oi on p.product_id = oi.order_item_product_id
left join orders o on oi.order_item_id = o.order_id
and o.status in ('complete', 'closed')
and (o.order_date >= '2014-01-01' and o.order_date < '2014-02-01')
group by ct.category_id, ct.category_department_id, ct.category_name
order by ct.category_id asc;


select d.department_id, d.department_name, count(*) as product_count
from departments d
inner join categories ct on d.department_id = ct.category_department_id
inner join products p on ct.category_id = p.product_category_id
group by d.department_id, d.department_name
order by d.department_id asc;
