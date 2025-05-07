--5 KPI
--5.1
select sum(Revenue) as Total_Revenue from vw_StoreSalesSummary;
--5.2
select customer_id, first_name, last_name, AOV_customers,Count_orders from vw_CustomerSalesSummary 
order by AOV_customers desc;
--5.3
select store_name, stock_ratio from vw_store_stock_ratio 
order by stock_ratio
--5.4
select store_name, total_sales, cast((total_sales/sum(total_sales) over())*100 as decimal(18,2)) as sales_contribution_pct   from vw_MargeBySummary_Stores
order by total_sales;
--5.5
select store_name, total_profit, cast((total_profit/sum(total_profit) over())*100 as decimal(18,2)) as profit_contribution_pct   from vw_MargeBySummary_Stores
order by total_profit;
--5.6
select * from vw_MargeBySummary_brands
order by total_profit desc;
--5.7
select * from vw_staff_summary_sales
order by total_staff_sales desc, count_orders desc;
