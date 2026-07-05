from app.core.config import settings


def test_trigger_welcome_email_unauthorized(client):
    response = client.post(
        "/notifications/welcome",
        json={
            "email": "student@edusphere.local",
            "full_name": "John Doe"
        }
    )
    assert response.status_code == 403
    assert response.json()["detail"] == "Forbidden: Invalid service key"


def test_trigger_welcome_email_success(client):
    headers = {"X-Internal-Key": settings.INTERNAL_API_KEY}
    response = client.post(
        "/notifications/welcome",
        json={
            "email": "student@edusphere.local",
            "full_name": "John Doe"
        },
        headers=headers
    )
    assert response.status_code == 201
    data = response.json()
    assert data["recipient_email"] == "student@edusphere.local"
    assert data["notification_type"] == "welcome"
    assert data["is_sent"] is True  # Mock sending succeeds
    assert "id" in data


def test_trigger_enrollment_email_success(client):
    headers = {"X-Internal-Key": settings.INTERNAL_API_KEY}
    response = client.post(
        "/notifications/enrollment",
        json={
            "email": "student@edusphere.local",
            "full_name": "John Doe",
            "course_title": "Kubernetes Mastery"
        },
        headers=headers
    )
    assert response.status_code == 201
    data = response.json()
    assert data["recipient_email"] == "student@edusphere.local"
    assert data["notification_type"] == "enrollment"
    assert "Kubernetes Mastery" in data["subject"]


def test_trigger_certificate_email_success(client):
    headers = {"X-Internal-Key": settings.INTERNAL_API_KEY}
    response = client.post(
        "/notifications/certificate",
        json={
            "email": "student@edusphere.local",
            "full_name": "John Doe",
            "course_title": "Kubernetes Mastery",
            "certificate_code": "CERT-12345-XYZ"
        },
        headers=headers
    )
    assert response.status_code == 201
    data = response.json()
    assert data["recipient_email"] == "student@edusphere.local"
    assert data["notification_type"] == "certificate"
    assert "CERT-12345-XYZ" in data["body"]


def test_trigger_password_reset_email_success(client):
    headers = {"X-Internal-Key": settings.INTERNAL_API_KEY}
    response = client.post(
        "/notifications/password-reset",
        json={
            "email": "student@edusphere.local",
            "full_name": "John Doe",
            "reset_link": "http://localhost/reset-password?token=abcdef"
        },
        headers=headers
    )
    assert response.status_code == 201
    data = response.json()
    assert data["recipient_email"] == "student@edusphere.local"
    assert data["notification_type"] == "password_reset"


def test_get_notification_history(client):
    headers = {"X-Internal-Key": settings.INTERNAL_API_KEY}
    # Insert multiple
    client.post(
        "/notifications/welcome",
        json={"email": "student1@edusphere.local", "full_name": "Student One"},
        headers=headers
    )
    client.post(
        "/notifications/welcome",
        json={"email": "student2@edusphere.local", "full_name": "Student Two"},
        headers=headers
    )

    response = client.get("/notifications/history", headers=headers)
    assert response.status_code == 200
    history = response.json()
    assert len(history) >= 2
    assert history[0]["recipient_email"] in ["student1@edusphere.local", "student2@edusphere.local"]
