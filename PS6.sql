-- Zadanie 1
-- Wyznacz ranking wydawców (podaj nazwę) w zależności od liczby książek, jaką opublikowali (tzn.
-- pierwszy na liście rankingowej powinien znaleźć się ten wydawca, który opublikował najwięcej książek).
-- Skorzystaj z funkcji RANK().

select p.name, count(distinct s.ISBN),
rank() over (order by count(distinct s.ISBN) desc) as rank
from V_SALE s join v_publisher p on p.PUBID = s.PUBID
group by p.name;


-- Zadanie 2
-- Rozwiąż Zadanie 1 zastępując funkcję RANK() funkcją DENSE_RANK(). Następnie wybierz tych
-- wydawców, którzy znaleźli się na pierwszym miejscu rankingu.

select *
from (
select p.name, count(distinct s.ISBN),
dense_rank() over (order by count(distinct s.ISBN) desc) as rank
from V_SALE s join v_publisher p on p.PUBID = s.PUBID
group by p.name)
where rank=1;

-- Zadanie 3
-- Dla każdego miasta klienta wyznacz liczbę sprzedanych książek. Podziel wynik zapytania wg liczby
-- sprzedanych książek rosnąco w oparciu o funkcję NTILE(N), gdzie N=2, 3, 4.

select c.city, sum(QUANTITY),
ntile(3) over (order by sum(QUANTITY) asc) as ntile
from v_sale s join v_customer c on c.CUSTOMER# = s.CUSTOMER#
group by c.city;

-- Zadanie 4
-- Dla każdego wydawcy i kolejnych miesięcy i lat (wyświetl miesiąc i rok) wyznacz zyski ze sprzedaży.
-- Wynik uporządkuj rosnąco wg daty. Dodatkowo wyznacz sumę narastającą dla zysków (wartość ta
-- powinna być wyznaczana w ramach danego wydawcy).

select p.NAME, t.ORDER_YEAR_MONTH, sum(SALE_AMOUNT),
       sum(sum(SALE_AMOUNT)) over (partition by p.NAME order by t.ORDER_YEAR_MONTH asc) as aaa
from V_SALE s join V_PUBLISHER p on p.PUBID = s.PUBID
join v_time t on s.ID_TIME = t.TIME_ID
group by p.NAME, t.ORDER_YEAR_MONTH
order by 1,2;

-- Zadanie 5
-- Zmodyfikuj Zadanie 4 zmieniając sumę narastającą na średnią kroczącą. Średnia krocząca powinna być
-- wyznaczona w oparciu o dwa wiersze poprzedzające dany wiersz i jeden wiersz następujący po danym
-- wierszu.



-- Zadanie 6
-- Zmodyfikuj Zadanie 4 zmieniając sumę narastającą na średnią centralną. Średnia centralna dla danej
-- grupy powinna być wyznaczona w oparciu o dwa wiersze poprzedzające dany wiersz i dwa wiersze
-- następujące po danym wierszu.


-- Zadanie 7
-- Dla każdej kategorii i każdego miesiąca roku 2005 wyznacz sumę sprzedanych książek (pole quantity).
-- Dodatkowo dodaj kolumnę, która zwróci średnią liczbę sprzedanych książek w danym miesiącu z
-- pominięciem kategorii. Skorzystaj z klauzuli PARTITION BY.


-- Zadanie 8
-- Dla każdego wydawcy wyznacz zyski ze sprzedaży.
-- Uporządkuj malejąco wynik zapytania wg wartości zysków.
-- Dodatkowo wyznacz dwie kolumny: (1) zwróci różnicę pomiędzy zyskami danego wydawcy i
-- wydawcy, który jest pierwszy na liście oraz (2) zwróci różnicę pomiędzy zyskami danego wydawcy i
-- wydawcy, który jest ostatni na liście. Skorzystaj z funkcji FIRST_VALUE(), LAST_VALUE().

select p.name, sum(s.profit),
       sum(s.profit) - (first_value(sum(s.profit)) over (order by 2 desc)),
       sum(s.profit) - (last_value(sum(s.profit)) over (order by 2 desc))
from v_sale s join v_publisher p on s.pubid = p.pubid
group by p.name
order by 2 desc;

-- Zadanie 9
-- Dla każdej kategorii wyznacz jej udział w całkowitych zyskach ze sprzedaży w roku 2005. Skorzystaj z
-- funkcji RATIO_TO_REPORT().
--
-- Następnie dodaj do zapytania wymiar czasu (miesiąc) i wyznacz udział
-- w zyskach ze sprzedaży dla każdej kategorii niezależnie dla każdego miesiąca.

