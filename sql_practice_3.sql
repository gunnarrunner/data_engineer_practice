select merchant_id, sum(amount) as num_payments
from payments
where status = 'completed'
and payment_date >= CURRENT_DATE - INTERVAL '30 days'
group by merchant_id;


-- Find duplicate payment IDs.
select payment_id, count(*) as duplicate_count
from payments
group by payment_id
having count(*) > 1;

-- Find each merchant’s most recent payment.

with ranked_payments as (
    select merchant_id, amount, payment_date,
           row_number() over (partition by merchant_id order by payment_date desc) as rn
    from payments
)
select merchant_id, amount, payment_date
from ranked_payments
where rn = 1;

-- practice 2 for most recent order for each customer 

with ranked_orders as (
    select customer_id, order_id, order_date, order_total,
            row_number() over (partition by customer_id order by order_date desc) as rn
    from orders
)
select customer_id, order_id, order_date, order_total
from ranked_orders
where rn = 1;