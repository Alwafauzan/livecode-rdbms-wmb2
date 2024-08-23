-- t_bill = trans_date, m_customer = customer_name, m_table = table_name, m_trans_type = trans_type , t_bill_detail = sub_total
-- soal no 1
select t_bill.id bill_id,t_bill.trans_date, m_customer.customer_name, m_table.table_name, t_bill.trans_type, 
t_bill_sub_total.sub_total
from t_bill 
left join m_customer on t_bill.customer_id = m_customer.id 
left join m_table on t_bill.table_id = m_table.id
left join (
	select t_bill_detail.bill_id, sum(m_menu_price.price * t_bill_detail.qty) as sub_total
	from t_bill_detail 
	join m_menu_price on t_bill_detail.menu_price_id = m_menu_price.id 
	group by t_bill_detail.bill_id
	order by t_bill_detail.bill_id
) as t_bill_sub_total on t_bill.id = t_bill_sub_total.bill_id;

-- t_bill = trans_date, m_menu = menu_name, sub total = menu * per hari, grand total, semua menu dikali per hari, sales contribution
-- soal no 2
select 
t_bill.trans_date, 
m_menu.menu_name, 
sum(m_menu_price.price * t_bill_detail.qty) as sub_total,
	(select sum(sub_total) as grand_total
		from (
			select t_bill.trans_date, sum(m_menu_price.price * t_bill_detail.qty) as sub_total
			from t_bill 
			join t_bill_detail on t_bill.id = t_bill_detail.bill_id
			join m_menu_price on t_bill_detail.menu_price_id = m_menu_price.id
			group by t_bill.trans_date
		) as t_bill_sub_total
		where t_bill_sub_total.trans_date = t_bill.trans_date
	) as grand_total,
(sum(m_menu_price.price * t_bill_detail.qty) / (select sum(sub_total) as grand_total
		from (
			select t_bill.trans_date, sum(m_menu_price.price * t_bill_detail.qty) as sub_total
			from t_bill 
			join t_bill_detail on t_bill.id = t_bill_detail.bill_id
			join m_menu_price on t_bill_detail.menu_price_id = m_menu_price.id
			group by t_bill.trans_date
		) as t_bill_sub_total
		where t_bill_sub_total.trans_date = t_bill.trans_date
	) * 100) as sales_contribution
from t_bill 
join t_bill_detail on t_bill.id = t_bill_detail.bill_id
join m_menu_price on t_bill_detail.menu_price_id = m_menu_price.id
join m_menu on m_menu_price.menu_id = m_menu.id
group by t_bill.trans_date, m_menu.menu_name
order by t_bill.trans_date, sub_total DESC ;

-- soal no 3
select 
m_menu.menu_name, 
sum(m_menu_price.price * t_bill_detail.qty) as sub_total,
	(select sum(sub_total) as grand_total
		from (
			select m_menu.menu_name, sum(m_menu_price.price * t_bill_detail.qty) as sub_total
			from t_bill 
			join t_bill_detail on t_bill.id = t_bill_detail.bill_id
			join m_menu_price on t_bill_detail.menu_price_id = m_menu_price.id
			join m_menu on m_menu_price.menu_id = m_menu.id
			group by m_menu.menu_name
		) as t_bill_sub_total
	) as grand_total,
(sum(m_menu_price.price * t_bill_detail.qty) / (select sum(sub_total) as grand_total
		from (
			select m_menu.menu_name, sum(m_menu_price.price * t_bill_detail.qty) as sub_total
			from t_bill 
			join t_bill_detail on t_bill.id = t_bill_detail.bill_id
			join m_menu_price on t_bill_detail.menu_price_id = m_menu_price.id
			join m_menu on m_menu_price.menu_id = m_menu.id
			group by m_menu.menu_name
		) as t_bill_sub_total
	) * 100) as sales_contribution
from t_bill 
join t_bill_detail on t_bill.id = t_bill_detail.bill_id
join m_menu_price on t_bill_detail.menu_price_id = m_menu_price.id
join m_menu on m_menu_price.menu_id = m_menu.id
group by m_menu.menu_name
order by sub_total DESC ;

-- soal no 4 cuma max
select max(sub_total) as max
from (
	select t_bill.trans_date, count(t_bill_detail.qty) as sub_total
	from t_bill 
	join t_bill_detail on t_bill.id = t_bill_detail.bill_id
	join m_menu_price on t_bill_detail.menu_price_id = m_menu_price.id
	group by t_bill.trans_date
) as t_bill_sub_total
group by trans_date
order by max DESC LIMIT 1;

-- soal no 4 lengkap
select max(sub_total) as total_transaction, trans_date date
from (
	select t_bill.trans_date, count(t_bill_detail.qty) as sub_total
	from t_bill 
	join t_bill_detail on t_bill.id = t_bill_detail.bill_id
	join m_menu_price on t_bill_detail.menu_price_id = m_menu_price.id
	group by t_bill.trans_date
) as t_bill_sub_total
group by trans_date
order by trans_date;


-- soal no 5
select 
	sum(CASE WHEN extract(dow from trans_date) in (0,6) THEN 1 ELSE 0 END * price * qty) as weekend,
	sum(CASE WHEN extract(dow from trans_date) not in (0,6) THEN 1 ELSE 0 END * price * qty) as weekday
from t_bill 
join t_bill_detail on t_bill.id = t_bill_detail.bill_id
join m_menu_price on t_bill_detail.menu_price_id = m_menu_price.id;
