# Mine Compliance Mobile App - Project Details


The Indian coal mining sector involves large-scale operations spread across multiple subsidiaries, mine sites, contractors, regulatory bodies, and field offices. Governance-related activities such as statutory compliance monitoring, inspection tracking, safety observations, production reporting, environmental monitoring, worker attendance, contract management, grievance handling, and regulatory reporting are often managed through fragmented systems, manual documentation, spreadsheets, and delayed reporting mechanisms.

This leads to challenges such as data inconsistency, delayed decision-making, limited transparency, compliance gaps, duplication of records, weak monitoring of field-level activities, and difficulty in obtaining real-time operational insights. With increasing focus on transparency, accountability, sustainability, and digital governance, there is a need for an integrated smart governance platform specifically designed for the coal mining ecosystem.

Defining the Problem:

Develop a centralized AI-enabled governance and compliance monitoring platform for coal mining operations that can digitally integrate mine-level activities, statutory compliance, inspections, contractor management, and operational reporting.

The proposed solution should:

• Digitally track statutory compliance requirements related to safety, environment, production, and labour regulations.
• Enable real-time monitoring of inspections, observations, violations, and corrective actions.
• Use AI/analytics to identify high-risk areas, recurring compliance failures, and operational anomalies.
• Provide geo-tagged and time-stamped field reporting through mobile applications.
• Integrate dashboards for mine officials, corporate management, and regulatory authorities.
• Generate automated alerts, reminders, compliance reports, and escalation mechanisms.
• Minimize manual paperwork and improve transparency, accountability, and decision-making.
• Be scalable for deployment across multiple mines and subsidiaries.
• Participants may use AI/ML, mobile applications, GIS mapping, OCR/document digitization, workflow automation, blockchain-based audit trails, or multilingual conversational interfaces as part of the solution.

The proposed system is expected to:

• Improve governance efficiency and transparency in coal mining operations.
• Reduce delays and errors in compliance management and reporting.
• Enable data-driven monitoring and faster administrative decision-making.
• Strengthen accountability and real-time tracking of field activities.
• Support digital transformation and paperless governance in the mining sector.
• Create a scalable indigenous e-governance framework for Indian coal mines. Expected Solution:

The proposed solution should be a centralized AI-enabled smart governance platform for coal mines that integrates compliance monitoring, inspection management, operational reporting, contractor management, and field activity tracking into a single digital ecosystem. The system should provide real-time visibility, automated workflows, and data-driven insights through web and mobile applications to improve transparency, accountability, and decision-making across multiple mining sites and subsidiaries.

• Centralized dashboard for mine officials, corporate management, and regulatory authorities with real-time compliance and operational monitoring.
• AI/analytics engine to detect compliance risks, operational anomalies, recurring violations, and generate predictive alerts.
• Geo-tagged mobile application for field inspections, safety observations, attendance, and incident reporting with offline support.
• Automated workflow system for alerts, reminders, escalations, digital approvals, and statutory report generation.
• GIS mapping, OCR-based document digitization, and secure digital audit trails for transparent and paperless governance.

## Problem Statement
AI-Based Smart Governance and Compliance Monitoring System for Coal Mines

## Planned Features & Requirements
USER ACCESSS: 
MINE OFFICIALS
mine manager
safety officer
environment officer

FIELD STAFF
sirdar
overman
field inspector

CONTRACTOR

WORKER
permanent/contract basis - grievance file/ attendance

CORPERATE
area
subsidiary headquarters

REGULATORS

AUDITS
5 bodies - SHMS, DGMS, MOEFCC,
SHMS - safety and health management -  annually
	coal controller organization (CCO)
DGMS - statutory annual mine return - annually
MOEFCC environmental clearance audit (ECA) - bi-annually
state pollution control board
DGMS/MHA - mine safety inspection -  4times a year - underground - bi-annually - open caste
CAG - financial/CAG performance audit - annually/triggered based
daily/weekly audit - mines24hour

5 working bodies - SHMS, DGMS, MOEFCC,

