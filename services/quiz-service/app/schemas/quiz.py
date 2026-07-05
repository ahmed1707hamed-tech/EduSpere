from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field


# Answer Option Schemas
class AnswerOptionCreate(BaseModel):
    option_text: str = Field(..., min_length=1, max_length=500)
    is_correct: bool = False


class AnswerOptionResponse(BaseModel):
    id: int
    option_text: str

    class Config:
        from_attributes = True


class AnswerOptionDetailResponse(BaseModel):
    id: int
    option_text: str
    is_correct: bool

    class Config:
        from_attributes = True


# Question Schemas
class QuestionCreate(BaseModel):
    question_text: str = Field(..., min_length=2, max_length=1000)
    question_type: str = "multiple_choice"  # multiple_choice, true_false
    options: List[AnswerOptionCreate] = Field(..., min_items=2)


class QuestionResponse(BaseModel):
    id: int
    question_text: str
    question_type: str
    options: List[AnswerOptionResponse]

    class Config:
        from_attributes = True


class QuestionDetailResponse(BaseModel):
    id: int
    question_text: str
    question_type: str
    options: List[AnswerOptionDetailResponse]

    class Config:
        from_attributes = True


# Quiz Schemas
class QuizCreate(BaseModel):
    course_id: int
    title: str = Field(..., min_length=2, max_length=255)
    description: Optional[str] = None
    passing_score: int = Field(70, ge=0, le=100)


class QuizResponse(BaseModel):
    id: int
    course_id: int
    title: str
    description: Optional[str]
    passing_score: int
    created_at: datetime

    class Config:
        from_attributes = True


class QuizDetailResponse(QuizResponse):
    questions: List[QuestionResponse] = []

    class Config:
        from_attributes = True


class QuizDetailAdminResponse(QuizResponse):
    questions: List[QuestionDetailResponse] = []

    class Config:
        from_attributes = True


# Quiz Submission Schemas
class QuestionAnswerSubmission(BaseModel):
    question_id: int
    selected_option_id: int


class QuizAttemptSubmit(BaseModel):
    answers: List[QuestionAnswerSubmission]


class QuizAttemptResponse(BaseModel):
    id: int
    quiz_id: int
    student_id: int
    score: float
    passed: bool
    completed_at: datetime

    class Config:
        from_attributes = True


# Progress Schemas
class LessonProgressCreate(BaseModel):
    lesson_id: int
    is_completed: bool = True


class LessonProgressResponse(BaseModel):
    id: int
    student_id: int
    lesson_id: int
    is_completed: bool
    updated_at: datetime

    class Config:
        from_attributes = True


# Certificate Schemas
class CertificateResponse(BaseModel):
    id: int
    student_id: int
    course_id: int
    certificate_code: str
    issue_date: datetime

    class Config:
        from_attributes = True
