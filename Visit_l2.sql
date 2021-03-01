create table season_dim_l2(
season_id varchar(10),
interval varchar(20)
);

insert into season_dim_l2 values('Summer','dec-feb');
insert into season_dim_l2 values('Autumn','mar-may');
insert into season_dim_l2 values('Winter','jun-aug');
insert into season_dim_l2 values('Spring','sep-nov');

create table visit_dim_scd_l2 as select client_person_id,property_id,visit_date from monre.visit;

drop table visit_dim_l2;
create table visit_dim_l2 as select distinct property_id from monre.visit;

create table visit_tempfact_l2 as select client_person_id,property_id,visit_date from monre.visit;

alter table visit_tempfact_l2 add season_id varchar(10);
update visit_tempfact_l2 set season_id ='Summer' where to_char(visit_date,'mon') in ('dec','jan','feb');
update visit_tempfact_l2 set season_id ='Autumn' where to_char(visit_date,'mon') in ('mar','apr','may');
update visit_tempfact_l2 set season_id ='Winter' where to_char(visit_date,'mon') in ('jun','jul','aug');
update visit_tempfact_l2 set season_id ='Spring' where to_char(visit_date,'mon') in ('sep','oct','nov');

drop table visit_fact_l2;
create table visit_fact_l2 as select property_id,season_id,count(visit_date) "Total number of Visits" from visit_tempfact_l2 group by property_id,season_id;

select sum("Total number of Visits") "Total number of Visits",season_id from visit_fact_l2 where season_id='Autumn' group by season_id;