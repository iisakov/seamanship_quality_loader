--	 88888888b                              dP   oo                                        .8888b                            dP                               
--	 88                                     88                                             88   "                            88                               
--	a88aaaa    dP    dP 88d888b. .d8888b. d8888P dP .d8888b. 88d888b. .d8888b.    .d8888b. 88aaa     .d8888b. 88d888b. .d888b88 .d8888b. 88d888b. .d8888b.    
--	 88        88    88 88'  `88 88'  `""   88   88 88'  `88 88'  `88 Y8ooooo.    88'  `88 88        88'  `88 88'  `88 88'  `88 88ooood8 88'  `88 Y8ooooo.    
--	 88        88.  .88 88    88 88.  ...   88   88 88.  .88 88    88       88    88.  .88 88        88.  .88 88       88.  .88 88.  ... 88             88 dP 
--	 dP        `88888P' dP    dP `88888P'   dP   dP `88888P' dP    dP `88888P'    `88888P' dP        `88888P' dP       `88888P8 `88888P' dP       `88888P' 88 
--  Функции для приказов

create or replace procedure _move(ship_id integer, island_id integer, debug bool) as $$
	begin
	    insert into actions.ship_moves(ship, destination) values (ship_id, island_id);
	end
$$ language plpgsql;


create or replace procedure _buy(contractors_id integer, quantity double precision, debug bool) as $$
	begin
		insert into actions.offers(contractor, quantity) values (_buy.contractors_id, _buy.quantity*0.97);
--		raise notice '%',_buy.quantity*0.97 ;
	end
$$ language plpgsql;


create or replace procedure _sell(contractors_id integer, quantity double precision, debug bool) as $$
	begin
		insert into actions.offers(contractor, quantity) values (_sell.contractors_id, _sell.quantity);
	end
$$ language plpgsql;


create or replace procedure _load(ship_id integer, item integer, player integer, island integer, debug bool) as $$
	<<loc>>
	declare
		quantity double precision;
	begin
		loc.quantity := (select s.quantity from world."storage" s where s.island = _load.island and s.player = _load.player);
		insert into actions.transfers (ship, item, quantity, direction) values (_load.ship_id, _load.item, coalesce(loc.quantity*0.97, 0), 'load');
	end
$$ language plpgsql;


create or replace procedure _unload(ship_id integer, item integer, debug bool) as $$
	<<loc>>
	declare
		quantity double precision;
	begin
		loc.quantity := (select c.quantity from world.cargo c where c.ship = _unload.ship_id);
		insert into actions.transfers (ship, item, quantity, direction) values (_unload.ship_id, _unload.item, loc.quantity*0.97, 'unload');
	end
$$ language plpgsql;

create or replace procedure _wait(moment_time double precision, debug bool) as $$
	begin
		insert into actions.wait ("until") values (_wait.moment_time);
	end
$$ language plpgsql;



--	 ______                    ___             __                         ___          ___                         __                                     
--	/\  _  \                  /\_ \           /\ \__  __                 /\_ \       /'___\                       /\ \__  __                              
--	\ \ \L\ \    ___      __  \//\ \    __  __\ \ ,_\/\_\    ___     __  \//\ \     /\ \__/  __  __    ___     ___\ \ ,_\/\_\    ___     ___     ____     
--	 \ \  __ \ /' _ `\  /'__`\  \ \ \  /\ \/\ \\ \ \/\/\ \  /'___\ /'__`\  \ \ \    \ \ ,__\/\ \/\ \ /' _ `\  /'___\ \ \/\/\ \  / __`\ /' _ `\  /',__\    
--	  \ \ \/\ \/\ \/\ \/\ \L\.\_ \_\ \_\ \ \_\ \\ \ \_\ \ \/\ \__//\ \L\.\_ \_\ \_   \ \ \_/\ \ \_\ \/\ \/\ \/\ \__/\ \ \_\ \ \/\ \L\ \/\ \/\ \/\__, `\__ 
--	   \ \_\ \_\ \_\ \_\ \__/.\_\/\____\\/`____ \\ \__\\ \_\ \____\ \__/.\_\/\____\   \ \_\  \ \____/\ \_\ \_\ \____\\ \__\\ \_\ \____/\ \_\ \_\/\____/\_\
--	    \/_/\/_/\/_/\/_/\/__/\/_/\/____/ `/___/> \\/__/ \/_/\/____/\/__/\/_/\/____/    \/_/   \/___/  \/_/\/_/\/____/ \/__/ \/_/\/___/  \/_/\/_/\/___/\/_/ 
-- Аналитические функции

