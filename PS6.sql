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

select p.NAME, t.ORDER_MONTH_NAME, t.ORDER_YEAR_NUMBER, sum(SALE_AMOUNT)
from V_SALE s join V_PUBLISHER p on p.PUBID = s.PUBID
join v_time t on s.ID_TIME = t.TIME_ID
group by p.NAME, t.ORDER_MONTH_NAME, t.ORDER_YEAR_NUMBER;

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
-- Dla każdego wydawcy wyznacz zyski ze sprzedaży. Uporządkuj malejąco wynik zapytania wg wartości
-- zysków. Dodatkowo wyznacz dwie kolumny: (1) zwróci różnicę pomiędzy zyskami danego wydawcy i
-- wydawcy, który jest pierwszy na liście oraz (2) zwróci różnicę pomiędzy zyskami danego wydawcy i
-- wydawcy, który jest ostatni na liście. Skorzystaj z funkcji FIRST_VALUE(), LAST_VALUE().


-- Zadanie 9
-- Dla każdej kategorii wyznacz jej udział w całkowitych zyskach ze sprzedaży w roku 2005. Skorzystaj z
-- funkcji RATIO_TO_REPORT(). Następnie dodaj do zapytania wymiar czasu (miesiąc) i wyznacz udział
-- w zyskach ze sprzedaży dla każdej kategorii niezależnie dla każdego miesiąca.


-- Zadanie 10
-- Dla każdego każdego roku wyznacz wartość sprzedaży. Dodatkowo dodaj dwie kolumny, które zwrócą
-- różnicę pomiędzy wartością sprzedaży w danym roku a wartością sprzedaży (1) dwa lata wcześniej oraz (2)
-- dwa lata później. Skorzystaj z funkcji LAG() oraz LEAD().
-- Zmodyfikuj następnie zapytanie ograniczając działanie funkcji LAG() oraz LEAD() do konkretnej
-- kategorii.


-- Zadanie 11
-- Dla każdego roku wysyłki wyznacz liczbę zamówionych książek. Następnie dodaj numer wiersza
-- (ROW_NUMBER()) umieszczając wiersze z wartością nieokreśloną na początku wyniku zapytania.


-- Zadanie 12
-- Dla każdego każdego roku wyznacz ranking wydawców względem liczby sprzedanych książek (rosnący).
-- Następnie dodaj do zapytania funkcję PERCENT_RANK() dla tego rankingu.


-- Zadanie 13
-- Zmodyfikuj Zadanie 11 zmieniając funkcję PERCENT_RANK() na funkcję CUME_DIST().
