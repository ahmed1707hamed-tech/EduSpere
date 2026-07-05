"""Create the initial auth-service schema."""

from alembic import op

revision = "0001_auth_service"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    from alembic.runtime.migration import MigrationContext
    from app.database.database import Base
    from app.models.user import User  # noqa: F401
    Base.metadata.create_all(bind=op.get_bind())


def downgrade():
    from app.database.database import Base
    from app.models.user import User  # noqa: F401
    Base.metadata.drop_all(bind=op.get_bind())
