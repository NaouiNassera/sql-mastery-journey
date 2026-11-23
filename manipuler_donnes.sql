/*
Voici la table employees :
id	name	salary
1	Alice	50000
2	Bob	    45000

Objectif : ajouter un nouvel employe avec les informations suivantes :
id	name	salary
3	Diana	55000
*/

INSERT INTO employees(id, name, salary)
VALUES (3, 'Diana', 55000);

/*
Objectif : ajouter trois employes en une seule requete SQL.
id	name	salary
3	Charlie	60000
4	Diana	55000
5	Eve	    48000
*/

INSERT INTO employees(id, name, salary)
VALUES 
        (3, 'Charlie', 60000),
        (4, 'Diana', 55000),
        (5, 'Eve', 48000);

/*
Voici la structure de la table employees :
Colonne	    Type	Regle
id	        INTEGER	Obligatoire
name	    VARCHAR	Obligatoire
salary	    INTEGER	Facultatif, valeur par defaut : NULL
department	VARCHAR	Facultatif, valeur par defaut : 'Unknown'

Objectif : ajouter un nouvel employe :
- id = 6
- name = Frank
- Ne pas renseigner son salaire.
- Laisser la base de donnees attribuer automatiquement la valeur par defaut a 
son departement.
*/

-- Regle importante : le nombre de colonnes declarees doit correspondre au 
-- nombre de valeurs fournies.
INSERT INTO employees(id, name)
VALUES (6, 'Frank');

/*
Meme table, memes regles

Objectif : ajouter l'employee Grace avec :
- id = 7
- name = Grace
- salary = 62000
- department : laisser la valeur par defaut.
*/
INSERT INTO employees(id, name, salary)
VALUES (7, 'Grace', 62000);

-- SQL permet aussi d'inserer des lignes 
-- a partir du resultat d'une requete SELECT

/*
Table employees
id	name	salary
1	Alice	50000
2	Bob	    45000
3	Charlie	60000
4	Diana	55000
5	Eve	    48000

Table high_salary_employees, initialement vide :
id	name	salary

Objectif : inserer dans high_salary_employees tous les employes dont le salaire
est strictement superieur a 50000, en conservant leurs trois colonnes.
*/

INSERT INTO high_salary_employees(id, name, salary)
SELECT id, name, salary 
FROM employees 
WHERE salary > 50000;


--- En PostgreSQL, RETURNING permet de recuperer des informations sur les lignes
--- qui viennent d'etre inserees

/*
Table employees :
id	name	salary
1	Alice	50000
2	Bob	    45000

Objectif : ajouter un employe avec les valeurs suivantes :
id	name	salary
3	Lucas	58000

Puis recuperer uniquement son nom et son salaire grace a RETURNING.
*/

INSERT INTO employees(id, name, salary)
VALUES(3, 'Lucas', 58000)
RETURNING name,salary;

/*
Table employees
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    48000	HR

Table it_employees, initialement vide :
id	name	salary

Objectif : copier dans it_employees les employes du departement IT dont le 
salaire est strictement superieur a 50000, puis renvoyer uniquement leur nom 
et leur salaire.
*/

INSERT INTO it_employees(id, name, salary)
SELECT id, name, salary 
FROM employees 
WHERE department = 'IT' AND salary > 50000
RETURNING name, salary;

------------------------------------------------------------------------------

-- UPDATE permet de modifier une ou plusieurs valeurs dans des lignes deja 
-- existantes.

--  attention sans WHERE, la modification s'applique a toutes les lignes de 
--  la table.

/*
Voici la table employees :
id	name	salary
1	Alice	50000
2	Bob	    45000
3	Charlie	60000

Objectif : modifier uniquement le salaire de Bob, pour le faire passer de 45000
 a 49000.
*/

UPDATE employees 
SET salary = 49000
WHERE id = 2;

/*
Voici la table employees :
id	name	salary	department
1	Alice	50000	IT
2	Bob	    49000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales

Objectif : modifier les informations de Diana (id = 4) :
- Son salaire doit passer a 62000.
- Son departement doit devenir IT.
- Les autres employes ne doivent pas etre modifies.
*/

UPDATE employees 
SET salary = 62000,
    department = 'IT'
WHERE id = 4;

-- Avec UPDATE, tu peux aussi calculer une nouvelle valeur a
-- partir de la valeur actuelle.

