create sequence s_id_zip;

create trigger t_id_zip
    before insert on zip for each row
    begin
        :new.id_zip=s_id_zip.nextval;
    end;

drop trigger t_id_zip;

create or replace procedure