select b.category, round(ratio_to_report(sum(s.profit)) over (), 2) as udzial
from v_sale s join v_book b on s.isbn = b.isbn
group by b.category;

select b.category, t.ORDER_MONTH_NUMBER,
       round(ratio_to_report(sum(s.profit)) over (), 2) as udzial,
       round(ratio_to_report(sum(s.profit)) over (partition by t.ORDER_MONTH_NUMBER), 2) as udzial_w_mies
from v_sale s join v_book b on s.isbn = b.isbn
    join v_time t on s.ID_TIME = t.TIME_ID
where t.ORDER_YEAR_NUMBER = 2005
group by b.category, t.ORDER_MONTH_NUMBER
order by 2;

-- Zadanie 10
-- Dla każdego każdego roku wyznacz wartość sprzedaży. Dodatkowo dodaj dwie kolumny, które zwrócą
-- różnicę pomiędzy wartością sprzedaży w danym roku a wartością sprzedaży
-- (1) dwa lata wcześniej oraz
-- (2) dwa lata później.
-- Skorzystaj z funkcji LAG() oraz LEAD().
-- Zmodyfikuj następnie zapytanie ograniczając działanie funkcji LAG() oraz LEAD() do konkretnej kategorii.

select t.order_year_number,
       sum(s.sale_amount) as wart_sprzed,
       sum(s.sale_amount) - (lag(sum(s.SALE_AMOUNT)) over (order by t.ORDER_YEAR_NUMBER)) diff_przed2,
       sum(s.sale_amount) - (lead(sum(s.SALE_AMOUNT)) over (order by t.ORDER_YEAR_NUMBER)) diff_po2
from v_sale s join v_time t on s.ID_TIME = t.TIME_ID
group by t.order_year_number
order by 1;

-- Zadanie 11
-- Dla każdego roku wysyłki wyznacz liczbę zamówionych książek. Następnie dodaj numer wiersza
-- (ROW_NUMBER()) umieszczając wiersze z wartością nieokreśloną na początku wyniku zapytania.

select
    row_number() over (order by extract(year from o.shipdate) nulls first) rn,
    extract(year from o.shipdate) rok,
    sum(oi.QUANTITY)
