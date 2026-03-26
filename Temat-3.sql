DROP TABLE d_time CASCADE CONSTRAINTS;
DROP SEQUENCE s_d_time;

-- 2. TWORZENIE TABELI
CREATE TABLE d_time (
    time_id            NUMBER PRIMARY KEY,
    orderdate          DATE,
    shipdate           DATE,
    order_day_name     VARCHAR2(15),
    ship_day_name      VARCHAR2(13),
    order_day_of_week  NUMBER,
    ship_day_of_week   NUMBER,
    order_day_of_month NUMBER,
    ship_day_of_month  NUMBER,
    order_year_month   CHAR(7),
    ship_year_month    CHAR(7),
    order_week_of_year NUMBER,
    ship_week_of_year  NUMBER,
    order_day_of_year  NUMBER,
    ship_day_of_year   NUMBER,
    order_is_weekend   NUMBER(1),
    ship_is_weekend    NUMBER(1),
    order_month_name   VARCHAR2(10),
    ship_month_name    VARCHAR2(10),
    order_month_number NUMBER,
    ship_month_number  NUMBER,
    order_quarter      NUMBER,
    ship_quarter       NUMBER,
    order_year_number  NUMBER,
    ship_year_number   NUMBER
);

-- 3. TWORZENIE SEKWENCJI
CREATE SEQUENCE s_d_time START WITH 1 INCREMENT BY 1;

-- 4. TWORZENIE TRIGGERA (Automatyczne nadawanie ID)
CREATE OR REPLACE TRIGGER t_d_time
    BEFORE INSERT ON d_time
    FOR EACH ROW
BEGIN
    IF :new.time_id IS NULL THEN
        :new.time_id := s_d_time.NEXTVAL;
    END IF;
END;
/

-- 5. TWORZENIE PROCEDURY
CREATE OR REPLACE PROCEDURE insert_d_time IS
    CURSOR c1 IS
        SELECT DISTINCT orderdate, shipdate
        FROM ORDERS
        WHERE orderdate IS NOT NULL; -- SHIPDATE może być NULL, obsłużymy to niżej
BEGIN
    FOR i IN c1 LOOP
        INSERT INTO d_time (
            orderdate, shipdate,
            order_day_name, ship_day_name,
            order_day_of_week, ship_day_of_week,
            order_day_of_month, ship_day_of_month,
            order_year_month, ship_year_month,
            order_week_of_year, ship_week_of_year,
            order_day_of_year, ship_day_of_year,
            order_is_weekend, ship_is_weekend,
            order_month_name, ship_month_name,
            order_month_number, ship_month_number,
            order_quarter, ship_quarter,
            order_year_number, ship_year_number
        )
        VALUES (
            i.ORDERDATE, i.SHIPDATE,
            -- Nazwy dni
            TRIM(TO_CHAR(i.ORDERDATE, 'Day', 'NLS_DATE_LANGUAGE=POLISH')),
            TRIM(TO_CHAR(i.SHIPDATE, 'Day', 'NLS_DATE_LANGUAGE=POLISH')),
            -- Dzień tygodnia
            TO_NUMBER(TO_CHAR(i.ORDERDATE, 'D')),
            TO_NUMBER(TO_CHAR(i.SHIPDATE, 'D')),
            -- Dzień miesiąca
            EXTRACT(DAY FROM i.ORDERDATE),
            CASE WHEN i.SHIPDATE IS NOT NULL THEN EXTRACT(DAY FROM i.SHIPDATE) ELSE NULL END,
            -- Rok-Miesiąc
            TO_CHAR(i.ORDERDATE, 'YYYY-MM'),
            TO_CHAR(i.SHIPDATE, 'YYYY-MM'),
            -- Tydzień roku
            TO_NUMBER(TO_CHAR(i.ORDERDATE, 'IW')),
            TO_NUMBER(TO_CHAR(i.SHIPDATE, 'IW')),
            -- Dzień roku
            TO_NUMBER(TO_CHAR(i.ORDERDATE, 'DDD')),
            TO_NUMBER(TO_CHAR(i.SHIPDATE, 'DDD')),
            -- Czy weekend (sobota=6, niedziela=7 w ISO)
            CASE WHEN TO_CHAR(i.ORDERDATE, 'D') IN ('6', '7') THEN 1 ELSE 0 END,
            CASE WHEN TO_CHAR(i.SHIPDATE, 'D') IN ('6', '7') THEN 1 ELSE 0 END,
            -- Nazwa miesiąca
            TRIM(TO_CHAR(i.ORDERDATE, 'Month', 'NLS_DATE_LANGUAGE=POLISH')),
            TRIM(TO_CHAR(i.SHIPDATE, 'Month', 'NLS_DATE_LANGUAGE=POLISH')),
            -- Numer miesiąca
            EXTRACT(MONTH FROM i.ORDERDATE),
            CASE WHEN i.SHIPDATE IS NOT NULL THEN EXTRACT(MONTH FROM i.SHIPDATE) ELSE NULL END,
            -- Kwartał
            TO_NUMBER(TO_CHAR(i.ORDERDATE, 'Q')),
            TO_NUMBER(TO_CHAR(i.SHIPDATE, 'Q')),
            -- Rok
            EXTRACT(YEAR FROM i.ORDERDATE),
            CASE WHEN i.SHIPDATE IS NOT NULL THEN EXTRACT(YEAR FROM i.SHIPDATE) ELSE NULL END
        );
    END LOOP;
    COMMIT;
END;
/

-- 6. URUCHOMIENIE PROCEDURY
BEGIN
    insert_d_time();
END;
/

-- 7. SPRAWDZENIE WYNIKÓW
SELECT * FROM d_time;