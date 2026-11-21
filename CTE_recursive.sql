/*
==================================================
 TOPIC: Common Table Expressions (CTEs)
 LEVEL: Intermediate → Advanced
 OBJECTIVE: Simplify complex SQL queries
==================================================
*/


/*
    Ecrit une requete qui genere les nombres suivants :
    5 10 15 20 25 
*/

WITH RECURSIVE numbers AS (
    SELECT 5 AS n 

    UNION ALL 

    SELECT n+5
    FROM numbers 
    WHERE n < 25 
)
SELECT *
FROM numbers;

/*
    Ecrit une requete qui genere les nombres suivants :
    20 16 12 8 4
*/

WITH RECURSIVE numbers AS (
    SELECT 20 AS n 

    UNION ALL 

    SELECT n-4
    FROM numbers 
    WHERE n > 4
)
SELECT * 
FROM numbers; 

------------------------------------------------------------------------
-- A ce niveau tu sais construire une CTE recursive basique. 
------------------------------------------------------------------------


/*
Objectif : ecrire une CTE recursive qui genere ce resultat :
n	double_n
1	2
2	4
3	6
4	8
5	10
*/

WITH RECURSIVE numbers AS (
    SELECT 1 AS n,
           2 AS double_n

    UNION ALL 

    SELECT n+1 AS n,
           (n + 1) * 2 AS double_n 
    FROM numbers 
    WHERE n < 5         
)
SELECT *
FROM numbers;

------------------------------------------------------------------------

/*
La valeur de n actuelle construit les valeurs de l'etape suivante :
Si la valeur actuelle est n = 3
SELECT n + 1 AS n,
       (n + 1) * 2 AS double_n
produira :
n = 3 + 1 = 4
double_n = (3 + 1) * 2 = 8
*/
------------------------------------------------------------------------

/*
Cette fois, on augmente legerement la difficulte.
on veut obtenir le resultat suivant :
n	triple_n
2	6
4	12
6	18
8	24
10	30
*/


WITH RECURSIVE numbers AS (
    SELECT 2 AS n,
           6 AS triple_n
    
    UNION ALL 

    SELECT n + 2 AS n,
           (n + 2) * 3 AS triple_n
    FROM numbers 
    WHERE n < 10
)
SELECT * 
FROM numbers;

------------------------------------------------------------------------
-- A ce niveau tu sais construire une CTE recursive avec plusieurs colonnes. 
------------------------------------------------------------------------

-- le mecanisme essentiel du JOIN recursif depend de la condition ON 

-- La CTE recursive est utilisee pendant sa propre construction.


/*
Voici la table employees :
id	name	manager_id
1	Alice	NULL
2	Bob	    1
3	Charlie	1
4	Diana	2
5	Eve	    4

Objectif : ecrit une CTE recursive appelee hierarchy qui recupere Bob et 
tous ses subordonnes, directs ou indirects.

Resultat attendu :
id	name
2	Bob
4	Diana
5	Eve
*/

WITH RECURSIVE hierarchy AS (
    SELECT id, name
    FROM employees 
    WHERE id = 2

    UNION ALL 

    SELECT e.id,e.name
    FROM employees AS e
    INNER JOIN hierarchy AS h 
    ON e.manager_id = h.id 
)
SELECT * 
FROM hierarchy;


-- C'est comme une chaine dependente A nous permet de trouver B 
-- B permet de trouver C et C permet de trouver D ainsi de suite

/*
id	name	manager_id
1	Alice	NULL
2	Bob	    1
3	Charlie	1
4	Diana	2
5	Eve	    4

Objectif : ecrire une CTE recursive appelee hierarchy qui affiche Alice et tous
 ses subordonnes, directs ou indirects.

Resultat attendu :
id	name
1	Alice
2	Bob
3	Charlie
4	Diana
5	Eve
*/

WITH RECURSIVE hierarchy AS (
    SELECT id,name 
    FROM employees 
    WHERE id = 1

    UNION ALL 

    SELECT e.id, e.name
    FROM employees AS e 
    INNER JOIN hierarchy AS h 
    ON e.manager_id = h.id
)
SELECT *
FROM hierarchy;

--- L'ordre d'affichage n'est pas garanti sans ORDER BY


/*
On conserve la meme table employees :

Objectif : ecrire une CTE recursive appelee hierarchy qui affiche Alice et 
tous ses subordonnes avec leur niveau hierarchique.

Resultat attendu :
name	level
Alice	0
Bob	    1
Charlie	1
Diana	2
Eve	    3 

Alice doit commencer au niveau 0. Chaque niveau inferieur augmente de 1.
*/

WITH RECURSIVE hierarchy AS (
    SELECT id,
           name,
           0 AS level
    FROM employees
    WHERE id = 1 

    UNION ALL 

    SELECT e.id,
           e.name, 
           h.level + 1
    FROM employees AS e 
    INNER JOIN hierarchy AS h 
    ON e.manager_id = h.id
)

