-- Seleccionar el nombre, apellido y dirección de correo electrónico de todos los clientes que han alquilado una película.

SELECT DISTINCT c.first_name, c.last_name, c.email
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id;

-- ¿Cuál es el pago promedio realizado por cada cliente? (Mostrar el ID del cliente, el nombre del cliente concatenado y el pago promedio realizado)

SELECT c.customer_id, 
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
       AVG(p.amount) AS average_payment
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, customer_name;

-- Seleccionar el nombre y dirección de correo electrónico de todos los clientes que han alquilado películas de "Action".
-- a. Consulta usando múltiples sentencias JOIN

SELECT DISTINCT c.first_name, c.last_name, c.email
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
WHERE cat.name = 'Action';

-- b. Consulta usando subconsultas con múltiples cláusulas WHERE e IN

SELECT c.first_name, c.last_name, c.email
FROM customer c
WHERE c.customer_id IN (
    SELECT r.customer_id
    FROM rental r
    WHERE r.inventory_id IN (
        SELECT i.inventory_id
        FROM inventory i
        WHERE i.film_id IN (
            SELECT f.film_id
            FROM film f
            WHERE f.film_id IN (
                SELECT fc.film_id
                FROM film_category fc
                WHERE fc.category_id = (
                    SELECT cat.category_id
                    FROM category cat
                    WHERE cat.name = 'Action'
                )
            )
        )
    )
);

-- Verificar si las dos consultas anteriores producen los mismos resultados
-- Para verificar si las dos consultas producen los mismos resultados, puedes comparar las salidas de ambas consultas utilizando un operador 
-- EXCEPT o una unión con un DISTINCT para ver si hay diferencias.

-- Verificación con EXCEPT (puede variar según el soporte de EXCEPT en tu SGBD)
SELECT DISTINCT c.first_name, c.last_name, c.email
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category cat ON fc.category_id = cat.category_id
WHERE cat.name = 'Action'
EXCEPT
SELECT c.first_name, c.last_name, c.email
FROM customer c
WHERE c.customer_id IN (
    SELECT r.customer_id
    FROM rental r
    WHERE r.inventory_id IN (
        SELECT i.inventory_id
        FROM inventory i
        WHERE i.film_id IN (
            SELECT f.film_id
            FROM film f
            WHERE f.film_id IN (
                SELECT fc.film_id
                FROM film_category fc
                WHERE fc.category_id = (
                    SELECT cat.category_id
                    FROM category cat
                    WHERE cat.name = 'Action'
                )
            )
        )
    )
);

-- Consulta Ajustada sin UNION ALL Utilizando CTE

WITH query1 AS (
    SELECT DISTINCT c.first_name, c.last_name, c.email
    FROM customer c
    JOIN rental r ON c.customer_id = r.customer_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category cat ON fc.category_id = cat.category_id
    WHERE cat.name = 'Action'
), query2 AS (
    SELECT c.first_name, c.last_name, c.email
    FROM customer c
    WHERE c.customer_id IN (
        SELECT r.customer_id
        FROM rental r
        WHERE r.inventory_id IN (
            SELECT i.inventory_id
            FROM inventory i
            WHERE i.film_id IN (
                SELECT f.film_id
                FROM film f
                WHERE f.film_id IN (
                    SELECT fc.film_id
                    FROM film_category fc
                    WHERE fc.category_id = (
                        SELECT cat.category_id
                        FROM category cat
                        WHERE cat.name = 'Action'
                    )
                )
            )
        )
    )
)
SELECT q1.first_name, q1.last_name, q1.email
FROM query1 q1
LEFT JOIN query2 q2 ON q1.first_name = q2.first_name AND q1.last_name = q2.last_name AND q1.email = q2.email
WHERE q2.email IS NULL

UNION ALL

SELECT q2.first_name, q2.last_name, q2.email
FROM query2 q2
LEFT JOIN query1 q1 ON q2.first_name = q1.first_name AND q2.last_name = q1.last_name AND q2.email = q1.email
WHERE q1.email IS NULL;

-- Use the case statement to create a new column classifying existing columns as either or high value transactions based on the amount of payment.
-- If the amount is between 0 and 2, label should be low and if the amount is between 2 and 4,
-- the label should be medium, and if it is more than 4, then it should be high.

SELECT p.payment_id, 
       p.amount, 
       CASE 
           WHEN p.amount BETWEEN 0 AND 2 THEN 'low'
           WHEN p.amount BETWEEN 2 AND 4 THEN 'medium'
           ELSE 'high'
       END AS payment_classification
FROM payment p;

