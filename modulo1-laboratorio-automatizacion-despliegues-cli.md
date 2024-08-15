# Laboratorio: Automatización de Despliegues con AWS CLI

## Introducción

Este laboratorio está diseñado para enseñarte cómo automatizar el despliegue de aplicaciones en AWS utilizando AWS Command Line Interface (CLI). Aprenderás a crear y configurar recursos de AWS como EC2, S3, y RDS, y luego automatizar el proceso de despliegue de una aplicación web mediante scripts en Bash.

## Objetivos del Laboratorio

- Configurar y lanzar instancias EC2 utilizando AWS CLI.
- Desplegar una aplicación web en EC2 de manera automatizada.
- Configurar y utilizar S3 para almacenar archivos estáticos.
- Automatizar la configuración de una base de datos RDS y conectar la aplicación web.

## Requisitos Previos

Antes de comenzar, asegúrate de tener lo siguiente:

- **Cuenta de AWS** con permisos para crear y gestionar recursos.
- **AWS CLI** instalado y configurado en tu máquina local.
- **Conocimientos básicos de Bash scripting** y administración de servidores Linux.

## Iteración 1: Configuración Inicial y Lanzamiento de EC2

**Objetivo:** Lanzar una instancia EC2 y preparar el entorno para el despliegue.

### Paso 1.1: Lanzamiento de una Instancia EC2

1. **Crear una instancia EC2 utilizando AWS CLI:**

   ```bash
   aws ec2 run-instances \
       --image-id ami-0abcdef1234567890 \  # Reemplaza con un AMI ID válido en tu región
       --instance-type t2.micro \
       --key-name MiClaveSSH \
       --security-groups MiGrupoSeguridad \
       --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MiServidorWeb}]'
   ```

2. **Obtener el ID de la instancia recién creada:**

   ```bash
   INSTANCE_ID=$(aws ec2 describe-instances \
       --filters "Name=instance-state-name,Values=pending,running" \
       --query "Reservations[*].Instances[*].InstanceId" --output text)
   echo "Instance ID: $INSTANCE_ID"
   ```

3. **Esperar hasta que la instancia esté en estado "running":**

   ```bash
   aws ec2 wait instance-running --instance-ids $INSTANCE_ID
   ```

4. **Asociar una dirección IP elástica (opcional):**

   ```bash
   ALLOCATION_ID=$(aws ec2 allocate-address --query 'AllocationId' --output text)
   aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $ALLOCATION_ID
   ```

### Paso 1.2: Configuración del Servidor Web

1. **Conectarse a la instancia EC2 vía SSH:**

   ```bash
   ssh -i MiClaveSSH.pem ec2-user@<IP-PUBLICA>
   ```

2. **Instalar y configurar un servidor web (por ejemplo, Apache):**

   ```bash
   sudo yum update -y
   sudo yum install -y httpd
   sudo systemctl start httpd
   sudo systemctl enable httpd
   ```

3. **Verificar que el servidor web está funcionando:**

   Abre un navegador y navega a la dirección IP pública de la instancia para ver la página de bienvenida de Apache.

## Iteración 2: Automatización del Despliegue de la Aplicación

**Objetivo:** Automatizar la implementación de una aplicación web en la instancia EC2.

### Paso 2.1: Despliegue de Archivos de la Aplicación

1. **Crear un script de despliegue en Bash:**

   ```bash
   #!/bin/bash
   APP_DIR="/var/www/html"

   # Descargar los archivos de la aplicación desde un repositorio o S3
   wget https://mi-repositorio.com/mis-archivos-app.zip -O /tmp/app.zip

   # Extraer y mover los archivos al directorio web
   sudo unzip /tmp/app.zip -d $APP_DIR
   sudo chown -R ec2-user:ec2-user $APP_DIR

   # Reiniciar el servidor web
   sudo systemctl restart httpd
   ```

