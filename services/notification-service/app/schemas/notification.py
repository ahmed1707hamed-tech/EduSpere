from datetime import datetime
from pydantic import BaseModel, EmailStr
from typing import Optional


class WelcomeEmailRequest(BaseModel):
    email: EmailStr
    full_name: str


class EnrollmentEmailRequest(BaseModel):
    email: EmailStr
    full_name: str
    course_title: str


class CertificateEmailRequest(BaseModel):
    email: EmailStr
    full_name: str
    course_title: str
    certificate_code: str


class PasswordResetEmailRequest(BaseModel):
    email: EmailStr
    full_name: str
    reset_link: str


class NotificationResponse(BaseModel):
    id: int
    recipient_email: EmailStr
    subject: str
    notification_type: str
    is_sent: bool
    error_message: Optional[str] = None
    created_at: datetime
    sent_at: Optional[datetime] = None

    class Config:
        from_attributes = True
