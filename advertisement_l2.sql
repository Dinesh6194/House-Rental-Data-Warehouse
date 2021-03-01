

select * from property_dim;
select * from property_advert_dim;
select * from property_date_dim;
drop table property_date_dim;


create table advert_dim_l2 as select advert_id,advert_name from monre.advertisement;
create table property_date_dim_l2 as select distinct to_char(property_date_added,'Month')||' '||
to_char(property_date_added,'yyyy') date_id,to_char(property_date_added,'Month') month,
to_char(property_date_added,'yyyy') year from monre.property;

create table advertisement_tempfact_l2 as select p.property_id,pd.property_date_added,a.advert_id 
from monre.advertisement a join monre.property_advert p on a.advert_id=p.advert_id
join monre.property pd on p.property_id=pd.property_id 
group by p.property_id,pd.property_date_added,a.advert_id;

select sum("Total number of Properties") from advertisement_fact;
select * from property_dim;

drop table advertisement_fact_l2;
create table advertisement_fact_l2 as select to_char(property_date_added,'Month')||' '||
to_char(property_date_added,'yyyy') date_id, advert_id, count(property_id) "Total number of Properties" 
from advertisement_tempfact_l2
group by to_char(property_date_added,'Month')||' '||
to_char(property_date_added,'yyyy'), advert_id;

select * from advertisement_fact_l2;

select sum("Total number of Properties") "Total number of Properties",d.month,d.year from advertisement_fact_l2 a
join advert_dim ad on a.advert_id=ad.advert_id
join property_date_dim d on a.date_id=d.date_id
where ad.advert_name like '%Sale%' and d.month like '%April%' and d.year='2020'
group by d.month,d.year;
