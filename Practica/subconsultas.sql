-- Practica Nº 5: Subconsultas, Tablas Temporales y Variables
-- Practica en Clase: 1 – 2 – 3 – 4 – 7 – 9 – 10 – 11 – 12 – 16
-- Práctica Complementaria: 5 – 6 – 8 – 13 – 14 – 15 – 17
-- BASE DE DATOS: AGENCIA_PERSONAL


-- 1 )¿Qué personas fueron contratadas por las mismas empresas que Stefanía Lopez?
-- |dni |apellido |nombre|
SELECT PER.dni, PER.apellido, PER.nombre 
	FROM `agencia_personal`.`personas` PER 
		INNER JOIN `agencia_personal`.`contratos` CON ON PER.dni=CON.dni 
	WHERE CON.cuit IN (
		SELECT CON.cuit 
			FROM `agencia_personal`.`personas` PER 
				INNER JOIN `agencia_personal`.`contratos` CON ON PER.dni=CON.dni
			WHERE CONCAT(nombre, " ", apellido) LIKE "Stefan_a Lopez"); 



-- 2) Encontrar a aquellos empleados que ganan menos que el máximo sueldo de los empleados
-- de Viejos Amigos.
-- |dni |nombre y apellidos |sueldo
SELECT PER.dni, CONCAT(nombre, " ", apellido) "nombre y apellidos", sueldo
	FROM `agencia_personal`.`contratos` CON 
		INNER JOIN `agencia_personal`.`personas` PER ON CON.dni=PER.dni
	WHERE sueldo < (
		SELECT MAX(sueldo) 
			FROM `agencia_personal`.`contratos` CON 
				INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit=EMP.cuit
			WHERE EMP.razon_social = "Viejos Amigos");
SET @MAX_SUELDO = (
		SELECT MAX(sueldo) 
			FROM `agencia_personal`.`contratos` CON 
				INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit=EMP.cuit
			WHERE EMP.razon_social = "Viejos Amigos");


SELECT PER.dni, CONCAT(nombre, " ", apellido) "nombre y apellidos", sueldo
	FROM `agencia_personal`.`contratos` CON 
		INNER JOIN `agencia_personal`.`personas` PER ON CON.dni=PER.dni
	WHERE sueldo < @MAX_SUELDO;



-- 3) Mostrar empresas contratantes y sus promedios de comisiones pagadas o a pagar, pero sólo
-- de aquellas cuyo promedio supere al promedio de Tráigame eso.
SELECT EMP.cuit, EMP.razon_social, ROUND(AVG(importe_comision), 2)
	FROM `agencia_personal`.`comisiones` COM
		INNER JOIN `agencia_personal`.`contratos` CON ON COM.nro_contrato=CON.nro_contrato
		INNER JOIN  `agencia_personal`.`empresas` EMP ON CON.cuit=EMP.cuit
	GROUP BY EMP.cuit
    HAVING AVG(importe_comision) > (
		SELECT AVG(importe_comision)
		FROM `agencia_personal`.`comisiones` COM
		INNER JOIN `agencia_personal`.`contratos` CON ON COM.nro_contrato=CON.nro_contrato
		INNER JOIN  `agencia_personal`.`empresas` EMP ON CON.cuit=EMP.cuit
		WHERE EMP.razon_social = "Tráigame eso"
    );



-- 4) Seleccionar las comisiones pagadas que tengan un importe menor al promedio de todas las
-- comisiones(pagas y no pagas), mostrando razón social de la empresa contratante, mes
-- contrato, año contrato , nro. contrato, nombre y apellido del empleado.
SET @prom_comision=(SELECT AVG(importe_comision) FROM `agencia_personal`.`comisiones`);

SELECT EMP.razon_social, COM.mes_contrato, COM.anio_contrato, CON.nro_contrato, CONCAT(PER.nombre, " ", PER.apellido)
	FROM `agencia_personal`.`comisiones` COM
		INNER JOIN `agencia_personal`.`contratos` CON ON COM.nro_contrato = CON.nro_contrato
		INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit = EMP.cuit
        INNER JOIN `agencia_personal`.`personas` PER ON CON.dni = PER.dni
	WHERE fecha_pago IS NOT NULL AND importe_comision < @prom_comision;
        
        

-- 5) Determinar las empresas que pagaron más que el promedio
SELECT AVG(sueldo) FROM `agencia_personal`.`contratos`;


-- 6) Seleccionar los empleados que no tengan educación no formal o terciario.
-- |apellido |nombre   |
SELECT DISTINCT PER.apellido, PER.nombre 
	FROM  `agencia_personal`.`personas` PER
		INNER JOIN `agencia_personal`.`personas_titulos` PT ON PER.dni = PT.dni
        INNER JOIN `agencia_personal`.`titulos` TIT ON PT.cod_titulo = TIT.cod_titulo
	WHERE tipo_titulo NOT IN ("Educacion no formal", "Terciario");