create or replace procedure _print(in log_row text, in _current_counter integer, in debug bool, out _counter integer) as $$
	begin
		if _print.debug
		then
			_counter = _current_counter + 1;
			raise notice '%', log_row;
		end if;
	end
$$ language plpgsql;


create or replace function _get_supply_demand() returns table (item integer, supply_demand float) as  $$ 
	begin
		return query
		select * 
		from ( select c.item, lag(sum(c.quantity)) over(partition by c.item order by c.item, c."type")/sum(c.quantity) supply_demand
			   from world.contractors c
			   group by c."type", c.item ) as t
		where t.supply_demand is not null;
	end
$$ language plpgsql;


create or replace function _get_metric_buy_price() returns table (item integer, avg_buy_price float, max_buy_price float,  min_buy_price float) as  $$ 
	begin
		return query
		select c.item, avg(c.price_per_unit) avg_buy_price, max(c.price_per_unit) max_buy_price, min(c.price_per_unit) min_buy_price
		from world.contractors c
		where c."type" = 'vendor'
		group by c."type", c.item;
	end
$$ language plpgsql;


create or replace function _get_metric_sell_price() returns table (item integer, avg_sell_price float, max_sell_price float,  min_sell_price float) as  $$ 
	begin
		return query
		select c.item, avg(c.price_per_unit) avg_sell_price, max(c.price_per_unit) max_sell_price, min(c.price_per_unit) min_sell_price
		from world.contractors c
		where c."type" = 'customer'
		group by c."type", c.item;
	end
$$ language plpgsql;


create or replace function _get_supply_demand_by_item(in item integer, out supply_demand float) as  $$ 
	begin
		select t.supply_demand into _get_supply_demand_by_item.supply_demand 
		from ( select c.item, lag(avg(c.price_per_unit)) over(partition by c.item order by c.item, c."type")/avg(c.price_per_unit) supply_demand
			   from init_world.contractors c
			   where c.item = _get_supply_demand_by_item.item
			   group by c."type", c.item ) as t
		where t.supply_demand is not null;
	end
$$ language plpgsql;


create or replace procedure _get_metric_buy_price_by_item(in item integer, out metric record) as  $$ 
	begin
		select c.item, avg(c.price_per_unit) avg_buy_price, max(c.price_per_unit) max_buy_price, min(c.price_per_unit) min_buy_price
		into _get_metric_buy_price_by_item.metric
		from world.contractors c
		where c."type" = 'vendor' and c.item  = _get_metric_buy_price_by_item.item
		group by c."type", c.item;
	end
$$ language plpgsql;


create or replace procedure _get_metric_sell_price_by_item(in item integer, out metric record) as  $$ 
	begin
		select c.item, avg(c.price_per_unit) avg_sell_price, max(c.price_per_unit) max_sell_price, min(c.price_per_unit) min_sell_price
		into _get_metric_sell_price_by_item.metric
		from world.contractors c
		where c."type" = 'customer' and c.item = _get_metric_sell_price_by_item.item
		group by c."type", c.item;
	end
$$ language plpgsql;


create or replace function _cumpute_avr_point(json_point json) returns point as $$
	<<loc>>
	declare
		array_point point array;
	begin
		select array_agg(point(island_row.x, island_row.y))
		into loc.array_point
		from json_to_recordset(_cumpute_avr_point.json_point) as island_row(id int, x float, y float);
	    
		return point(array_to_string(loc.array_point, ', ')::polygon);
	end;
