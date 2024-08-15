### Laboratorio: Orquestación de Microservicios en AWS

#### Objetivo

El objetivo de este laboratorio es aprender a orquestar microservicios en AWS utilizando **Amazon API Gateway**, **AWS Lambda**, y **Amazon SQS**. Al finalizar este laboratorio, serás capaz de implementar y gestionar una arquitectura de microservicios desacoplados que se comunican de manera asíncrona y escalable.

#### Requisitos Previos

- Cuenta de AWS con permisos para crear y gestionar recursos como API Gateway, Lambda, SQS, y IAM roles.
- Familiaridad con la consola de AWS y servicios básicos como S3 y DynamoDB.
- Conocimientos básicos de microservicios y APIs RESTful.

#### Arquitectura de la Solución

La solución que se implementará en este laboratorio sigue una arquitectura basada en microservicios, donde cada componente realiza una tarea específica. Los microservicios se comunicarán a través de colas de mensajes utilizando Amazon SQS y estarán expuestos mediante API Gateway.

1. **API Gateway:** Actúa como punto de entrada para las solicitudes de los usuarios y enruta las solicitudes a los microservicios correspondientes.
2. **AWS Lambda:** Cada microservicio está implementado como una función Lambda que se encarga de procesar una parte específica de la aplicación.
3. **Amazon SQS:** Se utiliza para manejar la comunicación asíncrona entre los microservicios, garantizando la entrega y el procesamiento de mensajes sin pérdida de datos.

#### Iteración 1: Configuración de los Microservicios

1. **Definir las Funciones Lambda para los Microservicios:**
   - Crea tres funciones Lambda en la consola de AWS:
     - **CreateOrderService:** Procesa las solicitudes de creación de pedidos.
     - **ProcessPaymentService:** Gestiona el procesamiento de pagos.
     - **NotificationService:** Envía notificaciones al cliente después de que el pedido y el pago han sido procesados.

   - Para cada función, escribe un código básico que simule la lógica de negocio correspondiente. Por ejemplo, el servicio `CreateOrderService` podría simplemente registrar el pedido y enviarlo a la cola de SQS.

   Ejemplo básico de código para `CreateOrderService`:
   ```python
   import json
   import boto3

   sqs = boto3.client('sqs')

   def lambda_handler(event, context):
       # Simulación de creación de pedido
       order_id = event['order_id']
       order_details = event['order_details']

       # Enviar a la cola de SQS
       response = sqs.send_message(
           QueueUrl='https://sqs.us-east-1.amazonaws.com/123456789012/OrderQueue',
           MessageBody=json.dumps({
               'order_id': order_id,
               'order_details': order_details
           })
       )

       return {
           'statusCode': 200,
           'body': json.dumps('Pedido creado exitosamente')
       }
   ```

2. **Crear las Colas SQS:**
   - Crea dos colas en Amazon SQS:
     - **OrderQueue:** Recibe mensajes de pedidos creados por `CreateOrderService`.
     - **PaymentQueue:** Recibe mensajes de pagos procesados por `ProcessPaymentService`.

   - Configura cada cola para permitir la entrega de mensajes con visibilidad de 30 segundos, asegurando que el mensaje no se procese más de una vez simultáneamente.

3. **Configurar los Triggers en Lambda:**
   - Configura `OrderQueue` para que dispare la función `ProcessPaymentService` cuando reciba un nuevo mensaje.
   - Configura `PaymentQueue` para que dispare la función `NotificationService` cuando se procese un pago.

#### Iteración 2: Configuración de API Gateway

1. **Crear la API en API Gateway:**
   - En la consola de **API Gateway**, crea una nueva API REST llamada `OrderProcessingAPI`.
   - Define dos recursos:
     - **/orders:** Para crear nuevos pedidos (método POST).
     - **/payments:** Para procesar pagos (método POST).

2. **Integrar la API con los Microservicios:**
   - Configura el recurso **/orders** para invocar la función Lambda `CreateOrderService`.
   - Configura el recurso **/payments** para invocar la función Lambda `ProcessPaymentService`.
   - Asegúrate de que las integraciones están correctamente configuradas y que los datos se pasan entre los recursos y las funciones Lambda.

3. **Implementar Seguridad y Autenticación:**
   - Configura API Gateway para utilizar **AWS IAM** o **Amazon Cognito** para autenticar y autorizar las solicitudes de API.
   - Define políticas que aseguren que solo los usuarios autenticados puedan acceder a los endpoints.

#### Iteración 3: Despliegue y Pruebas

1. **Desplegar la API:**
   - En API Gateway, despliega la API en un entorno de producción y obtiene la URL del endpoint para pruebas.

2. **Pruebas de la API:**
   - Utiliza herramientas como **Postman** o **curl** para enviar solicitudes HTTP a los endpoints `/orders` y `/payments`.
   - Verifica que los pedidos se están creando correctamente y que los pagos están siendo procesados, activando los microservicios apropiados.

3. **Verificación del Flujo de Mensajes:**
   - Revisa las colas de SQS para asegurarte de que los mensajes se están entregando y procesando correctamente.
   - Verifica los logs de CloudWatch para cada función Lambda para asegurarte de que no hay errores y que los microservicios están funcionando según lo esperado.

#### Iteración 4: Monitoreo y Escalabilidad

1. **Configurar Monitoreo con CloudWatch:**
   - Configura alarmas en **Amazon CloudWatch** para monitorear las métricas clave de las funciones Lambda, como invocaciones, errores y duración.
   - Configura métricas para las colas SQS, como la longitud de la cola y la tasa de mensajes procesados.

2. **Ajuste de Escalabilidad:**
   - Configura **AWS Lambda** para escalar automáticamente en función de la carga de trabajo.
   - Ajusta las configuraciones de visibilidad en SQS para optimizar el procesamiento de mensajes y evitar cuellos de botella.

#### Iteración 5: Optimización y Mejores Prácticas

1. **Optimización de Costos:**
   - Revisa el uso de recursos y ajusta la configuración de las funciones Lambda, las colas de SQS y API Gateway para minimizar los costos sin comprometer el rendimiento.
   - Considera implementar la compresión de mensajes en SQS y ajustar los tiempos de visibilidad para mejorar la eficiencia.

2. **Documentación de la Arquitectura:**
   - Documenta la arquitectura implementada, incluyendo diagramas que describan cómo los microservicios se comunican entre sí y cómo se manejan las solicitudes de los usuarios.
   - Documenta también las configuraciones de seguridad y monitoreo implementadas.

3. **Revisión de Mejores Prácticas:**
   - Asegúrate de seguir las mejores prácticas recomendadas por AWS para la orquestación de microservicios, incluyendo el uso de políticas de IAM, la gestión de errores en Lambda, y la optimización de las colas SQS.

#### Conclusión

Este laboratorio te ha proporcionado una experiencia práctica en la orquestación de microservicios utilizando **API Gateway**, **AWS Lambda**, y **Amazon SQS**. Ahora estás equipado para diseñar y desplegar arquitecturas de microservicios en AWS que son escalables, resilientes y fáciles de mantener, aprovechando las capacidades gestionadas de AWS para manejar la infraestructura subyacente.