/*
Voici la table employees :
id	name	salary	department
1	Alice	50000	IT
2	Bob	    49000	HR
3	Charlie	60000	IT
4	Diana	62000	IT
5	Eve	    48000	HR

Objectif : augmenter de 10 % le salaire de tous les employes du departement IT,
 sans modifier les autres employes.
*/

UPDATE employees 
SET salary = salary + salary * 0.1
WHERE department = 'IT';

/*
Voici une nouvelle situation.

Table employees
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    48000	HR
6	Frank	40000	IT

Objectif : augmenter de 5000 le salaire des employes qui remplissent 
simultanement ces deux conditions :
- Appartenir au departement IT.
- Avoir un salaire strictement inferieur a 55000.
Les autres employes doivent conserver leur salaire.
*/

UPDATE employees 
SET salary = salary + 5000
WHERE department = 'IT' AND salary < 55000;

-- La commande CASE permet d'appliquer des modifications differentes selon 
-- certaines conditions.

/*
Voici une nouvelle table employees :
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    48000	HR

Objectif : effectuer les modifications suivantes en une seule requete :
- Departement IT : augmentation de 10 %.
- Departement HR : augmentation de 5 %.
- Departement Sales : aucune modification.
*/


UPDATE employees
SET salary = CASE
    WHEN department = 'IT' THEN salary + salary * 0.1
    WHEN department = 'HR' THEN salary + salary * 0.05
    ELSE salary
END;

/*
Point important : l'absence de WHERE est volontaire ici. Toutes les lignes sont 
concernees par l'instruction, mais ELSE salary conserve les salaires du departement Sales.
*/

-- En PostgreSQL, RETURNING permet de recuperer les valeurs des lignes apres leur modification.
/*
Voici une nouvelle table employees :
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    48000	HR

Objectif : augmenter de 3000 le salaire de tous les employes du departement HR, puis renvoyer 
uniquement leur nom et leur nouveau salaire.
*/

UPDATE employees
SET salary = salary + 3000
WHERE department = 'HR'
RETURNING name, salary;

-- UPDATE avec une sous-requete 

/*
Voici une nouvelle table employees :
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    40000	HR

Objectif : augmenter de 2000 le salaire de tous les employes dont le salaire est strictement inferieur 
a la moyenne des salaires de l'ensemble de l'entreprise.
*/

UPDATE employees
SET salary = salary + 2000
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
);

/*
Voici une nouvelle table employees :
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    40000	HR
6	Frank	42000	IT


Objectif : modifier les salaires selon les regles suivantes :
- Employes du departement IT ayant un salaire strictement inferieur a 55000 : augmentation de 10 %.
- Employes du departement HR ayant un salaire strictement inferieur a 45000 : augmentation de 5 %.
- Tous les autres employes : salaire inchange.
La requete doit egalement renvoyer le nom, le departement et le nouveau salaire des employes 
effectivement augmentes.
*/

UPDATE employees 
SET salary = CASE
    WHEN department = 'IT' AND salary < 55000 THEN salary + salary * 0.1
    WHEN department = 'HR' AND salary < 45000 THEN salary + salary * 0.05
    ELSE salary 
END
WHERE ( department = 'IT' AND salary < 55000 ) OR ( department = 'HR' AND salary < 45000 ) 
RETURNING name, department, salary;

-- En PostgreSQL, WHERE doit etre place avant RETURNING.

----------------------------------------------------------------------------------------------------------------------------------

-- sans WHERE, DELETE FROM employees; supprimerait toutes les lignes de la table.

/*
Table employees :
id	name	salary
1	Alice	50000
2	Bob	    45000
3	Charlie	60000
4	Diana	55000

Objectif : supprimer uniquement Charlie (id = 3), sans toucher aux autres employes.

*/

DELETE 
FROM employees 
WHERE id = 3;

/*
Voici une nouvelle table employees :
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    40000	HR
6	Frank	42000	IT

Objectif : supprimer uniquement les employes qui remplissent simultanement ces deux conditions :
- Appartenir au departement HR.
- Avoir un salaire strictement inferieur a 45000.
Les autres employes doivent etre conserves.
*/

DELETE 
FROM employees
WHERE department = 'HR' AND salary < 45000;

-- En PostgreSQL, RETURNING permet de recuperer les informations des lignes supprimees.

/*
Voici une nouvelle table employees :
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    40000	HR

Objectif : supprimer tous les employes du departement HR, puis renvoyer uniquement leur nom et leur salaire.
*/