-- 7) Mostrar los empleados cuyo salario supere al promedio de sueldo de la empresa que los
-- contrató.
-- |cuit |dni |sueldo |prom



-- 8) Determinar las empresas que pagaron en promedio la mayor o menor de las comisiones
-- |razon_social | promedio

SELECT EMP.razon_social, ROUND(AVG(importe_comision), 2) "promedio"
	FROM `agencia_personal`.`comisiones` COM
		INNER JOIN `agencia_personal`.`contratos` CON ON COM.nro_contrato = CON.nro_contrato
        INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit = EMP.cuit
	GROUP BY EMP.cuit
    HAVING 
		AVG(importe_comision) = (SELECT MAX(importe_comision) FROM `agencia_personal`.`comisiones` COM) OR 
        AVG(importe_comision) = (SELECT MIN(importe_comision) FROM `agencia_personal`.`comisiones` COM);
        
        
        
-- 9) Alumnos que se hayan inscripto a más cursos que Antoine de Saint-Exupery. Mostrar
-- todos los datos de los alumnos, la cantidad de cursos a la que se inscribió y cuantas
-- veces más que Antoine de Saint-Exupery.
-- |dni |nombre|apellido |direccion |email |te |count(*) count(*)- @cant)

SET @cant = (SELECT COUNT(*) 
	FROM `afatse`.`alumnos` ALU
		INNER JOIN `afatse`.`inscripciones` INS ON ALU.dni = INS.dni
	WHERE CONCAT(ALU.nombre, " ", ALU.apellido) = "Antoine de Saint-Exupery");

SELECT ALU.dni, ALU.nombre, ALU.apellido, ALU.direccion, ALU.email, ALU.tel, (COUNT(*) - @cant) "diferencia"
	FROM `afatse`.`alumnos` ALU
		INNER JOIN `afatse`.`inscripciones` INS ON ALU.dni = INS.dni
	GROUP BY ALU.dni
    HAVING COUNT(*) > @cant;



-- 10) En el año 2014, qué cantidad de alumnos se han inscripto a los Planes de Capacitación
-- indicando para cada Plan de Capacitación la cantidad de alumnos inscriptos y el
-- porcentaje que representa respecto del total de inscriptos a los Planes de Capacitación
-- dictados en el año.

SET @cant_total = (
	SELECT COUNT(*)
		FROM `afatse`.`inscripciones` INS
			INNER JOIN `afatse`.`plan_capacitacion` PC ON INS.nom_plan = PC.nom_plan
	WHERE YEAR(INS.fecha_inscripcion) = 2014
);

SELECT PC.nom_plan "plan", COUNT(*) "cantidad", ROUND(((COUNT(*)/@cant_total)*100), 2) "porcentaje"
	FROM `afatse`.`inscripciones` INS
		INNER JOIN `afatse`.`plan_capacitacion` PC ON INS.nom_plan = PC.nom_plan
	WHERE YEAR(INS.fecha_inscripcion) = 2014
    GROUP BY PC.nom_plan;



-- 11) Indicar el valor actual de los planes de Capacitación
-- nom_plan fecha_desde_plan valor_plan

DROP TEMPORARY TABLE IF EXISTS `afatse`.`tt_ultimas_fechas`;

CREATE TEMPORARY TABLE `afatse`.`tt_ultimas_fechas` (
	SELECT VP.nom_plan, MAX(VP.fecha_desde_plan) "fecha_desde_plan"
		FROM `afatse`.`valores_plan` VP
		GROUP BY VP.nom_plan
);

SELECT TTUF.nom_plan, VP.fecha_desde_plan, VP.valor_plan
	FROM `afatse`.`tt_ultimas_fechas` TTUF 
		INNER JOIN `afatse`.`valores_plan` VP ON TTUF.nom_plan = VP.nom_plan
	WHERE TTUF.fecha_desde_plan = VP.fecha_desde_plan;

DROP TEMPORARY TABLE `afatse`.`tt_ultimas_fechas`;

-- 12) Plan de capacitacion mas barato. Indicar los datos del plan de capacitacion y el valor actual
-- nom_plan desc_plan hs modalidad valor_plan

SET @mas_barato = (SELECT MIN(VP.valor_plan) FROM  `afatse`.`valores_plan` VP);

SELECT VP.nom_plan, PC.desc_plan, PC.hs, PC.modalidad, VP.valor_plan
	FROM `afatse`.`valores_plan` VP
		INNER JOIN `afatse`.`plan_capacitacion` PC ON VP.nom_plan = PC.nom_plan
    WHERE VP.valor_plan = @mas_barato; 
    
-- 13) ¿Qué instructores que han dictado algún curso del Plan de Capacitación “Marketing 1” el
-- año 2014 y no vayan a dictarlo este año? (año 2015)

