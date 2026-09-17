import os
import tempfile
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

from extractor import parse_pdf, extract_obligations_from_text
from schemas import ObligationList

load_dotenv()

app = FastAPI(
    title="KoylaNetra AI Compliance Pipeline",
    description="AI Engine to extract statutory obligations from mining clearance PDFs via Ollama Local LLM or NVIDIA API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    provider = os.getenv("AI_PROVIDER", "ollama").lower()
    nvidia_key = os.getenv("NVIDIA_API_KEY")
    ollama_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
    return {
        "status": "healthy",
        "service": "KoylaNetra AI Compliance Pipeline",
        "ai_provider": provider,
        "nvidia_configured": bool(nvidia_key and len(nvidia_key) > 5),
        "ollama_base_url": ollama_url,
        "ollama_model": os.getenv("OLLAMA_MODEL", "llama3.2:3b"),
        "nvidia_model": os.getenv("NVIDIA_MODEL", "meta/llama-3.1-8b-instruct")
    }

@app.post("/extract", response_model=ObligationList)
async def extract_obligations(file: UploadFile = File(...)):
    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are supported")

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
            content = await file.read()
            tmp.write(content)
            tmp_path = tmp.name

        raw_text = parse_pdf(tmp_path)
        os.remove(tmp_path)

        if not raw_text.strip():
            raise HTTPException(status_code=422, detail="No readable text found in PDF")

        result = extract_obligations_from_text(raw_text)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI Extraction failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
