# GPS School Attendance Management App — KPK E&SED Primary Schools (Offline-First)

A production-ready, offline-first attendance management mobile and tablet application specifically designed and aligned for **Pakistan Khyber Pakhtunkhwa (KPK) Elementary & Secondary Education Department (E&SED) Primary Schools (GPS / GGPS)**.

Built with **Flutter, GetX, Drift (SQLite), Cloudflare Workers (TypeScript), Cloudflare D1**, and the **Official Meta WhatsApp Business Cloud API**.

---

## 1. Key Capabilities & KPK E&SED Alignment

- **KPK Primary School Structure (`Kachi` to `Class 5`)**:
  - Pre-configured for KPK Government Primary Schools (`GPS / GGPS`) with **Kachi (کچی)**, **Class 1 (اول)**, **Class 2 (دوم)**, **Class 3 (سوم)**, **Class 4 (چہارم)**, and **Class 5 (پنجم)**.
  - Captures official KPK metadata: **EMIS Code** (e.g., `EMIS-12405`), **District**, **Tehsil**, **Circle Office (ASDEO)**, **Climate Zone** (Summer vs. Winter Zone), **School Cutoff Time** (`08:15 AM`), and **Bilingual UI (`EN` / `اردو` RTL)**.
  - Extended student register fields: **Student Form-B (NADRA)**, **Father CNIC**, and **School Leaving Certificate (SLC)** transfer tracking.
- **100% Offline-First Attendance & Session Finalization**:
  - Every attendance mutation (`present`, `absent`, `late`, `leave`, `half_day`), undo snapshot, session finalization, and student update is wrapped inside an **atomic SQLite transaction** that writes both the domain table and the `sync_queue` outbox.
  - Supports **Draft vs. Finalized Sessions**: Once all students are marked, the teacher can finalize and lock the daily register. Post-cutoff edits require a **Correction Request** reviewed and approved by the **Head Teacher (Admin)**.
- **Mark All Present with Instant Transactional Undo**:
  - One-tap marking with confirmation modal and an instant undo snapshot that restores previous statuses or issues `DELETE` tombstones to the sync outbox.
- **Cryptographic QR Credentials & Revocation**:
  - Generates 128-bit cryptographic opaque QR tokens (`KPK_QR_<32-hex>`) using `Random.secure()`—zero PII is ever stored inside QR codes.
  - Supports **QR Token Rotation & Revocation**: When a lost card is replaced, scanning the old card displays an immediate **REVOKED QR CARD** security alert, and printable PDF Student ID Cards can be exported directly from the app.
- **Offline PDF Reporting Engine (5 Official Registers + In-App Preview)**:
  - Five A4/Landscape report templates generated 100% offline via `pdf` and `printing` with interactive in-app `PdfPreview`:
    1. **Monthly Attendance Register (Matrix Grid)**: 31-day status matrix (`P`, `A`, `L`, `Lv`, `HD`, `H`, `S`).
    2. **Class Attendance Register**: Tabular register with instructional day totals and attendance percentages.
    3. **Individual Student Dossier**: Complete student attendance history and metric breakdown.
    4. **Daily Attendance Sheet**: Single-day register with arrival times and summary totals.
    5. **KPK Administrative Summary (ASDEO / EMIS)**: Class-wise enrollment, attendance totals, and average attendance rate for Circle Office reporting.
  - **Enrollment-Date-Aware Instructional Days**: Excludes Sundays, gazetted KPK holidays, and days outside a student's `[admissionDate, leavingDate]` window. Flags incomplete sessions as provisional.
- **Cloudflare Workers & D1 Bi-Directional Synchronization**:
  - Push (`pushPending`) and incremental cursor pull (`pullLatest`) synchronization with conflict detection (`sync_conflicts`) and an interactive **Outbox & Conflict Inspector**.

---

## 2. Project Structure

```
gps/
├── backend/                        # Cloudflare Workers TypeScript API
│   ├── migrations/                 # D1 SQL Migrations
│   │   ├── 0001_initial_schema.sql # Multi-tenant tables, indexes, constraints
│   │   └── 0002_kpk_sessions_and_corrections.sql # KPK settings, sessions, corrections
│   ├── src/
│   │   ├── routes/
│   │   │   ├── auth.ts             # Login, School Registration, KPK Demo Seeder
│   │   │   ├── sync.ts             # Bi-directional push/pull sync endpoints
│   │   │   └── whatsapp.ts         # WhatsApp message queue & Meta webhooks
│   │   ├── services/
│   │   │   ├── auth.ts             # PBKDF2 password hashing & JWT
│   │   │   └── whatsapp.ts         # Meta Graph API dispatcher & phone normalization
│   │   ├── index.ts                # Main Hono worker entrypoint
│   │   └── types.ts                # TypeScript bindings & schemas
│   ├── package.json
│   ├── tsconfig.json
│   └── wrangler.toml               # D1 and R2 configuration
├── lib/                            # Flutter Client Application
│   ├── core/
│   │   ├── database/               # Drift SQLite database (v2) & DAOs
│   │   │   ├── daos/               # AttendanceDao, StudentDao, SyncDao
│   │   │   ├── tables.dart         # SQLite table schemas
│   │   │   └── app_database.dart   # Database accessor, KPK models & migrations
│   │   ├── localization/
│   │   │   └── app_translations.dart # Bilingual English (EN) & Urdu (اردو RTL)
│   │   └── utils/
│   │       └── idempotency.dart    # Deterministic idempotency & CSPRNG QR tokens
│   ├── data/
│   │   └── repositories/           # Offline-first repositories (Auth, Attendance, Student, Sync)
│   ├── modules/
│   │   ├── admin/                  # KPK School Setup, Approvals & Audit, Holidays, Classes
│   │   ├── attendance/             # Attendance marking, session lock, correction requests
│   │   ├── auth/                   # Login, demo switcher & offline teacher PIN unlock
│   │   ├── dashboard/              # Executive KPK overview, class selector & 5-tab shell
│   │   ├── pdf_reports/            # 5 offline PDF generators & interactive PdfPreview
│   │   ├── qr_scanner/             # Continuous QR scanner, cutoff rule & revoked detection
│   │   ├── students/               # Directory, CSV bulk import, SLC transfer & PDF ID cards
│   │   └── sync/                   # Bi-directional sync, Outbox Inspector & Conflict Resolver
│   └── main.dart                   # Application bootstrap & dependency injection
└── test/                           # Automated test suite
    ├── attendance_flow_test.dart   # End-to-end attendance, QR rotation, session lock & CSV
    ├── drift_test.dart             # SQLite schema, foreign keys, uniqueness checks
    ├── pdf_test.dart               # Offline 5-template PDF generation & instructional days
    └── widget_test.dart            # Flutter widget launch & UI rendering
```

---

## 3. Running the Application

### A. Run Flutter Mobile App

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run automated tests
flutter test

# 3. Analyze code
flutter analyze

# 4. Run application
flutter run
```

### B. Run Cloudflare Workers Backend Locally

```bash
cd backend

# 1. Install packages
npm install

# 2. Apply local D1 database migrations
npx wrangler d1 migrations apply DB --local

# 3. Start local Workers development server (http://127.0.0.1:8787)
npx wrangler dev
```
