# CoalGov — Complete Project Documentation

> **SIH 2026 · PS 6024 · Ministry of Coal · Coal India Limited**
> AI-Based Smart Governance & Compliance Monitoring System for Coal Mines

---

## Table of Contents

1. [What Is This Project?](#1-what-is-this-project)
2. [The Problem Being Solved](#2-the-problem-being-solved)
3. [Repository Structure](#3-repository-structure)
4. [Tech Stack](#4-tech-stack)
5. [Design System & Branding](#5-design-system--branding)
6. [User Roles & Access Control](#6-user-roles--access-control)
7. [Backend — mine-compliance/](#7-backend--mine-compliance)
8. [Mobile App — mobile_app/](#8-mobile-app--mobile_app)
9. [Data Flow (End to End)](#9-data-flow-end-to-end)
10. [How to Run the Project](#10-how-to-run-the-project)
11. [What Is Built vs. What Is Planned](#11-what-is-built-vs-what-is-planned)
12. [Key Concepts Explained Simply](#12-key-concepts-explained-simply)

---

## 1. What Is This Project?

**CoalGov** is an AI-powered compliance monitoring platform for Indian coal mines.

Think of it this way: A coal mine in India has to follow rules set by at least **5 different government regulators** (DGMS for safety, MoEFCC for environment, CPCB for pollution, Ministry of Coal for production, and Labour laws for workers). Each regulator sends its rules as thick **PDF documents**. The mine then has to prove it's following all those rules — and that proof currently lives in paper registers and spreadsheets.

**CoalGov's job:** Take those PDF documents, extract every single legal obligation from them automatically using AI, turn them into a live trackable task list, let field workers log compliance evidence from their phones even without internet, and show managers, corporate executives, and regulators a real-time picture of how compliant each mine is.

---

## 2. The Problem Being Solved

### Root Cause
A single working coal mine is simultaneously answerable to 5 different regulatory regimes:

| Regulator | What They Issue | What The Mine Owes |
|---|---|---|
| **DGMS** (Ministry of Labour) | Mines Act 1952, Coal Mines Regulations 2017 | Safety Management Plan, inspections, accident reports, annual returns |
| **MoEFCC** | Environmental Clearance (EC) letters via PARIVESH | Six-monthly EC compliance reports |
| **CPCB/SPCB** | Air Act 1981, Water Act 1974 | OCEMS real-time emission/effluent data |
| **Ministry of Coal / CCO** | Coal production returns | Production, dispatch, grade data |
| **Labour Dept.** | CLRA 1970, wage codes | Contractor licences, attendance, training, medical exams |

None of these 5 systems share a common mine identifier. That one missing link is the root of all the data inconsistency and duplication of records.

### Why The Old Way Fails
- Compliance obligations exist only inside 30-page PDFs — not machine-readable
- The same incident gets re-entered into 3+ different systems
- Corrective actions have no SLA, no assigned owner, no escalation
- Field workers record on paper underground, enters digital days later
- No cross-mine pattern detection

---

## 3. Repository Structure

```
SIH26024/
├── .gitignore                     <- Excludes .env, TEMPFILE/, build artifacts
├── README.md                      <- THIS FILE
│
├── mine-compliance/               <- BACKEND (Python / FastAPI)
│   ├── .env.example               <- Template for secrets
│   ├── extractor.py               <- AI obligation extractor (Gemini + pdfplumber)
│   ├── schemas.py                 <- Pydantic data models
│   └── main.py                    <- FastAPI app entry point
│
└── mobile_app/                    <- MOBILE APP (Flutter / Dart)
    ├── pubspec.yaml               <- Flutter dependencies
    └── lib/
        ├── main.dart              <- App entry point
        ├── theme/app_theme.dart   <- Full color palette + Material ThemeData
        ├── database/
        │   ├── database.dart      <- Drift SQLite schema
        │   └── database.g.dart    <- Auto-generated (do not edit)
        ├── models/
        │   ├── user_role.dart     <- UserRole enum + MockUser
        │   └── mock_data.dart     <- Static demo data (Sardega OCP)
        ├── widgets/
        │   ├── coal_app_bar.dart
        │   ├── metric_card.dart
        │   ├── compliance_chart.dart
        │   └── risk_vector_bar.dart
        └── screens/
            ├── role_select.dart
            ├── observation_form.dart
            ├── shared/
            │   ├── dashboard_tab.dart
            │   ├── observations_tab.dart
            │   ├── capas_tab.dart
            │   └── grievances_tab.dart
            ├── sirdar/sirdar_home.dart
            ├── worker/worker_home.dart
            └── contractor/
                ├── contractor_home.dart
                └── contractors_tab.dart
```

---

## 4. Tech Stack

### Backend
| Layer | Technology | Why |
|---|---|---|
| API Framework | FastAPI (Python) | Auto-generates OpenAPI docs, async support |
| AI / LLM | Google Gemini 2.5 Flash | Structured output enforcement with JSON schema |
| PDF Parsing | pdfplumber | Precise text extraction, page-level segmentation |
| Data Validation | Pydantic v2 | Schema enforcement, model_validate_json |
| Server | Uvicorn (ASGI) | FastAPI production server |

### Mobile App
| Layer | Technology | Why |
|---|---|---|
| Framework | Flutter 3.41 (Dart) | Single codebase -> Android APK; offline-first |
| Local Database | Drift (SQLite) | Type-safe, reactive queries, code-generation |
| State Management | Provider | Simple, efficient |
| Charts | fl_chart | Smooth animated line charts |
| Location | geolocator | GPS for observation trust scoring |
| Connectivity | connectivity_plus | Network state detection for sync |
| UUID | uuid | Client-side unique IDs for offline records |

---

## 5. Design System & Branding

### Color Palette

| Role | Name | Hex | Where Used |
|---|---|---|---|
| Primary | Absolute Black | #000000 | AppBars, bottom nav, sidebars |
| Background | Off-White | #F7F5F0 | All screen backgrounds |
| Text | Near-Black Coal | #16150F | Body text, headings |
| Accent | Hi-Vis Amber | #E0961C | Active nav, buttons, charts |
| Safe | Green | #2C9C77 | Verified/closed/safe |
| Danger | Red | #C0512E | Overdue/critical/expired |

### Layout Principles (Web -> Mobile)
- Web sidebar -> Mobile BottomNavigationBar
- 4-stat-card row -> 2x2 GridView
- Side-by-side chart + risk panel -> Stacked vertically
- All cards: borderRadius=8, subtle shadow, white on off-white

---

## 6. User Roles & Access Control

### Sirdar (Field Staff)
- Who: Underground supervisors who physically inspect mine faces
- Primary Need: "Log a hazard right now, offline, underground"
- Tabs: Dashboard, Observations, CAPAs, Grievances (4 tabs)

### Mine Worker
- Who: Permanent or contract miners
- Primary Need: "Report something wrong without fear of retaliation"
- Access: Grievances ONLY (anonymous supported)

### Contractor Supervisor
- Who: Supervisor responsible for a gang of contract workers
- Primary Need: "Show my workers are licensed and inducted"
- Tabs: Dashboard, Observations, CAPAs, Workers, Grievances (5 tabs)

### Org Hierarchy
```
CIL Corporate
    -> Subsidiary (SECL, MCL, WCL, ECL, BCCL, CCL, NCL)
            -> Area
                    -> Mine (e.g., Sardega OCP)
```
All data scoped by org_id — users only see their own mine's data.

---

## 7. Backend — mine-compliance/

### extractor.py — The Core AI Engine

#### parse_pdf(file_path: str) -> str
- Opens PDF with pdfplumber
- Iterates every page, extracts text
- Prepends "--- PAGE N ---" markers
- Returns one concatenated string

#### extract_obligations_from_text(raw_text: str) -> ObligationList
- Truncates text to 12,000 chars
- Sends to Gemini with expert compliance officer prompt
- Instructs AI: ignore preambles, focus on "shall/must/required to" conditions
- Enforces JSON output via response_schema=ObligationList
- Returns validated Pydantic object

### schemas.py — Data Models

Obligation fields:
- clause_ref: "Condition 4(vii)"
- obligation_text: Full condition text
- summary: One-line summary
- domain: "safety"|"environment"|"labour"|"production"
- frequency: "daily"|"weekly"|"monthly"|"bi-annually"|"annually"
- responsible_role: "MINE_OFFICIAL"|"SAFETY_OFFICER"|"ENV_OFFICER"
- evidence_type: "photo"|"report"|"measurement"|"register"
- mine_types: ["opencast"]|["underground"]|["opencast","underground"]
- confidence: 0.0 to 1.0

### main.py — FastAPI Application

Planned endpoints:
- POST /documents/ingest — Upload PDF, trigger extraction
- GET /obligations/{org_id} — List all obligations for a mine
- POST /sync/push — Mobile pushes offline data
- GET /sync/pull/{org_id} — Mobile fetches latest
- GET /dashboard/{org_id} — KPI metrics
- POST /observations — Create field observation
- POST /grievances — Submit grievance
- GET /capas/{org_id} — List corrective actions

---

## 8. Mobile App — mobile_app/

### main.dart
- Wraps entire app in Provider<AppDatabase> for global DB access
- Boots into RoleSelectScreen

### database/database.dart — SQLite Schema

**Observations Table:**
| Column | Type | Description |
|---|---|---|
| id | int PK | Auto-increment |
| orgId | text | Mine identifier |
| reportedBy | text | Username |
| category | text | Hazard type |
| location | text | GPS coords or district code |
| clientUuid | text unique | Device-generated UUID (prevents duplicates on sync) |
| trustScore | real | 0-100 evidence quality score |
| syncStatus | int | 0=pending, 1=synced |

**Evidences Table:**
| Column | Type | Description |
|---|---|---|
| id | int PK | Auto-increment |
| entityType | text | "observation" etc |
| entityId | text | Parent clientUuid |
| capturedAt | dateTime | When photo/audio taken |
| location | text | GPS at capture time |
| filePath | text | Local device path |
| trustScore | real | Evidence quality |
| phash | text | Perceptual hash for duplicate detection |

**Grievances Table:**
| Column | Type | Description |
|---|---|---|
| id | int PK | Auto-increment |
| orgId | text | Mine |
| raisedBy | text nullable | Null = anonymous |
| isAnonymous | bool | Hide identity flag |
| lang | text | Language code |
| rawText | text | Grievance content |
| createdAt | dateTime | Timestamp |
| syncStatus | int | 0=pending, 1=synced |

### models/user_role.dart
- UserRole enum: sirdar, mineWorker, contractorSup
- Extensions: displayName, shortLabel, userName
- MockUser: role + mineName + subsidiary

### models/mock_data.dart
- sardegaMetrics: 88/100 trust, 14 obligations, 8 CAPAs, Low risk
- sardegaRiskVectors: Env=92%, Slope=78%(warn), Machine=85%, Contractor=64%(CRITICAL), Fire=98%
- complianceTrendData: [92, 94.5, 91, 95, 93, 96.5] (Jan-Jun)
- mockObservations: 3 samples (Open, CAPA Raised, Closed)
- mockContractors: 3 contractors, 1 with vtcExpired=true

### Screen-by-Screen Detail

**role_select.dart:** Dark launch screen. Three role cards navigate to respective home screens.

**sirdar_home.dart:** 4-tab IndexedStack (Dashboard/Obs/CAPAs/Grievances). Black bottom nav, amber active.

**worker_home.dart:** Single screen, no bottom nav. Only shows GrievancesTab.

**contractor_home.dart:** 5-tab IndexedStack. Same as Sirdar + Workers tab.

**shared/dashboard_tab.dart:** SingleChildScrollView with 2x2 MetricCard grid, ComplianceChart, RiskVectors panel.

**shared/observations_tab.dart:** ListView of observation cards with colored left border by status. FAB -> ObservationFormScreen.

**observation_form.dart:** GPS-acquiring offline form. Saves to SQLite with syncStatus=0 and UUID. Shows GPS lock status indicator.

**shared/capas_tab.dart:** ListView of CAPA cards with left border by severity. Shows escalation indicator.

**shared/grievances_tab.dart:** Anonymous toggle + language picker + text area + voice note button. Shows success banner with ticket number on submit.

**contractor/contractors_tab.dart:** List of contractors with VTC/PME expiry badges. Expired = red border + red badge.

### Widget Details

**CoalAppBar:** Shield logo on amber, mine name subtitle, role badge, notification bell.

**MetricCard:** Label (9px) + trend (top-right) + big value (28px) + contributing factors (10px).

**ComplianceChart:** fl_chart LineChart, Y=80-100, amber line, white-stroke dots, amber glow fill.

**RiskVectorBar:** Label + % badge + 7px LinearProgressIndicator. Critical=red, Warning=amber, Safe=green.

---

## 9. Data Flow (End to End)

### PDF -> Obligation Calendar (Backend)
1. PDF uploaded via API
2. pdfplumber extracts text
3. Gemini AI reads, extracts structured obligations
4. Pydantic validates JSON
5. Stored to DB as obligations
6. Calendar auto-generated 12 months ahead with owners + SLAs

### Field Observation (Mobile -> Backend)
1. Inspector opens phone offline underground
2. Fills ObservationFormScreen, GPS captured
3. Drift saves to local SQLite, syncStatus=0, UUID generated
4. Phone reconnects to network
5. WorkManager (planned) sends POST /sync/push with UUID
6. Server validates trust score (GPS real? In lease boundary? EXIF clean?)
7. syncStatus set to 1 on device
8. Dashboard count updates

### Grievance (Worker -> Manager)
1. Worker opens app, Mine Worker role, Grievances tab
2. Types concern, marks Anonymous
3. Saves locally with raisedBy=null
4. Syncs to server, SLA timer starts (48 hours)
5. Mine Manager sees ticket in web dashboard
6. Status updates return to app ("In Review" -> "Resolved")

---

## 10. How to Run the Project

### Backend
```bash
cd mine-compliance
python -m venv venv
venv\Scripts\activate
pip install fastapi uvicorn pdfplumber google-genai python-dotenv pydantic
cp .env.example .env
# Edit .env: GEMINI_API_KEY=your_key_here
python -m uvicorn main:app --reload
# API: http://localhost:8000
# Docs: http://localhost:8000/docs
```

### Mobile App
```bash
cd mobile_app
flutter pub get
flutter devices
flutter run
# Build APK:
flutter build apk --release
# -> build/app/outputs/flutter-apk/app-release.apk
```

---

## 11. What Is Built vs. Planned

### Built
- Backend obligation extractor (Gemini + pdfplumber) - WORKING
- Flutter 3-role navigation app - COMPLETE
- CoalGov theme (all colors) - COMPLETE
- All 3 role home screens with correct tabs - COMPLETE
- Offline SQLite schema (Observations, Evidences, Grievances) - COMPLETE
- GPS trust scoring foundation - COMPLETE
- Role select demo screen - COMPLETE

### Planned
- PostgreSQL full database + PostGIS
- Document ingestion API endpoint
- Sync push/pull API + WorkManager background sync
- Camera evidence capture
- Bhashini voice input
- Risk engine (XGBoost + SHAP)
- Web dashboard (Mine Manager, Regulator, Corporate)
- Hash-chained audit ledger
- RBAC/Auth (JWT)

---

## 12. Key Concepts Explained Simply

**Obligation:** One single enforceable rule from a PDF. E.g., "Submit groundwater data every 6 months."

**CAPA:** Corrective & Preventive Action. A ticket auto-created when a critical hazard is logged. Has owner + deadline. Escalates if overdue.

**Trust Score:** How genuine is the field evidence? Checks: real GPS? within mine lease? EXIF timestamp consistent? Photo not reused? Score 0-100.

**Drift:** Flutter's SQLite library. You write table classes in Dart, it generates the SQL. Reactive — UI updates automatically when DB changes.

**client_uuid:** UUID generated on device per observation. Prevents duplicates when sync runs twice. This is idempotent sync.

**syncStatus:** 0 = saved offline, not yet sent. 1 = synced to server. Dashboard counts records where syncStatus==0 to show "X items pending sync".

---

## Repository
**GitHub:** https://github.com/yashmishra19/SIH26024

**Competition:** SIH 2026 | PS 6024 | Ministry of Coal | Coal India Limited

*Generated: September 2026 | CoalGov Team*
