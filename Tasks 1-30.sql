--1. Find the model number, speed and hard drive capacity for all the PCs with prices below $500.
--Result set: model, speed, hd.
SELECT model, speed, hd FROM pc
WHERE price < 500

--2. List all printer makers. Result set: maker. 
SELECT DISTINCT maker FROM product
WHERE type='printer'

--3. Find the model number, RAM and screen size of the laptops with prices over $1000. 
SELECT model, ram, screen 
FROM laptop WHERE price > 1000

--4. Find all records from the Printer table containing data about color printers. 
SELECT * FROM printer
WHERE color = 'y'

--5. Find the model number, speed and hard drive capacity
--of PCs cheaper than $600 having a 12x or a 24x CD drive.
SELECT model, speed, hd 
FROM pc WHERE (cd='12x' OR cd='24x') AND price < 600

--6. For each maker producing laptops with a hard drive capacity of 10 Gb or higher, find the speed of such laptops.
--Result set: maker, speed. 
SELECT DISTINCT maker, speed
FROM product INNER JOIN laptop ON product.model=laptop.model
WHERE hd >= 10
ORDER BY maker

--7. Get the models and prices for all commercially available products (of any type) produced by maker B.
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

--8. Find the makers producing PCs but not laptops. 
SELECT maker FROM product WHERE type='pc'
EXCEPT
SELECT maker FROM product WHERE type='laptop'

--9. Find the makers of PCs with a processor speed of 450 MHz or more. Result set: maker. 
SELECT DISTINCT maker 
FROM product
INNER JOIN pc ON product.model=pc.model
WHERE speed >= 450

--10. Find the printer models having the highest price. Result set: model, price.
SELECT model, price FROM printer
WHERE price IN (SELECT MAX(price) FROM printer)

--11. Find out the average speed of PCs. 
SELECT AVG(speed) FROM pc

--12. Find out the average speed of the laptops priced over $1000. 
SELECT AVG(speed) FROM laptop
WHERE price > 1000

--13. Find out the average speed of the PCs produced by maker A. 
SELECT AVG(speed) 
FROM pc INNER JOIN product ON pc.model=product.model
WHERE maker='A'

--14. For the ships in the Ships table that have at least 10 guns, get the class, name, and country. 
SELECT ships.class, name, country FROM ships
INNER JOIN classes ON ships.class=classes.class 
WHERE numGuns >=10

--15. Get hard drive capacities that are identical for two or more PCs.
--Result set: hd. 
SELECT hd FROM pc
GROUP BY hd
HAVING COUNT(model) >= 2

--16. Get pairs of PC models with identical speeds and the same RAM capacity. 
--Each resulting pair should be displayed only once, i.e. (i, j) but not (j, i).
--Result set: model with the bigger number, model with the smaller number, speed, and RAM. 
SELECT DISTINCT pc1.model, pc2.model, pc1.speed, pc2.ram FROM pc pc1
JOIN pc pc2
ON pc1.ram = pc2.ram
AND pc1.speed = pc2.speed
AND pc1.model > pc2.model

--17. Get the laptop models that have a speed smaller than the speed of any PC.
--Result set: type, model, speed. 
SELECT DISTINCT type, product.model, speed
FROM product INNER JOIN laptop ON product.model=laptop.model
WHERE speed<(SELECT MIN(pc.speed) FROM pc)

--18. Find the makers of the cheapest color printers.
--Result set: maker, price.
SELECT DISTINCT maker, price 
FROM product INNER JOIN printer ON product.model=printer.model
AND price = (SELECT MIN(price) FROM printer WHERE color='y')
AND color='y'

--19. For each maker having models in the Laptop table, find out the average screen size of the laptops he produces.
--Result set: maker, average screen size. 
SELECT maker, AVG(screen) 
FROM product INNER JOIN laptop ON product.model=laptop.model
GROUP BY maker

--20. Find the makers producing at least three distinct models of PCs.
--Result set: maker, number of PC models.
SELECT maker, COUNT(model)
FROM product
WHERE type = 'pc'
GROUP BY product.maker
HAVING COUNT (DISTINCT model) >= 3

--21. Find out the maximum PC price for each maker having models in the PC table. Result set: maker, maximum price.  
SELECT maker, MAX(price)
FROM product INNER JOIN pc ON product.model=pc.model
GROUP BY maker

--22. For each value of PC speed that exceeds 600 MHz, find out the average price of PCs with identical speeds.
--Result set: speed, average price. 
SELECT speed, AVG(price)
FROM pc
WHERE speed > 600
GROUP BY speed

--23. Get the makers producing both PCs having a speed of 750 MHz or higher and laptops with a speed of 750 MHz or higher.
--Result set: maker 
SELECT maker FROM product INNER JOIN pc ON product.model=pc.model
WHERE speed >= 750
INTERSECT
SELECT maker FROM product INNER JOIN laptop ON product.model=laptop.model
WHERE speed >= 750

--24. List the models of any type having the highest price of all products present in the database.  
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

--25. Find the printer makers also producing PCs with the lowest RAM capacity and the highest processor speed of all PCs having the lowest RAM capacity.
--Result set: maker. 
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

--26. Find out the average price of PCs and laptops produced by maker A.
--Result set: one overall average price for all items. 
WITH PRICE_CTE AS (
	SELECT price FROM pc INNER JOIN product ON pc.model=product.model 
	AND maker = 'A'
	UNION ALL 
	SELECT price FROM laptop INNER JOIN product ON laptop.model=product.model 
	AND maker = 'A')

--27. Find out the average hard disk drive capacity of PCs produced by makers who also manufacture printers.
--Result set: maker, average HDD capacity. 
SELECT maker, AVG(pc.hd) FROM Product JOIN pc ON Product.model = pc.model
WHERE product.maker IN (SELECT DISTINCT maker 
	FROM product WHERE product.type='printer')
GROUP BY maker

SELECT AVG(COALESCE(price,0)) AS avg_price FROM PRICE_CTE

--28. Using Product table, find out the number of makers who produce only one model.
SELECT COUNT(maker) FROM product
WHERE maker IN
    (
      SELECT maker FROM product
      GROUP BY maker
      HAVING COUNT(model) = 1
    )

--29. Under the assumption that receipts of money (inc) and payouts (out) 
--are registered not more than once a day for each collection point [i.e. the primary key consists of (point, date)], 
--write a query displaying cash flow data (point, date, income, expense).
--Use Income_o and Outcome_o tables. 
SELECT t1.point, t1.date, inc, out
FROM income_o t1 LEFT JOIN outcome_o t2 ON t1.point = t2.point
AND t1.date = t2.date
UNION
SELECT t2.point, t2.date, inc, out
FROM income_o t1 RIGHT JOIN outcome_o t2 ON t1.point = t2.point
AND t1.date = t2.date

--30. Under the assumption that receipts of money (inc) and payouts (out) can be registered any number of times a day for each collection point [i.e. the code column is the primary key], display a table with one corresponding row for each operating date of each collection point.
--Result set: point, date, total payout per day (out), total money intake per day (inc).
--Missing values are considered to be NULL. 
SELECT point, [date], SUM(sum_out), SUM(sum_inc)
FROM( 
SELECT point, [date], SUM(inc) AS sum_inc, NULL AS sum_out FROM Income GROUP BY point, [date]
UNION
SELECT point, [date], NULL AS sum_inc, SUM([out]) AS sum_out FROM Outcome GROUP BY point, [date] 
) AS t
GROUP BY point, [date] 
ORDER BY point