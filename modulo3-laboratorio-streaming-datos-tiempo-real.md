### Laboratorio: Configuración de Streaming de Datos en Tiempo Real

#### Objetivo

El objetivo de este laboratorio es guiarte a través del proceso de configurar un flujo de streaming de datos en tiempo real utilizando **Amazon Kinesis Data Streams** y **Amazon Kinesis Data Firehose**. Al final del laboratorio, habrás implementado un flujo que ingesta datos en tiempo real, los procesa y los entrega a un destino, como **Amazon S3** o **Amazon Redshift**.

#### Requisitos Previos

- Cuenta de AWS con permisos para crear recursos como Kinesis, S3, Lambda, y Redshift.
- Conocimientos básicos de la consola de AWS y servicios como S3.
- Familiaridad con la escritura de scripts en **AWS Lambda** (Node.js o Python).

#### Arquitectura de la Solución

La solución que se implementará en este laboratorio seguirá la siguiente arquitectura:

1. **Amazon Kinesis Data Streams:** Se configurará para recibir datos en tiempo real desde un productor de datos.
2. **AWS Lambda:** Procesará los datos recibidos, realizando transformaciones necesarias.
3. **Amazon Kinesis Data Firehose:** Entregará los datos procesados a un destino, como un bucket de S3 o una tabla de Amazon Redshift.

#### Iteración 1: Configuración de Amazon Kinesis Data Streams

1. **Crear un Stream en Kinesis:**
   - Accede a la consola de **Amazon Kinesis** y selecciona "Data Streams".
   - Crea un nuevo stream llamado `RealTimeDataStream`.
   - Configura el número de **shards** según la cantidad de datos que esperas recibir. Cada shard soporta 1 MB/s de datos entrantes y 2 MB/s de datos salientes.
   - Confirma la creación del stream.

2. **Configurar un Productor de Datos:**
   - Configura un productor de datos que envíe eventos a `RealTimeDataStream`. Si estás utilizando un entorno de desarrollo local, puedes usar un script en Python o Node.js que simule la generación de datos.
   - Ejemplo de código en Python para enviar datos a Kinesis:
     ```python
     import boto3
     import json
     import time

     kinesis = boto3.client('kinesis', region_name='us-east-1')

     while True:
         data = {
             'event_type': 'click',
             'timestamp': int(time.time() * 1000),
             'user_id': 'user123',
             'page': '/home'
         }
         kinesis.put_record(
             StreamName='RealTimeDataStream',
             Data=json.dumps(data),
             PartitionKey='user123'
         )
         time.sleep(1)
     ```

3. **Verificar la Ingesta de Datos:**
   - Accede a la consola de **Amazon Kinesis** y verifica que los datos están siendo ingesados correctamente en el stream `RealTimeDataStream`.
   - Monitorea el uso de los shards para asegurarte de que no se están sobrecargando.

#### Iteración 2: Configuración de Procesamiento con AWS Lambda

1. **Crear una Función Lambda:**
   - Ve a la consola de **AWS Lambda** y crea una nueva función llamada `ProcessRealTimeData`.
   - Selecciona **Python** o **Node.js** como entorno de ejecución.
   - En la sección de permisos, asegúrate de que la función Lambda tenga permisos para leer desde Kinesis y escribir en S3 o Redshift.

2. **Escribir la Lógica de Procesamiento:**
   - Escribe el código en la función Lambda para procesar los datos recibidos. Este procesamiento puede incluir la transformación de datos, filtrado, o enriquecimiento.
   - Ejemplo básico en Python:
     ```python
     import json

     def lambda_handler(event, context):
         for record in event['Records']:
             payload = json.loads(record['kinesis']['data'])
             print(f"Processed record: {payload}")
             # Aquí puedes realizar transformaciones o enviar los datos a otro servicio
     ```

3. **Configurar el Trigger de Kinesis:**
   - En la consola de Lambda, configura `RealTimeDataStream` como un trigger para la función `ProcessRealTimeData`.
   - Esto asegura que cada vez que se envían datos al stream, la función Lambda se ejecuta automáticamente.

#### Iteración 3: Configuración de Amazon Kinesis Data Firehose

1. **Crear un Delivery Stream en Firehose:**
   - Ve a la consola de **Amazon Kinesis Data Firehose** y crea un nuevo delivery stream llamado `ProcessedDataDeliveryStream`.
   - Selecciona `RealTimeDataStream` como la fuente de datos.

2. **Configurar la Transformación de Datos:**
   - Puedes configurar **AWS Lambda** para realizar transformaciones adicionales antes de que los datos sean entregados al destino final.
   - En la configuración de Firehose, selecciona la opción para habilitar la transformación de datos y elige la función Lambda `ProcessRealTimeData`.

3. **Seleccionar el Destino de Datos:**
   - Selecciona el destino de los datos transformados. Puede ser un bucket de **Amazon S3** para almacenamiento a largo plazo o **Amazon Redshift** para análisis inmediato.
   - Configura las opciones de entrega, como la compresión y el cifrado de datos.

4. **Verificar la Entrega de Datos:**
   - Monitorea el delivery stream en la consola de Firehose para verificar que los datos procesados están siendo entregados correctamente al destino configurado.
   - Si los datos se entregan a S3, verifica que los archivos están siendo almacenados en el bucket. Si se entregan a Redshift, asegúrate de que las tablas están recibiendo los datos.

#### Iteración 4: Monitoreo y Escalabilidad

1. **Configurar Monitoreo con CloudWatch:**
   - Configura **Amazon CloudWatch** para monitorear el rendimiento de los streams de Kinesis y la función Lambda. Incluye métricas como el uso de shards, latencia de procesamiento, y errores de Lambda.
   - Crea alarmas que te notifiquen si el uso de los shards supera un cierto umbral o si la latencia aumenta.

2. **Ajuste de Capacidad de Shards:**
   - Si el flujo de datos crece con el tiempo, ajusta la capacidad de los shards en Kinesis Data Streams para manejar la mayor carga. Puedes hacerlo manualmente o configurar un **Auto Scaling**.

3. **Optimización de Costos:**
   - Revisa el uso de recursos y ajusta las configuraciones para optimizar los costos. Por ejemplo, ajusta el tamaño de los lotes en Firehose para reducir la frecuencia de las escrituras en S3 o Redshift, lo que puede reducir los costos.

#### Iteración 5: Documentación y Mejores Prácticas

1. **Documentación del Flujo de Trabajo:**
   - Documenta todos los pasos realizados en este laboratorio, incluyendo la configuración de Kinesis, Lambda, y Firehose, así como los scripts utilizados para producir y procesar datos.
   - Incluye diagramas de arquitectura que muestren cómo fluyen los datos desde la ingesta hasta el almacenamiento final.

2. **Revisión de Mejores Prácticas:**
   - Asegúrate de seguir las mejores prácticas de AWS para la configuración de Kinesis, Lambda, y Firehose. Esto incluye la seguridad, el manejo de errores, y la optimización de costos.
   - Revisa las políticas de IAM para asegurarte de que solo los servicios y usuarios autorizados tienen acceso a los datos y recursos.

#### Conclusión

Este laboratorio te ha proporcionado una experiencia práctica en la configuración de un flujo de streaming de datos en tiempo real en AWS, utilizando Kinesis Data Streams, AWS Lambda, y Kinesis Data Firehose. Ahora tienes las habilidades necesarias para implementar y gestionar flujos de datos en tiempo real, desde la ingesta hasta la entrega y almacenamiento, utilizando servicios totalmente gestionados de AWS.