from ORDERITEMS oi join orders o using(order#)
group by extract(year from o.shipdate)
order by 1;

-- Zadanie 12
-- Dla każdego każdego roku wyznacz ranking wydawców względem liczby sprzedanych książek (rosnący).
-- Następnie dodaj do zapytania funkcję PERCENT_RANK() dla tego rankingu.

select t.order_year_number,
    p.name,
    sum(s.QUANTITY),
    percent_rank() over (partition by t.ORDER_YEAR_NUMBER order by sum(s.QUANTITY)) pr
from V_SALE s join v_publisher p using(pubid)
    join v_time t on s.ID_TIME = t.TIME_ID
group by t.order_year_number, p.name
order by 1, 4 desc;

-- Zadanie 13
-- Zmodyfikuj Zadanie 11 zmieniając funkcję PERCENT_RANK() na funkcję CUME_DIST().

select t.order_year_number,
    p.name,
    sum(s.QUANTITY),
    cume_dist() over (partition by t.ORDER_YEAR_NUMBER order by sum(s.QUANTITY)) pr
from V_SALE s join v_publisher p using(pubid)
    join v_time t on s.ID_TIME = t.TIME_ID
group by t.order_year_number, p.name
order by 1, 4 desc;


-- Z ZAJEĆ OD BABKI
--Zadanie 1
SELECT P.NAME, COUNT(distinct(s.isbn)),
RANK() OVER (Order by COUNT(distinct(s.isbn)) desc ) as rank
FROM v_SALE s  JOIN v_publisher p on p.pubid= s.pubid
group by p.name;

--Zadanie 2

select *
From(
SELECT P.NAME, COUNT(distinct(s.isbn)),
Dense_RANK() OVER (Order by COUNT(distinct(s.isbn)) desc ) as rank
FROM v_SALE s  JOIN v_publisher p on p.pubid= s.pubid
group by p.name) x
where x.rank=1;

--Zadanie 3
select c.city, sum(s.quantity),
NTile(20) OVER (order by sum(s.quantity) asc ) as ntile
from V_Sale s join V_Customer c on c.customer# = s.customer#
Group by c.city;

--Zadanie 4

select p.name,t.year_month, sum(s.profit),
sum(sum(s.profit)) over (partition by p.name  order by t.year_month asc) as SumRos
FROM v_SALE s  JOIN v_publisher p on p.pubid= s.pubid
            join v_time t on s.id_time = t.id_time
Group by p.name,t.year_month
order by 1,2;

--Zadanie 5
select p.name,t.year_month, sum(s.profit),
round(avg(sum(s.profit)) over (partition by p.name  order by t.year_month asc
    rows between 2 preceding and 1 following),2) as SumRos
FROM v_SALE s  JOIN v_publisher p on p.pubid= s.pubid
            join v_time t on s.id_time = t.id_time
Group by p.name,t.year_month
order by 1,2;

--Zadanie 6
select p.name,t.year_month, sum(s.profit),
round(avg(sum(s.profit)) over (partition by p.name  order by t.year_month asc
    rows between 2 preceding and 2 following),2) as SumRos
FROM v_SALE s  JOIN v_publisher p on p.pubid= s.pubid
            join v_time t on s.id_time = t.id_time
Group by p.name,t.year_month
order by 1,2;

--Zadanie 7
select b.category, t.month_number, sum(s.quantity),
round(avg(sum(s.quantity)) over (partition by t.month_number),2) as sale
from v_sale s join v_time t on s.id_time = t.id_time
    join v_book b on b.isbn = s.isbn
where t.year_number = 2005
group by b.category, t.month_number;

-- Zadanie 8
SELECT
    p.name,
    SUM(s.profit),
    SUM(s.profit) - (FIRST_VALUE(SUM(s.profit)) OVER (ORDER BY 2 DESC)),
    SUM(s.profit) - (LAST_VALUE(SUM(s.profit)) OVER (ORDER BY 2 DESC))
FROM V_SALE s JOIN V_PUBLISHER p ON s.pubid = p.pubid
GROUP BY p.name
ORDER BY 2 DESC;

-- Zadanie 9
SELECT
    b.category,
    t.month_number,
    SUM(s.profit),
    ROUND(RATIO_TO_REPORT(SUM(s.profit)) OVER (), 2) udzial,
    ROUND(RATIO_TO_REPORT(SUM(s.profit)) OVER (PARTITION BY t.month_number), 2) udzial_w_mies
FROM V_SALE s JOIN V_BOOK b ON s.isbn = b.isbn JOIN V_TIME t ON s.id_time = t.id_time
WHERE t.year_number = 2005
GROUP BY b.category, t.month_number
ORDER BY 2;

-- Zadanie 10
SELECT
    t.year_number,
    sum(s.sale_amount) wart_sprzed,
    sum(s.sale_amount) - (LAG(sum(s.sale_amount), 2) OVER (ORDER BY t.year_number)) diff_przed2,
    sum(s.sale_amount) - (LEAD(sum(s.sale_amount), 2) OVER (ORDER BY t.year_number)) diff_po2
FROM v_sale s JOIN v_time t USING (id_time)
GROUP BY t.year_number
ORDER BY 1;

-- Zadanie 11
SELECT
    ROW_NUMBER() OVER (ORDER BY EXTRACT(YEAR FROM o.shipdate) NULLS FIRST) nr,
    EXTRACT(YEAR FROM o.shipdate) rok,
    SUM(oi.quantity)
FROM ORDERITEMS oi join ORDERS o USING(ORDER#)
GROUP BY EXTRACT(YEAR FROM o.shipdate)
ORDER BY 1
;

-- Zadanie 12
SELECT t.year_number, p.name, SUM(s.quantity),
PERCENT_RANK() OVER (PARTITION BY t.year_number ORDER BY SUM(s.quantity)) rank
FROM V_SALE s JOIN V_TIME t USING(id_time) JOIN V_PUBLISHER p USING(pubid)
GROUP BY t.year_number, p.name
ORDER BY 1 asc, 4 desc;

-- Zadanie 13
SELECT t.year_number, p.name, SUM(s.quantity),
CUME_DIST() OVER (PARTITION BY t.year_number ORDER BY SUM(s.quantity)) rank
FROM V_SALE s JOIN V_TIME t USING(id_time) JOIN V_PUBLISHER p USING(pubid)
GROUP BY t.year_number, p.name
ORDER BY 1 asc, 4 desc;