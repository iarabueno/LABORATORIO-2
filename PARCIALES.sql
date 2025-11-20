-- MODELO 1
/*
1. Realice una consulta SQL que muestre el id de localidad, regional group, nombre de departamento y cantidad de empleados de aquellos departamentos que cuentan con menos de 3 empleados. Ordenados por
nombre de región y luego nombre de departamento.
*/

SELECT
    d.LOCATION_ID AS "ID Localidad",
    l.REGIONAL_GROUP AS "Grupo Regional",
    d.NAME AS "Nombre Departamento",
    COUNT(e.EMPLOYEE_ID) AS "Cantidad Empleados"
FROM
    DEPARTMENT d
LEFT JOIN
    EMPLOYEE e ON d.DEPARTMENT_ID = e.DEPARTMENT_ID
LEFT JOIN
    LOCATION l ON d.LOCATION_ID = l.LOCATION_ID
GROUP BY
    d.LOCATION_ID,
    l.REGIONAL_GROUP,
    d.NAME
HAVING
    COUNT(e.EMPLOYEE_ID) < 3
ORDER BY
    "Grupo Regional",
    "Nombre Departamento";

/*
2. Disminuir en un 5% el límite de crédito a todos los clientes cuyo monto acumulado entre todas sus ordenes no superan los 3000$ (resuelva con el bloque de codigo o la DML que considere mejor)
*/

UPDATE CUSTOMER c
SET c.CREDIT_LIMIT = c.CREDIT_LIMIT * 0.95 
WHERE c.CUSTOMER_ID IN (
    
    SELECT so.CUSTOMER_ID
    FROM SALES_ORDER so
    GROUP BY so.CUSTOMER_ID
    HAVING SUM(so.total) < 3000
)
OR c.CUSTOMER_ID NOT IN (

    SELECT DISTINCT CUSTOMER_ID
    FROM SALES_ORDER
);

/*
3. Escribir una función que recibe como parámetro un nombre de una función (funcion) y retorna su ID (job_id) o cancela con excepciones propias indicando el error en el mensaje del error. Contemplar todo error posible.
*/
create or replace function "FU_OBTENER_JOB_ID" (
   p_nombre_funcion IN JOB.function%TYPE )
RETURN JOB.job_id%TYPE
IS
    -- Variable para almacenar el ID encontrado
    v_job_id JOB.job_id%TYPE;
    
    -- Excepciones propias definidas
    e_funcion_no_encontrada EXCEPTION;
    e_nombre_funcion_duplicado EXCEPTION;
    e_parametro_nulo EXCEPTION;
    
BEGIN
    -- 1. Contemplar la función/trabajo nulo (NO_DATA_FOUND si la tabla estuviera vacía, o un error de lógica si se permite NULL)
    IF p_nombre_funcion IS NULL THEN
        RAISE e_parametro_nulo;
    END IF;
    
    -- 2. Buscar el JOB_ID
    -- Se utiliza UPPER() para asegurar que la búsqueda sea insensible a mayúsculas/minúsculas.
    SELECT job_id INTO v_job_id
    FROM JOB
    WHERE UPPER(function) = UPPER(p_nombre_funcion);
    
    -- 3. Retornar el ID si todo es correcto
    RETURN v_job_id;

EXCEPTION
    -- Manejo y cancelación con excepciones propias personalizadas (RAISE_APPLICATION_ERROR)
    
    -- Manejo de parámetro de entrada nulo
    WHEN e_parametro_nulo THEN
        RAISE_APPLICATION_ERROR(-20001, 'ERROR -20001: El nombre de la función no puede ser nulo. Debe proporcionar un valor.');
    
    -- Manejo de función no encontrada (NO_DATA_FOUND)
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'ERROR -20002: La función "' || p_nombre_funcion || '" no se encuentra registrada.');

    -- Manejo de múltiples funciones con el mismo nombre (TOO_MANY_ROWS)
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20003, 'ERROR -20003: Existe más de una función registrada con el nombre "' || p_nombre_funcion || '". El campo FUNCTION debe ser único.');

    -- Contempla cualquier otro error posible (ej. error de I/O, error de diccionario, error de acceso)
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20999, 'ERROR -20999: Error Desconocido al buscar el ID de la función: ' || SQLERRM);

END;
/

/*
4. Escribir un procedimiento que permite modificar la función de un empleado. El procedimiento recibe como parámetros id de empleado y descripción de la nueva función.
a. Manejar las excepciones correspondientes.
b. Informar si pudo realizar su propósito correctamente.
c. Utilizar la función del punto anterior.
d. Si no se pudo realizar, informar el motivo correcto. No cancelar.
*/

create or replace procedure "PR_MODIFICAR_FUNCION_EMPLEADO" (
p_id_empleado IN EMPLOYEE.EMPLOYEE_ID%TYPE,
    p_nueva_funcion_desc IN JOB.function%TYPE
)
IS
    -- Variable para guardar el nuevo JOB_ID obtenido de la función
    v_new_job_id JOB.job_id%TYPE;
    
    -- Variables para manejar las excepciones propias de la función
    e_job_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_job_error, -20000); -- Rango general para errores de aplicación
    
    -- Excepción para empleado no encontrado
    e_empleado_no_encontrado EXCEPTION;
