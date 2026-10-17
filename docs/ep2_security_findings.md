# Evidencia de seguridad — EP2 DOY0101

## Estado actual: CI y seguridad sin despliegue automático

A partir de la eliminación de los trabajos de despliegue simulado, el workflow `.github/workflows/ci.yml` mantiene **solo tres jobs**:

- `Pruebas automatizadas` — PyTest.
- `Snyk - dependencias` — auditoría de `requirements-docker.txt`.
- `Docker Build y Trivy` — validación Docker Compose, construcción de imagen, inventario de dependencias y escaneo de imagen HIGH/CRITICAL.

**No existe despliegue automático ni despliegue simulado en GitHub Actions.** Para comprobar la aplicación se utiliza manualmente `docker compose up -d --build` y `http://localhost:8501/_stcore/health`, además de las pruebas de funcionalidad de la interfaz.

### Evidencia de escaneos y verificaciones previas

La ejecución [CI-CD #39035582440](https://github.com/alva2000/ia-components-devops/actions/runs/39035582440) aprobó las pruebas, Snyk y Trivy. **En ese momento todavía existían jobs de despliegue simulado**, que posteriormente se eliminaron a solicitud del equipo. Esta evidencia histórica no implica publicación del servicio en un servidor.

### Vulnerabilidades corregidas

Anteriormente Snyk detectó 9 vulnerabilidades HIGH en dependencias transitivas de `sentence-transformers` (`torch` y `transformers`). El backend de embeddings se sustituyó por `fastembed` (ONNX), manteniendo FAISS.

Trivy señaló versiones desactualizadas en dependencias incluidas dentro de las herramientas de instalación del entorno Python. El Dockerfile separa las fases de construcción y ejecución, y **no incluye `pip` ni sus dependencias vendorizadas en el entorno virtual final**. Los controles siguen configurados para fallar ante vulnerabilidades HIGH/CRITICAL corregibles.

### Política de seguridad

No se utiliza `continue-on-error` para ocultar fallos, ni se omite el escaneo. Las nuevas alertas deben tratarse actualizando o reemplazando los paquetes afectados y repitiendo el pipeline.

Para evidencias de una nueva evaluación, utilizar el último run de **CI - Calidad y Seguridad** del commit que se vaya a entregar.
