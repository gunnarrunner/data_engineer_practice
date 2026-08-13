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




select c.customer_id, c.name, COUNT(o.order_id) as order_count, SUM(COALESCE(o.total_amount, 0)) as total_spend
from customers c
inner join orders o on c.customer_id = o.customer_id
where o.status = 'completed'
group by c.customer_id, c.name
having COUNT(o.order_id) > 3
order by total_spend desc;


with ranked_orders as (
    select c.customer_id, c.name, o.order_id, o.order_date, o.total_amount,
           AVG(o.total_amount) over (partition by c.customer_id) as avg_order_value,
           row_number() over (partition by c.customer_id order by o.order_date desc) as rn
    from customers c
    inner join orders o on c.customer_id = o.customer_id
    where o.status = 'completed'
)
select customer_id, name, order_id, order_date, total_amount, avg_order_value,
       total_amount - avg_order_value as vs_avg
from ranked_orders
where rn = 1;

select st.category, 
       AVG(EXTRACT(EPOCH FROM (resolved_at - created_at)) / 3600) 
        FILTER (WHERE resolved_at IS NOT NULL) AS avg_resolution_hours,
       SUM(CASE WHEN st.ticket_id = NULL THEN 1 ELSE 0 END) as total_unresolved_tickets, 
       COUNT(*) as total_volume
from support_tickets st
group by st.category
order by avg_resolution_hours desc;

select u.vip_tier,
        Count(DISTINCT b.user_id) as distinct_depositors,
        SUM(b.payout_amount) as total_deposit_amount,
        AVG(b.payout_amount) as avg_deposit_amount
from users u
inner join bets b on u.user_id = b.user_id
where b.status = 'won'
group by u.vip_tier
order by total_deposit_amount desc;


with deposit_stats as (
    select u.user_id, t.transaction_id, t.transaction_date, t.amount,
              AVG(t.amount) over (partition by t.user_id) as avg_deposit_amount
              COUNT(t.transaction_id) over (partition by t.user_id) as deposit_count
    from users u
    inner join transactions t on u.user_id = t.user_id
    where t.type = 'deposit' and t.status = 'completed'
)

select user_id, transaction_id, transaction_date, amount, avg_deposit_amount,
       true as is_suspicious
from deposit_stats
where deposit_count >= 5 and amount > avg_deposit_amount * 3;

select a.team,
AVG(EXTRACT(EPOCH FROM (st.closed_at - st.opened_at)) / 3600) as avg_resolution_hours
from support_tickets st
left join agents a on st.agent_id = a.agent_id
where st.closed_at is not null and st.closed_at >= current_date - interval '30 days'
group by a.team
order by avg_resolution_hours desc;

select t.status, 
       round(AVG(amount), 2) as avg_transaction_amount
from transactions t
inner join users u on t.user_id = u.user_id
where u.vip_tier IN ('gold', 'platinum') and t.txn_type = 'deposit' and t.txn_date >= current_date - interval '90 days'
group by t.status
order by avg_transaction_amount desc;

with ranked_bets as (
    b.user_id,
    b.bet_id,
    b.bet_date,
    b.stake_amount,
    round(avg(b.stake_amount) over (partition by b.udrer_id), 2) as avg_stake_amount,
    count(*) over (partition by b.user_id) as bet_count,
    row_number() over (partition by b.user_id order by b.bet_date desc) as rn
    from bets b
)

select user_id, bet_id, bet_date, stake_amount, avg_stake_amount, bet_count
from ranked_bets
where rn = 1 and bet_count >= 5
order by user_id;