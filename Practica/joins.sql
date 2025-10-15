-- Práctica Nº 2: JOINS
-- Practica en Clase: 1 – 2 – 6 – 7 – 10 – 11 – 12 – 14 – 15 – 16
-- Práctica Complementaria: 3 – 4 – 5 – 8 – 9 – 13
-- BASE DE DATOS: AGENCIA_PERSONAL

-- 1) Mostrar del Contrato 5: DNI, Apellido y Nombre de la persona contratada y el
-- sueldo acordado en el contrato
-- |nombre |apellido |sueldo |dni|

USE agencia_personal;
SELECT PER.dni, PER.apellido, PER.nombre, CON.sueldo
	FROM contratos CON INNER JOIN personas PER ON CON.dni=PER.dni
    WHERE CON.nro_contrato=5;
    
-- 2) ¿Quiénes fueron contratados por la empresa Viejos Amigos o Tráigame Eso?
-- Mostrar el DNI, número de contrato, fecha de incorporación, fecha de solicitud en la
-- agencia de los contratados y fecha de caducidad (si no tiene fecha de caducidad colocar
-- ‘Sin Fecha’). Ordenado por fecha de contrato y nombre de empresa
-- | Dni |nro_contrato|fecha_incorporacion|fecha_solicitud|fecha_caducidad|

SELECT PER.dni, CON.nro_contrato, CON.fecha_incorporacion, SE.fecha_solicitud, IFNULL(CON.fecha_caducidad, "Sin Fecha") "fecha_caducidad"
	FROM personas PER 
		INNER JOIN contratos CON ON PER.dni = CON.dni
		INNER JOIN solicitudes_empresas SE ON CON.cuit = SE.cuit
		INNER JOIN empresas EMP ON SE.cuit = EMP.cuit
        WHERE EMP.razon_social IN ("Viejos Amigos", "Tráigame Eso")
        ORDER BY CON.fecha_incorporacion, EMP.razon_social;

-- 6) Empleados que no tengan referencias o hayan puesto de referencia a Armando
-- Esteban Quito o Felipe Rojas. Mostrarlos de la siguiente forma:
-- Pérez, Juan tiene como referencia a Felipe Rojas cuando trabajo en Constructora Gaia
-- S.A

SELECT concat(PER.apellido, ", ", PER.nombre, " tiene como referencia a ", IFNULL(ANT.persona_contacto, "nadie"), " y cuando trabajo en ", EMP.razon_social) "Descripcion" FROM personas PER 
	INNER JOIN antecedentes ANT ON PER.dni = ANT.dni
    INNER JOIN empresas EMP ON ANT.cuit = EMP.cuit
    WHERE ANT.persona_contacto IN ("Armando Esteban Quito", "Felipe Rojas")
		OR ANT.persona_contacto IS NULL
		OR ANT.persona_contacto = "";

-- 7) Seleccionar para la empresa Viejos amigos, fechas de solicitudes, descripción del
-- cargo solicitado y edad máxima y mínima . Encabezado:
-- |Empresa  | Fecha  Solicitud dd-mm-YYYY    |Cargo |Edad Mín / Sin especificar    |Edad Máx / Sin especificar    |

        SELECT EMP.razon_social, date_format(SE.fecha_solicitud, "%d/%m/%Y") "Fecha Solicitud", CAR.desc_cargo, IFNULL(SE.edad_minima, "Sin especificar") "Edad Min",  IFNULL(SE.edad_maxima, "Sin especificar") "Edad Max"
			FROM empresas EMP
				INNER JOIN solicitudes_empresas SE
                INNER JOIN cargos CAR
				WHERE EMP.razon_social = "Tráigame Eso";
        
-- 8) Mostrar los antecedentes de cada postulante:
-- Postulante (nombre y apellido) Cargo (descripción del cargo)

SELECT CONCAT(PER.nombre, " ", PER.apellido) "Postulante", CAR.desc_cargo "Cargo"
	FROM personas PER 
    INNER JOIN antecedentes ANT ON PER.dni = ANT.dni
    INNER JOIN cargos CAR ON ANT.cod_cargo = CAR.cod_cargo;

-- 9) Mostrar todas las evaluaciones realizadas para cada solicitud ordenar en forma
-- ascendente por empresa y descendente por cargo:

