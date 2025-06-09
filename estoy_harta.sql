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
