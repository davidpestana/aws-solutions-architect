# Laboratorio: Implementación de Alta Disponibilidad en AWS

## Introducción

Este laboratorio te guiará a través del proceso de creación de un entorno de alta disponibilidad en AWS, utilizando múltiples zonas de disponibilidad, Auto Scaling, Elastic Load Balancing (ELB), y una base de datos RDS con configuraciones Multi-AZ. Este entorno estará diseñado para manejar fallos sin interrupción del servicio, garantizando la continuidad del negocio.

## Objetivos

- Configurar un Auto Scaling Group para escalar automáticamente las instancias EC2.
- Implementar un Elastic Load Balancer para distribuir el tráfico entre instancias en múltiples zonas de disponibilidad.
- Configurar una base de datos RDS en múltiples zonas de disponibilidad (Multi-AZ).
- Probar la configuración mediante la simulación de fallos y la observación del comportamiento del sistema.

## Requisitos Previos

- Una cuenta de AWS con permisos administrativos.
- Familiaridad básica con servicios como EC2, RDS, ELB, y VPC.

## Iteración 1: Configuración de la VPC y Subnets

**Objetivo:** Crear una VPC personalizada y subnets que se utilizarán para alojar los recursos del laboratorio.

1. **Crear una VPC:**
   - En la consola de AWS, navega a **VPC** y selecciona "Create VPC".
   - Configura la VPC con un rango de CIDR de `10.0.0.0/16`.
   - Asigna un nombre a la VPC, por ejemplo, "VPC-AltaDisponibilidad".

2. **Crear Subnets en Múltiples Zonas de Disponibilidad:**
   - Dentro de la VPC, crea dos subnets públicas en diferentes zonas de disponibilidad (por ejemplo, `us-east-1a` y `us-east-1b`).
   - Asigna un rango de CIDR como `10.0.1.0/24` y `10.0.2.0/24` a las subnets.
   - Configura una tabla de rutas para permitir el acceso a Internet a través de una Gateway de Internet.

## Iteración 2: Lanzamiento de Instancias EC2 Base

**Objetivo:** Desplegar instancias EC2 en las subnets creadas y configurar un servidor web.

1. **Lanzar Instancias EC2 en Subnets Diferentes:**
   - Inicia dos instancias EC2, una en cada subnet creada. Utiliza Amazon Linux 2 como AMI y `t2.micro` como tipo de instancia.
   - Configura grupos de seguridad que permitan tráfico HTTP/HTTPS y SSH.
   - Asigna direcciones IP elásticas a ambas instancias para acceso público.

2. **Configurar un Servidor Web en Cada Instancia:**
   - Conéctate a cada instancia mediante SSH y ejecuta los siguientes comandos:
     ```bash
     sudo yum update -y
     sudo yum install -y httpd
     sudo systemctl start httpd
     sudo systemctl enable httpd
     echo "Bienvenido a la instancia EC2 en alta disponibilidad" | sudo tee /var/www/html/index.html
     ```

3. **Verificación:**
   - Accede a la dirección IP pública de ambas instancias desde un navegador para confirmar que el servidor web está activo.

## Iteración 3: Configuración de un Elastic Load Balancer (ELB)

**Objetivo:** Configurar un Elastic Load Balancer que distribuya el tráfico entre las instancias EC2 en múltiples zonas de disponibilidad.

1. **Crear un Load Balancer:**
   - En la consola de EC2, navega a **Load Balancers** y selecciona "Create Load Balancer".
   - Elige **Application Load Balancer (ALB)** y configúralo para operar en las dos subnets creadas.
   - Asigna un **Target Group** con las instancias EC2 lanzadas previamente.

2. **Configurar Listeners:**
   - Configura un listener en el puerto 80 para que el Load Balancer escuche las solicitudes HTTP.
   - Asocia el Target Group creado anteriormente al listener para enrutar el tráfico.

3. **Verificación:**
   - Obtén la URL del Load Balancer y accede a ella desde un navegador. Deberías ver el contenido del archivo `index.html` de una de las instancias EC2.

## Iteración 4: Configuración de un Auto Scaling Group

**Objetivo:** Configurar un Auto Scaling Group para ajustar dinámicamente el número de instancias EC2 en función de la carga.

1. **Crear una Launch Configuration:**
   - En la consola de EC2, navega a **Auto Scaling Groups** y selecciona "Create Auto Scaling group".
   - Crea una configuración de lanzamiento (Launch Configuration) utilizando la misma AMI y tipo de instancia (`t2.micro`) utilizados anteriormente.

