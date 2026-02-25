
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

    foreign key (id_zip) references zip(id_zip),
    foreign key (id_time) references time(id_time)
);

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

create or replace procedure proc_zip_insert is
        cursor c_zip is
            select distinct zip, state
            from customers
            order by state, zip;

    begin
--         for each row c_zip insert into zip(zipcode, state) values
        for i in c_zip loop
            insert into zip(state, zipcode) values (i.state, i.zip);
        end loop;
    end;

begin
proc_zip_insert;
end;

select distinct zip, state
from customers
order by state, zip; -- opcjonalnie order by

commit;