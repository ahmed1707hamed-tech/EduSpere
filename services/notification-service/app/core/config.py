from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional


class Settings(BaseSettings):
    PROJECT_NAME: str = "EduSphere Notification Service"
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"

    INTERNAL_API_KEY: str = "local-internal-service-key"
    FRONTEND_URL: str = "http://localhost"

    SMTP_HOST: Optional[str] = None
    SMTP_PORT: int = 587
    SMTP_STARTTLS: bool = True
    SMTP_USERNAME: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None
    SMTP_FROM: str = "noreply@edusphere.local"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
