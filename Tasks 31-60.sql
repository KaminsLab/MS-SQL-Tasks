

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