DELETE 
FROM employees
WHERE department = 'HR'
RETURNING name, salary;

-- DELETE avec une sous-requete

/*
Voici une nouvelle table employees :
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    40000	HR

Objectif : supprimer tous les employes dont le salaire est strictement inferieur a la moyenne des salaires de 
l'entreprise, puis afficher uniquement leur nom et leur salaire.
*/

DELETE 
FROM employees
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
)
RETURNING name, salary;

--DELETE avec plusieurs conditions et RETURNING

/*
Voici une nouvelle table employees :
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    40000	HR
6	Frank	42000	IT
7	Grace	38000	Sales

Objectif : supprimer les employes qui remplissent au moins une des conditions suivantes :
- Appartenir au departement HR avec un salaire strictement inferieur a 45000.
- Appartenir au departement Sales avec un salaire strictement inferieur a 40000.
Puis renvoyer uniquement leur nom, leur departement et leur salaire.
*/

DELETE 
FROM employees
WHERE ( department = 'HR' AND salary < 45000 ) OR ( department = 'Sales' AND salary < 40000 )
RETURNING name, department, salary;

--- Exercice de synthese sur DELETE 

/*
Voici deux tables.

Table employees
id	name	salary	department
1	Alice	50000	IT
2	Bob	    45000	HR
3	Charlie	60000	IT
4	Diana	55000	Sales
5	Eve	    40000	HR
6	Frank	42000	IT

Table departments_to_close
department
HR
Sales

Objectif : supprimer de employees tous les employes dont le departement figure dans la table 
departments_to_close et dont le salaire est strictement inferieur a 50000.

Puis afficher uniquement le nom, le departement et le salaire des employes supprimes.
*/

DELETE 
FROM employees
WHERE department IN(
    SELECT department
    FROM departments_to_close
) 
AND  salary < 50000 
RETURNING name, department, salary;



----------------------------------------------------------------------------------------------------------------

--- Les transactions SQL

--- Une transaction permet de regrouper plusieurs operations SQL pour qu'elles soient validees ou annulees ensemble.

/*
Nous allons travailler avec PostgreSQL.
Les trois commandes essentielles :
Commande	Role
BEGIN	    Demarrer une transaction
COMMIT	    Valider definitivement les modifications
ROLLBACK	Annuler les modifications non validees
*/

/*
Exercice 1 : Premiere transaction
Voici la table employees :
id	name	salary
1	Alice	50000
2	Bob	    45000

Objectif :
1. Demarrer une transaction.
2. Modifier le salaire de Bob a 52000.
3. Annuler cette modification.
4. Conserver son salaire initial de 45000.
*/

BEGIN;

UPDATE employees
SET salary = 52000
WHERE id = 2;

ROLLBACK;

/* 
ROLLBACK annule les modifications effectuees dans la transaction et restaure les valeurs precedentes, 
tant qu'elles n'ont pas ete validees par COMMIT

ROLLBACK annule toutes les modifications non validees de la transaction, pas uniquement le dernier UPDATE
*/

/*
Transaction avec COMMIT
Voici une nouvelle table employees :
id	name	salary
1	Alice	50000
2	Bob	    45000
3	Charlie	60000

Objectif :
1. Demarrer une transaction.
2. Augmenter le salaire d'Alice de 5000.
3. Augmenter le salaire de Bob de 3000.
4. Valider definitivement les deux modifications.
*/

BEGIN;

UPDATE employees 
SET salary = salary + 5000
WHERE id = 1;

UPDATE employees
SET salary = salary + 3000
WHERE id = 2;

COMMIT;

/*
apres COMMIT, les modifications sont validees. Un ROLLBACK execute ensuite dans une nouvelle transaction ne 
pourra pas annuler ce COMMIT.
*/

/*
Transaction avec plusieurs operations et ROLLBACK
Voici une nouvelle table employees :
id	name	salary
1	Alice	50000
2	Bob	    45000
3	Charlie	60000
4	Diana	55000

Objectif :
1. Demarrer une transaction.
2. Augmenter le salaire d'Alice de 10000.
3. Supprimer Bob de la table.
4. Annuler les deux operations pour retrouver exactement la table initiale.
*/

BEGIN;

UPDATE employees
SET salary = salary + 10000
WHERE id = 1;

DELETE 
FROM employees
WHERE id = 2;

ROLLBACK;

