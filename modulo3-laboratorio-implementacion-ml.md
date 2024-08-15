### Laboratorio: Implementación de un Modelo de ML en AWS

#### Objetivo

El objetivo de este laboratorio es guiarte a través del proceso de creación, entrenamiento, despliegue y evaluación de un modelo de machine learning utilizando **Amazon SageMaker**. Al final de este laboratorio, habrás desarrollado un modelo predictivo que puede hacer inferencias en tiempo real utilizando datos en AWS.

#### Requisitos Previos

- Cuenta de AWS con permisos para crear y gestionar recursos en **Amazon SageMaker**, **S3**, **IAM**, y **Lambda**.
- Familiaridad básica con Python y conceptos de machine learning, como entrenamiento de modelos y validación.

#### Arquitectura de la Solución

La solución en este laboratorio incluye los siguientes componentes:

1. **Amazon S3:** Almacenamiento de datos para el conjunto de datos de entrenamiento y los modelos entrenados.
2. **Amazon SageMaker:** Plataforma para construir, entrenar y desplegar el modelo de machine learning.
3. **AWS Lambda (Opcional):** Función para invocar el modelo desplegado y realizar inferencias.
4. **Amazon API Gateway (Opcional):** Exponer el modelo a través de una API REST para facilitar el acceso.

#### Iteración 1: Preparación del Entorno

1. **Configuración de S3:**
   - Accede a la consola de **Amazon S3** y crea un bucket para almacenar los datos de entrenamiento y los artefactos del modelo. Nombra el bucket, por ejemplo, `ml-lab-data`.
   - Sube el conjunto de datos de entrenamiento al bucket. Puedes utilizar un conjunto de datos público o uno propio. Ejemplo: datos de viviendas con características y precios asociados.

2. **Configuración de IAM Roles:**
   - Crea un rol de IAM que permita a SageMaker acceder a los datos en S3 y gestionar los trabajos de entrenamiento y despliegue.
   - Asegúrate de que el rol tenga políticas como `AmazonS3FullAccess` y `AmazonSageMakerFullAccess`.

#### Iteración 2: Creación y Entrenamiento del Modelo en SageMaker

1. **Iniciar un Jupyter Notebook en SageMaker:**
   - Ve a la consola de **Amazon SageMaker** y crea un nuevo **Notebook Instance**.
   - Selecciona un tipo de instancia adecuado (por ejemplo, `ml.t2.medium`).
   - Asocia el rol de IAM creado anteriormente con la instancia del notebook.
   - Inicia el notebook y crea un nuevo cuaderno de Python.

2. **Cargar y Preparar los Datos:**
   - Dentro del Jupyter Notebook, carga los datos desde S3 utilizando `boto3` y las bibliotecas de manejo de datos como `pandas`.
   - Realiza la limpieza y preprocesamiento de los datos, como el manejo de valores faltantes, la normalización de características, y la división en conjuntos de entrenamiento y validación.

   Ejemplo de código:
   ```python
   import pandas as pd
   import boto3

   s3 = boto3.client('s3')
   bucket_name = 'ml-lab-data'
   file_key = 'house_prices.csv'
   
   # Cargar los datos desde S3
   obj = s3.get_object(Bucket=bucket_name, Key=file_key)
   df = pd.read_csv(obj['Body'])
   
   # Preprocesamiento de datos
   df = df.dropna()  # Ejemplo: eliminar filas con valores faltantes
   # Realizar otras tareas de preprocesamiento según sea necesario
   ```

