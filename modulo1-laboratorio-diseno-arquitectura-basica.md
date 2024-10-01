## Laboratorio: Diseño de Arquitectura Básica en AWS con Implementación de Software y Conexión RDS

### Introducción
Este laboratorio te guiará en el diseño y despliegue de una arquitectura básica en AWS. Implementarás una aplicación que interactúa con servicios de almacenamiento S3 y una base de datos relacional RDS. Además, aprenderás a configurar un servidor de salto utilizando una instancia EC2 para conectarte de manera segura a la base de datos desde un cliente local.

### Objetivos del Laboratorio
- Comprender y utilizar los componentes fundamentales de AWS.
- Diseñar una arquitectura básica en AWS utilizando EC2, S3, y RDS.
- Desplegar una aplicación que se conecta a RDS y almacena datos en S3.
- Conectar de manera segura a una base de datos RDS desde un cliente local usando un servidor de salto.

### Iteración 1: Configuración de la Cuenta de AWS y Preparación del Entorno

1. **Crear una cuenta de AWS:**
   - Regístrate en [aws.amazon.com](https://aws.amazon.com) y sigue el proceso de registro.
   - Configura tu cuenta con MFA (Multi-Factor Authentication).

2. **Configurar IAM:**
   - Crea un usuario IAM con permisos administrativos.
   - Activa MFA para este usuario.
   - Configura un grupo de usuarios con permisos específicos para evitar el uso de la cuenta raíz.

3. **Configurar la AWS CLI:**
   - Instala la AWS CLI en tu máquina local.
   - Configura la CLI usando el comando `aws configure` y proporciona las credenciales del usuario IAM.

4. **Establecer una política de etiquetas (Tags):**
   - Define una política de etiquetado para organizar y administrar los recursos en AWS.

### Iteración 2: Creación de una VPC

1. **Crear una nueva VPC:**
   - En la consola de AWS, navega a "VPC" y selecciona "Crear VPC".
   - Configura la VPC con un rango de direcciones CIDR de `10.0.0.0/16`.

2. **Configurar subredes:**
   - Crea una subred pública con CIDR `10.0.1.0/24`.
   - Crea una subred privada con CIDR `10.0.2.0/24`.

3. **Configurar una tabla de enrutamiento:**
   - Configura una tabla de enrutamiento para la subred pública y asocia una puerta de enlace de Internet.

4. **Asociar la tabla de enrutamiento:**
   - Asocia la tabla de enrutamiento con la subred pública.

### Iteración 3: Creación y Configuración de una Instancia EC2

1. **Lanzar una instancia EC2:**
   - En la consola de EC2, selecciona "Lanzar instancia".
   - Elige la AMI de Amazon Linux 2 y el tipo de instancia `t2.micro`.
   - Coloca la instancia en la subred pública.

2. **Configurar el grupo de seguridad:**
   - Crea un grupo de seguridad que permita tráfico SSH (puerto 22) desde tu IP y tráfico HTTP (puerto 80) desde cualquier IP.

3. **Asignar una IP elástica:**
   - Asigna una Elastic IP a la instancia EC2 para tener una dirección IP pública estática.

4. **Conectar a la instancia mediante SSH:**
   - Conéctate a la instancia usando SSH:
     ```bash
     ssh -i "tu-clave.pem" ec2-user@<Elastic-IP>
     ```

### Iteración 4: Configuración de un Servidor Web en EC2

1. **Actualizar el sistema operativo:**
   - Ejecuta:
     ```bash
     sudo yum update -y
     ```

2. **Instalar un servidor web (Apache):**
   - Instala Apache:
     ```bash
     sudo yum install httpd -y
     ```

3. **Iniciar y habilitar Apache:**
   - Inicia Apache y configúralo para que se ejecute en cada arranque:
     ```bash
     sudo systemctl start httpd
     sudo systemctl enable httpd
     ```

4. **Verificar la instalación:**
   - Accede a la IP elástica en un navegador. Deberías ver la página de bienvenida de Apache.

### Iteración 5: Configuración de Almacenamiento S3

1. **Crear un bucket S3:**
   - Navega a S3 en la consola de AWS y crea un nuevo bucket con un nombre único.

2. **Configurar permisos del bucket:**
   - Asegúrate de que el bucket sea privado por defecto.

3. **Subir archivos al bucket:**
   - Sube archivos estáticos (imágenes, documentos) al bucket.

4. **Habilitar el versionado:**
   - Activa el versionado para el bucket.

5. **Configurar una política de ciclo de vida:**
   - Configura una política para mover archivos a S3 Glacier después de 30 días.

### Iteración 6: Configuración de una Base de Datos Relacional con RDS

1. **Crear una instancia de RDS:**
   - Desde la consola de RDS, crea una base de datos utilizando MySQL.
   - Coloca la instancia en la subred privada.

2. **Configurar la base de datos en la subred privada:**
   - Asegúrate de que la instancia RDS esté inaccesible desde internet.

3. **Configurar grupos de seguridad:**
   - Configura el grupo de seguridad para permitir acceso solo desde la instancia EC2.

4. **Conectar la instancia EC2 a la base de datos:**
   - Desde la instancia EC2, instala un cliente MySQL:
     ```bash
     sudo yum install mysql -y
     ```
   - Conéctate a la base de datos:
     ```bash
     mysql -h <RDS-Endpoint> -u <username> -p
     ```

### Iteración 7: Conectar a la RDS desde un Cliente Local Usando EC2 como Servidor de Salto

1. **Configurar el túnel SSH:**
   - Desde tu máquina local, configura un túnel SSH para redirigir el tráfico al RDS a través de la instancia EC2:
     ```bash
     ssh -i "tu-clave.pem" -L 3306:<RDS-Endpoint>:3306 ec2-user@<Elastic-IP>
     ```

2. **Conectar a la base de datos desde el cliente local:**
   - Usa un cliente MySQL local para conectarte al RDS a través del túnel SSH:
     ```bash
     mysql -h 127.0.0.1 -P 3306 -u <username> -p
     ```

### Iteración 8: Implementación de la Aplicación

1. **Clonar la aplicación en EC2:**
   - Clona tu aplicación desde GitHub (o sube el código) en la instancia EC2:
     ```bash
     git clone <tu-repositorio>
     cd <nombre-del-repositorio>
     ```
   > si no tienes un repo de ejemplo puedes crear uno siguiendo esta estructura
   [proyecto python](./proyecto-python.md)

2. **Instalar dependencias:**
   - Instala las dependencias necesarias (por ejemplo, si es una aplicación Python):
     ```bash
     sudo yum install python3 -y
     pip3 install -r requirements.txt
     ```

3. **Configurar la conexión a S3 y RDS:**
   - En tu aplicación, utiliza el SDK de AWS para Python (`boto3`) o el lenguaje de tu elección, para interactuar con S3 y RDS. Aquí un ejemplo en Python:
     ```python
     import boto3
     import pymysql

     # Conexión a S3
     s3 = boto3.client('s3')
     s3.upload_file('local_file.txt', 'your-bucket-name', 's3_file.txt')

     # Conexión a RDS
     connection = pymysql.connect(
         host='rds-endpoint',
         user='username',
         password='password',
         db='database_name'
     )
     ```

4. **Ejecutar la aplicación:**
   - Ejecuta tu aplicación en la instancia EC2 y verifica que se conecta correctamente a S3 y RDS.

### Iteración 9: Implementación de Seguridad Adicional

1. **Habilitar CloudTrail:**
   - Activa AWS CloudTrail para registrar todas las acciones en la cuenta de AWS.

2. **Configurar políticas de IAM:**
   - Ajusta las políticas de IAM para limitar los permisos solo a lo necesario.

3. **Configurar claves KMS para cifrado:**
   - Usa AWS KMS para cifrar datos en S3 y RDS.

4. **Revisar las reglas de los grupos de seguridad:**
   - Asegúrate de que solo los puertos necesarios estén abiertos.

5. **Configurar AWS Config:**
   - Activa AWS Config para monitorear los cambios en la configuración de los recursos.

### Iteración 10: Implementación de Monitorización y Alertas

1. **Configurar métricas de CloudWatch:**
   - Monitoriza el uso de CPU, memoria y red en EC2 y RDS.

2. **Crear alarmas en CloudWatch:**
   - Configura alarmas para notificar sobre métricas críticas.

3. **Monitorear los logs de Apache:**
   - Configura CloudWatch Logs para recopilar y almacenar los registros de Apache.

4. **

Implementar dashboards en CloudWatch:**
   - Crea un dashboard en CloudWatch que muestre todas las métricas clave.

### Iteración 11: Optimización de Costos

1. **Revisar el uso de EC2:**
   - Analiza el uso de la instancia y considera el uso de instancias reservadas.

2. **Configurar el ciclo de vida de los datos en S3:**
   - Mueve datos inactivos a S3 Glacier.

3. **Revisar el uso de EBS:**
   - Libera o reduce el tamaño de volúmenes subutilizados.

4. **Implementar AWS Budgets:**
   - Configura alertas de presupuestos para evitar sorpresas en la factura.

5. **Optimizar la base de datos RDS:**
   - Ajusta el tamaño de la instancia de RDS si es necesario.

### Iteración 12: Pruebas y Mejora Continua

1. **Prueba de Resiliencia:**
   - Simula fallos de zona de disponibilidad para verificar la resiliencia.

2. **Pruebas de carga:**
   - Usa herramientas como Apache JMeter para simular tráfico y medir el rendimiento.

3. **Pruebas de seguridad:**
   - Realiza pruebas de penetración y análisis de vulnerabilidades.

4. **Documentar la Arquitectura:**
   - Crea una documentación detallada de la arquitectura y flujos de trabajo.

5. **Revisión y mejora continua:**
   - Establece un ciclo regular de revisiones y mejoras en la arquitectura.

### Conclusión
Este laboratorio te ha guiado a través del diseño, implementación y gestión de una arquitectura básica en AWS, con énfasis en la seguridad, la escalabilidad, y la optimización de costos. Has desplegado una aplicación, configurado un entorno seguro y conectado a servicios de AWS, preparándote para manejar arquitecturas más complejas en el futuro.
