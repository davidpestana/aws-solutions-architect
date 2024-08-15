# Automatización y Gestión con Scripts en AWS

## Introducción

La automatización en AWS permite gestionar recursos de manera eficiente, reducir errores manuales, y asegurar la consistencia en la infraestructura. En este módulo, exploraremos cómo utilizar scripts y herramientas de automatización, como AWS CLI, SDKs, y AWS CloudFormation, para gestionar y operar recursos en AWS.

## Herramientas Principales para la Automatización

### 1. **AWS Command Line Interface (CLI)**

AWS CLI es una herramienta unificada que permite interactuar con los servicios de AWS desde la línea de comandos. Es una herramienta poderosa para automatizar tareas repetitivas y gestionar recursos sin necesidad de utilizar la consola web.

#### **Ejemplo de Automatización con AWS CLI**

**Script de Bash para Crear y Configurar una Instancia EC2:**

```bash
#!/bin/bash

# Variables
AMI_ID="ami-0abcdef1234567890"  # Reemplaza con un AMI ID válido en tu región
INSTANCE_TYPE="t2.micro"
KEY_NAME="mi-clave-ssh"
SECURITY_GROUP="mi-grupo-seguridad"

# Crear una nueva instancia EC2
aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE \
--key-name $KEY_NAME --security-groups $SECURITY_GROUP

# Obtener el ID de la instancia recién creada
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=pending,running" \
--query "Reservations[*].Instances[*].InstanceId" --output text)

# Esperar hasta que la instancia esté en estado "running"
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Asociar una etiqueta a la instancia
aws ec2 create-tags --resources $INSTANCE_ID --tags Key=Name,Value=MiInstanciaAutomatizada

echo "Instancia EC2 creada y configurada exitosamente con ID: $INSTANCE_ID"
```

### 2. **AWS Software Development Kits (SDKs)**

AWS SDKs permiten interactuar con los servicios de AWS utilizando lenguajes de programación como Python (Boto3), JavaScript (AWS SDK for JavaScript), y otros. Los SDKs son ideales para integrar la automatización directamente en las aplicaciones.

#### **Ejemplo de Automatización con Boto3 (Python SDK)**

**Script en Python para Listar Buckets de S3:**

```python
import boto3

# Crear un cliente de S3
s3 = boto3.client('s3')

# Listar todos los buckets de S3
buckets = s3.list_buckets()

# Imprimir el nombre de cada bucket
print("Buckets de S3 en tu cuenta:")
for bucket in buckets['Buckets']:
    print(f" - {bucket['Name']}")
```

### 3. **AWS CloudFormation**

AWS CloudFormation permite crear y gestionar recursos de AWS mediante plantillas que describen la infraestructura como código. Esto asegura que los entornos sean reproducibles y consistentes.

#### **Ejemplo de Plantilla CloudFormation**

**Plantilla para Crear una VPC y una Instancia EC2:**

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Plantilla para crear una VPC y una instancia EC2 en AWS'

Resources:
  MiVPC:
    Type: 'AWS::EC2::VPC'
    Properties:
      CidrBlock: '10.0.0.0/16'
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: MiVPC

  PublicSubnet:
    Type: 'AWS::EC2::Subnet'
    Properties:
      VpcId: !Ref MiVPC
      CidrBlock: '10.0.1.0/24'
      MapPublicIpOnLaunch: true
      AvailabilityZone: !Select [0, !GetAZs '']

  MiInstanciaEC2:
    Type: 'AWS::EC2::Instance'
    Properties:
      InstanceType: t2.micro
      KeyName: MiClaveSSH
      SubnetId: !Ref PublicSubnet
      ImageId: ami-0abcdef1234567890 # Reemplaza con un AMI ID válido en tu región
      Tags:
        - Key: Name
          Value: MiInstancia
```

### 4. **AWS Lambda**

AWS Lambda permite ejecutar código sin aprovisionar ni gestionar servidores, lo que es ideal para tareas de automatización que se ejecutan en respuesta a eventos. Se puede utilizar para automatizar respuestas a eventos de AWS, como la creación de una instancia EC2 o la modificación de un bucket S3.

#### **Ejemplo de Automatización con AWS Lambda**

**Script en Python para Automatizar Respuestas a Eventos de S3:**

```python
import json
import boto3

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    
    # Obtener el bucket y el objeto desde el evento
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    # Imprimir la información del objeto
    print(f"Objeto {key} fue creado en el bucket {bucket}")
    
    # Realizar alguna acción automatizada, como mover el objeto a otro bucket
    # s3.copy_object(Bucket='otro-bucket', CopySource={'Bucket': bucket, 'Key': key}, Key=key)
    
    return {
        'statusCode': 200,
        'body': json.dumps('Automatización completada')
    }
```

## Mejores Prácticas para la Automatización en AWS

1. **Uso de Control de Versiones:** Mantén todos los scripts y plantillas en un sistema de control de versiones como Git para facilitar la colaboración y el seguimiento de cambios.
   
2. **Pruebas en Ambientes de Desarrollo:** Siempre prueba los scripts y automatizaciones en un entorno de desarrollo o pruebas antes de desplegarlos en producción.

3. **Manejo de Errores:** Implementa un manejo de errores robusto en tus scripts para manejar situaciones inesperadas de manera segura.

4. **Seguridad en la Automatización:** Asegúrate de que las credenciales y los secretos utilizados en los scripts estén gestionados de manera segura, por ejemplo, usando AWS Secrets Manager.

## Conclusión

Automatizar la gestión y operación de recursos en AWS a través de scripts y herramientas como AWS CLI, SDKs, y CloudFormation permite una administración más eficiente y segura de tu infraestructura. Al dominar estas herramientas, puedes reducir la carga operativa, minimizar errores y asegurar la consistencia en la gestión de tus entornos AWS.