$$ language plpgsql;		


create or replace function _cumpute_base_island(json_point json, center_point point) returns integer as $$ 
	<<loc>>
	declare 
		center_island int;
	begin
		select island_row.id
		into loc.center_island 
		from json_to_recordset(_cumpute_base_island.json_point) as island_row(id int, x float, y float)
		order by _cumpute_base_island.center_point <-> point(island_row.x, island_row.y);
		
		return loc.center_island;
	end;
$$ language plpgsql;



--      _____                    _____                _____                _____                    _____                    _____                    _____          
--     /\    \                  /\    \              /\    \              /\    \                  /\    \                  /\    \                  /\    \         
--    /::\    \                /::\    \            /::\    \            /::\    \                /::\    \                /::\    \                /::\    \        
--   /::::\    \              /::::\    \           \:::\    \           \:::\    \              /::::\    \              /::::\    \              /::::\    \       
--  /::::::\    \            /::::::\    \           \:::\    \           \:::\    \            /::::::\    \            /::::::\    \            /::::::\    \      
-- /:::/\:::\    \          /:::/\:::\    \           \:::\    \           \:::\    \          /:::/\:::\    \          /:::/\:::\    \          /:::/\:::\    \     
--/:::/  \:::\    \        /:::/__\:::\    \           \:::\    \           \:::\    \        /:::/__\:::\    \        /:::/__\:::\    \        /:::/__\:::\    \    
--:::/    \:::\    \      /::::\   \:::\    \          /::::\    \          /::::\    \      /::::\   \:::\    \      /::::\   \:::\    \       \:::\   \:::\    \   
--::/    / \:::\    \    /::::::\   \:::\    \        /::::::\    \        /::::::\    \    /::::::\   \:::\    \    /::::::\   \:::\    \    ___\:::\   \:::\    \  
--:/    /   \:::\ ___\  /:::/\:::\   \:::\    \      /:::/\:::\    \      /:::/\:::\    \  /:::/\:::\   \:::\    \  /:::/\:::\   \:::\____\  /\   \:::\   \:::\    \ 
--::/__/  ___\:::|    |/:::/__\:::\   \:::\____\    /:::/  \:::\____\    /:::/  \:::\____\/:::/__\:::\   \:::\____\/:::/  \:::\   \:::|    |/::\   \:::\   \:::\____\
--::\  \ /\  /:::|____|\:::\   \:::\   \::/    /   /:::/    \::/    /   /:::/    \::/    /\:::\   \:::\   \::/    /\::/   |::::\  /:::|____|\:::\   \:::\   \::/    /
--:::\  /::\ \::/    /  \:::\   \:::\   \/____/   /:::/    / \/____/   /:::/    / \/____/  \:::\   \:::\   \/____/  \/____|:::::\/:::/    /  \:::\   \:::\   \/____/ 
--\:::  \:::\ \/____/    \:::\   \:::\    \      /:::/    /           /:::/    /            \:::\   \:::\    \            |:::::::::/    /    \:::\   \:::\    \     
-- \::   \:::\____\       \:::\   \:::\____\    /:::/    /           /:::/    /              \:::\   \:::\____\           |::|\::::/    /      \:::\   \:::\____\    
--  \:\  /:::/    /        \:::\   \::/    /    \::/    /            \::/    /                \:::\   \::/    /           |::| \::/____/        \:::\  /:::/    /    
--   \:\/:::/    /          \:::\   \/____/      \/____/              \/____/                  \:::\   \/____/            |::|  ~|               \:::\/:::/    /     
--    :::::/    /            \:::\    \                                                         \:::\    \                |::|   |                \::::::/    /      
--     \::/    /              \:::\____\                                                         \:::\____\               \::|   |                 \::::/    /       
--      \/____/                \::/    /                                                          \::/    /                \:|   |                  \::/    /        
--                              \/____/                                                            \/____/                  \|___|                   \/____/                                                                                                                                                                                
-- Геттеры

