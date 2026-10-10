## Estrategia de ramificación: GitFlow

Se optó por GitFlow como modelo de ramificación:

- **main**: código estable, listo para producción.
- **develop**: rama de integración, concentra el trabajo ya revisado antes del release.
- **feature/<nombre>**: nuevas funcionalidades, se crean desde `develop` y se integran hacia `develop` vía Pull Request.
- **hotfix/<nombre>**: correcciones urgentes, se crean desde `main` y se integran hacia `main` y `develop`.

## Convenciones de commits

Se utiliza el formato de Conventional Commits:


| Tipo       | Uso                                              |
|------------|---------------------------------------------------|
| feat       | Nueva funcionalidad                               |
| fix        | Corrección de errores                             |
| docs       | Cambios en documentación                          |
| ci         | Cambios en configuración de CI/CD                 |
| refactor   | Cambios de código que no alteran comportamiento   |

## Naming de ramas

| Prefijo    | Uso                                     | Ejemplo                              |
|------------|------------------------------------------|----------------------------------------|
| feature/   | Nueva funcionalidad                       | feature/observability-tracing          |
| hotfix/    | Corrección urgente sobre producción       | hotfix/fix-requirements                |
| develop    | Rama de integración (única, permanente)   | —                                       |
| main       | Rama de producción (única, permanente)    | —                                       |

## Flujo de merge

1. Las ramas `feature/*` se crean desde `develop` y se integran hacia `develop` mediante Pull Request.
2. Las ramas `hotfix/*` se crean desde `main` y se integran hacia `main` y `develop`.
3. Ningún cambio se sube directo a `main` o `develop`: todo pasa por Pull Request.
4. El pipeline de GitHub Actions (`.github/workflows/ci.yml`) se ejecuta en cada push a `develop`/`main` y en cada Pull Request hacia esas ramas.

## Estrategia de revisión (Pull Requests)

- Todo Pull Request debe tener al menos 1 revisor antes de aprobarse.
- El PR debe incluir una descripción breve de qué cambia y por qué.
- El revisor valida que el código cumple su propósito, los tests pasan (verificado automáticamente por GitHub Actions), y las convenciones de nombres y commits se respetan.

## Pipeline de Integración Continua (CI)

El archivo `.github/workflows/ci.yml` automatiza:

1. Descarga del código (checkout).
2. Configuración del entorno Python 3.11.
3. Instalación de dependencias (`pip install -r requirements.txt`).
4. Ejecución de la batería de pruebas (`python -m pytest tests/`).

## Uso de Inteligencia Artificial

Se utilizó Claude (Anthropic) como apoyo para resolver errores de configuración del pipeline de CI/CD, corregir dependencias en `requirements.txt`, y documentar las convenciones del proyecto. Las decisiones de diseño y las conclusiones individuales fueron elaboradas por los propios integrantes.


##Reflexiones##
[Nicolás Troncoso]
Al principio me costó entender GitFlow, sobre todo diferenciar main de develop y saber desde qué rama debía crear cada tipo de trabajo (feature o hotfix). Un momento que me ayudó a entenderlo de verdad fue cuando tuvimos que resolver un conflicto de merge en requirements.txt, donde dos cambios distintos (un hotfix mío y una actualización de mi compañero) chocaban en el mismo archivo — ahí entendí en la práctica por qué Git necesita que alguien decida manualmente qué versión final debe quedar. También aprendí lo importante que es revisar el código de otra persona antes de integrarlo: no es solo un trámite, sino una forma real de detectar errores o inconsistencias antes de que lleguen a producción.

[Álvaro Eyzaguirre]
Durante el desarrollo del proyecto pude aprender y aplicar GitFlow para organizar el trabajo con mi compañero. Lo que más me gustó fue la forma en que se puede revisar y aprobar el código de otra persona antes de integrarlo, ya que permite tener un mayor control sobre los cambios realizados. Esta experiencia me ayudó a entender mejor cómo GitFlow facilita el trabajo colaborativo y la integración del código entre los integrantes del equipo.


## EP2 — Calidad, seguridad y despliegue con contenedores

### Proceso automatizado
- **CI:** `.github/workflows/ci.yml` instala dependencias y ejecuta `python -m pytest tests/ -v`.
- **Análisis Snyk:** `seguridad-dependencias` inspecciona `requirements-docker.txt`; las vulnerabilidades **HIGH/CRITICAL** producen fallo. Este job depende de las pruebas.
- **Imagen Docker:** después de PyTest, el job independiente **Docker Build y Trivy** construye `gmcomponents-ev2:latest` y busca vulnerabilidades HIGH/CRITICAL corregibles, incluso si Snyk detecta problemas. El despliegue requiere que terminen exitosamente tanto Snyk como Trivy.
- **Entrega simulada:** solo después de pasar ambos escaneos se reconstruye la imagen en el job de despliegue y se ejecuta `docker compose up -d --no-build`, comprobando el endpoint `/_stcore/health`.
- **Orquestación:** `docker-compose.yml` gestiona la aplicación Streamlit, reinicio, healthcheck y límites de **1 CPU / 2 GiB RAM**. El Dockerfile usa un usuario sin privilegios.
- **Dependabot:** `.github/dependabot.yml` revisa semanalmente dependencias pip, GitHub Actions y Docker. Crea PRs que deben revisarse; no actualiza ni bloquea automáticamente por sí solo.

### Configuración imprescindible (una vez)
1. Crear una cuenta/proyecto en [Snyk](https://snyk.io/) y obtener un token API personal.
2. En este repositorio: **Settings → Secrets and variables → Actions → New repository secret**; nombre exacto `SNYK_TOKEN`, valor el token. **Nunca publicarlo en archivos ni mensajes.**
3. Abrir un Pull Request hacia `main` o `develop`. Revisar que los jobs `Pruebas automatizadas`, `Snyk - dependencias` y `Docker Build y Deploy` pasen.
4. Si Snyk/Trivy encuentran vulnerabilidades, resolverlas actualizando la dependencia o justificando y gestionando una excepción revisada; **no omitir el escaneo ni poner `continue-on-error`**.

### Pruebas locales
```bash
python -m pip install -r requirements.txt
python -m pytest tests/ -v
docker compose config
docker compose build
docker compose up -d
docker compose ps
docker compose down
```

### Trazabilidad y evidencia para la rúbrica
Cada push y Pull Request en `main`/`develop` registra su commit, actor, resultado y logs en **Actions → CI-CD**. El despliegue simulado ocurre solamente si terminan satisfactoriamente las pruebas y escaneos. Adjuntar capturas de los jobs, el healthcheck y un ejemplo de bloqueo ante fallo en el informe o en `docs/` si el docente lo pide.

**Nota:** esta documentación describe la configuración propuesta; su ejecución integral debe verificarse después de instalar `SNYK_TOKEN`. No constituye evidencia de un run exitoso por sí sola.