subsidiary - 85 areas
SECL - south eastern coal field limited
MCL -
Westen Coal field limited
ECL - eastern coal field limited
BCCL -
CCL -
NCL -
## Additional Notes
AS PER PER MY UNDERSTANDING THE AND DISCUSSION DONE WITH CLAUDE -
🏗️ SIH 2026 · PS 6024 — Deep Analysis
AI-Based Smart Governance & Compliance Monitoring System for Coal Mines

Ministry of Coal · Coal India Limited · Category: Software · Theme: Smart Automation

⚡ Verdict up front: This is a high-ceiling, high-trap PS. The domain is genuinely under-digitised and the sponsor is serious, but the wording is generic enough that 80% of teams will build a pretty CRUD dashboard and lose. The winning move is to go narrow and deep on one thing nobody else will build: turning unstructured statutory documents into a machine-readable obligation graph, plus tamper-resistant field evidence. Everything else is scaffolding.

1️⃣ Pain Points & Core Understanding 🔎
🎯 What exactly is the problem?

Not "coal mines are unsafe." The problem is that compliance obligations and the evidence of compliance live in different universes.

A single working coal mine is simultaneously answerable to at least five different regulatory regimes, each with its own portal, format, and cadence:

Regulator	Instrument	What's owed	Current state
🦺 DGMS (Min. of Labour)	Mines Act 1952, Mines Rules 1955, Coal Mines Regulations 2017	Safety Management Plan, inspections, accident reports, annual returns	Partially online
🌳 MoEFCC	EC letters via PARIVESH	Six-monthly EC compliance reports	PDF uploads
💨 CPCB / SPCB	Air Act 1981, Water Act 1974, CTO	OCEMS real-time emission/effluent data	Sensor telemetry
⛏️ Ministry of Coal / CCO	Coal production returns	Production, dispatch, grade	ERP / spreadsheets
👷 Labour	CLRA 1970, wage codes, VT Rules 1966	Contractor licences, attendance, training, PME	Mostly paper

DGMS enforces the Mines Act 1952, Mines Rules 1955, Coal Mines Regulations 2017 and Metalliferous Mines Regulations 1961, with requirements spanning approved safety management plans, mandatory safety committees, daily safety rounds by the mine manager, dust and noise monitoring, and annual Form M returns. 
iCeipts
 None of these five systems share a common mine identifier. That single architectural absence is the root of the "data inconsistency" and "duplication of records" the PS complains about.

🧨 Why does this problem exist? (Root causes — say these on your slide)
🔀 Regulatory federalism, not laziness. Safety sits with the Ministry of Labour (DGMS), environment with MoEFCC, production with the Ministry of Coal. Each digitised independently. There is no join key.
📄 Obligations are unstructured text. An Environmental Clearance letter is a 30-page PDF containing 60–100 conditions written in prose. Nothing in the system knows that condition 4(vii) means "submit a groundwater report every 6 months to the RO." MoEFCC itself noted that six-monthly reports arriving as PDFs at Regional Offices consumed considerable man-hours to evaluate. 
Environment Clearance
📶 Connectivity gap. Underground and remote opencast faces have no network. Field data goes onto paper first and into a system days later — so the "real-time" dashboard is structurally lying.
⚖️ Statutory paper anchoring. Mines legislation prescribes bound registers and physical forms. So sites run both paper and digital, doubling effort and creating divergence.
🙈 Self-reporting incentive conflict. The person recording a violation is often the person accountable for it. Under-reporting is rational.
🏗️ Contractor opacity. A very large share of the on-site workforce is contractual. Contractor attendance, training validity, and safety induction are the thinnest data layer in the entire ecosystem — and disproportionately represented in accident statistics.
🧩 Incomplete ERP coverage. Tech Mahindra completed SAP-ERP deployment for CIL in March 2025 across the corporate office, Mahanadi Coalfields, Western Coalfields and North-Eastern Coalfields — covering payroll, finance, materials management, personnel, production, sales and marketing. 
Fintechbiznews
 Note what's absent: statutory safety compliance, inspections, and EC conditions. And note that it's not yet all subsidiaries. This is your wedge, not your competitor.
