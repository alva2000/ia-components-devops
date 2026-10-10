"""Tests de contrato RAG, con embeddings deterministas sin descarga de modelos."""
from unittest.mock import patch
import numpy as np
from services.rag import RAG


def fake_batch(texts):
    return np.asarray([[float("gpu" in text.lower()), float("cpu" in text.lower())] for text in texts], dtype="float32")


def fake_text(text):
    return fake_batch([text])[0]


def test_empty_index():
    rag = RAG()
    rag.construir_indice([])
    assert rag.buscar("gpu") == "Índice RAG no construido."


def test_query_returns_related_catalog_item():
    rag = RAG()
    with patch("services.rag.embed_batch", side_effect=fake_batch), patch("services.rag.embed_text", side_effect=fake_text):
        rag.construir_indice([
            {"categoria": "GPU", "nombre": "Tarjeta gráfica", "descripcion": "gpu"},
            {"categoria": "CPU", "nombre": "Procesador", "descripcion": "cpu"},
        ])
        result = rag.buscar("gpu", k=1)
    assert "Tarjeta gráfica" in result


def test_top_k_limited_by_catalog_size():
    rag = RAG()
    with patch("services.rag.embed_batch", side_effect=fake_batch), patch("services.rag.embed_text", side_effect=fake_text):
        rag.construir_indice([{"categoria": "CPU", "nombre": "A"}])
        result = rag.buscar("cpu", k=50)
    assert result.count("CPU") == 1
