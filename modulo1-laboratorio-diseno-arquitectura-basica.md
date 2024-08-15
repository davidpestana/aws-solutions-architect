# Laboratorio: Diseño de Arquitectura Básica en AWS

## Introducción

En este laboratorio, diseñaremos y desplegaremos una arquitectura básica en AWS. El objetivo es guiarte a través de cada paso del proceso, explicando no solo lo que se hace, sino también cómo y por qué se hace. El laboratorio se estructura en iteraciones, con cada iteración construyendo sobre la anterior para asegurar que comprendas y puedas replicar cada aspecto de la arquitectura.

## Objetivos del Laboratorio

- Desarrollar una comprensión sólida de los componentes fundamentales de AWS.
- Aprender a diseñar una arquitectura básica utilizando servicios clave como EC2, S3, y RDS.
- Implementar buenas prácticas en seguridad, disponibilidad, y gestión de recursos.
- Adquirir experiencia práctica en el despliegue y configuración de recursos en la nube.

## Iteraciones del Laboratorio

### Iteración 1: Configuración de la Cuenta de AWS y Preparación del Entorno

**Objetivo:** Asegurarse de que la cuenta de AWS esté configurada correctamente y que el entorno esté listo para el despliegue.

1. **Crear una cuenta de AWS:**
   - Si aún no tienes una cuenta de AWS, regístrate en [aws.amazon.com](https://aws.amazon.com). Sigue el proceso de registro, incluyendo la verificación de tu correo electrónico y el ingreso de detalles de pago.
   - **Por qué:** La cuenta de AWS es esencial para acceder a los servicios de AWS y realizar cualquier operación en la nube.

2. **Configurar IAM (Identity and Access Management):**
   - Crea un nuevo usuario IAM con permisos administrativos para realizar las operaciones en AWS. Es recomendable no usar la cuenta raíz para tareas diarias.
   - **Cómo:** Navega a IAM desde la consola de AWS, selecciona "Usuarios", y luego "Agregar usuario". Asigna permisos administrativos y habilita MFA.
   - **Por qué:** Crear un usuario IAM con privilegios limitados mejora la seguridad y permite una mejor gestión de acceso.

3. **Configurar la consola de AWS CLI (Command Line Interface):**
   - Instala AWS CLI en tu máquina local. Una vez instalada, configura la CLI usando `aws configure` e ingresa las credenciales del usuario IAM.
   - **Por qué:** AWS CLI permite automatizar tareas y ejecutar comandos desde la terminal, lo que es útil para scripts y despliegues repetitivos.

4. **Establecer una política de etiquetas (Tags):**
   - Define una política de etiquetado para los recursos que crearás. Las etiquetas ayudan a organizar y administrar los recursos.
   - **Por qué:** Etiquetar los recursos facilita la gestión, la facturación y el seguimiento de los activos en AWS.

### Iteración 2: Creación de una VPC (Virtual Private Cloud)

**Objetivo:** Configurar una VPC que servirá como red aislada para los recursos que desplegaremos.

1. **Crear una nueva VPC:**
   - En la consola de AWS, navega a "VPC" y selecciona "Crear VPC". Configura una VPC con un rango de direcciones CIDR de 10.0.0.0/16.
   - **Por qué:** Una VPC permite tener una red privada en la nube, donde puedes gestionar y aislar tus recursos.

2. **Configurar subredes:**
   - Crea dos subredes dentro de la VPC: una pública (10.0.1.0/24) y una privada (10.0.2.0/24).
   - **Por qué:** Las subredes públicas permiten que los recursos sean accesibles desde internet, mientras que las subredes privadas mantienen ciertos recursos protegidos.

3. **Configurar una tabla de enrutamiento:**
   - Configura la tabla de enrutamiento para que el tráfico de la subred pública se dirija a la puerta de enlace de internet.
   - **Por qué:** Esto asegura que las instancias en la subred pública puedan comunicarse con el exterior.

4. **Asociar la tabla de enrutamiento:**
   - Asocia la tabla de enrutamiento con la subred pública.
   - **Por qué:** Esto es necesario para que el tráfico pueda fluir correctamente desde la subred pública hacia internet.

### Iteración 3: Creación y Configuración de una Instancia EC2

**Objetivo:** Desplegar una instancia EC2 y configurarla para que sea accesible públicamente.

1. **Lanzar una instancia EC2:**
   - Desde la consola de EC2, selecciona "Lanzar instancia". Elige una AMI (Amazon Machine Image) de Linux, como Amazon Linux 2, y selecciona el tipo de instancia t2.micro.
   - **Por qué:** EC2 es un servicio que proporciona capacidad de cómputo escalable en la nube. La instancia t2.micro es suficiente para fines de aprendizaje y es gratuita dentro del nivel gratuito de AWS.

2. **Configurar la instancia en la subred pública:**
   - Asegúrate de lanzar la instancia en la subred pública creada en la iteración anterior.
   - **Por qué:** Esto permite que la instancia sea accesible desde internet, necesario para servidores web y otros servicios públicos.

3. **Configurar el grupo de seguridad:**
   - Configura un grupo de seguridad para permitir tráfico SSH (puerto 22) desde tu IP y tráfico HTTP (puerto 80) desde cualquier IP.
   - **Por qué:** Los grupos de seguridad actúan como firewalls virtuales, controlando el acceso a las instancias EC2.

4. **Asignar una IP elástica:**
   - Asigna una Elastic IP a la instancia EC2 para que tenga una dirección IP pública estática.
   - **Por qué:** Una Elastic IP permite que tu instancia EC2 sea accesible mediante una dirección IP fija, lo cual es crucial para servidores que necesitan ser accesibles continuamente.

5. **Conectar a la instancia mediante SSH:**
   - Usa un cliente SSH (como PuTTY en Windows o la terminal en macOS/Linux) para conectarte a la instancia usando la IP elástica.
   - **Por qué:** Conectarse a la instancia EC2 te permite administrar y configurar el servidor.

### Iteración 4: Configuración de un Servidor Web en EC2

**Objetivo:** Configurar un servidor web básico en la instancia EC2.

1. **Actualizar el sistema operativo:**
   - Ejecuta `sudo yum update -y` para actualizar los paquetes del sistema operativo.
   - **Por qué:** Mantener el sistema actualizado es crucial para la seguridad y el rendimiento.

2. **Instalar un servidor web (Apache):**
   - Instala Apache ejecutando `sudo yum install httpd -y`.
   - **Por qué:** Apache es un servidor web ampliamente utilizado y fácil de configurar.

3. **Iniciar y habilitar el servicio de Apache:**
   - Ejecuta `sudo systemctl start httpd` para iniciar el servidor web y `sudo systemctl enable httpd` para que Apache se inicie automáticamente al arrancar la instancia.
   - **Por qué:** Esto garantiza que el servidor web esté en funcionamiento y se mantenga activo después de reinicios.

4. **Configurar las reglas de seguridad:**
   - Verifica que el puerto 80 esté abierto en el grupo de seguridad para permitir el tráfico HTTP.
   - **Por qué:** Sin esta configuración, los usuarios no podrán acceder al servidor web desde internet.

5. **Verificar la instalación:**
   - Abre un navegador web y accede a la IP elástica. Deberías ver la página de bienvenida de Apache.
   - **Por qué:** Esto confirma que el servidor web está configurado correctamente y es accesible desde internet.

### Iteración 5: Configuración de Almacenamiento S3

**Objetivo:** Configurar un bucket S3 para almacenar y servir contenido estático, como imágenes o archivos.

1. **Crear un bucket S3:**
   - Navega a S3 en la consola de AWS y crea un nuevo bucket. Nombra el bucket de acuerdo con tu preferencia, asegurándote de que sea único a nivel global.
   - **Por qué:** Amazon S3 es un servicio de almacenamiento de objetos que permite almacenar y recuperar cualquier cantidad de datos en cualquier momento.

2. **Configurar permisos del bucket:**
   - Asegura que el bucket sea privado por defecto. Configura políticas de acceso para permitir la lectura pública solo de ciertos objetos si es necesario.
   - **Por qué:** La privacidad de los datos es crucial; solo los objetos que deben ser accesibles públicamente deben serlo.

3. **Subir archivos al bucket:**
   - Sube algunos archivos estáticos (imágenes, documentos) al bucket.
   - **Por qué:** S3 es ideal para almacenar contenido estático que puede ser servido a través de una aplicación web.

4. **Habilitar el versionado:**
   - Activa el versionado en el bucket para mantener múltiples versiones de un objeto.
   - **Por qué:** El versionado permite recuperar versiones anteriores de un archivo, protegiendo contra la sobrescritura accidental.

5. **Configurar una política de ciclo de vida:**
   - Configura una política de ciclo de vida para mover archivos a S3 Glacier después de 30 días.
   - **Por qué:** Esto ayuda a reducir costos al almacenar archivos a largo plazo en un almacenamiento más económico.

### Iteración 6: Configuración de una Base de Datos Relacional con RDS

**Objetivo:** Configurar un servicio de base de datos relacional utilizando Amazon RDS.

1. **Crear una instancia de RDS:**
   - Desde la consola de

 RDS, crea una nueva base de datos utilizando MySQL o PostgreSQL como motor de base de datos.
   - **Por qué:** RDS permite configurar, operar y escalar una base de datos relacional en la nube con facilidad.

2. **Configurar la base de datos en la subred privada:**
   - Asegúrate de que la instancia de RDS esté en la subred privada para que no sea accesible desde internet.
   - **Por qué:** Las bases de datos deben estar protegidas de accesos no autorizados y solo ser accesibles por las aplicaciones que las necesiten.

3. **Configurar grupos de seguridad:**
   - Configura los grupos de seguridad para permitir el acceso a la base de datos solo desde la instancia EC2.
   - **Por qué:** Restringir el acceso a la base de datos mejora la seguridad al limitar quién puede conectarse.

4. **Conectar la instancia EC2 a la base de datos:**
   - Configura la aplicación en la instancia EC2 para conectarse a la base de datos RDS utilizando las credenciales y la dirección endpoint proporcionadas por RDS.
   - **Por qué:** Esto permite que la aplicación almacene y recupere datos de una base de datos gestionada y escalable.

5. **Verificar la conexión y el rendimiento:**
   - Ejecuta algunas consultas de prueba desde la instancia EC2 para asegurarte de que la base de datos esté operativa.
   - **Por qué:** Probar la conexión garantiza que la configuración sea correcta y que la base de datos esté lista para usarse.

### Iteración 7: Implementación de Seguridad Adicional

**Objetivo:** Fortalecer la seguridad de la arquitectura desplegada.

1. **Habilitar CloudTrail:**
   - Activa AWS CloudTrail para registrar todas las acciones y cambios realizados en la cuenta de AWS.
   - **Por qué:** CloudTrail proporciona un registro detallado de la actividad de la cuenta, lo que es esencial para auditoría y monitoreo.

2. **Configurar políticas de IAM:**
   - Revisa y ajusta las políticas de IAM para asegurarte de que los usuarios solo tengan acceso a los recursos necesarios.
   - **Por qué:** Minimizar los permisos reduce el riesgo de accesos no autorizados y la exposición de datos.

3. **Configurar claves KMS para cifrado:**
   - Usa AWS KMS para crear y gestionar claves de cifrado que se utilicen para cifrar datos en S3, RDS, y EBS.
   - **Por qué:** El cifrado es esencial para proteger los datos en reposo y en tránsito.

4. **Revisar las reglas de los grupos de seguridad:**
   - Asegúrate de que solo los puertos y direcciones IP necesarias estén permitidas en los grupos de seguridad.
   - **Por qué:** Las reglas excesivamente permisivas pueden exponer la infraestructura a ataques externos.

5. **Configurar AWS Config para el monitoreo de conformidad:**
   - Activa AWS Config para monitorear los cambios en la configuración de los recursos y garantizar que cumplan con las políticas de la organización.
   - **Por qué:** AWS Config permite identificar configuraciones incorrectas o no conformes de manera proactiva.

### Iteración 8: Implementación de Monitorización y Alertas

**Objetivo:** Configurar la monitorización y las alertas para mantener la infraestructura bajo control.

1. **Configurar métricas de CloudWatch:**
   - Configura Amazon CloudWatch para monitorizar el uso de CPU, memoria, y el tráfico de red en las instancias EC2.
   - **Por qué:** Monitorizar el rendimiento es crucial para identificar y resolver problemas antes de que afecten a los usuarios.

2. **Crear alarmas en CloudWatch:**
   - Configura alarmas que notifiquen al equipo cuando las métricas críticas (como el uso de CPU) superen ciertos umbrales.
   - **Por qué:** Las alarmas automáticas permiten una respuesta rápida a los problemas, minimizando el tiempo de inactividad.

3. **Monitorear los logs de Apache:**
   - Configura CloudWatch Logs para recopilar y almacenar los registros del servidor Apache en la instancia EC2.
   - **Por qué:** Analizar los logs del servidor ayuda a identificar errores y comportamientos anómalos en la aplicación.

4. **Configurar el monitoreo de RDS:**
   - Usa CloudWatch para monitorizar las métricas de RDS, como el uso de CPU, conexiones activas, y IOPS.
   - **Por qué:** Monitorear la base de datos es esencial para asegurar su rendimiento y disponibilidad.

5. **Implementar dashboards en CloudWatch:**
   - Crea un dashboard en CloudWatch que muestre todas las métricas clave en un solo lugar.
   - **Por qué:** Un dashboard proporciona una vista centralizada del estado de la infraestructura, facilitando su gestión.

### Iteración 9: Optimización de Costos

**Objetivo:** Optimizar los recursos utilizados para reducir los costos operativos.

1. **Revisar el uso de EC2:**
   - Analiza el uso de la instancia EC2 y considera el uso de instancias reservadas si la carga de trabajo es constante.
   - **Por qué:** Las instancias reservadas ofrecen descuentos significativos si se usan continuamente.

2. **Configurar el ciclo de vida de los datos en S3:**
   - Asegúrate de que los datos en S3 se muevan automáticamente a S3 Glacier después de un período de inactividad.
   - **Por qué:** Almacenar datos menos utilizados en Glacier reduce costos.

3. **Revisar el uso de EBS:**
   - Verifica si los volúmenes EBS que has provisionado están siendo utilizados. Libera o reduce el tamaño de volúmenes subutilizados.
   - **Por qué:** Reducir o eliminar volúmenes EBS innecesarios ayuda a reducir costos de almacenamiento.

4. **Implementar AWS Budgets:**
   - Configura AWS Budgets para alertarte cuando los costos mensuales se aproximen a un límite predeterminado.
   - **Por qué:** AWS Budgets te ayuda a controlar los costos y evitar sorpresas en la factura.

5. **Optimizar la base de datos RDS:**
   - Revisa el tamaño de la instancia de RDS y ajusta si es demasiado grande para la carga de trabajo.
   - **Por qué:** Seleccionar el tamaño adecuado para la instancia RDS puede reducir costos sin sacrificar el rendimiento.

### Iteración 10: Pruebas y Mejora Continua

**Objetivo:** Realizar pruebas de la arquitectura y preparar un plan para su mejora continua.

1. **Prueba de Resiliencia:**
   - Simula fallos de zona de disponibilidad para verificar que la arquitectura pueda mantenerse operativa.
   - **Por qué:** Probar la resiliencia asegura que la infraestructura pueda soportar fallos y continuar operando.

2. **Pruebas de carga:**
   - Usa herramientas como Apache JMeter o AWS Load Testing para simular tráfico y medir el rendimiento de la arquitectura.
   - **Por qué:** Las pruebas de carga identifican cuellos de botella y permiten mejorar la capacidad de la infraestructura.

3. **Pruebas de seguridad:**
   - Realiza pruebas de penetración y análisis de vulnerabilidades en la infraestructura para identificar y mitigar riesgos de seguridad.
   - **Por qué:** Asegurar la infraestructura contra posibles ataques es crítico para proteger los datos y la operación.

4. **Documentar la Arquitectura:**
   - Crea una documentación detallada de la arquitectura, incluyendo diagramas y flujos de trabajo.
   - **Por qué:** La documentación facilita el mantenimiento y la mejora de la infraestructura en el futuro.

5. **Revisión y mejora continua:**
   - Establece un ciclo regular de revisiones de la arquitectura y ajustes basados en nuevos requisitos, cambios en el negocio o avances tecnológicos.
   - **Por qué:** La mejora continua asegura que la infraestructura evolucione junto con las necesidades del negocio y las mejores prácticas.

## Conclusión

Este laboratorio ha cubierto un amplio conjunto de actividades que conforman el diseño, implementación, y gestión de una arquitectura básica en AWS. Cada iteración te ha guiado a través de los pasos clave con explicaciones detalladas de qué, cómo, y por qué se realizan las tareas. Siguiendo este enfoque iterativo y detallado, estarás mejor preparado para construir arquitecturas más complejas y optimizadas en AWS.# modulo1-laboratorio-diseno-arquitectura-basica.md
