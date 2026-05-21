# Manual de Usuario — Solarver

**Versión:** 1.1  
**Fecha:** 2026-05-20  
**Audiencia:** Administradores y Empleados del sistema

---

## Tabla de contenidos

1. [Introducción](#1-introducción)
2. [Acceso al sistema](#2-acceso-al-sistema)
3. [Pantalla principal (Dashboard)](#3-pantalla-principal-dashboard)
4. [Clientes](#4-clientes)
5. [Pagos](#5-pagos)
6. [Notificaciones y recordatorios](#6-notificaciones-y-recordatorios)
7. [Reportes](#7-reportes) *(solo administrador)*
8. [Conciliaciones](#8-conciliaciones) *(solo administrador)*
9. [Historial](#9-historial) *(solo administrador)*
10. [Respaldos](#10-respaldos) *(solo administrador)*
11. [Usuarios](#11-usuarios) *(solo administrador)*
12. [Mi perfil](#12-mi-perfil)
13. [Preguntas frecuentes](#13-preguntas-frecuentes)

---

## 1. Introducción

**Solarver** es un sistema de gestión de pagos y cartera de clientes. Permite registrar y dar seguimiento a las deudas de cada cliente, procesar pagos, enviar recordatorios de cobro y generar reportes del estado financiero.

### Roles del sistema

El sistema tiene dos tipos de usuario con distintos niveles de acceso:

| Rol | Acceso |
|---|---|
| **Administrador** | Acceso completo: clientes, pagos, reportes, conciliaciones, usuarios, respaldos e historial. |
| **Empleado** | Acceso limitado: consulta de clientes, registro de pagos y envío de recordatorios. |

Las secciones marcadas con *"solo administrador"* no son visibles para los empleados.

---

## 2. Acceso al sistema

### 2.1 Credenciales iniciales del sistema

Al instalar el sistema por primera vez se crea automáticamente una cuenta de administrador raíz con las siguientes credenciales:

| Campo | Valor |
|---|---|
| Usuario | `admin` |
| Contraseña | `Admin1234` |

> **Importante:** cambie la contraseña en su primer inicio de sesión desde la sección **Mi Perfil**. Esta cuenta no puede eliminarse ni cambiar de rol.

### 2.2 Iniciar sesión

1. Abra el navegador y dirígase a la dirección del sistema.
2. Ingrese su **nombre de usuario** y **contraseña**.
3. Haga clic en **Iniciar sesión**.

El sistema lo redirigirá automáticamente al panel que corresponde a su rol.

### 2.3 Bloqueo por intentos fallidos

Si ingresa una contraseña incorrecta **3 veces consecutivas**, su cuenta quedará bloqueada temporalmente durante **5 minutos**. Después de ese tiempo podrá intentarlo de nuevo. Si el problema persiste, contacte a un administrador.

### 2.4 Cerrar sesión

Haga clic en su nombre o foto de perfil en la esquina superior y seleccione **Cerrar sesión**. Su sesión se cerrará de inmediato y será redirigido a la pantalla de inicio.

> **Importante:** no cierre la pestaña del navegador sin cerrar sesión en computadoras compartidas.

---

## 3. Pantalla principal (Dashboard)

Al iniciar sesión verá el panel de resumen con los indicadores más relevantes del sistema.

### 3.1 Tarjetas de resumen

| Tarjeta | Descripción |
|---|---|
| **Ingresos del mes** | Total de pagos completados en el mes en curso. |
| **Deuda total** | Suma de todos los saldos pendientes de la cartera. |
| **Clientes activos** | Número de clientes con deuda vigente. |

### 3.2 Últimos pagos

Lista de los pagos más recientes registrados en el sistema, con folio, cliente, monto y fecha.

### 3.3 Clientes con deuda

Listado rápido de clientes con saldo pendiente, ordenados por prioridad de atención.

---

## 4. Clientes

En esta sección se administra la información de cada cliente y su deuda asociada.

### 4.1 Ver la lista de clientes

La tabla muestra todos los clientes registrados con su saldo actual y estatus de deuda.

**Columnas de la tabla:**

| Columna | Descripción |
|---|---|
| Nombre | Nombre completo del cliente. |
| Identificación | RFC, CURP u otro identificador único. |
| Correo / Teléfono | Datos de contacto. |
| Día de pago | Día de corte mensual (5 o 17). |
| Saldo pendiente | Monto que aún debe el cliente. |
| Estatus | Estado actual de la deuda (ver §4.2). |

**Buscar un cliente:** utilice el campo de búsqueda en la parte superior de la tabla para filtrar por nombre o identificación.

### 4.2 Estatus de deuda

| Estatus | Significado |
|---|---|
| **Pendiente** | El cliente tiene saldo pero aún no ha vencido el periodo de pago. |
| **Atrasado** | El cliente no pagó antes de su fecha de corte. Se aplica un recargo del 5 %. |
| **Pagado** | El cliente cubrió el pago del periodo vigente. |

El sistema actualiza estos estatus automáticamente cada mañana a las 08:00.

### 4.3 Registrar un nuevo cliente *(administrador)*

1. Haga clic en el botón **Nuevo cliente**.
2. Complete el formulario:

| Campo | Obligatorio | Notas |
|---|---|---|
| Nombre completo | Sí | — |
| Identificación | Sí | RFC, CURP u otro. Debe ser único en el sistema. |
| Correo electrónico | No | Se valida que sea una dirección real. |
| Teléfono | No | Se valida el formato mexicano. |
| Dirección | No | — |
| Día de pago | Sí | Solo puede ser **5** o **17**. |
| Deuda inicial | No | Si se omite, el cliente se crea sin deuda. |
| Plazo (meses) | No | Aplica si se registra deuda. Valores permitidos: 3, 6, 9, 12, 18, 24, 36, 48, 60 o 72. |

3. Haga clic en **Guardar**. El cliente aparecerá en la tabla de inmediato.

> **Nota:** la identificación no puede modificarse una vez guardada. Verifique que sea correcta antes de guardar.

### 4.4 Editar un cliente

1. Haga clic en el botón de edición (lápiz) en la fila del cliente.
2. Modifique los campos disponibles. La **identificación no se puede cambiar**.
3. Haga clic en **Guardar cambios**.

Cada edición queda registrada automáticamente en el historial de auditoría.

### 4.5 Eliminar un cliente *(administrador)*

1. Haga clic en el botón de eliminar (basurero) en la fila del cliente.
2. Confirme la acción en el cuadro de diálogo.

> **Importante:** no se puede eliminar un cliente que tenga saldo pendiente mayor a cero. Primero registre el pago completo o ajuste la deuda.

### 4.6 Ver los últimos pagos de un cliente

Haga clic en el nombre del cliente para ver un resumen de sus últimos 5 pagos: folio, monto, fecha y método de pago.

---

## 5. Pagos

En esta sección se registran los abonos de los clientes y se consulta el historial de movimientos.

### 5.1 Ver la lista de pagos

La tabla muestra los últimos 200 pagos del sistema con folio, cliente, monto, método y estado.

**Tipos de folio:**

| Prefijo | Origen |
|---|---|
| `FOL-` | Pago registrado manualmente por un usuario. |
| `FOL-AUTO-` | Pago procesado automáticamente por notificación bancaria. |
| `FOL-MAN-` | Pago conciliado manualmente por un administrador. |
| `FOL-HUERF-` | Pago bancario cuya referencia no fue identificada (requiere conciliación). |

### 5.2 Registrar un pago

1. Haga clic en **Registrar pago**.
2. Seleccione el **cliente** en el buscador. El sistema mostrará automáticamente el saldo pendiente.
3. Ingrese los datos del pago:

| Campo | Obligatorio | Notas |
|---|---|---|
| Monto | Sí | Debe ser mayor a cero. |
| Fecha | Sí | Fecha en que se recibió el pago. |
| Método de pago | Sí | Transferencia, Efectivo o Tarjeta. |

4. Haga clic en **Guardar**.

El sistema generará un folio único y actualizará el saldo del cliente. Si el monto ingresado supera el saldo pendiente, aparecerá una **advertencia** (el pago se registra igualmente).

**Resultado en pantalla:**
- Folio asignado.
- Nuevo saldo del cliente.
- Nuevo estatus de la deuda.

---

## 6. Notificaciones y recordatorios

Desde esta sección se pueden enviar avisos de cobro a los clientes con deuda activa.

### 6.1 Lista de clientes para notificar

La tabla muestra únicamente clientes con saldo pendiente o atrasado. Los clientes **atrasados** aparecen primero para facilitar la priorización.

### 6.2 Enviar un recordatorio

1. Seleccione uno o varios clientes marcando sus casillas.
2. Haga clic en **Enviar recordatorio**.
3. Elija el **canal** de envío:

| Canal | Requisito |
|---|---|
| **Correo electrónico** | El cliente debe tener correo registrado. |
| **SMS** | El cliente debe tener teléfono registrado. |
| **WhatsApp** | El cliente debe tener teléfono registrado. |

4. Confirme el envío.

Al terminar, el sistema mostrará cuántos recordatorios se enviaron correctamente y cuáles fallaron (junto con la razón).

### 6.3 Historial de recordatorios

La tabla inferior muestra los últimos 20 recordatorios enviados con la fecha, el canal, el destinatario y si el envío fue exitoso o falló.

---

## 7. Reportes *(solo administrador)*

Desde esta sección se generan resúmenes del estado financiero de la cartera y se exportan en distintos formatos.

### 7.1 Estado mensual

Muestra dos listas del mes en curso:
- **Pagaron:** clientes que ya realizaron su pago del periodo.
- **Faltan:** clientes que aún no han pagado.

### 7.2 Ingresos mensuales

Gráfico o tabla de los pagos completados dentro de un rango de fechas. Por defecto muestra los últimos 30 días. Puede ajustar el rango con los campos **Desde** y **Hasta**.

### 7.3 Descargar un reporte

1. Seleccione el **tipo de reporte**:

| Tipo | Contenido |
|---|---|
| **Integral** | Todos los clientes con su situación actual. |
| **Realizados** | Solo pagos completados en el periodo. |
| **Pendiente** | Clientes con saldo pendiente. |
| **Atrasado** | Clientes con deuda vencida. |

2. Elija el **formato**: PDF o Excel.
3. Si aplica, ajuste el rango de fechas.
4. Haga clic en **Descargar**. El archivo se descargará automáticamente.

### 7.4 Enviar estados de cuenta por correo

Envía el estado de cuenta individual de cada cliente directamente a su correo electrónico.

1. Seleccione el tipo de reporte (no aplica `Realizados`).
2. Haga clic en **Enviar a todos**.
3. El sistema confirmará el número de correos a enviar y comenzará el procesamiento en segundo plano.

> El envío puede tardar varios minutos si la cartera es grande. Puede seguir usando el sistema mientras tanto.

**Marca de agua en los PDF:**
- Los estados de cuenta de clientes **al corriente** no llevan marca de agua.
- Los de clientes **pagados** muestran el sello **"PAGADO"** en verde.
- Los de clientes **atrasados** muestran el sello **"VENCIDO"** en rojo.

---

## 8. Conciliaciones *(solo administrador)*

La conciliación es el proceso de relacionar pagos bancarios recibidos con las referencias de cobro del sistema. Cuando el banco notifica un pago con una referencia no reconocida, el pago queda pendiente de conciliación.

### 8.1 Ver referencias pendientes

La tabla muestra las referencias de cobro que aún no han sido pagadas o que necesitan revisión manual, con el cliente asociado, el monto esperado y la fecha de generación.

### 8.2 Conciliar una referencia individualmente

1. Localice la referencia en la tabla.
2. Haga clic en **Conciliar**.
3. Confirme la acción.

El sistema registrará el pago con folio `FOL-MAN-N`, actualizará el saldo del cliente y marcará la referencia como conciliada.

### 8.3 Conciliación masiva

Para conciliar varias referencias a la vez:

1. Seleccione las referencias marcando sus casillas.
2. Haga clic en **Conciliar seleccionadas**.
3. Confirme la acción.

El sistema procesará cada referencia seleccionada. Las que ya hayan sido conciliadas previamente se omitirán sin generar un error.

### 8.4 ¿Qué son los pagos huérfanos?

Un pago huérfano ocurre cuando el banco notifica un pago con una referencia que el sistema no reconoce (por ejemplo, una referencia vencida o escrita incorrectamente por el cliente). Estos pagos aparecen en la lista de pagos con el prefijo `FOL-HUERF-` y con estado **pendiente**.

Para resolverlos, contacte al cliente para identificar a qué deuda corresponde el pago y regístrelo manualmente desde la sección de **Pagos**.

---

## 9. Historial *(solo administrador)*

El historial registra automáticamente cada acción relevante realizada en el sistema: creación y edición de clientes, registros de pagos, actualizaciones de estatus y más.

### 9.1 Ver el historial

La tabla muestra los últimos 100 registros con:
- Fecha y hora del evento.
- Cliente afectado.
- Usuario que realizó la acción.
- Descripción del cambio.

**Ejemplos de acciones registradas:**

| Acción | Cuándo ocurre |
|---|---|
| `CREAR_CLIENTE` | Se registra un nuevo cliente. |
| `EDITAR_CLIENTE` | Se modifican los datos de un cliente. |
| `REGISTRAR_PAGO` | Se registra un pago manual. |
| `ACTUALIZAR_ESTATUS` | El scheduler actualiza el estatus de una deuda. |

Este registro es de **solo lectura** y no puede ser modificado por ningún usuario.

---

## 10. Respaldos *(solo administrador)*

Los respaldos protegen la información del sistema ante fallas de hardware o errores humanos.

### 10.1 Ver los respaldos disponibles

La tabla muestra todos los archivos de respaldo con su nombre, tipo (automático o manual) y fecha de creación.

### 10.2 Crear un respaldo manual

1. Haga clic en **Crear respaldo**.
2. El sistema generará el archivo en segundos y lo mostrará en la tabla.

El nombre del archivo incluye la fecha y hora de creación (ej. `solarver_manual_20260519_142300.sql`).

### 10.3 Descargar un respaldo

Haga clic en el botón de descarga en la fila del respaldo que desea guardar. El archivo `.sql` se descargará a su computadora.

Se recomienda conservar copias de los respaldos en una ubicación externa al servidor (USB, nube, etc.).

### 10.4 Restaurar un respaldo

> **Precaución:** restaurar un respaldo **reemplaza todos los datos actuales** del sistema. Esta acción no se puede deshacer. Asegúrese de crear un respaldo del estado actual antes de proceder.

1. Localice el respaldo en la tabla.
2. Haga clic en **Restaurar**.
3. Confirme la acción en el cuadro de advertencia.

### 10.5 Eliminar un respaldo

Haga clic en el botón de eliminar (basurero) en la fila del respaldo. Confirme la acción. El archivo se eliminará permanentemente del servidor.

### 10.6 Configurar respaldos automáticos

El sistema puede generar respaldos de forma automática según la frecuencia configurada.

1. Haga clic en **Configuración de respaldos**.
2. Seleccione la **frecuencia**:

| Frecuencia | Cuándo se ejecuta |
|---|---|
| **Diario** | Todos los días. |
| **Semanal** | Todos los domingos. |
| **Mensual** | El primer día de cada mes. |

3. Seleccione la **hora** de ejecución (ej. 02:00).
4. Guarde la configuración.

---

## 11. Usuarios *(solo administrador)*

Desde esta sección se gestionan las cuentas de acceso al sistema.

### 11.1 Ver la lista de usuarios

La tabla muestra todos los usuarios con su nombre, nombre de usuario, correo, rol y estado (activo/inactivo).

### 11.2 Crear un usuario

1. Haga clic en **Nuevo usuario**.
2. Complete el formulario:

| Campo | Obligatorio | Notas |
|---|---|---|
| Nombre completo | Sí | — |
| Nombre de usuario | Sí | Debe ser único. Se usa para iniciar sesión. |
| Correo electrónico | Sí | Debe ser único. |
| Contraseña | Sí | Mínimo recomendado: 8 caracteres. |
| Rol | Sí | Administrador o Empleado. |

3. Haga clic en **Guardar**.

La contraseña se almacena de forma segura (cifrada). Nunca se muestra en texto claro.

### 11.3 Editar un usuario

1. Haga clic en el botón de edición en la fila del usuario.
2. Modifique los campos necesarios. El campo de contraseña es opcional; si se deja vacío, la contraseña actual no cambia.
3. Guarde los cambios.

### 11.4 Eliminar un usuario

1. Haga clic en el botón de eliminar en la fila del usuario.
2. Confirme la acción.

> **Nota:** eliminar un usuario no elimina los registros de historial y recordatorios que ese usuario generó; dichos registros quedan sin usuario asociado como referencia histórica.

> **Restricción:** la cuenta de administrador raíz (`admin`) no puede eliminarse ni cambiar de rol. El sistema rechazará esas operaciones con un mensaje de error.

---

## 12. Mi perfil

Cualquier usuario, independientemente de su rol, puede actualizar sus propios datos desde esta sección.

### 12.1 Actualizar datos personales

1. Haga clic en la pestaña **Perfil**.
2. Modifique su **nombre** o **nombre de usuario**.
3. Para actualizar su **foto de perfil**, haga clic en la imagen actual y seleccione un archivo (formatos admitidos: JPG, PNG; tamaño máximo: 5 MB).
4. Haga clic en **Guardar cambios**.

### 12.2 Cambiar contraseña

1. En la pestaña **Perfil**, localice la sección de cambio de contraseña.
2. Ingrese su **contraseña actual**.
3. Ingrese y confirme la **nueva contraseña**.
4. Haga clic en **Actualizar contraseña**.

Si la contraseña actual es incorrecta, el sistema mostrará un mensaje de error y no realizará el cambio.

---

## 13. Preguntas frecuentes

**¿Por qué no puedo eliminar un cliente?**  
El cliente tiene saldo pendiente mayor a cero. Registre el pago completo o contacte a un administrador para ajustar la deuda antes de eliminar la cuenta.

**¿Por qué el estatus de un cliente cambió a "Atrasado" sin que yo hiciera nada?**  
El sistema actualiza los estatus automáticamente cada mañana a las 08:00. Si la fecha de corte del cliente pasó sin que se registrara un pago suficiente, el sistema marcará la deuda como atrasada y aplicará el recargo del 5 %.

**¿Qué hago si un cliente pagó pero el sistema no lo refleja?**  
Si el pago llegó por transferencia bancaria, puede tardar en llegar la notificación al sistema. Revise la sección de **Conciliaciones** para verificar si el pago llegó como huérfano. Si no aparece, registre el pago manualmente desde la sección de **Pagos**.

**¿Puedo enviar un recordatorio a un cliente que ya pagó?**  
No. La lista de notificaciones solo muestra clientes con saldo pendiente o atrasado. Los clientes al corriente no aparecen en esa lista.

**¿Qué pasa si el envío de estados de cuenta falla para algún cliente?**  
El sistema intenta enviarlo hasta completar la lista. Si algún correo falla (por ejemplo, por dirección incorrecta), ese cliente se omite y los demás se procesan normalmente. Puede reenviar individualmente desde la sección de **Notificaciones**.

**¿Con qué frecuencia se generan las referencias de cobro?**  
El sistema genera referencias automáticamente 5 días antes de la fecha de corte de cada cliente (día 5 o día 17 del mes). El cliente recibe por correo un PDF con las instrucciones de pago y el código de referencia.

**¿Qué formato debe tener la referencia de pago para el banco?**  
Las referencias tienen el formato `SOL-{número}-{4 caracteres}` (ej. `SOL-12-A8F9`). Esta referencia es la que el cliente debe usar al realizar su transferencia bancaria para que el pago se procese automáticamente.

**¿Con qué frecuencia debo hacer respaldos?**  
Se recomienda al menos un respaldo diario. La configuración predeterminada del sistema ya contempla esto a las 02:00 AM. Descargue y guarde una copia externa periódicamente.

**No recuerdo mi contraseña, ¿cómo la recupero?**  
Contacte a un administrador para que restablezca su contraseña desde la sección de **Usuarios**. Si quien olvidó la contraseña es el administrador raíz y no hay otro administrador activo, el acceso debe restaurarse directamente en la base de datos o reinstalando el sistema.

**¿Por qué no puedo eliminar ni cambiar el rol del usuario `admin`?**  
La cuenta `admin` es el administrador raíz del sistema y está protegida para evitar que el sistema quede sin acceso de administrador. Puede cambiar su contraseña, nombre y correo normalmente desde **Mi Perfil**.

**¿Puedo ver el historial de cambios de un cliente específico?**  
Actualmente el historial general muestra los últimos 100 eventos del sistema completo. Si necesita filtrar por cliente, un administrador puede consultar la base de datos directamente.

---

*Fin del manual de usuario.*
