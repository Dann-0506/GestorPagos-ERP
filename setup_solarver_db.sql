-- ═══════════════════════════════════════════════════════════
--  SolarVer – Script de configuración inicial de la base de datos
--
--  Crea la base de datos, todas las tablas del sistema,
--  las relaciones de clave foránea y los datos de prueba
--  necesarios para el entorno de desarrollo.
--  Ejecutar como superusuario de PostgreSQL.
-- ═══════════════════════════════════════════════════════════

-- 1. Crear la base de datos
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'SolarVer';
DROP DATABASE IF EXISTS "SolarVer";
CREATE DATABASE "SolarVer";

-- ── Conectarse a la BD antes de continuar ──
\c SolarVer;

-- ═══════════════════════════════════════════════════════════
--  2. TABLAS 
-- ═══════════════════════════════════════════════════════════

-- Catálogo de roles del sistema (Administrador, Empleado).
CREATE TABLE "ROL" (
    "Id_Rol"      SERIAL PRIMARY KEY,
    "Nombre_Rol"  VARCHAR(50)  NOT NULL,
    "Descripcion" VARCHAR(150)
);

-- Usuarios del sistema con credenciales, rol asignado y bloqueo por intentos fallidos.
-- Es_Raiz marca la cuenta de administrador raíz creada por seed_admin.py; no puede eliminarse ni cambiar de rol.
CREATE TABLE "USUARIO" (
    "Id_Usuario"        SERIAL PRIMARY KEY,
    "Nombre"            VARCHAR(100) NOT NULL,
    "Username"          VARCHAR(50)  UNIQUE NOT NULL,
    "Correo"            VARCHAR(150) UNIQUE NOT NULL,
    "Contrasena"        VARCHAR(255) NOT NULL,
    "Estado"            BOOLEAN      DEFAULT TRUE,
    "Intentos_Fallidos" INTEGER      DEFAULT 0,
    "Fecha_Bloqueo"     TIMESTAMP,
    "Id_Rol"            INTEGER,
    "Foto_Perfil"       VARCHAR(255),
    "Es_Raiz"           BOOLEAN      DEFAULT FALSE NOT NULL,

    CONSTRAINT "Chk_Intentos_Fallidos"
        CHECK ("Intentos_Fallidos" BETWEEN 0 AND 3)
);

-- Clientes registrados con datos de contacto y día de corte mensual (5 o 17).
CREATE TABLE "CLIENTE" (
    "Id_Cliente"      SERIAL PRIMARY KEY,
    "Nombre_Completo" VARCHAR(150) NOT NULL,
    "Identificacion"  VARCHAR(50)  UNIQUE NOT NULL,
    "Correo"          VARCHAR(150),
    "Telefono"        VARCHAR(20),
    "Direccion"       VARCHAR(200),
    "Fecha_Pago"      INTEGER      CHECK ("Fecha_Pago" IN (5, 17)),
    "Estado"          VARCHAR(20)  DEFAULT 'Activo'
);

-- Deudas activas o liquidadas de cada cliente, con plazo, saldo pendiente e intereses acumulados.
CREATE TABLE "DEUDA" (
    "Id_Deuda"                  SERIAL PRIMARY KEY,
    "Id_Cliente"                INTEGER,
    "Monto_Total"               NUMERIC(10,2) NOT NULL,
    "Saldo_Pendiente"           NUMERIC(10,2) NOT NULL,
    "Estatus"                   VARCHAR(30) CHECK ("Estatus" IN ('pendiente', 'pagado', 'atrasado')),
    "Fecha_Ultimo_Corte"        DATE,
    "Plazo_Meses"               INTEGER DEFAULT 12 CHECK ("Plazo_Meses" IN (3, 6, 9, 12, 18, 24, 36, 48, 60, 72)),
    "Interes_Acumulado"         NUMERIC(10,2) DEFAULT 0.00,
    "Fecha_Ultima_Penalizacion" DATE
);

-- Abonos realizados contra una deuda, con folio único y método de pago.
CREATE TABLE "PAGO" (
    "Id_Pago"     SERIAL PRIMARY KEY,
    "Id_Deuda"    INTEGER,
    "Monto"       NUMERIC(10,2) NOT NULL,
    "Fecha_Pago"  TIMESTAMP    NOT NULL,
    "Metodo_Pago" VARCHAR(50),
    "Folio"       VARCHAR(100) UNIQUE,
    "Estado"      VARCHAR(30)  CHECK ("Estado" IN ('completado', 'pendiente', 'cancelado')),
    "Referencia_Externa"  VARCHAR(255)
);

