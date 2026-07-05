from jose import jwt
from app.core.config import settings
from app.main import is_public_path


def test_gateway_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "api-gateway"


def test_gateway_root(client):
    response = client.get("/")
    assert response.status_code == 200
    assert "Running" in response.json()["message"]


def test_is_public_path():
    assert is_public_path("/api/auth/login", "POST") is True
    assert is_public_path("/api/auth/register", "POST") is True
    assert is_public_path("/api/courses", "GET") is True
    assert is_public_path("/api/courses/5", "GET") is True
    assert is_public_path("/api/courses/5/enroll", "POST") is False
    assert is_public_path("/api/courses/enrolled/me", "GET") is False
    assert is_public_path("/api/courses", "POST") is False


def test_protected_route_unauthorized(client):
    # Try reaching user list without authorization header
    response = client.get("/api/auth/users")
    assert response.status_code == 401
    assert "credentials" in response.json()["detail"].lower()


def test_protected_route_invalid_token(client):
    # Try reaching with malformed token
    response = client.get("/api/auth/users", headers={"Authorization": "Bearer malformed_token"})
    assert response.status_code == 401
    assert "validate" in response.json()["detail"].lower()
