USE [AdventureWorks2019]
GO

--33. Get the ships sunk in the North Atlantic battle.
--Result set: ship. 
SELECT ship FROM Outcomes
WHERE battle='North Atlantic' AND result = 'sunk'

--34. In accordance with the Washington Naval Treaty concluded in the beginning of 1922, it was prohibited to build battle ships with a displacement of more than 35 thousand tons.
--Get the ships violating this treaty (only consider ships for which the year of launch is known).
--List the names of the ships.
SELECT [name] 
FROM Ships INNER JOIN Classes ON Ships.class = Classes.class
WHERE Ships.launched >= 1922 AND displacement > 35000 AND [type]='bb'

--35. Find models in the Product table consisting 
--either of digits only or Latin letters (A-Z, case insensitive) only.
--Result set: model, type.
SELECT model, [type] FROM Product
WHERE model NOT LIKE '%[^0-9]%' OR LOWER(model) NOT LIKE '%[^a-z]%'

--36. List the names of lead ships in the database (including the Outcomes table).
SELECT [name] FROM Ships
WHERE [name] = [class]
UNION 
SELECT [ship] FROM Outcomes
WHERE [ship] IN (SELECT [class] FROM Classes)

--37. Find classes for which only one ship exists in the database (including the Outcomes table).
SELECT class
FROM (
		SELECT Classes.class, [name] FROM Classes LEFT JOIN Ships ON Classes.class = Ships.class
		UNION
		SELECT ship AS class, ship AS [name] FROM Outcomes
		WHERE ship IN (SELECT Classes.class FROM Classes) 
	) AS T
GROUP BY class
HAVING COUNT([name]) = 1

--38. Find countries that ever had classes of both battleships (‘bb’) and cruisers (‘bc’).
SELECT country FROM Classes
WHERE [type]='bc'
INTERSECT
SELECT country FROM Classes
WHERE [type]='bb'

--39. Find the ships that `survived for future battles`;
--that is, after being damaged in a battle, they participated in another one, which occurred later.
SELECT DISTINCT curOutcomes.ship FROM Outcomes AS curOutcomes 
LEFT JOIN Battles AS curBattles ON curOutcomes.battle=curBattles.[name]
WHERE result='damaged' AND EXISTS 
	(
		SELECT ship FROM Outcomes a2 
		LEFT JOIN Battles b2 ON a2.battle=b2.[name] 
		WHERE b2.[date] > curBattles.[date] AND ship=curOutcomes.ship
	)

--40. Get the makers who produce only one product type and more than one model. Output: maker, type.
SELECT maker, MAX([type])
FROM product
GROUP BY maker
HAVING COUNT(DISTINCT [type]) = 1 AND COUNT(model) > 1

--41. For each maker who has models at least in one of the tables PC, Laptop, or Printer,
--determine the maximum price for his products.
--Output: maker; if there are NULL values among the prices for the products of a given maker,
--display NULL for this maker, otherwise, the maximum price.
SELECT maker, CASE MAX(COALESCE(price, 922337203685477))
				WHEN 922337203685477 THEN NULL
				ELSE MAX(price)
				END AS max_price
FROM Product AS p INNER JOIN (
	SELECT model, price FROM PC
	UNION ALL
	SELECT model, price FROM Laptop
	UNION ALL
	SELECT model, price FROM Printer
) AS SQ ON p.model = SQ.model
GROUP BY maker

--42. Find the names of ships sunk at battles, along with the names of the corresponding battles.
SELECT ship, battle FROM Outcomes
WHERE result='sunk'

--43. Get the battles that occurred in years when no ships were launched into water.
SELECT [name] FROM Battles
WHERE YEAR([date]) NOT IN (
	SELECT [launched] FROM Ships WHERE [launched] IS NOT NULL
)

--44. Find all ship names beginning with the letter R.
SELECT [name] FROM Ships
WHERE name LIKE 'R%'
UNION
SELECT [ship] FROM Outcomes
WHERE [ship] LIKE 'R%'

--45. Find all ship names consisting of three or more words (e.g., King George V).
--Consider the words in ship names to be separated by single spaces, and the ship names to have no leading or trailing spaces. 
SELECT [name] FROM Ships
WHERE [name] LIKE'% % %'
UNION
SELECT [ship] FROM Outcomes
WHERE [ship] LIKE'% % %'

--46. For each ship that participated in the Battle of Guadalcanal, get its name, displacement, and the number of guns.
SELECT o.ship, displacement, numGuns FROM
	(SELECT name AS ship, displacement, numGuns
	FROM Ships s JOIN Classes c ON c.class=s.class
	UNION
	SELECT class AS ship, displacement, numGuns
	FROM Classes c) AS a
RIGHT JOIN Outcomes o
ON o.ship=a.ship
WHERE battle = 'Guadalcanal'

--48. Find the ship classes having at least one ship sunk in battles. 
SELECT DISTINCT Classes.class FROM Classes LEFT JOIN Ships ON Classes.class = Ships.class
WHERE [name] IN (
	SELECT ship FROM Outcomes WHERE result='sunk') 
OR Classes.class IN (
	SELECT ship FROM Outcomes WHERE result='sunk')

--49. Find the names of the ships having a gun caliber of 16 inches (including ships in the Outcomes table).
SELECT [name] FROM Ships AS s 
INNER JOIN Classes AS c ON s.class = c.class
WHERE bore = 16
UNION
SELECT ship FROM Outcomes AS o
INNER JOIN Classes AS c ON o.ship = c.class
WHERE bore = 16

--50. Find the battles in which Kongo-class ships from the Ships table were engaged.
SELECT DISTINCT battle FROM Outcomes
WHERE Outcomes.ship IN (SELECT [name] FROM Ships WHERE Ships.class = 'Kongo')

--51. Find the names of the ships with the largest number of guns among all ships having the same displacement 
--(including ships in the Outcomes table). 
WITH sh AS (
  SELECT name, class FROM Ships
  UNION
  SELECT ship, ship FROM Outcomes
)
SELECT
  name
  FROM sh INNER JOIN Classes AS c on sh.class=c.class
  WHERE numguns >= ALL(
    SELECT ci.numguns FROM Classes ci
      WHERE ci.displacement=c.displacement
        and ci.class in (SELECT sh.class FROM sh)
    )