-- Referencias de pago generadas para conciliación bancaria automática.
-- El estado refleja si la referencia fue pagada, conciliada manualmente o expiró.
CREATE TABLE "REFERENCIAPAGO" (
    "Id_Referencia" SERIAL PRIMARY KEY,
    "Id_Deuda"      INTEGER NOT NULL,
    "Clave_Ref"     VARCHAR(50) UNIQUE NOT NULL,
    "Monto_Esperado" NUMERIC(10,2) NOT NULL,
    "Fecha_Generacion" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    "Estado"        VARCHAR(30) DEFAULT 'Pendiente' CHECK ("Estado" IN ('Pendiente', 'Pagado_Automatico', 'Conciliado_Manual', 'Expirado'))
);

-- Auditoría de acciones realizadas sobre clientes por los usuarios del sistema.
CREATE TABLE "HISTORIALCAMBIOS" (
    "Id_Historial" SERIAL PRIMARY KEY,
    "Id_Cliente"   INTEGER,
    "Id_Usuario"   INTEGER,
    "Accion"       VARCHAR(100),
    "Descripcion"  TEXT,
    "Fecha"        TIMESTAMP
);

-- Avisos de pago enviados a clientes por canal (correo, SMS) con su estado de entrega.
CREATE TABLE "RECORDATORIO" (
    "Id_Recordatorio" SERIAL PRIMARY KEY,
    "Id_Cliente"      INTEGER,
    "Id_Usuario"      INTEGER,
    "Fecha_Envio"     TIMESTAMP,
    "Canal"           VARCHAR(50),
    "Mensaje"         TEXT,
    "Estado_Envio"    VARCHAR(30)
);

-- Secuencia para folios de pago (evita condición de carrera)
CREATE SEQUENCE folio_seq START 500000;

-- ═══════════════════════════════════════════════════════════
--  3. RELACIONES
-- ═══════════════════════════════════════════════════════════

ALTER TABLE "USUARIO"
    ADD CONSTRAINT "Fk_Usuario_Rol"
    FOREIGN KEY ("Id_Rol")
    REFERENCES "ROL"("Id_Rol")
    ON DELETE SET NULL
    ON UPDATE CASCADE;

ALTER TABLE "DEUDA"
    ADD CONSTRAINT "Fk_Deuda_Cliente"
    FOREIGN KEY ("Id_Cliente")
    REFERENCES "CLIENTE"("Id_Cliente")
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE "PAGO"
    ADD CONSTRAINT "Fk_Pago_Deuda"
    FOREIGN KEY ("Id_Deuda")
    REFERENCES "DEUDA"("Id_Deuda")
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE "REFERENCIAPAGO"
    ADD CONSTRAINT "Fk_Referencia_Deuda"
    FOREIGN KEY ("Id_Deuda")
    REFERENCES "DEUDA"("Id_Deuda")
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE "RECORDATORIO"
    ADD CONSTRAINT "Fk_Recordatorio_Cliente"
    FOREIGN KEY ("Id_Cliente")
    REFERENCES "CLIENTE"("Id_Cliente")
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE "RECORDATORIO"
    ADD CONSTRAINT "Fk_Recordatorio_Usuario"
    FOREIGN KEY ("Id_Usuario")
    REFERENCES "USUARIO"("Id_Usuario")
    ON DELETE SET NULL
    ON UPDATE CASCADE;

ALTER TABLE "HISTORIALCAMBIOS"
    ADD CONSTRAINT "Fk_Historial_Cliente"
    FOREIGN KEY ("Id_Cliente")
    REFERENCES "CLIENTE"("Id_Cliente")
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE "HISTORIALCAMBIOS"
    ADD CONSTRAINT "Fk_Historial_Usuario"
    FOREIGN KEY ("Id_Usuario")
    REFERENCES "USUARIO"("Id_Usuario")
    ON DELETE SET NULL
    ON UPDATE CASCADE;

-- ═══════════════════════════════════════════════════════════
--  4. DATOS INICIALES
-- ═══════════════════════════════════════════════════════════

-- Roles del sistema (requeridos antes de ejecutar seed_admin.py)
INSERT INTO "ROL" ("Nombre_Rol", "Descripcion") VALUES
    ('Administrador', 'Gestiona usuarios, clientes y configuración del sistema.'),
    ('Empleado',      'Gestiona información de clientes y registra pagos.');

-- NOTA: el usuario administrador raíz se crea ejecutando seed_admin.py
--       después de inicializar esta base de datos.

-- ═══════════════════════════════════════════════════════════
--  5. VERIFICACIÓN FINAL
-- ═══════════════════════════════════════════════════════════

SELECT 'Tablas creadas:' AS info;
-- Filtra por 'public' para excluir tablas internas del sistema de PostgreSQL.
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;

SELECT 'Roles registrados:' AS info;
SELECT "Id_Rol", "Nombre_Rol" FROM "ROL";