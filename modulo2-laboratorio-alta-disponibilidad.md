# Laboratorio: Implementación de Alta Disponibilidad en AWS

## Introducción

Este laboratorio práctico está diseñado para guiarte en la creación de una arquitectura de alta disponibilidad en AWS. Utilizarás una combinación de servicios de AWS, como Elastic Load Balancing (ELB), Auto Scaling, y Amazon RDS con configuración Multi-AZ, para construir un entorno que puede resistir fallos de componentes sin interrumpir el servicio.

## Objetivos

- Configurar un Auto Scaling Group para escalar automáticamente las instancias EC2.
- Implementar un Elastic Load Balancer para distribuir el tráfico entre instancias en múltiples zonas de disponibilidad.
- Configurar una base de datos RDS en múltiples zonas de disponibilidad (Multi-AZ) para alta disponibilidad.
- Simular fallos y observar cómo el entorno responde para mantener la disponibilidad.

## Requisitos Previos

- Cuenta de AWS con permisos suficientes para crear y gestionar recursos como EC2, Auto Scaling, ELB, y RDS.
- Familiaridad básica con servicios de AWS, como EC2, RDS, y VPC.

## Iteración 1: Configuración de la VPC y Subnets

**Objetivo:** Crear una VPC personalizada y subnets en múltiples zonas de disponibilidad.

1. **Crear una VPC:**
   - Inicia sesión en la consola de AWS y navega a **VPC**.
   - Crea una nueva VPC con un rango de CIDR de `10.0.0.0/16`.
   - Asigna un nombre a la VPC, como "VPC-AltaDisponibilidad".

2. **Crear Subnets:**
   - Crea dos subnets públicas en diferentes zonas de disponibilidad (por ejemplo, `us-east-1a` y `us-east-1b`).
   - Configura una tabla de rutas asociada a una Gateway de Internet para permitir el tráfico a la Internet.

3. **Configurar un Internet Gateway:**
   - Crea un Internet Gateway y asígnalo a la VPC.
   - Configura la tabla de rutas para que el tráfico de las subnets se enrute a la Internet a través de este gateway.

## Iteración 2: Lanzamiento de Instancias EC2 Base

**Objetivo:** Desplegar instancias EC2 en las subnets creadas y configurar un servidor web básico.

1. **Lanzar Instancias EC2:**
   - Usa la consola de EC2 para lanzar dos instancias, una en cada subnet.
   - Selecciona Amazon Linux 2 como AMI y `t2.micro` como tipo de instancia.

2. **Configurar Seguridad:**
   - Configura un grupo de seguridad que permita tráfico HTTP (puerto 80) y SSH (puerto 22).
   - Asigna una dirección IP elástica a cada instancia para acceso externo.

3. **Configurar Servidor Web:**
   - Conéctate a cada instancia mediante SSH y configura Apache:
     ```bash
     sudo yum update -y
     sudo yum install -y httpd
     sudo systemctl start httpd
     sudo systemctl enable httpd
     echo "Bienvenido a mi sitio web de alta disponibilidad" | sudo tee /var/www/html/index.html
     ```

4. **Verificación:**
   - Accede a las direcciones IP públicas de ambas instancias desde un navegador para confirmar que el servidor web está activo.

## Iteración 3: Configuración de un Elastic Load Balancer (ELB)

**Objetivo:** Implementar un Elastic Load Balancer para distribuir el tráfico entre las instancias EC2.

1. **Crear un Load Balancer:**
   - En la consola de EC2, selecciona **Load Balancers** y elige "Create Load Balancer".
   - Selecciona **Application Load Balancer (ALB)**, configurando las subnets en diferentes zonas de disponibilidad.

2. **Configurar Listeners:**
   - Configura un listener en el puerto 80 para que el Load Balancer escuche solicitudes HTTP.
   - Asocia un Target Group con las instancias EC2 creadas.

3. **Verificación:**
   - Obtén la URL del Load Balancer y accede a ella desde un navegador. Deberías ver el mensaje del archivo `index.html`.

## Iteración 4: Configuración de un Auto Scaling Group

**Objetivo:** Crear un Auto Scaling Group que ajuste el número de instancias EC2 según la demanda.

1. **Crear una Launch Configuration:**
   - En la consola de EC2, crea una configuración de lanzamiento con la misma AMI y tipo de instancia (`t2.micro`).

