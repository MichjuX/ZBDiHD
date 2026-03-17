create table sales_info
(
    saleinfo_id number primary key,
    orderdate date,
    shipdate date,
    order_day_name     varchar2(10),
    ship_day_name     varchar2(10),
    order_day_of_week  number,
    ship_day_of_week  number,
    order_day_of_month number,
    ship_day_of_month number,
    order_year_month   char(7),
    ship_year_month   char(7),
    order_week_of_year number,
    ship_week_of_year number,
    order_day_of_year  number,
    ship_day_of_year  number,
    order_is_weekend   number(1),
    ship_is_weekend   number(1),
    order_month_name   varchar2(10),
    ship_month_name   varchar2(10),
    order_month_number number,
    ship_month_number number,
    order_quarter      number,
    ship_quarter      number,
    order_year_number  number,
    ship_year_number  number
);

create sequence s_saleInfo;

create or replace trigger s_saleInfo_id
    before insert on sales_info for each row
    begin
    :new.saleinfo_id:=s_saleInfo.nextval;
    end;

create or replace procedure insert_sale_info is
    cursor c1 is
        select distinct orderdate, shipdate
        from ORDERS;

    begin
        for i in c1 loop

            insert into sales_info (orderdate, shipdate, order_day_name, ship_day_name, order_day_of_week,
                                    ship_day_of_week, order_day_of_month, ship_day_of_month, order_year_month,
                                    ship_year_month, order_week_of_year, ship_week_of_year, order_day_of_year,
                                    ship_day_of_year, order_is_weekend, ship_is_weekend, order_month_name,
                                    ship_month_name, order_month_number, ship_month_number, order_quarter,
                                    ship_quarter, order_year_number, ship_year_number)
            values (i.ORDERDATE, i.SHIPDATE,
                    to_char(i.orderdate, 'Day'), to_char(i.SHIPDATE, 'Day'),
                    to_char(i.ORDERDATE, 'D'), to_char(i.SHIPDATE, 'D'),
                    extract(day from i.ORDERDATE),
                    extract(day from i.SHIPDATE),
                    to_char(i.ORDERDATE, 'YYYY-MM'),
                    to_char(i.SHIPDATE, 'YYYY-MM'),
                    to_char(i.ORDERDATE, 'IW'),
                    to_char(i.SHIPDATE, 'IW'),
                    to_char(i.)
                   )
        end loop;
    end;