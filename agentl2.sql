
create table Agent_Info_Dim_l2 as select Distinct(a.Person_Id),p.title||' '||p.first_name||' '||p.last_name as "Agent Name" from monre.Agent a join monre.person p on a.person_id=p.person_id;
create table agent_office_bridge_dim_l2 as select Person_Id,office_id from monre.agent_office;
create table Office_Dim_l2 as select office_id,office_name from monre.Office;
create table agent_office_size_Dim_l2 (office_type varchar2(30),office_Description varchar2(40));
insert into agent_office_size_Dim_l2 values('Small','< 4 employees');
insert into agent_office_size_Dim_l2 values('Medium',' 4-12 employees');
insert into agent_office_size_Dim_l2 values('Large','> 12 employees');



drop table agent_tempfact_l2;


create table agent_tempfact_l2 as select person_id,gender,suburb,salary,sum(price) "Total Worth" from (
select a.person_id,pe.gender,a.salary,ad.suburb,s.price from monre.agent a
left join monre.sale s on a.person_id=s.agent_person_id
left join monre.property p on s.property_id=p.property_id 
left join monre.address ad on p.address_id=ad.address_id 
left join MONRE.agent_office ao on a.person_id=ao.person_id
left join monre.person pe on a.person_id=pe.person_id
union 
select a.person_id,pe.gender,a.salary,ad.suburb,r.price*(r.rent_end_date-r.rent_start_date)/7 from monre.agent a
left join monre.rent r on a.person_id=r.agent_person_id
left join monre.property p on r.property_id=p.property_id 
left join monre.address ad on p.address_id=ad.address_id
left join MONRE.agent_office ao on a.person_id=ao.person_id
left join monre.person pe on a.person_id=pe.person_id
)
where price is not null 
group by person_id,gender,suburb,salary order by sum(price) desc;

alter table agent_tempfact_l2 add office_size varchar(10);
select a.person_id from agent_tempfact_l2 a join agent_office_bridge_dim b on a.person_id =b.person_id where b.office_id in (select office_id from monre.agent_office group by office_id having count(person_id)<4);
update agent_tempfact_l2 set office_size='Small' where person_id in (select a.person_id from agent_tempfact a join agent_office_bridge_dim b on a.person_id =b.person_id where b.office_id in (select office_id from monre.agent_office group by office_id having count(person_id)<4));
update agent_tempfact_l2 set office_size='Medium' where person_id in (select a.person_id from agent_tempfact a join agent_office_bridge_dim b on a.person_id =b.person_id where b.office_id in (select office_id from monre.agent_office group by office_id having count(person_id) between 4 and 12));
update agent_tempfact_l2 set office_size='Big' where person_id in (select a.person_id from agent_tempfact a join agent_office_bridge_dim b on a.person_id =b.person_id where b.office_id in (select office_id from monre.agent_office group by office_id having count(person_id)>12));

 
select * from property_dim;
select * from agent_tempfact;

create table agent_fact_l2 as select person_id,gender,suburb,office_size,sum(salary) "Total Salary",sum("Total Worth") "Total Worth",count( distinct person_id) "Total Agents"
from agent_tempfact_l2 group by (person_id,gender,suburb,office_size);

select * from agent_fact_l2;

select avg("Total Salary") "Average Salary" from agent_fact_l2 a 
join agent_office_bridge_dim_l2 b on a.person_id=b.person_id 
join office_dim_l2 o on b.office_id=o.office_id where o.office_name like '%Ray White%' order by a.person_id;


select b."Agent Name" from agent_fact_l2 a
join agent_info_dim_l2 b on a.person_id=b.person_id
where suburb='Melbourne' and "Total Worth" is not null
group by b."Agent Name" order by sum("Total Worth") desc fetch next 3 rows only;

select count(distinct("Agent Name")) "Total Female Agents" from agent_fact_l2 a join agent_info_dim_l2 b on a.person_id=b.person_id  where gender='Female' and office_size='Medium';


