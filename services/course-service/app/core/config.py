from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "EduSphere Course Service"
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    
    REDIS_HOST: str = "redis"
    REDIS_PORT: int = 6379

    NOTIFICATION_SERVICE_URL: str = "http://notification-service:8005"
    INTERNAL_API_KEY: str = "local-internal-service-key"

    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore"
    )


settings = Settings()
