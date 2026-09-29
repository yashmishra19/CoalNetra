# CoalNetra

**AI-based smart governance and compliance monitoring for Indian coal mines**

> Smart India Hackathon 2026 · Problem Statement 6024 · Ministry of Coal / Coal India Limited
> Team **Blaze Squad**

CoalNetra replaces paper statutory registers and scattered spreadsheets with one connected system. It reads regulatory PDFs and turns them into trackable obligations. Field staff can log geo-tagged evidence from their phones, even underground with no network. Mine managers and DGMS regulators each get a live dashboard that only shows the data their role is allowed to see.

---

## 📱 Mobile App (Android APK Download)

> **Evaluators & Invigilators**: You can directly download and install the compiled CoalNetra Android application onto any Android device:
> 
> 📥 **[Download CoalNetra Android APK (v1.0.0)](https://github.com/yashmishra19/CoalNetra/raw/main/apk/CoalNetra.apk)**
> 
> * **Direct Repository Path**: [`apk/CoalNetra.apk`](./apk/CoalNetra.apk)
> * **Installation & Feature Guide**: [`apk/README.md`](./apk/README.md)
> * **Key Mobile Features**: Offline-first reporting via Drift SQLite, real-time photographic evidence capture with GPS watermark, speech-to-text voice note logging, live atmospheric multi-gas telemetry (CH₄, CO, Air velocity, Dust PM10), and automatic synchronization with the CoalNetra Web Portal.

---


## The problem

A single working coal mine answers to several regulators at once: DGMS for safety, MoEFCC and CPCB for environment and pollution, the Ministry of Coal for production, and the labour authorities for workers. Their rules arrive as long PDFs. Proof of compliance usually lives in paper registers, spreadsheets and delayed reports. That makes records inconsistent, lets compliance gaps go unnoticed, and slows decisions.

## What CoalNetra does

- **AI obligation extraction.** Upload a clearance or regulation PDF and an LLM pulls out each obligation, deadline, penalty and source section as structured data. It can run on a local Ollama model or on the NVIDIA API.
- **Statutory compliance tracking.** Obligations under the Coal Mines Regulations 2017 and the OSHWC Code 2020 become live tasks with due dates and status.
- **Inspections, observations and CAPAs.** Observations are geo-tagged and time-stamped. Each one leads to a corrective and preventive action (CAPA), and the person who closes a CAPA cannot be the one who verifies it (maker-checker). Overdue items escalate automatically.
- **Offline-first mobile app.** Records are saved to on-device SQLite and sync when the phone reconnects. Retries never create duplicate records.
- **Underground presence.** GPS doesn't reach underground workings, so presence at a survey station is proven by scanning QR or NFC tags placed there.
- **SOS beacon.** A worker can raise an SOS that carries their last GPS fix. It reaches nearby phones over the local network and the server over the API.
- **Risk scoring and dashboards.** Each mine gets a risk score with a component breakdown, plus a risk map, workforce view, production and environment view, and reports and approvals.
- **Regulator portal.** DGMS officers get a mines register, inspections, directions, accidents, permissions and an assurance view, limited to their geographic region.
- **Tamper-evident audit trail.** An append-only SHA-256 hash chain records who did what and when.

---

## Architecture

```mermaid
flowchart LR
    subgraph Field["Field (often offline)"]
        APP["Flutter mobile app<br/>Sirdar · Worker · Contractor"]
        DB[("On-device SQLite<br/>Drift")]
        APP <--> DB
    end

    subgraph Office["Mine office & DGMS"]
        WEB["React web dashboard<br/>Mine Manager · Regulator"]
    end

    API["Node.js / Express API<br/>server/"]
    AI["FastAPI AI pipeline<br/>mine-compliance/"]
    LLM["Ollama (local) or<br/>NVIDIA API"]
    SB[("Supabase<br/>Postgres + PostGIS<br/>RLS · Storage · pg_cron")]

    APP -- "sync push / pull" --> API
    WEB -- "REST + JWT" --> API
    WEB -- "Supabase Auth" --> SB
    API --> SB
    AI --> LLM
    PDF["Regulation PDFs"] --> AI
    AI -- "extracted obligations" --> SB
```

### Access by role

| Role | Where they work | What they can do |
| :--- | :--- | :--- |
| **Field Officer (Sirdar)** | Mobile, often offline | Inspections, checklists, observations, closing CAPAs with after-photos, GIS map, SOS |
| **Mine Worker** | Mobile | Observations, grievances, SOS |
| **Contractor Supervisor** | Mobile | Contractor labour, contracts, compliance alerts |
| **Mine Manager** | Web | One mine: obligations, CAPA verification, incidents, risk, production, workforce, reports |
| **DGMS Regulator** | Web | Read and audit mines in their region; issue directions and prohibition orders |

Regulators are blocked at the database level from internal commercial data: risk scores, production logs, biometric attendance, injured workers' personal details and draft inquiry notes. There is no RLS policy on those tables for the regulator role, so their queries return zero rows.

---

## Tech stack

| Layer | Technology |
| :--- | :--- |
| Database & auth | Supabase: Postgres, PostGIS, pgcrypto, pg_cron, Row-Level Security, Storage |
| API server | Node.js, Express, `@supabase/supabase-js` |
| Web dashboard | React 19, Vite, Tailwind CSS, React Router, Recharts, lucide-react |
| Mobile app | Flutter (Android / iOS), Drift (SQLite), Provider, geolocator, connectivity_plus, fl_chart |
| AI pipeline | Python, FastAPI, Uvicorn, pdfplumber / PyMuPDF, Pydantic, Ollama or NVIDIA API |

---

## Repository structure

```
CoalNetra/
├── client/            React + Vite web dashboard (Mine Manager and Regulator portals)
├── server/            Express API: auth, today, compliance, regulator, mobile sync, SOS
├── mobile_app/        Flutter field app (Sirdar, Worker, Contractor)
├── mine-compliance/   FastAPI service that extracts obligations from regulation PDFs
├── supabase/
│   ├── migrations/    Schema, enums, RLS, triggers, materialized views, cron, storage
│   ├── seed.sql       Demo dataset (one demo mine and region)
│   └── tests/         RLS and business-rule tests
├── IDEAS/             PRD, detailed project documentation, HTML field-app prototype
└── package.json       npm workspaces: runs client and server together
```

---

## Getting started

### Prerequisites

- Node.js 18 or later and npm
- Flutter SDK (Dart 3.11 or later) and Android Studio or an emulator
- Python 3.11
- A Supabase project, or the Supabase CLI with Docker for a local instance
- For AI extraction: [Ollama](https://ollama.com) running locally, or an NVIDIA API key

### 1. Database (Supabase)

```bash
# Local instance
supabase start
supabase db reset                     # applies everything in supabase/migrations

# Demo data
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f supabase/seed.sql

# Optional: RLS and rule tests
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f supabase/tests/rls_and_rules_test.sql
```

For a hosted project, link it with `supabase link` and run `supabase db push`.

### 2. Environment variables

Create these files. They are git-ignored and must never be committed.

**`server/.env`**
```env
PORT=3001
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
# Only for a trusted local demo that needs mobile writes:
DEMO_MODE=true
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>
```

**`client/.env`**
```env
VITE_SUPABASE_URL=https://<project-ref>.supabase.co
VITE_SUPABASE_ANON_KEY=<anon-key>
```

**`mine-compliance/.env`**
```env
AI_PROVIDER=ollama                    # or: nvidia
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2:3b
NVIDIA_API_KEY=<your-key>
NVIDIA_BASE_URL=<nvidia-endpoint>
NVIDIA_MODEL=meta/llama-3.1-8b-instruct
```

> ⚠️ The Supabase **service-role key** stays on the server only. Never put it in the Flutter app, a `--dart-define`, the web client or any committed file.

### 3. API server and web dashboard

```bash
npm install          # installs root, client and server workspaces
npm run dev          # API on http://localhost:3001, dashboard on http://localhost:5173
```

Vite forwards `/api` calls to `localhost:3001`. To check that the API can reach the database, open `http://localhost:3001/api/health`.

To create the demo login accounts (this needs `SUPABASE_SERVICE_ROLE_KEY` in `server/.env`):

```bash
node server/create-demo-users.js
```

### 4. Mobile app

```bash
cd mobile_app
flutter pub get
dart run build_runner build           # generates the Drift database code

# Android emulator (reaches the host at 10.0.2.2, which is the default)
flutter run

# Physical device on the same Wi-Fi as your computer
flutter run --dart-define=API_BASE_URL=http://<your-lan-ip>:3001
```

The phone and computer need to be on a network that allows device-to-device traffic.

### 5. AI compliance pipeline

```bash
cd mine-compliance
python -m venv .venv && source .venv/bin/activate    # Windows: .venv\Scripts\activate
pip install -r requirements.txt
python main.py                                       # http://localhost:8000
```

Upload a PDF to extract obligations:

```bash
curl -F "file=@clearance.pdf" http://localhost:8000/extract
```

Interactive API docs are at `http://localhost:8000/docs`. `download_rules.py` fetches the Coal Mines Regulation PDFs, and `ai_pipeline.py` analyses them from the command line.

---

## API overview

| Method | Endpoint | Purpose |
| :--- | :--- | :--- |
| `GET` | `/api/health` | Server and database status |
| `POST` | `/api/auth/login` · `GET /api/auth/me` | Sign in; current user and role |
| `GET` | `/api/today` | Mine manager's daily view, including the risk score |
| `GET` | `/api/obligations`, `/api/capas`, `/api/incidents`, `/api/directions`, `/api/observations`, `/api/mine` | Compliance data for a mine |
| `GET` | `/api/regulator/*` | Regulator views: mines register, inspections, directions, accidents, permissions, assurance |
| `POST` | `/api/sync/push` | Mobile uploads queued offline records |
| `GET` | `/api/sync/pull` · `/api/sync/sos/active` | Mobile downloads updates; active SOS signals |

---

## Core design rules

1. **Scope on every row.** Each record a regulator can see carries its mine, area, subsidiary, district and DGMS region. Triggers fill these in, so RLS checks stay simple and fast.
2. **Provenance.** Every record states its source: inspector, instrument, or operator (sealed or unsealed). Sealed records are hashed into the audit chain.
3. **Maker-checker on CAPAs.** A table constraint and an RLS policy both stop the person who closed a CAPA from also verifying it.
4. **Regulator denial boundary.** Internal commercial and personal data has no regulator policy at all, so it is denied by default.
5. **Offline-first.** Devices generate UUIDs for new records, and each record keeps both the device time and the server time. That makes sync safe to retry.

The full schema, the purpose of each migration, per-role query patterns and scaling notes are in [`docs/BACKEND.md`](docs/BACKEND.md). The full project write-up is in [`IDEAS/README.md`](IDEAS/README.md).

---

## Current status

This is a hackathon prototype.

- **Built:** database schema with RLS and tests; Express API; manager and regulator web dashboards; Flutter field app with offline sync and SOS; AI obligation extraction service.
- **Demo mode:** mobile writes go through a service-role-backed demo endpoint, turned on with `DEMO_MODE=true`. This is not production authentication, so don't expose it to an untrusted network.
- **Partly on mock data:** some dashboard and mobile screens still use mock data (`client/src/data/`, `mobile_app/lib/models/mock_data.dart`).
- **Planned:** connecting document storage and OCR to the API; BLE proximity SOS.

---

## Team

**Blaze Squad** · Smart India Hackathon 2026