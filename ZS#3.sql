create materialized view mv_sales_summary
            build immediate
    refresh complete on demand
as
select p.productline,
       l.country,
       t.year,
       sum(s.sales)           as total_sales,
       sum(s.quantityordered) as total_quantity
from ZS2_SALES s
         join zs2_product p using (id_product)
         join zs2_location l using (id_location)
         join zs2_time t using (id_time)
group by p.productline, l.country, t.year;

select country, total_sales
from mv_sales_summary
where productline = 'Classic Cars'
order by total_sales desc;