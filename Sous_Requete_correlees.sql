/*
Nous allons travailler successivement sur IN, NOT IN, EXISTS, NOT EXISTS et les sous-requetes correlees.
*/


---- IN 


/*
IN avec une sous-requete
L'operateur IN permet de verifier si une valeur appartient à un ensemble de resultats.
*/

/*
Imaginons deux tables.

Table departments
id	  name
10	  IT
20	  HR
30	  Sales

Table employees
id	name	department_id	salary
1	Alice	10	            50000
2	Bob	    20	            45000
3	Charlie	10	            60000
4	David	30	            40000

Sous-requete avec IN :
On utilise les deux tables precedentes.

Objectif : afficher name et salary des employes appartenant aux departements IT ou HR.

*/

SELECT name, salary 
FROM employees
WHERE department_id IN (
    SELECT id
    FROM departments
    WHERE name = 'IT' OR name = 'HR'
);

/*
Petite remarque : tu aurais egalement pu ecrire WHERE name IN ('IT', 'HR') 
dans la sous-requete, mais ta solution est parfaitement valide.
*/

----- NOT IN 

/*
NOT IN permet de sélectionner les lignes dont la valeur n'appartient pas à l'ensemble retourné par une sous-requête.
*/

/*
Attention : NOT IN présente une particularité importante avec les valeurs NULL. 
Si la sous-requête retourne un NULL, le résultat peut être inattendu. 
Nous approfondirons ce point avec NOT EXISTS.
*/

/*
On utilise les memes tables 
Objectif : 
afficher name et salary des employés qui n'appartiennent ni au département IT ni au département HR.
*/

SELECT name, salary
FROM employees
WHERE department_id NOT IN (
    SELECT id 
    FROM departments
    WHERE name IN ('IT', 'HR')
);

-- Tu as correctement combiné NOT IN dans la requête principale et IN dans la sous-requête.

------------ EXISTS

/*
L'opérateur EXISTS vérifie si une sous-requête retourne au moins une ligne.

Contrairement à IN, qui compare une valeur à un ensemble, EXISTS teste l'existence d'un résultat.

exemple :

SELECT name
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.id
);

e.department_id = d.id

relie la sous-requête à la requête principale. On parle de sous-requête corrélée.

SELECT 1 est une convention courante avec EXISTS : les valeurs sélectionnées n'ont 
pas d'importance, seule l'existence d'une ligne compte.
*/

/*
Première sous-requête avec EXISTS
On utilise les tables suivantes.

Table departments
id	  name
10	  IT
20	  HR
30	  Sales
40	  Marketing


Table employees
id	name	 department_id	salary
1	Alice	 10	            50000
2	Bob	     20	            45000
3	Charlie	 10	            60000
4	David	 30	            40000

Objectif : afficher les noms des départements qui possèdent au moins un employé.
*/

SELECT name 
FROM departments AS d
WHERE EXISTS (
    SELECT 1
    FROM employees AS e
    WHERE e.department_id = d.id
);

/*
DANS SELECT 1 : Le 1 est simplement une constante, pas un numéro de colonne, pas un 
identifiant d'employé et pas une quantité.

Cherche les employés appartenant au département actuellement examiné. Pour chaque ligne trouvée, retourne la valeur constante 1.

Mais EXISTS ne s'intéresse pas à cette valeur. Il vérifie uniquement si la sous-requête retourne au moins une ligne.
- Au moins une ligne trouvée → EXISTS vaut TRUE.
- Aucune ligne trouvée → EXISTS vaut FALSE.
*/


/*
, PostgreSQL vérifie seulement si une ligne existe.

On préfère souvent SELECT 1 parce que cela indique clairement notre intention : nous ne voulons récupérer aucune donnée particulière, 
seulement vérifier l'existence d'une correspondance.
*/

/*
SELECT name
FROM departments d
WHERE EXISTS (
    SELECT NULL
    FROM employees e
    WHERE e.department_id = d.id
);


Cette requête fonctionne également !

Même si la sous-requête retourne NULL, EXISTS vaut TRUE dès qu'au moins une ligne est retournée.

C'est une différence fondamentale :
- EXISTS vérifie la présence de lignes.
- Il ne vérifie pas si les valeurs retournées sont différentes de NULL.
- SELECT 1 n'est donc pas une condition imposant que la valeur soit égale à 1.
*/

-- PostgreSQL peut choisir un plan d'exécution optimisé plutôt que 
-- d'exécuter littéralement la sous-requête une fois par département.


------------------------------------ NOT EXISTS

/*
NOT EXISTS est l'inverse de EXISTS.
- EXISTS vaut TRUE si la sous-requête retourne au moins une ligne.
- NOT EXISTS vaut TRUE si la sous-requête ne retourne aucune ligne.
*/

/*
Différence importante avec NOT IN :
NOT EXISTS est particulièrement utile lorsque des valeurs NULL peuvent apparaître dans les données. 
Contrairement à NOT IN, il ne provoque pas le même problème de comparaison avec un NULL retourné 
par la sous-requête.
*/


