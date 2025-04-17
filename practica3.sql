/*
Crear un bloque Pl/Sql que solicite el número de empleado usando una variable de sustitución y dependiendo del monto de su sueldo incrementar su comisión según el siguiente criterio:
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

when others then 
    raise_application_error(-20002, 'ocurrio un error inesperado ' || SQLERRM);

 end;
