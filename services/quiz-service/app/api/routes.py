from typing import List
from fastapi import APIRouter, Depends, status, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session

from app.utils.notification_helper import send_notification_task

from app.database.database import get_db
from app.schemas.quiz import (
    QuizCreate,
    QuizResponse,
    QuizDetailResponse,
    QuizDetailAdminResponse,
    QuestionCreate,
    QuestionResponse,
    QuestionDetailResponse,
    QuizAttemptSubmit,
    QuizAttemptResponse,
    LessonProgressCreate,
    LessonProgressResponse,
    CertificateResponse
)
from app.services.quiz_service import QuizService
from app.core.security import get_current_user, RoleChecker, UserPayload

router = APIRouter(prefix="/quizzes", tags=["Quiz & Progress"])


# Quiz CRUD
@router.post("/", response_model=QuizResponse, status_code=status.HTTP_201_CREATED)
def create_quiz(
    data: QuizCreate,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    quiz_service = QuizService(db)
    return quiz_service.create_quiz(data)


@router.get("/course/{course_id}", response_model=List[QuizResponse])
def get_course_quizzes(
    course_id: int,
    current_user: UserPayload = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    quiz_service = QuizService(db)
    return quiz_service.get_quizzes_by_course(course_id)


@router.get("/{quiz_id}")
def get_quiz(
    quiz_id: int,
    current_user: UserPayload = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    quiz_service = QuizService(db)
    quiz = quiz_service.get_quiz_by_id(quiz_id)
    
    # If student, return quiz WITHOUT correct answer flags
    if current_user.role == "student":
        return QuizDetailResponse.model_validate(quiz)
        
    # If instructor/admin, return quiz WITH correct answer flags
    return QuizDetailAdminResponse.model_validate(quiz)


# Question CRUD
@router.post("/{quiz_id}/questions", response_model=QuestionDetailResponse, status_code=status.HTTP_201_CREATED)
def add_question(
    quiz_id: int,
    data: QuestionCreate,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    quiz_service = QuizService(db)
    return quiz_service.add_question(quiz_id, data)


@router.delete("/questions/{question_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_question(
    question_id: int,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    quiz_service = QuizService(db)
    quiz_service.delete_question(question_id)
    return None


# Quiz Submission
@router.post("/{quiz_id}/submit", response_model=QuizAttemptResponse, status_code=status.HTTP_201_CREATED)
def submit_quiz(
    quiz_id: int,
    submission: QuizAttemptSubmit,
    background_tasks: BackgroundTasks,
    current_user: UserPayload = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    quiz_service = QuizService(db)
    attempt = quiz_service.submit_quiz(quiz_id, current_user.user_id, submission)
    
    if attempt.passed:
        try:
            quiz = quiz_service.get_quiz_by_id(quiz_id)
            from app.models.quiz import Certificate
            certificate = db.query(Certificate).filter(
                Certificate.student_id == current_user.user_id,
                Certificate.course_id == quiz.course_id
            ).first()
            
            if certificate:
                friendly_name = current_user.email.split("@")[0].capitalize()
                background_tasks.add_task(
                    send_notification_task,
                    "/notifications/certificate",
                    {
                        "email": current_user.email,
                        "full_name": friendly_name,
                        "course_title": quiz.title,
                        "certificate_code": certificate.certificate_code
                    }
                )
        except Exception:
            pass
            
    return attempt


# Progress Tracking
@router.post("/progress", response_model=LessonProgressResponse)
def mark_progress(
    data: LessonProgressCreate,
    current_user: UserPayload = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    quiz_service = QuizService(db)
    return quiz_service.mark_lesson_progress(current_user.user_id, data)


@router.get("/progress/completed", response_model=List[int])
def get_completed_lessons(
    current_user: UserPayload = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    quiz_service = QuizService(db)
    return quiz_service.get_completed_lessons(current_user.user_id)


# Certificates
@router.get("/certificates/me", response_model=List[CertificateResponse])
def get_my_certificates(
    current_user: UserPayload = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    quiz_service = QuizService(db)
    return quiz_service.get_certificates(current_user.user_id)
