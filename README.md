# RISKORA – Intelligent Digital Risk Protection Platform (DRP)

![RISKORA Banner](https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=1200&auto=format&fit=crop&q=80)

**RISKORA** is an enterprise-grade cybersecurity full-stack platform designed for proactive brand protection, impersonation mitigation, and rogue mobile application defense. It enables SecOps analysts and brand defense teams to audit registered assets, detect lookalike social profiles and trojanized APK packages, examine neural similarity breakdowns, dispatch formal takedown requests, and converse with an autonomous AI threat intelligence copilot powered by Groq.

---

## ⚡ Quickstart Guide (Full-Stack Monorepo)

### 🐍 1. Run Backend (Python FastAPI)
```bash
cd backend
pip install -r requirements.txt
python main.py
```
> API runs at `http://localhost:8000`. Swagger API docs available at `http://localhost:8000/docs`.

### 📱 2. Run Frontend (Flutter Web)
```bash
flutter pub get
flutter run -d chrome
```

---

## 👥 Team Collaboration Workflow
- **Frontend Developer**: Work inside `lib/`, `web/`, `assets/`.
- **Backend Developer**: Work inside `backend/` (`main.py`, `database.py`, `models.py`).
- Pull and push without conflicts using standard `git pull` & `git push`.

---

## 🛡️ Key Platform Highlights

- **Dark Cybersecurity Aesthetics**: Dark navy-blue command center backdrop (`#090D16`), charcoal-blue card surfaces (`#111726`), glowing teal (`#00D2C4`) and mint-green (`#10B981`) telemetry accents, and crisp typography (`Plus Jakarta Sans`, `Inter`, `JetBrains Mono`).
- **Responsive Architecture**: Multi-device layouts supporting **Desktop** (with collapsible telemetry sidebar), **Tablet** (adaptive rail), and **Mobile** (drawer + quick bottom navigation bar).
- **Zero-Dependency Demo Sandbox**: Out-of-the-box simulated threat models, risk vectors, and AI advisor reasoning that work offline without requiring an active Python server for college presentations and reviews.
- **FastAPI Integration Ready**: Centralized REST API client (`ApiService` and `ChatService`) prepared to integrate directly with Python FastAPI backends.
- **Comprehensive Threat Forensics**: Side-by-side asset comparison, composite score decomposition (Name 25%, Logo 30%, Malicious Keywords 20%, Age 15%, Malware/Permissions 10%), and DMCA takedown package generation.

---

## 📱 Implemented Screens

1. **Dashboard (`DashboardScreen`)**
   - 4 Live Telemetry Stat Cards: *Total Detections*, *Social Candidates*, *Suspicious Apps*, *High-Risk Alerts*.
   - Activity Timeline Chart (`fl_chart` smooth multi-series line chart).
   - Risk Distribution Chart (`fl_chart` interactive donut chart).
   - SecOps Quick Actions Toolbar (*Trigger Crawl*, *Configure Assets*, *Consult AI*, *Generate Report*).
   - Recent High-Priority Detections list with direct investigation links.
   - Persistent Floating AI Advisor button with pulsing cyber glow.

2. **Brand Profile (`BrandProfileScreen`)**
   - Interactive editing mode for core brand identity (*Company Name*, *Industry*, *Website*, *Logo*).
   - Authorized Social Media channel registry (handles, profile URLs, verified status).
   - Official Mobile App packages (Google Play & Apple App Store package IDs, publishers).
   - Trusted Identifiers and trademark keywords chip manager.

3. **Social Media Monitoring (`SocialMonitoringScreen`)**
   - Multi-platform candidate feed (Twitter/X, Telegram, Instagram, LinkedIn, TikTok).
   - Real-time search by handle, display name, or threat keyword.
   - Filter by platform ecosystem and risk category (Critical, High, Medium, Low).
   - Sort by Risk Score, Name Match, or Discovery Date.
   - Detailed Forensic View modal with raw similarity metrics and threat flags.