/*
ROLLBACK annule aussi les suppressions effectuees dans la transaction. Bob revient donc dans la table.
*/

/*
La regle a retenir
Dans une transaction PostgreSQL, ROLLBACK annule toutes les modifications non validees, notamment :
- INSERT : les lignes ajoutees sont retirees.
- UPDATE : les anciennes valeurs sont restaurees.
- DELETE : les lignes supprimees sont restaurees.
COMMIT valide les changements, tandis que ROLLBACK les annule.

Attention : si tu as deja execute COMMIT, un ROLLBACK ulterieur ne peut pas annuler cette transaction validee.
*/


/*
SAVEPOINT et ROLLBACK TO SAVEPOINT
Nous allons decouvrir une nouvelle notion : les points de sauvegarde.

Un SAVEPOINT permet de definir un point intermediaire dans une transaction.

Contrairement a ROLLBACK, qui annule toute la transaction, ROLLBACK TO SAVEPOINT permet de revenir a un point 
precis sans annuler les modifications effectuees avant ce point.
*/

/*
Voici une nouvelle table employees :
id	name	salary
1	Alice	50000
2	Bob	    45000
3	Charlie	60000

Objectif :
1. Demarrer une transaction.
2. Augmenter le salaire d'Alice de 5000.
3. Creer un point de sauvegarde nomme sp_salary.
4. Augmenter le salaire de Bob de 10000.
5. Annuler uniquement l'augmentation de Bob.
6. Valider definitivement l'augmentation d'Alice.
*/

BEGIN;

UPDATE employees
SET salary = salary + 5000 
WHERE id = 1;

SAVEPOINT sp_salary;

UPDATE employees
SET salary = salary + 10000
WHERE id = 2;

ROLLBACK TO SAVEPOINT sp_salary;

COMMIT;

/*
Plusieurs SAVEPOINT
Nous allons maintenant augmenter legerement la difficulte.

Voici une nouvelle table employees :
id	name	salary
1	Alice	50000
2	Bob	    45000
3	Charlie	60000

Objectif :
1. Demarrer une transaction.
2. Augmenter le salaire d'Alice de 5000.
3. Creer un point de sauvegarde nomme sp1.
4. Augmenter le salaire de Bob de 3000.
5. Creer un deuxieme point de sauvegarde nomme sp2.
6. Augmenter le salaire de Charlie de 10000.
7. Revenir au point de sauvegarde sp1.
8. Valider la transaction.

Question : 
ecris toutes les instructions SQL necessaires, puis indique les salaires 
finaux d'Alice, Bob et Charlie apres COMMIT.
*/

BEGIN;

UPDATE employees 
SET salary = salary + 5000
WHERE id = 1;

SAVEPOINT sp1;

UPDATE employees
SET salary = salary + 3000
WHERE id = 2;

SAVEPOINT sp2;

UPDATE employees
SET salary = salary + 10000
WHERE id = 3;

ROLLBACK TO SAVEPOINT sp1;

COMMIT;

/*
PostgreSQL :
- Conserve les modifications effectuees avant sp1.
- Annule les modifications de Bob et Charlie.
- Supprime egalement le point de sauvegarde sp2, puisqu'il a ete cree apres sp1.
- Maintient la transaction ouverte jusqu'au COMMIT.
*/

/*
Synthese finale des transactions
Voici une nouvelle table employees :
id	name	salary
1	Alice	50000
2	Bob	    45000
3	Charlie	60000
4	Diana	55000

Objectif :
1. Demarrer une transaction.
2. Augmenter le salaire d'Alice de 5000.
3. Creer un point de sauvegarde sp1.
4. Supprimer Bob.
5. Augmenter le salaire de Charlie de 10000.
6. Creer un deuxieme point de sauvegarde sp2.
7. Inserer un nouvel employe : id = 5, name = 'Eve', salary = 48000.
8. Revenir au point de sauvegarde sp1.
9. Augmenter le salaire de Diana de 2000.
10. Valider la transaction.
*/

BEGIN;

UPDATE employees
SET salary = salary + 5000
WHERE id = 1;

SAVEPOINT sp1;

DELETE 
FROM employees
WHERE id = 2;

UPDATE employees
SET salary = salary + 10000
WHERE id = 3;

SAVEPOINT sp2;

INSERT INTO employees(id, name, salary)
VALUES(5, 'Eve', 48000);

ROLLBACK TO SAVEPOINT sp1;

