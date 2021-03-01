drop table client_dim_l2;
drop table budget_type_dim_l2;
drop table client_fact_l2;
drop table client_tempfact_l2;
create table client_dim_l2 as select distinct person_id from monre.client;
create table budget_type_Dim_l2 (
budget_id varchar(10),
budget_description varchar(20)
);
insert into budget_type_Dim_l2 values('Low','0-1000');
insert into budget_type_Dim_l2 values('Medium','1001-100000');
insert into budget_type_Dim_l2 values('High','100001-10000000');

create table client_wishlist_dim_l2 as select * from MONRE.client_wish;

create table client_tempfact_l2 as select person_id,max_budget from monre.client;

alter table client_tempfact_l2 add budget_id varchar(10);

update client_tempfact_l2 set budget_id='Low' where max_budget between 0 and 1000;
update client_tempfact_l2 set budget_id='Medium' where max_budget between 1001 and 100000;
update client_tempfact_l2 set budget_id='High' where max_budget between 100001 and 10000000;

select * from client_tempfact_l2;

create table client_fact_l2 as select person_id,budget_id,count(person_id) "Number of Clients" from 
client_tempfact_l2 group by person_id,budget_id;

commit;

select sum("Number of Clients"),budget_id from client_fact_l2 where budget_id='High' group by budget_id;


