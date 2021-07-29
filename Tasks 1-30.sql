--1. ������� ����� ������, �������� � ������ �������� ����� 
--��� ���� �� ���������� ����� 500 ���. 
--�������: model, speed � hd 
SELECT model, speed, hd FROM pc
WHERE price < 500

--2. ������� �������������� ���������. �������: maker
SELECT DISTINCT maker FROM product
WHERE type='printer'

--3. ������� ����� ������, ����� ������ � ������� ������� ��-���������, ���� ������� ��������� 1000 ���.
SELECT model, ram, screen 
FROM laptop WHERE price > 1000

--4. ������� ��� ������ ������� Printer ��� ������� ���������. 
SELECT * FROM printer
WHERE color = 'y'

--5. ������� ����� ������, �������� � ������ �������� ����� ��, 
--������� 12x ��� 24x CD � ���� ����� 600 ���. 
SELECT model, speed, hd 
FROM pc WHERE (cd='12x' OR cd='24x') AND price < 600

--6. ��� ������� �������������, ������������ ��-�������� c ������� �������� ����� �� ����� 10 �����,
--����� �������� ����� ��-���������. �����: �������������, ��������. 
SELECT DISTINCT maker, speed
FROM product INNER JOIN laptop ON product.model=laptop.model
WHERE hd >= 10
ORDER BY maker

--7.  ������� ������ ������� � ���� ���� ��������� � ������� ��������� (������ ����) ������������� B (��������� �����).
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

--8. ������� �������������, ������������ ��, �� �� ��-��������. 
SELECT maker FROM product WHERE type='pc'
EXCEPT
SELECT maker FROM product WHERE type='laptop'

--9.  ������� �������������� �� � ����������� �� ����� 450 ���. �������: Maker
SELECT DISTINCT maker 
FROM product
INNER JOIN pc ON product.model=pc.model
WHERE speed >= 450

--10.  ������� ������ ���������, ������� ����� ������� ����. �������: model, price 
SELECT model, price FROM printer
WHERE price IN (SELECT MAX(price) FROM printer)

--11. ������� ������� �������� ��.
SELECT AVG(speed) FROM pc

--12. ������� ������� �������� ��-���������, ���� ������� ��������� 1000 ���. 
SELECT AVG(speed) FROM laptop
WHERE price > 1000

--13. ������� ������� �������� ��, ���������� �������������� A. 
SELECT AVG(speed) 
FROM pc INNER JOIN product ON pc.model=product.model
WHERE maker='A'

--14. ������� �����, ��� � ������ ��� �������� �� ������� Ships, ������� �� ����� 10 ������. 
SELECT ships.class, name, country FROM ships
INNER JOIN classes ON ships.class=classes.class 
WHERE numGuns >=10

--15. ������� ������� ������� ������, ����������� � ���� � ����� PC. �������: HD
SELECT hd FROM pc
GROUP BY hd
HAVING COUNT(model) >= 2

--16. ������� ���� ������� PC, ������� ���������� �������� � RAM. 
--� ���������� ������ ���� ����������� ������ ���� ���, �.�. (i,j), �� �� (j,i), 
--������� ������: ������ � ������� �������, ������ � ������� �������, �������� � RAM. 
SELECT DISTINCT pc1.model, pc2.model, pc1.speed, pc2.ram FROM pc pc1
JOIN pc pc2
ON pc1.ram = pc2.ram
AND pc1.speed = pc2.speed
AND pc1.model > pc2.model

--17. ������� ������ ��-���������, �������� ������� ������ �������� ������� �� ��.
--�������: type, model, speed 
SELECT DISTINCT type, product.model, speed
FROM product INNER JOIN laptop ON product.model=laptop.model
WHERE speed<(SELECT MIN(pc.speed) FROM pc)

--18.  ������� �������������� ����� ������� ������� ���������. 
--�������: maker, price 
SELECT DISTINCT maker, price 
FROM product INNER JOIN printer ON product.model=printer.model
AND price = (SELECT MIN(price) FROM printer WHERE color='y')
AND color='y'

--19. ��� ������� �������������, �������� ������ � ������� Laptop, ������� ������� ������ ������ ����������� �� ��-���������.
--�������: maker, ������� ������ ������. 
SELECT maker, AVG(screen) 
FROM product INNER JOIN laptop ON product.model=laptop.model
GROUP BY maker

