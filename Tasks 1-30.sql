--1. Найдите номер модели, скорость и размер жесткого диска 
--для всех ПК стоимостью менее 500 дол. 
--Вывести: model, speed и hd 
SELECT model, speed, hd FROM pc
WHERE price < 500

--2. Найдите производителей принтеров. Вывести: maker
SELECT DISTINCT maker FROM product
WHERE type='printer'

--3. Найдите номер модели, объем памяти и размеры экранов ПК-блокнотов, цена которых превышает 1000 дол.
SELECT model, ram, screen 
FROM laptop WHERE price > 1000

--4. Найдите все записи таблицы Printer для цветных принтеров. 
SELECT * FROM printer
WHERE color = 'y'

--5. Найдите номер модели, скорость и размер жесткого диска ПК, 
--имеющих 12x или 24x CD и цену менее 600 дол. 
SELECT model, speed, hd 
FROM pc WHERE (cd='12x' OR cd='24x') AND price < 600

--6. Для каждого производителя, выпускающего ПК-блокноты c объёмом жесткого диска не менее 10 Гбайт,
--найти скорости таких ПК-блокнотов. Вывод: производитель, скорость. 
SELECT DISTINCT maker, speed
FROM product INNER JOIN laptop ON product.model=laptop.model
WHERE hd >= 10
ORDER BY maker

--7.  Найдите номера моделей и цены всех имеющихся в продаже продуктов (любого типа) производителя B (латинская буква).
SELECT product.model, price
FROM product INNER JOIN laptop ON product.model=laptop.model
WHERE maker='B'
UNION
SELECT product.model, price
FROM product INNER JOIN pc ON product.model=pc.model
WHERE maker='B'
UNION
SELECT product.model, price
FROM product INNER JOIN printer ON product.model=printer.model
WHERE maker='B'

--8. Найдите производителя, выпускающего ПК, но не ПК-блокноты. 
SELECT maker FROM product WHERE type='pc'
EXCEPT
SELECT maker FROM product WHERE type='laptop'

--9.  Найдите производителей ПК с процессором не менее 450 Мгц. Вывести: Maker
SELECT DISTINCT maker 
FROM product
INNER JOIN pc ON product.model=pc.model
WHERE speed >= 450

--10.  Найдите модели принтеров, имеющих самую высокую цену. Вывести: model, price 
SELECT model, price FROM printer
WHERE price IN (SELECT MAX(price) FROM printer)

--11. Найдите среднюю скорость ПК.
SELECT AVG(speed) FROM pc

--12. Найдите среднюю скорость ПК-блокнотов, цена которых превышает 1000 дол. 
SELECT AVG(speed) FROM laptop
WHERE price > 1000

--13. Найдите среднюю скорость ПК, выпущенных производителем A. 
SELECT AVG(speed) 
FROM pc INNER JOIN product ON pc.model=product.model
WHERE maker='A'

--14. Найдите класс, имя и страну для кораблей из таблицы Ships, имеющих не менее 10 орудий. 
SELECT ships.class, name, country FROM ships
INNER JOIN classes ON ships.class=classes.class 
WHERE numGuns >=10

--15. Найдите размеры жестких дисков, совпадающих у двух и более PC. Вывести: HD
SELECT hd FROM pc
GROUP BY hd
HAVING COUNT(model) >= 2

--16. Найдите пары моделей PC, имеющих одинаковые скорость и RAM. 
--В результате каждая пара указывается только один раз, т.е. (i,j), но не (j,i), 
--Порядок вывода: модель с большим номером, модель с меньшим номером, скорость и RAM. 
SELECT DISTINCT pc1.model, pc2.model, pc1.speed, pc2.ram FROM pc pc1
JOIN pc pc2
ON pc1.ram = pc2.ram
AND pc1.speed = pc2.speed
AND pc1.model > pc2.model

--17. Найдите модели ПК-блокнотов, скорость которых меньше скорости каждого из ПК.
--Вывести: type, model, speed 
SELECT DISTINCT type, product.model, speed
FROM product INNER JOIN laptop ON product.model=laptop.model
WHERE speed<(SELECT MIN(pc.speed) FROM pc)

--18.  Найдите производителей самых дешевых цветных принтеров. 
--Вывести: maker, price 
SELECT DISTINCT maker, price 
FROM product INNER JOIN printer ON product.model=printer.model
AND price = (SELECT MIN(price) FROM printer WHERE color='y')
AND color='y'

--19. Для каждого производителя, имеющего модели в таблице Laptop, найдите средний размер экрана выпускаемых им ПК-блокнотов.
--Вывести: maker, средний размер экрана. 
SELECT maker, AVG(screen) 
FROM product INNER JOIN laptop ON product.model=laptop.model
GROUP BY maker

--20. Найдите производителей, выпускающих по меньшей мере три различных модели ПК. 
--Вывести: Maker, число моделей ПК. 
SELECT maker, COUNT(model)
FROM product
WHERE type = 'pc'
GROUP BY product.maker
HAVING COUNT (DISTINCT model) >= 3

