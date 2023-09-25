#! venv/bin/python
import datetime
import math
import random

from seeman_classes.seeman_classes import *
from sys import argv

from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont


def make_gif(file_name: str, gif_name: str, mg: str = 'да'):
    islands = []
    myMoney: float = 0.0
    buy_price: float = 0.0
    sell_price: float = 0.0
    cap = Image.open('img/photo_2023-08-24_12-16-34.jpg')
    cap = cap.resize((int(cap.size[0]*0.2), int(cap.size[1]*0.2)))
    buy_quantity = []
    sell_quantity = []
    offers_reject = []
    total_buy_quantity: float = 0.0
    total_sell_quantity: float = 0.0
    total_buy_cost: float = 0.0
    total_sell_cost: float = 0.0
    storage_quantities_1:list = []
    storage_quantities_2: list = []
    moneys:list = []
    storage_quantity_1: float = 0.0
    storage_quantity_2: float = 0.0
    all_storage_quantities:list = []
    all_storage_quantity: float = 0.0
    item_names = ['тряпьё', 'лом', 'оружие', 'лишние ifы', 'открывающие скобки', 'эль', 'байты', 'printы для отладки', 'открывающие скобки', 'Недостоющие ;']
    cap_says = ['АРГХХХ!!!!!!!!!!!!!',
                'Сухопутные крысы!!',
                'ПЭ ЭЛЬ ПЭ ЖЕ ЭСКЮЭЛЬ!!!',
                f'Жизнь пирата! Это и бремя...\n'
                f'...и благословение небес!!!',
                'Земля!!!!']
    cap_says_event = {'Нет контрактов': ['Никто не хочет покупать этот хлам!!!!',
                                         'Эй там, на берегу, кончай грабить!!!'],
                      'На складах нет товара': ['Всем эля, за счёт Капитана!!!',
                                                'Кажется кто-то не работает!!!',
                                                f'Сейчас я тебя раздену и продам в рабство,\n'
                                                f'Если на складах не появится товар'],
                      'Деньги ушли в минут': ['Ещё немного и команда Начнёт бунт!', 'Мы должны каждому в этой бухте']}
    say_count = 0
    contract_num = 1

    contractars = []

    game_step: int = 0
    frames = []
    step_num_row: int = 0

    start_row: int = 0
    end_row: int = start_row + 50000

    vendor_color = (255, 100, 100)
    customer_color = (100, 255, 100)
    warehouse_color = (100, 100, 255)
    contract_color = (0, 100, 0)
    board_size = (1000, 1200)

    draw_wave = True
    delta = 10
    board = Image.new('RGB', board_size, (0, 0, 0))
    draw = ImageDraw.Draw(board)
    font = ImageFont.truetype("OpenSans-Regular.ttf", 20)
    # print('собираем острова')
    with open(file_name, 'r') as f:
        for num_row, row in enumerate(f.readlines()):
            raw = row.split(':')[-1].strip()
            item = raw.split(' ')[0]
            value = raw.split(' ')[-1][1:-1].split(',')
            if item == 'island':
                islands.append(Island(*value))
            elif item == 'contractor':
                contractars.append(Contractor(*value, islands=islands))

    if mg == 'да':
        print('Колдуем фреймы')
        with open(file_name, 'r') as f:
            for num_row, row in enumerate(f.readlines()[start_row:] if end_row == 0 else f.readlines()[start_row:end_row]):
                raw = row.split(':')[-1].strip()
                if raw == '-':
                    board.paste(cap, (850, 1000))
                    if game_step % 50 == 0:
                        say_count = 0
                        say = cap_says[random.randint(0, len(cap_says))-1]
                    if contract_num == 0:
                        say_count = 0
                        say = cap_says_event['Нет контрактов'][random.randint(0, len(cap_says_event['Нет контрактов'])) - 1]
                    if float(all_storage_quantity) <= 100:
                        say_count = 0
                        say = cap_says_event['На складах нет товара'][random.randint(0, len(cap_says_event['На складах нет товара']))-1]
                    if float(myMoney) <= 0:
                        say_count = 0
                        say = cap_says_event['Деньги ушли в минут'][random.randint(0, len(cap_says_event['Деньги ушли в минут']))-1]
                    say_count += 1
                    if say_count > 20:
                        say = ''
                    if say != '':
                        draw.polygon([(990-((len(say)*12) if '\n' not in say else (len(say)*6)), 930),
                                         (990, 930),
                                         (990, 1010),
                                         (990-((len(say)*12) if '\n' not in say else (len(say)*6))/2, 1010),
                                         (945, 1100),
                                         (970-((len(say)*12) if '\n' not in say else (len(say)*6))/2, 1010),
                                         (990-((len(say)*12) if '\n' not in say else (len(say)*6)), 1010)],
                                     (30, 15, 10),
                                     outline=(50, 100, 50))
                    draw.text((1000 - ((len(say) * 12) if '\n' not in say else (len(say) * 6)), 950), say, font=font)
                    for num_islands, island in enumerate(islands):
                        draw.text(xy=(island.get_x(), island.get_y() - 20), text=str(island.get_id()), font=font, fill=(255, 255, 255))

                    draw.text((10, 1010), 'game_step: ' + str(game_step), font=font)
                    draw.text((500, 1005), 'Наши контракты, Капитан:', font=font, fill=customer_color)
                    # draw.text((500, 1050), 'sell_price: ' + str(sell_price), font=font, fill=customer_color)
                    draw.text((10, 1070), 'vendor', font=font, fill=vendor_color)
                    draw.text((10, 1090), 'customer', font=font, fill=customer_color)
                    draw.text((10, 1110), 'warehouse', font=font, fill=warehouse_color)
                    draw.text((10, 1130), 'contract', font=font, fill=contract_color)
                    step_num_row = 0
                    frames.append(board.copy())
                    draw.polygon([(0, 1200), (1000, 1200), (1000, 0), (0, 0)], (25, 25, 100))
                    draw_wave = True
                    contract_num = 0
                    for num_islands, island in enumerate(islands):
                        draw.ellipse(xy=[(island.get_x() - 2, island.get_y() - 2),
                                         (island.get_x() + 2, island.get_y() + 2)],
                                     fill=(0, 0, 0), outline=(255, 255, 255), width=1)

                    game_step += 1
                    contractor = []
                    warehouse = []
                    print(f'{file_name} ход:', game_step)
                else:
                    step_num_row += 1
                    item = raw.split(' ')[0]
                    value = raw.split(' ')[-1][1:-1].split(',')
                    if item == 'island':
                        islands.append(Island(*value))
                    elif item == 'all_storage_quantity':
                        all_storage_quantity = value[0]
                        draw.text((10, 1030), 'all_storage_quantity: ' + str(round(float(all_storage_quantity), 2)), font=font, fill='yellow')

                    elif item == 'warehouse':
                        color = warehouse_color
                        warehouse = Warehouse(*value, islands=islands)
                        draw.ellipse(xy=[(warehouse.get_x() - math.sqrt((warehouse.get_quantity()) / 2), warehouse.get_y() - math.sqrt((warehouse.get_quantity()) / 2)),
                                         (warehouse.get_x() + math.sqrt((warehouse.get_quantity()) / 2), warehouse.get_y() + math.sqrt((warehouse.get_quantity()) / 2))],
                                     fill=color,
                                     outline=(255, 255, 255), width=1)
                        draw.text((1100, 20 * step_num_row), f'{warehouse}', font=font, fill=color)

                    elif item == 'contractor':
                        contractor = Contractor(*value, islands=islands)
                        if contractor.get_type() == 'vendor':
                            color = vendor_color
                        else:
                            color = customer_color
                        draw.ellipse(xy=[(contractor.get_x() - math.sqrt((contractor.get_quantity()) / 2), contractor.get_y() - math.sqrt((contractor.get_quantity()) / 2)),
                                         (contractor.get_x() + math.sqrt((contractor.get_quantity()) / 2), contractor.get_y() + math.sqrt((contractor.get_quantity()) / 2))],
                                     fill=color,
                                     outline=(255, 255, 255),
                                     width=1)
                        # draw.text((1100, 20*step_num_row), f'{contractor}', font=font, fill=color)
                        x = contractor.get_x()
                        y = contractor.get_y()
                        xy = (x + (30 if contractor.get_type() == 'customer' else 40), y-20)
                        delta_xy = (x + (30 if contractor.get_type() == 'customer' else 40), y)
                        draw.arc(xy=(xy, delta_xy), start=-45, end=45, fill=color, width=3)
                        # draw.text(xy=(contractor.get_x(), contractor.get_y() - 20), text=str(contractor.get_island()), font=font, fill=color)

                    elif item == 'contract':
                        contract = Contract(*value, islands=islands)
                        color = (0, 100, 0)
                        # draw.text((450, 1010 + 25 * contract_num), f'{contract.get_id()}', font=font, fill=color)
                        item_name = item_names[contract_num%len(item_names)]
                        if contract_num < 6:
                            draw.text((400-(len(item_name)*10), 1030 + 25 * contract_num), f'{item_name}', font=font, fill=customer_color)
                            draw.polygon([(450, 1030 + 25 * contract_num),
                                             (450+int(contract.get_quantity()/10), 1030 + 25 * contract_num),
                                             (450+int(contract.get_quantity()/10), 1050 + 25 * contract_num),
                                             (450, 1050 + 25 * contract_num)], color, outline=(100, 100, 100))
                        else:
                            draw.text((400+300-(len(item_name)*10), 1030 + 25 * (contract_num-6)), f'{item_name}', font=font, fill=customer_color)
                            draw.polygon([(450+300, 1030 + 25 * (contract_num-6)),
                                             (450+300+int(contract.get_quantity()/10), 1030 + 25 * (contract_num-6)),
                                             (450+300+int(contract.get_quantity()/10), 1050 + 25 * (contract_num-6)),
                                             (450+300, 1050 + 25 * (contract_num-6))],
                                         color, outline=(100, 100, 100))

                        contract_num += 1

                        draw.ellipse(xy=[(contract.get_x() - math.sqrt((contract.get_quantity()) / 10),
                                          contract.get_y() - math.sqrt((contract.get_quantity()) / 10)),
                                         (contract.get_x() + math.sqrt((contract.get_quantity()) / 10),
                                          contract.get_y() + math.sqrt((contract.get_quantity()) / 10))],
                                     fill=color,
                                     outline=(0, 0, 0), width=1)
                        draw.text((1100, 20 * step_num_row), f'{contract}', font=font, fill=color)
                    elif item == 'move':
                        move = Move(*value, islands=islands)
                        if move.get_type() == 'vendor':
                            color = vendor_color
                        else:
                            color = customer_color
                        draw.line([move.get_start_point(), move.get_end_point()], color, 3)
                        draw.text((1100, 20 * step_num_row), f'move: {move}', font=font, fill=color)

                    elif item == 'load':
                        load = Load(*value, islands=islands)
                        draw.text((load.get_x()+7, load.get_y()-50), 'L', font=font, fill=warehouse_color, align='center')
                        draw.text((1100, 20 * step_num_row), f'load: {load}', font=font, fill=warehouse_color)

                    elif item == 'unload':
                        unload = Unload(*value, islands=islands)
                        draw.text((unload.get_x(), unload.get_y()-50), 'U', font=font, fill=warehouse_color, align='center')
                        draw.text((1100, 20 * step_num_row), f'unload: {unload}', font=font, fill=warehouse_color)

                    elif item == 'buy':
                        buy = Buy(*value, islands=islands)
                        draw.text((buy.get_x()-10, buy.get_y()-50), 'B', font=font, fill=vendor_color, align='center')
                        draw.text((1100, 20 * step_num_row), f'buy: {buy}', font=font, fill=vendor_color)

                    elif item == 'sell':
                        sell = Sell(*value, islands=islands)
                        draw.text((sell.get_x()-10, sell.get_y()-50), 'S', font=font, fill=customer_color, align='center')
                        draw.text((1100, 20 * step_num_row), f'sell: {sell}', font=font, fill=customer_color)

                    elif item == 'parked_ship':
                        color = (128, 255, 0)
                        parked_ship = ParkedShip(*value, islands=islands)
                        # draw.text((sell.get_x()-10, sell.get_y()-50), 'S', font=font, fill=customer_color, align='center')
                        draw.text((1100, 20 * step_num_row), f'parked_ship: {parked_ship}', font=font, fill=color)

                    elif item == 'moving_ship':
                        moving_ship = MovingShip(*value, islands=islands)
                        color = (255, 255, 0)
                        # draw.text((sell.get_x()-10, sell.get_y()-50), 'S', font=font, fill=customer_color, align='center')
                        draw.line(moving_ship.get_line(), color, int(math.sqrt(moving_ship.get_quantity()/10)))
                        draw.text((1100, 20 * step_num_row), f'moving_ship: {moving_ship}', font=font, fill=color)

                    elif item == 'transferring_ship':
                        transferring_ship = TransferringShip(*value, islands=islands)
                        color = (0, 255, 128)
                        # draw.text((sell.get_x()-10, sell.get_y()-50), 'S', font=font, fill=customer_color, align='center')
                        # draw.line(moving_ship.get_line(), color, int(moving_ship.get_quantity() / 10))
                        draw.text((1100, 20 * step_num_row), f'transferring_ship: {transferring_ship}', font=font, fill=color)

                    elif item == 'currentTime':
                        currentTime = value[0] if value[0] != '' else 0
                        draw.text((10, 1050), 'currentTime: ' + str(round(float(currentTime), 2)), font=font, fill='yellow')
                    # elif item == 'base_island':
                    #     base_island = value[0] if value[0] != '' else 0
                    #     draw.text((500, 50), 'base_island: ' + base_island, font=font, fill='yellow')
                    elif item == 'base_item_1':
                        base_item_1 = value[0] if value[0] != '' else 0
                        draw.text((500, 1070), 'base_item: ' + base_item_1, font=font, fill='yellow')
                    elif item == 'base_item_2':
                        base_item_2 = value[0] if value[0] != '' else 0
                        draw.text((500, 1090), 'base_item: ' + base_item_2, font=font, fill='yellow')
                    elif item == 'myMoney':
                        myMoney = float(value[0]) if value[0] != '' else 0
                        draw.text((200, 1010), 'myMoney: ' + str(round(myMoney, 2)), font=font)
                    elif item == 'game_step_num':
                        game_step_num = value[0] if value[0] != '' else 0
                        draw.text((500, 1110), 'phase: ' + game_step_num, font=font, fill='yellow')
                    # elif item == 'buy_price':
                    #     buy_price = value[0] if value[0] != '' else 0
                    # elif item == 'sell_price':
                    #     sell_price = float(value[0]) if value[0] != '' else 0
                    if draw_wave:
                        for _ in range(5):
                            size_wave = 10
                            # wave_x = 500
                            # wave_y = 500
                            wave_x = random.randint(10, 990)
                            wave_y = random.randint(10, 990)
                            for w in range(random.randint(2, 5)):
                                draw.arc((wave_x+size_wave*w*2, wave_y, (wave_x+size_wave*w*2) + size_wave*2, wave_y+size_wave*2), 0, 180, fill=(50, 100, 50), width=3)
                        draw_wave = False

        gif_name = f'{gif_name}_{datetime.datetime.now()}'
        print(f'{file_name} собираем gif {gif_name}')
        frames[0].save(f'gif/{gif_name}.gif', save_all=True, append_images=frames[1:], optimize=True, duration=200, loop=0)



    else:
        type_item_storage = 0
        start_row: int = 0
        end_row: int = 0
        # print('не делаем гиф, а делаем график')
        with open(file_name, 'r') as f:
            for num_row, row in enumerate(f.readlines()[start_row:] if end_row == 0 else f.readlines()[start_row:end_row]):
                raw = row.split(':')[-1].strip()
                if raw == '-':
                    game_step += 1
                    # print(f'{file_name} ход:', game_step)
                    pass
                else:
                    step_num_row += 1
                    item = raw.split(' ')[0]
                    value = raw.split(' ')[-1][1:-1].split(',')
                    if item == 'island':
                        islands.append(Island(*value))
                    elif item == 'warehouse':
                        warehouse = Warehouse(*value, islands=islands)
                        # print(warehouse)
                    elif item == 'contractor':
                        contractor = Contractor(*value, islands=islands)
                        # print(contractor)
                    elif item == 'move':
                        move = Move(*value, islands=islands)
                        # print(move)
                    elif item == 'load':
                        load = Load(*value, islands=islands)
                        # print(load)
                    elif item == 'unload':
                        unload = Unload(*value, islands=islands)
                        # print(unload)
                    elif item == 'buy':
                        buy = Buy(*value, islands=islands)
                        buy_quantity.append(buy)
                        total_buy_quantity += buy.get_quantity()
                        total_buy_cost += buy.get_total_cost()
                        # print(buy)
                    elif item == 'sell':
                        sell = Sell(*value, islands=islands)
                        total_sell_quantity += sell.get_quantity()
                        total_sell_cost += sell.get_total_cost()
                        # print(sell)
                    elif item == 'parked_ship':
                        parked_ship = ParkedShip(*value, islands=islands)
                        # print(parked_ship)
                    elif item == 'moving_ship':
                        moving_ship = MovingShip(*value, islands=islands)
                        # print(moving_ship)
                    elif item == 'transferring_ship':
                        transferring_ship = TransferringShip(*value, islands=islands)
                        # print(transferring_ship)
                    elif item == 'currentTime':
                        currentTime = value[0] if value[0] != '' else 0
                        # print(currentTime)
                    elif item == 'base_island':
                        base_island = value[0] if value[0] != '' else 0
                        # print(base_island)
                    elif item == 'base_item':
                        base_item = value[0] if value[0] != '' else 0
                        # print(base_item)
                    elif item == 'myMoney':
                        myMoney = value[0] if value[0] != '' else 0
                        moneys.append((game_step, value[0] if value[0] != '' else 0))
                        # print(myMoney)
                    elif item == 'game_step_num':
                        game_step_num = value[0] if value[0] != '' else 0
                        # print(game_step_num)
                    elif item == 'buy_price':
                        buy_price = value[0] if value[0] != '' else 0
                        # print(buy_price)
                    elif item == 'sell_price':
                        sell_price = value[0] if value[0] != '' else 0
                        # print(sell_price)

                    elif item == 'event_contract_completed':
                        event_contract_completed = value[0] if value[0] != '' else 0
                        sell_quantity.append(event_contract_completed)
                        # print(event_contract_completed)
                    elif item == 'event_contract_start':
                        event_contract_completed = value[0] if value[0] != '' else 0
                    elif item == 'event_contract_offer_rejected':
                        event_contract_offer_rejected = value[0] if value[0] != '' else 0
                        offers_reject.append(event_contract_offer_rejected)
                        # print(event_contract_offer_rejected)
                    elif item == 'all_storage_quantity':
                        if type_item_storage == 0:
                            storage_quantities_1.append((game_step, value[0]))
                            type_item_storage = 1
                        else:
                            storage_quantities_2.append((game_step, value[0]))
                            type_item_storage = 0
                        all_storage_quantity = value[0]
    return {'myMoney': myMoney,
            'storage_quantities_1': storage_quantities_1,
            'storage_quantities_2': storage_quantities_2,
            'moneys': moneys}