create or replace procedure _get_vendor_by_item(in item integer, in max_prise double precision, in debug bool, out vendor record) as $$ 
	begin
		select * from (
		select * into _get_vendor_by_item.vendor from world.contractors wc 
	   	where "type" = 'vendor' 
	   		  and wc.price_per_unit <= max_prise 
	   		  and wc.item = _get_vendor_by_item.item
	   	order by wc.price_per_unit asc limit 2) as t
	   	order by t.quantity desc limit 1;
	end
$$ language plpgsql;

--create or replace procedure _get_vendor_by_item(in item integer, in max_prise double precision, in debug bool, out vendor record) as $$ 
--	begin
--		select * into _get_vendor_by_item.vendor from world.contractors wc 
--	   	where "type" = 'vendor' 
--	   		  and wc.price_per_unit <= max_prise 
--	   		  and wc.item = _get_vendor_by_item.item
--	   	order by wc.price_per_unit asc limit 1;
----	   	order by wc.quantity desc limit 1;
--	end
--$$ language plpgsql;

create or replace procedure _get_customer_by_item(in item integer, in min_prise double precision, in player_id integer, in debug bool, out customer record) as $$ 
	begin
		select * into _get_customer_by_item.customer
		from world.contractors wc 
		left join world.contracts c on c.contractor = wc.id
		where "type" = 'customer' 
	  		and wc.item = _get_customer_by_item.item
	  		and wc.price_per_unit >= min_prise
	  		and (c.player is null or c.player != _get_customer_by_item.player_id)
		order by wc.price_per_unit*wc.quantity desc
		limit 1;

--		select * into _get_customer_by_item.customer from world.contractors wc 
--	   	where "type" = 'customer' 
--	   		  and wc.item = _get_customer_by_item.item
--	   		  and wc.price_per_unit >= min_prise
--	   	order by wc.price_per_unit*wc.quantity  desc limit 1;
	end
$$ language plpgsql;

create or replace function _get_parked_ships_by_player_id(player_id integer) returns table (id integer, ship_num integer, player integer, island integer)  as  $$ 
	begin
		return query
		select s.id, (select pms.ship_num::integer from public.my_ships pms where pms.ship_id = s.id) as ship_num, s.player, ps.island from world.ships s
		join world.parked_ships ps on s.id = ps.ship
		where s.player = _get_parked_ships_by_player_id.player_id;
	end
$$ language plpgsql;

create or replace function _get_storage_by_player_id(player_id integer) returns table (island integer, item integer, quantity double precision, c_type text)  as  $$ 
	begin
		return query
		select distinct s.island, s.item, s.quantity, substring(c."type"::text, 1,1) as c_type from world."storage" s
		join world.contractors c on s.island = c.island and s.item = c.item 
		where s.player = _get_storage_by_player_id.player_id
		order by substring(c."type"::text, 1,1), s.island;
	end
$$ language plpgsql;

create or replace function _get_vender_array_storage_by_player_id(player_id integer) returns integer array as  $$
	declare
	test int array;
	begin
		select array_agg(island) into test from (select * from _get_storage_by_player_id(_get_vender_array_storage_by_player_id.player_id) where c_type = 'v' order by quantity desc) as t;
		return test; 
	end
$$ language plpgsql;

create or replace function _get_array_storage_by_player_id(player_id integer) returns integer array as  $$
	declare
	_result int array;
	begin
		select 
			array_agg(island) into _result 
		from (select
				c2.island,
				c.quantity
			  from world.contracts c 
			  join world.contractors c2 on c.contractor = c2.id
			  where c2."type" = 'customer' and c.player = _get_array_storage_by_player_id.player_id
			  order by c.payment_sum desc) as t;
		return _result;
	end
$$ language plpgsql;



