
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

-- dla sale
create trigger t_set_id_sale
before insert on sale for each row
begin
    :new.id_sale:=seq_id_sale.nextval;
end;


-- zadanie 3
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


