BEGIN
    -- 1. Obtener el nuevo JOB_ID utilizando la función obtener_job_id
    BEGIN
        v_new_job_id := FU_OBTENER_JOB_ID(p_nueva_funcion_desc);
        
    EXCEPTION
        -- Captura cualquier excepción propia lanzada por la función (-20001, -20002, etc.)
        WHEN OTHERS THEN
            -- Re-lanza la excepción capturada como una excepción genérica.
            RAISE e_job_error; 
    END;
    
    -- 2. Modificar la función (job_id) del empleado
    
    UPDATE EMPLOYEE
    SET job_id = v_new_job_id
    WHERE employee_id = p_id_empleado;
    
    -- 3. Verificar si se actualizó algún empleado
    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_empleado_no_encontrado;
    ELSE
        COMMIT; -- Consolida el cambio si la actualización fue exitosa
        -- b. Informar si pudo realizar su propósito correctamente.
        DBMS_OUTPUT.PUT_LINE('Exito: La funcion del empleado ID ' || p_id_empleado || ' fue modificada a "' || p_nueva_funcion_desc || '" (JOB_ID: ' || v_new_job_id || ').');
    END IF;

EXCEPTION
    -- a. Manejar las excepciones correspondientes y d. Informar el motivo correcto (No cancelar)
    
    WHEN e_empleado_no_encontrado THEN
        ROLLBACK; 
        DBMS_OUTPUT.PUT_LINE('Error: El empleado con ID ' || p_id_empleado || ' no existe en la tabla EMPLOYEE.');
        
    WHEN e_job_error THEN
        ROLLBACK;
        -- SQLERRM aquí devuelve el mensaje de error personalizado (-2000X) lanzado por la función.
        DBMS_OUTPUT.PUT_LINE('Error en la Funcion: No se pudo obtener el nuevo JOB_ID.');
        DBMS_OUTPUT.PUT_LINE('Motivo: ' || SQLERRM);

    WHEN OTHERS THEN
        ROLLBACK; 
        DBMS_OUTPUT.PUT_LINE('Error Desconocido: No se pudo modificar la funcion del empleado.');
        DBMS_OUTPUT.PUT_LINE('Motivo: ' || SQLERRM);
END;
/

/*
4. Realizar un bloque anónimo que muestre todas las escalas salariales y los empleados que pertenecen.
a. En caso de que no haya empleados, mostrar el mensaje correspondiente.
b. Ordenar por grado de la escala. Los empleados por apellido.
c. Mostrar de la siguiente manera:
*/

DECLARE
    -- Cursor explícito para iterar sobre todas las escalas salariales, ordenadas por GRADE_ID.
    CURSOR c_grados IS
        SELECT 
            grade_id, 
            lower_bound, 
            upper_bound
        FROM 
            SALARY_GRADE
        ORDER BY 
            grade_id;
            
    v_cantidad_empleados NUMBER;

BEGIN
    FOR r_grado IN c_grados LOOP
        
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Grado ' || r_grado.grade_id || ' de $' || r_grado.lower_bound || ' a $' || r_grado.upper_bound);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        
        v_cantidad_empleados := 0; 
        
        DBMS_OUTPUT.PUT_LINE(RPAD('Nombre emp', 15) || RPAD('Apellido emp', 15) || RPAD('Salario emp', 15) || RPAD('Nombre jefe', 15) || 'Apellido jefe');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 15, '-') || ' ' || RPAD('-', 14, '-') || ' ' || RPAD('-', 14, '-') || ' ' || RPAD('-', 14, '-') || ' ' || RPAD('-', 14, '-'));

        -- Consulta anidada usando los nombres de columna con MAYÚSCULAS y comillas dobles
        FOR r_emp IN (
            SELECT
                e.first_name AS nombre_emp,
                e.last_name AS apellido_emp,
                e.salary AS salario_emp,
                m.first_name AS nombre_jefe,
                m.last_name AS apellido_jefe
            FROM
                EMPLOYEE e
            LEFT JOIN 
                EMPLOYEE m ON e.manager_id = m.employee_id 
            WHERE
                e.salary BETWEEN r_grado.lower_bound AND r_grado.upper_bound
            ORDER BY
                e.last_name 
        )
        LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(r_emp.nombre_emp, 15) || 
                RPAD(r_emp.apellido_emp, 15) || 
                RPAD(r_emp.salario_emp, 15) || 
                RPAD(NVL(r_emp.nombre_jefe, 'N/A'), 15) || 
                NVL(r_emp.apellido_jefe, 'N/A')
            );
            v_cantidad_empleados := v_cantidad_empleados + 1;
        END LOOP;
        
        IF v_cantidad_empleados = 0 THEN
            DBMS_OUTPUT.PUT_LINE('(No hay empleados registrados en esta escala salarial)');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Cantidad de empleados: ' || v_cantidad_empleados);
        DBMS_OUTPUT.PUT_LINE(' ');

    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('==================================================');
    DBMS_OUTPUT.PUT_LINE('Reporte de escalas salariales finalizado.');

END;
/