4. **App Store Monitoring (`AppMonitoringScreen`)**
   - Rogue APK and iOS counterfeit package feed.
   - Invasive permission warnings (`RECEIVE_SMS`, `READ_CONTACTS`, `ACCESSIBILITY_SERVICE`).
   - Repository filters (*Google Play*, *Apple App Store*, *Third-Party APK Mirrors*).
   - Detailed App Forensics modal with package comparison and triage triggers.

5. **Threat Investigation Workbench (`ThreatInvestigationScreen`)**
   - Threat switcher dropdown to quickly audit any flagged incident.
   - Side-by-side comparison: Monitored Official Asset vs Detected Rogue Impersonator.
   - Five-factor risk score progress bar decomposition.
   - Analyst notes timeline with author stamps and live note addition.
   - Functional Triage: *Mark Confirmed Threat*, *Mark False Positive*, *Keep Under Review*, and *Initiate Takedown Notice* (modal with pre-formatted legal DMCA/trademark packet).

6. **AI Threat Intelligence Copilot (`ChatAssistantScreen` & `QuickChatDialog`)**
   - Dedicated full chat screen + floating quick chat popup accessible anywhere.
   - 3 Specialized Reasoning Modes:
     - 🏢 **Brand Assistant**: Monitors brand baseline, handles, and coverage.
     - 🛡️ **Risk Advisor**: Explains threat scoring logic and remediation playbooks.
     - 🎧 **Customer Support**: Guides DMCA filing and platform navigation.
   - Pre-loaded suggested prompt chips (*"What brands are registered?"*, *"Why was this account flagged?"*, *"What does this risk score mean?"*, *"How do I register a brand?"*, *"How do I report a suspicious app?"*).
   - Rich response cards for Brand Profiles, Detection Forensics, and Takedown Guides.

7. **Scan History & Audit Logs (`ScanHistoryScreen`)**
   - Multi-channel crawl trigger (*All Sources*, *Social Media*, *App Stores*, *DNS*, *Dark Web*).
   - Animated scanning state with simulated crawler progress stages.
   - Detailed telemetry: Candidates Checked, Flagged Items, Speed, and Warning logs.

8. **Security Intelligence Reports (`ReportsScreen`)**
   - Audit window selector (*Last 7 Days*, *Last 30 Days*, *Last 90 Days*, *All Time*).
   - Threat validation ratio bar (Confirmed Attacks vs Benign False Positives).
   - Executive Brief PDF generator with preview dialog and download simulation.
   - CSV telemetry export trigger.

9. **Settings & API Configuration (`SettingsScreen`)**
   - FastAPI Backend URL configuration with connection health checker (`GET /api/health`).
   - Quick preset buttons for `http://localhost:8000` (Web/Desktop) and `http://10.0.2.2:8000` (Android Emulator).
   - Offline Simulation Sandbox toggle for smooth demoing without backend dependencies.
   - Sensitivity threshold slider (50% – 95%) and automated scan frequency controls.
   - Complete FastAPI REST API schema reference for developers.

---

## 📂 Project Structure

