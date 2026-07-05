from typing import Optional, List
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.course import Course, Module, Lesson, Enrollment
from app.schemas.course import (
    CourseCreate,
    CourseUpdate,
    ModuleCreate,
    ModuleUpdate,
    LessonCreate,
    LessonUpdate
)
from app.repositories.course_repository import CourseRepository

class CourseService:
    def __init__(self, db: Session):
        self.db = db
        self.course_repo = CourseRepository(db)

    # Course Services
    def create_course(self, instructor_id: int, data: CourseCreate) -> Course:
        course = Course(
            title=data.title,
            description=data.description,
            instructor_id=instructor_id,
            category=data.category,
            price=data.price,
            is_published=False
        )
        return self.course_repo.create(course)

    def get_course_by_id(self, course_id: int) -> Course:
        course = self.course_repo.get_by_id(course_id)
        if not course:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Course not found"
            )
        return course

    def get_all_courses(
        self,
        skip: int = 0,
        limit: int = 100,
        category: Optional[str] = None,
        search: Optional[str] = None,
        is_published: Optional[bool] = None
    ) -> List[Course]:
        return self.course_repo.get_all(skip, limit, category, search, is_published)

    def update_course(self, course_id: int, user_id: int, user_role: str, data: CourseUpdate) -> Course:
        course = self.get_course_by_id(course_id)
        
        # Access check: Only the creator instructor or an admin can update
        if user_role != "admin" and course.instructor_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to modify this course"
            )
            
        for field, value in data.model_dump(exclude_unset=True).items():
            setattr(course, field, value)
            
        return self.course_repo.update(course)

    def delete_course(self, course_id: int, user_id: int, user_role: str) -> None:
        course = self.get_course_by_id(course_id)
        
        # Access check: Only the creator instructor or an admin can delete
        if user_role != "admin" and course.instructor_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to delete this course"
            )
            
        self.course_repo.delete(course)

    # Module Services
    def create_module(self, course_id: int, instructor_id: int, data: ModuleCreate) -> Module:
        course = self.get_course_by_id(course_id)
        if course.instructor_id != instructor_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to add modules to this course"
            )
            
        module = Module(
            course_id=course_id,
            title=data.title,
            description=data.description,
            order=data.order
        )
        return self.course_repo.create_module(module)

    def update_module(self, module_id: int, instructor_id: int, data: ModuleUpdate) -> Module:
        module = self.course_repo.get_module_by_id(module_id)
        if not module:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Module not found")
            
        course = self.get_course_by_id(module.course_id)
        if course.instructor_id != instructor_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to modify this module"
            )
            
        for field, value in data.model_dump(exclude_unset=True).items():
            setattr(module, field, value)
            
        return self.course_repo.update_module(module)

    def delete_module(self, module_id: int, instructor_id: int) -> None:
        module = self.course_repo.get_module_by_id(module_id)
        if not module:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Module not found")
            
        course = self.get_course_by_id(module.course_id)
        if course.instructor_id != instructor_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to delete this module"
            )
            
        self.course_repo.delete_module(module)

    # Lesson Services
    def create_lesson(self, module_id: int, instructor_id: int, data: LessonCreate) -> Lesson:
        module = self.course_repo.get_module_by_id(module_id)
        if not module:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Module not found")
            
        course = self.get_course_by_id(module.course_id)
        if course.instructor_id != instructor_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to add lessons to this module"
            )
            
        lesson = Lesson(
            module_id=module_id,
            title=data.title,
            content_type=data.content_type,
            content_url=data.content_url,
            order=data.order
        )
        return self.course_repo.create_lesson(lesson)

    def update_lesson(self, lesson_id: int, instructor_id: int, data: LessonUpdate) -> Lesson:
        lesson = self.course_repo.get_lesson_by_id(lesson_id)
        if not lesson:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Lesson not found")
            
        module = self.course_repo.get_module_by_id(lesson.module_id)
        course = self.get_course_by_id(module.course_id)
        if course.instructor_id != instructor_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to modify this lesson"
            )
            
        for field, value in data.model_dump(exclude_unset=True).items():
            setattr(lesson, field, value)
            
        return self.course_repo.update_lesson(lesson)

    def delete_lesson(self, lesson_id: int, instructor_id: int) -> None:
        lesson = self.course_repo.get_lesson_by_id(lesson_id)
        if not lesson:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Lesson not found")
            
        module = self.course_repo.get_module_by_id(lesson.module_id)
        course = self.get_course_by_id(module.course_id)
        if course.instructor_id != instructor_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to delete this lesson"
            )
            
        self.course_repo.delete_lesson(lesson)

    # Enrollment Services
    def enroll_student(self, student_id: int, course_id: int) -> Enrollment:
        course = self.get_course_by_id(course_id)
        if not course.is_published:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot enroll in an unpublished course"
            )
            
        existing = self.course_repo.get_enrollment(student_id, course_id)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Student is already enrolled in this course"
            )
            
        enrollment = Enrollment(student_id=student_id, course_id=course_id)
        return self.course_repo.create_enrollment(enrollment)

    def get_enrolled_courses(self, student_id: int) -> List[Course]:
        enrollments = self.course_repo.get_student_enrollments(student_id)
        return [e.course for e in enrollments]
