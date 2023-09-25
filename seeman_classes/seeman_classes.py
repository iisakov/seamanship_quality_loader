class Island:
    def __init__(self, island_id: int, x: float, y: float):
        self._island_id = int(island_id)
        self._x = float(x)
        self._y = float(y)

    def get_point(self):
        return self._x, self._y

    def get_x(self):
        return self._x

    def get_y(self):
        return self._y

    def get_id(self):
        return self._island_id


class Contract:
    def __init__(self, contract_id: int, contractor_id: int, quantity: float, payment_sum: float, island_id: int, item_id: int, islands: list[Island]):
        for island in islands:
            if island.get_id() == int(island_id):
                self._x = float(island.get_x())
                self._y = float(island.get_y())
        self._contract_id = contract_id
        self._contractor_id = int(contractor_id)
        self._island_id = int(island_id)
        self._item_id = int(item_id)
        self._quantity = float(quantity)
        self._payment_sum = float(payment_sum)

    def __str__(self):
        return f'contract: {self._contract_id}, contractor: {self._contractor_id},  island: {self._island_id}, quantity: {self._quantity}, payment_sum: {self._payment_sum}'

    def get_point(self):
        return self._x, self._y

    def get_x(self):
        return self._x

    def get_y(self):
        return self._y

    def get_island(self):
        return str(self._island_id)

    def get_item(self):
        return str(self._item_id)

    def get_quantity(self):
        return self._quantity

    def get_payment_sum(self):
        return self._payment_sum

    def get_price(self):
        return self._payment_sum / self._quantity

    def get_id(self):
        return str(self._contractor_id)

    def get_contractor(self):
        return str(self._contract_id)


class Contractor:
    def __init__(self, contractor_id: int, c_type: str, island_id: int, item_id: int,
                 quantity: float, price: float, x: float, y: float, islands: list[Island]):
        for island in islands:
            if island.get_id() == int(island_id):
                self._x = float(island.get_x())
                self._y = float(island.get_y())
        self._contractor_id = int(contractor_id)
        self._type = c_type
        self._island_id = int(island_id)
        self._item_id = int(item_id)
        self._quantity = float(quantity)
        self._price = float(price)

    def __str__(self):
        return f'id: {self._contractor_id}, island: {self._island_id}, quantity: {self._quantity}, price: {self._price}'

    def get_point(self):
        return self._x, self._y

    def get_x(self):
        return self._x

    def get_y(self):
        return self._y

    def get_island(self):
        return str(self._island_id)

    def get_quantity(self):
        return self._quantity

    def get_price(self):
        return self._price

    def get_total_cost(self):
        return self._price * self._quantity

    def get_id(self):
        return str(self._contractor_id)

    def get_type(self):
        return self._type


class Warehouse:
    def __init__(self, island_id: int, quantity: float, islands: list[Island]):
        for island in islands:
            if island.get_id() == int(island_id):
                self._x = float(island.get_x())
                self._y = float(island.get_y())
        self._island_id = int(island_id)
        self._quantity = float(quantity)

    def __str__(self):
        return f'island: {self._island_id}, quantity: {self._quantity}'

    def get_point(self):
        return self._x, self._y

    def get_x(self):
        return self._x

    def get_y(self):
        return self._y

    def get_island(self):
        return str(self._island_id)

    def get_quantity(self):
        return self._quantity


class Move:
    def __init__(self, island_start_id: int, island_end_id: int, c_type: str, islands: list[Island]):
        self._type = c_type
        self._island_start = island_start_id
        self._island_end = island_end_id
        for island in islands:
            if island.get_id() == int(island_start_id):
                self._start_x = float(island.get_x())
                self._start_y = float(island.get_y())
            if island.get_id() == int(island_end_id):
                self._end_x = float(island.get_x())
                self._end_y = float(island.get_y())

    def __str__(self):
        return f'island_start: {self._island_start}, _island_end: {self._island_end}, c_type: {self._type}'

    def get_start_point(self):
        return self._start_x, self._start_y

    def get_end_point(self):
        return self._end_x, self._end_y

    def get_line(self):
        return [(self._start_x, self._start_y), (self._end_x, self._end_y)]

    def get_start_x(self):
        return self._start_x

    def get_start_y(self):
        return self._start_y

    def get_end_x(self):
        return self._end_x

    def get_end_y(self):
        return self._end_y

    def get_type(self):
        return self._type


class Load:
    def __init__(self, island_id: int, ship_id: int, islands: list[Island]):
        self._island = island_id
        self._ship_id = ship_id
        for island in islands:
            if island.get_id() == int(island_id):
                self._x = float(island.get_x())
                self._y = float(island.get_y())

    def __str__(self):
        return f'island: {self._island}, ship_id {self._ship_id}, x: {self._x}, y: {self._y}'

    def get_x(self):
        return self._x

    def get_y(self):
        return self._y


