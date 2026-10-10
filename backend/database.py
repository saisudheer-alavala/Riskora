import sqlite3
import json
import hashlib
import os
from datetime import datetime

DB_PATH = os.environ.get("DATABASE_PATH", "riskora.db")

def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def hash_password(password: str) -> str:
    # Secure SHA-256 with consistent salt
    salt = "riskora_secops_salt_2026"
    return hashlib.sha256((salt + password).encode("utf-8")).hexdigest()

def verify_password(plain_password: str, hashed: str) -> bool:
    return hash_password(plain_password) == hashed

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()

    # 1. Users Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        dob TEXT,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
    );
    """)

    # 2. Brand Profiles Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS brand_profiles (
        user_id TEXT PRIMARY KEY,
        brand_name TEXT NOT NULL,
        official_website TEXT NOT NULL,
        industry TEXT NOT NULL,
        description TEXT,
        logo_url TEXT,
        social_handles TEXT,
        mobile_apps TEXT,
        package_names TEXT,
        publishers TEXT,
        trusted_domains TEXT,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
    );
    """)

    # 3. Threats Table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS threats (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        brand_name TEXT NOT NULL,
        type TEXT NOT NULL,
        risk_score INTEGER NOT NULL,
        platform TEXT NOT NULL,
        detected_url TEXT,
        matched_pattern TEXT,
        screenshot_url TEXT,
        detected_at TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
    );
    """)

    # 4. Scan Records Table (History)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS scan_records (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        scan_date TEXT NOT NULL,
        source_type TEXT NOT NULL,
        status TEXT NOT NULL,
        candidates_checked INTEGER NOT NULL,
        detections_count INTEGER NOT NULL,
        high_risk_count INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        errors TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
    );
    """)

    conn.commit()

    # Seed Default Demo Account
    seed_demo_account(cursor)
    conn.commit()
    conn.close()

