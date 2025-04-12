/*
2. Crear un bloque anónimo para desplegar los siguientes mensajes:
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
3. Crear un bloque Pl/Sql para consultar el salario de un empleado dado:
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
dbms_output.put_line('ocurrió un error' || SQLERRM);
end;

/*
4. Escribir un bloque para desplegar todos los datos de una orden dada. 
Ingresar el nro de orden  usando una variable de sustitución
En una variable de tipo record recuperar toda la información y desplegarla usando Dbms_output.
Que pasa si la orden no existe?

SALES ORDER
#* order_id
 order_date
* customer_id
 ship_date
 total

*/

select order_id 
from sales_order
order by order_id;
/

declare

v_order_id sales_order.order_id%type := 510; --&valor_order_id;

type sales_order_record_type is record (
    order_id sales_order.order_id%type,
    order_date sales_order.order_date%type,
    customer_id sales_order.customer_id%type,
    ship_date sales_order.ship_date%type,
    total sales_order.total%type
);

v_sales_order sales_order_record_type;

begin

select order_id, order_date, customer_id, ship_date, total
into v_sales_order
from sales_order
where order_id = v_order_id;

dbms_output.put_line('order id: ' || v_sales_order.order_id );
dbms_output.put_line('fecha de orden: ' || v_sales_order.order_date);
dbms_output.put_line('customer id: '|| v_sales_order.customer_id );
dbms_output.put_line('ship date: ' || v_sales_order.ship_date );
dbms_output.put_line('total: ' || v_sales_order.total );

exception

when NO_DATA_FOUND then
dbms_output.put_line('no se encontro la orden');

when OTHERS then
dbms_output.put_line('ocurrio un error inesperado ' || SQLERRM);

end;




