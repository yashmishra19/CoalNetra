import os
import pdfplumber
from dotenv import load_dotenv
from google import genai
from schemas import ObligationList

load_dotenv()

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

def parse_pdf(file_path: str) -> str:
    """Extract raw text from an uploaded clearance PDF."""
    full_text = []
    with pdfplumber.open(file_path) as pdf:
        for idx, page in enumerate(pdf.pages):
            text = page.extract_text()
            if text:
                full_text.append(f"--- PAGE {idx + 1} ---\n{text}")
    return "\n".join(full_text)

def extract_obligations_from_text(raw_text: str) -> ObligationList:
    """Send text to Gemini with structured output enforcement."""
    prompt = f"""
    You are an expert Indian mining statutory compliance officer (DGMS, MoEFCC, SPCB).
    Analyze the following clearance document text and extract all enforceable legal obligations.
    
    Ignore standard preambles and background notes. Focus only on conditions using mandatory language 
    like 'shall', 'must', 'strictly adhere to', or 'required to'.
    
    Document text:
    {raw_text[:12000]}
    """

    response = client.models.generate_content(
        model="gemini-3.6-flash",
        contents=prompt,
        config={
            "response_mime_type": "application/json",
            "response_schema": ObligationList,
        },
    )
    
    return ObligationList.model_validate_json(response.text)