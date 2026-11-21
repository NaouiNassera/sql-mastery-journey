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

-- Règle importante : le nombre de colonnes declarees doit correspondre au 
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