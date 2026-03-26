create or replace view v_publisher as select * from publisher;

create or replace view v_book as select * from books;

create or replace view v_author as select * from author;

create or replace view v_time as select * from d_time;
drop view v_time;

create or replace view v_customer as select * from customers;

create or replace view v_sale as
select
    t.time_id as id_time,
    b.pubid,
    oi.isbn,
    o.customer#,
    min(ba.authorid) as authorid, -- bierzemy tylko jednego autora, aby nie powielać wierszy
    sum(oi.quantity) as quantity,
    sum(oi.quantity * (b.retail - b.cost)) as profit,
    sum(oi.quantity * b.retail) as sale_amount
from orders o
join orderitems oi on o.order# = oi.order#
join books b on oi.isbn = b.isbn
join bookauthor ba on b.isbn = ba.isbn
join d_time t on o.orderdate = t.orderdate
group by
    t.time_id,
    b.pubid,
    oi.isbn,
    o.customer#;
drop view v_sale;

-- Zadanie 2

select name, count(isbn) as book_count, avg(retail) as avg_price
from v_publisher join v_book using (pubid)
group by name
union all
select null, count(isbn), avg(retail)
from v_book;

select name, count(isbn) as book_count, avg(retail) as avg_price
from v_publisher join v_book using (pubid)
group by grouping sets ((name), ());

select name, count(isbn) as book_count, avg(retail) as avg_price
from v_publisher join v_book using (pubid)
group by rollup (name);


-- Zadanie 3
select c.firstname, c.lastname, t.ORDER_YEAR_MONTH, sum(s.SALE_AMOUNT) sale_amount
from v_time t join v_sale s on t.time_id = s.id_time
join v_customer c on c.customer# = s.customer#
group by grouping sets(( c.CUSTOMER#, c.firstname, c.lastname, t.ORDER_YEAR_MONTH), ( c.CUSTOMER#, c.firstname, c.lastname), ());


-- Zadanie 4
select b.category, t.ORDER_DAY_OF_MONTH, sum(s.profit) profit
from v_time t join v_sale s on t.time_id=s.id_time
    join v_book b on b.isbn=s.isbn
where t.ORDER_YEAR_MONTH='2005-04'
group by grouping sets ( (t.ORDER_DAY_OF_MONTH, b.category), b.CATEGORY);

-- Zadanie 5
select a.FNAME, a.LNAME, t.ORDER_YEAR_NUMBER,
       sum(s.quantity) quantity, sum(s.SALE_AMOUNT) amount
from v_time t join v_sale s on t.time_id=s.id_time
    join v_author a on a.authorid=s.authorid
group by rollup (( a.AUTHORID ,a.FNAME, a.LNAME), t.ORDER_YEAR_NUMBER);

-- Zadanie 6
select t.ORDER_DAY_NAME, c.city, c.state, sum(s.quantity) quantity
from v_time t join v_sale s on t.time_id=s.id_time
    join v_customer c on c.CUSTOMER#=s.customer#
where ORDER_YEAR_MONTH = '2010-06'
group by cube (t.ORDER_DAY_NAME, c.city, c.state)
order by 1,2,3

-- Zadanie 7





