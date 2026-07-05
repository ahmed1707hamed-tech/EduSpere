from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional


class Settings(BaseSettings):
    PROJECT_NAME: str = "EduSphere Content Service"
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    
    # S3 / MinIO Configuration
    S3_ENDPOINT_URL: Optional[str] = "http://minio:9000"  # Set to None for actual AWS S3
    S3_ACCESS_KEY: str = "minioadmin"
    S3_SECRET_KEY: str = "minioadmin"
    S3_BUCKET: str = "edusphere-content"
    S3_REGION: str = "us-east-1"

    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore"
    )


settings = Settings()
