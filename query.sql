drop function _cumpute_base_island;
create or replace function _cumpute_base_island(json_point json) returns integer as $$ 
	<<loc>>
	declare 
	center_point point;
	array_point point array;
	center_island int;
	begin
		select array_agg(point(island_row.x, island_row.y))
		into loc.array_point
		from json_to_recordset(_cumpute_base_island.json_point) as island_row(id int, x float, y float);
		
		loc.center_point = point(array_to_string(loc.array_point, ', ')::polygon);
		
		select island_row.id
		into loc.center_island 
		from json_to_recordset(_cumpute_base_island.json_point) as island_row(id int, x float, y float)
		order by loc.center_point <-> point(island_row.x, island_row.y);
		
		return loc.center_island;
	end;
$$ language plpgsql;

select c.*, i.x , i.y from init_world.contractors c
join init_world.islands i on c.island = i.id 
where c.item = 1

do $$
declare
json_island json;
begin
	select json_agg(init_world.islands.*) into json_island from init_world.islands;
	raise notice '%', _cumpute_base_island(json_island);
end;
$$;

select distinct s.island, s.item, s.quantity, substring(c."type"::text, 1,1) from final_world."storage" s
join final_world.contractors c on s.island = c.island
where s.player = 1
order by substring(c."type"::text, 1,1), s.island;

select array_agg(island) from (
select distinct s.island, s.quantity from final_world."storage" s
join final_world.contractors c on c.island = s.island
where s.player = 1 and c."type" = 'vendor'
order by s.quantity desc) as t


select distinct s.island, s.item, s.quantity, substring(c."type"::text, 1,1) from final_world."storage" s
join final_world.contractors c on s.island = c.island
where s.player = 1
order by substring(c."type"::text, 1,1), s.island;

select s.island, s.quantity from final_world."storage" s
where s.player = 1

select ps.ship/2, c.quantity,  ps.island, s.speed, s.capacity from world.parked_ships ps
join world.ships s on ps.ship = s.id
join world.cargo c on ps.ship = c.ship 
where s.player = 2

select * from world.cargo c 

select ms.ship, c.quantity , ms."start", ms.destination, s.speed , s.capacity, ms.arrives_at from world.moving_ships ms
join world.ships s on ms.ship = s.id
join world.cargo c on ms.ship = c.ship 
where s.player = 2

select id/2, * from world.ships s 

select 
	pms.ship_num::integer from public.my_ships pms where pms.ship_id = s.id), c.quantity , ts.finish_time, s.speed, s.capacity from world.transferring_ships ts join world.ships s on ts.ship = s.id join world.cargo c on ts.ship = c.ship where s.player = think.player_id
	
	
SELECT
	s.id,
	ts.finish_time,
	s.speed,
	s.capacity
from world.transferring_ships ts
join world.ships s on ts.ship = s.id
where s.player = 1

select * from world.transferring_ships ts



select * from world.contractors wc 
left join world.contracts c on c.contractor = wc.id
where "type" = 'customer' 
	  and wc.item = 2
	  and wc.price_per_unit >= 4
	  and (c.player is null or c.player != 1)
order by wc.price_per_unit*wc.quantity desc limit 1;


select i.id, array_agg(c.item)  from world.islands i
join world.contractors c on i.id = c.island
group by i.id
having 2 in array_agg(c.item);



select json_agg(i.*) from world.islands i
join world.contractors c on i.id = c.island
where c.item = 2

select * from world.contractors c 

-- отношение больше 3
with ct as (
select c.item, c."type", sum(c.quantity*c.price_per_unit), count(*) from world.contractors c 
where c."type" = 'customer'
group by c.item, c."type"
order by c.item, c."type"
), vt as (
select c.item, c."type", sum(c.quantity*c.price_per_unit), count(*) from world.contractors c 
where c."type" = 'vendor'
group by c.item, c."type"
order by c.item, c."type"
)
select *, ct."sum"/vt."sum" as _result from ct
join vt on ct.item = vt.item
where ct."sum"/vt."sum" > 3

-- где спрос больше чем 100 000
with ct as (
select c.item, c."type", sum(c.quantity*c.price_per_unit), count(*) from world.contractors c 
where c."type" = 'customer'
group by c.item, c."type"
order by c.item, c."type"
), vt as (
select c.item, c."type", sum(c.quantity*c.price_per_unit), count(*) from world.contractors c 
where c."type" = 'vendor'
group by c.item, c."type"
order by c.item, c."type"
)
select *, ct."sum"/vt."sum" as _result from ct
join vt on ct.item = vt.item
where ct."sum" > 100000

-- Отношение вендоров к кастомерам больше 0.5 но меньше 2
-- item integer, customer_supply double precision, vendor_demand double precision, customer_count integer, vendor_count integer
with ct as (
	select c.item, c."type", sum(c.quantity*c.price_per_unit) as customer_supply, count(*) as customer_count from world.contractors c 
	where c."type" = 'customer'
	group by c.item, c."type"
	order by c.item, c."type"
), vt as (
	select c.item, c."type", sum(c.quantity*c.price_per_unit) as vendor_demand, count(*) as vendor_count from world.contractors c 
	where c."type" = 'vendor'
	group by c.item, c."type"
	order by c.item, c."type"
)
select vt.item, customer_supply, vendor_demand, customer_count, vendor_count from ct
join vt on ct.item = vt.item
where vendor_count/customer_count > 0.5
and vendor_count/customer_count < 2
and customer_count > 2
and vendor_count > 2
and vt.item = any (1, 2 ,3 ,4, 5);

--select json_agg(t.*) from (
select i.id, i.x, i.y, c."type" from world.islands i
join world.contractors c on i.id = c.island
group by i.id 
having array_to_string(array_agg(c.item::text), ' ') not like '%' || 1::text || '%'/*) as t*/

select i.id, i.x, i.y, array_to_string(array_agg(c.item::text), ' ') from world.islands i
join world.contractors c on i.id = c.island
group by i.id 
having array_to_string(array_agg(c.item::text), ' ') not like '%' || 1::text || '%'

select i.id, i.x, i.y from world.islands i
join world.contractors c on i.id = c.island
where i.id not in (select i.id from world.islands i join world.contractors c on i.id = c.island where c.item = 1)

select 
	c.id, 
	c.quantity, s.*, '*****',c.*
from world."storage" s 
join world.contractors c on s.island = c.island
where s.player = 1
	and c."type" = 'customer'
	and c.item = s.item
	order by s.quantity 
	desc limit 1;
	
select * from world.players p 

select c.item, c."type" , c.* from init_world.contractors c

select c.item, c."type" , sum(c.quantity*c.price_per_unit) from init_world.contractors c
group by c.item, c."type"
order by c.item, c."type" 