3. **Seleccionar y Entrenar el Modelo:**
   - Utiliza uno de los algoritmos integrados de SageMaker, como **XGBoost**, para entrenar el modelo.
   - Configura el trabajo de entrenamiento, especificando el tipo de instancia y los hiperparámetros del modelo.
   - Entrena el modelo utilizando los datos preprocesados y guarda el modelo entrenado en S3.

   Ejemplo de código:
   ```python
   import sagemaker
   from sagemaker import get_execution_role
   from sagemaker.estimator import Estimator

   role = get_execution_role()

   # Configuración del estimador de XGBoost
   xgboost = sagemaker.estimator.Estimator(
       image_uri=sagemaker.image_uris.retrieve("xgboost", boto3.Session().region_name, "1.0-1"),
       role=role,
       instance_count=1,
       instance_type='ml.m4.xlarge',
       output_path=f's3://{bucket_name}/xgboost-model'
   )

   # Entrenar el modelo
   xgboost.fit({'train': f's3://{bucket_name}/train.csv'})
   ```

#### Iteración 3: Despliegue del Modelo

1. **Desplegar el Modelo en un Endpoint:**
   - Después del entrenamiento, despliega el modelo en un endpoint en tiempo real utilizando SageMaker.
   - El endpoint permitirá realizar inferencias en tiempo real mediante solicitudes HTTP.

   Ejemplo de código:
   ```python
   predictor = xgboost.deploy(
       initial_instance_count=1,
       instance_type='ml.m4.xlarge',
       endpoint_name='xgboost-endpoint'
   )
   ```

2. **Prueba del Endpoint:**
   - Envía datos de prueba al endpoint para verificar que el modelo funciona correctamente.
   - Usa el predictor para enviar datos en formato JSON y recibir predicciones.

   Ejemplo de código:
   ```python
   test_data = [1, 2, 3, 4, 5]  # Datos de prueba
   prediction = predictor.predict(test_data)
   print("Predicción:", prediction)
   ```

#### Iteración 4: Integración con AWS Lambda y API Gateway (Opcional)

1. **Crear una Función Lambda:**
   - Crea una función Lambda que invoque el endpoint del modelo y procese las predicciones.
   - Configura la función Lambda con el rol de IAM adecuado para invocar el endpoint de SageMaker.

   Ejemplo de código:
   ```python
   import boto3

   runtime = boto3.client('runtime.sagemaker')

   def lambda_handler(event, context):
       response = runtime.invoke_endpoint(
           EndpointName='xgboost-endpoint',
           ContentType='text/csv',
           Body=event['body']
       )
       result = response['Body'].read().decode('utf-8')
       return {
           'statusCode': 200,
           'body': result
       }
   ```

2. **Exponer la Función a través de API Gateway:**
   - Configura **Amazon API Gateway** para exponer la función Lambda a través de un endpoint REST.
   - Esto permitirá que aplicaciones externas consuman el modelo mediante solicitudes HTTP.

3. **Pruebas de la API:**
   - Utiliza herramientas como Postman o curl para enviar solicitudes a la API y verificar que las predicciones se devuelven correctamente.

#### Iteración 5: Monitoreo y Optimización

1. **Monitoreo del Modelo con CloudWatch:**
   - Configura **Amazon CloudWatch** para monitorear el rendimiento del endpoint, incluyendo latencia de inferencia, uso de recursos, y tasas de error.
   - Configura alarmas para detectar cualquier comportamiento anómalo.

2. **Optimización del Modelo:**
   - Revisa el rendimiento del modelo y ajusta los hiperparámetros si es necesario.
   - Considera volver a entrenar el modelo con más datos o probar diferentes algoritmos si el rendimiento no es satisfactorio.

3. **Gestión del Ciclo de Vida del Modelo:**
   - Implementa un pipeline de CI/CD para automatizar el reentrenamiento y despliegue del modelo a medida que se dispone de nuevos datos.
   - Utiliza **SageMaker Model Monitor** para supervisar el rendimiento del modelo en producción y detectar cualquier desviación de los datos de entrenamiento.

### Conclusión

Este laboratorio te ha guiado a través del proceso completo de implementación de un modelo de machine learning en AWS utilizando Amazon SageMaker. Desde la preparación de datos hasta el despliegue y monitoreo del modelo, has aprendido a crear una solución ML que puede integrarse fácilmente en aplicaciones en tiempo real. Con estas habilidades, ahora estás capacitado para desarrollar y desplegar modelos ML eficaces en un entorno de producción.
