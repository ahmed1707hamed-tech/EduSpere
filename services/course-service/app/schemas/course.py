from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field


# Lesson Schemas
class LessonCreate(BaseModel):
    title: str = Field(..., min_length=2, max_length=255)
    content_type: str = Field("video", description="video, pdf, or text")
    content_url: Optional[str] = None
    order: int = 0


class LessonUpdate(BaseModel):
    title: Optional[str] = None
    content_type: Optional[str] = None
    content_url: Optional[str] = None
    order: Optional[int] = None


class LessonResponse(BaseModel):
    id: int
    module_id: int
    title: str
    content_type: str
    content_url: Optional[str]
    order: int

    class Config:
        from_attributes = True


# Module Schemas
class ModuleCreate(BaseModel):
    title: str = Field(..., min_length=2, max_length=255)
    description: Optional[str] = None
    order: int = 0


class ModuleUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    order: Optional[int] = None


class ModuleResponse(BaseModel):
    id: int
    course_id: int
    title: str
    description: Optional[str]
    order: int
    lessons: List[LessonResponse] = []

    class Config:
        from_attributes = True


# Course Schemas
class CourseCreate(BaseModel):
    title: str = Field(..., min_length=2, max_length=255)
    description: Optional[str] = Field(None, max_length=1000)
    category: str = "General"
    price: float = 0.0


class CourseUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    price: Optional[float] = None
    is_published: Optional[bool] = None


class CourseResponse(BaseModel):
    id: int
    title: str
    description: Optional[str]
    instructor_id: int
    category: str
    price: float
    is_published: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class CourseDetailResponse(CourseResponse):
    modules: List[ModuleResponse] = []

    class Config:
        from_attributes = True


# Enrollment Schemas
class EnrollmentCreate(BaseModel):
    course_id: int


class EnrollmentResponse(BaseModel):
    id: int
    student_id: int
    course_id: int
    enrolled_at: datetime

    class Config:
        from_attributes = True