--20. ������� ��������������, ����������� �� ������� ���� ��� ��������� ������ ��. 
--�������: Maker, ����� ������� ��. 
SELECT maker, COUNT(model)
FROM product
WHERE type = 'pc'
GROUP BY product.maker
HAVING COUNT (DISTINCT model) >= 3

--21. ������� ������������ ���� ��, ����������� ������ ��������������, � �������� ���� ������ � ������� PC.
--�������: maker, ������������ ����. 
SELECT maker, MAX(price)
FROM product INNER JOIN pc ON product.model=pc.model
GROUP BY maker

--22. ��� ������� �������� �������� ��, ������������ 600 ���, ���������� ������� ���� �� � ����� �� ���������. 
--�������: speed, ������� ����. 
SELECT speed, AVG(price)
FROM pc
WHERE speed > 600
GROUP BY speed

--23. ������� ��������������, ������� ����������� �� ��� ��
--�� ��������� �� ����� 750 ���, ��� � ��-�������� �� ��������� �� ����� 750 ���.
--�������: Maker 
SELECT maker FROM product INNER JOIN pc ON product.model=pc.model
WHERE speed >= 750
INTERSECT
SELECT maker FROM product INNER JOIN laptop ON product.model=laptop.model
WHERE speed >= 750

--24. ����������� ������ ������� ����� �����, ������� ����� ������� ���� �� ���� ��������� � ���� ������ ���������. 
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

--25. ������� �������������� ���������, ������� ���������� �� � ���������� ������� RAM
--� � ����� ������� ����������� ����� ���� ��, ������� ���������� ����� RAM. 
--�������: Maker 
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

--26. ������� ������� ���� �� � ��-���������, ���������� �������������� A (��������� �����).
--�������: ���� ����� ������� ����. 
WITH PRICE_CTE AS (
	SELECT price FROM pc INNER JOIN product ON pc.model=product.model 
	AND maker = 'A'
	UNION ALL 
	SELECT price FROM laptop INNER JOIN product ON laptop.model=product.model 
	AND maker = 'A')

--27. ������� ������� ������ ����� �� ������� �� ��� ��������������, ������� ��������� � ��������. 
--�������: maker, ������� ������ HD. 
SELECT maker, AVG(pc.hd) FROM Product JOIN pc ON Product.model = pc.model
WHERE product.maker IN (SELECT DISTINCT maker 
	FROM product WHERE product.type='printer')
GROUP BY maker

SELECT AVG(COALESCE(price,0)) AS avg_price FROM PRICE_CTE

--28. ��������� ������� Product, ���������� ���������� ��������������, ����������� �� ����� ������. 
SELECT COUNT(maker) FROM product
WHERE maker IN
    (
      SELECT maker FROM product
      GROUP BY maker
      HAVING COUNT(model) = 1
    )

--29. � �������������, ��� ������ � ������ ����� �� ������ ������ ������ ����������� �� ���� ������ ���� � ���� [�.�. ��������� ���� (�����, ����)], 
--�������� ������ � ��������� ������� (�����, ����, ������, ������). 
--������������ ������� Income_o � Outcome_o. 
SELECT t1.point, t1.date, inc, out
FROM income_o t1 LEFT JOIN outcome_o t2 ON t1.point = t2.point
AND t1.date = t2.date
UNION
SELECT t2.point, t2.date, inc, out
FROM income_o t1 RIGHT JOIN outcome_o t2 ON t1.point = t2.point
AND t1.date = t2.date

--30. � �������������, ��� ������ � ������ ����� �� ������ ������ ������ ����������� ������������ ����� ��� 
--(��������� ������ � �������� �������� ������� code), 
--��������� �������� �������, � ������� ������� ������ �� ������ ���� ���������� �������� ����� ��������������� ���� ������.
�����: point, date, ��������� ������ ������ �� ���� (out), ��������� ������ ������ �� ���� (inc). ������������� �������� ������� ��������������� (NULL). 
SELECT point, [date], SUM(sum_out), SUM(sum_inc)
FROM( 
SELECT point, [date], SUM(inc) AS sum_inc, NULL AS sum_out FROM Income GROUP BY point, [date]
UNION
SELECT point, [date], NULL AS sum_inc, SUM([out]) AS sum_out FROM Outcome GROUP BY point, [date] 
) AS t
GROUP BY point, [date] 
ORDER BY point