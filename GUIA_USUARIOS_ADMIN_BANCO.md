# 🚀 Guía de Trabajo: Usuarios Admin y Banco

## 👥 Usuarios Configurados

### 🔑 Credenciales de Acceso

| Usuario | Email | Contraseña | Rol | Descripción |
|---------|-------|------------|-----|-------------|
| **Administrador** | `<correo del administrador>` | `<contraseña asignada>` | ROLE_ADMIN | Acceso completo al sistema |
| **Ana Banco** | `<correo de usuario banco>` | `<contraseña asignada>` | ROLE_BANCO | Analista bancario |
| **Carlos Gestor** | `<correo de gestor>` | `<contraseña asignada>` | ROLE_GESTOR | Gestor de crédito |

## 🎯 Flujo de Trabajo: Crear Solicitud y Asignar a Banco

### Paso 1: Login como Administrador
1. Ve a: `http://localhost/baes/`
2. Login con: `<correo del administrador>` / `<contraseña asignada>`
3. Serás redirigido al dashboard

### Paso 2: Crear una Nueva Solicitud
1. En el menú lateral, haz clic en **"Solicitudes de Crédito"**
2. Haz clic en el botón **"Nueva Solicitud"** (verde)
3. Completa los campos obligatorios:
   - **Tipo de Persona**: Natural o Jurídica
   - **Nombre del Cliente**: Ej. "Juan Pérez"
   - **# de Cédula**: Ej. "123456789"
   - **Perfil Financiero**: Asalariado, Jubilado o Independiente

### Paso 3: Asignar Usuario Banco
1. En la pestaña **"Datos Generales"**
2. En la sección **"Asignación de Banco"**
3. Selecciona **"Ana Banco"** del dropdown
4. Completa otros datos opcionales si deseas
5. Haz clic en **"Guardar Solicitud"**

### Paso 4: Verificar la Asignación
1. La solicitud se creará con estado **"Nueva"**
2. Al asignar el banco, el estado cambiará a **"En Revisión Banco"**
3. Se creará automáticamente una nota en el muro de tiempo

### Paso 5: Login como Usuario Banco
1. Cierra sesión del admin
2. Login con: `<correo de usuario banco>` / `<contraseña asignada>`
3. En el dashboard verás las solicitudes asignadas a ti
4. Ve a **"Solicitudes de Crédito"** para ver todas las solicitudes

### Paso 6: Procesar la Solicitud como Banco
1. Busca la solicitud que creaste
2. Haz clic en el botón **"Aprobar/Rechazar"** (gavel icon)
3. Completa los datos requeridos:
   - **Ejecutivo del Banco**: Tu nombre
   - **Decisión**: Aprobar o Rechazar
   - Si apruebas: Letra y Plazo
   - Si rechazas: Comentarios del motivo
4. Haz clic en **"Procesar Decisión"**

## 🔍 Funcionalidades por Rol

### 👑 ROLE_ADMIN
- ✅ Ver todas las solicitudes
- ✅ Crear nuevas solicitudes
- ✅ Asignar usuarios banco
- ✅ Editar cualquier solicitud
- ✅ Eliminar solicitudes
- ✅ Gestionar usuarios
- ✅ Gestionar roles
- ✅ Gestionar bancos

### 🏦 ROLE_BANCO
- ✅ Ver solo sus solicitudes asignadas
- ✅ Editar solicitudes asignadas
- ✅ Aprobar/Rechazar solicitudes
- ✅ Agregar notas al muro de tiempo
- ✅ Ver adjuntos
- ❌ No puede crear nuevas solicitudes
- ❌ No puede eliminar solicitudes
- ❌ No puede gestionar usuarios

## 📊 Estados de Solicitud

| Estado | Descripción | Quién puede cambiar |
|--------|-------------|-------------------|
| **Nueva** | Solicitud recién creada | Admin/Gestor |
| **En Revisión Banco** | Asignada a usuario banco | Admin (al asignar) |
| **Aprobada** | Aprobada por el banco | Usuario Banco |
| **Rechazada** | Rechazada por el banco | Usuario Banco |
| **Completada** | Proceso finalizado | Admin |

## 🛠️ URLs Importantes

- **Login**: `http://localhost/baes/`
- **Dashboard**: `http://localhost/baes/dashboard.php`
- **Solicitudes**: `http://localhost/baes/solicitudes.php`
- **Usuarios**: `http://localhost/baes/usuarios.php` (solo admin)
- **Roles**: `http://localhost/baes/roles.php` (solo admin)
- **Bancos**: `http://localhost/baes/bancos.php` (solo admin)

## 💡 Consejos de Uso

1. **Para Admin**: Puedes usar tanto el rol admin como gestor para crear solicitudes
2. **Para Banco**: Solo verás las solicitudes asignadas a ti
3. **Muro de Tiempo**: Cada acción importante crea una nota automática
4. **Adjuntos**: Puedes subir documentos desde el modal de adjuntos
5. **Estados**: El sistema cambia automáticamente los estados según las acciones

## 🚨 Solución de Problemas

### Si no puedes acceder:
- Verifica que XAMPP esté corriendo (Apache y MySQL)
- Verifica las credenciales
- Revisa la consola del navegador por errores

### Si no aparecen solicitudes:
- Verifica que la base de datos `solicitud_credito` existe
- Verifica que las tablas se crearon correctamente
- Revisa los logs de Apache/PHP

### Si hay errores de permisos:
- Verifica que los roles estén asignados correctamente
- Revisa la tabla `usuario_roles`

---

**¡Listo para trabajar! 🎉**
