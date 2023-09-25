create table traffic (
    "ship" INTEGER,
    "item" INTEGER,
    "island" INTEGER,
    "to_island" INTEGER,    
    "contractor" DOUBLE PRECISION,
    "quantity" DOUBLE PRECISION
); 


CREATE PROCEDURE think(player_id INTEGER) LANGUAGE PLPGSQL AS $$ 
	<<loc>>
declare
    currentTime double precision := (select game_time from world.global);
    sh record;    
    rows record;
   	log_row record; log_float double precision;
begin
	raise notice '-';
	raise notice 'currentTime = (%)', loc.currentTime;
	raise notice 'myMoney = (%)', (select p."money" from world.players p where p.id = think.player_id);
	
	loc.log_float = (select sum(s.quantity) from world."storage" s where s.player = think.player_id);
	raise notice 'all_storage_quantity = (%)', coalesce(loc.log_float, 0);

	if loc.currentTime < 10
	then
	for loc.log_row in (select * from world.islands i)
	loop
		raise notice 'island = %', loc.log_row;
	end loop;
	end if;
	
	for loc.log_row in (select s.island, s.quantity from world."storage" s where s.player = think.player_id)
	loop 
		raise notice 'warehouse = %', loc.log_row;
	end loop;

	for loc.log_row in (select c.*, i.x , i.y from world.contractors c join world.islands i on c.island = i.id)
	loop
		raise notice 'contractor = %', loc.log_row;
	end loop;

	for loc.log_row in (select s.id, c.quantity,  ps.island, s.speed, s.capacity from world.parked_ships ps join world.ships s on ps.ship = s.id join world.cargo c on ps.ship = c.ship where s.player = think.player_id)
	loop
		raise notice 'parked_ship = %', loc.log_row;
	end loop;
	
	for loc.log_row in (select s.id, c.quantity , ms."start", ms.destination, s.speed, s.capacity, ms.arrives_at from world.moving_ships ms join world.ships s on ms.ship = s.id join world.cargo c on ms.ship = c.ship where s.player = think.player_id)
	loop
		raise notice 'moving_ship = %', loc.log_row;
	end loop;

	for loc.log_row in (select s.id, ts.island, ts.finish_time, s.speed, s.capacity from world.transferring_ships ts join world.ships s on ts.ship = s.id where s.player =  think.player_id)
	loop
		raise notice 'transferring_ship = %', loc.log_row;
	end loop;

	for loc.log_row in (select c.id, c.contractor, c.quantity, c.payment_sum, c2.island, c2.item from world.contracts c join world.contractors c2 on c.contractor = c2.id)
	loop
		raise notice 'contract = %', loc.log_row;
	end loop;

	FOR loc.log_row IN (select * from world.ships s join world.cargo c on s.id = c.ship where s.player = think.player_id)
	loop
		raise notice 'ship = %', loc.log_row;
	end loop;

	
    if currentTime > 900 then
        for rows in select b.price_per_unit, least(a.quantity, b.quantity) as quan, b.quantity as sale_quan, b.id, a.player, least(a.quantity, b.quantity) * b.price_per_unit as q
                    from world.storage a
                    join world.contractors b on b.island = a.island and b.item = a.item and b.type = 'customer' and a.player = player_id
                    order by q desc
        loop
            if rows.sale_quan > 300 or rows.price_per_unit > 31 or currentTime > 80000 then
                insert into actions.offers(contractor, quantity) values(rows.id, rows.quan);
            end if;
        end loop;
    end if;


    for sh in select b.id, a.island, c.item, n.x, n.y, b.capacity, b.speed, smf.time as is_move, c.quantity
        from world.parked_ships a
        join world.ships b on b.id = a.ship and b.player = player_id
        join world.islands n on n.id = a.island
        left join events.ship_move_finished smf on smf.ship = a.ship
        left join world.cargo c on c.ship = a.ship
        order by b.capacity * b.speed desc
    loop
        if sh.is_move > 0 and sh.quantity > 0 then
            insert into actions.transfers values(sh.id, sh.item, sh.quantity, 'unload');
        elsif sh.quantity > 0 then
            select to_island, contractor into rows from traffic where ship = sh.id limit 1;
            insert into actions.ship_moves(ship, destination) values (sh.id, rows.to_island);
            insert into actions.offers(contractor, quantity) values(rows.contractor, sh.quantity);
            update world.contractors set quantity = quantity - sh.quantity where id = rows.contractor;
        else
            if sh.is_move > 0 then
                select a.item, a.contractor, a.quantity as q, b.quantity, least(a.quantity, b.quantity) as quan into rows from traffic a 
                    join world.storage b on b.island = a.island and b.item = a.item and a.ship = sh.id and b.player = player_id limit 1;
                if rows.quan > 0 then
                    insert into actions.transfers values(sh.id, rows.item, rows.quan, 'load');
                    insert into actions.offers(contractor, quantity) values(rows.contractor, rows.quan);
                    update world.contractors set quantity = quantity - rows.quan where id = rows.contractor;
                    update world.storage set quantity = quantity - rows.quan where island = sh.island and item = rows.item;
                    continue;
                end if;
            end if;

            select a.id as id, b.id as bid, a.island, b.island as to_island, a.item, b.quantity as sale_quan, least(a.quantity, sh.capacity) as quan, b.price_per_unit,
                (b.price_per_unit - a.price_per_unit)*least(a.quantity, sh.capacity) / (100 + least(a.quantity, sh.capacity)*2 +
                ( least(abs(sh.x - n.x), 1000 - abs(sh.x - n.x)) + least(abs(sh.y - n.y), 1000 - abs(sh.y - n.y)) + least(abs(n.x - m.x), 1000 - abs(n.x - m.x)) + least(abs(n.y - m.y), 1000 - abs(n.y - m.y)) ) / sh.speed) as q
                    into rows from world.contractors a
                    join world.contractors b on b.item = a.item and b.type = 'customer' and a.type = 'vendor'
                    join world.islands n on n.id = a.island
                    join world.islands m on m.id = b.island
                    where (b.price_per_unit - a.price_per_unit) > 0 and a.quantity > 10
                    order by q desc limit 1;

            rows.quan := floor(rows.quan);
            if rows.quan > 0 then
                insert into actions.offers(contractor, quantity) values(rows.id, rows.quan);
                if rows.sale_quan > 300 or rows.price_per_unit > 26 then
                    insert into actions.offers(contractor, quantity) values(rows.bid, rows.quan);
                end if;

                delete from traffic where ship = sh.id;
                insert into traffic(ship, item, island, to_island, contractor, quantity) values(sh.id, rows.item, rows.island, rows.to_island, rows.bid, rows.quan);
                update world.contractors set quantity = quantity - rows.quan where id in (rows.id, rows.bid);

                if sh.island = rows.island then
                    insert into actions.transfers values(sh.id, rows.item, rows.quan, 'load');
                else
                    insert into actions.ship_moves(ship, destination) values (sh.id, rows.island);
                end if;
            else
                insert into actions.wait(until) values(currentTime + 100);
            end if;
        end if;
    end loop;
END $$;
