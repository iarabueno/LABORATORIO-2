/*CONSULTAS*/
/*
1)  Realice una consulta SQL que muestre Nombre del clientes, nombre y apellido del vendedor de clientes que tienen menos de 5 órdenes de compra.
*/
select c.name,
       e.first_name,
       e.last_name,
       count(so.order_id) as cantidad_ordenes
       from customer c

full outer join employee e on 
e.employee_id = c.salesperson_id

full outer join sales_order so on 
so.customer_id = c.customer_id

group by c.name, e.first_name, e.last_name
having count(so.order_id) < 5 
order by c.name;

/*
Realice una consulta SQL que muestre el id de producto, descripción precio lista vigente, precio min vigente y cantidad de ordenes en las que fue vendido, para aquellos productos que estén incluidos en
más de 10 órdenes.
Ordenados por nombre de producto.
*/

select i.product_id,
       pro.description,
       pri.list_price,
       pri.min_price,
       count(distinct i.order_id) as cantidad_ordenes
       from item i

inner join product pro on 
pro.product_id = i.product_id

inner join price pri on
pri.product_id = pro.product_id

group by 
         i.product_id,
         pro.description,
         pri.list_price,
         pri.min_price
having count(distinct i.order_id) > 10 
order by pro.description;

/*
1) Realice una consulta SQL que muestre el id de producto, descripción y cantidad de ordenes en las que fue vendido, para aquellos productos que estén 
en mas de 3 ordenes.  Ordenados por nombre de producto.
*/
select i.product_id,
       pro.description,
       count(i.order_id) as cantidad_ordenes
       from item i 

inner join product pro on
pro.product_id = i.product_id 

group by i.product_id,
        pro.description
having count(distinct i.order_id) > 3
order by pro.description;

/*
Listar todos los departmanetos y regiones en los que haya mas de 2 empleados, indicando el nombre del departamento
 el nombre de la region y la cantidad de empleados bajo la denominacion TOTAL EMPLEADOS. 
El listado debe quedar ordenado por los departamentos con mayor cantidad de empleados.
*/

select d.name as nombre_departamento,
       l.regional_group as nombre_region,
       count(e.employee_id) as total_empleados 
       from department d 

inner join location l on
l.location_id = d.location_id 

inner join employee e on 
e.department_id = d.department_id

group by d.name,
       l.regional_group
having count(e.employee_id) > 2       
order by total_empleados desc;


------------------------------------------------------------------------------------------------------------------------
/*FUNCIONES*/
/*
2)  Función que valida el cliente, la cual recibe el nombre de un cliente y retorna el id correspondiente o cancela con excepciones propias indicando el error en el mensaje del error.

Contemplar todo error posible..
*/
create or replace function "FU_VALIDAR_CLIENTE" (
    p_first_name in customer.name%type)
return customer.customer_id%type
as
v_customer_id customer.customer_id%type;
v_name customer.name%type;   
begin

    if p_first_name IS NULL then 
        raise_application_error(-20000, 'el nombre del cliente no puede quedar nulo');
    end if;

    select customer_id 
    into v_customer_id
    from customer
    where name = p_first_name;
    return v_customer_id;
    
exception
    when no_data_found then
    raise_application_error(-20001, 'No se ha encontrado ningun cliente');

    when too_many_rows then 
    raise_application_error(-20002, 'hay multiples clientes con ese nombre');

    when others then
    raise_application_error(-20003, 'error inesperado: ' || sqlerrm);
end "FU_VALIDAR_CLIENTE";
/

/*
2) Escribir una función que recibe como parámetro un nombre de una region (regional _group) y retorna su ID (location_id) o cancela con excepciones propias indicando el error en el mensaje del error.
Contemplar todo error posible
*/create or replace procedure "PR_ELIMINAR_DEPARTAMENTOS" (
    p_regional_group      in  location.regional_group%type
    )
as

v_validar_location location.location_id%type;
begin

-- validamos cliente

v_validar_location := fu_validar_location(p_regional_group);

delete from department
where location_id = v_validar_location;

dbms_output.put_line('se han eliminado los departamentos de la localidad '|| p_regional_group);

exception 
when others then 

dbms_output.put_line('no se pudo eliminar correctamente: || motivo: ' || sqlerrm);


end "PR_ELIMINAR_DEPARTAMENTOS";
/
/*
 2) Escribir una función que recibe como parámetro un nombre de producto y retorna su ID o cancela con excepciones propias indicando el error en el mensaje del error.
 Contemplar todo error posible.
*/

create or replace function "FU_VALIDAR_PRODUCTO" (
    p_description in product.description%type)
return product.product_id%type
as
    v_product_id product.product_id%type;
begin
    
    if p_description is null then 
    raise_application_error(-20000, 'no se puede dejar este campo vacio');

    end if;

    select product_id into v_product_id 
    from product 
    where description = p_description;

    return v_product_id;

exception
    when no_data_found then
    raise_application_error(-20001, 'no se ha encontrado ningun producto con ese nombre');

    when too_many_rows then 
    raise_application_error(-20002, 'hay más productos con ese nombre');

    when others then 
    raise_application_error(-20003, 'ocurrio un error inesperado ' || sqlerrm);
end "FU_VALIDAR_PRODUCTO";
/

