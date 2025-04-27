-- FUNCION QUE RECIBE UNA REGION Y DEVUELVE EL ID DE LOCALIDAD
create or replace function fu_id_loc_por_region(p_region in location.regional_group%type)
return location.location_id%type
is
  v_id location.location_id%type;
begin
  select location_id into v_id
  from location
  where upper(regional_group) = upper(p_region);
  return v_id;
exception
  when no_data_found then
    raise_application_error(-20001, 'No existe la región: ' || p_region);
  when too_many_rows then
    raise_application_error(-20002, 'La región ' || p_region || ' tiene más de una localidad asociada.');
  when others then
    raise_application_error(-20003, 'Error inesperado: ' || sqlerrm);
end;
/

-- PROCEDIMIENTO PARA ELIMINAR DEPARTAMENTOS POR LOCALIDAD
create or replace procedure pr_eliminar_deptos_por_localidad(p_localidad in location.regional_group%type)
is
  v_loc_id location.location_id%type;
  v_exist number;
begin
  v_loc_id := fu_id_loc_por_region(p_localidad);

  select count(*) into v_exist
  from department
  where location_id = v_loc_id;

  if v_exist > 0 then
    delete from department
    where location_id = v_loc_id;
    commit;
    dbms_output.put_line('Departamentos eliminados para la localidad: ' || p_localidad);
  else
    dbms_output.put_line('No hay departamentos en la localidad: ' || p_localidad);
  end if;

exception
  when others then
    dbms_output.put_line('Error al eliminar departamentos: ' || sqlerrm);
end;
/

-- BLOQUE ANONIMO CON CURSORES PARA MOSTRAR ORDENES E ITEMS

declare
    v_fecha date := to_date('&fecha', 'dd/mm/yyyy');
    v_ordenes number;

    cursor c_ordenes is
        select so.order_id, so.order_date, so.total, c.name cliente
        from sales_order so
        join customer c on so.customer_id = c.customer_id
        where so.order_date = v_fecha
        order by c.name;

    cursor c_items(p_order_id sales_order.order_id%type) is
        select i.item_id, i.product_id, p.description, i.actual_price, i.quantity, i.total
        from item i
        join product p on i.product_id = p.product_id
        where i.order_id = p_order_id;
begin
    select count(*)
    into v_ordenes
    from sales_order
    where order_date = v_fecha;

    if v_ordenes = 0 then
        dbms_output.put_line('no hay órdenes para la fecha indicada.');
        return;
    end if;

    dbms_output.put_line('fecha: ' || to_char(v_fecha, 'dd/mm/yyyy'));

    for r_orden in c_ordenes loop
        dbms_output.put_line(
            r_orden.order_id || ' ' ||
            to_char(r_orden.order_date, 'dd/mm/yyyy') || ' $' || r_orden.total || ' ' || r_orden.cliente
        );

        for r_item in c_items(r_orden.order_id) loop
            dbms_output.put_line(
                'item ' || r_item.item_id || ' - ' || r_item.product_id || ' (' || r_item.description || ') $' ||
                r_item.actual_price || ' x ' || r_item.quantity || ' = $' || r_item.total
            );
        end loop;
    end loop;

exception
    when others then
        dbms_output.put_line('error: ' || sqlerrm);
end;
/
