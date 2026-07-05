"""Create EduSphere PostgreSQL databases if they do not exist."""
from sqlalchemy import create_engine, text

ADMIN_URL = "postgresql://postgres:P%40ssw0rd123456%40%40@localhost:5432/postgres"
DATABASES = [
    "edusphere_auth",
    "edusphere_course",
    "edusphere_content",
    "edusphere_quiz",
    "edusphere_notification",
    "auth_db",
    "course_db",
    "content_db",
    "quiz_db",
    "notification_db",
]


def main() -> None:
    engine = create_engine(ADMIN_URL, isolation_level="AUTOCOMMIT")
    with engine.connect() as conn:
        existing = {
            row[0]
            for row in conn.execute(
                text("SELECT datname FROM pg_database WHERE datistemplate = false")
            )
        }
        for name in DATABASES:
            if name in existing:
                print(f"exists: {name}")
                continue
            conn.execute(text(f'CREATE DATABASE "{name}"'))
            print(f"created: {name}")


if __name__ == "__main__":
    main()