👥 Stakeholder map (build personas from this, not from imagination)
Persona	What they actually need	Their pain today
Mine Manager / Agent ⛑️	"What's due from me today, and am I personally exposed?"	Statutory post-holders carry personal legal liability. They track it in a diary.
Safety Officer / ISO 🦺	Observation → corrective action → closure loop	Observations die in registers; no closure tracking
Environment Officer 🌿	60–100 EC conditions per mine, per cadence	Manually rebuilt every six months from the original PDF
Area GM / Subsidiary Dir (Tech) 📊	Cross-mine risk ranking	Gets a consolidated Excel, 2 weeks stale
CIL Corporate (Dir. Safety & Rescue) 🏢	Portfolio view across 8 states	Reconciliation, not insight
DGMS Inspector 🔍	Where to inspect next, with limited inspector strength	Inspection targeting is largely manual
Contractor supervisor 🚧	Prove workers are inducted & licensed	Paper gate registers
Worker / Workmen's Inspector / Safety Committee 👷‍♀️	Report a hazard without retaliation, in their own language	Realistically: no channel

💎 Insight most teams will miss: The worker and the regulator are the two personas everyone forgets. The PS explicitly names regulatory authorities as a dashboard audience. Build that third portal — it's cheap and it's a differentiator.

⚠️ Current inefficiencies, concretely
Same incident re-keyed into ≥3 systems (mine register → subsidiary MIS → DGMS return)
Compliance status is a point-in-time report, never a live state
Corrective actions have no SLA, no owner, no escalation
No cross-mine pattern detection: a haul-road violation recurring at 12 mines looks like 12 unrelated events
Regulator sees only what the proponent chooses to upload
2️⃣ Feasibility of Execution ⚙️
✅ Can you build this in a hackathon? Yes — if you scope brutally.

The functional surface in the PS (compliance + inspections + contractors + production + attendance + grievances + GIS + OCR + blockchain + chatbot) is a 3-year enterprise programme, not a 36-hour build. Attempting all of it is the single most common failure mode on this PS.

🗂️ Data & assets — where to get real data (this is your unfair advantage)
Asset	Source	Why it matters
📜 Real EC letters with conditions	PARIVESH (parivesh.nic.in) — public, downloadable	Your obligation-extraction corpus. Use actual CIL mine ECs.
📋 DGMS circulars & legislation	dgms.gov.in	Second corpus; Technical/Legislation circulars
📉 Accident statistics	DGMS + Ministry of Coal Annual Report Ch. 14 (coal.nic.in)	Real base rates for your risk model
🗺️ Leasehold boundaries	CMSMS / OCBIS concept (CMPDI)	Geofencing ground truth
🛰️ Satellite imagery	Sentinel-2 (free, Copernicus)	Independent verification layer
🗣️ Indian-language stack	Bhashini APIs	ASR/translation for Hindi, Bengali, Odia, Telugu

🔑 Say this on stage: "We did not synthesise our compliance corpus. We ingested N real Environmental Clearance letters for CIL mines from PARIVESH and M DGMS circulars." That one sentence beats a hundred fake records.

🧱 Realistic blockers
Blocker	Severity	Mitigation
No access to CIL internal data	🔴 High	Public corpora above + clearly labelled synthetic operational data
Accident data too sparse to predict fatalities	🔴 High	Don't predict accidents. Predict compliance failure & near-miss clustering. Defensible and honest.
SAP/legacy integration can't be demoed	🟡 Med	Ship a documented integration adapter + OData/REST mock; show the contract, not the connection
Digital records vs statutory paper validity	🟡 Med	Frame as parallel-run with e-Sign/DigiLocker, not replacement
Worker biometric/attendance data	🟡 Med	DPDP Act 2023 compliance slide — consent, purpose limitation, data minimisation
Government data can't sit on foreign clouds	🟡 Med	On-prem / NIC MeghRaj deployment story + self-hosted small LLM option
Offline sync conflicts	🟢 Low	CRDT or last-write-wins + server-side reconciliation queue
🏆 The MVP that actually wins (3 hero flows, nothing else)

Flow A — 📜 "PDF → Live Compliance Calendar" (your headline demo, 90 seconds)
Upload a real EC letter → OCR + LLM extraction → structured obligations {clause_ref, text, frequency, responsible_role, evidence_type, statute_source, due_rule} → auto-generated calendar with owners and SLAs → flag orphan obligations with no assigned owner and flag conflicting conditions across documents. This mirrors live research: recent work builds NLP/LLM pipelines that structure legal obligations from regulatory texts into knowledge graphs, 
ACM Other conferences
 and GPT-4-class models have been evaluated on detecting conflicts and contradictions inside regulatory requirement corpora. 