class Unload:
    def __init__(self, island_id: int, islands: list[Island]):
        self._island = island_id
        for island in islands:
            if island.get_id() == int(island_id):
                self._x = float(island.get_x())
                self._y = float(island.get_y())

    def __str__(self):
        return f'island: {self._island}, x: {self._x}, y: {self._y}'

    def get_x(self):
        return self._x

    def get_y(self):
        return self._y


class Sell:
    def __init__(self, island_id: int, quantity: float, price_per_unit: float, islands: list[Island]):
        self._quantity = float(quantity)
        self._price_per_unit = float(price_per_unit)
        self._island = island_id
        for island in islands:
            if island.get_id() == int(island_id):
                self._x = float(island.get_x())
                self._y = float(island.get_y())

    def __str__(self):
        return f'island: {self._island}, x: {self._x}, y: {self._y}, quantity: {self._quantity}, price_per_unit: {self._price_per_unit}'

    def get_quantity(self):
        return self._quantity

    def get_price_per_unit(self):
        return self._price_per_unit

    def get_total_cost(self):
        return self._quantity*self._price_per_unit

    def get_x(self):
        return self._x

    def get_y(self):
        return self._y


class Buy:
    def __init__(self, island_id: int, quantity: float, price_per_unit: float, islands: list[Island]):
        self._island = island_id
        self._quantity = float(quantity)
        self._price_per_unit = float(price_per_unit)
        for island in islands:
            if island.get_id() == int(island_id):
                self._x = float(island.get_x())
                self._y = float(island.get_y())

    def __str__(self):
        return f'island: {self._island}, x: {self._x}, y: {self._y}, quantity: {self._quantity}, price_per_unit: {self._price_per_unit}'

    def get_quantity(self):
        return self._quantity

    def get_price_per_unit(self):
        return self._price_per_unit

    def get_total_cost(self):
        return self._quantity*self._price_per_unit

    def get_x(self):
        return self._x

    def get_y(self):
        return self._y


class ParkedShip:
    def __init__(self, ship_id: int, quantity: float, island_id: int, speed: float, capacity: float, islands: list[Island]):
        self._island = island_id
        self._ship_id = ship_id
        self._quantity = quantity
        self._speed = speed
        self._capacity = capacity
        for island in islands:
            if island.get_id() == int(island_id):
                self._x = float(island.get_x())
                self._y = float(island.get_y())

    def __str__(self):
        return f'ship_id: {self._ship_id}, quantity: {self._quantity}, island_id: {self._island}, speed: {self._speed}, capacity: {self._capacity}'

    def get_quantity(self):
        return self._quantity

    def get_x(self):
        return self._x

    def get_y(self):
        return self._y

    def get_point(self):
        return self._x, self._y


class MovingShip:
    def __init__(self, ship_id: int, quantity: float, island_start_id: int, island_end_id: int, speed: float, capacity: float, arrives_at: float, islands: list[Island]):
        self._island_start = island_start_id
        self._island_end = island_end_id
        self._ship_id = ship_id
        self._quantity = float(quantity)
        self._speed = speed
        self._capacity = capacity
        self._arrives_at = arrives_at
        for island in islands:
            if island.get_id() == int(island_start_id):
                self._start_x = float(island.get_x())
                self._start_y = float(island.get_y())
            if island.get_id() == int(island_end_id):
                self._end_x = float(island.get_x())
                self._end_y = float(island.get_y())

    def __str__(self):
        return f'ship_id: {self._ship_id}, quantity: {self._quantity}, island_start_id: {self._island_start}, island_end_id: {self._island_end}, speed: {self._speed}, capacity: {self._capacity}, arrives_at: {self._arrives_at}'

    def get_quantity(self):
        return self._quantity

    def get_start_x(self):
        return self._start_x

    def get_start_y(self):
        return self._start_y

    def get_end_x(self):
        return self._end_x

    def get_end_y(self):
        return self._end_y

    def get_line(self):
        return [(self._start_x, self._start_y), (self._end_x, self._end_y)]


class TransferringShip:
    def __init__(self, ship_id: int, island_id: int, finish_time: float, speed: float, capacity: float, islands: list[Island]):
        self._island = island_id
        self._ship_id = ship_id
        self._speed = speed
        self._capacity = capacity
        self._finish_time = finish_time
        for island in islands:
            if island.get_id() == int(island_id):
                self._x = float(island.get_x())
                self._y = float(island.get_y())

    def __str__(self):
        return f'ship_id: {self._ship_id}, island: {self._island}, finish_time: {self._finish_time}, speed: {self._speed}, capacity: {self._capacity}'
