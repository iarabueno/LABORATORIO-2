/*
1. Crear un bloque Pl/Sql que solicite el número de empleado usando una variable de sustitución y dependiendo del monto de su sueldo incrementar su comisión según el siguiente criterio:
Si el sueldo es menor a 1300 el incremento es de 10%
Si el sueldo está entre 1300 y 1500 el incremento es de 15%
Si el sueldo es mayor a 1500 el incremento es de 20%
Tener en cuenta que puede haber comisiones en NULL
Si el empleado no existe mandar un mensaje de error.

*/

declare

v_empleado_id employee.employee_id%type := 7369;--&ingrese_empleado_id;
v_salary employee.salary%type;
v_commission employee.commission%type;
v_nueva_commission employee.commission%type;

begin

select salary, 
       commission
into v_salary,
     v_commission
from employee
where employee_id = v_empleado_id;

if v_salary < 1300 then
    v_nueva_commission := nvl(v_commission, 0) + (v_commission * 0.10);

elsif v_salary between 1300 and 1500 then 
    v_nueva_commission := nvl(v_commission, 0) + (v_commission * 0.15);  

else
    v_nueva_commission := nvl(v_commission, 0) + (v_commission * 0.20);


end if;

update employee
set commission = v_nueva_commission
where employee_id = v_empleado_id;

dbms_output.put_line('se ha actualizado la comision de empleado ' || v_empleado_id || ' comision nueva: ' || v_nueva_commission);

exception
when no_data_found then
    dbms_output.put_line('no se encontró el empleado: ' || v_empleado_id);
when others then
    dbms_output.put_line('ocurrió un error inesperado ' || SQLERRM);
end;

/*
2. Modificar el ejercicio anterior para actualizar la comisión de todos los empleados de acuerdo a su sueldo usando los mismos criterios. Desplegar mensajes indicando cuantos registros fueron actualizados según cada criterio. 
*/

declare
    v_contador_registro_10 number := 0;
    v_contador_registro_15 number := 0;
    v_contador_registro_20 number := 0;
begin
    -- para sueldos < 1300
    update employee
    set commission = nvl(commission, 0) + nvl(commission, 0) * 0.10
    where salary < 1300;

    v_contador_registro_10 := sql%rowcount;

    -- para sueldos entre 1300 y 1500
    update employee
    set commission = nvl(commission, 0) + nvl(commission, 0) * 0.15
    where salary between 1300 and 1500;

    v_contador_registro_15 := sql%rowcount;

    -- para sueldos > 1500
    update employee
    set commission = nvl(commission, 0) + nvl(commission, 0) * 0.20
    where salary > 1500;

    v_contador_registro_20 := sql%rowcount;

    dbms_output.put_line('Empleados actualizados con 10% de incremento: ' || v_contador_registro_10);
    dbms_output.put_line('Empleados actualizados con 15% de incremento: ' || v_contador_registro_15);
    dbms_output.put_line('Empleados actualizados con 20% de incremento: ' || v_contador_registro_20);

exception
    when others then
        dbms_output.put_line('Ocurrió un error inesperado: ' || SQLERRM);
end;

/*
3. Crear un bloque Pl/Sql que permita dar de baja cargos que ya no se usan (usar la tabla JOB):
Eliminar de la tabla JOB aquella fila cuyo Job_Id es ingresado con una variable de sustitución del SqlDeveloper.
Capturar  e informar mediante excepciones o atributos del cursor , las siguientes eventualidades: no existe el código de cargo ingresado (Sql%Notfound  o Sql%Rowcount) no puede eliminar un cargo que está asignado a empleados (Asociar una excepción con el error correspondiente) .
*/

/*
fijarse la cantidad de empleados que tiene
select job_id,
       count(*) as cantidad_empleados
from employee 
group by job_id 
having count(*) > 0;
*/

declare

v_job_id job.job_id%type := 670; --'&ingrese_job_id';

e_fk exception;
pragma e_fk exception_init(e_fk, -2292);

begin

delete from job 
where job_id = v_job_id;

if sql%rowcount = 0 then
    dbms_output.put_line('no existe el cargo: ' || v_job_id);
else
    dbms_output.put_line('cargo eliminado correctamente');
end if;

exception 

when e_fk then
    raise_application_error(-20001, 'no se puede porque tiene empleados asignados');

/*
4. Escribir un bloque PL/Sql para insertar un nuevo cargo en la tabla JOB:
El Job_Id debe generarse sumando 1 al máximo Job_Id existente. Para esto primero encontrar el Max(Job_Id) y guardarlo en una variable.
El nombre del cargo (Function) debe ser informado desde una variable de sustitución del SqlDeveloper (usar Becario o Estudiante). En la tabla JOB los nombres de función deben estar en mayúsculas.   
Asentar en la base de datos este insert (Commit).
Una vez que se ejecutó el bloque Pl/Sql  consultar desde SqlDeveloper todo el contenido de la tabla JOB.
*/

declare
v_max_job_id job.job_id%type;
v_nuevo_job_id job.job_id%type;
v_function job.function%type := 'holi';--&ingrese_function;

begin

select max(job_id)
into v_max_job_id
from job;