2. **Crear el Auto Scaling Group:**
   - Define el tamaño inicial (2 instancias) y configura las subnets para que las instancias se distribuyan entre las dos zonas de disponibilidad.
   - Configura políticas de escalado basadas en métricas como el uso de CPU.

3. **Verificación:**
   - Monitorea el Auto Scaling Group y observa cómo las instancias se escalan según las políticas definidas.

## Iteración 5: Configuración de una Base de Datos RDS Multi-AZ

**Objetivo:** Implementar una base de datos RDS con Multi-AZ para garantizar alta disponibilidad.

1. **Crear una Instancia RDS Multi-AZ:**
   - En la consola de RDS, selecciona "Create database" y elige MySQL.
   - Habilita la opción **Multi-AZ Deployment** para asegurar la replicación en múltiples zonas de disponibilidad.

2. **Verificación:**
   - Conéctate a la base de datos desde una de las instancias EC2 y verifica que la base de datos esté accesible.

## Iteración 6: Implementación de Réplicas de Lectura de RDS

**Objetivo:** Mejorar el rendimiento y la disponibilidad mediante la implementación de réplicas de lectura.

1. **Crear una Réplica de Lectura:**
   - En la consola de RDS, selecciona "Create read replica" para la base de datos existente.
   - Configura la réplica en una zona de disponibilidad diferente.

2. **Verificación:**
   - Configura tu aplicación para utilizar la réplica de lectura para operaciones de solo lectura y verifica que esté funcionando correctamente.

## Iteración 7: Configuración de Alarmas de Auto Scaling con CloudWatch

**Objetivo:** Configurar alarmas que activen el escalado automático basado en métricas de rendimiento.

1. **Crear una Alarma en CloudWatch:**
   - En la consola de CloudWatch, crea una alarma que monitoree el uso de CPU de las instancias.
   - Configura un umbral para activar el escalado si el uso de CPU supera el 70% durante un período de tiempo.

2. **Asociar la Alarma al Auto Scaling Group:**
   - Configura el Auto Scaling Group para que responda a la alarma configurada, aumentando o disminuyendo el número de instancias según sea necesario.

## Iteración 8: Pruebas de Alta Disponibilidad y Fallo Simulado

**Objetivo:** Validar la resiliencia del entorno simulando fallos y observando cómo se mantiene la disponibilidad.

1. **Simular la Caída de una Instancia EC2:**
   - Apaga una de las instancias EC2 desde la consola de EC2.
   - Verifica cómo el Auto Scaling Group lanza automáticamente una nueva instancia para reemplazarla.

2. **Simular Fallo en RDS y Observación del Failover:**
   - En la consola de RDS, forza un failover de la base de datos.
   - Observa cómo la base de datos secundaria toma el control sin interrupción significativa en el servicio.

## Iteración 9: Monitoreo del Entorno con CloudWatch

**Objetivo:** Monitorear la salud y el rendimiento del entorno utilizando Amazon CloudWatch.

1. **Configurar un Dashboard en CloudWatch:**
   - Crea un dashboard en CloudWatch que muestre las métricas clave de tus instancias EC2, ELB, y RDS.
   - Añade gráficos para monitorear el uso de CPU, latencia del ELB, y tiempo de respuesta de la base de datos.

2. **Configurar Notificaciones de Alarma:**
   - Configura notificaciones para recibir alertas cuando las métricas clave superen los umbrales definidos.

## Iteración 10: Limpieza y Revisión del Entorno

**Objetivo:** Desactivar y eliminar los recursos utilizados en el laboratorio, y revisar lo aprendido.

1. **Eliminar Recursos No Necesarios:**
   - Desactiva el Auto Scaling Group, elimina las instancias EC2, y elimina el ELB.
   - Elimina la base de datos RDS y sus réplicas.

2. **Revisión del Laboratorio:**
   - Revisa los conceptos y técnicas aplicadas durante el laboratorio, asegurando que comprendes cómo se implementó la alta disponibilidad en AWS.

---

Este laboratorio te proporciona una experiencia práctica en la implementación de alta disponibilidad en AWS, utilizando servicios clave como EC2, ELB, Auto Scaling, y RDS. Al seguir estas iteraciones, habrás creado un entorno robusto capaz de manejar fallos y escalar dinámicamente según la demanda.