arxiv

Flow B — 📱 "Offline field capture with trust scoring" (your credibility demo)
Phone in airplane mode → inspector logs a safety observation with photo, GPS, timestamp, voice note in Hindi → queued locally → reconnect → syncs → appears on dashboard and auto-raises a corrective action with SLA + escalation ladder. Then show the trust score: mock-location detection, EXIF integrity, geofence check against leasehold boundary, capture-time vs sync-time drift.

Flow C — 📊 "Risk engine + regulator view"
Cross-mine recurrence analytics → risk-ranked mines/contractors/hazard-types → explainable (SHAP/feature attributions, never a black box) → regulator portal showing risk-based inspection targeting → one-click statutory report generation.

🎁 Bonus if time allows (in priority order): hash-chained audit ledger → multilingual voice reporting via Bhashini → Sentinel-2 greenbelt verification → RAG chatbot over the regulation corpus.

❌ Explicitly out of scope (put this on a slide — evaluators respect it): IoT gas sensors, wearables, CCTV/PPE vision, full ERP replacement, payroll.

🛠️ Suggested stack
Mobile    → Flutter + Drift/SQLite + WorkManager  (offline-first, Android-first)
Frontend  → React + TypeScript + MapLibre GL + Recharts
Backend   → FastAPI (Python) + Celery/APScheduler + Postgres 16 + PostGIS + Redis
AI Layer  → PaddleOCR/Surya (Devanagari) · pgvector RAG · LLM for obligation extraction
            XGBoost + SHAP for risk scoring (NOT deep learning — you have no data for it)
Auth      → Keycloak, RBAC + ABAC scoped by mine → area → subsidiary → corporate
Audit     → Append-only Postgres + SHA-256 hash chain + Merkle root (honest "blockchain")
Lang      → Bhashini APIs (ASR + translation)
Deploy    → Docker Compose demo; documented MeghRaj/on-prem path
3️⃣ Impact & Relevance 🌍
📈 The scale you're addressing (memorise these numbers)

CIL operates 85 mining areas across eight states, managing 310 working mines — 129 underground, 168 opencast and 13 mixed — with a manpower of 2,20,242 as of 1 April 2025, and targets 1 billion tonnes of production by FY 2028-29, up from 781 million tonnes in FY 2024-25. 
Coal India
 India crossed the 1-billion-tonne coal production mark on 20 March 2026, the second consecutive year of that milestone. 
Edunovations

🩺 The human case

Coal mines recorded 48 fatal accidents in 2020, 43 in 2021, 24 in 2022, 38 in 2023, 38 in 2024 and 41 in 2025. Between 2020 and 2024, coal mines saw 195 fatal accidents and 726 serious accidents, resulting in 226 deaths and 770 serious injuries. 
FACTLY

🎤 Pitch line: "Serious injuries outnumber deaths roughly 3-to-1. Those 770 injuries are the signal layer — and they're precisely the layer that is worst-recorded today. Our system is built to make that layer visible before it becomes the fatality layer."

🌐 Impact dimensions
Dimension	Impact
👷 Social	Fewer preventable injuries; contractor workers get a safety identity; grievance channel in the worker's own language
💰 Economic	Avoided production stoppages from Section 22 orders / EC violations; reduced compliance man-hours; lower NGT environmental-compensation exposure
🌱 Environmental	EC conditions become tracked obligations instead of six-monthly PDFs; satellite-verified greenbelt & OB dump compliance
🏛️ Governance	Paperless, auditable, evidence-backed compliance — directly aligned with Digital India
🇮🇳 Strategic	Indigenous alternative to foreign EHS suites (the PS explicitly asks for an indigenous framework)
🚀 Scalability beyond the hackathon
Coal India (310 mines) 
   → Captive & commercial coal blocks (post-2020 private entrants — same DGMS regime)
      → Metalliferous mines under Ministry of Mines (MMR 1961 — swap the rulebook, keep the engine)
         → Any multi-site regulated PSU (ports, power, steel, oil)