2. **Crear el Auto Scaling Group:**
   - Define el tamaño inicial del grupo (por ejemplo, 2 instancias) y configúralo para que opere en las dos subnets.
   - Configura las políticas de escalado basadas en métricas como el uso promedio de CPU, usando AWS CloudWatch.

3. **Verificación:**
   - Monitorea el grupo de Auto Scaling para asegurarte de que las instancias se escalan correctamente según las políticas definidas.

## Iteración 5: Configuración de una Base de Datos RDS Multi-AZ

**Objetivo:** Configurar una base de datos relacional en RDS con capacidad de alta disponibilidad utilizando la opción Multi-AZ.

1. **Crear una Instancia RDS Multi-AZ:**
   - En la consola de RDS, selecciona "Create database" y elige MySQL o PostgreSQL como motor de base de datos.
   - Habilita la opción **Multi-AZ Deployment** para que la base de datos se replique automáticamente en una segunda zona de disponibilidad.
   - Completa la configuración de la base de datos (nombre, usuario, contraseña, etc.).

2. **Verificación:**
   - Utiliza la consola de RDS para verificar que la base de datos se está ejecutando en un entorno Multi-AZ.
   - Conéctate a la base de datos desde una de las instancias EC2 y verifica la conectividad.

## Iteración 6: Implementación de Réplicas de Lectura de RDS

**Objetivo:** Mejorar la disponibilidad y el rendimiento implementando réplicas de lectura en RDS.

1. **Crear una Réplica de Lectura:**
   - En la consola de RDS, selecciona la base de datos creada y elige "Create read replica".
   - Configura la réplica para que se despliegue en una zona de disponibilidad diferente a la de la base de datos principal.

2. **Verificación:**
   - Confirma que la réplica de lectura está activa y disponible.
   - Configura la aplicación web para dirigir las consultas de lectura a la réplica.

## Iteración 7: Configuración de Alarmas de Auto Scaling con CloudWatch

**Objetivo:** Configurar alarmas para monitorear y activar el escalado automático basado en métricas de rendimiento.

1. **Crear una Alarma en CloudWatch:**
   - En la consola de CloudWatch, navega a "Alarms" y selecciona "Create Alarm".
   - Configura una alarma para monitorear el uso de CPU de las instancias EC2.
   - Establece umbrales para activar el escalado automático (por ejemplo, si el uso de CPU excede el 70% durante 5 minutos).

2. **Asociar la Alarma al Auto Scaling Group:**
   - En la consola de EC2, edita las políticas del Auto Scaling Group para que respondan a las alarmas configuradas.

## Iteración 8: Pruebas de Alta Disponibilidad y Fallo Simulado

**Objetivo:** Validar la resiliencia del entorno simulando fallos y observando la respuesta del sistema.

1. **Simular la Caída de una Instancia EC2:**
   - Apaga manualmente una de las instancias EC2 desde la consola.
   - Observa cómo el Auto Scaling Group lanza automáticamente una nueva instancia para reemplazar la caída.

2. **Probar la Conmutación por Error en RDS:**
   - Forza la conmutación por error (failover) en la base de datos RDS desde la consola de RDS.
   - Verifica que la aplicación siga funcionando correctamente durante y después del failover.

## Iteración 9: Monitoreo del Entorno con CloudWatch

**Objetivo:** Configurar el monitoreo continuo del entorno para asegurar el rendimiento y la disponibilidad.

1. **Configurar Dashboards en CloudWatch:**
   - Crea un dashboard en CloudWatch que muestre las métricas clave de tus instancias EC2, RDS, y ELB.
   - Agrega gráficos que incluyan el uso de CPU, tráfico de red, y latencia de la base de datos.

2. **Configurar Alarmas Adicionales:**
   - Configura alarmas adicionales para notificarte si el tráfico de red cae a cero, lo que podría indicar un fallo en el ELB.

## Iteración 10: Limpieza y Revisión del Entorno

**Objetivo:** Finalizar el laboratorio limpiando los recursos y revisando lo aprendido.

1. **Eliminar Recursos No Necesarios:**
   - Desactiva el Auto Scaling Group, elimina las instancias EC2, y desactiva el ELB.
   - Elimina la base de datos RDS y sus réplicas.

2. **Revisión del Laboratorio:**
   - Revisa todos

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