```
lib/
├── main.dart                          # Application entry point
├── app.dart                           # RiskoraApp, multi-provider, & screen router
├── theme/
│   └── app_theme.dart                 # Dark cybersecurity palette, typography, & card themes
├── models/
│   ├── brand_profile.dart             # BrandProfile, SocialAccount, & OfficialApp models
│   ├── threat_item.dart               # ThreatItem, RiskBreakdown, InvestigationNote, & ReviewStatus
│   ├── scan_record.dart               # ScanRecord & ScanStatus models
│   ├── chat_message.dart              # ChatMessage, ChatMode, MessageSender, & metadata cards
│   └── report_data.dart               # ReportSummary & analytics metrics model
├── providers/
│   └── app_state_provider.dart        # Unified state manager connecting all screens & API
├── services/
│   ├── api_service.dart               # Centralized HTTP client for Python FastAPI
│   ├── chat_service.dart              # Multi-mode AI copilot engine with offline reasoning
│   └── mock_data_service.dart         # Realistic cybersecurity threat intelligence data
├── widgets/
│   ├── app_navigation.dart            # Responsive shell (Desktop sidebar, tablet rail, mobile bottom nav)
│   ├── stat_card.dart                 # Dashboard telemetry stat card with glow & trends
│   ├── threat_card.dart               # Reusable threat card with similarity metrics & badges
│   ├── risk_badge.dart                # Risk level & review status badge indicators
│   ├── demo_banner.dart               # Transparency banner indicating simulation vs live API
│   ├── floating_ai_button.dart        # Pulsing floating AI button for quick access
│   ├── quick_chat_dialog.dart         # Modal AI Copilot dialog
│   └── charts/
│       ├── risk_distribution_chart.dart # Donut chart with interactive slices
│       └── threat_timeline_chart.dart   # Smooth activity timeline line chart
└── screens/
    ├── dashboard_screen.dart          # SOC Command Center dashboard
    ├── brand_profile_screen.dart      # Brand perimeter & asset registry
    ├── social_monitoring_screen.dart  # Social impersonation candidates
    ├── app_monitoring_screen.dart     # Rogue APK & mobile app scanner
    ├── investigation_screen.dart      # Forensics workbench & takedown generator
    ├── chat_assistant_screen.dart     # Dedicated AI Copilot chat workspace
    ├── scan_history_screen.dart       # Multi-channel crawl audit trail
    ├── reports_screen.dart            # Incident metrics & PDF executive brief
    └── settings_screen.dart           # FastAPI URL setup, sensitivity & presets
```

---

## 🚀 Running the Project

### Prerequisites
- Flutter SDK 3.13+ or 3.47+
- Chrome (for Flutter Web) or Android Studio / Android Emulator

### 1. Run on Flutter Web (Recommended for Dashboard view)
```bash
flutter run -d chrome
```

### 2. Run on Android Emulator or Device
```bash
flutter run -d android
```

### 3. Run Static Analysis & Tests
```bash
flutter analyze
flutter test
```

---

## 🐍 Connecting with Python FastAPI Backend

In `lib/screens/settings_screen.dart` or via `ApiService`, set your backend URL:
- **Web / Desktop**: `http://localhost:8000`
- **Android Emulator**: `http://10.0.2.2:8000`

### Expected FastAPI Endpoints:

```python
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="RISKORA Threat Intelligence API")

@app.get("/api/health")
def health_check():
    return {"status": "online", "version": "1.0.0"}

@app.get("/api/brand-profile")
def get_brand_profile():
    # Returns BrandProfile JSON
    ...

@app.put("/api/brand-profile")
def update_brand_profile(profile: dict):
    # Updates monitored assets
    ...

@app.get("/api/threats")
def get_threats(type: Optional[str] = None):
    # Returns list of ThreatItem objects
    ...

@app.post("/api/threats/{threat_id}/status")
def update_status(threat_id: str, payload: dict):
    # Updates review status (confirmedThreat, falsePositive, takedownRequested)
    ...

@app.post("/api/chat")
def chat_copilot(payload: dict):
    # payload: {"prompt": str, "mode": str, "history": list}
    return {
        "id": "ai-resp",
        "sender": "assistant",
        "text": "Threat analysis response...",
        "timestamp": "2026-10-10T12:00:00Z",
        "mode": payload["mode"],
        "metadata": None
    }
```

---

## 🎓 Academic / Project Demonstration Notice

This project frontend cleanly separates presentation from backend infrastructure:
- Simulated detections and AI suggestions in **Simulation Mode** are designed for student demonstrations and testing without claiming real monitoring.
- The connection mode is transparently badged on top of the dashboard, allowing users to toggle between simulated sandbox mode and a live FastAPI backend seamlessly.
