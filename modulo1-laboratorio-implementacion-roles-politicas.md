# Laboratorio: Implementación de Roles y Políticas en AWS IAM

## Introducción

En este laboratorio, aprenderás a implementar roles y políticas avanzadas en AWS Identity and Access Management (IAM). Estos son fundamentales para asegurar el acceso controlado y gestionar los permisos de manera eficiente en un entorno AWS. A través de una serie de iteraciones, crearás políticas personalizadas, configurarás roles y aplicarás condiciones avanzadas para fortalecer la seguridad en tu cuenta de AWS.

## Objetivos del Laboratorio

- Crear y gestionar políticas avanzadas en IAM.
- Implementar roles que puedan ser asumidos por diferentes entidades en AWS.
- Configurar y aplicar condiciones en políticas para controlar el acceso.
- Asegurar el entorno AWS utilizando principios de privilegio mínimo y buenas prácticas de seguridad.

## Iteración 1: Configuración Inicial

**Objetivo:** Configurar un entorno básico en IAM donde crearás y probarás políticas y roles avanzados.

1. **Acceder a la Consola de IAM:**
   - Inicia sesión en la consola de AWS y navega a la sección de IAM.

2. **Crear un Usuario IAM:**
   - Crea un nuevo usuario llamado `admin-user`.
   - Asigna permisos administrativos completos para este usuario inicialmente para permitir la creación de políticas y roles.

3. **Configurar Autenticación Multifactor (MFA):**
   - Habilita MFA para el usuario `admin-user` como una capa adicional de seguridad.

4. **Verificación de Acceso:**
   - Inicia sesión con el nuevo usuario `admin-user` para verificar que puedes acceder y gestionar recursos en AWS.

## Iteración 2: Creación de Políticas Gestionadas por el Cliente

**Objetivo:** Crear políticas personalizadas que definen permisos específicos.

1. **Crear una Política para Acceso Restringido a S3:**
   - Navega a la sección de "Políticas" en IAM y selecciona "Crear política".
   - Define una política JSON que permita acceso solo de lectura a un bucket específico en S3:

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": "s3:GetObject",
               "Resource": "arn:aws:s3:::example-bucket/*"
           }
       ]
   }
   ```

2. **Asociar la Política a un Usuario:**
   - Asocia la política creada al usuario `admin-user` para restringir su acceso solo al bucket S3 especificado.

3. **Probar la Política:**
   - Intenta acceder a otros buckets en S3 y verifica que el acceso está denegado, confirmando que la política está funcionando correctamente.

## Iteración 3: Implementación de Roles y Políticas Cruzadas entre Cuentas

**Objetivo:** Crear un rol que pueda ser asumido por usuarios de otra cuenta de AWS, y aplicar políticas que definan lo que pueden hacer.

1. **Crear un Rol para Acceso Cruzado:**
   - Navega a la sección de "Roles" en IAM y selecciona "Crear rol".
   - Elige "Otra cuenta de AWS" como la entidad de confianza y proporciona el ID de la cuenta que podrá asumir el rol.

2. **Definir una Política de Confianza:**
   - Configura la política de confianza para permitir que la cuenta especificada asuma el rol:

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Principal": {
                   "AWS": "arn:aws:iam::123456789012:root"
               },
               "Action": "sts:AssumeRole"
           }
       ]
   }
   ```

3. **Asociar una Política de Permisos:**
   - Asocia una política gestionada o personalizada que permita a los usuarios de la otra cuenta realizar ciertas acciones, como acceder a un bucket S3 específico.

4. **Prueba de Asunción del Rol:**
   - Desde la cuenta externa, intenta asumir el rol creado y verifica que los permisos se aplican correctamente.

## Iteración 4: Uso de Condiciones en Políticas

**Objetivo:** Aplicar condiciones avanzadas en políticas IAM para controlar el acceso basado en factores como la dirección IP y el tiempo.

1. **Crear una Política con Condiciones de IP:**
   - Define una política que permita acceso a los recursos solo desde un rango específico de IPs:

   ```json
   {
       "Version": "2012-10-17",
       "Statement": [
           {
               "Effect": "Allow",
               "Action": "s3:*",
               "Resource": "arn:aws:s3:::example-bucket/*",
               "Condition": {
                   "IpAddress": {
                       "aws:SourceIp": "203.0.113.0/24"
                   }
               }
           }
       ]
   }
   ```

2. **Aplicar la Política:**
   - Asocia esta política a un rol o usuario, y verifica que el acceso a los recursos solo se permite desde las IPs definidas.

3. **Probar la Condición:**
   - Intenta acceder a los recursos desde una IP no permitida y confirma que el acceso es denegado.

## Iteración 5: Auditoría y Monitoreo de Roles y Políticas

**Objetivo:** Utilizar herramientas de monitoreo y auditoría para asegurar que las políticas y roles están funcionando correctamente y se siguen las mejores prácticas de seguridad.

1. **Habilitar AWS CloudTrail:**
   - Asegúrate de que AWS CloudTrail esté habilitado para registrar todas las acciones en la cuenta relacionadas con IAM.

2. **Revisar Logs de CloudTrail:**
   - Revisa los logs generados por CloudTrail para asegurarte de que los roles y políticas están siendo utilizados como se espera.

3. **Configuración de Alertas con CloudWatch:**
   - Configura alertas en CloudWatch para notificarte si se detectan acciones sospechosas o intentos de acceso no autorizados relacionados con IAM.

4. **Auditoría de IAM con AWS Config:**
   - Implementa AWS Config para monitorear la conformidad de las configuraciones de IAM, asegurando que se adhieren a las políticas de seguridad definidas.

## Iteración 6: Limpieza y Revisión Final

**Objetivo:** Asegurarse de que todos los recursos y configuraciones aplicadas en el laboratorio sean revisados, y limpiar los recursos no necesarios.

1. **Revisar Roles y Políticas Creadas:**
   - Realiza una revisión final de todos los roles y políticas creados durante el laboratorio para asegurar que cumplen con las expectativas de seguridad.

2. **Eliminar Recursos No Necesarios:**
   - Elimina cualquier usuario, rol, política, o recurso que no sea necesario para evitar costos adicionales y reducir el riesgo de seguridad.

3. **Documentación de Resultados:**
   - Documenta todas las configuraciones y resultados del laboratorio, asegurando que puedas replicar y mejorar estas configuraciones en entornos de producción.

## Conclusión

Este laboratorio te ha guiado a través de la creación y gestión de roles y políticas avanzadas en AWS IAM, enseñándote cómo aplicar condiciones, cómo implementar roles que se pueden asumir entre cuentas, y cómo auditar y monitorear estas configuraciones para asegurar un entorno seguro en AWS. Siguiendo estas prácticas, podrás fortalecer la seguridad y el control de acceso en cualquier entorno AWS que administres.