--	   I8                ,dPYb,                  ,dPYb,                                                                     ,dPYb,    
--	   I8                IP'`Yb                  IP'`Yb                                                                     IP'`Yb    
--	88888888             I8  8I                  I8  8I                                                                     I8  8I    
--	   I8                I8  8'                  I8  8'                                                                     I8  8bgg, 
--	   I8      ,gggg,gg  I8 dP       gg      gg  I8 dP    ,gggg,gg   ,gggggg,      gg    gg    gg     ,ggggg,     ,gggggg,  I8 dP" "8 
--	   I8     dP"  "Y8I  I8dP   88gg I8      8I  I8dP    dP"  "Y8I   dP""""8I      I8    I8    88bg  dP"  "Y8ggg  dP""""8I  I8d8bggP" 
--	  ,I8,   i8'    ,8I  I8P    8I   I8,    ,8I  I8P    i8'    ,8I  ,8'    8I      I8    I8    8I   i8'    ,8I   ,8'    8I  I8P' "Yb, 
--	 ,d88b, ,d8,   ,d8b,,d8b,  ,8I  ,d8b,  ,d8b,,d8b,_ ,d8,   ,d8b,,dP     Y8,    ,d8,  ,d8,  ,8I  ,d8,   ,d8'  ,dP     Y8,,d8    `Yb,
--	88P""Y88P"Y8888P"`Y88P'"Y88P"'  8P'"Y88P"`Y88P'"Y88P"Y8888P"`Y88P      `Y8    P""Y88P""Y88P"   P"Y8888P"    8P      `Y888P      Y8
-- Работа с таблицами

create unlogged table public.memory (id serial PRIMARY KEY, _time float, _money float);

create unlogged table public.foundation (base_island int2, game_step_num int2);

create unlogged table public.my_ships (ship_id int2, ship_num int2);


--	  ▄████  ▄▄▄       ███▄ ▄███▓▓█████     ▄████▄   ██▓ ▄████▄   ██▓    ▓█████ 
--	 ██▒ ▀█▒▒████▄    ▓██▒▀█▀ ██▒▓█   ▀    ▒██▀ ▀█  ▓██▒▒██▀ ▀█  ▓██▒    ▓█   ▀ 
--	▒██░▄▄▄░▒██  ▀█▄  ▓██    ▓██░▒███      ▒▓█    ▄ ▒██▒▒▓█    ▄ ▒██░    ▒███   
--	░▓█  ██▓░██▄▄▄▄██ ▒██    ▒██ ▒▓█  ▄    ▒▓▓▄ ▄██▒░██░▒▓▓▄ ▄██▒▒██░    ▒▓█  ▄ 
--	░▒▓███▀▒ ▓█   ▓██▒▒██▒   ░██▒░▒████▒   ▒ ▓███▀ ░░██░▒ ▓███▀ ░░██████▒░▒████▒
--	 ░▒   ▒  ▒▒   ▓▒█░░ ▒░   ░  ░░░ ▒░ ░   ░ ░▒ ▒  ░░▓  ░ ░▒ ▒  ░░ ▒░▓  ░░░ ▒░ ░
--	  ░   ░   ▒   ▒▒ ░░  ░      ░ ░ ░  ░     ░  ▒    ▒ ░  ░  ▒   ░ ░ ▒  ░ ░ ░  ░
--	░ ░   ░   ░   ▒   ░      ░      ░      ░         ▒ ░░          ░ ░      ░   
--	      ░       ░  ░       ░      ░  ░   ░ ░       ░  ░ ░          ░  ░   ░  ░
--	                                       ░            ░                                                                         
-- Игровой цикл

create or replace PROCEDURE think(player_id INTEGER) LANGUAGE PLPGSQL AS $$
	<<loc>>
	declare
	    currentTime double precision;	myMoney double precision;	beforeThink record;	constants record;
	    
	   	debug bool default
