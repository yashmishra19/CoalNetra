# 📱 CoalNetra Mobile Application (Android Release)

This directory contains the production-ready standalone Android APK for CoalNetra, built for field officers, mining sirdars, workers, and contractors.

---

## 📥 Direct Download & Installation

- **Download APK File**: [`CoalNetra.apk (v1.0.1)`](./CoalNetra.apk)
- **Direct GitHub Raw Download Link**: [Download CoalNetra.apk (v1.0.1)](https://github.com/yashmishra19/CoalNetra/raw/main/apk/CoalNetra.apk)

### Installation Steps on Android:
1. Tap the download link above on your Android smartphone (or download to PC and transfer via USB/WhatsApp/Drive).
2. Open the downloaded `CoalNetra.apk` file on your device.
3. If prompted with *"For your security, your phone is not allowed to install unknown apps from this source"*, tap **Settings** and enable **"Allow from this source"**.
4. Tap **Install** and then **Open**.
5. Grant required permissions (Camera and Location) to enable live geo-tagging, sensor telemetry, and photographic evidence.

---

## 🚀 Key Features for Evaluators & Invigilators

1. **Role-Based Workflows**:
   - **Mining Sirdar**: Shift inspections, live geo-inspections, statutory hazard reporting, handover job actions.
   - **Mine Worker**: Shift PPE declarations, SOS emergency beacon, grievances reporting.
   - **Contractor**: Labour compliance tracking and work orders.
2. **Interactive Evidence Bar**:
   - 📷 **Photo Capture**: Capture or attach real site evidence with auto GPS watermarking.
   - 🎙️ **Voice Notes**: Interactive voice recorder with live speech-to-text transcriptions appended to inspection notes.
   - 📡 **Atmospheric Telemetry**: Real-time multi-gas sensor snapshot (CH₄ %, CO ppm, Air velocity m/s, Dust PM10 mg/m³) attached to the observation record.
3. **Offline-First Drift SQLite Database**:
   - Field operations function 100% offline underground.
   - Observations, inspections, and grievances are saved to the local encrypted SQLite ledger.
4. **Instant Server & Web Portal Sync**:
   - Automatically pushes to the CoalNetra governance web dashboard upon network reconnect or sync trigger.
   - Live updates appear under **"Latest from the field"** on the Mine Manager and DGMS Regulator dashboards.
