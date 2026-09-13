"""Analyze downloaded mining rules with a local or NVIDIA-hosted model."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from typing import Any

import pymupdf
import requests
from dotenv import load_dotenv


load_dotenv()

PROMPT = """You are a compliance analyst for India's mining sector.
Analyze the supplied rule text and return valid JSON with exactly these keys:
title, effective_date, applies_to, obligations, deadlines, penalties, exceptions, source_sections.
Use arrays for obligations, deadlines, penalties, exceptions, and source_sections.
Do not invent facts. Use null when a scalar value is not stated.

Rule text:
{document}
"""


def extract_text(pdf_path: Path) -> str:
    with pymupdf.open(pdf_path) as pdf:
        pages = [page.get_text("text") for page in pdf]
    return "\n\n".join(pages).strip()


def chunks(text: str, size: int = 12000) -> list[str]:
    return [text[index : index + size] for index in range(0, len(text), size)] or [""]


def call_model(provider: str, prompt: str, session: requests.Session) -> str:
    if provider == "ollama":
        base_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434").rstrip("/")
        model = os.getenv("OLLAMA_MODEL", "llama3.2:3b")
        response = session.post(
            f"{base_url}/api/chat",
            json={
                "model": model,
                "messages": [{"role": "user", "content": prompt}],
                "stream": False,
                "format": "json",
            },
            timeout=300,
        )
        response.raise_for_status()
        return response.json()["message"]["content"]

    if provider == "nvidia":
        api_key = os.getenv("NVIDIA_API_KEY")
        if not api_key:
            raise RuntimeError("NVIDIA_API_KEY is missing from .env")
        base_url = os.getenv("NVIDIA_BASE_URL", "https://integrate.api.nvidia.com/v1").rstrip("/")
        model = os.getenv("NVIDIA_MODEL", "meta/llama-3.1-8b-instruct")
        response = session.post(
            f"{base_url}/chat/completions",
            headers={"Authorization": f"Bearer {api_key}"},
            json={
                "model": model,
                "messages": [{"role": "user", "content": prompt}],
                "temperature": 0.1,
                "max_tokens": 2048,
                "stream": False,
            },
            timeout=300,
        )
        response.raise_for_status()
        return response.json()["choices"][0]["message"]["content"]

    raise ValueError("AI_PROVIDER must be either 'ollama' or 'nvidia'")


def parse_model_json(content: str) -> dict[str, Any]:
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        start, end = content.find("{"), content.rfind("}")
        if start >= 0 and end > start:
            return json.loads(content[start : end + 1])
        return {"raw_response": content}


def analyze_pdf(pdf_path: Path, provider: str, session: requests.Session) -> dict[str, Any]:
    text_chunks = chunks(extract_text(pdf_path))
    analyses = [
        parse_model_json(call_model(provider, PROMPT.format(document=part), session))
        for part in text_chunks
    ]
    return {"file": pdf_path.name, "provider": provider, "chunks": analyses}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=Path("data/rules"))
    parser.add_argument("--output", type=Path, default=Path("data/analysis"))
    parser.add_argument(
        "--provider", choices=("ollama", "nvidia"), default=os.getenv("AI_PROVIDER", "ollama")
    )
    parser.add_argument("--limit", type=int, default=0, help="Analyze only the first N PDFs; 0 means all")
    args = parser.parse_args()

    pdfs = sorted(args.input.glob("*.pdf"))
    if args.limit:
        pdfs = pdfs[: args.limit]
    if not pdfs:
        raise SystemExit(f"No PDFs found in {args.input}")

    args.output.mkdir(parents=True, exist_ok=True)
    session = requests.Session()
    for pdf_path in pdfs:
        destination = args.output / f"{pdf_path.stem}.json"
        if destination.exists():
            print(f"Skipping {pdf_path.name} (already analyzed)")
            continue
        result = analyze_pdf(pdf_path, args.provider, session)
        destination.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"Analyzed {pdf_path.name}")


if __name__ == "__main__":
    main()