SELECT EMP.razon_social "Empresa", CAR.desc_cargo "Cargo", EVA.desc_evaluacion, EE.resultado
	FROM evaluaciones EVA
	INNER JOIN entrevistas_evaluaciones EE ON EVA.cod_evaluacion = EE.cod_evaluacion
    INNER JOIN entrevistas ENT ON EE.nro_entrevista = ENT.nro_entrevista
    INNER JOIN solicitudes_empresas SE ON ENT.cuit = SE.cuit
    INNER JOIN empresas EMP ON SE.cuit = EMP.cuit
    INNER JOIN cargos CAR ON SE.cod_cargo = CAR.cod_cargo
    ORDER BY EMP.razon_social ASC, CAR.cod_cargo DESC;

-- 10) Listar las empresas solicitantes mostrando la razón social y fecha de cada solicitud,
-- y descripción del cargo solicitado. Si hay empresas que no hayan solicitado que salga la
-- leyenda: Sin Solicitudes en la fecha y en la descripción del cargo.
-- |cuit |razon_social |Fecha Solicitud |Cargo

SELECT EMP.cuit, EMP.razon_social, IFNULL(SE.fecha_solicitud, "Sin Solicitudes") "Fecha Solicitud", IFNULL(CAR.desc_cargo, "Sin Solicitudes") "Cargo"
	FROM empresas EMP
	LEFT JOIN solicitudes_empresas SE ON EMP.cuit=SE.cuit
    LEFT JOIN cargos CAR ON SE.cod_cargo = CAR.cod_cargo;

-- misma consulta resuelta con right
    
SELECT EMP.cuit, EMP.razon_social, IFNULL(SE.fecha_solicitud, "Sin Solicitudes") "Fecha Solicitud", IFNULL(CAR.desc_cargo, "Sin Solicitudes") "Cargo"
	FROM cargos CAR
    RIGHT JOIN solicitudes_empresas SE ON SE.cod_cargo = CAR.cod_cargo
    RIGHT JOIN empresas EMP ON EMP.cuit=SE.cuit;
    
-- usando right join nos quedamos con todos los cargos y los registros coincidentes de las solicitudes

SELECT EMP.cuit, EMP.razon_social, IFNULL(SE.fecha_solicitud, "Sin Solicitudes") "Fecha Solicitud", IFNULL(CAR.desc_cargo, "Sin Solicitudes") "Cargo"
	FROM empresas EMP
	RIGHT JOIN solicitudes_empresas SE ON EMP.cuit=SE.cuit
    RIGHT JOIN cargos CAR ON SE.cod_cargo = CAR.cod_cargo;
    
-- Empresas que solicitaron cargos y los cargos que no fueron solicitados

SELECT EMP.cuit, EMP.razon_social, IFNULL(SE.fecha_solicitud, "Sin Solicitudes") "Fecha Solicitud", IFNULL(CAR.desc_cargo, "Sin Solicitudes") "Cargo"
	FROM empresas EMP
	LEFT JOIN solicitudes_empresas SE ON EMP.cuit=SE.cuit
    RIGHT JOIN cargos CAR ON SE.cod_cargo = CAR.cod_cargo;

-- 11) Mostrar para todas las solicitudes la razón social de la empresa solicitante, el cargo
-- y si se hubiese realizado un contrato los datos de la(s) persona(s).
-- cuit razon_social desc_cargo DNI Apellido Nombre

		 
-- 12) Mostrar para todas las solicitudes la razón social de la empresa solicitante, el cargo de
-- las solicitudes para las cuales no se haya realizado un contrato.
-- |cuit |razon_social |desc_cargo


-- 13) Listar todos los cargos y para aquellos que hayan sido mencionados como
-- antecedente por alguna persona indicar nombre y apellido de la persona y empresa donde
-- lo ocupó.
-- desc_cargo DNI Apellido razon_social

        



use `afatse`;
-- BASE DE DATOS: AFATSE
-- 14) Indicar todos los instructores que tengan un supervisor.
-- Cuil Instructor | Nombre Instructor | Apellido Instructor | Cuil Supervisor | Nombre Supervisor | Apellido Supervisor

-- ejemplo de self join, unir una tabla consigo misma usando diferentes alias


--  15 16

-- 15) Ídem 14) pero para todos los instructores. Si no tiene supervisor mostrar esos
-- campos en blanco


-- 16) Ranking de Notas por Supervisor e Instructor. El ranking deberá indicar para cada
-- supervisor los instructores a su cargo y las notas de los exámenes que el instructor haya
-- corregido en el 2014. Indicando los datos del supervisor , nombre y apellido del instructor,
-- plan de capacitación, curso, nombre y apellido del alumno, examen, fecha de evaluación y
-- nota. En caso de que no tenga supervisor a cargo indicar espacios en blanco. Ordenado
-- ascendente por nombre y apellido de supervisor y descendente por fecha.
