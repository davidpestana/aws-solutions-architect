### Laboratorio: Desarrollo de una Aplicación Sin Servidor

#### Objetivo

Este laboratorio te guiará a través del proceso de desarrollar una aplicación completamente sin servidor utilizando **AWS Lambda**, **API Gateway**, **Amazon DynamoDB**, y otros servicios de AWS. Al final del laboratorio, habrás creado una aplicación web básica que permite a los usuarios enviar y recuperar datos mediante una API REST, todo gestionado sin servidores tradicionales.

#### Requisitos Previos

- Cuenta de AWS con permisos para crear recursos como Lambda, API Gateway, DynamoDB, y S3.
- Familiaridad básica con servicios de AWS, JavaScript (Node.js), y JSON.
- Conocimientos básicos de HTTP y APIs RESTful.

#### Arquitectura de la Aplicación

La aplicación consistirá en los siguientes componentes:

1. **API Gateway:** Gestiona las solicitudes HTTP y las redirige a las funciones Lambda.
2. **AWS Lambda:** Ejecuta la lógica de la aplicación en respuesta a las solicitudes HTTP.
3. **Amazon DynamoDB:** Almacena los datos enviados por los usuarios.
4. **Amazon S3 (opcional):** Aloja el frontend de la aplicación, si se decide crear una interfaz web.

#### Iteración 1: Configuración del Entorno

1. **Crear un Bucket en S3 para Almacenamiento (opcional):**
   - Navega a la consola de Amazon S3 y crea un bucket para almacenar los archivos de frontend (HTML, CSS, JS).
   - Configura el bucket como público para permitir el acceso a los archivos web.

2. **Crear la Tabla en DynamoDB:**
   - Ve a la consola de DynamoDB y crea una nueva tabla llamada `UsersData` con una clave primaria `UserId` (tipo String).
   - Configura la tabla para permitir operaciones de lectura y escritura.

3. **Configurar IAM Roles y Políticas:**
   - Crea un rol de IAM que permita a Lambda acceder a DynamoDB.
   - Adjunta una política que otorgue permisos para realizar acciones en DynamoDB, como `PutItem` y `GetItem`.

#### Iteración 2: Creación de la API con API Gateway

1. **Configurar una API REST en API Gateway:**
   - En la consola de API Gateway, crea una nueva API REST llamada `UserAPI`.
   - Añade un recurso `/users` y un método `POST` para permitir la creación de nuevos usuarios.
   - Configura el método `POST` para invocar una función Lambda que se encargará de procesar los datos.

2. **Definir el Método GET:**
   - Añade otro método `GET` al recurso `/users/{userId}` para permitir la obtención de datos de un usuario específico.
   - Configura el método `GET` para invocar otra función Lambda que recupere los datos de DynamoDB.

#### Iteración 3: Implementación de las Funciones Lambda

1. **Crear la Función Lambda para el Método POST:**
   - En la consola de Lambda, crea una nueva función llamada `CreateUser`.
   - Escribe la lógica en Node.js para recibir datos de la solicitud HTTP, validar la entrada, y guardarla en DynamoDB.
   - Aquí un ejemplo básico de código:
   ```javascript
   const AWS = require('aws-sdk');
   const dynamo = new AWS.DynamoDB.DocumentClient();

   exports.handler = async (event) => {
       const userId = event.body.userId;
       const data = event.body.data;

       const params = {
           TableName: 'UsersData',
           Item: {
               UserId: userId,
               Data: data
           }
       };

       try {
           await dynamo.put(params).promise();
           return {
               statusCode: 200,
               body: JSON.stringify({ message: 'User created successfully!' })
           };
       } catch (error) {
           return {
               statusCode: 500,
               body: JSON.stringify({ message: 'Error creating user', error })
           };
       }
   };
   ```

