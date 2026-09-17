import json
import os
from typing import Any
import pdfplumber
import requests
from dotenv import load_dotenv
from schemas import ObligationList, ObligationItem

load_dotenv()

def parse_pdf(file_path: str) -> str:
    """Extract raw text from an uploaded clearance PDF."""
    full_text = []
    with pdfplumber.open(file_path) as pdf:
        for idx, page in enumerate(pdf.pages):
            text = page.extract_text()
            if text:
                full_text.append(f"--- PAGE {idx + 1} ---\n{text}")
    return "\n".join(full_text)

def call_model(prompt: str) -> str:
    provider = os.getenv("AI_PROVIDER", "ollama").lower()
    session = requests.Session()

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
            timeout=180,
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
            timeout=180,
        )
        response.raise_for_status()
        return response.json()["choices"][0]["message"]["content"]

    raise ValueError(f"Unsupported AI_PROVIDER '{provider}'. Must be 'ollama' or 'nvidia'.")

def parse_model_json(content: str) -> dict[str, Any]:
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        start, end = content.find("{"), content.rfind("}")
        if start >= 0 and end > start:
            return json.loads(content[start : end + 1])
        return {"document_title": "Extracted Clearance", "issuing_authority": "DGMS / MoEFCC", "obligations": []}

def extract_obligations_from_text(raw_text: str) -> ObligationList:
    """Send text to local LLM or NVIDIA API with structured output prompt."""
    prompt = f"""You are an expert Indian mining statutory compliance officer (DGMS, MoEFCC, SPCB).
Analyze the clearance document text below and extract all enforceable legal obligations.

Return valid JSON with exactly this structure:
{{
  "document_title": "Title of the document",
  "issuing_authority": "Issuing Authority (e.g., DGMS, MoEFCC, SPCB)",
  "obligations": [
    {{
      "title": "Short title of obligation",
      "description": "Full requirement text",
      "cmr_2017_ref": "CMR 2017 clause if applicable or null",
      "oshwc_2020_ref": "OSHWC Code clause if applicable or null",
      "domain": "safety",
      "frequency": "daily",
      "responsible_role": "Mine Manager",
      "penalty_summary": "Penalty if defaulted"
    }}
  ]
}}

Document text:
{raw_text[:12000]}
"""

    raw_response = call_model(prompt)
    data = parse_model_json(raw_response)
    
    # Ensure items conform to ObligationList model
    obligations = []
    for item in data.get("obligations", []):
        if isinstance(item, dict):
            obligations.append(ObligationItem(
                title=item.get("title", "Statutory Requirement"),
                description=item.get("description", ""),
                cmr_2017_ref=item.get("cmr_2017_ref"),
                oshwc_2020_ref=item.get("oshwc_2020_ref"),
                domain=item.get("domain", "safety"),
                frequency=item.get("frequency", "daily"),
                responsible_role=item.get("responsible_role", "Mine Manager"),
                penalty_summary=item.get("penalty_summary")
            ))

    return ObligationList(
        document_title=data.get("document_title", "Statutory Clearance Document"),
        issuing_authority=data.get("issuing_authority", "DGMS / MoEFCC / SPCB"),
        obligations=obligations
    )