/*
Escribir una funcion denominada CODIGO_LOCALIDAD que al recibir como parametro el nombre de una region (regional_group) retorne
su ID (location_id). Manejar las excepciones correspondientes, retornando:
0 si la region no existe
-1 si existen varias regiones que se corresponden con el parametro ingresado
-2 para cualquier otro error que pueda ocurrir.
*/
create or replace function "FU_CODIGO_LOCALIDAD" (
    p_regional_group in location.regional_group%type)
return location.location_id%type
as
    v_location_id location.location_id%type;
begin
    
    if p_regional_group is null then
    raise_application_error(-20000, 'no se puede dejar este campo vacio');
    end if;

    select location_id 
    into v_location_id 
    from location 
    where regional_group = p_regional_group;

    return v_location_id;

exception
    when no_data_found then
    return 0;

    when too_many_rows then 
    return -1;
    
    when others then 
    return -2;
    
end "FU_CODIGO_LOCALIDAD";
/
------------------------------------------------------------------------------------------------------------------------
/*PROCEDIMIENTOS*/
/*
    
3)  Procedimiento que permita dar de alta un cliente.

Recibirá por parámetro el id del cliente, el nombre del cliente, dirección, ciudad, código postal y el id del vendedor



·    Informar si se actualizo correctamente

·    Si ya existe un cliente con ese nombre no darlo de alta e informarlo

·    Utilizar la función del punto anterior

·    Si no se pudo realizar informar el motivo correcto. No Cancelar
*/
    
create or replace procedure "PR_DAR_ALTA_CLIENTE" (
    pi_customer_id in customer.customer_id%type,
    pi_name      in customer.name%type,
    pi_city        in customer.address%type,
    pi_zip_code        in customer.zip_code%type,
    pi_salesperson_id   in customer.salesperson_id%type)
as
v_validar_cliente customer.customer_id%type;

begin
   v_validar_cliente := fu_validar_cliente(pi_name);

   dbms_output.put_line('ya existe un cliente con ese nombre, no podemos realizar el alta');

exception 
when others then
-- Si el error es que no existe el cliente, entonces lo damos de alta
begin
if SQLCODE = -20001 then
insert into customer(
    customer_id, name, address, city, zip_code, area_code, phone_number, salesperson_id, credit_limit, comments
)
values
(pi_customer_id, pi_name, null, pi_city, pi_zip_code, null, null, pi_salesperson_id, null, null);

dbms_output.put_line('se ha insertado de manera correcta');

else 
-- para otros errores
dbms_output.put_line('no se pudo dar el alta el cliente. || motivo: ' || SQLERRM);
end if;
end;

end "PR_DAR_ALTA_CLIENTE";
/

/*
3) Escribir un procedimiento que permite eliminar todos los departamentos de una localidad.
El procedimiento recibe como parámetros
• nombre de la localidad
Manejar las excepciones correspondientes,
• Informar si pudo realizar su propósito correctamente
• Utilizar la función del punto anterior
• Si no se pudo realizar informar el motivo correcto. No Cancelar
*/
create or replace procedure "PR_ELIMINAR_DEPARTAMENTOS" (
    p_regional_group      in  location.regional_group%type
    )
as

v_validar_location location.location_id%type;
begin

-- validamos cliente

v_validar_location := fu_validar_location(p_regional_group);

delete from department
where location_id = v_validar_location;

dbms_output.put_line('se han eliminado los departamentos de la localidad '|| p_regional_group);

exception 
when others then 

dbms_output.put_line('no se pudo eliminar correctamente: || motivo: ' || sqlerrm);


end "PR_ELIMINAR_DEPARTAMENTOS";
/

/*
2)    
- Escribir un procedimiento ELIMINAR_DEPTO que permita eliminar todos los departamentos ubicados en una localidad (regional_group).
-- El procedimiento recibe como parametro el nombre de la region y obtiene su id de localidad (location_id) utilizando la funcion
-- definida en el punto 2.
-- Manejar los mensaje y las excepciones correspondientes al procedimiento a saber:
-- Debe imprimir DEPARTAMENTO ELIMINADO u OCURRIO UN PROBLEMA AL BORRAR LOS DEPAPRTAMENTOS DE LA LOCALIDAD.
*/

create or replace procedure "PR_ELIMINAR_DEPTO" (
    p_regional_group      in location.regional_group%type)
as

v_validar_localidad location.location_id%type;
e_restriccion_integridad exception;
pragma exception_init(e_restriccion_integridad, -02292);

begin

v_validar_localidad := fu_codigo_localidad(p_regional_group);

if v_validar_localidad not in (0,-1,-2) then 
delete from department
where location_id = v_validar_localidad;

-- tenemos que hacer esto porque no permitia el uso de raise application error
if sql%rowcount > 0 then 
    dbms_output.put_line('se ha eliminado el departamento');
    else
    dbms_output.put_line('ocurrio un error al borrar los departamentos');
    end if;
    else 
    dbms_output.put_line('ocurrio un error al borrar los departamentos');
    end if;

exception 
when e_restriccion_integridad then 
dbms_output.put_line('ocurrio un problema al borrar toods los departamentos ' || sqlerrm);
end "PR_ELIMINAR_DEPTO";
/
