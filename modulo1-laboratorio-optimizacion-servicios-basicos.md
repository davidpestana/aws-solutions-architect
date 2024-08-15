# Laboratorio Completo: Provisión y Optimización de Servicios Básicos en AWS

## Introducción

Este laboratorio está diseñado para guiarte a través de la creación de un entorno básico en AWS, seguido por la optimización de los recursos configurados, tales como EC2, S3, RDS, y la red en una VPC. Comenzaremos configurando los recursos utilizando una plantilla de AWS CloudFormation y luego procederemos a realizar ajustes y optimizaciones para mejorar el rendimiento, reducir costos y asegurar la eficiencia.

### Objetivos del Laboratorio

- Provisión automatizada de recursos utilizando AWS CloudFormation.
- Optimización de instancias EC2, almacenamiento en S3, y bases de datos RDS.
- Implementación de seguridad y monitoreo para mantener un entorno eficiente y seguro.
- Comprensión del proceso de revisión y ajuste continuo en un entorno AWS.

## Requisitos Previos

Antes de comenzar este laboratorio, asegúrate de tener lo siguiente:

- **Una cuenta de AWS activa.**
- **Permisos administrativos en la cuenta de AWS** para crear y gestionar recursos (VPC, EC2, S3, RDS, etc.).
- **Conocimientos básicos de AWS CLI y consola de AWS.**
- **Un cliente SSH** (como PuTTY en Windows o la terminal en macOS/Linux) para acceder a las instancias EC2.

## Iteración 1: Provisión de Recursos con AWS CloudFormation

### Paso 1.1: Creación de la Plantilla de CloudFormation

Dado que no hay un enlace directo para descargar la plantilla, te proporciono el código de la plantilla CloudFormation a continuación. Deberás copiar este código en un archivo YAML y luego usarlo en AWS CloudFormation para crear los recursos necesarios.

#### Código de la Plantilla de CloudFormation

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Entorno Básico en AWS con EC2, S3, RDS, y VPC'

Parameters:
  KeyName:
    Description: Nombre de la clave SSH para acceso a las instancias EC2
    Type: String

Resources:
  MyVPC:
    Type: 'AWS::EC2::VPC'
    Properties:
      CidrBlock: '10.0.0.0/16'
      EnableDnsSupport: 'true'
      EnableDnsHostnames: 'true'
      Tags:
        - Key: Name
          Value: MyVPC

  PublicSubnet:
    Type: 'AWS::EC2::Subnet'
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: '10.0.1.0/24'
      MapPublicIpOnLaunch: true
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      Tags:
        - Key: Name
          Value: PublicSubnet

  PrivateSubnet:
    Type: 'AWS::EC2::Subnet'
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: '10.0.2.0/24'
      AvailabilityZone: !Select [ 1, !GetAZs '' ]
      Tags:
        - Key: Name
          Value: PrivateSubnet

  InternetGateway:
    Type: 'AWS::EC2::InternetGateway'
    Properties:
      Tags:
        - Key: Name
          Value: MyIGW

  AttachGateway:
    Type: 'AWS::EC2::VPCGatewayAttachment'
    Properties:
      VpcId: !Ref MyVPC
      InternetGatewayId: !Ref InternetGateway

  PublicRouteTable:
    Type: 'AWS::EC2::RouteTable'
    Properties:
      VpcId: !Ref MyVPC
      Tags:
        - Key: Name
          Value: PublicRouteTable

  PublicRoute:
    Type: 'AWS::EC2::Route'
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: '0.0.0.0/0'
      GatewayId: !Ref InternetGateway

  PublicSubnetRouteTableAssociation:
    Type: 'AWS::EC2::SubnetRouteTableAssociation'
    Properties:
      SubnetId: !Ref PublicSubnet
      RouteTableId: !Ref PublicRouteTable

  EC2Instance:
    Type: 'AWS::EC2::Instance'
    Properties:
      InstanceType: t2.micro
      KeyName: !Ref KeyName
      SubnetId: !Ref PublicSubnet
      ImageId: ami-0abcdef1234567890 # Reemplaza con un AMI ID válido en tu región
      Tags:
        - Key: Name
          Value: MyEC2Instance
      SecurityGroups: [!Ref InstanceSecurityGroup]

  InstanceSecurityGroup:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      GroupDescription: Enable SSH and HTTP access
      VpcId: !Ref MyVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: '22'
          ToPort: '22'
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: '80'
          ToPort: '80'
          CidrIp: 0.0.0.0/0

  MyBucket:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketName: !Sub "${AWS::StackName}-bucket"

  MyRDSInstance:
    Type: 'AWS::RDS::DBInstance'
    Properties:
      DBInstanceClass: db.t2.micro
      Engine: MySQL
      AllocatedStorage: '20'
      DBName: MyDatabase
      MasterUsername: admin
      MasterUserPassword: password123
      VPCSecurityGroups: [!Ref InstanceSecurityGroup]
      DBSubnetGroupName: !Ref MyDBSubnetGroup

  MyDBSubnetGroup:
    Type: 'AWS::RDS::DBSubnetGroup'
    Properties:
      DBSubnetGroupDescription: My DB Subnet Group
      SubnetIds:
        - !Ref PrivateSubnet
