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
	    if _move.debug then raise notice 'Отправили ship % на island %', _move.ship_id, _move.island_id; end if;
	end
$$ language plpgsql;


create or replace procedure _buy(contractors_id integer, quantity double precision, debug bool) as $$
	begin
		insert into actions.offers(contractor, quantity) values (_buy.contractors_id, _buy.quantity);
		if _buy.debug then raise notice 'Предложили vendor № % контракт на %', _buy.contractors_id, _buy.quantity; end if;
	end
$$ language plpgsql;


create or replace procedure _sell(contractors_id integer, quantity double precision, debug bool) as $$
	begin
		insert into actions.offers(contractor, quantity) values (_sell.contractors_id, _sell.quantity);
		if _sell.debug then raise notice 'Предложили customer № % контракт на %', _sell.contractors_id, _sell.quantity; end if;
	end
$$ language plpgsql;


create or replace procedure _load(ship_id integer, item integer, quantity double precision, debug bool) as $$
	begin
		insert into actions.transfers (ship, item, quantity, direction) values (_load.ship_id, _load.item, _load.quantity, 'load');
		if _load.debug then raise notice 'Загрузжаем ship % товаром % на % единиц', _load.ship_id, _load.item, _load.quantity; end if;
	end
$$ language plpgsql;


create or replace procedure _unload(ship_id integer, item integer, debug bool) as $$
	<<loc>>
	declare
		quantity double precision;
	begin
		loc.quantity := (select c.quantity from world.cargo c where c.ship = _unload.ship_id);
		insert into actions.transfers (ship, item, quantity, direction) values (_unload.ship_id, _unload.item, loc.quantity, 'unload');
		if _unload.debug then raise notice 'Разгрузжаем % единиц товара % с ship %', loc.quantity, _unload.item, _unload.ship_id; end if;
	end
$$ language plpgsql;

create or replace procedure _wait(moment_time double precision, debug bool) as $$
	begin
		insert into actions.wait ("until") values (_wait.moment_time);
		if _wait.debug then raise notice 'Ждём до %', _wait.moment_time; end if;
	end
$$ language plpgsql;


--	 ______                    ___             __                         ___          ___                         __                                     
--	/\  _  \                  /\_ \           /\ \__  __                 /\_ \       /'___\                       /\ \__  __                              
--	\ \ \L\ \    ___      __  \//\ \    __  __\ \ ,_\/\_\    ___     __  \//\ \     /\ \__/  __  __    ___     ___\ \ ,_\/\_\    ___     ___     ____     
--	 \ \  __ \ /' _ `\  /'__`\  \ \ \  /\ \/\ \\ \ \/\/\ \  /'___\ /'__`\  \ \ \    \ \ ,__\/\ \/\ \ /' _ `\  /'___\ \ \/\/\ \  / __`\ /' _ `\  /',__\    
--	  \ \ \/\ \/\ \/\ \/\ \L\.\_ \_\ \_\ \ \_\ \\ \ \_\ \ \/\ \__//\ \L\.\_ \_\ \_   \ \ \_/\ \ \_\ \/\ \/\ \/\ \__/\ \ \_\ \ \/\ \L\ \/\ \/\ \/\__, `\__ 
--	   \ \_\ \_\ \_\ \_\ \__/.\_\/\____\\/`____ \\ \__\\ \_\ \____\ \__/.\_\/\____\   \ \_\  \ \____/\ \_\ \_\ \____\\ \__\\ \_\ \____/\ \_\ \_\/\____/\_\
--	    \/_/\/_/\/_/\/_/\/__/\/_/\/____/ `/___/> \\/__/ \/_/\/____/\/__/\/_/\/____/    \/_/   \/___/  \/_/\/_/\/____/ \/__/ \/_/\/___/  \/_/\/_/\/___/\/_/ 

create or replace procedure _log(currentTime double precision, myMoney double precision, debug bool) as $$ 
	begin
		if _log.debug then 
	    raise notice '';
		raise notice '############################# money: %, time: % ', myMoney, _log.currentTime;
	   	end if;
	end
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

create or replace procedure _get_vendor_by_item(in item integer, in debug bool, out vendor record) as $$ 
	begin
		select * into _get_vendor_by_item.vendor from world.contractors wc 
	   	where "type" = 'vendor' 
	   		  and wc.price_per_unit < 4 
	   		  and wc.item = _get_vendor_by_item.item
	   	order by wc.price_per_unit asc limit 1;
	   
		if _get_vendor_by_item.debug then 
			raise notice 'v_id: %, v_type: %, v_island: %, v_item: %, v_quantity: %, v_price: %',
				_get_vendor_by_item.vendor.id,
				substring(_get_vendor_by_item.vendor."type"::text from 1 for 1),
		    	_get_vendor_by_item.vendor.island,
		    	_get_vendor_by_item.vendor.item,
		    	_get_vendor_by_item.vendor.quantity,
		    	_get_vendor_by_item.vendor.price_per_unit;
	   	end if;
	end
