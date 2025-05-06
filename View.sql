--3  View
--3.1
--vw_StoreSalesSummary: Revenue, #Orders, AOV per store
create view	vw_StoreSalesSummary
as
	select s.store_name, COUNT(distinct oi.order_id) as Number_of_orders, 
		sum(quantity*list_price*(1-coalesce(discount,2))) as Revenue, 
		cast(sum(quantity*list_price*coalesce(discount,2))/COUNT(distinct oi.order_id) as decimal(18,2)) as AOV 
	from order_items oi join orders o on oi.order_id=o.order_id 
	join stores s on o.store_id=s.store_id
	where shipped_date is not null
	group by s.store_name;

--3.2
--	vw_TopSellingProducts: Rank products by total sales
create view vw_TopSellingProducts 
	as
	select 
	    p.product_id,
	    p.product_name,
	    SUM(oi.quantity) as total_quantity_sold,
	    SUM(oi.quantity * (oi.list_price - oi.discount)) as total_sales_amount,
	    RANK() over (order by SUM(oi.quantity * (oi.list_price - oi.discount)) desc) as sales_rank
	from order_items oi
	join products p on oi.product_id = p.product_id
	group by p.product_id, p.product_name;

--3.3
create view vw_InventoryStatus
as 
select sr.store_name, p.product_name, sk.quantity from stocks sk
inner join stores  sr on sk.store_id = sr.store_id
inner join products p on sk.product_id = p.product_id
where sk.quantity<3;

--3.4
--vw_StaffPerformance
create view vw_StaffPerformance 
as
select s.first_name, s.last_name,count(distinct o.order_id) as orders_handled , sum(quantity*list_price*(1-discount)) as revenue from staffs s
inner join orders o on s.staff_id = o.staff_id
inner join order_items oi on oi.order_id = o.order_id
group by s.first_name, s.last_name;
--3.5
--Abduvohid
--3.6
create view vw_SalesByCategory 
as
select 
	c.category_id,  
	c.category_name,
	cast(sum((p.list_price)*ot.quantity*(1-coalesce(ot.discount,0))) as DECIMAL(18, 2)) as total_sales,
	cast(sum((p.list_price*(1-coalesce(ot.discount,0))-p.cost_price)*ot.quantity) as DECIMAL(18, 2)) as total_profit,
	sum(ot.quantity) as count_sales,
	cast(sum((p.list_price*(1-coalesce(ot.discount,0))-p.cost_price)*ot.quantity)/sum((p.list_price)*ot.quantity*(1-coalesce(ot.discount,0)))*100 as DECIMAL(18, 2)) as per_marja
from categories c
inner join  products p on p.category_id = c.category_id 
inner join order_items ot on p.product_id = ot.product_id
group by c.category_id,  c.category_name;

--3.7
create view vw_CustomerSalesSummary 
as
select 
		c.customer_id,
		c.first_name, 
		c.last_name,
		cast(sum(oi.list_price*oi.quantity*(1- COALESCE(oi.discount, 0))) as DECIMAL(18, 2)) as Total_customer_sales,
		cast(sum(oi.list_price*oi.quantity*(1- COALESCE(oi.discount, 0)))/count(distinct o.order_id)as DECIMAL(18, 2)) as AOV_customers,
		sum(oi.quantity) as count_customer_sales,
		count(distinct o.order_id) as Count_orders   from customers c
inner join orders o on c.customer_id = o.customer_id
inner join order_items oi on oi.order_id = o.order_id 
group by c.customer_id, c.first_name, c.last_name;
--3.8
create view vw_store_stock_ratio 
as
with stock_cte as (
    select store_id, sum(cast(quantity as decimal(18,2))) as total_stock
    from stocks
    group by store_id
),
sales_cte as (
    select o.store_id, sum(cast(coalesce(oi.quantity,0) as decimal(18,2))) as total_sales
    from orders o
    inner join order_items oi on oi.order_id = o.order_id
    group by o.store_id
)
select 
    sr.store_name,
    coalesce(st.total_stock,0) as total_stock,
    coalesce(sa.total_sales,0) as total_sales,
    coalesce(st.total_stock,0) / nullif(coalesce(st.total_stock,0) + coalesce(sa.total_sales,0), 0) as stock_ratio
from stores sr
left join stock_cte st on sr.store_id = st.store_id
left join sales_cte sa on sr.store_id = sa.store_id;
--3.9
create view vw_MargeBySummary_Stores
as
select 
	s.store_id,  
	s.store_name,
	cast(sum((p.list_price)*ot.quantity*(1-coalesce(ot.discount,0))) as DECIMAL(18, 2)) as total_sales,
	cast(sum((p.list_price*(1-coalesce(ot.discount,0))-p.cost_price)*ot.quantity) as DECIMAL(18, 2)) as total_profit,
	sum(ot.quantity) as count_sales,
	cast(sum((p.list_price*(1-coalesce(ot.discount,0))-p.cost_price)*ot.quantity)/sum((p.list_price)*ot.quantity*(1-coalesce(ot.discount,0)))*100 as DECIMAL(18, 2)) as per_marja
from stores s
inner join orders o on s.store_id = o.store_id
inner join order_items ot on ot.order_id = o.order_id
inner join  products p on p.product_id = ot.product_id
group by s.store_id, s.store_name;

--3.10
create view vw_MargeBySummary_brands
as
select 
	b.brand_id, 
	brand_name,
	cast(sum((p.list_price)*oi.quantity*(1-coalesce(oi.discount,0))) as DECIMAL(18, 2)) as total_sales,
	cast(sum((p.list_price*(1-coalesce(oi.discount,0))-p.cost_price)*oi.quantity) as DECIMAL(18, 2)) as total_profit,
	sum(oi.quantity) as count_sales,
	cast(sum((p.list_price*(1-coalesce(oi.discount,0))-p.cost_price)*oi.quantity)/sum((p.list_price)*oi.quantity*(1-coalesce(oi.discount,0)))*100 as DECIMAL(18, 2)) as per_marja  
	from brands b
inner join products p on b.brand_id = p.brand_id
inner join order_items oi on oi.product_id = p.product_id
group by b.brand_id, brand_name;
--3.11
create view vw_staff_summary_sales
as
select 
		s.staff_id,
		s.first_name,
		s.last_name, 
		cast(sum(oi.list_price*oi.quantity*(1- oi.discount)) as decimal(18,2)) as total_staff_sales,
		count(distinct o.order_id) as count_orders
from staffs s
inner join orders o on o.staff_id = s.staff_id
inner join order_items oi on o.order_id = oi.order_id
group by s.staff_id,s.first_name,s.last_name;
