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








