if __name__ == '__main__':
    import os

    import matplotlib.pyplot as plt
    # for num, filename in enumerate(os.listdir('log/')):
    #     result = make_gif(f'log/{filename}', "gif_name", 'нет')
    #     #
        # import matplotlib.pyplot as plt
        # x = [float(x[0]) for x in result['storage_quantities_1']]
        # y = [float(y[1]) for y in result['storage_quantities_1']]
        # plt.plot(x, y)
        # plt.grid(True)
        # plt.savefig(f'graf/storage_quantities_1/{filename}_storage_quantities_1.png')
        #
        # plt.clf()
        #
        # x = [float(x[0]) for x in result['storage_quantities_2']]
        # y = [float(y[1]) for y in result['storage_quantities_2']]
        # plt.plot(x, y)
        # plt.grid(True)
        # plt.savefig(f'graf/storage_quantities_2/{filename}_storage_quantities_2.png')
        #
        # plt.clf()
        #
    #     x = [float(x[0]) for x in result['moneys']]
    #     y = [float(y[1]) for y in result['moneys']]
    #     plt.plot(x, y)
    #     plt.grid(True)
    # plt.savefig(f'graf/moneys/{filename}_moneys.png')



    # # zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
    # filename = 'log_1001.log'
    # result = make_gif(f'log/{filename}', "gif_name", 'нет')
    #
    # x = [float(x[0]) for x in result['storage_quantities_1']]
    # y = [float(y[1]) for y in result['storage_quantities_1']]
    # plt.plot(x, y)
    # plt.grid(True)
    # plt.savefig(f'graf/storage_quantities_1/{filename}_storage_quantities_1.png')
    #
    # plt.clf()
    #
    # x = [float(x[0]) for x in result['storage_quantities_2']]
    # y = [float(y[1]) for y in result['storage_quantities_2']]
    # plt.plot(x, y)
    # plt.grid(True)
    # plt.savefig(f'graf/storage_quantities_2/{filename}_storage_quantities_2.png')
    #
    # plt.clf()
    #
    # x = [float(x[0]) for x in result['moneys']]
    # y = [float(y[1]) for y in result['moneys']]
    # plt.plot(x, y)
    # plt.grid(True)
    # plt.savefig(f'graf/moneys/{filename}_moneys.png')
    #
    # plt.clf()

    avr = 0
    result = []

    # for num, filename in enumerate(os.listdir('log/')):
        # print(filename, num, make_gif(f'log/{filename}', "gif_name", 'нет'))
        # result.append(float(make_gif(f'log/{filename}', "gif_name", 'нет')))
    filename = 'log_101.log'
    make_gif(f'log/{filename}', "gif_name", 'да')
    # for i in result:
    #     avr += float(i)
    # print()
    # print(min(result), '[:|||:]', avr/len(result), '[:|||:]', max(result))
    # print()
