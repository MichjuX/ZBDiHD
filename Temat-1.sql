
create table time(
    id_time number(3) primary key,
    month number(2),
    year number(4)
);

create table zip(
    id_zip number(5) primary key,
    zipcode varchar2(5) not null,
    state varchar2(2)

);

create table sale(
    id_sale number(8) primary key,
    id_zip number(5) not null,
    id_time number(5) not null,
    sale number(5),

    foreign key (id_zip) references zip(id_zip),
    foreign key (id_time) references time(id_time)
);

drop table sale;

create table profit_by_state(
    state varchar2(2) primary key,
    profit number(8)
);

-- Zadanie 2

create sequence seq_id_zip;
create sequence seq_id_time;
create sequence seq_id_sale;

create trigger t_set_id_zip
    before insert on zip for each row
    begin
        :new.id_zip:=seq_id_zip.nextval;
        -- :new odwołujemy sie do wartości kolumn polecenia które aktywowało te wyzwalacz
    end;
-- ten trigger (wyzwalacz) wyżej jest wywoływany np. z tym poleceniem niżej

insert into zip(zipcode, state) values ('15217', 'PA');

select * from zip;

-- dla time
create or replace trigger t_set_id_time
    before insert on time for each row
    begin
        :new.id_time:=seq_id_time.nextval;
    end;

-- dla zip

-- dla sale
create trigger t_set_id_sale
before insert on sale for each row
begin
    :new.id_sale:=seq_id_sale.nextval;
end;


-- zadanie 3
-- Utwórz pakiet składający się z następujących elementów:
-- (a) procedury, która w oparciu o tabele ze schematu zamieszczonego w Dodatku, przepisze odpowiednio
-- dane do tabel utworzonych w Zadaniu 1. Wartość sprzedaży w tabeli Sale powinna być wyznaczana w
-- oparciu o pola retail i quantity. Z kolei wartość kolumn miesiąc i rok w tabeli Time powinny
-- być wyznaczone w oparciu o pole orderdate z tabeli Orders. Uwaga: pamiętaj o wykorzystaniu
-- sekwencji do generowania kluczy głównych tabel;


-- create package pack_;

-- dla zipa
create or replace procedure proc_zip_insert is
        cursor c_zip is
            select distinct zip, state
            from customers
            order by state, zip; -- opcjonalnie order by

    begin
--         for each row c_zip insert into zip(zipcode, state) values
        for i in c_zip loop
            insert into zip(state, zipcode) values (i.state, i.zip);
        end loop;
    end;

begin
proc_zip_insert;
end;

-- dla time
create or replace procedure proc_time_insert is
    cursor c_time is
        select distinct extract(month from orderdate) as month,
                        extract(year from orderdate) as year
        from orders
        order by 2, 1;
begin
    for i in c_time loop
            insert into time(month, year) values (i.month, i.year);
        end loop;
end;

select distinct extract(month from orderdate) as month,
                extract(year from orderdate) as year
from orders
order by 2, 1;

commit;

begin
    proc_time_insert();
end;
-- dla sale
-- create procedure proc_sale_insert is
--     cursor c_sale is
select * from time;


create or replace procedure proc_sale_insert is
    cursor c_sale is
        select z.id_zip, t.id_time, sum(b.retail*oi.quantity) as sale
        -- from zip z, time t, books b, orderitems oi, orders o, customers c
        from zip z join customers c on c.zip=z.zipcode and c.STATE=z.STATE
        join orders o on o.CUSTOMER#=c.CUSTOMER#
        join orderitems oi on o.ORDER#=oi.ORDER#
        join books b on b.ISBN=oi.ISBN
        join time t on t.month=extract(month from o.ORDERDATE) and t.year=extract(year from o.ORDERDATE)
        group by z.id_zip, t.id_time;
begin
    for i in c_sale loop
        insert into sale(id_zip, id_time, sale) values (i.id_zip, i.id_time, i.sale);
        end loop;
end;

begin
    proc_sale_insert();
end;

commit;
truncate table sale;
truncate table time;

-- (b) funkcji, która dla danego stanu (parametr wejściowy funkcji) wyznaczy wartość zysku ze sprzedaży.
-- Jeśli parametr wejściowy będzie opisywał stan, który nie występuje w bazie, wówczas funkcja powinna
-- zwrócić NULL;

create or replace function fun_calc_sale(f_state CUSTOMERS.STATE%type)
    return number is f_sale number;
begin
    select sum(RETAIL*QUANTITY) into f_sale
    from customers c join orders o on c.CUSTOMER#=o.CUSTOMER#
                     join orderitems oi on oi.ORDER#=o.ORDER#
                     join books b on b.ISBN=oi.ISBN
    where c.STATE=f_state;

    return f_sale;
exception
    when NO_DATA_FOUND then
        return null;
end;

select fun_calc_sale('FL')
from dual;