def seed_demo_account(cursor):
    demo_email = "admin@riskora.ai"
    cursor.execute("SELECT id FROM users WHERE email = ?", (demo_email,))
    user = cursor.fetchone()

    if not user:
        user_id = "usr_demo_admin_001"
        now_iso = datetime.now().isoformat()
        cursor.execute("""
        INSERT INTO users (id, name, email, dob, password_hash, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """, (
            user_id,
            "Chief Security Officer",
            demo_email,
            "1994-06-15",
            hash_password("RiskoraSecOps#2026"),
            now_iso
        ))

        # Seed Brand Profile
        cursor.execute("""
        INSERT INTO brand_profiles (
            user_id, brand_name, official_website, industry, description,
            logo_url, social_handles, mobile_apps, package_names, publishers,
            trusted_domains, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            user_id,
            "Acme Global Technologies",
            "https://acme-global.io",
            "Fintech & Enterprise Cloud",
            "Global enterprise financial infrastructure & payment gateway services.",
            "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200&q=80",
            json.dumps(["@acmeglobal", "@acmepay_support", "@acmetechnologies"]),
            json.dumps(["AcmePay Android", "Acme Authenticator iOS", "Acme BizPortal"]),
            json.dumps(["io.acmeglobal.pay", "com.acme.authenticator", "io.acme.portal"]),
            json.dumps(["Acme Security Holdings LLC", "Acme Global Devs"]),
            json.dumps(["acme-global.io", "acmepay.com", "auth.acme.net"]),
            now_iso
        ))

        # Seed Scan Records (History)
        initial_scans = [
            ("SCN-984210", user_id, "2026-10-10T09:30:00", "All Sources", "completed", 1420, 6, 3, 94, "[]"),
            ("SCN-984180", user_id, "2026-10-09T18:15:00", "Social Media", "completed", 840, 4, 2, 58, "[]"),
            ("SCN-984020", user_id, "2026-10-08T11:45:00", "App Stores", "completed", 580, 2, 1, 46, "[]"),
            ("SCN-983910", user_id, "2026-10-07T14:20:00", "Web & Domains", "completed", 1210, 5, 2, 82, "[]"),
            ("SCN-983750", user_id, "2026-10-06T10:00:00", "All Sources", "completed", 1560, 7, 4, 112, "[]"),
            ("SCN-983600", user_id, "2026-10-05T16:40:00", "Social Media", "completed", 720, 3, 1, 42, "[]"),
        ]

        cursor.executemany("""
        INSERT INTO scan_records (
            id, user_id, scan_date, source_type, status,
            candidates_checked, detections_count, high_risk_count,
            duration_seconds, errors
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, initial_scans)

        # Seed Initial Threats
        initial_threats = [
            (
                "THREAT-801",
                user_id,
                "Fake Customer Support Account",
                "Acme Global Technologies",
                "socialMedia",
                94,
                "Instagram",
                "https://instagram.com/acme_global_support_helpdesk",
                "Username similarity: 96% typosquatting targeting customer wallets",
                "https://images.unsplash.com/photo-1563986768609-322da13575f3?w=500&q=80",
                "2026-10-10T09:32:00",
                "flagged",
                json.dumps([
                    {"id": "n1", "author": "SecOps AI Bot", "text": "High risk impersonator detected conducting phishing via DM links.", "timestamp": "2026-10-10T09:33:00"}
                ])
            ),
            (
                "THREAT-802",
                user_id,
                "Trojanized Payment Gateway APK",
                "Acme Global Technologies",
                "appStore",
                89,
                "APKPure Hub",
                "https://apkpure.fake/app/io.acme.pay.clone",
                "Package spoof: io.acmeglobal.pay.free with injected keylogger signature",
                "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=500&q=80",
                "2026-10-10T09:35:00",
                "investigating",
                json.dumps([
                    {"id": "n2", "author": "Analyst David", "text": "Package signature does not match Acme release keys. Takedown notice queued.", "timestamp": "2026-10-10T10:00:00"}
                ])
            ),
            (
                "THREAT-803",
                user_id,
                "Brand Typosquat Phishing Portal",
                "Acme Global Technologies",
                "webDomain",
                82,
                "Domain Registrar",
                "https://acme-globall-login.net",
                "Homoglyph attack duplicating official portal CSS & logo assets",
                "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=500&q=80",
                "2026-10-09T18:20:00",
                "takedownRequested",
                json.dumps([
                    {"id": "n3", "author": "Legal SecOps", "text": "DMCA and registrar abuse complaint dispatched to Cloudflare & GoDaddy.", "timestamp": "2026-10-09T18:45:00"}
                ])
            ),
            (
                "THREAT-804",
                user_id,
                "Unauthorized VIP Telegram Channel",
                "Acme Global Technologies",
                "socialMedia",
                76,
                "Telegram",
                "https://t.me/acmepay_official_airdrop",
                "Unauthorized token airdrop scam leveraging official logo mark",
                "https://images.unsplash.com/photo-1614064641938-3bbee52942c7?w=500&q=80",
                "2026-10-08T11:48:00",
                "resolved",
                json.dumps([
                    {"id": "n4", "author": "SecOps Automation", "text": "Telegram trust & safety team removed the rogue channel.", "timestamp": "2026-10-08T14:10:00"}
                ])
            )
        ]

        cursor.executemany("""
        INSERT INTO threats (
            id, user_id, title, brand_name, type, risk_score,
            platform, detected_url, matched_pattern, screenshot_url,
            detected_at, status, notes
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, initial_threats)

    # Seed Lead User Account (Kureti Titus Karthikeya)
    lead_email = "kuretitituskathikeya@gmail.com"
    cursor.execute("SELECT id FROM users WHERE email = ?", (lead_email,))
    lead_user = cursor.fetchone()

    if not lead_user:
        lead_id = "usr_lead_karthikeya_001"
        now_iso = datetime.now().isoformat()
        cursor.execute("""
        INSERT INTO users (id, name, email, dob, password_hash, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """, (
            lead_id,
            "Kureti Titus Karthikeya",
            lead_email,
            "2001-06-15",
            hash_password("RiskoraLead#2026"),
            now_iso
        ))

        cursor.execute("""
        INSERT INTO brand_profiles (
            user_id, brand_name, official_website, industry, description,
            logo_url, social_handles, mobile_apps, package_names, publishers,
            trusted_domains, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            lead_id,
            "Riskora SecOps Global",
            "https://riskora.ai",
            "Cyber Defense & AI Security",
            "Autonomous digital risk protection and anti-impersonation intelligence.",
            "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200&q=80",
            json.dumps(["@riskora_ai", "@riskora_secops", "@kureti_lead"]),
            json.dumps(["Riskora Sentinel Mobile", "Riskora Guard iOS"]),
            json.dumps(["ai.riskora.sentinel", "com.riskora.guard"]),
            json.dumps(["Riskora Cyber Defense LLC", "Kureti Tech Systems"]),
            json.dumps(["riskora.ai", "auth.riskora.ai", "secops.riskora.io"]),
            now_iso
        ))

        lead_scans = [
            ("SCN-990100", lead_id, "2026-10-10T12:00:00", "All Sources", "completed", 1680, 8, 4, 88, "[]"),
            ("SCN-990080", lead_id, "2026-10-09T20:30:00", "Dark Web & Domains", "completed", 950, 5, 2, 60, "[]"),
        ]
        cursor.executemany("""
        INSERT INTO scan_records (
            id, user_id, scan_date, source_type, status,
            candidates_checked, detections_count, high_risk_count,
            duration_seconds, errors
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, lead_scans)

        lead_threats = [
            (
                "THREAT-901",
                lead_id,
                "Rogue Lead Executive Profile",
                "Riskora SecOps Global",
                "socialMedia",
                97,
                "LinkedIn",
                "https://linkedin.com/in/fake-kureti-titus-riskora",
                "Executive impersonation: duping partners using fabricated credential badges",
                "https://images.unsplash.com/photo-1563986768609-322da13575f3?w=500&q=80",
                "2026-10-10T12:05:00",
                "flagged",
                json.dumps([
                    {"id": "ln1", "author": "SecOps AI Bot", "text": "High priority executive spoofing detected.", "timestamp": "2026-10-10T12:06:00"}
                ])
            ),
            (
                "THREAT-902",
                lead_id,
                "Malicious Riskora CLI Trojan",
                "Riskora SecOps Global",
                "appStore",
                91,
                "GitHub / PyPI Mirror",
                "https://pypi-mirror.fake/packages/riskora-secops-fake",
                "Package typo-squat injecting backdoor reverse shell",
                "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=500&q=80",
                "2026-10-10T12:10:00",
                "investigating",
                json.dumps([
                    {"id": "ln2", "author": "Lead Architect", "text": "Reported to abuse desk for immediate revocation.", "timestamp": "2026-10-10T12:15:00"}
                ])
            )
        ]
        cursor.executemany("""
        INSERT INTO threats (
            id, user_id, title, brand_name, type, risk_score,
            platform, detected_url, matched_pattern, screenshot_url,
            detected_at, status, notes
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, lead_threats)