UPDATE employees
SET salary = salary + 2000
WHERE id = 4;

COMMIT;

/*
Tu maitrises maintenant les mecanismes fondamentaux de BEGIN, COMMIT, ROLLBACK, SAVEPOINT et ROLLBACK TO SAVEPOINT.
*/

/*

-----------------------------------------------------------------------------------------------------------------------

Les contraintes SQL :

Les contraintes permettent a la base de donnees de proteger l'integrite des donnees.
Nous allons etudier progressivement :
1. NOT NULL
2. UNIQUE
3. PRIMARY KEY
4. FOREIGN KEY
5. CHECK
6. DEFAULT
*/

-- NOT NULL empeche une colonne de contenir la valeur NULL.

/*
Premiere contrainte
Objectif : creer une table students avec les colonnes suivantes :
Colonne	Type	        Contrainte
id	    INTEGER	        Aucune pour cet exercice
name	VARCHAR(100)	NOT NULL
email	VARCHAR(150)	NOT NULL
age	    INTEGER	        Aucune

Objectif : 
ecrire une seule instruction CREATE TABLE qui respecte exactement cette structure.
*/

CREATE TABLE students(
    id INTEGER,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    age INTEGER
);


-- UNIQUE empeche d'enregistrer plusieurs fois la meme valeur dans une colonne.

/*
en PostgreSQL, une contrainte UNIQUE autorise normalement plusieurs valeurs NULL, 
car elles ne sont pas considerees comme egales pour cette contrainte.

*/

-- Pour rendre une colonne obligatoire et unique, on peut combiner NOT NULL et UNIQUE

/*
NOT NULL et UNIQUE
Cree une table users avec les caracteristiques suivantes :
Colonne	  Type	        Contraintes
id	      INTEGER	    Aucune
username  VARCHAR(50)	NOT NULL, UNIQUE
email	  VARCHAR(150)	NOT NULL, UNIQUE
age	      INTEGER	    Aucune

Objectif : 
empecher deux utilisateurs d'avoir le meme nom d'utilisateur ou la meme adresse e-mail, 
tout en rendant ces deux informations obligatoires.
*/

CREATE TABLE users (
    id INTEGER,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    age INTEGER
);

/*
L'ordre UNIQUE NOT NULL est valide en PostgreSQL, tout comme NOT NULL UNIQUE.
*/

/*

Une cle primaire permet d'identifier de maniere unique chaque ligne d'une table.

Elle combine automatiquement deux proprietes :
- UNIQUE : deux lignes ne peuvent pas avoir la meme cle primaire.
- NOT NULL : la cle primaire ne peut pas etre NULL.

*/


/*

Cree une table products avec la structure suivante :

Colonne	 Type	            Contrainte
id	     INTEGER	        PRIMARY KEY
name	 VARCHAR(100)	    NOT NULL
price	 INTEGER	        Aucune
sku	     VARCHAR(50)	    UNIQUE, NOT NULL

Objectif : ecrire une seule instruction CREATE TABLE qui respecte exactement ces regles.

*/

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INTEGER,
    sku VARCHAR(50) UNIQUE NOT NULL
);

/*
FOREIGN KEY
Une cle etrangere permet de creer une relation entre deux tables tout en garantissant l'integrite referentielle.

une cle etrangere n'implique pas automatiquement NOT NULL. Il faut ajouter cette contrainte si la relation est obligatoire.
*/

/*
Premiere cle etrangere :

On suppose que la table departments existe deja :

CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

Objectif : creer une table employees avec les caracteristiques suivantes :
----------------------------------------------------------------------------------
| Colonne	    | Type	           | Contraintes   
|---------------|------------------|----------------------------------------------
| id	        | INTEGER	       | PRIMARY KEY
| name	        | VARCHAR(100)	   | NOT NULL
| salary	    | INTEGER	       | Aucune
| department_id	| INTEGER	       | NOT NULL, cle etrangere vers departments(id)
|               |                  |
----------------------------------------------------------------------------------

*/

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary INTEGER,
    department_id INTEGER NOT NULL REFERENCES departments(id)
);

/*
Point important : avec department_id INTEGER NOT NULL REFERENCES departments(id), chaque 
employe doit appartenir a un departement existant.
*/

