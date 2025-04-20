/*
Escribir un procedimiento Alta_Job para insertar un nuevo cargo en la tabla JOB: (ver ej 4, Unidad 3)
el Job_Id debe generarse sumando 1 al máximo Job_Id existente
el nombre del cargo (Function) debe ser informado por parámetro. Recordar que en la base de datos todos los nombres de función están en mayúsculas
asentar en la base de datos este insert (Commit).
*/

-- PROCEDIMIENTO
create or replace procedure "PR_ALTA_JOB"
(PI_FUNCTION IN JOB.JOB_ID%TYPE)

as
v_nuevo_job_id job.job_id%type;
v_max_job_id job.job_id%type;

begin
    
    -- seleccionar el máximo cargo
    select nvl(max(job_id), 0) 
    into v_max_job_id 
    from job;


    -- nuevo job

    v_nuevo_job_id := v_max_job_id + 1;

    -- insertar cargo
    insert into job(job_id, function)
    values(v_nuevo_job_id, upper(PI_FUNCTION));

    -- guardar
    commit;

    -- mostrar xd
    dbms_output.put_line('cargo ingresado: ' || upper(PI_FUNCTION) || 'job_id: ' || v_nuevo_job_id);

    exception 
    when others then 
    dbms_output.put_line('ha ocurrido un error inesperado: ' || SQLERRM);


end "PR_ALTA_JOB";
/

/*
2. Crear un procedimiento Upd_Job para actualizar los nombres de los cargos:
Informar el job_id y el nuevo nombre de función mediante dos parámetros. 
Si el job_id no existe, informar mediante un mensaje y cancelar el procedimiento.
*/
create or replace procedure pr_upd_job (
    pi_job_id    in job.job_id%type,
    pi_function  in job.function%type
)
as
    v_existe_id_job    number := 0;
    v_existe_function  number := 0;
begin
    -- verificar si existe el job_id
    select count(*)
    into v_existe_id_job
    from job
    where job_id = pi_job_id;

    -- verificar si ya existe otro cargo con esa función
    select count(*)
    into v_existe_function
    from job
    where upper(function) = upper(pi_function)
      and upper(job_id) != upper(pi_job_id);

    if v_existe_id_job = 0 then
        dbms_output.put_line('no existe un cargo con ese job_id');
    elsif v_existe_function > 0 then
        dbms_output.put_line('ya existe un cargo con esa función');
    else
        update job
        set function = upper(pi_function)
        where job_id = pi_job_id;

        commit;
        dbms_output.put_line('cargo actualizado');
    end if;

exception
    when others then
        dbms_output.put_line('ocurrió un error inesperado: ' || sqlerrm);
end pr_upd_job;
/

/*
3. Crear un procedimiento Lista_Emp que recibe mediante un parámetro el código de un departamento e informe el nombre y apellido de todos los empleados que trabajan en él. 
Contemplar todos los errores posibles: el código no corresponde a un departamento, no hay empleados en el departamento o cualquier error y desplegar mensajes. 
*/
create or replace procedure "PR_LISTA_EMP" (

    PI_DEPARTAMENT_ID department.department_id%type
)

as
v_existe_department_id number := 0;
v_cantidad_empleados number := 0;

-- cursor para recorrer las filas de empleado
cursor c_empleado is 
    select first_name,
           last_name
    from employee
    where department_id = PI_DEPARTAMENT_ID;


begin
 -- verificar si existe department_id
select count(*)
into v_existe_department_id
from department
where department_id = PI_DEPARTAMENT_ID;

if v_existe_department_id = 0 then
    raise_application_error('-20001', 'el codigo departamento id no existe');
end if;

-- verificar si hay empleados
select count(*)
into v_cantidad_empleados
from employee
where department_id = PI_DEPARTAMENT_ID;

if v_cantidad_empleados = 0 then
    raise_application_error('-20002', 'el departamento no tiene empleados');
end if;

dbms_output.put_line('empleados del departamento id : ' || PI_DEPARTAMENT_ID || ': ');

for emp in c_empleado loop
    dbms_output.put_line('nombre del empleado: ' || emp.first_name || ' ' || 'apellido del empleado: ' || emp.last_name);
end loop;

exception
when others then
    dbms_output.put_line('ocurrio un error inesperado ' || SQLERRM);

end "PR_LISTA_EMP";
/

/*
4. Crear un procedimiento Consulta_Precio que recibe un código de producto y devuelve el precio de lista (List_price) y el precio_mínimo (Min_price).
Si el producto no existe, atrapar la excepción correspondiente y emitir un mensaje de error.
Para probar el procedimiento usar el RUN de SqlDeveloper o invocarlo desde un bloque anónimo y desplegar los valores obtenidos en las variables usadas como parámetros de out.
*/

create or replace procedure "PR_CONSULTA_PRECIO" (
    PI_PRODUCT_ID in product.product_id%type,
    PI_MIN_PRICE out price.min_price%type,
    PI_LIST_PRICE out price.list_price%type

)
as
begin

select min_price, list_price
into PI_MIN_PRICE, PI_LIST_PRICE
from price
where product_id = PI_PRODUCT_ID and 
      end_date is null;

exception

when no_data_found then
    dbms_output.put_line('no existe el producto o no tiene precio vigente');

when others then
    dbms_output.put_line('ocurrio un error inesperado');

    -- enter the procedure code here
end "PR_CONSULTA_PRECIO";
/

/*

Crear una función Valida_Loc que recibe un código de localidad y devuelve TRUE si el código existe en la tabla Location, en caso contrario devuelve FALSE.
*/
create or replace function "FU_VALIDA_LOC" (
    PI_LOCATION_ID in location.location_id%type)
return BOOLEAN
as

v_contador number;

begin

select count(*)
into v_contador
from location
where location_id = PI_LOCATION_ID;
    return v_contador > 0;

exception

when others then 
    return false;

end "FU_VALIDA_LOC";
/


/*
7. Crear un procedimiento New_Dept para insertar una fila en la tabla Department. Este procedimiento recibe como parámetros el id, (Department_id), el nombre (Name) y la localidad (Location_id). Para insertar el departamento se debe validar que el código de localidad sea válido usando la función Valida_Loc. Si la localidad es inválida cancelar el procedimiento con un mensaje se error.
*/
create or replace procedure "PR_NEW_DEPT" (
    PI_DEPARTMENT_ID in department.department_id%type,
    PI_NAME in department.name%type,
    PI_LOCATION in department.location_id%type
    
)
as

begin

if not fu_valida_loc(PI_DEPARTMENT_ID) then 
    raise_application_error('-20001', 'no existe la location id');
end if;

insert into department(department_id, name, location_id)
values (PI_DEPARTMENT_ID, upper(PI_NAME), PI_LOCATION);

dbms_output.put_line('valores insertados correctamente');

exception 
when dup_val_on_index then
    dbms_output.put_line('los valores insertados ya existen');

when others then
    dbms_output.put_line('ocurrio un error inesperado ' || SQLERRM);
end "PR_NEW_DEPT";
/