SELECT CI.cuil
		FROM `afatse`.`cursos_instructores` CI
        INNER JOIN `afatse`.`cursos` CUR ON CI.nom_plan = CUR.nom_plan AND CI.nro_curso = CUR.nro_curso
	WHERE CI.nom_plan = "Marketing 1" AND YEAR(CUR.fecha_ini) = '2014'
    GROUP BY CI.cuil
    HAVING CI.cuil NOT IN (
		SELECT CI.cuil
			FROM `afatse`.`cursos_instructores` CI
			INNER JOIN `afatse`.`cursos` CUR ON CI.nom_plan = CUR.nom_plan AND CI.nro_curso = CUR.nro_curso
		WHERE CI.nom_plan = "Marketing 1" AND YEAR(CUR.fecha_ini) = '2015'
		GROUP BY CI.cuil
    );
    
    

-- 14) Alumnos que tengan todas sus cuotas pagas hasta la fecha.
-- dni nombre apellido tel email direccion

SELECT ALU.*
	FROM `afatse`.`cuotas` CUO
			INNER JOIN `afatse`.`alumnos` ALU ON CUO.dni = ALU.dni
            WHERE fecha_pago <= CURDATE()
            GROUP BY ALU.dni
            HAVING ALU.dni NOT IN (
				SELECT ALU.dni
					FROM `afatse`.`cuotas` CUO
						INNER JOIN `afatse`.`alumnos` ALU ON CUO.dni = ALU.dni
					GROUP BY ALU.dni
					HAVING SUM(fecha_pago IS NULL) >= 1
            )
            ORDER BY ALU.dni ASC;



-- 15) Alumnos cuyo promedio supere al del curso que realizan. Mostrar dni, nombre y apellido,
-- promedio y promedio del curso.
-- dni nombre apellido avg( nota ) prome

DROP TEMPORARY TABLE IF EXISTS `afatse`.`tt_prom_cursos`;

CREATE TEMPORARY TABLE `afatse`.`tt_prom_cursos` (
	SELECT CUR.nom_plan, CUR.nro_curso, AVG(EVA.nota) "prome"
		FROM `afatse`.`cursos` CUR
			INNER JOIN `afatse`.`evaluaciones` EVA ON CUR.nro_curso = EVA.nro_curso AND CUR.nom_plan = EVA.nom_plan
            GROUP BY CUR.nom_plan, CUR.nro_curso
);

SELECT ALU.dni, ALU.nombre, ALU.apellido, AVG(EVA.nota), TTPC.prome
	FROM `afatse`.`alumnos` ALU
		INNER JOIN `afatse`.`inscripciones` INS ON ALU.dni = INS.dni
		INNER JOIN `afatse`.`evaluaciones` EVA ON INS.nro_curso = EVA.nro_curso AND INS.nom_plan = EVA.nom_plan AND INS.dni = EVA.dni
        INNER JOIN `afatse`.`tt_prom_cursos` TTPC ON INS.nro_curso = TTPC.nro_curso AND INS.nom_plan = TTPC.nom_plan
        GROUP BY INS.nom_plan, INS.nro_curso, INS.dni, TTPC.prome
        HAVING AVG(EVA.nota) > TTPC.prome
        ORDER BY ALU.dni ASC;
        
DROP TEMPORARY TABLE `afatse`.`tt_prom_cursos`;



-- 16)Para conocer la disponibilidad de lugar en los cursos que empiezan en abril, para
-- lanzar una campaña se desea conocer la cantidad de alumnos inscriptos a los cursos
-- que comienzan a partir del 1/04/2014 indicando: Plan de Capacitación, curso, fecha de
-- inicio, salón, cantidad de alumnos inscriptos y diferencia con el cupo de alumnos
-- registrado para el curso que tengan al más del 80% de lugares disponibles respecto del
-- cupo.
-- Ayuda: tener en cuenta el uso de los paréntesis y la precedencia de los operadores
-- matemáticos.
-- nro_curso fecha_ini salon cupo count( dni ) ( cupo - count( dni ) )

-- cantidad de disponibilidad de lughar en cada curso que empieza en abril
-- cantidad de alumnos inscriptos a los cursos que comienzan del 1-4-24

SELECT CUR.nro_curso, CUR.fecha_ini, CUR.salon, CUR.cupo, COUNT(INS.dni) "ocupados", (CUR.cupo - COUNT(INS.dni)) "cupos_disponibles"
	FROM `afatse`.`inscripciones` INS
        RIGHT JOIN `afatse`.`cursos` CUR ON INS.nom_plan = CUR.nom_plan AND INS.nro_curso = CUR.nro_curso
        WHERE CUR.fecha_ini >= '2014-04-01'
        GROUP BY CUR.nom_plan, CUR.nro_curso, CUR.fecha_ini
        HAVING (((CUR.cupo - COUNT(INS.dni))/CUR.cupo)*100) > 80;
        

