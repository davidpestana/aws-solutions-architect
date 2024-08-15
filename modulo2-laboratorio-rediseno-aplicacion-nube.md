# Laboratorio: Rediseño de una Aplicación Monolítica para la Nube en AWS

## Introducción

Este laboratorio te guiará a través del proceso de rediseñar una aplicación monolítica sencilla, "Gestión de Tareas", hacia una arquitectura de microservicios utilizando servicios de AWS. El objetivo es mejorar la escalabilidad, disponibilidad y eficiencia en costos mediante la implementación de servicios administrados como Amazon RDS, S3 y Lambda.

## Objetivos

- Migrar y rediseñar una aplicación monolítica hacia una arquitectura de microservicios.
- Implementar servicios administrados de AWS para mejorar la escalabilidad y disponibilidad.
- Optimizar la aplicación para reducir costos y mejorar el rendimiento.
- Configurar la infraestructura utilizando herramientas de automatización como AWS CloudFormation.

## Requisitos Previos

- Cuenta de AWS con permisos administrativos.
- Conocimientos básicos de AWS, Node.js y SQL.
- Familiaridad con servicios como EC2, RDS y Lambda.

## Aplicación Original: "Gestión de Tareas"

### Descripción

La aplicación "Gestión de Tareas" permite a los usuarios crear, leer, actualizar y eliminar tareas. Está construida como un monolito, lo que significa que todo el código, la lógica de negocios, la interfaz de usuario y la base de datos están empaquetados en una única aplicación.

### Código Fuente de la Aplicación Original

#### Estructura del Proyecto

```plaintext
gestion-tareas/
├── app.js
├── package.json
├── views/
│   ├── index.html
│   └── task.html
└── db/
    └── tasks.sql
```

#### Código de `app.js`

```javascript
const express = require('express');
const mysql = require('mysql');
const app = express();
const port = 3000;

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'task_manager'
});

db.connect(err => {
    if (err) {
        throw err;
    }
    console.log('Conectado a MySQL');
});

app.use(express.json());
app.use(express.static('views'));

app.get('/tasks', (req, res) => {
    let sql = 'SELECT * FROM tasks';
    db.query(sql, (err, results) => {
        if (err) throw err;
        res.json(results);
    });
});

app.post('/tasks', (req, res) => {
    let task = { title: req.body.title, description: req.body.description };
    let sql = 'INSERT INTO tasks SET ?';
    db.query(sql, task, (err, result) => {
        if (err) throw err;
        res.send('Tarea añadida');
    });
});

app.listen(port, () => {
    console.log(`Servidor corriendo en http://localhost:${port}`);
});
```

#### Archivo SQL (`tasks.sql`)

```sql
CREATE DATABASE IF NOT EXISTS task_manager;
USE task_manager;

CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT
);
```

#### Vistas (`index.html` y `task.html`)

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Tareas</title>
</head>
<body>
    <h1>Mis Tareas</h1>
    <ul id="task-list"></ul>
    <a href="task.html">Añadir Nueva Tarea</a>
    <script>
        fetch('/tasks')
            .then(response => response.json())
            .then(tasks => {
                const taskList = document.getElementById('task-list');
                tasks.forEach(task => {
                    const li = document.createElement('li');
                    li.textContent = task.title;
                    taskList.appendChild(li);
                });
            });
    </script>
</body>
</html>
```

```html
<!-- task.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Añadir Tarea</title>
</head>
<body>
    <h1>Añadir Nueva Tarea</h1>
    <form id="task-form">
        <input type="text" name="title" placeholder="Título" required>
        <textarea name="description" placeholder="Descripción"></textarea>
        <button type="submit">Guardar</button>
    </form>
    <script>
        document.getElementById('task-form').addEventListener('submit', function(event) {
            event.preventDefault();
            const data = new FormData(event.target);
            const task = {
                title: data.get('title'),
                description: data.get('description')
            };
            fetch('/tasks', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(task)
            }).then(response => {
                if (response.ok) {
                    alert('Tarea añadida');
                    window.location.href = '/';
                }
            });
        });
    </script>
</body>
</html>
```

## Iteraciones del Laboratorio

### Iteración 1: Configuración del Entorno de Desarrollo

**Objetivo:** Configurar el entorno de desarrollo local e implementar la aplicación original.

1. **Instalación de Node.js y MySQL:**
   - Instala Node.js en tu máquina local.
   - Instala MySQL y crea una base de datos llamada `task_manager`.

2. **Clonación del Repositorio y Ejecución de la Aplicación:**
   - Clona el repositorio que contiene el código de la aplicación original.
   - Ejecuta los comandos `npm install` y `node app.js` para iniciar la aplicación.

3. **Pruebas Locales:**
   - Accede a `http://localhost:3000` para interactuar con la aplicación y verificar que funciona correctamente.

### Iteración 2: Migración a una Arquitectura de Microservicios

**Objetivo:** Descomponer la aplicación monolítica en microservicios independientes.

1. **División de la Aplicación en Microservicios:**
   - Separa el código en tres microservicios: `Servicio de Usuarios`, `Servicio de Tareas` y `Servicio de Notificaciones`.

2. **Configuración de API Gateway:**
   - Configura AWS API Gateway para gestionar las solicitudes a cada microservicio.

3. **Implementación de Funciones Lambda:**
   - Implementa `AWS Lambda` para gestionar tareas como las notificaciones, reduciendo la dependencia de servidores dedicados.

### Iteración 3: Despliegue en AWS

**Objetivo:** Desplegar los microservicios en AWS utilizando instancias EC2 y otros servicios.

1. **Configuración de Amazon RDS:**
   - Crea una instancia de Amazon RDS y migra la base de datos MySQL a esta instancia.

