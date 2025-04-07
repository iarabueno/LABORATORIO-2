/*
FRIENDLY REMINDER
ORDEN: 

SELECT ...
FROM ...
[JOIN ...]
WHERE ...
GROUP BY ...
HAVING ...
ORDER BY ...
*/


/*
2. Mostrar las distintas funciones (jobs) que pueden cumplir los empleados.
*/

select distinct function from job;

/*
3. Desplegar el nombre completo de todos los empleados (Ej: Adam, Diane) ordenados por apellido.
*/

select last_name, first_name from employee
order by last_name;

/*
4. Mostrar el nombre y el apellido de los empleados que ganan entre $1500 y $2850.
*/

select first_name, last_name from employee 
where salary between 1500 and 2850;

/*
5. Mostrar el nombre y la fecha de ingreso de todos los empleados que ingresaron en el año 2006.
*/

select first_name, hire_date 
from employee
where hire_date between to_date ('01-01-2006', 'DD - MM - YYYY')
                and to_date ('31-12-2006', 'DD - MM - YYYY')
order by hire_date;

/*
6. Mostrar el id y nombre de todos los departamentos de la localidad 122. 
*/

select department_id, name 
from department d 
where location_id = 122;

/*
7. Modificar el ejercicio anterior para que la localidad pueda ser ingresada en el momento de efectuar la consulta.
*/

DECLARE
    v_location_id NUMBER;
BEGIN
    -- Pedir la localidad al usuario
    v_location_id := :ingresar_localidad;  

    -- Ejecutar la consulta
    FOR r_departamento IN (SELECT department_id, name  -- Error corregido aquí
                           FROM department  -- Error corregido aquí
                           WHERE location_id = v_location_id)
    LOOP 
        DBMS_OUTPUT.PUT_LINE('ID: ' || r_departamento.department_id ||  -- Error corregido aquí
                             ' - Nombre: ' || r_departamento.name);
    END LOOP;
END;
/

/*
8. Mostrar el nombre y salario de los empleados que no tienen jefe.
*/

select first_name, salary 
from employee
where manager_id is null;


/*
10. Mostrar el nombre completo de los empleados, el número de departamento y el nombre del departamento donde trabajan.
*/

select e.first_name,
       e.last_name,
       e.department_id,
       d.name
from employee e
inner join department d
on e.department_id = d.department_id;

/*
11. Mostrar el nombre y apellido, la función que ejercen, el nombre del departamento y el salario de todos los empleados ordenados por su apellido.
*/

select e.first_name,
       e.last_name,
       d.name,
       j.function,
       e.salary
from employee e

inner join department d on
e.department_id = d.department_id

inner join job j on 
e.job_id = j.job_id

order by e.last_name;

/*
12. Para todos los empleados que cobran comisión, mostrar su nombre, el nombre del departamento donde trabajan y el nombre de la región a la que pertenece el departamento.
*/

select e.first_name, 
       d.name, 
       l.regional_group
from employee e
inner join department d on
e.department_id = d.department_id
inner join location l on
d.location_id = l.location_id
where e.commission is not null;

/*
14. Mostrar el número y nombre de cada empleado junto con el número de empleado y nombre de su jefe.
*/

select e.employee_id,
       e.first_name,
       j.employee_id,
       j.employee_id
from employee e
left join employee j on
e.manager_id = j.employee_id;

/*
15. Modificar el ejercicio anterior para mostrar también aquellos empleados que no tienen jefe. 
*/

select e.employee_id,
       e.first_name,
       j.employee_id,
       j.first_name
from employee e
left join employee j on 
e.manager_id = j.employee_id;

/*
16. Mostrar las órdenes de venta, el nombre del cliente al que se vendió y la descripción  de los productos. Ordenar la  consulta por nro. de orden.
*/

select so.order_id,
       c.name,
       p.description
from sales_order so

inner join customer c on 
so.customer_id = c.customer_id

inner join item i on 
so.order_id = i.order_id

inner join product p on 
i.product_id = p.product_id

order by so.order_id;

/*
17. mostrar la cantidad de clientes
*/

select count(*) as cantidad_clientes
from customer;

/*
18. Mostrar la cantidad de clientes del estado de Nueva York (NY).
*/

select * from customer;

-- cuando se quiere contar una cantidad de algo especifico: 1- SELECT, 2- FROM, 3- WHERE

select count(*) as cantidad_clientes_NY
from customer
where state = 'NY' and city = 'NEW YORK';

/*
19. Mostrar la cantidad de empleados que son jefes. Nombrar a la columna JEFES.
*/

select count(distinct manager_id) as JEFES
from employee 
where manager_id is not null;


/*
20. Mostrar toda la información del empleado más antiguo.
*/

select * 
from employee 
where hire_date = (
                   select min(hire_date)
                   from employee
);

/*
21. Generar un listado con el nombre completo de los empleados, el salario, y el nombre de su departamento para todos los empleados que tengan el mismo cargo que John Smith. Ordenar la salida por salario y apellido.
*/

