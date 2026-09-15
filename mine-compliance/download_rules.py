"""Download the two coal-mining regulation PDFs used by this pipeline."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from urllib.parse import urljoin

import requests
from dotenv import load_dotenv


MINEMOUNTAIN_PAGE = "https://minemountain.in/mining/coal-mines-regulation-2017"
MINEMOUNTAIN_PDF = "https://minemountain.in/assets/uploads/Coal_Mines_Regulation,_2017_52331785478411.pdf"
DGMS_PDF = "https://www.dgms.gov.in/writereaddata/UploadFile/Coal_Mines_Regulation_1957.pdf"
DEFAULT_OUTPUT = Path("data/rules")


@dataclass(frozen=True)
class SourceDocument:
    title: str
    year: int
    source_page: str
    source_url: str
    filename: str
    local_file: str = ""
    status: str = "pending"


SOURCES = (
    SourceDocument(
        title="Coal Mines Regulations, 2017",
        year=2017,
        source_page=MINEMOUNTAIN_PAGE,
        source_url=MINEMOUNTAIN_PDF,
        filename="coal_mines_regulations_2017.pdf",
    ),
    SourceDocument(
        title="Coal Mines Regulations, 1957",
        year=1957,
        source_page=DGMS_PDF,
        source_url=DGMS_PDF,
        filename="coal_mines_regulations_1957.pdf",
    ),
)


def discover_minemountain_pdf(session: requests.Session) -> str:
    response = session.get(MINEMOUNTAIN_PAGE, timeout=30)
    response.raise_for_status()
    matches = re.findall(r"(?:href|src)=[\"']([^\"']+\.pdf[^\"']*)", response.text, re.IGNORECASE)
    for link in matches:
        absolute_url = urljoin(MINEMOUNTAIN_PAGE, link)
        if "Coal_Mines_Regulation" in absolute_url:
            return absolute_url
    raise RuntimeError("Could not find the Coal Mines Regulations 2017 PDF on MineMountain")


def download_sources(session: requests.Session, output: Path, dry_run: bool) -> list[SourceDocument]:
    output.mkdir(parents=True, exist_ok=True)
    documents: list[SourceDocument] = []
    minemountain_pdf = discover_minemountain_pdf(session)
    for source in SOURCES:
        source_url = minemountain_pdf if source.year == 2017 else source.source_url
        target = output / source.filename
        document = SourceDocument(**{**asdict(source), "source_url": source_url, "local_file": str(target)})
        if target.exists():
            documents.append(SourceDocument(**{**asdict(document), "status": "exists"}))
            continue
        if dry_run:
            documents.append(SourceDocument(**{**asdict(document), "status": "planned"}))
            continue
        with session.get(source_url, stream=True, timeout=60) as response:
            response.raise_for_status()
            content_type = response.headers.get("Content-Type", "").lower()
            if not ("application/pdf" in content_type or source_url.lower().endswith(".pdf")):
                raise RuntimeError(f"Expected a PDF from {source_url}, received {content_type or 'unknown content'}")
            with target.open("wb") as file_handle:
                for chunk in response.iter_content(chunk_size=1024 * 128):
                    if chunk:
                        file_handle.write(chunk)
        documents.append(SourceDocument(**{**asdict(document), "status": "downloaded"}))
    return documents


def main() -> None:
    load_dotenv()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    session = requests.Session()
    session.headers.update({"User-Agent": "sih-compliance-pipeline/1.0"})
    documents = download_sources(session, args.output, args.dry_run)
    index_path = args.output / "index.json"
    index_path.write_text(
        json.dumps([asdict(document) for document in documents], ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"Processed exactly {len(documents)} documents; index written to {index_path}")


if __name__ == "__main__":
    main()