2. **Despliegue de Microservicios en EC2 o Fargate:**
   - Despliega los microservicios en instancias EC2 o contenedores en Amazon Fargate.

3. **Configuración de Elastic Load Balancer:**
   - Configura un ELB para distribuir el tráfico entre los microservicios desplegados.

### Iteración 4: Escalabilidad y Optimización

**Objetivo:** Asegurar que la aplicación sea escalable y optimizar el rendimiento.

1. **Implementación de Auto Scaling:**
   - Configura Auto Scaling para que los microservicios escalen según la demanda.

2. **Optimización del Almacenamiento con S3:**
   - Migra el almacenamiento de archivos estáticos a Amazon S3 y configura CloudFront para distribución global.

3. **Monitoreo y Ajuste:**
   - Usa CloudWatch para monitorear el rendimiento y ajustar los recursos según sea necesario.

### Iteración 5: Seguridad y Gestión de Acceso

**Objetivo:** Implementar controles de seguridad para proteger los datos y el acceso a la aplicación.

1. **Configuración de IAM Roles y Políticas:**
   - Configura roles de IAM para asegurar que cada microservicio tenga acceso mínimo necesario a los recursos.

2. **Seguridad en la Red:**
   - Implementa grupos de seguridad y VPC para controlar el acceso a los microservicios.

### Iteración 6: Automatización con CloudFormation

**Objetivo:** Automatizar la configuración y despliegue de la infraestructura en AWS.

1. **Creación de Plantillas de CloudFormation:**
   - Automatiza la infraestructura creando plantillas de AWS CloudFormation.

2. **Despliegue Automatizado:**
   - Despliega toda la arquitectura de manera automatizada utilizando las plantillas creadas.

### Iteración 7: Pruebas de Carga y Optimización Continua

**Objetivo:** Evaluar el rendimiento de la aplicación bajo carga y optimizarla continuamente.

1. **Ejecutar Pruebas de Carga:**
   - Simula tráfico para evaluar el rendimiento de la aplicación bajo carga.

2. **Optimización de Costos:**
   - Revisa el uso de recursos y ajusta configuraciones para optimizar costos.

### Iteración 8: Documentación y Mejores Prácticas

**Objetivo:** Documentar todo el proceso de rediseño y aplicar mejores prácticas para asegurar la sostenibilidad y escalabilidad de la aplicación.

1. **Documentación Completa:**
   - **Arquitectura:** Detalla la arquitectura final, describiendo cada microservicio y cómo interactúan entre sí. Incluye diagramas que muestren la infraestructura en AWS.
   - **Despliegue:** Documenta los pasos necesarios para desplegar la aplicación, incluyendo las configuraciones de Auto Scaling, Elastic Load Balancer, y otras configuraciones de infraestructura.
   - **Código:** Explica el código de cada microservicio, incluyendo comentarios en el código y guías de estilo que se deben seguir.

2. **Prácticas de Seguridad:**
   - **Control de Acceso:** Revisa y documenta las políticas de IAM, asegurando que cada servicio solo tenga los permisos necesarios.
   - **Cifrado de Datos:** Asegura que todos los datos almacenados en S3 y RDS estén cifrados. Documenta cómo se implementó el cifrado y qué claves se utilizan.
   - **Monitoreo de Seguridad:** Configura y documenta alertas en AWS CloudWatch para detectar accesos no autorizados o actividades sospechosas.

3. **Prácticas de Escalabilidad:**
   - **Auto Scaling:** Documenta las políticas de Auto Scaling configuradas, explicando cuándo y cómo se escalan los microservicios.
   - **Optimización de Costos:** Revisa las métricas de uso de recursos y ajusta las configuraciones para minimizar costos sin comprometer el rendimiento. Documenta estas optimizaciones para futuras referencias.

4. **Pruebas y Mantenimiento:**
   - **Pruebas de Integración Continua:** Configura un pipeline de integración continua que incluya pruebas automatizadas de cada microservicio. Documenta cómo se configuró este pipeline y cómo se pueden añadir nuevas pruebas.
   - **Mantenimiento Regular:** Establece un plan de mantenimiento regular para revisar las métricas de rendimiento, ajustar configuraciones, y aplicar parches de seguridad.

5. **Mejores Prácticas:**
   - **Código Limpio:** Asegúrate de que todo el código siga las mejores prácticas de desarrollo, como el principio de responsabilidad única, la reutilización de código y la separación de preocupaciones. Documenta estas prácticas en un archivo de guía de estilo de código.
   - **Gestión de Versiones:** Implementa un sistema de control de versiones robusto y documenta cómo se debe manejar el ciclo de vida de las versiones de cada microservicio.
   - **Backup y Recuperación:** Establece un plan de recuperación ante desastres que incluya copias de seguridad regulares de los datos y los sistemas. Documenta cómo se pueden restaurar los servicios en caso de fallo.

6. **Refinamiento Continuo:**
   - **Feedback Loop:** Establece mecanismos para recopilar feedback de los usuarios y mejorar continuamente la aplicación. Documenta cómo se debe gestionar el feedback y las actualizaciones del producto.
   - **Optimización Continua:** Realiza revisiones periódicas del rendimiento de la aplicación y ajusta las configuraciones de AWS para optimizar aún más los costos y la eficiencia.

7. **Publicación y Entrega:**
   - **Publicación:** Documenta el proceso de publicación de nuevas versiones de los microservicios, incluyendo la configuración de despliegue continuo y pruebas en ambientes de staging antes de la producción.
   - **Entrega:** Asegura que los procesos de entrega de código y actualizaciones estén alineados con las mejores prácticas de DevOps, incluyendo automatización y monitoreo post-despliegue.
