from typing import List, Optional
from pydantic import BaseModel, Field

class ObligationItem(BaseModel):
    title: str = Field(description="Short summary title of the statutory obligation")
    description: str = Field(description="Detailed requirement or condition text extracted from the document")
    cmr_2017_ref: Optional[str] = Field(None, description="Relevant Coal Mines Regulation 2017 clause reference, e.g. Reg 104")
    oshwc_2020_ref: Optional[str] = Field(None, description="Relevant OSHWC Code reference if applicable")
    domain: str = Field("safety", description="Domain: safety, environment, labour, or production")
    frequency: str = Field("daily", description="Frequency: daily, weekly, monthly, quarterly, bi-annually, annually, or as_required")
    responsible_role: str = Field("Mine Manager", description="Role responsible for compliance, e.g., Mine Manager, Overman, Safety Officer")
    penalty_summary: Optional[str] = Field(None, description="Statutory penalty or consequence if defaulted")

class ObligationList(BaseModel):
    document_title: str = Field(description="Name or title of the statutory clearance document")
    issuing_authority: str = Field(description="Issuing authority, e.g., DGMS, MoEFCC, SPCB")
    obligations: List[ObligationItem] = Field(default_factory=list)