/*
Sous-requête avec NOT EXISTS
Table departments : 
id	name
10	IT
20	HR
30	Sales
40	Marketing
50	Finance

Table employees :
id	name	department_id
1	Alice	10
2	Bob	    20
3	Charlie	10
4	David	30

Objectif : afficher uniquement les noms des départements qui ne possèdent aucun employé.
*/

SELECT name
FROM departments AS d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees AS e 
    WHERE d.id  = e.department_id
);


------------------------------------------- NOT IN et les valeurs NULL

/*
Nous allons approfondir une différence importante entre NOT IN et NOT EXISTS.

en SQL, une comparaison avec NULL produit généralement une valeur logique 
UNKNOWN (inconnue), et non TRUE ou FALSE.

*/

/*
Prenons deux tables :

Table departments
id	name
10	IT
20	HR
30	Sales
40	Marketing

Table employees
id	name	department_id
1	Alice	10
2	Bob	    20
3	Charlie	NULL 

Avec les deux tables ci-dessus, considère cette requête :
SELECT d.name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.id
);


Question 1 : quels départements seront affichés ?

Question 2 : pourquoi l'employé Charlie, dont department_id vaut NULL, n'empêche-t-il pas ces départements d'être affichés ?
*/

-- Réponse 1 : Sales Marketing 
-- 

-- Réponse 2 : 
/*
je vais t'expliquer le mécanisme, car c'est une notion essentielle pour maîtriser les sous-requêtes avancées.

Imaginons que PostgreSQL examine le département Sales, dont id = 30.

Pour chaque employé, voici le résultat logique de la comparaison :
Employé	department_id	Comparaison avec 30	  Résultat
Alice	10	            10 = 30	              FALSE
Bob	    20	            20 = 30	              FALSE
Charlie	NULL	        NULL = 30	          UNKNOWN

En SQL, NULL = 30 ne vaut pas TRUE. 
La comparaison vaut UNKNOWN, car NULL représente une valeur inconnue.

Or, une clause WHERE ne conserve que les lignes pour lesquelles la condition vaut TRUE.

Donc, pour Sales :
1. Aucun employé ne satisfait la condition.
2. La sous-requête retourne zéro ligne.
3. EXISTS vaut FALSE.
4. NOT EXISTS vaut TRUE.
5. Sales est affiché.
C'est exactement le même raisonnement pour Marketing.

*/

--- En SQL, NULL représente une valeur inconnue. On ne peut donc pas affirmer qu'elle est égale ou différente de 10.


----------------------------------- Sous-requête corrélée avec AVG()
/*
La table employees contient déjà toutes les informations nécessaires :
id	name	department_id	salary
1	Alice	10	            50000
2	Bob	    10	            60000
3	Charlie	10	            70000
4	David	20	            40000
5	Emma	20	            50000
6	Frank	20	            90000

Rappel de l'objectif : afficher name, department_id et salary des employés dont le salaire est strictement supérieur 
à la moyenne de leur propre département.
*/

SELECT name, department_id, salary
FROM employees AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees AS e2
    WHERE e.department_id = e2.department_id
);

/*
Exercice 7 : 
sous-requête corrélée plus complexe
Nous augmentons maintenant la difficulté.

Voici la table employees :
id	name	department_id	salary
1	Alice	10	            50000
2	Bob	    10	            70000
3	Charlie	10	            70000
4	David	20	            40000
5	Emma	20	            60000
6	Frank	20	            90000
7	Grace	30	            55000
8	Henry	30	            55000

Objectif : afficher name, department_id et salary de tous les employés qui gagnent le salaire maximum de leur propre département.

*/

SELECT name, department_id, salary
FROM employees AS e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees AS e2
    WHERE e.department_id = e2.department_id
);

/*
Exercice 8 : 
synthèse finale

Table departments
id	name
10	IT
20	HR
30	Sales
40	Marketing

Table employees
id	name	department_id	salary
1	Alice	10	            50000
2	Bob	    10	            70000
3	Charlie	10	            70000
4	David	20	            40000
5	Emma	20	            60000
6	Frank	20	            90000
7	Grace	30	            55000
8	Henry	30	            55000

Objectif
Afficher le nom des départements qui respectent simultanément ces deux conditions :
1. Ils possèdent au moins deux employés.
2. Leur salaire moyen est strictement supérieur à 55 000.
*/

SELECT name 
FROM departments AS d 
WHERE ((
    SELECT COUNT(e.id)
    FROM employees AS e 
    WHERE d.id = e.department_id
) >= 2 
AND (
    SELECT AVG(e.salary) 
    FROM employees AS e 
    WHERE d.id = e.department_id 
    ) > 55000
);

--- une sous-requête scalaire peut retourner un nombre, et la requête extérieure peut 
--- ensuite comparer ce nombre à un seuil. 