SELECT name,level
FROM hierarchy;

-- Sans ORDER BY, l'ordre exact des lignes n'est pas garanti.

/*
Objectif : afficher uniquement les employes situs aux niveaux 1 et 2 sous Alice.

Resultat attendu :
name	level
Bob	    1
Charlie	1
Diana	2
*/

WITH RECURSIVE hierarchy AS (
    SELECT id,
           name,
           0 AS level
    FROM employees
    WHERE id = 1 

    UNION ALL 

    SELECT e.id,
           e.name, 
           h.level + 1
    FROM employees AS e 
    INNER JOIN hierarchy AS h 
    ON e.manager_id = h.id
)

SELECT name,level
FROM hierarchy
WHERE level = 1 OR level = 2; -- WHERE level IN(1, 2);  est un autre choix 

/*
limiter la recursion elle-meme.

Voici la table employees :
id	name	manager_id
1	Alice	NULL
2	Bob	1
3	Charlie	1
4	Diana	2
5	Eve	4

Objectif : ecrire une CTE recursive qui part d'Alice, mais qui s'arrete au 
niveau 2. Eve, situee au niveau 3, ne doit meme pas etre genere par la CTE.

Resultat attendu :
name	level
Alice	0
Bob	    1
Charlie	1
Diana	2
*/

WITH RECURSIVE hierarchy AS (
    SELECT id,
           name,
           0 AS level
    FROM employees
    WHERE id = 1 

    UNION ALL 

    SELECT e.id,
           e.name, 
           h.level + 1
    FROM employees AS e 
    INNER JOIN hierarchy AS h 
    ON e.manager_id = h.id
    WHERE h.level + 1 <= 2 -- WHERE h.level < 2 c'est équivalent
)

SELECT name,level
FROM hierarchy; 

/*
Objectif : ecrire une CTE recursive qui part de Bob et affiche tous ses 
subordonnes, avec leur niveau par rapport a Bob.

Resultat attendu :
name	level
Bob	    0
Diana	1
Eve     2
*/

WITH RECURSIVE hierarchy AS (
    SELECT id,
           name,
           0 AS level 
    FROM employees 
    WHERE id = 2

    UNION ALL 

    SELECT e.id,
           e.name,
           h.level + 1
    FROM employees AS e
    INNER JOIN hierarchy AS h 
    ON e.manager_id = h.id 
)

SELECT name, level
FROM hierarchy;

/*
Objectif : ecrire une CTE recursive qui part d'Alice et compte tous ses 
subordonnes, directs et indirects, sans compter Alice elle-meme.

Resultat attendu :
name	total_subordinates
Alice	4
*/

WITH RECURSIVE hierarchy AS (
    SELECT id,
           name,
           0 AS level 
    FROM employees 
    WHERE id = 1

    UNION ALL 

    SELECT e.id,
           e.name,
           h.level + 1
    FROM employees AS e
    INNER JOIN hierarchy AS h 
    ON e.manager_id = h.id 
)

SELECT 'Alice' AS name,
       COUNT(name) AS total_subordinates
FROM hierarchy 
WHERE level > 0 ;


/*
nous allons faire l'inverse : retrouver ses superieurs hierarchiques.
Exercice 15 : Remonter une hierarchie
Objectif : ecrire une CTE recursive appelee hierarchy qui part d'Eve et 
remonte jusqu'a Alice.

resultat attendu :
name
Eve
Diana
Bob
Alice
*/

WITH RECURSIVE hierarchy AS (
    SELECT manager_id, 
           name
    FROM employees 
    WHERE id = 5

    UNION ALL 

    SELECT e.manager_id,
           e.name 
    FROM employees AS e 
    INNER JOIN hierarchy AS h 
    ON h.manager_id = e.id -- il suffit de jouer sur la condition pour remoter 
                           --ou descendre 
)

-- l faut egalement conserver manager_id dans la CTE pour pouvoir remonter 
-- a chaque etape.
SELECT name
FROM hierarchy;

-- L'ordre d'affichage n'est pas garanti sans ORDER BY

/*
Exercice 16 : Synthese finale des CTE recursives
Voici la table employees :
id	name	manager_id
1	Alice	NULL
2	Bob	    1
3	Charlie	1
4	Diana	2
5	Eve	    4

Objectif : ecrire une CTE recursive qui part de Bob et affiche tous ses 
subordonnes, avec leur niveau hierarchique.

Cette fois, Bob ne doit pas apparaitre dans le resultat final.

Resultat attendu :
name	level
Diana	1
Eve	    2
*/


WITH RECURSIVE hierarchy AS(
    SELECT id,
           name,
           0 AS level
    FROM employees 
    WHERE id = 2

    UNION ALL

    SELECT e.id,
           e.name,
           h.level + 1
    FROM employees AS e
    INNER JOIN hierarchy AS h 
    ON e.manager_id = h.id 
)

SELECT name, 
       level 
FROM hierarchy
WHERE level > 0;

