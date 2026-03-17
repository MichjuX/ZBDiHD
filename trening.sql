
-- 1 Napisz funkcję, która wyznaczy wartość sprzedaży wszystkich zamówień danego klienta z podanego roku. Identyfikator klienta
-- oraz rok powinny stanowić parametry wejściowe funkcji. Wartość sprzedaży powinna być wyznaczona w oparciu o pola
-- Books.retail oraz Orderitems.quantity. Jeśli identyfikator klienta przekazany do funkcji będzie reprezentował klienta, którego nie
-- ma w bazie, wówczas funkcja powinna zwrócić NULL.

create or replace function f_client_sales(f_id_customer ORDERS.CUSTOMER#%type, f_year number)
    return number is f_sales number;
begin
    select sum(retail*QUANTITY)
    into f_sales
    from books b join orderitems oi on b.ISBN= oi.ISBN
    join orders o on o.ORDER#=oi.ORDER#
    where o.CUSTOMER#=f_id_customer and extract(year from o.ORDERDATE)=f_year;

    return f_sales;

    exception when no_data_found then return null;
end;

select f_client_sales(1005, 2005) from dual;


-- 2 Następnie napisz procedurę, która dopisze do tabeli Customer_statistics dla każdego klienta wartość jego zamówień w kolejnych
-- latach, w których składał zamówienia (Orders.ordertime). W tabeli Customer_statistics (definicja poniżej) powinno się znależd
-- imię i nazwisko klienta, rok oraz wartość jego zamówień. Wartość pola customerID jest automatycznie uzupełniana przez
-- wyzwalacz, który uruchamia się przy dodawianiu rekordu do tabeli. Skorzystaj z funkcji zaimplementowanej w 1

create or replace procedure p_customerStat_insert is
    cursor c1 is
    select distinct extract(year from ORDERDATE) as year, CUSTOMER# from orders;

    v_sale number;
    v_firstname varchar2(60);
    v_lastname varchar2(60);
begin
    for i in c1 loop
        v_sale:=f_client_sales(i.CUSTOMER#, i.year);

        select FIRSTNAME, LASTNAME
        into v_firstname, v_lastname
        from SIENKIEWICZ_MICHAL.CUSTOMERS
        where CUSTOMER#=i.CUSTOMER#;

        insert into CUSTOMER_STATISTICS (firstname, lastname, year, amount) values (v_firstname,
                                                                                                v_lastname, i.year, v_sale);
        end loop;
end;

begin
    p_customerStat_insert();
end;

commit;

rollback;

create table Customer_statistics(
    customerID NUMBER(6) primary key,
    firstname varchar2(60),
    lastname varchar2(60),
    year number(4),
    amount number,
    unique (customerID,year)
)

create sequence s_cs_id;

drop trigger t_cs_id;
create or replace trigger t_cs_id
    before insert on Customer_statistics for each row
    begin
        :new.customerid:=s_cs_id.nextval;
    end;

select * from CUSTOMER_STATISTICS;





create or replace function f_wejsc_1(f_year number, f_customer_id CUSTOMERS.CUSTOMER#%type)
    return number is f_return number;
    begin
        select sum(retail*quantity) as suma
        into f_return
        from orders o join orderitems oi on o.order#=oi.order#
        join books b on oi.ISBN=b.ISBN
        where extract(year from o.ORDERDATE) = f_year and o.CUSTOMER# = f_customer_id;

        return f_return;
    end;


create or replace procedure p_wejsc_1 is
    cursor c1 is
        select distinct extract(year from ORDERDATE) as year, CUSTOMER# from ORDERS;

        v_firstname varchar2(60);
        v_lastname varchar2(60);
        v_amount number;

    begin

        for i in c1 loop
                select f_wejsc_1(i.year, i.customer#)
                into v_amount from dual;

--             v_amount:=f_wejsc_1(i.year, i.customer#);

                select FIRSTNAME, LASTNAME into v_firstname, v_lastname from customers where CUSTOMER#=i.CUSTOMER#;

            insert into CUSTOMER_STATISTICS (firstname, lastname, year, amount) values (v_firstname, v_lastname, i.year, v_amount);
            end loop;
    end;

begin
    p_wejsc_1();
end;

truncate table CUSTOMER_STATISTICS;

commit;