--21. Найдите максимальную цену ПК, выпускаемых каждым производителем, у которого есть модели в таблице PC.
--Вывести: maker, максимальная цена. 
SELECT maker, MAX(price)
FROM product INNER JOIN pc ON product.model=pc.model
GROUP BY maker

--22. Для каждого значения скорости ПК, превышающего 600 МГц, определите среднюю цену ПК с такой же скоростью. 
--Вывести: speed, средняя цена. 
SELECT speed, AVG(price)
FROM pc
WHERE speed > 600
GROUP BY speed

--23. Найдите производителей, которые производили бы как ПК
--со скоростью не менее 750 МГц, так и ПК-блокноты со скоростью не менее 750 МГц.
--Вывести: Maker 
SELECT maker FROM product INNER JOIN pc ON product.model=pc.model
WHERE speed >= 750
INTERSECT
SELECT maker FROM product INNER JOIN laptop ON product.model=laptop.model
WHERE speed >= 750

--24. Перечислите номера моделей любых типов, имеющих самую высокую цену по всей имеющейся в базе данных продукции. 
WITH Product_Models_CTE(model, price)
AS
(SELECT model, price
 FROM pc
 UNION
 SELECT model, price
 FROM Laptop
 UNION
 SELECT model, price
 FROM Printer
)

SELECT model
FROM Product_Models_CTE
WHERE price = (
 SELECT MAX(price)
 FROM (
  SELECT price
  FROM pc
  UNION
  SELECT price
  FROM Laptop
  UNION
  SELECT price
  FROM Printer
  ) t2
 )

--25. Найдите производителей принтеров, которые производят ПК с наименьшим объемом RAM
--и с самым быстрым процессором среди всех ПК, имеющих наименьший объем RAM. 
--Вывести: Maker 
SELECT DISTINCT maker
FROM product
WHERE model IN (
SELECT model
FROM pc
WHERE ram = (
  SELECT MIN(ram)
  FROM pc
  )
AND speed = (
  SELECT MAX(speed)
  FROM pc
  WHERE ram = (
   SELECT MIN(ram)
   FROM pc
   )
  )
)
AND
maker IN (
SELECT maker
FROM product
WHERE type='printer'
)

--26. Найдите среднюю цену ПК и ПК-блокнотов, выпущенных производителем A (латинская буква).
--Вывести: одна общая средняя цена. 
WITH PRICE_CTE AS (
	SELECT price FROM pc INNER JOIN product ON pc.model=product.model 
	AND maker = 'A'
	UNION ALL 
	SELECT price FROM laptop INNER JOIN product ON laptop.model=product.model 
	AND maker = 'A')

--27. Найдите средний размер диска ПК каждого из тех производителей, которые выпускают и принтеры. 
--Вывести: maker, средний размер HD. 
SELECT maker, AVG(pc.hd) FROM Product JOIN pc ON Product.model = pc.model
WHERE product.maker IN (SELECT DISTINCT maker 
	FROM product WHERE product.type='printer')
GROUP BY maker

SELECT AVG(COALESCE(price,0)) AS avg_price FROM PRICE_CTE

--28. Используя таблицу Product, определить количество производителей, выпускающих по одной модели. 
SELECT COUNT(maker) FROM product
WHERE maker IN
    (
      SELECT maker FROM product
      GROUP BY maker
      HAVING COUNT(model) = 1
    )

--29. В предположении, что приход и расход денег на каждом пункте приема фиксируется не чаще одного раза в день [т.е. первичный ключ (пункт, дата)], 
--написать запрос с выходными данными (пункт, дата, приход, расход). 
--Использовать таблицы Income_o и Outcome_o. 
SELECT t1.point, t1.date, inc, out
FROM income_o t1 LEFT JOIN outcome_o t2 ON t1.point = t2.point
AND t1.date = t2.date
UNION
SELECT t2.point, t2.date, inc, out
FROM income_o t1 RIGHT JOIN outcome_o t2 ON t1.point = t2.point
AND t1.date = t2.date

--30. В предположении, что приход и расход денег на каждом пункте приема фиксируется произвольное число раз 
--(первичным ключом в таблицах является столбец code), 
--требуется получить таблицу, в которой каждому пункту за каждую дату выполнения операций будет соответствовать одна строка.
Вывод: point, date, суммарный расход пункта за день (out), суммарный приход пункта за день (inc). Отсутствующие значения считать неопределенными (NULL). 
SELECT point, [date], SUM(sum_out), SUM(sum_inc)
FROM( 
SELECT point, [date], SUM(inc) AS sum_inc, NULL AS sum_out FROM Income GROUP BY point, [date]
UNION
SELECT point, [date], NULL AS sum_inc, SUM([out]) AS sum_out FROM Outcome GROUP BY point, [date] 
) AS t
GROUP BY point, [date] 
ORDER BY point