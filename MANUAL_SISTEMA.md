# Manual de Sistema — Solarver

**Versión:** 1.1  
**Fecha:** 2026-05-20  
**Plataforma:** Python 3 / Flask · PostgreSQL · JavaScript Vanilla

---

## Tabla de contenidos

1. [Descripción general](#1-descripción-general)
2. [Arquitectura del sistema](#2-arquitectura-del-sistema)
3. [Requisitos e instalación](#3-requisitos-e-instalación)
4. [Variables de entorno](#4-variables-de-entorno)
5. [Esquema de base de datos](#5-esquema-de-base-de-datos)
6. [API REST](#6-api-rest)
7. [Servicios de negocio](#7-servicios-de-negocio)
8. [Tareas programadas (Scheduler)](#8-tareas-programadas-scheduler)
9. [Frontend](#9-frontend)
10. [Roles y permisos](#10-roles-y-permisos)
11. [Flujos principales](#11-flujos-principales)
12. [Operaciones de mantenimiento](#12-operaciones-de-mantenimiento)
13. [Cuenta de administrador raíz](#13-cuenta-de-administrador-raíz)
14. [Problemas conocidos](#14-problemas-conocidos)

---

## 1. Descripción general

**Solarver** es un sistema de gestión de pagos y conciliaciones bancarias orientado a empresas que administran carteras de clientes con deudas a plazos. Centraliza el ciclo completo: registro de clientes y deudas, generación automática de referencias de cobro, recepción de pagos vía webhook bancario, conciliación manual de rezagos, envío de recordatorios y generación de reportes exportables.

### Características principales

- Registro y seguimiento de clientes con deudas a plazos (3 – 72 meses).
- Generación diaria automática de referencias de pago con envío de instrucciones por correo.
- Recepción de notificaciones bancarias mediante webhook HTTP.
- Conciliación manual de pagos no identificados automáticamente.
- Actualización diaria de estatus de deuda con aplicación de interés moratorio del 5 %.
- Envío de recordatorios por correo electrónico y SMS.
- Exportación de reportes en PDF y Excel.
- Respaldos automáticos y manuales de la base de datos.
- Auditoría completa de cambios en historial.

---

## 2. Arquitectura del sistema

### 2.1 Vista general de capas

```
┌─────────────────────────────────────────────┐
│               CLIENTE (Navegador)            │
│  login.html · admin.html · empleado.html     │
│  JavaScript Vanilla (modules/ + core/)       │
└───────────────────┬─────────────────────────┘
                    │ HTTP / JSON
┌───────────────────▼─────────────────────────┐
│              FLASK (backend/app.py)          │
│  CORS · APScheduler · Max upload 5 MB        │
│                                              │
│  Blueprints REST:                            │
│  auth · usuarios · clientes · pagos          │
│  recordatorios · reportes · conciliaciones   │
│  webhooks · respaldos                        │
│                                              │
│  Services:                                   │
│  pagos_service · notificaciones_service      │
│  documentos_service · scheduler_service      │
│  validators_service                          │
└───────────────────┬─────────────────────────┘
                    │ psycopg2
┌───────────────────▼─────────────────────────┐
│           PostgreSQL (SolarVer DB)           │
│  ROL · USUARIO · CLIENTE · DEUDA · PAGO      │
│  REFERENCIAPAGO · HISTORIALCAMBIOS           │
│  RECORDATORIO                                │
└─────────────────────────────────────────────┘
```

### 2.2 Estructura de directorios

```
solarver/
├── backend/
│   ├── app.py                  # Entry point Flask y configuración central
│   ├── db.py                   # Conexión PostgreSQL (psycopg2)
│   ├── routes/                 # Blueprints REST
│   │   ├── auth.py
│   │   ├── usuarios.py
│   │   ├── clientes.py
│   │   ├── pagos.py
│   │   ├── recordatorios.py
│   │   ├── reportes.py
│   │   ├── conciliaciones.py
│   │   ├── webhooks.py
│   │   └── respaldos.py
│   ├── services/               # Lógica de negocio
│   │   ├── pagos_service.py
│   │   ├── notificaciones_service.py
│   │   ├── documentos_service.py
│   │   ├── scheduler_service.py
│   │   └── validators_service.py
│   ├── static/uploads/         # Archivos subidos (fotos de perfil)
│   └── backups/                # Respaldos SQL y config.json
├── frontend/
│   ├── js/
│   │   ├── core/               # Utilidades compartidas
│   │   ├── modules/            # Lógica por dominio
│   │   └── pages/              # Entry points por vista
│   ├── pages/                  # HTML de cada vista
│   ├── partials/               # Fragmentos HTML reutilizables (tabs)
│   └── styles/                 # CSS
├── demos/                      # Scripts de demostración
├── requirements.txt
├── setup_solarver_db.sql
└── setup_solarver_dev.py
```

### 2.3 Dependencias principales

| Librería | Versión | Uso |
|---|---|---|
| Flask | 3.0.0 | Framework web |
| flask-cors | 4.0.0 | CORS |
| psycopg2-binary | 2.9.9 | Driver PostgreSQL |
| python-dotenv | 1.0.0 | Variables de entorno |
| bcrypt | 4.1.2 | Hash de contraseñas |
| APScheduler | 3.10.4 | Tareas programadas |
| pandas | 2.0.0 | Generación de Excel |
| openpyxl | 3.1.0 | Formato Excel |
| reportlab | 4.1.0 | Generación de PDF |
| phonenumbers | 8.13.0 | Validación de teléfonos |
| requests | 2.31.0 | Llamadas a APIs externas |
| pytz | 2024.1 | Zona horaria |

---

## 3. Requisitos e instalación

### 3.1 Requisitos previos

- Python 3.10 o superior.
- PostgreSQL 14 o superior.
- `pg_dump` y `psql` disponibles en PATH (para respaldos).
- Acceso a internet para APIs externas (Brevo, Infobip, Abstract API).

### 3.2 Instalación

```bash
# 1. Clonar o descomprimir el proyecto
cd solarver/

# 2. Crear entorno virtual
python -m venv .venv
source .venv/bin/activate        # Linux / macOS
# .venv\Scripts\activate         # Windows

# 3. Instalar dependencias
pip install -r requirements.txt

# 4. Crear archivo .env con las variables de entorno (ver sección 4)
python setup_solarver_dev.py     # opción 1 → genera .env base
# Editar DB_PASSWORD en .env antes de continuar

# 5. Inicializar la base de datos
psql -U postgres -f setup_solarver_db.sql

# 6. Crear la cuenta de administrador raíz
python seed_admin.py

# 7. Iniciar el servidor
python backend/app.py
```

El servidor queda disponible en `http://0.0.0.0:5000`.

### 3.3 Verificar instalación

```bash
curl http://localhost:5000/api/health
# Respuesta esperada: {"status": "ok"}
```

---

## 4. Variables de entorno

El archivo `.env` debe estar en la raíz del proyecto. Todas las variables son obligatorias salvo indicación.

```bash
# ── Base de datos ──────────────────────────────────────────
DB_HOST=localhost
DB_PORT=5432
DB_NAME=SolarVer
DB_USER=postgres
DB_PASSWORD=tu_contraseña

# ── Brevo (correo electrónico) ─────────────────────────────
BREVO_API_KEY=tu_api_key
CORREO_REMITENTE=noreply@tudominio.com
NOMBRE_REMITENTE=Solarver
BREVO_EMAIL_REC_TEMPLATE_ID=3       # Plantilla de recordatorio
BREVO_ESTADO_CUENTA_TEMPLATE_ID=1   # Plantilla de estado de cuenta
BREVO_INSTRUCCIONES_PAGO_TEMPLATE_ID=4  # Plantilla de instrucciones de pago

# ── Infobip (SMS) ─────────────────────────────────────────
INFOBIP_API_KEY=tu_api_key
INFOBIP_BASE_URL=https://xxxxx.api.infobip.com
SMS_SENDER_NAME=SolarVer

# ── Abstract API (validaciones) ────────────────────────────
ABSTRACT_EMAIL_API_KEY=tu_api_key
ABSTRACT_PHONE_API_KEY=tu_api_key
```

---

## 5. Esquema de base de datos

### 5.1 Diagrama de relaciones

```
ROL ──────────────────── USUARIO
                            │
                  ┌─────────┼──────────┐
                  │                    │
              CLIENTE             (auditoría)
                  │                    │
         ┌────────┴────────┐           │
         │                 │           │
       DEUDA          RECORDATORIO ────┘
         │
    ┌────┴────────────┐
    │                 │
  PAGO         REFERENCIAPAGO

HISTORIALCAMBIOS → CLIENTE, USUARIO
```

### 5.2 Tablas

#### ROL

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| Id_Rol | SERIAL | PK | Identificador del rol |
| Nombre_Rol | VARCHAR(50) | NOT NULL | `'Administrador'` o `'Empleado'` |
| Descripcion | VARCHAR(150) | — | Descripción textual del rol |

#### USUARIO

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| Id_Usuario | SERIAL | PK | Identificador del usuario |
| Nombre | VARCHAR(100) | NOT NULL | Nombre completo |
| Username | VARCHAR(50) | UNIQUE, NOT NULL | Nombre de usuario para login |
| Correo | VARCHAR(150) | UNIQUE, NOT NULL | Correo electrónico |
| Contrasena | VARCHAR(255) | NOT NULL | Hash bcrypt |
| Estado | BOOLEAN | DEFAULT TRUE | Cuenta activa/inactiva |
| Intentos_Fallidos | INTEGER | DEFAULT 0, CHECK(0–3) | Contador de intentos fallidos de login |
| Fecha_Bloqueo | TIMESTAMP | — | Bloqueo temporal (5 min) al alcanzar 3 intentos |
| Id_Rol | INTEGER | FK → ROL | Rol asignado |
| Foto_Perfil | VARCHAR(255) | — | Ruta relativa al archivo en `static/uploads/profiles/` |
| Es_Raiz | BOOLEAN | DEFAULT FALSE, NOT NULL | Marca la cuenta raíz creada por `seed_admin.py`. Bloquea eliminación y cambio de rol vía API. |

#### CLIENTE

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| Id_Cliente | SERIAL | PK | Identificador del cliente |
| Nombre_Completo | VARCHAR(150) | NOT NULL | Nombre completo |
| Identificacion | VARCHAR(50) | UNIQUE, NOT NULL | RFC, CURP u otro identificador único |
| Correo | VARCHAR(150) | — | Para envío de recordatorios y reportes |
| Telefono | VARCHAR(20) | — | Formato E.164 sin `+` (ej. `522291234567`) |
| Direccion | VARCHAR(200) | — | Dirección postal |
| Fecha_Pago | INTEGER | CHECK IN (5, 17) | Día de corte mensual |
| Estado | VARCHAR(20) | DEFAULT `'Activo'` | Estado del cliente |

#### DEUDA

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| Id_Deuda | SERIAL | PK | Identificador de la deuda |
| Id_Cliente | INTEGER | FK → CLIENTE, ON DELETE CASCADE | Cliente dueño de la deuda |
| Monto_Total | NUMERIC(10,2) | NOT NULL | Monto original de la deuda |
| Saldo_Pendiente | NUMERIC(10,2) | NOT NULL | Saldo restante por pagar |
| Estatus | VARCHAR(30) | — | `'pendiente'`, `'pagado'`, `'atrasado'` |
| Fecha_Ultimo_Corte | DATE | — | Último día de corte registrado |
| Plazo_Meses | INTEGER | DEFAULT 12 | Valores válidos: 3, 6, 9, 12, 18, 24, 36, 48, 60, 72 |
| Interes_Acumulado | NUMERIC(10,2) | DEFAULT 0 | Interés moratorio acumulado (5 % mensual) |
| Fecha_Ultima_Penalizacion | DATE | — | Evita aplicar multa dos veces en el mismo mes |

#### PAGO

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| Id_Pago | SERIAL | PK | Identificador del pago |
| Id_Deuda | INTEGER | FK → DEUDA, ON DELETE CASCADE | Deuda asociada |
| Monto | NUMERIC(10,2) | NOT NULL | Monto pagado |
| Fecha_Pago | TIMESTAMP | NOT NULL | Fecha y hora del pago |
| Metodo_Pago | VARCHAR(50) | — | `'Transferencia'`, `'Efectivo'`, `'Tarjeta'`, `'Conciliación'` |
| Folio | VARCHAR(100) | UNIQUE | Identificador único del pago. Ver formatos en §5.3 |
| Estado | VARCHAR(30) | — | `'completado'`, `'pendiente'`, `'cancelado'` |
| Referencia_Externa | VARCHAR(255) | — | Referencia bancaria original |

#### REFERENCIAPAGO

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| Id_Referencia | SERIAL | PK | Identificador de la referencia |
| Id_Deuda | INTEGER | FK → DEUDA, ON DELETE CASCADE, NOT NULL | Deuda que origina la referencia |
| Clave_Ref | VARCHAR(50) | UNIQUE, NOT NULL | Formato: `SOL-{id_deuda}-{4chars}` (ej. `SOL-12-A8F9`) |
| Monto_Esperado | NUMERIC(10,2) | NOT NULL | Monto que debe pagar el cliente |
| Fecha_Generacion | TIMESTAMP | DEFAULT NOW() | Fecha de creación |
| Estado | VARCHAR(30) | DEFAULT `'Pendiente'` | `'Pendiente'`, `'Pagado_Automatico'`, `'Conciliado_Manual'`, `'Expirado'` |

#### HISTORIALCAMBIOS

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| Id_Historial | SERIAL | PK | Identificador del registro |
| Id_Cliente | INTEGER | FK → CLIENTE, ON DELETE CASCADE | Cliente afectado |
| Id_Usuario | INTEGER | FK → USUARIO, ON DELETE SET NULL | Usuario que realizó la acción |
| Accion | VARCHAR(100) | — | Ej. `'CREAR_CLIENTE'`, `'REGISTRAR_PAGO'`, `'ACTUALIZAR_ESTATUS'` |
| Descripcion | TEXT | — | Detalle legible del cambio |
| Fecha | TIMESTAMP | — | Fecha y hora del evento |

#### RECORDATORIO

| Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|
| Id_Recordatorio | SERIAL | PK | Identificador del recordatorio |
| Id_Cliente | INTEGER | FK → CLIENTE, ON DELETE CASCADE | Cliente destinatario |
| Id_Usuario | INTEGER | FK → USUARIO, ON DELETE SET NULL | Usuario que lo envió |
| Fecha_Envio | TIMESTAMP | — | Fecha y hora del envío |
| Canal | VARCHAR(50) | — | `'EMAIL'`, `'SMS'`, `'WHATSAPP'` |
| Mensaje | TEXT | — | Contenido del mensaje |
| Estado_Envio | VARCHAR(30) | — | `'enviado'`, `'fallido'`, `'pendiente'` |

### 5.3 Formatos de folio

| Prefijo | Origen | Ejemplo |
|---|---|---|
| `FOL-` | Pago manual registrado por usuario | `FOL-500001` |
| `FOL-AUTO-` | Pago automático procesado por webhook | `FOL-AUTO-500002` |
| `FOL-MAN-` | Conciliación manual de referencia | `FOL-MAN-500003` |
| `FOL-HUERF-` | Pago bancario con referencia desconocida | `FOL-HUERF-500004` |

La secuencia `folio_seq` inicia en 500 000 y se consume de forma atómica.

---

## 6. API REST

La URL base es `http://<host>:5000/api`.

La identidad del usuario autenticado se transmite en el header **`X-Username`** en todas las peticiones que requieren autorización.

### 6.1 Autenticación — `/api`

#### `POST /login`

Valida credenciales y retorna datos de sesión.

**Cuerpo:**
```json
{ "username": "string", "password": "string" }
```

**Respuesta 200:**
```json
{
  "id_usuario": 1,
  "nombre": "Ana García",
  "username": "ana",
  "correo": "ana@empresa.com",
  "rol": "Administrador",
  "foto_perfil": "profiles/ana.jpg",
  "redirect": "/pages/admin.html"
}
```

**Errores:**
| Código | Causa |
|---|---|
| 401 | Credenciales incorrectas |
| 403 | Cuenta bloqueada (máx. 3 intentos; bloqueo de 5 min) |
| 403 | Cuenta desactivada |

---

#### `POST /session/check`

Verifica que el usuario de la sesión activa aún exista en la base de datos.

**Cuerpo:** `{ "username": "string" }`

**Respuesta 200:** `{ "valid": true }`

---

### 6.2 Usuarios — `/api`

Requiere rol **Administrador** (verificado por el frontend).

#### `GET /usuarios`

Lista todos los usuarios del sistema.

**Respuesta 200:**
```json
[
  {
    "id_usuario": 1,
    "nombre": "Ana García",
    "username": "ana",
    "correo": "ana@empresa.com",
    "estado": true,
    "foto_perfil": null,
    "nombre_rol": "Administrador"
  }
]
```

---

#### `GET /roles`

Lista todos los roles disponibles.

**Respuesta 200:** `[{ "id_rol": 1, "nombre_rol": "Administrador" }]`

---

#### `POST /usuarios`

Crea un nuevo usuario. La contraseña se almacena con hash bcrypt.

**Cuerpo:**
```json
{
  "nombre": "string",
  "username": "string",
  "correo": "string",
  "password": "string",
  "id_rol": 1
}
```

**Respuesta 201:** `{ "id_usuario": 5 }`

**Errores:** 400 si username o correo ya existe; 400 si la validación de correo falla.

---

#### `PUT /usuarios/<id_usuario>`

Edita los datos de un usuario. El campo `password` es opcional.

**Cuerpo:** Mismos campos que `POST /usuarios` (todos opcionales salvo los de identificación).

**Respuesta 200:** `{ "mensaje": "Usuario actualizado" }`

---

#### `DELETE /usuarios/<id_usuario>`

Elimina un usuario.

**Respuesta 200:** `{ "mensaje": "Usuario eliminado" }`

---

#### `PUT /usuarios/perfil/<id_usuario>`

Actualiza nombre, username y foto de perfil (multipart/form-data).

**Form fields:** `nombre`, `username`, `foto` (archivo, opcional)

**Respuesta 200:** datos actualizados del usuario.

---

#### `PUT /usuarios/perfil/<id_usuario>/password`

Cambia la contraseña verificando la actual.

**Cuerpo:** `{ "password_actual": "string", "password_nueva": "string" }`

**Respuesta 200:** `{ "mensaje": "Contraseña actualizada" }`

---

### 6.3 Clientes — `/api`

#### `GET /clientes`

Retorna todos los clientes con su deuda activa (LEFT JOIN).

**Respuesta 200:**
```json
[
  {
    "id_cliente": 1,
    "nombre_completo": "Juan Pérez",
    "identificacion": "PERJ800101ABC",
    "correo": "juan@mail.com",
    "telefono": "522291234567",
    "fecha_pago": 5,
    "estado": "Activo",
    "id_deuda": 3,
    "saldo_pendiente": 15000.00,
    "estatus": "pendiente"
  }
]
```

---

#### `POST /clientes`

Registra un nuevo cliente. Si se proporcionan `deuda_inicial` y `plazo_meses`, se crea la deuda al mismo tiempo.

**Cuerpo:**
```json
{
  "nombre": "string",
  "identificacion": "string",
  "correo": "string (opcional)",
  "telefono": "string (opcional)",
  "direccion": "string (opcional)",
  "fecha_pago": 5,
  "deuda_inicial": 50000.00,
  "plazo_meses": 12,
  "id_usuario": 1
}
```

**Validaciones:** correo vía Abstract API (failsafe: pasa si la API falla); teléfono vía `phonenumbers` + Abstract API; `fecha_pago` debe ser 5 o 17.

**Respuesta 201:** `{ "id_cliente": 8 }`

---

#### `PUT /clientes/<id_cliente>`

Edita los datos de un cliente. No permite cambiar la `identificacion`.

**Respuesta 200:** `{ "mensaje": "Cliente actualizado" }`

---

#### `DELETE /clientes/<id_cliente>`

Elimina un cliente. Bloqueado si tiene saldo pendiente mayor a cero.

**Errores:** 400 si tiene saldo activo.

---

#### `GET /clientes/<id_cliente>/pagos`

Retorna los últimos 5 pagos del cliente.

**Respuesta 200:**
```json
[
  {
    "folio": "FOL-500001",
    "monto": 2500.00,
    "fecha_pago": "15/04/2026",
    "metodo_pago": "Transferencia",
    "estado": "completado"
  }
]
```

---

### 6.4 Pagos — `/api`

#### `GET /pagos`

Retorna los últimos 200 pagos registrados con datos del cliente.

**Respuesta 200:**
```json
[
  {
    "id_pago": 1,
    "folio": "FOL-500001",
    "nombre_completo": "Juan Pérez",
    "monto": 2500.00,
    "fecha_pago": "2026-04-15T10:30:00",
    "metodo_pago": "Transferencia",
    "estado": "completado",
    "huerfano": false
  }
]
```

El campo `huerfano: true` indica pagos sin deuda asignada (pago bancario no identificado).

---

#### `POST /pagos`

Registra un pago manual.

**Cuerpo:**
```json
{
  "id_cliente": 1,
  "monto": 2500.00,
  "fecha_pago": "2026-04-15",
  "metodo_pago": "Efectivo",
  "id_usuario": 1
}
```

**Respuesta 201:**
```json
{
  "folio": "FOL-500005",
  "id_pago": 12,
  "nuevo_saldo": 12500.00,
  "nuevo_estatus": "pendiente",
  "advertencia": null
}
```

El campo `advertencia` se popula si el monto supera el saldo pendiente.

---

### 6.5 Recordatorios e historial — `/api`

#### `GET /recordatorios/clientes`

Lista clientes con deuda activa (saldo > 0, estatus `pendiente` o `atrasado`). Los clientes `atrasado` aparecen primero.

---

#### `POST /recordatorios/enviar`

Envía recordatorios de pago a uno o varios clientes.

**Cuerpo:**
```json
{
  "ids_clientes": [1, 3, 5],
  "canal": "email",
  "id_usuario": 1
}
```

**Canales válidos:** `"email"`, `"sms"`, `"whatsapp"`

**Respuesta 200:**
```json
{
  "enviados": 2,
  "errores": [{ "id_cliente": 5, "razon": "sin correo registrado" }]
}
```

---

#### `GET /recordatorios/historial`

Retorna los últimos 20 recordatorios enviados.

---

#### `GET /historial`

Retorna los últimos 100 registros de auditoría del sistema.

---

### 6.6 Reportes — `/api`

#### `GET /reportes/estado-mensual`

Resumen del mes en curso: clientes que pagaron vs. clientes que aún no pagan.

**Respuesta 200:** `{ "pagaron": [...], "faltan": [...] }`

---

#### `GET /reportes/ingresos-mensuales`

Pagos completados dentro de un rango de fechas (por defecto últimos 30 días).

**Query params:** `inicio=YYYY-MM-DD`, `fin=YYYY-MM-DD`

---

#### `GET /reportes/exportar`

Descarga un reporte en PDF o Excel.

**Query params:**

| Parámetro | Valores | Descripción |
|---|---|---|
| `tipo` | `integral`, `realizados`, `pendiente`, `atrasado` | Tipo de reporte |
| `formato` | `pdf`, `excel` | Formato de salida |
| `inicio` | `YYYY-MM-DD` | Inicio del rango (opcional) |
| `fin` | `YYYY-MM-DD` | Fin del rango (opcional) |

**Respuesta:** archivo adjunto con Content-Disposition.

---

#### `POST /reportes/enviar-masivo`

Envía estados de cuenta individuales por correo a todos los clientes con deuda activa. El procesamiento es asíncrono (responde HTTP 202 inmediatamente).

**Cuerpo:** `{ "tipo": "integral" }`  
**Tipos no permitidos:** `"realizados"` (retorna 400).

**Respuesta 202:** `{ "mensaje": "Procesando", "total": 35 }`

---

### 6.7 Conciliaciones — `/api`

#### `GET /conciliaciones/pendientes`

Lista referencias de cobro con Estado `'Pendiente'`, enriquecidas con datos del cliente.

---

#### `POST /conciliaciones/manual/<id_referencia>`

Concilia manualmente una referencia pendiente. Genera folio `FOL-MAN-N`, registra el pago y actualiza la deuda.

**Respuesta 200:** `{ "mensaje": "Conciliación exitosa", "folio": "FOL-MAN-500006" }`

---

#### `POST /conciliaciones/manual/masivo`

Concilia varias referencias en una sola llamada.

**Cuerpo:** `{ "referencias": [1, 2, 3] }`

**Respuesta 200:** `{ "procesadas": 3 }`  
Las referencias inválidas o ya procesadas se omiten silenciosamente.

---

### 6.8 Webhooks bancarios — `/api`

#### `POST /webhooks/banco`

Punto de entrada para notificaciones del banco. Siempre responde HTTP 200 (el banco no debe recibir errores que bloqueen el flujo).

**Cuerpo:**
```json
{ "referencia": "SOL-12-A8F9", "monto": 4166.67 }
```

**Comportamiento:**

| Caso | Folio generado | Estado REFERENCIAPAGO | Estado PAGO |
|---|---|---|---|
| Referencia válida y `Pendiente` | `FOL-AUTO-N` | `Pagado_Automatico` | `completado` |
| Referencia inválida o ya procesada | `FOL-HUERF-N` | N/A (no existe) | `pendiente` |

Los pagos huérfanos quedan visibles en la pantalla de Conciliaciones para resolución manual.

---

### 6.9 Respaldos — `/api`

Todos los endpoints requieren rol **Administrador** (verificado por header `X-Username`).

#### `GET /respaldos`

Lista los archivos de respaldo disponibles en `backend/backups/`.

---

#### `POST /respaldos`

Genera un respaldo manual mediante `pg_dump`.

**Cuerpo:** `{ "tipo": "manual" }` (opcional)

**Respuesta 201:** `{ "nombre": "solarver_manual_20260519_142300.sql" }`

---

#### `POST /respaldos/restaurar`

**Acción destructiva.** Restaura la base de datos desde un archivo de respaldo mediante `psql`.

**Cuerpo:** `{ "nombre": "solarver_manual_20260519_142300.sql" }`

---

#### `DELETE /respaldos/<nombre>`

Elimina un archivo de respaldo.

---

#### `GET /respaldos/descargar/<nombre>`

Descarga un archivo de respaldo como adjunto.

---

#### `GET /respaldos/config`

Lee la configuración de respaldos automáticos desde `backups/config.json`.

**Respuesta 200:** `{ "frecuencia": "diario", "hora": "02:00" }`

---

#### `POST /respaldos/config`

Actualiza la configuración de respaldos automáticos.

**Cuerpo:** `{ "frecuencia": "semanal", "hora": "03:00" }`

---

### 6.10 Health check

#### `GET /api/health`

**Respuesta 200:** `{ "status": "ok" }`

---

## 7. Servicios de negocio

### 7.1 pagos_service.py

Contiene la lógica transaccional de pagos y conciliaciones. Las funciones reciben una conexión/cursor abierto y **no hacen commit ni rollback** — esa responsabilidad recae en el endpoint llamador.

#### `generar_folio(cursor, prefijo='FOL') → str`

Consume la secuencia `folio_seq` de PostgreSQL de forma atómica y devuelve un folio formateado.

```python
generar_folio(cur, 'FOL')       # → 'FOL-500001'
generar_folio(cur, 'FOL-AUTO')  # → 'FOL-AUTO-500002'
generar_folio(cur, 'FOL-MAN')   # → 'FOL-MAN-500003'
generar_folio(cur, 'FOL-HUERF') # → 'FOL-HUERF-500004'
```

---

#### `calcular_estatus_deuda(cursor, id_deuda, nuevo_saldo, deuda, hoy=None) → str`

Determina el estatus de una deuda después de un pago.

**Lógica:**
1. Calcula el inicio del periodo vigente: último día de corte (5 o 17) del mes actual.
2. Suma los pagos registrados desde ese día.
3. Compara con la mensualidad esperada (incluyendo interés acumulado).
4. Si `nuevo_saldo ≤ 0`: retorna `'pagado'`.
5. Si los pagos del periodo cubren la mensualidad: retorna `'pendiente'`.
6. Si la fecha ya pasó el día de corte y no cubrió: retorna `'atrasado'`.

---

#### `procesar_conciliacion(cursor, id_ref: int) → bool`

Ejecuta en 5 pasos la conciliación de una referencia:
1. Obtiene la referencia (verifica que exista y esté `Pendiente`).
2. Genera folio `FOL-MAN-N`.
3. Registra el pago con método `'Conciliación'` y estado `'completado'`.
4. Marca la referencia como `'Conciliado_Manual'`.
5. Actualiza saldo y estatus de la deuda.

Retorna `False` si la referencia no existe o ya fue procesada.

---

### 7.2 notificaciones_service.py

Centraliza el envío de mensajes por distintos canales. Las credenciales de API se leen desde las variables de entorno en cada llamada.

#### `enviar_email(to_email, to_name, template_id, params, adjunto=None) → (bool, str)`

Envía un correo usando la API v3 de Brevo con una plantilla predefinida.

- `params`: dict con variables que se inyectan en la plantilla HTML.
- `adjunto`: dict `{ "nombre": "archivo.pdf", "contenido_b64": "..." }`.
- Retorna `(True, "")` en éxito o `(False, mensaje_error)` en fallo.

---

#### `enviar_sms(telefono, mensaje) → (bool, str)`

Envía SMS mediante la API Advanced de Infobip.

- Normaliza el número: si tiene 10 dígitos, antepone el prefijo `52` (México).
- Retorna `(True, "")` en éxito o `(False, mensaje_error)` en fallo.

---

#### `enviar_estado_cuenta(cliente) → bool`

Genera el PDF del estado de cuenta del cliente y lo envía por correo como adjunto.

---

#### `iniciar_envio_masivo(lista_clientes)`

Lanza el procesamiento en segundo plano usando `ThreadPoolExecutor` con máximo 3 hilos paralelos para no saturar la API de Brevo.

---

#### `enviar_instrucciones_pago(datos_pago) → bool`

Genera un PDF con el código QR de la referencia de cobro y lo envía por correo al cliente.

---

### 7.3 documentos_service.py

Genera los documentos PDF y Excel que el sistema produce.

#### `generar_pdf_base64(cliente) → str`

Crea el estado de cuenta en PDF con los siguientes elementos:
- Encabezado con logotipo y datos del cliente.
- Tabla de movimientos (pagos recientes).
- Saldo actual y estatus.
- **Marca de agua** condicional:
  - `"PAGADO"` en verde si saldo ≤ 0 o estatus `'pagado'`.
  - `"VENCIDO"` en rojo si estatus es `'atrasado'`, `'vencido'` o `'moroso'`.
- Retorna el PDF codificado en Base64.

**Colores de marca:**  
`BRAND_BLUE #1E85C8` · `BRAND_DARK #0E4F8A` · `BRAND_ORANGE #FF7A1F`

---

#### `generar_pdf_instrucciones_pago(cliente_nombre, monto, clave_referencia, fecha_limite) → str`

PDF de instrucciones de pago con código QR generado a partir de `clave_referencia`. Retorna Base64.

---

#### `generar_excel_reporte(datos) → BytesIO`

Genera una hoja de cálculo con pandas y openpyxl. Retorna un stream listo para enviar como descarga.

---

#### `generar_pdf_reporte(datos, tipo) → BytesIO`

Genera un reporte PDF tabular con ReportLab. Retorna stream para descarga.

---

### 7.4 validators_service.py

#### `validar_correo(correo) → (bool, str|None)`

Validación en dos fases:
1. Regex básico de formato.
2. Abstract Email Reputation API (verifica entregabilidad real).

**Failsafe:** si la API externa falla, el correo se considera válido para no bloquear el flujo.

---

#### `validar_telefono(telefono, region_default='MX') → (bool, str|None)`

Validación en dos fases:
1. Librería `phonenumbers` (validación local, sin internet).
2. Abstract Phone Intelligence API (verifica número real).

Retorna el número normalizado en formato E.164 sin `+` (ej. `522291234567`). Failsafe equivalente al de correo.

---

## 8. Tareas programadas (Scheduler)

El scheduler se inicializa en `app.py` usando APScheduler con zona horaria `America/Mexico_City`.

### Resumen de tareas

| Hora | Función | Descripción |
|---|---|---|
| 08:00 AM | `actualizar_estatus_deudas` | Recalcula estatus y aplica interés moratorio |
| 09:00 AM | `procesar_cobros_automaticos` | Genera referencias y envía instrucciones de pago |
| Cada minuto | `procesar_respaldos_automaticos` | Evalúa si toca hacer respaldo automático |

---

### `actualizar_estatus_deudas(fecha_simulada=None) → int`

Procesa todas las deudas activas (saldo > 0):

1. Para cada deuda, determina el periodo vigente (desde el último día de corte: 5 o 17).
2. Suma los pagos del periodo.
3. Calcula el nuevo estatus (`pendiente`, `atrasado`, `pagado`).
4. Si el nuevo estatus es `atrasado` y `Fecha_Ultima_Penalizacion` no corresponde al mes actual: aplica un recargo del **5 %** sobre el saldo pendiente.
5. Registra cada cambio en `HISTORIALCAMBIOS` con acción `'ACTUALIZAR_ESTATUS'`.

Retorna el número de cuentas actualizadas. El parámetro `fecha_simulada` permite pruebas sin alterar el reloj del sistema.

---

### `procesar_cobros_automaticos(fecha_simulada=None) → int`

Se activa automáticamente si la fecha de hoy + 5 días corresponde al día 5 o 17:

1. Busca clientes cuya `Fecha_Pago` coincide con ese día y que tengan saldo pendiente.
2. Para cada cliente, genera una `Clave_Ref` única (`SOL-{id_deuda}-{4chars_aleatorios}`).
3. Inserta la referencia en `REFERENCIAPAGO` con Estado `'Pendiente'`.
4. Genera el PDF de instrucciones de pago con código QR.
5. Envía el PDF por correo al cliente.

Retorna el número de referencias enviadas.

---

### `procesar_respaldos_automaticos()`

Lee `backups/config.json` (por defecto: frecuencia diaria a las 02:00):

| Frecuencia | Condición de ejecución |
|---|---|
| `'diario'` | Una vez por día |
| `'semanal'` | Solo los domingos |
| `'mensual'` | Solo el día 1 de cada mes |

Evita respaldos duplicados en el mismo día consultando los archivos existentes. Si corresponde, invoca `generar_archivo_respaldo('auto')` que ejecuta `pg_dump`.

---

## 9. Frontend

### 9.1 Tecnología

JavaScript Vanilla (ES Modules, sin frameworks). Organizado en tres capas:

| Capa | Directorio | Propósito |
|---|---|---|
| Core | `js/core/` | Utilidades compartidas entre todas las vistas |
| Módulos | `js/modules/` | Lógica de dominio por funcionalidad |
| Pages | `js/pages/` | Entry points que orquestan los módulos por rol |

---

### 9.2 Utilidades core

**`api.js`** — Define `API_BASE_URL` (`http://<host>:5000`). Todas las llamadas al backend pasan por esta constante.

**`auth.js`**

| Función | Descripción |
|---|---|
| `getUsuario()` | Lee el usuario de `sessionStorage` |
| `guardarUsuario(datos)` | Persiste el usuario tras login |
| `cerrarSesion()` | Limpia `sessionStorage` y redirige a login |
| `esAdmin()` | Retorna `true` si el rol es `'Administrador'` |
| `actualizarDatosSesion(datos)` | Fusiona nuevos datos sobre la sesión actual |

**`utils.js`**

| Función | Descripción |
|---|---|
| `formatMoney(valor)` | Formatea a pesos MX: `$1.5M`, `$300k`, `$1,234.56` |
| `getIniciales(nombre)` | Extrae las dos primeras iniciales del nombre |
| `renderPagBtns(containerId, pages, active, fn)` | Renderiza paginación |

**`partials.js`** — `loadSharedTabs()`: carga dinámicamente los HTML de los tabs comunes (dashboard, clientes, pagos, notificaciones, perfil).

**`dashboard_utils.js`** — `cargarStatsDashboard()` y `cargarListasDashboard()`: poblán las tarjetas de resumen del dashboard.

---

### 9.3 Vistas y roles

| Vista | Archivo HTML | Entry point JS | Rol |
|---|---|---|---|
| Login | `pages/login.html` | `pages/login.js` | Público |
| Dashboard administrador | `pages/admin.html` | `pages/admin.js` | Administrador |
| Dashboard empleado | `pages/empleado.html` | `pages/empleado.js` | Empleado |

**Tabs del administrador:** Dashboard · Clientes · Pagos · Notificaciones · Reportes · Conciliaciones · Historial · Respaldos · Usuarios · Perfil

**Tabs del empleado:** Dashboard · Clientes · Pagos · Notificaciones · Perfil

---

## 10. Roles y permisos

### Administrador

| Área | Acciones permitidas |
|---|---|
| Usuarios | Crear, editar, eliminar, cambiar rol |
| Clientes | Crear, editar, eliminar |
| Pagos | Registrar pagos manuales |
| Conciliaciones | Conciliar manual e individual y masivo |
| Recordatorios | Enviar por email, SMS, WhatsApp |
| Reportes | Descargar PDF/Excel, envío masivo de estados de cuenta |
| Respaldos | Crear, restaurar, descargar, eliminar, configurar |
| Historial | Ver auditoría completa |
| Perfil | Editar datos propios y contraseña |

### Empleado

| Área | Acciones permitidas |
|---|---|
| Clientes | Ver lista, editar datos (sin eliminar) |
| Pagos | Registrar pagos manuales |
| Recordatorios | Enviar a clientes individuales |
| Perfil | Editar datos propios y contraseña |
| **Bloqueado** | Usuarios, conciliaciones, reportes completos, respaldos |

La verificación de acceso de administrador en el backend se realiza consultando el rol del usuario desde `X-Username` mediante la función `es_admin(username)` en `respaldos.py`. El resto de los módulos confía en el control del frontend.

---

## 11. Flujos principales

### 11.1 Autenticación

```
Usuario          →  POST /login
                 ←  { usuario, rol, redirect }
                 →  sessionStorage.setItem(usuario)
                 →  window.location = redirect
```

Bloqueo temporal: tras 3 intentos fallidos consecutivos, la cuenta queda bloqueada 5 minutos. El contador se reinicia al autenticarse correctamente.

---

### 11.2 Registro manual de pago

```
Empleado/Admin  →  Selecciona cliente (GET /clientes)
                →  Abre modal de pago
                →  Ingresa monto, fecha, método
                →  POST /pagos
                       ↓ (pagos_service)
                       generar_folio()
                       calcular_estatus_deuda()
                       INSERT pago, UPDATE deuda
                       INSERT historialcambios
                ←  { folio, nuevo_saldo, nuevo_estatus }
```

---

### 11.3 Ciclo automático de cobro

```
09:00 AM  →  procesar_cobros_automaticos()
              ├── Selecciona deudas con fecha_pago = hoy+5
              ├── INSERT REFERENCIAPAGO (Estado='Pendiente')
              ├── generar_pdf_instrucciones_pago()
              └── enviar_instrucciones_pago() → Brevo API

Banco     →  POST /webhooks/banco { referencia, monto }
              ├── Referencia válida:
              │     generar_folio('FOL-AUTO')
              │     INSERT PAGO (completado)
              │     UPDATE REFERENCIAPAGO → Pagado_Automatico
              │     UPDATE DEUDA
              └── Referencia inválida:
                    generar_folio('FOL-HUERF')
                    INSERT PAGO (pendiente, huérfano)
```

---

### 11.4 Actualización diaria de estatus

```
08:00 AM  →  actualizar_estatus_deudas()
              Para cada deuda activa:
              ├── Suma pagos del periodo vigente
              ├── Compara con mensualidad requerida
              ├── Determina nuevo estatus
              ├── Si atrasado y no penalizado este mes:
              │     Saldo += Saldo * 0.05
              │     Fecha_Ultima_Penalizacion = hoy
              └── INSERT HISTORIALCAMBIOS
```

---

### 11.5 Conciliación manual

```
Admin  →  GET /conciliaciones/pendientes
       ←  Lista de referencias Pendiente
       →  POST /conciliaciones/manual/<id>
               ↓ (pagos_service.procesar_conciliacion)
               generar_folio('FOL-MAN')
               INSERT PAGO (completado, método='Conciliación')
               UPDATE REFERENCIAPAGO → Conciliado_Manual
               UPDATE DEUDA
       ←  { folio }
```

---

### 11.6 Envío masivo de estados de cuenta

```
Admin  →  POST /reportes/enviar-masivo { tipo }
       ←  HTTP 202 { total: N }   ← Respuesta inmediata

En background (ThreadPoolExecutor, 3 hilos):
  Para cada cliente con correo:
    generar_pdf_base64(cliente)
    enviar_email(to, template, pdf_b64) → Brevo API
```

---

## 12. Operaciones de mantenimiento

### 12.1 Iniciar el servidor

```bash
source venv/bin/activate
python backend/app.py
```

El servidor escucha en `0.0.0.0:5000` en modo desarrollo. Para producción se recomienda usar Gunicorn detrás de Nginx.

---

### 12.2 Respaldo manual de la base de datos

Desde la interfaz web (panel de Respaldos, solo administrador):
- Hacer clic en **Crear respaldo** genera un archivo `.sql` en `backend/backups/`.

Desde la línea de comandos:
```bash
pg_dump -U postgres -d SolarVer > solarver_$(date +%Y%m%d_%H%M%S).sql
```

---

### 12.3 Restaurar un respaldo

**Precaución: esta operación es destructiva y reemplaza todos los datos actuales.**

Desde la interfaz web (panel de Respaldos):
- Seleccionar el archivo y hacer clic en **Restaurar**.

Desde la línea de comandos:
```bash
psql -U postgres -d SolarVer < nombre_del_respaldo.sql
```

---

### 12.4 Configurar respaldos automáticos

El archivo `backend/backups/config.json` controla la programación:

```json
{
  "frecuencia": "diario",
  "hora": "02:00"
}
```

**Valores válidos para `frecuencia`:** `"diario"`, `"semanal"` (domingos), `"mensual"` (día 1).

Este archivo también se puede editar desde el panel de Respaldos de la interfaz web.

---

### 12.5 Carpetas que no se deben modificar manualmente

| Carpeta | Razón |
|---|---|
| `backend/static/uploads/` | Archivos subidos por usuarios reales |
| `backend/backups/` | Respaldos de base de datos |
| `backend/__pycache__/` | Generado automáticamente por Python |

---

## 13. Cuenta de administrador raíz

La cuenta raíz es el primer usuario administrador del sistema. Se crea ejecutando `seed_admin.py` una sola vez después de inicializar el esquema.

### 13.1 Creación

```bash
python seed_admin.py
```

El script verifica si el usuario `admin` ya existe. Si no existe, lo crea con contraseña hasheada en bcrypt y el flag `Es_Raiz = TRUE`. Si ya existe, termina sin realizar cambios.

**Credenciales iniciales:**

| Campo | Valor |
|---|---|
| Usuario | `admin` |
| Contraseña | `Admin1234` |
| Correo | `admin@solarver.com` |
| Rol | Administrador |

> **Cambiar la contraseña en el primer inicio de sesión** desde la sección **Mi Perfil**.

También puede ejecutarse desde el menú interactivo de `setup_solarver_dev.py` (opción 3).

### 13.2 Protecciones aplicadas

El flag `Es_Raiz` activa las siguientes restricciones en `backend/routes/usuarios.py`:

| Operación | Comportamiento |
|---|---|
| `DELETE /usuarios/<id>` | Retorna **403** — la cuenta raíz no puede eliminarse. |
| `PUT /usuarios/<id>` con cambio de rol | Retorna **403** — el rol de la cuenta raíz no puede modificarse. |
| Cambio de contraseña, nombre o correo | Permitido normalmente desde **Mi Perfil**. |

Estas restricciones operan a nivel de API; no hay cambios de interfaz en el frontend.

---

## 14. Problemas conocidos

### FIXME — Contraseñas sin hash (riesgo de seguridad)

**Ubicación:** `backend/routes/auth.py` (login) y `backend/routes/usuarios.py` (cambio de contraseña).

**Descripción:** El sistema tiene un fallback que permite autenticar usuarios cuya contraseña esté almacenada en texto plano, para compatibilidad con cuentas antiguas que no fueron migradas a bcrypt.

**Riesgo:** expone contraseñas de usuarios que no han sido migrados.

**Mitigación recomendada:** migrar todas las cuentas existentes a bcrypt y eliminar el bloque de fallback en ambos archivos.

---

### Concurrencia en envío masivo

El envío masivo de estados de cuenta usa `ThreadPoolExecutor` con 3 hilos. Si la lista de clientes es muy grande, el proceso puede extenderse varios minutos en segundo plano sin retroalimentación adicional al usuario más allá del total inicial devuelto en HTTP 202.

---

*Fin del manual de sistema.*