2. **Ejecutar el script en la instancia EC2:**

   ```bash
   scp -i MiClaveSSH.pem deploy.sh ec2-user@<IP-PUBLICA>:/home/ec2-user/
   ssh -i MiClaveSSH.pem ec2-user@<IP-PUBLICA> 'bash /home/ec2-user/deploy.sh'
   ```

### Paso 2.2: Configuración de Variables de Entorno

1. **Configurar las variables de entorno necesarias para la aplicación:**

   ```bash
   echo "export DB_HOST='mi-bd-instance.xxxxxxxxx.us-west-2.rds.amazonaws.com'" | sudo tee -a /etc/profile
   echo "export DB_USER='admin'" | sudo tee -a /etc/profile
   echo "export DB_PASS='password123'" | sudo tee -a /etc/profile
   ```

2. **Cargar las variables de entorno:**

   ```bash
   source /etc/profile
   ```

## Iteración 3: Configuración y Conexión con RDS

**Objetivo:** Configurar una base de datos RDS y conectar la aplicación.

### Paso 3.1: Creación de la Instancia RDS

1. **Crear una instancia RDS con AWS CLI:**

   ```bash
   aws rds create-db-instance \
       --db-instance-identifier MiBaseDeDatos \
       --db-instance-class db.t2.micro \
       --engine mysql \
       --allocated-storage 20 \
       --master-username admin \
       --master-user-password password123 \
       --vpc-security-group-ids MiGrupoSeguridad \
       --backup-retention-period 7
   ```

2. **Esperar a que la instancia esté disponible:**

   ```bash
   aws rds wait db-instance-available --db-instance-identifier MiBaseDeDatos
   ```

3. **Obtener el endpoint de la base de datos:**

   ```bash
   DB_ENDPOINT=$(aws rds describe-db-instances \
       --db-instance-identifier MiBaseDeDatos \
       --query "DBInstances[0].Endpoint.Address" --output text)
   echo "RDS Endpoint: $DB_ENDPOINT"
   ```

### Paso 3.2: Configuración de la Aplicación para Conectarse a RDS

1. **Actualizar las variables de entorno con el endpoint de RDS:**

   ```bash
   echo "export DB_HOST='$DB_ENDPOINT'" | sudo tee -a /etc/profile
   source /etc/profile
   ```

2. **Configurar la aplicación para utilizar la base de datos:**
   - Modifica los archivos de configuración de la aplicación para que utilicen el `DB_HOST`, `DB_USER`, y `DB_PASS` configurados anteriormente.

3. **Probar la conexión a la base de datos desde la aplicación:**
   - Verifica que la aplicación puede conectarse y realizar operaciones con la base de datos RDS.

## Iteración 4: Almacenamiento de Archivos Estáticos en S3

**Objetivo:** Utilizar Amazon S3 para almacenar y servir archivos estáticos.

### Paso 4.1: Creación de un Bucket S3

1. **Crear un bucket S3:**

   ```bash
   aws s3 mb s3://mi-bucket-estatico
   ```

2. **Configurar el bucket para servir contenido estático:**

   ```bash
   aws s3 website s3://mi-bucket-estatico/ --index-document index.html
   ```

### Paso 4.2: Subida de Archivos Estáticos a S3

1. **Subir archivos estáticos al bucket S3:**

   ```bash
   aws s3 sync /var/www/html/static s3://mi-bucket-estatico
   ```

2. **Actualizar la aplicación para servir archivos estáticos desde S3:**
   - Modifica las rutas de los archivos estáticos en la aplicación para que apunten al bucket S3.

## Conclusión

Este laboratorio te ha guiado a través del proceso de automatización de despliegues en AWS utilizando AWS CLI. Aprendiste a configurar y lanzar instancias EC2, desplegar una aplicación web, configurar una base de datos RDS y utilizar S3 para almacenar archivos estáticos. Al dominar estas técnicas, puedes automatizar de manera efectiva la gestión y despliegue de aplicaciones en la nube, mejorando la eficiencia y reduciendo errores manuales.