select e.first_name,
       e.last_name,
       e.salary,
       d.name
from employee e

inner join department d on 
e.department_id = d.department_id

where e.job_id = ( -- acá esta diciendo que busque si el job ib es igual al de john smith
                select job_id from employee 
                where upper(first_name) = 'JOHN' and upper(last_name) = 'SMITH'
)

order by e.salary, e.last_name;

/*
22. Seleccionar los nombres completos, el nombre del departamento y el salario de aquellos empleados que ganan más que el promedio de salarios.
*/

select e.first_name,
       e.last_name,
       d.name,
       e.salary
from employee e

inner join department d on 
e.department_id = d.department_id

 where e.salary > (
                    select avg(salary)
                    from employee
 );

/*
23. Mostrar los datos de las órdenes máxima y mínima.
*/

select * 
select * 
from sales_order
where order_id = (select max(order_id) from sales_order) or 
      order_id = (select min(order_id) from sales_order);

/*
24. Mostrar la cantidad de órdenes agrupadas por cliente. 
*/

select c.customer_id,
       c.name,
       count(*) as cantidad_ordenes
from sales_order so

inner join customer c on 
so.customer_id = c.customer_id 

group by c.customer_id, c.name
order by cantidad_ordenes desc;

/*
28. Mostrar la cantidad de empleados que tiene los departamentos 20 y 30.
*/

select count(*) as cantidad_empleados
from employee

where department_id in (20,30);

/*
29. Mostrar el promedio de salarios de los empleados de los departamentos de investigación (Research). Redondear el promedio a dos decimales.
*/

select round(avg(e.salary), 2) as promedio_salary
from employee e

inner join department d on 
e.department_id = d.department_id

where lower(d.name) like '%research%';

/*
30. Por cada departamento desplegar su id, su nombre y el promedio de salarios (sin decimales) de sus empleados. El resultado ordenarlo por promedio.
*/


select d.department_id,
       d.name,
       trunc(avg(e.salary)) as promedio_salario
from employee e

left join department d on 
e.department_id = d.department_id 

group by d.department_id, d.name
order by promedio_salario;



/*
RECORDATORIO 

INNER JOIN: Muestra solo las filas que tienen coincidencia en ambas tablas. Se utiliza solo te interesan los datos que tienen relación en ambas tablas
LEFT JOIN: Muestra todas las filas de la tabla izquierda (aunque no coincidan). Cuando querés ver todos los datos de una tabla, incluso si no hay coincidencias en la otra

¿Estoy empezando por una tabla "principal" y quiero ver si hay datos relacionados, aunque no siempre los haya? → LEFT JOIN.

¿Solo me interesan los datos que están conectados en ambas tablas? → INNER JOIN.

*/

/*
31. Modificar el ejercicio anterior para mostrar solamente los departamentos que tienen más de 3 empleados.
*/
select d.department_id,
       d.name,
       trunc(avg(e.salary)) as promedio_salario
from employee e

left join department d on 
e.department_id = d.department_id 

group by d.department_id, d.name
having count(e.employee_id) > 3
order by promedio_salario;

/*
32. Por cada producto (incluir todos los productos)  mostrar la cantidad de unidades que se han pedido y el precio máximo que se ha facturado. 
*/

select p.product_id,
       p.description,
       count(i.quantity) as cantidad_de_unidades,
       max(i.actual_price) as precio_maximo
from item i 

left join product p on 
i.product_id = p.product_id
group by p.product_id, p.description
order by p.product_id;


select * from sales_order;

/*
33. Para cada cliente mostrar nombre, teléfono, la cantidad de órdenes emitidas y la fecha de su última orden. Ordenar el resultado por nombre de cliente.
*/

select c.name,
       c.address,
       count(so.order_id) as cantidad_de_ordenes,
       max(so.ship_date) as ultima_orden
from customer c

left join sales_order so on 
so.customer_id = c.customer_id

group by c.name, c.address
order by c.name;

/*
34. Para todas las localidades mostrar sus datos, la cantidad de empleados que tiene y el total de salarios de sus empleados. Ordenar por cantidad de empleados.
*/

select l.location_id,
       l.regional_group,
       count(e.employee_id) as cantidad_empleados,
       sum(e.salary) as total_salario

from location l

left join department d on 
l.location_id = d.location_id

left join employee e on 
d.department_id = e.department_id

group by l.location_id, l.regional_group
order by cantidad_empleados;

/*
35. Mostrar los empleados que ganan más que su jefe. El reporte debe mostrar el nombre completo del empleado, su salario, el nombre del departamento al que pertenece y la función que ejerce.
*/

select e.first_name as nombre_empleado,
       e.last_name as apellido_empleado,
       e.salary,
       d.name 
from employee e

join employee j on 
e.manager_id = j.employee_id

join department d on 
e.department_id = d.department_id

join job jo on 
e.job_id = jo.job_id

where e.salary > j.salary;