/*
FOREIGN KEY et ON DELETE
Que se passe-t-il lorsqu'on supprime un departement auquel des employes appartiennent ?

PostgreSQL permet de definir le comportement avec ON DELETE.
Option	             Comportement
ON DELETE RESTRICT	 Empeche la suppression du departement s'il est reference
ON DELETE CASCADE	 Supprime automatiquement les employes lies au departement
ON DELETE SET NULL	 Remplace leur department_id par NULL

Attention : ON DELETE SET NULL necessite que la colonne puisse accepter NULL.
*/

/*
La table departments existe deja :
CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);


Objectif : creer une table employees avec cette structure :
Colonne	        Type	        Contraintes
id	            INTEGER	        PRIMARY KEY
name	        VARCHAR(100)	NOT NULL
salary	        INTEGER	        Aucune
department_id	INTEGER	        NOT NULL, cle etrangere vers departments(id) avec ON DELETE CASCADE

Question supplementaire : si le departement 10 possede trois employes et qu'on supprime ce departement, 
que deviennent ces trois employes ?

*/

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary INTEGER,
    department_id INTEGER NOT NULL REFERENCES departments(id) 
        ON DELETE CASCADE
);

/*
Attention : 
ON DELETE CASCADE peut provoquer la suppression de nombreuses lignes liees. Il faut l'utiliser avec precaution.
*/

/*
ON DELETE SET NULL
Contrairement a CASCADE, qui supprime les lignes liees, ON DELETE SET NULL permet de conserver les employes, 
mais de retirer leur association avec le departement supprime.
*/

/*
Regle importante : si department_id possede la contrainte NOT NULL, l'action ON DELETE SET NULL echouera 
lorsqu'elle devra attribuer NULL a cette colonne.
*/

/*
La table departments existe deja :
CREATE TABLE departments (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);


Objectif : creer une table employees avec cette structure :
Colonne	        Type	        Contraintes
id	            INTEGER	        PRIMARY KEY
name	        VARCHAR(100)	NOT NULL
salary	        INTEGER	        Aucune
department_id	INTEGER	        Cle etrangere vers departments(id) avec ON DELETE SET NULL

*/

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    salary INTEGER,
    department_id INTEGER REFERENCES departments(id)
        ON DELETE SET NULL
);

/*
La contrainte CHECK :
La contrainte CHECK permet d'imposer une condition sur les valeurs enregistrees dans une colonne
Point important : 
en PostgreSQL, une contrainte CHECK accepte une condition evaluee a TRUE ou a NULL (inconnue). 
Pour interdire NULL, il faut ajouter NOT NULL.

*/

/*
Premiere contrainte CHECK
Objectif : 
creer une table products avec les caracteristiques suivantes :
Colonne	Type	      Contraintes
id	    INTEGER	      PRIMARY KEY
name	VARCHAR(100)  NOT NULL
price	INTEGER	      NOT NULL, strictement superieur a 0
stock	INTEGER	      Superieur ou egal a 0
*/

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INTEGER NOT NULL CHECK (price > 0),
    stock INTEGER CHECK (stock >= 0)
);

/*
La contrainte DEFAULT
La contrainte DEFAULT permet de definir une valeur utilisee automatiquement lorsqu'aucune valeur 
n'est fournie pour une colonne.

*/

/*
Attention : 
DEFAULT ne remplace pas automatiquement un NULL explicitement fourni.
*/

/*
Combiner DEFAULT et CHECK
Cree une table products respectant les regles suivantes :
Colonne	Type	        Contraintes
id	    INTEGER	        PRIMARY KEY
name	VARCHAR(100)	NOT NULL
price	INTEGER	        NOT NULL, strictement superieur a 0
stock	INTEGER	        Valeur par defaut 0, superieur ou egal a 0
status	VARCHAR(20)	    Valeur par defaut 'active', NOT NULL
*/

CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INTEGER NOT NULL CHECK (price > 0),
    stock INTEGER DEFAULT 0 CHECK (stock >= 0),
    status VARCHAR(20) DEFAULT 'active' NOT NULL
);

/*
ALTER TABLE : modifier une table existante
Jusqu'ici, tu as defini les contraintes lors de la creation des tables avec CREATE TABLE.

Mais dans un projet reel, il est frequent de devoir modifier la structure d'une table deja existante.

C'est le role de ALTER TABLE.

Voici trois operations courantes :

1. Ajouter une contrainte NOT NULL
ALTER TABLE products
ALTER COLUMN name SET NOT NULL;


2. Ajouter une contrainte CHECK
ALTER TABLE products
ADD CONSTRAINT positive_price CHECK (price > 0);
-- Ici, positive_price est le nom donne a la contrainte.

3. Ajouter une valeur par defaut
ALTER TABLE products
ALTER COLUMN stock SET DEFAULT 0;


Ces modifications concernent une table existante, sans avoir a la recreer. 
Attention : certaines contraintes peuvent etre refusees si les donnees deja presentes ne les respectent pas.

*/

