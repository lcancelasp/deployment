# Ejercicio Repaso (CF + Docker + Maven + S3 + AWS CodeBuild + AWS CodePipeline + AWS Lambda + AWS API Gateway)
```
Pasos:

- Crear un Token en Github (https://github.com/settings/tokens)
- Crear stack de CF con el Pipeline del "build" de la imagen Docker Maven (serverless-app-image-pipeline)
- Crear stack de CF con el Pipeline del "build" de la aplicación (serverless-app-build-pipeline)
```

# NOTA:
```
Los eventos de API Gateway consiste en una solicitud a una función Lambda desde API GW. Cuando esto sucede, API Gateway espera que el resultado de la función sea la respuesta con la que API Gateway debería responder. En este caso además, se escribe en una tabla DynamoDB (ver código fuente en post-lambda y get-lambda)
```

# Scripts:
```
setup.sh:

infrastructure/image-cfn.yml   
  // CodeBuild Project in Docker env + CodePipeline Project with Github and S3 storage
infrastructure/image-buildspec.yml
  // docker build (Maven Build) + docker push

infrastructure/app-build-cfn.yml 
  // CodeBuild Project in Docker env + CodePipeline Project (Source, Build and Deploy)
infrastructure/app-buildspec.yml
  // Build and Post Build stages
sam.yml
  // Post Lambda and Get Lambda functions with API Gateway. Escribe y lee en tabla de DynamoDB

down.sh (No está probado)
  // Eliminar la tabla de DynamoDB, elimina el stack serverless-app, elimina el bucket S3 (artefacto), elimina el stack serverless-app-build-pipeline (codebuild + codepipeline) y por último elimina el repositorio de imagen Docker de ECR, y el stack serverless-app-image-pipeline
```

# NOTAS
```
En el script de setup, no lanzar la segunda plantilla de serverless-app-build, hasta que se haya ejecutado el image build de la anterior serverless-app-image-build (en codepipeline serverless-app-build-codepipeline-XXXX)!

BUILD: Después de que Maven construya los artefactos (.jar), y aún dentro de la acción "Build" del Pipeline, el comando aws cloudformation package utiliza el modelo de aplicación Serverless (también conocido como SAM) para determinar qué jars deberían cargarse en S3 para actualizar el código en las funciones de Lambda.

POST-BUILD: La plantilla resultante packaged-sam.yml se genera con el comando aws cloudformation package en formato zip en un bucket de S3 "serverless-app-build-artifactbucket-XXXX"

DEPLOYMENT: Los .class de get y post del código fuente, se suben a otro bucket de S3 "serverless-app-build-cfnbucket-XXXX"


NOTA: la template “serverless-app” se genera automáticamente y es el que invoca finalmente a los endpoint del API Gateway
```