```

### Paso 1.2: Crear el Stack de CloudFormation

1. **Guardar el archivo:** Guarda el código anterior en un archivo llamado `entorno-basico.yml`.

2. **Iniciar sesión en la consola de AWS:**
   - Ve a [AWS Console](https://aws.amazon.com/).

3. **Navegar a AWS CloudFormation:**
   - En el servicio de AWS, selecciona "CloudFormation".

4. **Crear un nuevo stack:**
   - Selecciona "Create Stack" y luego "With new resources (standard)".
   - Carga el archivo `entorno-basico.yml`.
   - Asigna un nombre al stack, como `entorno-optimizacion`.
   - Completa los parámetros, como el nombre de la clave SSH (`KeyName`), que se utilizará para acceder a las instancias EC2.

5. **Revisar y crear el stack:**
   - Revisa la configuración y selecciona "Create Stack".
   - Espera a que CloudFormation cree los recursos (esto puede tardar varios minutos).

### Paso 1.3: Verificar los Recursos Creado

1. **VPC:** Verifica que la VPC y las subredes públicas y privadas se hayan creado correctamente en la consola de VPC.

2. **EC2:** Verifica que la instancia EC2 esté corriendo y accesible vía SSH.

3. **S3:** Verifica que el bucket S3 se haya creado correctamente en la consola de S3.

4. **RDS:** Verifica que la instancia de RDS esté activa en la consola de RDS.

5. **ELB (opcional):** Si se configuró, verifica que el ELB esté correctamente asociado con la instancia EC2.

## Iteración 2: Configuración de Acceso y Preparación del Entorno

**Objetivo:** Asegurarse de que los usuarios puedan acceder a los recursos creados y preparar el entorno para las tareas de optimización.

### Paso 2.1: Configurar Accesos IAM

1. **Crear usuarios IAM:**
   - En la consola de IAM, crea un usuario para cada alumno.
   - Asigna permisos para acceder a los recursos creados (EC2, S3, RDS, VPC).
   - Habilita MFA para mayor seguridad.

2. **Proporcionar credenciales:**
   - Proporciona a cada alumno las credenciales de acceso (Access Key ID, Secret Access Key) junto con instrucciones para configurar AWS CLI.

3. **Configurar acceso SSH:**
   - Cada alumno debe configurar su cliente SSH (PuTTY, terminal) para conectarse a la instancia EC2 utilizando la clave SSH configurada durante la creación del stack.

### Paso 2.2: Preparar el Entorno de Trabajo

1. **Cargar datos de prueba en S3:**
   - Navega a la consola de S3 y carga archivos de prueba en el bucket creado.

2. **Configurar bases de datos de ejemplo en RDS:**
   - Conéctate a la instancia RDS utilizando un cliente MySQL o PostgreSQL y crea algunas tablas de prueba con datos ficticios.

## Iteración 3: Optimización de Instancias EC2

**Objetivo:** Ajustar las configuraciones de las instancias EC2 para mejorar el rendimiento y reducir costos.

### Paso 3.1: Análisis del Uso Actual de EC2

1. **Monitorizar el uso de CPU y memoria:**
   - Utiliza AWS CloudWatch para revisar las métricas actuales de las instancias EC2.
   - Identifica instancias

 sobredimensionadas o infrautilizadas.

### Paso 3.2: Redimensionar Instancias EC2

1. **Redimensionar instancias si es necesario:**
   - Desde la consola de EC2, selecciona la instancia y elige "Change Instance Type" para ajustar a un tipo más adecuado.
   - Reinicia la instancia después del cambio.

### Paso 3.3: Configurar Auto Scaling

1. **Crear un grupo de Auto Scaling:**
   - Navega a la consola de EC2 y configura un grupo de Auto Scaling para tus instancias.
   - Define políticas basadas en el uso de CPU o el tráfico de red.

### Paso 3.4: Optimizar EBS

1. **Revisar y optimizar volúmenes EBS:**
   - Revisa los volúmenes asociados con tus instancias. Libera volúmenes no utilizados o ajusta el tamaño si es necesario.

## Iteración 4: Optimización del Almacenamiento en S3

**Objetivo:** Configurar S3 para optimizar el almacenamiento y reducir costos.

### Paso 4.1: Configurar Políticas de Ciclo de Vida

1. **Implementar políticas de ciclo de vida:**
   - Navega a la consola de S3 y configura políticas de ciclo de vida para mover datos inactivos a S3 Glacier.

### Paso 4.2: Habilitar S3 Intelligent-Tiering

1. **Configurar Intelligent-Tiering:**
   - Para buckets con datos de acceso impredecible, habilita S3 Intelligent-Tiering desde la consola de S3.

### Paso 4.3: Implementar Versionado de Objetos

1. **Habilitar el versionado en S3:**
   - Desde la consola de S3, habilita el versionado en el bucket para proteger los datos contra la sobrescritura.

## Iteración 5: Optimización de RDS

**Objetivo:** Ajustar la configuración de RDS para mejorar el rendimiento y reducir costos.

### Paso 5.1: Análisis del Rendimiento de RDS

1. **Monitorizar el rendimiento de RDS:**
   - Utiliza AWS CloudWatch para revisar las métricas de rendimiento de RDS.

### Paso 5.2: Redimensionar RDS

1. **Redimensionar la instancia RDS:**
   - Si la instancia actual es demasiado grande para la carga de trabajo, redimensiona a un tipo más pequeño.

### Paso 5.3: Configurar Multi-AZ y Réplicas de Lectura

1. **Habilitar Multi-AZ:**
   - Si no está habilitado, activa Multi-AZ en la configuración de RDS.
   - Configura réplicas de lectura si tu aplicación realiza muchas consultas.

## Iteración 6: Implementación de Seguridad Adicional

**Objetivo:** Fortalecer la seguridad en todos los recursos.

### Paso 6.1: Configurar Políticas de IAM

1. **Revisar y ajustar políticas IAM:**
   - Asegúrate de que las políticas otorguen solo los permisos necesarios.

### Paso 6.2: Habilitar Cifrado en S3 y RDS

1. **Habilitar cifrado en S3 y RDS:**
   - Verifica que el cifrado esté habilitado para proteger los datos en reposo.

### Paso 6.3: Configurar CloudTrail

1. **Habilitar AWS CloudTrail:**
   - Configura CloudTrail para registrar todas las acciones realizadas en los recursos de AWS.

## Iteración 7: Reducción de Costos

**Objetivo:** Implementar estrategias para reducir costos en AWS.

### Paso 7.1: Uso de Instancias Reservadas y Spot

1. **Evaluar y comprar instancias reservadas:**
   - Identifica las instancias con uso constante y considera la compra de instancias reservadas.

2. **Configurar instancias Spot:**
   - Para cargas de trabajo flexibles, configura instancias Spot para aprovechar precios más bajos.

## Iteración 8: Revisión y Mejora Continua

**Objetivo:** Establecer un proceso de revisión continua para asegurar que las optimizaciones se mantengan.

### Paso 8.1: Establecer Revisiones Periódicas

1. **Programar revisiones trimestrales:**
   - Configura un ciclo regular de revisiones de la configuración y uso de recursos en AWS.

## Conclusión

Este laboratorio te ha proporcionado una guía completa, desde la provisión automatizada de recursos hasta la optimización avanzada de esos recursos en AWS. Siguiendo estas iteraciones, habrás creado un entorno eficiente, seguro y optimizado para maximizar tanto el rendimiento como el ahorro de costos en AWS.