--	   		true;
	    	false;
	   	
	   	iterator record;
	   	
	   	buy_price double precision default 4;	sell_price double precision default 5;
	   	
	   	baseTypeItem integer default 2;	item record;	
	   	
	   	contractor record;
	   	vendor record;   v_island integer;
	   	customer record; c_island integer;
	   
	   	contract record;
	   
	   	ship record; parked_ship record; moving_ship record; transferring_ship record;
	   	
	   	test record;
	   	
	   	island record;
	   
	   	warehouse record;
	   	
	   	_row_counter int default 0;
	   
	   	trush int array;
	begin
		call _print('-', loc._row_counter, loc.debug, loc._row_counter);
	--	Получаем текущее время
		select wg.game_time into loc.currentTime from world."global" wg;
	--  Получаем текущие деньги
		select wp."money" into loc.myMoney from world.players wp where wp.id = think.player_id;
  	--  Получаем метрики за прошлый think
		select * into loc.beforeThink from public.memory m order by m.id desc limit 1;
	--	Получаем константы
		select * into loc.constants from public.foundation f;
	
	--  Записываем метрики 
		insert into public.memory(_time, _money) values (loc.currentTime, loc.myMoney);
	
		
		
--	Инициализация переменных
		if loc.constants.base_island is null
		then
			for loc.island in (select * from world.islands i)
			loop
				call _print('island = ' || loc.island, loc._row_counter, loc.debug, loc._row_counter);
			end loop;
			insert into public.my_ships select s.id, row_number () over (partition by s.player) from world.ships s where s.player = think.player_id order by s.id;
		end if;

		for loc.warehouse in (select s.island, s.quantity from world."storage" s where s.player = think.player_id)
		loop 
			call _print('warehouse = ' || loc.warehouse, loc._row_counter, loc.debug, loc._row_counter);
		end loop;
	
		for loc.contractor in (select c.*, i.x , i.y from world.contractors c join world.islands i on c.island = i.id where c.item = baseTypeItem)
		loop
			call _print('contractor = ' || loc.contractor, loc._row_counter, loc.debug, loc._row_counter);
		end loop;
		
		for loc.parked_ship in (select s.id, (select pms.ship_num::integer from public.my_ships pms where pms.ship_id = s.id), c.quantity,  ps.island, s.speed, s.capacity from world.parked_ships ps join world.ships s on ps.ship = s.id join world.cargo c on ps.ship = c.ship where s.player = think.player_id)
		loop
			call _print('parked_ship = ' || loc.parked_ship, loc._row_counter, loc.debug, loc._row_counter);
		end loop;
		
		for loc.moving_ship in (select s.id, (select pms.ship_num::integer from public.my_ships pms where pms.ship_id = s.id), c.quantity , ms."start", ms.destination, s.speed, s.capacity, ms.arrives_at from world.moving_ships ms join world.ships s on ms.ship = s.id join world.cargo c on ms.ship = c.ship where s.player = think.player_id)
		loop
			call _print('moving_ship = ' || loc.moving_ship, loc._row_counter, loc.debug, loc._row_counter);
		end loop;
	
		for loc.transferring_ship in (select s.id, (select pms.ship_num::integer from public.my_ships pms where pms.ship_id = s.id), ts.island, ts.finish_time, s.speed, s.capacity from world.transferring_ships ts join world.ships s on ts.ship = s.id where s.player =  think.player_id)
		loop
			call _print('transferring_ship = ' || loc.transferring_ship, loc._row_counter, loc.debug, loc._row_counter);
		end loop;
	
		for loc.contract in (select * from world.contracts c join world.contractors c2 on c.contractor = c2.id)
		loop
			call _print('contract = ' || loc.contract, loc._row_counter, loc.debug, loc._row_counter);
		end loop;
	
		FOR loc.ship IN (select * from world.ships s join public.my_ships ms on s.id = ms.ship_id where s.player = think.player_id)
		loop
			call _print('ship = ' || loc.ship, loc._row_counter, loc.debug, loc._row_counter);
		end loop;
		
	
	--  Аналитика	
	--	Получаем бвзовый остров 
		if loc.constants.base_island is null 
		then
			insert into public.foundation(base_island) 
				   values (_cumpute_base_island((select json_agg(t.*) from (
												 select i.id, i.x, i.y from world.islands i
												 join world.contractors c on i.id = c.island
												 group by i.id 
												 having array_to_string(array_agg(c.item::text), ' ') not like '%'|| loc.baseTypeItem ||'%') as t),
				  		   _cumpute_avr_point((select json_agg(i.*) 
				  		                       from world.islands i 
				  		                       join world.contractors c on i.id = c.island
				  		                       where c.item = loc.baseTypeItem))));
		else
			call _print('base_island = (' || loc.constants.base_island::text || ')', loc._row_counter, loc.debug, loc._row_counter);
		end if;
	--	Проверяем ход игры
		if loc.constants.game_step_num is null or loc.constants.game_step_num < loc.currentTime/10000
		then
			update public.foundation set game_step_num = ceil(currentTime/10000);
		else
			call _print('game_step_num = ' || loc.constants.game_step_num::text, loc._row_counter, loc.debug, loc._row_counter);
		end if;

		call _print('myMoney = (' || loc.myMoney::text || ')', loc._row_counter, loc.debug, loc._row_counter);
		call _print('currentTime = (' || currentTime::text || ')', loc._row_counter, loc.debug, loc._row_counter);
		
		
		call _get_metric_sell_price_by_item(loc.baseTypeItem, loc.item);
		sell_price = loc.item.avg_sell_price;
