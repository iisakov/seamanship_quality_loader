### В **2023** году участвоал в соревновании по написанию стратегии на **pl/pgSQL**.  
Здесь лежат все скрипты, которые удалось сохранить для истории.  
Место в турнирной таблице - **33** из **50** финалистов.  
Обшее количество участников - **150 аккаунтов**.  

![otput_1](https://github.com/iisakov/seamanship_quality_loader/assets/59264679/d3182d54-6030-4d40-8fb1-cfec69ab2ae9)  
Гифки большего размера gitHub не пропускает, так что это единственная гифка.

----

Сам код смотреть не стоит - в условиях нехватки времени и среднего знания **pl/pgSQL**, код весьмя удручает.
Первая версия решения [тут](https://github.com/iisakov/seamanship_quality_loader/blob/master/solution/seeman_v1.0.0.sql) отражает красату замысла, последняя версия [здесь](https://github.com/iisakov/seamanship_quality_loader/blob/master/solution/seeman_v4.0.0do.sql) показывает во что может превратиться файл без должного к нему отношения.  

Но есть прикольные гифки. Они сгенерированы на основе логфайлов локалранера чемпионата.  

**Локал ранер** организаторами был реализован ввиде **докер файла** с требованиями внешних файлов:
  - файл настроек - предоставлялся организаторами ([options/](https://github.com/iisakov/seamanship_quality_loader/tree/master/options))
  - файла стратегии - непосредственно скрипт победной стратегии ([solution/](https://github.com/iisakov/seamanship_quality_loader/tree/master/solution))
  
Так же среди файлов можно найти небольшой **bash-скрипт** [все скрипты](https://github.com/iisakov/seamanship_quality_loader/tree/master/run), в котором я запускал **несколько докер контейнеров на своём ноутбуке.** [запускающий несколько докеров](https://github.com/iisakov/seamanship_quality_loader/blob/master/run/run_p.sh).

![image](https://github.com/iisakov/seamanship_quality_loader/assets/59264679/ac721239-f911-46ae-8022-310f13e1b93f)  


## Правила игрового мира
В данной игре вам предстоит торговать и перевозить товары. Ищите выгодные контракты и заработайте больше ваших оппонентов для победы.

#### Действия участников игры
В качестве действий вы можете:

* Предлагать заключать контракты
* Грузить/разгружать корабли на островах
* Перемещать корабли между островами
* Ожидать определенного момента времени

Игровой сервер обрабатывает ваши действия в описанном выше порядке.

Для совершения действия необходимо записать соответствующую строку в таблицу 

Действия, которые вы желаете сделать. Данную схему вам предстоит заполнять данными.
CREATE SCHEMA actions;
#### Действия перемещения
```
CREATE TABLE "actions"."ship_moves" (
  "ship" INTEGER NOT NULL, --  Корабль
  "destination" INTEGER NOT NULL --  Целевой остров
);
```

#### Ожидание
```
CREATE TABLE "actions"."wait" (
    "id" SERIAL PRIMARY KEY NOT NULL, --  Идентификатор действия
    "until" DOUBLE PRECISION NOT NULL --  Момент времени в который ожидание должно закончиться
);
```

#### Предложения сделок с контрагентами
```
CREATE TABLE "actions"."offers" (
    "id" SERIAL PRIMARY KEY NOT NULL, --  Идентификатор предложения
    "contractor" INTEGER NOT NULL, --  Контрагент
    "quantity" DOUBLE PRECISION NOT NULL --  Количество покупаемого/продаваемого товара
);
```

#### Погрузка/разгрузка кораблей
```
CREATE TYPE "actions"."transfer_direction" AS ENUM ('load', 'unload');
CREATE TABLE "actions"."transfers" (
    "ship" INTEGER NOT NULL, --  Корабль, на/с которого переносить товар
    "item" INTEGER NOT NULL, --  Тип товара, который нужно переносить
    "quantity" DOUBLE PRECISION NOT NULL, --  Количество товара, которое нужно перенести
    "direction" "actions"."transfer_direction" NOT NULL --  Направление - погрузка/разгрузка
);
```



![image](https://github.com/iisakov/seamanship_quality_loader/assets/59264679/3e761c47-eb7a-4a82-88b3-3c150ec74012)  


Пруфы занимаемого места:  
![image](https://github.com/iisakov/seamanship_quality_loader/assets/59264679/973ab311-5a65-4f36-a1e4-6898d1d28883)  
 

