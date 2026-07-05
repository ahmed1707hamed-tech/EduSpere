from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List, Union


class Settings(BaseSettings):
    PROJECT_NAME: str = "EduSphere API Gateway"
    SECRET_KEY: str = "local-development-secret-key-change-before-production"
    ALGORITHM: str = "HS256"

    REDIS_URL: str = "redis://redis:6379/0"

    AUTH_SERVICE_URL: str = "http://auth-service:8001"
    COURSE_SERVICE_URL: str = "http://course-service:8002"
    CONTENT_SERVICE_URL: str = "http://content-service:8003"
    QUIZ_SERVICE_URL: str = "http://quiz-service:8004"
    NOTIFICATION_SERVICE_URL: str = "http://notification-service:8005"

    RATE_LIMIT_PER_MINUTE: int = 120
    
    # Accept comma separated list or native list
    CORS_ORIGINS: Union[str, List[str]] = "http://localhost,http://localhost:3000,http://localhost:5173"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    def get_cors_origins(self) -> List[str]:
        if isinstance(self.CORS_ORIGINS, list):
            return self.CORS_ORIGINS
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",") if origin.strip()]


settings = Settings()