Because your obligation schema is regulation-agnostic, the platform generalises by swapping the corpus, not the code. Say this. It converts a coal project into a national governance primitive.

🎯 Why evaluators care

Coal is ~70% of India's electricity generation, production targets are being pushed hard, and safety and environmental scrutiny are both rising simultaneously. The sponsor (CIL) is mid-digital-transformation and knows the compliance layer is the gap their ERP didn't fill.

4️⃣ Scope of Innovation & Competitor Analysis 💡
🇮🇳 What already exists in the Indian coal ecosystem
System	Owner	What it does	❌ Gap you exploit
CMSMS + Khanan Prahari 🛰️	MoC / CMPDI + BISAG	Web-GIS application using satellite data to detect unauthorised mining beyond allotted lease area; 
GKToday
 satellite images scanned at three-month intervals plus citizen reports via the mobile app; 
Ministry of Coal
 geo-tagged photos routed automatically to nodal officers with complaint tracking 
Pragnyaias
	Targets illegal mining by outsiders, not internal statutory compliance. Zero coverage of DGMS/EC obligations.
DGMS online modules 📋	Min. of Labour	Approval System, Permission/Exemption/Relaxation System, National Safety Awards and Accident Statistics modules, plus online mine registration, inspection assignment and unified annual returns via Shram Suvidha 
Dgms
	Regulator-side transactional workflows. Doesn't give the mine a live obligation register.
PARIVESH 🌳	MoEFCC	Single-window portal for environment, forest, wildlife and CRZ clearances launched in October 2018 
Spans
	Six-monthly compliance reports arrive as PDFs requiring considerable man-hours to evaluate 
Environment Clearance
 — document-centric, not obligation-centric
CPCB OCEMS 💨	CPCB	Upgraded portal live since late August 2025, with directives pushing direct data transmission to CPCB servers 
Ppsthane
	Pure telemetry. No link to statutory conditions or corrective actions.
CIL SAP-ERP 🏢	CIL / Tech Mahindra	Integrates payroll, finance, materials, personnel, production, sales and marketing with real-time monitoring of production and stock 
InfotechLead
	No statutory safety compliance module. Partial subsidiary rollout. You're the missing layer, not a rival.

💎 Positioning statement (steal this): "We are not building another portal. We are building the obligation layer that sits between the regulator portals and the mine — the layer that turns their PDFs into our tasks and our field evidence into their reports."

🌍 Global commercial EHS platforms

The EHS software market has consolidated around VelocityEHS, Cority, Intelex, Enablon, Sphera and Benchmark Gensuite, with SafetyCulture positioned as a workplace operations platform supporting EHS workflows rather than a full enterprise EHS system. 
Reliable

Platform	Strength	❌ Why it fails for Indian coal
Sphera	Strongest process safety and operational risk for asset-intensive industries including mining 
Reliable
	Typically starts in the high six figures annually for asset-intensive deployments 
Reliable

Enablon (Wolters Kluwer)	Global regulatory content library, ESG reporting, enterprise-scale configurability 
Safetyiq
	Regulatory library built for OSHA/EU — no Mines Act 1952 / CMR 2017 content
Cority	Occupational health + ESG depth	Same regulatory mismatch; heavy implementation
Intelex	Integrated EHSQ, strong mobile ranking	Enterprise pricing, English-only field UX
VelocityEHS	Industrial hygiene, dust/silica exposure	Estimated around $10–30 per user monthly 
EHS Reviews
 — ×220,000 users is unviable
SafetyCulture	Excels at getting frontline workers to actually log observations; low barrier to reporting 
EcoOnline
	Not a traditional EHS platform and does not position itself as one 
EcoOnline
 — no statutory engine
SiteDocs	Rugged offline-capable mobile inspections for remote mine sites 
EHS Reviews
	Inspection forms only; no compliance intelligence

🔓 The structural gap: Every global platform assumes an English-literate user, a Western regulatory corpus, and a per-seat licence. Indian coal needs multilingual, offline, low-literacy field UX + Indian statutory content + a regulator-side portal. That combination does not exist commercially. That's your slide.

📚 Research grounding (cite these — evaluators notice)
Paper	Finding	Use it for
Coal mine roof accident risk prediction via ML (Sci Reports, 2025) — nature.com	Built from 305 screened accident cases across human–machine–environment–management dimensions, 
Nature
 reaching 0.967 accuracy with an optimised parameter set 