--		sell_price = 10;
		call _print('sell_price = (' || loc.sell_price::text || ')', loc._row_counter, loc.debug, loc._row_counter);
		buy_price = loc.item.avg_sell_price * 0.5;
--		buy_price = 5;
		call _print('buy_price = (' || loc.buy_price::text || ')', loc._row_counter, loc.debug, loc._row_counter);
		
	--	Первый попавшийся вендор
	   	call _get_vendor_by_item(loc.baseTypeItem, loc.buy_price, loc.debug, loc.vendor);
	
	--  Первый попавшийся покупатель с типом товара как у вендора
	   	call _get_customer_by_item(loc.baseTypeItem, loc.sell_price, think.player_id, loc.debug, loc.customer);

	
	--	Покупаем   
		if loc.vendor.id is not null
		then
			call _buy(loc.vendor.id, loc.vendor.quantity, loc.debug);
			call _print('buy = (' || loc.vendor.island::text || ')', loc._row_counter, loc.debug, loc._row_counter);
--			call _print('tbu = ' || loc.vendor, loc._row_counter, loc.debug, loc._row_counter);
		end if;
	--	Продаём
	   	if loc.customer.id is not null
	   	then
	   		call _sell(loc.customer.id, loc.customer.quantity, loc.debug);
	   		call _print('sell = (' || loc.customer.island::text || ')', loc._row_counter, loc.debug, loc._row_counter);
	   	end if;
	   
	--	   	
		if true /*loc.vendor.id is not null and loc.customer.id is not null*/ 
		then
			for loc.ship in select * from _get_parked_ships_by_player_id(think.player_id) /*Возможно мы сломаемся на том что у нас нет припаркованых кораблей*/
			loop
				if ((select 1 from world.cargo c where c.ship = loc.ship.id) is null) or (0.1 > (select c2.quantity from world.cargo c2 where c2.ship = loc.ship.id)) /*Проверяет корабль, пустой ли он*/
				then /* Работаем с путым или теми в ком меньше 0.1 товара */
					if loc.ship.ship_num <= 5 /*Выбираем продающие корабли*/
					then
--						call _print(loc.ship.ship_num::text, loc._row_counter, loc.debug, loc._row_counter);
						if loc.ship.island != loc.constants.base_island
						then  
							call _move(loc.ship.id, loc.constants.base_island, loc.debug); /*Плывём на базу за товаром*/
							call _print('move = (' || loc.ship.island::text ||','|| loc.constants.base_island::text || ',customer' ||')', loc._row_counter, loc.debug, loc._row_counter);
						else
							call _load(loc.ship.id, loc.baseTypeItem, think.player_id, loc.ship.island, debug); /*загружаемся на базе*/
							call _print('load = (' || loc.ship.island::text ||','|| loc.ship.id::text || ')', loc._row_counter, loc.debug, loc._row_counter);
						end if;
					else /*Выбираем покупающие корабли*/
