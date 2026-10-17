# GM Components

Aplicación de análisis de compatibilidad de hardware desarrollada con Python y Streamlit. Consulta un catálogo de componentes y combina búsqueda semántica (FAISS), búsqueda web y un modelo de lenguaje de Groq. También guarda los análisis realizados para poder reutilizarlos.

## Estructura del proyecto

| Archivo o carpeta | Descripción |
| --- | --- |
| `app.py` | Interfaz Streamlit |
| `agent.py` | Flujo principal de análisis |
| `services/` | Consulta web, búsqueda semántica y Groq |
| `memory/` | Historial y persistencia de análisis |
| `observability/` | Registro de trazas y métricas |
| `tests/` | Pruebas automatizadas |
| `Dockerfile`, `docker-compose.yml` | Imagen y configuración del contenedor |

## Ejecutar el proyecto

Para ejecutarlo con Docker:

```bash
docker compose config
docker compose up -d --build
docker compose ps
```

Abrir `http://localhost:8501`. El endpoint `http://localhost:8501/_stcore/health` permite comprobar que Streamlit está activo.

Para detenerlo:

```bash
docker compose down
```

Las funciones que consultan Groq y SerpAPI requieren claves válidas en las variables `GROQ_API_KEY` y `SERP_API_KEY`. El modelo de embeddings ONNX se descarga en el primer uso, por lo que puede requerirse conexión a internet.

Para ejecutar las pruebas fuera de Docker:

```bash
python -m pip install -r requirements.txt
python -m pytest tests/ -v
```

## CI y controles de seguridad

El workflow `.github/workflows/ci.yml` se ejecuta en GitHub Actions al abrir un pull request hacia `main` o `develop`, al enviar cambios a esas ramas y cuando se inicia manualmente.

Contiene tres trabajos:

- **Pruebas automatizadas:** ejecuta PyTest.
- **Snyk:** revisa las dependencias del contenedor y bloquea vulnerabilidades de severidad alta o crítica.
- **Docker Build y Trivy:** valida Compose, construye la imagen, comprueba las dependencias del entorno y examina la imagen con Trivy.

Para Snyk se necesita el secreto `SNYK_TOKEN` en **Settings → Secrets and variables → Actions**.

El workflow no levanta un servidor permanente ni publica la aplicación. Para probar el servicio hay que ejecutarlo con Docker Compose y utilizar la interfaz. El contenedor utiliza un usuario sin privilegios; se construye en varias etapas y su entorno de ejecución no incluye `pip` ni otras herramientas de instalación que no necesita. Los embeddings se calculan con FastEmbed (ONNX) y el índice vectorial se administra con FAISS.

Dependabot revisa periódicamente las dependencias y las acciones de GitHub. Las actualizaciones se integran después de revisar sus cambios y las pruebas.

## Trabajo en Git

Usamos GitFlow para separar el trabajo estable de las funciones en desarrollo.

| Rama | Uso |
| --- | --- |
| `main` | Versión estable |
| `develop` | Integración de cambios revisados |
| `feature/*` | Funciones nuevas |
| `hotfix/*` | Correcciones urgentes |

Los cambios se revisan mediante pull requests. Como norma de trabajo, cada PR describe qué se modificó, requiere la revisión de otro integrante y debe aprobar las comprobaciones de GitHub Actions antes de integrarse.

Los commits siguen una convención simple: `feat` para nuevas funciones, `fix` para correcciones, `docs` para documentación, `ci` para el pipeline y `refactor` para reorganización de código.

## Uso de Inteligencia Artificial

Se utilizó Claude (Anthropic) como apoyo para resolver errores de configuración del pipeline de CI/CD, corregir dependencias en `requirements.txt`, y documentar las convenciones del proyecto. Las decisiones de diseño y las conclusiones individuales fueron elaboradas por los propios integrantes.

## Reflexiones del equipo
**Nicolás Troncoso**
Al principio me costó entender GitFlow, sobre todo diferenciar main de develop y saber desde qué rama debía crear cada tipo de trabajo (feature o hotfix). Un momento que me ayudó a entenderlo de verdad fue cuando tuvimos que resolver un conflicto de merge en requirements.txt, donde dos cambios distintos (un hotfix mío y una actualización de mi compañero) chocaban en el mismo archivo — ahí entendí en la práctica por qué Git necesita que alguien decida manualmente qué versión final debe quedar. También aprendí lo importante que es revisar el código de otra persona antes de integrarlo: no es solo un trámite, sino una forma real de detectar errores o inconsistencias antes de que lleguen a producción.

**Álvaro Eyzaguirre**
Durante el desarrollo del proyecto pude aprender y aplicar GitFlow para organizar el trabajo con mi compañero. Lo que más me gustó fue la forma en que se puede revisar y aprobar el código de otra persona antes de integrarlo, ya que permite tener un mayor control sobre los cambios realizados. Esta experiencia me ayudó a entender mejor cómo GitFlow facilita el trabajo colaborativo y la integración del código entre los integrantes del equipo.

## Registros de pruebas

Las ejecuciones y los resultados de seguridad quedan disponibles en la pestaña **Actions** del repositorio. El detalle técnico de la remediación de dependencias está en `docs/ep2_security_findings.md`.
