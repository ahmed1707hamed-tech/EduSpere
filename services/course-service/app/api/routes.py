from typing import List, Optional
from fastapi import APIRouter, Depends, status, BackgroundTasks
from sqlalchemy.orm import Session

from app.utils.notification_helper import send_notification_task

from app.database.database import get_db
from app.schemas.course import (
    CourseCreate,
    CourseUpdate,
    CourseResponse,
    CourseDetailResponse,
    ModuleCreate,
    ModuleUpdate,
    ModuleResponse,
    LessonCreate,
    LessonUpdate,
    LessonResponse,
    EnrollmentResponse
)
from app.services.course_service import CourseService
from app.core.security import get_current_user, RoleChecker, UserPayload

router = APIRouter(prefix="/courses", tags=["Courses"])


# Course Endpoints
@router.get("/", response_model=List[CourseResponse])
def get_courses(
    skip: int = 0,
    limit: int = 100,
    category: Optional[str] = None,
    search: Optional[str] = None,
    is_published: Optional[bool] = True,
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    return course_service.get_all_courses(
        skip=skip, limit=limit, category=category, search=search, is_published=is_published
    )


@router.post("/", response_model=CourseResponse, status_code=status.HTTP_201_CREATED)
def create_course(
    data: CourseCreate,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    return course_service.create_course(current_user.user_id, data)


@router.get("/enrolled/me", response_model=List[CourseResponse])
def get_my_enrolled_courses(
    current_user: UserPayload = Depends(RoleChecker(["student", "instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    return course_service.get_enrolled_courses(current_user.user_id)


@router.get("/{course_id}", response_model=CourseDetailResponse)
def get_course(course_id: int, db: Session = Depends(get_db)):
    course_service = CourseService(db)
    return course_service.get_course_by_id(course_id)


@router.put("/{course_id}", response_model=CourseResponse)
def update_course(
    course_id: int,
    data: CourseUpdate,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    return course_service.update_course(course_id, current_user.user_id, current_user.role, data)


@router.delete("/{course_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_course(
    course_id: int,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    course_service.delete_course(course_id, current_user.user_id, current_user.role)
    return None


# Module Endpoints
@router.post("/{course_id}/modules", response_model=ModuleResponse, status_code=status.HTTP_201_CREATED)
def create_module(
    course_id: int,
    data: ModuleCreate,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    return course_service.create_module(course_id, current_user.user_id, data)


@router.put("/modules/{module_id}", response_model=ModuleResponse)
def update_module(
    module_id: int,
    data: ModuleUpdate,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    return course_service.update_module(module_id, current_user.user_id, data)


@router.delete("/modules/{module_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_module(
    module_id: int,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    course_service.delete_module(module_id, current_user.user_id)
    return None


# Lesson Endpoints
@router.post("/modules/{module_id}/lessons", response_model=LessonResponse, status_code=status.HTTP_201_CREATED)
def create_lesson(
    module_id: int,
    data: LessonCreate,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    return course_service.create_lesson(module_id, current_user.user_id, data)


@router.put("/lessons/{lesson_id}", response_model=LessonResponse)
def update_lesson(
    lesson_id: int,
    data: LessonUpdate,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    return course_service.update_lesson(lesson_id, current_user.user_id, data)


@router.delete("/lessons/{lesson_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_lesson(
    lesson_id: int,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    course_service.delete_lesson(lesson_id, current_user.user_id)
    return None


# Enrollment Endpoints
@router.post("/{course_id}/enroll", response_model=EnrollmentResponse, status_code=status.HTTP_201_CREATED)
def enroll_in_course(
    course_id: int,
    background_tasks: BackgroundTasks,
    current_user: UserPayload = Depends(RoleChecker(["student", "instructor", "admin"])),
    db: Session = Depends(get_db)
):
    course_service = CourseService(db)
    enrollment = course_service.enroll_student(current_user.user_id, course_id)
    
    # Get course details for the title
    try:
        course = course_service.get_course_by_id(course_id)
        course_title = course.title
    except Exception:
        course_title = "EduSphere Course"

    # Queue enrollment email notification
    friendly_name = current_user.email.split("@")[0].capitalize()
    background_tasks.add_task(
        send_notification_task,
        "/notifications/enrollment",
        {
            "email": current_user.email,
            "full_name": friendly_name,
            "course_title": course_title
        }
    )
    return enrollment