--					call _print('-----------------------------------  '|| loc.ship.island::text || _get_vender_array_storage_by_player_id(think.player_id)::text, loc._row_counter, loc.debug, loc._row_counter);
						
						if loc.ship.island = any (_get_vender_array_storage_by_player_id(think.player_id)) /*Если мы на острове с не пустым складом*/
						then
							call _load(loc.ship.id, baseTypeItem, think.player_id, loc.ship.island, debug); /*загружаемся на vendor`а*/
							call _print('load = (' || loc.ship.island::text ||','|| loc.ship.id::text || ')', loc._row_counter, loc.debug, loc._row_counter);
						else /* если мы не на острове со складом */
--							call _print('-----------------------------------  '|| array_length(_get_vender_array_storage_by_player_id(think.player_id), 1)::text, loc._row_counter, loc.debug, loc._row_counter);
							if array_length(_get_vender_array_storage_by_player_id(think.player_id), 1) > 0 /* есть ли хоть один склад vendora*/
							then
								v_island := (select * from _get_vender_array_storage_by_player_id(think.player_id))[1]; /* выбираем самый накаченый */
								call _move(loc.ship.id, v_island, loc.debug); /* плывём на самый накаченый */
								call _print('move = (' || loc.ship.island::text ||','|| v_island::text || ',vendor' || ')', loc._row_counter, loc.debug, loc._row_counter);
							end if;
						end if;
					end if;
				else /* Работаем с не пустыми */
					if loc.ship.ship_num <= 5 /*Выбираем продающие корабли*/
					then
						select array_agg(c.island) into trush from world.contractors c where c."type" = 'customer' and c.item = loc.baseTypeItem;
						if loc.ship.island = any (trush)/*(_get_array_storage_by_player_id(think.player_id))*/ /* Мы на острове покупателя */
						then
							call _unload(loc.ship.id, baseTypeItem, debug); /*Разгружаемся на покупателя*/
							call _print('unload = (' || loc.ship.island::text || ')', loc._row_counter, loc.debug, loc._row_counter);
						else
							if array_length(_get_array_storage_by_player_id(think.player_id), 1) > 0 /* покупатели существуют */
							then /* Мы НЕ на острове покупателя */
								c_island := (_get_array_storage_by_player_id(think.player_id))[1]; /* Берём лучшего покупателя */
								call _move(loc.ship.id, c_island, loc.debug); /* Двигаемся к лучшему покупателю */
								call _print('move = (' || loc.ship.island::text ||','|| c_island::text || ',customer' || ')', loc._row_counter, loc.debug, loc._row_counter);
							end if;
						end if;
					else /*Выбираем покупающие корабли*/
						if loc.ship.island != loc.constants.base_island /* Мы не на базе? */
						then /*Мы не на базе*/
							call _move(loc.ship.id, loc.constants.base_island, loc.debug); /* двигаем на базу */
							call _print('move = (' || loc.ship.island::text ||','|| loc.constants.base_island::text || ',vendor' || ')', loc._row_counter, loc.debug, loc._row_counter);
						else /* Мы на базе */
							call _unload(loc.ship.id, baseTypeItem, debug); /* Разгружаемся */
							call _print('unload = (' || loc.ship.island::text || ')', loc._row_counter, loc.debug, loc._row_counter);
						end if;
					end if;
				end if;
			end loop;
		else
			call _wait(loc.currentTime+1, loc.debug);
		end if;
		
		loop
			exit when loc._row_counter > 57;
			call _print('', loc._row_counter, loc.debug, loc._row_counter);
		end loop;
END $$;