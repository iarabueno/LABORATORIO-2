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
*/
create or replace function "FU_VALIDAR_LOCATION" (
    p_regional_group in location.regional_group%type)
return location.location_id%type
as
    v_regional_group location.regional_group%type;
    v_location_id location.location_id%type;
begin
    
    if p_regional_group is null then 
    raise_application_error(-20001, 'no se puede dejar este campo vacio');
    end if;

    select location_id into
    v_location_id from location
    where regional_group = v_regional_group;

    return v_location_id;

exception
    when no_data_found then
    raise_application_error(-20001, 'no se ha encontrado ninguna localidad');

    when too_many_rows then 
    raise_application_error(-20002, 'hay mas localidades con esa misma region');

    when others then 
    raise_application_error(-20003, 'ocurrio un error inesperado ' || sqlerrm);
end "FU_VALIDAR_LOCATION";
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
