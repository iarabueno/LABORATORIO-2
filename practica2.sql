/*
1. Crear un bloque anónimo para desplegar los siguientes mensajes:
‘Hola , soy ‘ username 
‘Hoy es: ‘  dd – Mon – yyyy’.  (mostrar la fecha del día)
*/

declare
    v_username varchar2(100);
    v_fecha    varchar2(30);
begin

    v_username := USER;

    v_fecha := TO_CHAR(SYSDATE, 'DD - Mon - YYYY');

    dbms_output.put_line('Hola, soy ' || v_username);
     dbms_output.put_line'Hoy es: ' || v_fecha);
END;

/*
2. Crear un bloque Pl/Sql para consultar el salario de un empleado dado:
Ingresar el id del empleado usando una variable de sustitución
Desplegar por pantalla el siguiente texto:
First_name, Last_name  tiene un salario de Salary pesos.
*/

-- select employee_id 
-- from employee
-- order by employee_id;


declare

v_id_empleado employee.employee_id%type := 7565;  --&id_del_empleado;
v_first_name_empleado employee.first_name%type;
v_last_name_empleado employee.last_name%type;
v_salary_empleado employee.salary%type;

begin

select first_name, last_name, salary
into v_first_name_empleado, v_last_name_empleado, v_salary_empleado
from employee
where employee_id = v_id_empleado;

dbms_output.put_line('nombre: ' || v_first_name_empleado || ' apellido: ' || v_last_name_empleado || ' salario: ' || v_salary_empleado);

exception

when NO_DATA_FOUND then
dbms_output.put_line('no se encontró el empleado');

when OTHERS then
dbms_output.put_line('ocurrió un error');
end;