v_nuevo_job_id := v_max_job_id + 1;

insert into job(job_id, function)
values(v_nuevo_job_id, upper(v_function));

dbms_output.put_line('nuevo cargo insertado: ' || v_function);

exception
when others then
dbms_output.put_line('error inesperado ' || SQLERRM);

end;

when others then 
    raise_application_error(-20002, 'ocurrio un error inesperado ' || SQLERRM);

 end;

/*
5. Escribir un bloque PL/SQL que actualice el precio de lista de un producto de acuerdo al número de veces que el producto se vendió:
Use una variable de sustitución para ingresar el producto.
Calcule las veces que el producto se vendió (Tabla ITEM). Si el producto se vendió 2 veces o menos decremente su precio en un 10%. Si se vendió más de 2 veces decremente su precio en un 20% y no se vendió nunca en un 50%.
Tenga en cuenta que el precio de lista vigente de un producto es aquel que tiene la columna END_DATE en null.
*/

select *
from product;


declare

v_producto_id product.product_id%type := 100860;--&ingrese_product_id;
v_cantidad_item number := 0;
v_precio_actual price.list_price%type;
v_nuevo_precio price.list_price%type;

begin

select count(*)
into v_cantidad_item
from item
where product_id = v_producto_id;

select list_price
into v_precio_actual
from price 
where product_id = v_producto_id and 
      end_date is null;

if v_cantidad_item = 0 then
    v_nuevo_precio := v_precio_actual * 0.5;


elsif v_cantidad_item <= 2 then
    v_nuevo_precio := v_precio_actual * 0.9;

else 
    v_nuevo_precio := v_precio_actual * 0.8;
end if;

update price 
set list_price = v_nuevo_precio
where product_id = v_producto_id and 
      end_date is null;
     
dbms_output.put_line('nuevo cargo insertado: ' || v_producto_id || ' veces vendido: ' || v_cantidad_item);
dbms_output.put_line('precio: ' || v_precio_actual || ' precio actualizado ' || v_nuevo_precio);

exception

when no_data_found then 
    dbms_output.put_line('no existe el producto');

when others then
    dbms_output.put_line('error inesperado ' || SQLERRM);
end;

/*
6. Modificar el ejercicio 5 de la práctica 2 para mostrar un mensaje en caso de no existir la orden.
*/

declare 

v_id_departamento department.department_id%type := 10; -- &id_de_departamento;
v_name_departamento department.name%type;
v_contador_empleado number;

begin 

-- para sacar el nombre
select department_id, name
into v_id_departamento, v_name_departamento
from department
where department_id = v_id_departamento;

-- para el contador
select count(*)
into v_contador_empleado
from employee
where department_id = v_id_departamento;

-- mostrar
dbms_output.put_line('departamento id: ' || v_id_departamento);
dbms_output.put_line('nombre: ' || v_name_departamento);
dbms_output.put_line('cantidad de empleados: ' || v_contador_empleado);

exception

when NO_DATA_FOUND then
dbms_output.put_line('no se encontró empleado');
when OTHERS then
dbms_output.put_line('error inesperado ' || SQLERRM);
end;

/*
7. Modificar el ejercicio 8 de la práctica 2 para ingresar el apellido del empleado y mostrar su id, nombre, salario y asteriscos de acuerdo al salario.
Mostrar mensajes si no existe empleado con dicho apellido, o si hay más de un empleado con ese apellido.

ejercicio 5:
Escribir un bloque para mostrar la cantidad de órdenes que emitió un cliente dado siguiendo las siguientes consignas:
Ingresar el id del cliente una variable de sustitución
Si el cliente emitió menos de 3 órdenes desplegar:
	“El cliente nombre  ES REGULAR”.
Si emitió entre 4 y 6
	“El cliente  nombre ES BUENO”.
Si emitió más:
	“El cliente nombre ES MUY BUENO”.
*/

declare
    v_apellido employee.last_name%type := 'smith'; --&ingrese_apellido;
    v_id       employee.employee_id%type;
    v_nombre   employee.first_name%type;
    v_salario  employee.salary%type;
    v_cantidad number;
    v_contador number;
begin
    select count(*)
    into v_cantidad
    from employee
    where upper(last_name) = upper(v_apellido);

    if v_cantidad = 0 then
        dbms_output.put_line('no existe ningún empleado con el apellido: ' || v_apellido);
    elsif v_cantidad > 1 then
        dbms_output.put_line('hay más de un empleado con el apellido: ' || v_apellido);
    else
        select employee_id, first_name, salary
        into v_id, v_nombre, v_salario
        from employee
        where upper(last_name) = upper(v_apellido);

        dbms_output.put_line('empleado id: ' || v_id);
        dbms_output.put_line('nombre: ' || v_nombre);
        dbms_output.put_line('salario: ' || v_salario);

        dbms_output.put_line('asteriscos: ');
        v_contador := 1;
        while v_contador <= round(v_salario / 1000) loop
            dbms_output.put('*');
            v_contador := v_contador + 1;
        end loop;
        dbms_output.new_line;
    end if;

exception
    when others then
        dbms_output.put_line('ocurrió un error inesperado: ' || sqlerrm);
end;
