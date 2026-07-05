from typing import Optional, List
from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload
from app.models.course import Course, Module, Lesson, Enrollment

class CourseRepository:
    def __init__(self, db: Session):
        self.db = db

    # Course operations
    def get_by_id(self, course_id: int) -> Optional[Course]:
        # Use joinedload to eagerly load modules and lessons to avoid N+1 query issues
        return self.db.query(Course).options(
            joinedload(Course.modules).joinedload(Module.lessons)
        ).filter(Course.id == course_id).first()

    def get_all(
        self,
        skip: int = 0,
        limit: int = 100,
        category: Optional[str] = None,
        search: Optional[str] = None,
        is_published: Optional[bool] = None
    ) -> List[Course]:
        query = self.db.query(Course)
        
        if is_published is not None:
            query = query.filter(Course.is_published == is_published)
            
        if category:
            query = query.filter(Course.category.iexact(category))
            
        if search:
            query = query.filter(
                or_(
                    Course.title.ilike(f"%{search}%"),
                    Course.description.ilike(f"%{search}%")
                )
            )
            
        return query.offset(skip).limit(limit).all()

    def create(self, course: Course) -> Course:
        self.db.add(course)
        self.db.commit()
        self.db.refresh(course)
        return course

    def update(self, course: Course) -> Course:
        self.db.commit()
        self.db.refresh(course)
        return course

    def delete(self, course: Course) -> None:
        self.db.delete(course)
        self.db.commit()

    # Module operations
    def get_module_by_id(self, module_id: int) -> Optional[Module]:
        return self.db.query(Module).options(
            joinedload(Module.lessons)
        ).filter(Module.id == module_id).first()

    def create_module(self, module: Module) -> Module:
        self.db.add(module)
        self.db.commit()
        self.db.refresh(module)
        return module

    def update_module(self, module: Module) -> Module:
        self.db.commit()
        self.db.refresh(module)
        return module

    def delete_module(self, module: Module) -> None:
        self.db.delete(module)
        self.db.commit()

    # Lesson operations
    def get_lesson_by_id(self, lesson_id: int) -> Optional[Lesson]:
        return self.db.query(Lesson).filter(Lesson.id == lesson_id).first()

    def create_lesson(self, lesson: Lesson) -> Lesson:
        self.db.add(lesson)
        self.db.commit()
        self.db.refresh(lesson)
        return lesson

    def update_lesson(self, lesson: Lesson) -> Lesson:
        self.db.commit()
        self.db.refresh(lesson)
        return lesson

    def delete_lesson(self, lesson: Lesson) -> None:
        self.db.delete(lesson)
        self.db.commit()

    # Enrollment operations
    def get_enrollment(self, student_id: int, course_id: int) -> Optional[Enrollment]:
        return self.db.query(Enrollment).filter(
            Enrollment.student_id == student_id,
            Enrollment.course_id == course_id
        ).first()

    def get_student_enrollments(self, student_id: int) -> List[Enrollment]:
        return self.db.query(Enrollment).options(
            joinedload(Enrollment.course)
        ).filter(Enrollment.student_id == student_id).all()

    def create_enrollment(self, enrollment: Enrollment) -> Enrollment:
        self.db.add(enrollment)
        self.db.commit()
        self.db.refresh(enrollment)
        return enrollment
