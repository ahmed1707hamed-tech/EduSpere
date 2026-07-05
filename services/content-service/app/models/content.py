from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime

from app.database.database import Base


class MediaItem(Base):
    __tablename__ = "media_items"

    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String(255), nullable=False)
    file_type = Column(String(100), nullable=False)
    s3_key = Column(String(500), unique=True, index=True, nullable=False)
    uploaded_by = Column(Integer, nullable=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
