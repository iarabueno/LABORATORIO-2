/*
1. Crear un bloque anónimo para desplegar los siguientes mensajes:
‘Hola , soy ‘ username 
‘Hoy es: ‘  dd – Mon – yyyy’.  (mostrar la fecha del día)
*/

declare
    v_username varchar2(100);
    v_fecha    varchar2(30);
begin

    v_username := USER;

    v_fecha := TO_CHAR(SYSDATE, 'DD - Mon - YYYY');

    dbms_output.put_line('Hola, soy ' || v_username);
     dbms_output.put_line'Hoy es: ' || v_fecha);
END;
*/
