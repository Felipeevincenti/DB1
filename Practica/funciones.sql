-- Práctica Nº 3: Funciones de presentación de datos
-- Practica Complementaria: 1 – 2 – 3 – 4 – 5
-- BASE DE DATOS: AGENCIA_PERSONAL

-- 1) Para aquellos contratos que no hayan terminado calcular la fecha de caducidad
-- como la fecha de solicitud más 30 días (no actualizar la base de datos). Función ADDDATE

SELECT 
	CON.nro_contrato,
    CON.fecha_incorporacion,
    fecha_finalizacion_contrato,
    ADDDATE(CON.fecha_solicitud, INTERVAL 30 day) "fecha_caducidad"
FROM `agencia_personal`.`contratos` CON
WHERE ISNULL(CON.fecha_caducidad);

-- 2) Mostrar los contratos. Indicar nombre y apellido de la persona, razón social de la
-- empresa fecha de inicio del contrato y fecha de caducidad del contrato. Si la fecha no ha
-- terminado mostrar “Contrato Vigente”. Función IFNULL

SELECT PER.nombre, PER.apellido, EMP.razon_social, CON.fecha_incorporacion, IFNULL(CON.fecha_caducidad, "Contrato Vigente")
	FROM `agencia_personal`.`personas` PER 
    INNER JOIN `agencia_personal`.`contratos` CON ON PER.dni = CON.dni
	INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit = EMP.cuit;

-- 3) Para aquellos contratos que terminaron antes de la fecha de finalización, indicar la
-- cantidad de días que finalizaron antes de tiempo. Función DATEDIFF

SELECT *, ABS(DATEDIFF(fecha_finalizacion_contrato, fecha_caducidad) )
	FROM `agencia_personal`.`contratos`
	WHERE fecha_caducidad < fecha_finalizacion_contrato;
	

-- 4) Emitir un listado de comisiones impagas para cobrar. Indicar cuit, razón social de la
-- empresa y dirección, año y mes de la comisión, importe y la fecha de vencimiento que se
-- calcula como la fecha actual más dos meses. Función ADDDATE con INTERVAL

SELECT EMP.cuit, EMP.razon_social, EMP.direccion, COM.anio_contrato, COM.mes_contrato, COM.importe_comision, ADDDATE(CURDATE(), INTERVAL 2 MONTH)
	FROM `agencia_personal`.`comisiones` COM
	INNER JOIN `agencia_personal`.`contratos` CON ON COM.nro_contrato = CON.nro_contrato
    INNER JOIN `agencia_personal`.`empresas` EMP ON CON.cuit = EMP.cuit
    WHERE COM.fecha_pago IS NULL;

-- 5) Mostrar en qué día mes y año nacieron las personas (mostrarlos en columnas
-- separadas) y sus nombres y apellidos concatenados. Funciones DAY, YEAR, MONTH y CONCAT

SELECT CONCAT(PER.apellido, " ", PER.nombre), PER.fecha_nacimiento, DAY(PER.fecha_nacimiento), MONTH(PER.fecha_nacimiento), YEAR(PER.fecha_nacimiento)
	FROM `agencia_personal`.`personas` PER;