PubMed Central
	Honest framing: 305 cases is a small dataset. Use this to justify why you predict compliance risk, not fatalities.
AI in predicting coal mine disaster risks: a review — PMC	Reviews AI approaches for gas outbursts, mine fires, water disasters, roof collapses and dust disasters 
nih
	Taxonomy of hazard classes for your risk engine
ML predictive models for mining safety (Springer, 2025) — link.springer.com	XGBoost and Random Forest reached 98.55% and 98.20% accuracy on equipment failure prediction 
Springer
	Justifies tree ensembles over deep learning
ComplianceNLP: KG-augmented RAG for regulatory gap detection — arXiv	Commercial GRC platforms still rely heavily on rule-based approaches with manual curation 
arXiv
	Direct evidence your approach is novel, not derivative
Lost in EU Regulation? AI Found the Obligation (ICAIL) — ACM DL	Extraction pipeline structuring legal obligations into knowledge graphs 
ACM Other conferences
	Architectural precedent for your obligation graph
RegNLP community — regnlp.github.io	Focuses on obligation extraction, reasoning over cross-referenced obligations, jurisdiction nuance 
Regnlp
	Names your sub-field. Saying "RegNLP" signals depth.
🌟 Five ways to stand out technically
#	Innovation	Why it wins
1️⃣	Regulation-as-Code obligation graph — statutes/ECs/circulars → typed, versioned, queryable obligations with provenance back to the source clause	Nobody else will build this. It's the actual IP.
2️⃣	Evidence trust scoring — mock-GPS detection, EXIF forensics, perceptual hashing against re-uploads, capture-vs-sync drift, leasehold geofencing	Anticipates the killer judge question: "What stops someone faking a geo-tag from home?"
3️⃣	Independent verification loop — Sentinel-2 NDVI to verify greenbelt/plantation EC conditions without trusting self-reports	Compliance you don't have to take anyone's word for
4️⃣	Orphan-obligation + conflict detection — surface conditions with no owner, and clauses that contradict across documents	Governance insight, not a dashboard feature
5️⃣	Voice-first multilingual reporting via Bhashini — a worker reports a hazard by speaking Hindi/Bengali/Odia into a feature-phone-grade UI	Solves real literacy + adoption; strong Digital India signal

⛓️ On blockchain — be careful. The PS invites it, so use it, but honestly: append-only Postgres + SHA-256 hash chain + periodic Merkle root anchoring. Explain why a full permissioned chain is over-engineering at this stage. Judges reward the team that says "we chose not to." Teams claiming a "blockchain audit trail" that's really a JSON array get destroyed in Q&A.

