### Laboratorio: Fortalecimiento de la Seguridad en AWS

#### Objetivo

El objetivo de este laboratorio es guiarte a través de la implementación de varias medidas de seguridad en AWS para proteger tus recursos en la nube. Este laboratorio cubrirá la configuración de **Amazon VPC**, **AWS IAM**, **AWS KMS**, y **AWS CloudTrail** para mejorar la seguridad de la red, la gestión de identidades y la protección de datos.

#### Requisitos Previos

- Una cuenta de AWS con permisos para crear y gestionar recursos como VPC, IAM, KMS, y CloudTrail.
- Familiaridad básica con la consola de AWS y conceptos de seguridad en la nube.

#### Arquitectura de la Solución

El laboratorio se divide en varias etapas que incluyen la configuración de una red segura utilizando Amazon VPC, la implementación de prácticas de gestión de identidades con IAM, la configuración de cifrado con KMS, y la habilitación de auditoría y monitoreo con CloudTrail.

#### Iteración 1: Configuración de una Red Segura con Amazon VPC

1. **Crear una VPC:**
   - Ve a la consola de **Amazon VPC** y crea una nueva VPC.
   - Asigna un rango de direcciones IP CIDR, por ejemplo, `10.0.0.0/16`.
   - Configura subredes públicas y privadas dentro de esta VPC. Las subredes públicas pueden estar en una zona de disponibilidad y las privadas en otra.

2. **Configurar Tablas de Rutas:**
   - Configura una tabla de rutas para la subred pública que permita el acceso a internet a través de un **Internet Gateway**.
   - Configura una tabla de rutas para la subred privada que dirija el tráfico a través de un **NAT Gateway** para que las instancias puedan acceder a internet de manera segura.

3. **Configurar NACLs y Grupos de Seguridad:**
   - Configura **Network ACLs** para agregar una capa adicional de control sobre el tráfico que entra y sale de las subredes.
   - Crea **Grupos de Seguridad** que definan qué tráfico está permitido a nivel de instancia. Por ejemplo, permite solo conexiones SSH desde direcciones IP específicas y acceso HTTP/HTTPS a tus servidores web.

#### Iteración 2: Gestión de Identidades y Acceso con AWS IAM

1. **Crear Roles y Políticas de IAM:**
   - Crea un rol de IAM que permita a las instancias EC2 acceder a servicios de AWS como S3 y CloudWatch. Asigna políticas de acceso mínimo, como `AmazonS3ReadOnlyAccess`.
   - Crea políticas personalizadas que restrinjan el acceso a recursos específicos, asegurando que los usuarios solo puedan acceder a los recursos necesarios para su trabajo.

2. **Implementar MFA:**
   - Habilita **Multi-Factor Authentication (MFA)** para las cuentas de usuario críticas, especialmente aquellas con privilegios administrativos.
   - Configura MFA en la consola de IAM y vincula dispositivos MFA, como aplicaciones de autenticación o tokens físicos, para mejorar la seguridad.

3. **Auditoría de IAM:**
   - Utiliza **IAM Access Analyzer** para revisar los permisos otorgados y detectar posibles exposiciones de datos.
   - Revise los logs de acceso en **CloudTrail** para auditar el uso de las credenciales IAM y detectar actividades sospechosas.

#### Iteración 3: Protección de Datos con AWS KMS

1. **Crear y Gestionar Claves en KMS:**
   - Ve a la consola de **AWS KMS** y crea una **CMK (Customer Master Key)**. Esta clave se utilizará para cifrar datos en servicios como S3, RDS, y EBS.
   - Configura políticas de claves que especifiquen quién puede usar y administrar la clave, siguiendo el principio de privilegio mínimo.

2. **Cifrado de Datos en S3:**
   - Configura un bucket de S3 para que utilice la CMK creada en KMS para cifrar automáticamente todos los objetos almacenados.
   - Habilita la opción de cifrado automático en S3 y prueba la carga y descarga de objetos para asegurarte de que el cifrado funciona como se espera.

3. **Rotación de Claves:**
   - Configura la rotación automática de claves en KMS para mejorar la seguridad, asegurando que las claves de cifrado se actualizan regularmente.
   - Asegúrate de que la rotación de claves no afecta el acceso a los datos cifrados.

#### Iteración 4: Monitoreo y Auditoría con AWS CloudTrail

1. **Habilitar AWS CloudTrail:**
   - Ve a la consola de **AWS CloudTrail** y habilita un nuevo trail que registre todas las acciones realizadas en tu cuenta de AWS.
   - Configura CloudTrail para enviar los logs a un bucket de S3 para almacenamiento a largo plazo y análisis.

2. **Configurar Alertas de Seguridad:**
   - Configura **Amazon CloudWatch Alarms** para recibir alertas cuando se realicen cambios específicos en la infraestructura, como la creación de nuevos roles de IAM o la modificación de políticas de seguridad.
   - Configura alertas para actividades inusuales, como intentos de inicio de sesión fallidos repetidos.

3. **Auditar el Acceso y Uso de Recursos:**
   - Revisa los logs generados por CloudTrail para asegurarte de que todas las actividades realizadas en la cuenta cumplen con las políticas de seguridad establecidas.
   - Analiza los logs para detectar patrones anómalos o potencialmente maliciosos, y toma medidas correctivas cuando sea necesario.

#### Iteración 5: Documentación y Mejores Prácticas

1. **Documentación de Configuraciones:**
   - Documenta todas las configuraciones realizadas durante el laboratorio, incluyendo la configuración de la VPC, las políticas de IAM, las claves de KMS, y la configuración de CloudTrail.
   - Asegúrate de que la documentación incluye diagramas de red, políticas de seguridad, y un resumen de los controles implementados.

2. **Revisión de Mejores Prácticas:**
   - Revisa y asegúrate de que se siguen las mejores prácticas de seguridad recomendadas por AWS. Esto incluye el principio de privilegio mínimo, la rotación de credenciales, y el uso de MFA.
   - Realiza una auditoría final para verificar que todas las configuraciones cumplen con las políticas de seguridad de tu organización.

#### Conclusión

Este laboratorio te ha guiado a través de la implementación de varias prácticas de seguridad en AWS, utilizando servicios como VPC, IAM, KMS, y CloudTrail. Estas medidas fortalecen significativamente la seguridad de tu infraestructura en la nube, protegiendo tanto la red como los datos almacenados y gestionando de manera segura el acceso a los recursos críticos. Con este conocimiento, ahora estás mejor preparado para diseñar y gestionar entornos seguros en AWS, cumpliendo con los más altos estándares de seguridad.
