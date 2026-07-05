from jose import jwt
from app.core.config import settings

def get_auth_headers(user_id: int, email: str, role: str) -> dict:
    payload = {
        "user_id": user_id,
        "sub": email,
        "role": role,
        "type": "access"
    }
    token = jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return {"Authorization": f"Bearer {token}"}


def test_create_course(client):
    headers = get_auth_headers(user_id=2, email="instructor@example.com", role="instructor")
    response = client.post(
        "/api/courses/",
        json={
            "title": "Introduction to FastAPI",
            "description": "Learn the basics of FastAPI and Python microservices.",
            "category": "Programming",
            "price": 49.99
        },
        headers=headers
    )
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Introduction to FastAPI"
    assert data["instructor_id"] == 2
    assert data["is_published"] is False


def test_create_course_unauthorized(client):
    headers = get_auth_headers(user_id=3, email="student@example.com", role="student")
    response = client.post(
        "/api/courses/",
        json={
            "title": "Introduction to FastAPI",
            "description": "Learn the basics of FastAPI and Python microservices.",
            "category": "Programming",
            "price": 49.99
        },
        headers=headers
    )
    assert response.status_code == 403  # Forbidden for students


def test_get_courses(client):
    # Create a published course and an unpublished course
    headers = get_auth_headers(user_id=2, email="instructor@example.com", role="instructor")
    client.post(
        "/api/courses/",
        json={"title": "Course 1", "description": "Desc 1", "category": "Programming", "price": 0.0},
        headers=headers
    )
    
    # By default, get_courses returns published courses. Let's verify.
    response = client.get("/api/courses/")
    assert response.status_code == 200
    assert len(response.json()) == 0  # Course 1 is unpublished
    
    # Get all courses including unpublished
    response = client.get("/api/courses/?is_published=false")
    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["title"] == "Course 1"


def test_course_module_lesson_flow(client):
    instructor_headers = get_auth_headers(user_id=2, email="instructor@example.com", role="instructor")
    
    # 1. Create Course
    course_response = client.post(
        "/api/courses/",
        json={"title": "Fullstack Course", "description": "Fullstack desc", "category": "Web Dev"},
        headers=instructor_headers
    )
    course_id = course_response.json()["id"]
    
    # 2. Create Module
    module_response = client.post(
        f"/api/courses/{course_id}/modules",
        json={"title": "Module 1: Setup", "description": "Setting up environment", "order": 1},
        headers=instructor_headers
    )
    assert module_response.status_code == 201
    module_id = module_response.json()["id"]
    
    # 3. Create Lesson
    lesson_response = client.post(
        f"/api/courses/modules/{module_id}/lessons",
        json={
            "title": "Lesson 1.1: Installation",
            "content_type": "video",
            "content_url": "s3://bucket/lesson1.mp4",
            "order": 1
        },
        headers=instructor_headers
    )
    assert lesson_response.status_code == 201
    
    # 4. Get Course Details
    detail_response = client.get(f"/api/courses/{course_id}")
    assert detail_response.status_code == 200
    data = detail_response.json()
    assert len(data["modules"]) == 1
    assert len(data["modules"][0]["lessons"]) == 1
    assert data["modules"][0]["lessons"][0]["title"] == "Lesson 1.1: Installation"


def test_enrollment_flow(client):
    instructor_headers = get_auth_headers(user_id=2, email="instructor@example.com", role="instructor")
    student_headers = get_auth_headers(user_id=3, email="student@example.com", role="student")
    
    # 1. Create Course
    course_response = client.post(
        "/api/courses/",
        json={"title": "FastAPI Course", "description": "Learn FastAPI"},
        headers=instructor_headers
    )
    course_id = course_response.json()["id"]
    
    # 2. Try to enroll in unpublished course -> should fail
    enroll_response = client.post(f"/api/courses/{course_id}/enroll", headers=student_headers)
    assert enroll_response.status_code == 400
    
    # 3. Publish course
    publish_response = client.put(
        f"/api/courses/{course_id}",
        json={"is_published": True},
        headers=instructor_headers
    )
    assert publish_response.status_code == 200
    assert publish_response.json()["is_published"] is True
    
    # 4. Enroll in published course -> should succeed
    enroll_response = client.post(f"/api/courses/{course_id}/enroll", headers=student_headers)
    assert enroll_response.status_code == 201
    
    # 5. Verify student's enrolled courses
    enrolled_response = client.get("/api/courses/enrolled/me", headers=student_headers)
    assert enrolled_response.status_code == 200
    assert len(enrolled_response.json()) == 1
    assert enrolled_response.json()[0]["id"] == course_id
