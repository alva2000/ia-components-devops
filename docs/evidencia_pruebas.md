# Pruebas del proyecto

Las pruebas están en la carpeta `tests/` y se ejecutan con PyTest.

## Cobertura

- `test_observability.py`: escritura de trazas JSONL, resumen de métricas y tolerancia a registros inválidos.
- `test_memory_manager.py`: historial y persistencia de análisis.
- `test_web_search.py`: consulta y respuesta de búsqueda web con solicitudes simuladas.
- `test_rag.py`: creación del índice vectorial y recuperación de resultados con embeddings controlados.

## Ejecución

```bash
python -m pytest tests/ -v
python scripts/analyze_logs.py
```

La aplicación también se puede comprobar desde `http://localhost:8501` después de iniciar Docker Compose.

## Resultados

Los resultados de cada cambio se encuentran en **GitHub Actions → CI - Calidad y Seguridad**. El job de pruebas utiliza Python 3.11 y publica el resultado en el registro de ejecución. El análisis de trazas permite comprobar los indicadores de observabilidad por separado.
