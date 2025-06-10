/*CONSULTAS*/
/*
1)  Realice una consulta SQL que muestre Nombre del clientes, nombre y apellido del vendedor de clientes que tienen menos de 5 órdenes de compra.
*/


select c.name, e.first_name, e.last_name, count(so.sales_order) as total_ordenes from customer c 

full outer join employee e on 
e.employee_id = c.salesperson_id

full outer join sales_order so on 
so.customer_id = c.customer_id

group by(c.name, e.first_name, e.last_name)
having count(so.sales_order) < 5
order by name;

select c.name,
       e.first_name,
       e.last_name,
       count(so.sales_order) as total_ordenes;
from customer

  full outer join employee e on
  e.employee_id = c.salesperson_id;

  full outer join sales_order so on 
  so.customer_id = c.customer_id;

group by(c.name, e.first_name, e.last_name)
having count(so.sales_order) < 5
order by c.name;

select c.name,
       e.first_name,
       e.last_name,
       count(so.order_id%type) as ordenes_de_compra;
from customer c

full outer join employee e on 
  e.employee_id = c.salesperson_id;

full outer join sales_order so on 
  so.customer_id = c.customer_id;

group by(c.name, e.first_name, e.last_name)
having count(so.order_id)< 5
  order by ordenes_de_compra;

/*
2)  Función que valida el cliente, la cual recibe el nombre de un cliente y retorna el id correspondiente o cancela con excepciones propias indicando el error en el mensaje del error.
Contemplar todo error posible..
*/

create or replace function "fu_validar_cliente"(
  p_name customer.name%type
) return customer.customer_id%type
  as
  v_customer_id customer.customer_id%type;
  begin
    if p_name is null then
    raise_application_error(-20000, ' no se puede dejar campo vacio ');
    end if;

    select customer_id 
    into v_customer_id 
    from customer_id
    where name = p_name;

    exception
      when no_data_found then 
      raise_application_error(-20001, 'no se ha encontrado el cliente con ese nombre');

      when too_many_rows then
      raise_application_error(-20002, 'hay más de un cliente con ese nombre');

      when others then
      raise_application_error(-20003, 'ocurrio un error inesperado ' || sqlerrm);
      
  end "fu_validar_cliente");

create or replace function "fu_validar_cliente"(
  p_name customer.name%type)
  return customer.customer_id%type
  as 

  v_customer_id customer.customer_id%type;

  begin 

    if p_name is null then 
    raise_application_error(-20000, 'no se puede dejar campo nulo');

    select customer_id into
    v_customer_id from customer
    where name = p_name;
    return v_customer_id;

exception 
  when no_data_found then 
  raise_application_error(-20001, 'no se ha encontrado un cliente con ese nombre');

  when too_many_rows then
  raise_application_error(-20002, 'hay más de un cliente con ese nombre');

  when others then 
  raise_application_error(-20003, 'error inesperado: '|| sqlerrm);

  end "fu_validar_cliente";

create or replace function "fu_validar_cliente" (
p_name in customer.name%type
  ) 
return  customer.customer_id%type
as
v_customer_id customer.customer_id%type; 
begin 

  if v_customer_id is null then 
  raise_application_error(-20000, 'no se puede dejar campo nulo');
  end if;

  select customer_id into v_customer_id
  from customer 
  where name = p_name;
  return v_customer_id;

exception

  when no_data_found then
  raise_application_error(-20001, 'no se ha encontrado ningun cliente con ese nombre');

  when too_many_rows then 
  raise_application_error(-20002, 'hay más de un cliente con ese nombre');

  when others then 
  raise_application_error(-20003, 'error inesperado ' || sqlerrm);
  
end "fu_validar_cliente";