-- (c) procedury, która załaduje do tabeli PROFIT_BY_STATE dane w oparciu o funkcję
-- zaimplementowaną w podpunkcie (b). Do tabeli powinny być dopisane stany, z których pochodzą klienci
-- (Customers.state) oraz zysk. Wiersz do tabeli PROFIT_BY_STATE powinien być dopisany tylko wtedy,
-- jeśli zysk ma wartość określoną (nie jest NULL).
-- Wywołaj procedury i funkcję pakietu.

create or replace procedure proc_pbs_insert is
--     cursor c_pbs is
--         select fun_calc_sale(f_state) from dual;
    cursor c_states is
        select distinct state from SIENKIEWICZ_MICHAL.CUSTOMERS;
    v_sale number;
begin

     for i in c_states loop
         v_sale := fun_calc_sale(i.STATE);

         if v_sale is not null then
             insert into PROFIT_BY_STATE (state, profit) values (i.STATE, v_sale);
         end if;

    end loop;
end;

begin
    proc_pbs_insert();
end;

commit;


-- FINALNY PAKIET DO ZADANIA 3

create or replace package pack_sales as
    procedure proc_zip_insert;
    procedure proc_time_insert;
    procedure proc_sale_insert;

    function proc_pbs_insert(f_state customers.STATE%type) return number;

    procedure pack_sales_run_all;

end pack_sales;

create or replace package body pack_sales as

    procedure proc_zip_insert is
        cursor c_zip is
            select distinct zip, state
            from customers
            order by state, zip; -- opcjonalnie order by

    begin
        --         for each row c_zip insert into zip(zipcode, state) values
        for i in c_zip loop
                insert into zip(state, zipcode) values (i.state, i.zip);
            end loop;
    end;

    procedure proc_time_insert is
        cursor c_time is
            select distinct extract(month from orderdate) as month,
                            extract(year from orderdate) as year
            from orders
            order by 2, 1;
    begin
        for i in c_time loop
                insert into time(month, year) values (i.month, i.year);
            end loop;
    end;

    procedure proc_sale_insert is
        cursor c_sale is
            select z.id_zip, t.id_time, sum(b.retail*oi.quantity) as sale
            -- from zip z, time t, books b, orderitems oi, orders o, customers c
            from zip z join customers c on c.zip=z.zipcode and c.STATE=z.STATE
                       join orders o on o.CUSTOMER#=c.CUSTOMER#
                       join orderitems oi on o.ORDER#=oi.ORDER#
                       join books b on b.ISBN=oi.ISBN
                       join time t on t.month=extract(month from o.ORDERDATE) and t.year=extract(year from o.ORDERDATE)
            group by z.id_zip, t.id_time;
    begin
        for i in c_sale loop
                insert into sale(id_zip, id_time, sale) values (i.id_zip, i.id_time, i.sale);
            end loop;
    end;

    function fun_calc_sale(f_state CUSTOMERS.STATE%type)
        return number is f_sale number;
    begin
        select sum(RETAIL*QUANTITY) into f_sale
        from customers c join orders o on c.CUSTOMER#=o.CUSTOMER#
                         join orderitems oi on oi.ORDER#=o.ORDER#
                         join books b on b.ISBN=oi.ISBN
        where c.STATE=f_state;

        return f_sale;
    exception
        when NO_DATA_FOUND then
            return null;
    end;

    procedure proc_pbs_insert is
    --     cursor c_pbs is
    --         select fun_calc_sale(f_state) from dual;
        cursor c_states is
    select distinct state from SIENKIEWICZ_MICHAL.CUSTOMERS;
    v_sale number;
    begin

        for i in c_states loop
                v_sale := fun_calc_sale(i.STATE);

                if v_sale is not null then
                    insert into PROFIT_BY_STATE (state, profit) values (i.STATE, v_sale);
                end if;

            end loop;
    end;

    procedure pack_sales_run_all is
    begin
        proc_zip_insert();
        proc_time_insert();
        proc_sale_insert();
        proc_pbs_insert();
        commit;
    end;
end pack_sales;

-- Zadanie 4
-- Utwórz wyzwalacz, który będzie kontrolował wartości kolumn retail i cost w tabeli books.
-- Wyzwalacz powinien się uruchamiać w momencie modyfikacji wartości tych kolumn, jak również przy
-- dodawaniu rekordu do tabeli books. Wartość w kolumnie retail powinna być co najwyżej dwa razy
-- wyższa niż wartość kolumny cost. Np. jeśli wartość retail wynosi 10, a wartość cost wynosi 4
-- wówczas wyzwalacz powinien zmienić wartość retail na wartość równą 8.

create or replace trigger t_control_books
before
insert or update of retail, cost on BOOKS
begin
    if :new.retail > 2*:new.cost then
        :new.retail := 2*new.COST;
    end if;
end;




















