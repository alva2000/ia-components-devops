# Evidencia de seguridad — EP2 DOY0101

## Ejecución registrada

- GitHub Actions: [CI-CD #](https://github.com/alva2000/ia-components-devops/actions/runs/38052112830) — revisar el enlace para confirmar identificador y logs de la corrida.
- Resultado del job `Pruebas automatizadas`: **success**.
- Resultado del job `Snyk - dependencias`: **failure** (exit code 1).
- Resultado del job `Docker Build y Deploy`: **skipped**, porque el análisis es una condición obligatoria previa.
- Se analizó `requirements-docker.txt` en el entorno Python 3.11.

## Hallazgos verificados en el log de Snyk

- 85 dependencias revisadas; **9 vulnerabilidades HIGH**, 9 rutas vulnerables.
- `torch@2.14.1`: 1 vulnerabilidad de deserialización de datos no confiables (SNYK-PYTHON-TORCH-15746467).
- `transformers@5.19.0`: 8 vulnerabilidades de inyección de código, deserialización y autorización (ver los identificadores en los logs de Snyk).
- Ambas son dependencias transitivas de `sentence-transformers@6.1.0`.
- Snyk reporta **"No upgrade or patch available"** en cada hallazgo.

## Decisión de seguridad

**Mantener el bloqueo por HIGH/CRITICAL.** No emplear `continue-on-error`, `exit-code: 0`, ignorar los hallazgos sin análisis ni reducir artificialmente el umbral de gravedad.

Para avanzar con el despliegue, el equipo debe revisar si las vulnerabilidades son explotables en su arquitectura, investigar versiones corregidas cuando se publiquen, o replantear el uso de las bibliotecas afectadas sin sacrificar la funcionalidad. Cualquier excepción requiere documentación y aprobación explícita, no una supresión silenciosa.

Esta ejecución **demuestra el control de bloqueo** exigido por IE3, pero **no demuestra** un despliegue exitoso con el nuevo pipeline. Tampoco se ha ejecutado Trivy en esta corrida: el job de Docker fue omitido.

## Registro y trazabilidad

Referencia de código: `feature/ep2-quality-security` en el fork `alva2000/ia-components-devops`.

Actualizar esta evidencia después de cada nueva ejecución. La decisión técnica y reflexión crítica deben ser redactadas por los estudiantes según la pauta de la asignatura.