/*
3)  Procedimiento que permita dar de alta un cliente.

Recibirá por parámetro el id del cliente, el nombre del cliente, dirección, ciudad, código postal y el id del vendedor



·    Informar si se actualizo correctamente

·    Si ya existe un cliente con ese nombre no darlo de alta e informarlo

·    Utilizar la función del punto anterior

·    Si no se pudo realizar informar el motivo correcto. No Cancelar
*/
create or replace "pr_dar_alta_cliente"(
 pi_customer_id in customer.customer_id%type,
    pi_name      in customer.name%type,
    pi_city        in customer.address%type,
    pi_zip_code        in customer.zip_code%type,
    pi_salesperson_id   in customer.salesperson_id%type)
  as 
  v_validar_cliente customer.customer_id%type;
  begin 
  v_validar_cliente := fu_validar_cliente(pi_name);
  dbms_out.put_put_line('hay un cliente con ese nombre');
  exception
    begin 
    when others then 
    insert into customer(customer_id, name, address, city, zip_code, area_code, phone_number, salesperson_id, credit_limit, comments)
    values (pi_customer_id, pi_name, null, pi_city, pi_zip_code, null, null, pi_salesperson_id, null, null);
    dbms_output.put_line('se ingreso con exito');
    else 
    dbms_output.put_line('ocurrio un error ' || sqlerrm);
    end if;
  end;

create or replace "pr_dar_alta_cliente"(
 pi_customer_id in customer.customer_id%type,
    pi_name      in customer.name%type,
    pi_city        in customer.address%type,
    pi_zip_code        in customer.zip_code%type,
    pi_salesperson_id   in customer.salesperson_id%type)
  as 
  v_validar_cliente customer.customer_id%type;
  begin
  v_validar_cliente := fu_validar_cliente(pi_name);
  dbms_output.put_line('no se puede ingresar un cliente con ese nombre porque ya existe');
  exception 
  when others then 
  if SQLCODE = -20001 then
    insert into customer( customer_id, name, address, city, zip_code, area_code, phone_number, salesperson_id, credit_limit, comments)
    values(pi_customer_id, pi_name, null, pi_city, pi_zip_code, null, null, pi_salesperson_id, null, null);
  else 
    dbms.output_put.line('ocurrio un error inesperado '|| sqlerrm);
    end if;
  end;


create or replace "pr_dar_alta_cliente"(
  p_id_cliente in customer.customer_id%type,
  p_name in customer.name%type,
  p_address in customer.address%type,
  p_zip_code in customer.zip_code%type,
  p_salesperson_id in customer.salesperson%type
)
as
  v_validar_customer customer.customer_id%type;
begin 

  --para validar el cliente
  v_validar_customer := fu_validar_cliente(p_name);

  dbms_output.put_line('no se puede ingresar ese cliente porque ya existe');

  exception 
  begin 
  when others then 
    if SQLCODE = -20001 then 
    insert into customer(customer_id, name, address, city, zip_code, area_code, phone_number, salesperson_id, credit_limit, comments)
    (pi_customer_id, pi_name, null, pi_city, pi_zip_code, null, null, pi_salesperson_id, null, null);
    dbms_output.put_line('se ejecuto de manera correcta');
    else 
    when others then
    dbms_output.put_line('error. motivo: '|| sqlerrm);
    end if;
  end;
end "pr_dar_alta_cliente";

-----------------------------------------------------------------------------------------------------------------
select i.product_id, pro.description, pri.list_price, pri.min_price, count(distinct i.order_id) as cantidad_total_de_ordenes
frmom item i 
  inner join product pro on 
  pro.product_id = i.product_id;
  inner join price pri on 
  pri.product_id = pro.product_id;
group by i.product_id, pro.description, pri.list_price, pri.min_price
having count(distinct i.order_id) > 10
group by pro.description;

select d.name as nombre_departamento, l.regional_group as nombre_region, count(e.employee_id) as total_empleados
from department d

inner join location l on 
l.location_id = d.location_id;

inner join employee e on 
e.department_id = d.department_id;

group by d.name, l.regional_group
having count(e.employee_id) > 2
order by total_empleados desc;

----------------------------------------------------
create or reaplace "fu_validar_producto"(
  p_description product.description%type
) return product.product_id%type
as 
  v_product_id product.product_id%type;
  begin 
    if p_description is null then 
    raise_application_error(-20000, 'no se puede dejar este campo vacio');
    end if;

    select product_id into 
    v_product_id 
    from product 
    where description = p_description;

  exception
    when no_data_found then 
    raise_application_error(-20001, 'no se ha encontrado un producto con ese nombre');

    when too_many_rows then 
    raise_application_error(-20002, 'hay mas de un producto con ese nombre');

    when others then
    raise_application_error(-20003, 'ocurrio un error inesperado');
end "fu_validar_producto";

-------------------------------------