2. **Crear la Función Lambda para el Método GET:**
   - Crea una nueva función Lambda llamada `GetUser`.
   - Implementa la lógica para recuperar los datos de un usuario específico desde DynamoDB.
   - Ejemplo básico de código:
   ```javascript
   const AWS = require('aws-sdk');
   const dynamo = new AWS.DynamoDB.DocumentClient();

   exports.handler = async (event) => {
       const userId = event.pathParameters.userId;

       const params = {
           TableName: 'UsersData',
           Key: {
               UserId: userId
           }
       };

       try {
           const data = await dynamo.get(params).promise();
           return {
               statusCode: 200,
               body: JSON.stringify(data.Item)
           };
       } catch (error) {
           return {
               statusCode: 500,
               body: JSON.stringify({ message: 'Error retrieving user', error })
           };
       }
   };
   ```

#### Iteración 4: Despliegue y Pruebas

1. **Despliegue de la API:**
   - En API Gateway, despliega la API a un entorno de producción.
   - Obtén la URL de la API para realizar pruebas.

2. **Pruebas de la API:**
   - Utiliza herramientas como Postman o CURL para enviar solicitudes POST y GET a la API.
   - Verifica que los datos se están almacenando y recuperando correctamente desde DynamoDB.

3. **Despliegue del Frontend (opcional):**
   - Si has creado un frontend, sube los archivos al bucket de S3.
   - Configura S3 para servir el contenido estático.

#### Iteración 5: Escalabilidad y Monitoreo

1. **Configurar Auto Scaling:**
   - Lambda escala automáticamente, pero verifica las configuraciones para asegurarte de que puede manejar los volúmenes esperados.

2. **Configurar Monitoreo con CloudWatch:**
   - Configura alarmas en CloudWatch para monitorear el rendimiento de las funciones Lambda y la latencia de la API.
   - Establece umbrales para las métricas clave y recibe alertas cuando se superen.

3. **Optimización de Costos:**
   - Revisa las configuraciones de recursos asignados a las funciones Lambda.
   - Ajusta la memoria asignada para equilibrar el costo y el rendimiento.

#### Iteración 6: Implementación de Seguridad

1. **Implementar Autenticación y Autorización:**
   - Configura Amazon Cognito para gestionar la autenticación de usuarios.
   - Protege los endpoints de la API con autorizaciones basadas en roles.

2. **Cifrado de Datos:**
   - Asegúrate de que los datos en DynamoDB estén cifrados en reposo.
   - Utiliza HTTPS para todas las comunicaciones API para proteger los datos en tránsito.

#### Iteración 7: Documentación y Mejores Prácticas

1. **Documentar la API:**
   - Utiliza Swagger o OpenAPI para generar documentación de la API que pueda ser compartida con otros desarrolladores.

2. **Documentar el Código:**
   - Comenta el código de las funciones Lambda para facilitar el mantenimiento y futuras actualizaciones.

3. **Adoptar Mejores Prácticas:**
   - Revisa las mejores prácticas de AWS para Lambda, API Gateway y DynamoDB para optimizar la seguridad, escalabilidad y rendimiento.

#### Iteración 8: Mantenimiento y Escalabilidad Continua

1. **Pruebas de Carga y Escalabilidad:**
   - Realiza pruebas de carga para verificar que la aplicación puede manejar el tráfico esperado.
   - Ajusta las configuraciones según sea necesario.

2. **Monitoreo Continuo:**
   - Implementa un monitoreo continuo para detectar problemas de rendimiento y escalabilidad.
   - Establece revisiones regulares de la infraestructura y el código para optimizaciones continuas.

3. **Refinamiento y Optimización:**
   - Analiza el uso de recursos y los costos asociados con la aplicación.
   - Optimiza las configuraciones y el código para reducir costos y mejorar la eficiencia.

Este laboratorio completo te permitirá desarrollar una aplicación completamente sin servidor, utilizando las mejores prácticas y herramientas proporcionadas por AWS para crear una solución escalable, segura y eficiente.