5️⃣ Clarity of the Problem Statement 🧩
✅ Deliverables mapped (build this table into your PPT — it's an instant alignment win)
PS Requirement	Your Feature	Demo?
Digitally track statutory compliance (safety, env, production, labour)	Obligation graph + compliance calendar	✅ Hero A
Real-time monitoring of inspections/observations/violations/CAPA	Observation → CAPA state machine with SLA	✅ Hero B
AI to identify high-risk areas & recurring failures	Recurrence analytics + XGBoost risk score + SHAP	✅ Hero C
Geo-tagged, time-stamped field reporting, offline	Flutter offline queue + trust scoring	✅ Hero B
Dashboards: mine / corporate / regulator	3 role-scoped views	✅
Automated alerts, reminders, reports, escalation	Scheduler + escalation ladder + report generator	✅
Minimise paperwork	One-click statutory report from live data	✅
Scalable across mines & subsidiaries	Multi-tenant hierarchy: mine → area → subsidiary → CIL	🟡 Architecture slide
GIS mapping	MapLibre + leasehold geofences	✅
OCR / document digitisation	PaddleOCR pipeline	✅ Hero A
Blockchain audit trail	Hash-chained ledger (honestly scoped)	🟡
Multilingual conversational interface	Bhashini voice + RAG chatbot	🟡 Stretch
🚨 Seven ways teams will misread this PS
Misread	Reality
❌ Build IoT gas sensors / smart helmets	Category is Software, Theme is Smart Automation. Hardware safety monitoring is a different PS.
❌ Rebuild illegal-mining reporting	Khanan Prahari + CMSMS already exist and are government-built. Duplicating them = instant elimination.
❌ "Governance" = admin CRUD panel	Governance here means statutory obligation lifecycle, not user management
❌ Predict accidents with 99% accuracy on synthetic data	The fastest possible way to lose credibility with CIL/DGMS judges
❌ Skip contractor management	Explicitly listed in the PS. Most teams drop it. Don't.
❌ Build online-only	The PS literally says "with offline support"
❌ Ignore the regulator persona	The PS names regulatory authorities as a dashboard audience
🖼️ How to frame it so evaluators see alignment

Open with one mine, one day, one obligation: "Sardega OCP, condition 4(vii) of its EC: submit groundwater quality data every six months. Today, that condition exists only inside a PDF. Watch what happens when we ingest it." Then run Hero A live. Narrative before architecture, always.

6️⃣ Evaluator's Perspective 🎯
📏 The official rubric

SIH ideas are evaluated for novelty, complexity, clarity, completeness in the prescribed format, feasibility, practicability, sustainability, scale of impact, user experience and future progression. Roughly four to five teams may be selected per problem statement, and the sponsoring organisation is not obliged to select a winner if submissions don't meet expectations. 
Vercel
 Judges provide written remarks alongside scores, noting strengths and areas for improvement. 
Scribd

⚖️ Weight the criteria for this PS
Criterion	Weight here	Why
🧠 Domain accuracy	🔴🔴🔴🔴🔴	Judges will likely be CIL/CMPDI officers. They know what Form B is. Wrong terminology = credibility gone in 30 seconds.
💡 Novelty	🔴🔴🔴🔴	Everyone brings a dashboard. Obligation extraction is the differentiator.
🏗️ Practicability	🔴🔴🔴🔴	Can this run at a mine with 2G and a ₹8,000 Android phone?
📈 Scale of impact	🔴🔴🔴	310 mines → all Indian mines
♻️ Sustainability	🔴🔴🔴	Ops model, on-prem path, who maintains the regulation corpus
🎨 UX	🔴🔴🔴	Low-literacy, gloved-hands, sunlight-readable field UI
⚙️ Complexity	🔴🔴	Real, but don't confuse with feature count

🗣️ Note: AI tools aren't banned, but teams are expected to build the solution themselves and be able to explain, modify and defend every part of it before judges. 
The New Views
 On a PS this technical, expect the panel to ask you to change something live.

🚩 Red flags evaluators will look for
🚩 No offline demo (they will ask you to switch on airplane mode)
🚩 Fabricated accuracy metrics on invented data
🚩 "Blockchain" that's a Python list of dictionaries
🚩 No RBAC — can a Mine Manager at ECL see BCCL data? If yes, you fail governance
🚩 No DPDP Act 2023 consideration for worker attendance/medical data
🚩 Claiming SAP integration with no interface contract
🚩 A demo built on happy-path mock JSON with no backend running
🚩 Not knowing what DGMS is, or confusing it with the Ministry of Coal ⚠️ (this happens more than you'd think)
🚩 Rebuilding Khanan Prahari without knowing it exists
7️⃣ Team Fit & Execution Strategy 👥
🧑‍💻 Recommended composition (6 members, min. 1 female — all from the same college, inter-college teams not permitted) 
Vercel
#	Role	Owns	Non-negotiable skill
1	Backend / Architect 🏛️	Multi-tenant schema, obligation model, workflow engine, RBAC	Postgres data modelling
2	Backend / Integrations & DevOps 🔌	Scheduler, escalation, report generation, Docker, integration adapters	Async jobs, auth
3	AI/ML Engineer 🤖	OCR → obligation extraction, RAG, risk scoring + SHAP	Prompt engineering + classical ML
4	Mobile Engineer 📱	Offline-first Flutter app, sync, geo + evidence trust scoring	Local DB + conflict resolution
5	Frontend / GIS 🗺️	3 role-based dashboards, MapLibre, charts	React + map libs
6	Domain + Design + Pitch Lead 🎤	Regulation corpus, personas, UX, deck, demo script, Q&A	Research + storytelling

Ratio → 2 : 1 : 1 : 1 : 1 (Backend : AI : Mobile : Frontend : Domain-Design)

⭐ The #6 slot is where teams lose. On a governance PS, the person who has read the Coal Mines Regulations 2017 index and can name a Workmen's Inspector is worth more than a sixth coder. They win the Q&A, and the Q&A wins the PS.

🗓️ Pre-build research plan (do this before writing a line of code)
Step	Time	Output
1. Regulation harvest 📚	3 hrs	Download 10 real EC letters (PARIVESH) for CIL mines + 10 DGMS circulars. Read three properly.
2. Obligation schema design 🧬	3 hrs	The JSON schema for a single obligation. This is your core IP — design it on paper first.
3. Domain interview 🎙️	2 hrs	One call with a mining-engineering student/faculty (ISM Dhanbad, IIT-BHU, NIT Rourkela) or a retired mine official. One conversation reshapes everything.
4. Persona day-in-life 🗓️	2 hrs	Hour-by-hour for Mine Manager, Safety Officer, Contractor Supervisor
5. Competitive teardown 🔍	2 hrs	Install Khanan Prahari. Browse PARIVESH. Watch a SafetyCulture demo. Write your one-line positioning statement.
6. Hero-flow lock 🔒	1 hr	Choose exactly 3 flows. Write "OUT OF SCOPE" on a slide and mean it.
7. Data honesty plan 📊	1 hr	Label every dataset: real / public / synthetic. Put it on a slide.
8. Demo script 🎬	2 hrs	Write the 5-minute narration before building. Build only what the script needs.
🎬 Your 5-minute demo script
0:00  One mine, one EC condition, one PDF. The problem in 30 seconds.
0:30  Hero A — ingest a REAL EC letter → live obligation calendar → orphan
      obligation flagged in red.
2:00  Hero B — phone in airplane mode → observation logged → reconnect →
      syncs → CAPA raised → trust score shown.
3:30  Hero C — corporate risk ranking → drill into recurring violation
      pattern → regulator view → one-click statutory report.
4:30  Architecture, scale path (310 mines → all Indian mines), what's next.
🧾 Key Takeaways

1. 🎯 Don't build a dashboard. Build the obligation layer. The compliance calendar generated from a real EC letter is the entire pitch. Everything else supports it.

2. 📄 Use real public documents. PARIVESH ECs and DGMS circulars are free and public. Ingesting real regulatory text separates you from every synthetic-data team on this PS.

3. 📴 Demo offline, live. The PS asks for it and judges will test it. Airplane mode on stage is the most persuasive 20 seconds you have.

4. 🤖 Predict compliance failure, not fatalities. With 195 fatal accidents across five years, 
FACTLY
 there is no dataset for fatality prediction. Claiming otherwise ends your credibility.

5. 🧭 Know the ecosystem cold. Khanan Prahari, CMSMS, PARIVESH, OCEMS, the SAP ERP rollout, DGMS. Naming them and explaining your gap is the single highest-leverage slide in your deck.

6. ⛓️ Be honest about blockchain. Hash-chained audit ledger, explained accurately, beats "blockchain-powered" every time.

7. 👤 Bring a domain person. Six coders lose to five coders and someone who has read the Mines Act.

🔗 Reference Shelf

Government / primary

Ministry of Coal — coal.nic.in · Annual Report Ch. 14 "Safety in Coal Mines" (2025-26 PDF)
DGMS — dgms.gov.in · DGMS at a Glance
PARIVESH — parivesh.nic.in · Six-monthly compliance OM
CIL — coalindia.in/about-us
CMSMS / Khanan Prahari — PIB launch release
Mine accident data — FACTLY analysis

Competitors — Sphera/Enablon/Cority comparison · EHS platforms for mining

Research — Roof accident ML (Sci Rep) · AI for coal mine disaster risk (review) · ComplianceNLP · RegNLP

SIH 2026 — problem statements released following the official launch on 21 August 2026; 
Reskilll
 registration reported closing 6 September 2026 
The New Views
 — verify with your SPOC.

 

I HAVE BEEN TOLDED TO WORK ON 
-document to obligation workflow
-obligation to compliance calendar
-offline mobile app
-alerts & risk engine
-grievance & voice