/*
Modifier une table existante

On suppose que la table products existe deja :
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    price INTEGER,
    stock INTEGER
);


Tu dois effectuer les modifications suivantes :
1. Rendre name obligatoire (NOT NULL).
2. Ajouter une contrainte nommee positive_price qui impose price > 0.
3. Definir 0 comme valeur par defaut de stock.
*/

ALTER TABLE products
ALTER COLUMN name SET NOT NULL;


ALTER TABLE products 
ADD CONSTRAINT positive_price CHECK (price > 0);


ALTER TABLE products
ALTER COLUMN stock SET DEFAULT 0;

/*
Deux nuances importantes : 
SET NOT NULL echouera si name contient deja des valeurs NULL, 
et SET DEFAULT 0 ne modifie pas les lignes existantes.
*/

-------   Supprimer ou modifier des contraintes

/*
Avec ALTER TABLE, tu peux aussi retirer des contraintes devenues inutiles.

Supprimer une contrainte CHECK
ALTER TABLE products
DROP CONSTRAINT positive_price;

Retirer NOT NULL
ALTER TABLE products
ALTER COLUMN name DROP NOT NULL;

Retirer une valeur par defaut
ALTER TABLE products
ALTER COLUMN stock DROP DEFAULT;

Attention : 
une contrainte NOT NULL ne se retire pas de la meme maniere qu'une contrainte CHECK nommee.
*/

/*
Retirer des contraintes
On suppose que la table products existe deja :
CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INTEGER CONSTRAINT positive_price CHECK (price > 0),
    stock INTEGER DEFAULT 0
);


Objectif : modifier cette table pour :

1. Supprimer la contrainte positive_price.
2. Autoriser les valeurs NULL dans name.
3. Supprimer la valeur par defaut de stock.
*/


ALTER TABLE products 
DROP CONSTRAINT positive_price;

ALTER TABLE products 
ALTER COLUMN name DROP NOT NULL;

ALTER TABLE products
ALTER COLUMN stock DROP DEFAULT;

/*
Nous allons maintenant verifier ta capacite a combiner plusieurs contraintes dans une situation realiste.

La table categories existe deja :
CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);


Tu dois creer une table products avec les caracteristiques suivantes :
Colonne	     Type	     Contraintes
id	         INTEGER	     PRIMARY KEY
name	     VARCHAR(100)    NOT NULL
sku	         VARCHAR(50)	 UNIQUE, NOT NULL
price	     INTEGER	     NOT NULL, strictement superieur a 0
stock	     INTEGER	     DEFAULT 0, superieur ou egal a 0
status	     VARCHAR(20)	 DEFAULT 'active', NOT NULL
category_id	 INTEGER	     Cle etrangere vers categories(id), avec ON DELETE SET NULL

*/


CREATE TABLE products (
    id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    price INTEGER NOT NULL CHECK (price > 0),
    stock INTEGER DEFAULT 0 CHECK (stock >= 0),
    status VARCHAR(20) DEFAULT 'active' NOT NULL,
    category_id INTEGER REFERENCES categories(id)
        ON DELETE SET NULL
);

/*
Questions supplementaires :

Apres la creation de la table, on execute :
INSERT INTO products (id, name, sku, price, category_id)
VALUES (1, 'Laptop', 'LAP-001', 1200, 10);


On suppose que la categorie 10 existe.

Question 1 : quelles valeurs sont attribuees a stock et status ?

Question 2 : que devient ce produit si la categorie 10 est supprimee ?

Question 3 : que se passe-t-il si on tente d'inserer un deuxieme produit avec le meme sku ?

Reponse 1 : stock 0 status 'active'
Reponse 2 : il devient NULL grace a ON DELETE SET NULL
Reponse 3 : echec grace a la containte UNIQUE 

*/

/*
Tu sais maintenant utiliser NOT NULL, UNIQUE, PRIMARY KEY, FOREIGN KEY, ON DELETE CASCADE, 
ON DELETE SET NULL, CHECK, DEFAULT et ALTER TABLE.
*/




