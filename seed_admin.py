"""
SolarVer – Seed de cuenta de administrador raíz

Crea el usuario administrador raíz con contraseña hasheada en bcrypt
si aún no existe en la base de datos. Ejecutar una sola vez después
de inicializar el esquema con setup_solarver_db.sql.

Uso:
    python seed_admin.py
"""

from __future__ import annotations

import os
import sys


def crear_admin_raiz() -> None:
    """Crea el usuario administrador raíz si no existe en la BD.

    Conecta a PostgreSQL usando las variables de entorno definidas en .env,
    verifica que el username 'admin' no exista y lo inserta con contraseña
    hasheada en bcrypt y el flag Es_Raiz activo.
    """
    try:
        import bcrypt
        import psycopg2
        import psycopg2.extras
        from dotenv import load_dotenv
    except ImportError as e:
        print(f"Error: módulo no encontrado — {e}")
        print("Ejecuta: pip install -r requirements.txt")
        sys.exit(1)

    load_dotenv()

    USERNAME = 'admin'
    PASSWORD = 'Admin1234'
    NOMBRE   = 'Administrador'
    CORREO   = 'admin@solarver.com'

    conn = cursor = None
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            port=os.getenv('DB_PORT', '5432'),
            dbname=os.getenv('DB_NAME', 'SolarVer'),
            user=os.getenv('DB_USER', 'postgres'),
            password=os.getenv('DB_PASSWORD'),
        )
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        cursor.execute('SELECT "Id_Usuario" FROM "USUARIO" WHERE "Username" = %s', (USERNAME,))
        if cursor.fetchone():
            print(f"La cuenta '{USERNAME}' ya existe. No se realizaron cambios.")
            return

        cursor.execute(
            'SELECT "Id_Rol" FROM "ROL" WHERE "Nombre_Rol" = \'Administrador\' LIMIT 1'
        )
        rol = cursor.fetchone()
        if not rol:
            print("Error: no se encontró el rol 'Administrador'.")
            print("Asegúrate de haber ejecutado setup_solarver_db.sql primero.")
            sys.exit(1)

        hashed = bcrypt.hashpw(PASSWORD.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

        cursor.execute(
            """
            INSERT INTO "USUARIO"
                ("Nombre", "Username", "Correo", "Contrasena", "Estado", "Id_Rol", "Es_Raiz")
            VALUES (%s, %s, %s, %s, TRUE, %s, TRUE)
            """,
            (NOMBRE, USERNAME, CORREO, hashed, rol['Id_Rol']),
        )
        conn.commit()

        print('═══════════════════════════════════════════════════════')
        print('  Cuenta de administrador raíz creada exitosamente     ')
        print('═══════════════════════════════════════════════════════')
        print(f'  Usuario:    {USERNAME}')
        print(f'  Contraseña: {PASSWORD}')
        print('  Cambia la contraseña en tu primer inicio de sesión.')
        print('═══════════════════════════════════════════════════════')

    except Exception as e:
        if conn:
            conn.rollback()
        print(f'Error al crear el administrador raíz: {e}')
        sys.exit(1)
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


if __name__ == '__main__':
    crear_admin_raiz()
