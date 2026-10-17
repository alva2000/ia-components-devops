"""Embeddings semánticos con FastEmbed ONNX, sin PyTorch/transformers.

Se inicializa bajo demanda para no descargar modelos al importar módulos.
"""
from functools import lru_cache
import numpy as np

MODEL = "sentence-transformers/all-MiniLM-L6-v2"


@lru_cache(maxsize=1)
def _get_model():
    from fastembed import TextEmbedding
    return TextEmbedding(model_name=MODEL)


def embed_batch(texts: list[str]):
    if not texts:
        return np.empty((0, 384), dtype="float32")
    return np.asarray(list(_get_model().embed(texts)), dtype="float32")


def embed_text(text: str):
    return embed_batch([text])[0]
