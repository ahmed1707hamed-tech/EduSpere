from datetime import datetime
from pydantic import BaseModel


class MediaItemResponse(BaseModel):
    id: int
    filename: str
    file_type: str
    s3_key: str
    uploaded_by: int
    created_at: datetime

    class Config:
        from_attributes = True


class SignedUrlResponse(BaseModel):
    url: str
    s3_key: str
    expires_in: int
