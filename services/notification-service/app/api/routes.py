from typing import List
from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from app.database.database import get_db
from app.schemas.notification import (
    WelcomeEmailRequest,
    EnrollmentEmailRequest,
    CertificateEmailRequest,
    PasswordResetEmailRequest,
    NotificationResponse
)
from app.services.notification_service import NotificationService
from app.repositories.notification_repository import NotificationRepository
from app.core.config import settings

router = APIRouter(prefix="/notifications", tags=["Notifications"])


def verify_internal_key(x_internal_key: str = Header(..., alias="X-Internal-Key")):
    if x_internal_key != settings.INTERNAL_API_KEY:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Forbidden: Invalid service key"
        )


@router.post("/welcome", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED)
def trigger_welcome_email(
    payload: WelcomeEmailRequest,
    db: Session = Depends(get_db),
    _ = Depends(verify_internal_key)
):
    service = NotificationService(db)
    return service.send_welcome_email(
        recipient_email=payload.email,
        full_name=payload.full_name
    )


@router.post("/enrollment", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED)
def trigger_enrollment_email(
    payload: EnrollmentEmailRequest,
    db: Session = Depends(get_db),
    _ = Depends(verify_internal_key)
):
    service = NotificationService(db)
    return service.send_enrollment_email(
        recipient_email=payload.email,
        full_name=payload.full_name,
        course_title=payload.course_title
    )


@router.post("/certificate", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED)
def trigger_certificate_email(
    payload: CertificateEmailRequest,
    db: Session = Depends(get_db),
    _ = Depends(verify_internal_key)
):
    service = NotificationService(db)
    return service.send_certificate_email(
        recipient_email=payload.email,
        full_name=payload.full_name,
        course_title=payload.course_title,
        certificate_code=payload.certificate_code
    )


@router.post("/password-reset", response_model=NotificationResponse, status_code=status.HTTP_201_CREATED)
def trigger_password_reset_email(
    payload: PasswordResetEmailRequest,
    db: Session = Depends(get_db),
    _ = Depends(verify_internal_key)
):
    service = NotificationService(db)
    return service.send_password_reset_email(
        recipient_email=payload.email,
        full_name=payload.full_name,
        reset_link=payload.reset_link
    )


@router.get("/history", response_model=List[NotificationResponse])
def get_notification_history(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    _ = Depends(verify_internal_key)
):
    repo = NotificationRepository(db)
    return repo.get_all(skip=skip, limit=limit)
