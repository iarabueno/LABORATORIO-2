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

/*
5. Escribir un bloque para mostrar la cantidad de órdenes que emitió un cliente dado siguiendo las siguientes consignas:
Ingresar el id del cliente una variable de sustitución
Si el cliente emitió menos de 3 órdenes desplegar:
	“El cliente nombre  ES REGULAR”.
Si emitió entre 4 y 6
	“El cliente  nombre ES BUENO”.
Si emitió más:
	“El cliente nombre ES MUY BUENO”.

    CUSTOMER
#* customer_id
 name
 address
 city, state,.......
* salesperson_id
 credit limit

SALES ORDER
#* order_id
 order_date
* customer_id
 ship_date
 total

 
*/

declare

v_id_cliente sales_order.customer_id%type := 101; --&id_customer;
v_nombre_cliente customer.name%type;
v_cantidad_ordenes number;


begin

-- para el nombre de cliente
select name 
into v_nombre_cliente 
from customer 
where customer_id = v_id_cliente;

-- cantidad de ordenes
select count(*) 
into v_cantidad_ordenes
from sales_order
where customer_id = v_id_cliente;

-- condicion
if v_cantidad_ordenes < 3 then
dbms_output.put_line('el cliente ' || v_nombre_cliente || ' es REGULAR');
elsif v_cantidad_ordenes between 4 and 6 then 
dbms_output.put_line('el cliente ' || v_nombre_cliente || 'es BUENO');
else 
dbms_output.put_line('el cliente ' || v_nombre_cliente || 'es MUY BUENO');

end if;


exception

when NO_DATA_FOUND then 
dbms_output.put_line('no se encontró el cliente');

when OTHERS then 
dbms_output.put_line('ocurrió un error inesperado ' || SQLERRM);

end;




