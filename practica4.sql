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
