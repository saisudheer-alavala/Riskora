from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

# Auth Schemas
class RegisterRequest(BaseModel):
    name: str
    email: str
    dob: Optional[str] = None
    password: str

class LoginRequest(BaseModel):
    email: str
    password: str

class UserResponse(BaseModel):
    id: str
    name: str
    email: str
    dob: Optional[str] = None
    created_at: str

class AuthResponse(BaseModel):
    token: str
    user: UserResponse

# Brand Profile Schemas
class BrandProfileModel(BaseModel):
    company_name: str
    description: str
    logo_url: str
    official_website: str
    social_media_accounts: List[str] = []
    official_mobile_apps: List[str] = []
    official_package_ids: List[str] = []
    official_publishers: List[str] = []
    trusted_identifiers: List[str] = []
    last_updated: Optional[str] = None

# Threat Schemas
class InvestigationNoteModel(BaseModel):
    id: str
    author: str
    text: str
    timestamp: str

class ThreatModel(BaseModel):
    id: str
    title: str
    brandName: str
    type: str
    riskScore: int
    platform: str
    detectedUrl: str
    matchedPattern: str
    screenshotUrl: str
    detectedAt: str
    status: str
    notes: List[InvestigationNoteModel] = []

class ThreatStatusUpdate(BaseModel):
    status: str

class AddNoteRequest(BaseModel):
    text: str
    author: str

# Scan Record Schemas
class ScanRecordModel(BaseModel):
    id: str
    scanDate: str
    sourceType: str
    status: str
    candidatesChecked: int
    detectionsCount: int
    highRiskCount: int
    durationSeconds: int
    errors: List[str] = []

class TriggerScanRequest(BaseModel):
    sourceType: str = "All Sources"

# Report Summary Schema
class ReportSummaryModel(BaseModel):
    range: str
    totalDetections: int
    threatsResolved: int
    avgResolutionTimeHours: float
    accuracyRate: float
    riskDistribution: dict = {}
    activityTimeline: List[dict] = []