$$ language plpgsql;

create or replace procedure _get_customer_by_item(in item integer, in debug bool, out customer record) as $$ 
	begin
		select * into _get_customer_by_item.customer from world.contractors wc 
	   	where "type" = 'customer' 
	   		  and wc.item = _get_customer_by_item.item
	   		  and wc.price_per_unit > 5
	   	order by wc.price_per_unit desc limit 1;
	   
		if _get_customer_by_item.debug then 
			raise notice 'c_id: %, c_type: %, c_island: %, c_item: %, c_quantity: %, c_price: %',
				_get_customer_by_item.customer.id,
				substring(_get_customer_by_item.customer."type"::text from 1 for 1),
		    	_get_customer_by_item.customer.island,
		    	_get_customer_by_item.customer.item,
		    	_get_customer_by_item.customer.quantity,
		    	_get_customer_by_item.customer.price_per_unit;
	   	end if;
	end
$$ language plpgsql;

create or replace FUNCTION _get_parked_ships_by_player_id(player_id integer) returns table (id integer, player integer, island integer)  as  $$ 
	begin
		return query
		select s.id, s.player, ps.island from world.ships s
		join world.parked_ships ps on s.id = ps.ship
		where s.player = _get_parked_ships_by_player_id.player_id;
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

create or replace PROCEDURE think(player_id INTEGER) LANGUAGE PLPGSQL AS $$
	<<loc>>
	declare
	    currentTime double precision;
	    myMoney double precision;
	   	debug bool default true; 
	   	
	   	baseTypeItem integer default 1;
	   	
	   	vendor record;	
	   
	   	customer record;
	   
	   	ship record;
	   
	   	island integer;
	begin
	--	Получаем время
		select wg.game_time into loc.currentTime from world."global" wg;
	--  Получаем деньги
		select wp."money" into loc.myMoney from world.players wp where wp.id = think.player_id;
  
	   
	--  Аналитика
		call _log(loc.currentTime, loc.myMoney, loc.debug);
	if loc.debug then raise notice '- - - - - - - - - - - - - - - - Считаем - - - - - - - - - - - - - - - - - -'; end if;
	--	Первый попавшийся вендор
	   	call _get_vendor_by_item(loc.baseTypeItem, loc.debug, loc.vendor);
	
	--  Первый попавшийся покупатель с типом товара как у вендора
	   	call _get_customer_by_item(loc.baseTypeItem, loc.debug, loc.customer);
	   
	if loc.debug then raise notice '- - - - - - - - - - - - - - - - Аналитика - - - - - - - - - - - - - - - - -'; end if;
	

	if loc.debug then raise notice '- - - - - - - - - - - - - - - Раздаём приказы - - - - - - - - - - - - - - -'; end if;
	if loc.debug then raise notice '- - - - - - Заключаем сделки:'; end if;
	if loc.debug then raise notice '-- На покупку:'; end if;		
		if loc.vendor.id is not null then call _buy(loc.vendor.id, loc.vendor.quantity, loc.debug); end if;
	if loc.debug then raise notice '-- На продажу:'; end if;
	   	if loc.customer.id is not null then call _sell(loc.customer.id, loc.customer.quantity, loc.debug); end if;
		
	if loc.debug then raise notice '- - - - - Плаваем короблями:'; end if;
	if loc.debug then raise notice '-- За товаром'; end if;
		if loc.vendor.id is not null and loc.customer.id is not null 
		then
		for loc.ship in select * from _get_parked_ships_by_player_id(think.player_id) as t
			loop
				if (select 1 from world.cargo c where c.ship = loc.ship.id) is null
				then
					if loc.debug then raise notice 'ship % пустой', loc.ship.id; end if;
					if loc.ship.island != loc.vendor.island
					then  
						if loc.debug then raise notice 'ship % НЕ на базе %', loc.ship.id, loc.vendor.island; end if;
						call _move(loc.ship.id, loc.vendor.island, loc.debug);
					else
						if loc.debug then raise notice 'ship % на базе %', loc.ship.id, loc.vendor.island; end if;
						call _load(loc.ship.id, loc.vendor.item, 1000, debug);
					end if;
				else
					if loc.debug then raise notice 'в ship % что-то есть', loc.ship.id; end if;
					if loc.ship.island = loc.vendor.island
					then
						if loc.debug then raise notice 'ship % на базе %', loc.ship.id, loc.vendor.island; end if;
						call _move(loc.ship.id, loc.customer.island, loc.debug);
					else
						if loc.debug then raise notice 'ship % у покупателя %', loc.ship.id, loc.vendor.island; end if;
						call _unload(loc.ship.id, loc.vendor.item, debug);
					end if;
				end if;
			end loop;
		else
			if loc.debug then raise notice '-- Ждём'; end if;
			call _wait(loc.currentTime+1, loc.debug);
		end if;
END $$;

-- TODO Статистика выполнения думания