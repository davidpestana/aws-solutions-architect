### Laboratorio: Configuración de Seguridad Multinivel en AWS

#### Objetivo

El objetivo de este laboratorio es guiarte a través de la configuración de una arquitectura de seguridad multinivel en AWS, protegiendo diferentes capas de tu infraestructura en la nube. Implementarás múltiples niveles de seguridad, incluyendo controles a nivel de red, acceso de usuarios, y monitoreo continuo, utilizando servicios como **Amazon VPC**, **IAM**, **Security Groups**, **Network ACLs**, y **VPC Flow Logs**.

#### Requisitos Previos

- Cuenta de AWS con permisos para crear y gestionar recursos como VPC, EC2, IAM, y CloudWatch.
- Familiaridad básica con los conceptos de red y seguridad en AWS.

#### Arquitectura de la Solución

La arquitectura de seguridad multinivel consistirá en:

1. **VPC con Subredes Públicas y Privadas**: Configuración de una VPC con subredes que permitan la segmentación de recursos y la aplicación de reglas de seguridad específicas.
2. **Security Groups y Network ACLs**: Implementación de firewalls a nivel de instancia y subred para controlar el tráfico entrante y saliente.
3. **VPC Flow Logs y CloudWatch**: Configuración de logs de flujo y monitoreo para supervisar el tráfico de red y detectar anomalías.

#### Iteración 1: Configuración de la VPC con Subredes

1. **Creación de la VPC:**
   - En la consola de **Amazon VPC**, crea una nueva VPC. Asigna un bloque CIDR, por ejemplo, `10.0.0.0/16`.
   - Crea dos subredes en diferentes zonas de disponibilidad (AZs). Una subred será pública (por ejemplo, `10.0.1.0/24`) y la otra será privada (`10.0.2.0/24`).

2. **Configuración de Internet Gateway y NAT Gateway:**
   - Asocia un **Internet Gateway (IGW)** con la VPC para proporcionar acceso a Internet a las instancias en la subred pública.
   - Configura un **NAT Gateway** en la subred pública para que las instancias en la subred privada puedan acceder a Internet para actualizaciones, sin ser accesibles desde Internet.

3. **Configuración de Route Tables:**
   - Crea y asocia una tabla de rutas para la subred pública que dirija el tráfico hacia el IGW.
   - Configura la tabla de rutas de la subred privada para dirigir el tráfico hacia el NAT Gateway.

#### Iteración 2: Configuración de Security Groups y Network ACLs

1. **Configuración de Security Groups:**
   - Crea un **Security Group (SG)** para las instancias en la subred pública que permita tráfico HTTP/HTTPS entrante desde cualquier lugar (`0.0.0.0/0`) y tráfico SSH solo desde direcciones IP específicas (por ejemplo, la IP de tu oficina).
   - Crea otro SG para las instancias en la subred privada que solo permita tráfico entrante desde la subred pública, bloqueando cualquier acceso directo desde Internet.

2. **Configuración de Network ACLs:**
   - Configura **Network ACLs (NACLs)** para la subred pública que permitan tráfico entrante HTTP/HTTPS y denieguen otros tipos de tráfico.
   - Configura las NACLs de la subred privada para que solo permitan el tráfico proveniente de la subred pública y bloqueen todo el tráfico no autorizado.

#### Iteración 3: Configuración de Roles y Políticas de IAM

1. **Creación de Roles IAM:**
   - Crea un rol IAM que permita a las instancias EC2 en la subred privada acceder a **Amazon S3** y **DynamoDB** para almacenar y recuperar datos.
   - Asocia el rol IAM con las instancias al momento de su creación, asegurando que puedan interactuar con otros servicios de AWS sin necesidad de credenciales de usuario.

2. **Implementación de Políticas IAM:**
   - Define políticas de IAM que restrinjan el acceso a recursos críticos a usuarios o grupos específicos. Por ejemplo, una política que permita a los desarrolladores acceder solo a los recursos en la subred de desarrollo, pero no a los recursos en la subred de producción.

#### Iteración 4: Configuración de Monitoreo con VPC Flow Logs y CloudWatch

1. **Habilitación de VPC Flow Logs:**
   - Habilita **VPC Flow Logs** para capturar el tráfico que entra y sale de las interfaces de red en la VPC.
   - Configura los logs para que se almacenen en **Amazon CloudWatch** o en un bucket de **S3** para su análisis posterior.

2. **Configuración de Alarms en CloudWatch:**
   - Configura **CloudWatch Alarms** para monitorear el tráfico inusual o los intentos de acceso no autorizados a través de los VPC Flow Logs.
   - Establece alarmas que envíen notificaciones cuando se detecten actividades sospechosas, como intentos repetidos de acceso fallidos o tráfico desde IPs desconocidas.

#### Iteración 5: Revisión y Auditoría de Seguridad

1. **Revisión de Configuraciones de Seguridad:**
   - Revisa todas las configuraciones de seguridad, incluyendo los Security Groups, NACLs, y las políticas de IAM, para asegurarte de que cumplen con las mejores prácticas y las políticas de seguridad de la organización.

2. **Auditoría de Acceso y Logs:**
   - Utiliza **AWS Config** y **AWS CloudTrail** para auditar los cambios en la configuración y revisar el acceso a los recursos en la VPC.
   - Analiza los logs recolectados para identificar posibles vulnerabilidades o brechas de seguridad, y toma acciones correctivas si es necesario.

#### Conclusión

Este laboratorio te ha guiado a través de la configuración de una arquitectura de seguridad multinivel en AWS, utilizando VPC, Security Groups, NACLs, IAM, y VPC Flow Logs. La implementación de estos controles en diferentes niveles de la infraestructura te permite crear un entorno seguro y resiliente, protegiendo tanto la red como los recursos de AWS contra accesos no autorizados y amenazas externas. Con estos conocimientos, ahora estás mejor preparado para diseñar y mantener arquitecturas seguras en AWS que cumplan con los requisitos de seguridad de tu organización.
