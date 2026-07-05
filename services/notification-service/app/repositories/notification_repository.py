from typing import Optional, List
from sqlalchemy.orm import Session
from app.models.notification import Notification


class NotificationRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, notification_id: int) -> Optional[Notification]:
        return self.db.query(Notification).filter(Notification.id == notification_id).first()

    def get_all(self, skip: int = 0, limit: int = 100) -> List[Notification]:
        return self.db.query(Notification).order_by(Notification.created_at.desc()).offset(skip).limit(limit).all()

    def get_by_recipient(self, email: str, skip: int = 0, limit: int = 100) -> List[Notification]:
        return self.db.query(Notification).filter(Notification.recipient_email == email).order_by(Notification.created_at.desc()).offset(skip).limit(limit).all()

    def create(self, notification: Notification) -> Notification:
        self.db.add(notification)
        self.db.commit()
        self.db.refresh(notification)
        return notification

    def update(self, notification: Notification) -> Notification:
        self.db.commit()
        self.db.refresh(notification)
        return notification
