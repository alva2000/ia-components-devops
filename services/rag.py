"""Búsqueda semántica RAG con embeddings ONNX (FastEmbed) y FAISS."""
import numpy as np
import faiss
from utils.embeddings import embed_text, embed_batch


class RAG:
    def __init__(self):
        self.textos: list[str] = []
        self.index = None

    def construir_indice(self, productos: list[dict]) -> None:
        self.textos = [
            f"{p.get('categoria', '')} {p.get('nombre', '')} {p.get('descripcion', '')}"
            for p in productos
        ]
        if not self.textos:
            self.index = None
            return
        embeddings = np.asarray(embed_batch(self.textos), dtype="float32")
        self.index = faiss.IndexFlatL2(embeddings.shape[1])
        self.index.add(embeddings)

    def buscar(self, query: str, k: int = 3) -> str:
        if self.index is None or not self.textos:
            return "Índice RAG no construido."
        vector = np.asarray([embed_text(query)], dtype="float32")
        k = max(1, min(k, len(self.textos)))
        _, indices = self.index.search(vector, k)
        return "\n".join(self.textos[int(i)] for i in indices[0] if 0 <= int(i) < len(self.textos))
