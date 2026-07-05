import uuid
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.orm import Session, joinedload

from app.models.quiz import Quiz, Question, AnswerOption, QuizAttempt, LessonProgress, Certificate
from app.schemas.quiz import QuizCreate, QuestionCreate, QuizAttemptSubmit, LessonProgressCreate

class QuizService:
    def __init__(self, db: Session):
        self.db = db

    # Quiz operations
    def create_quiz(self, data: QuizCreate) -> Quiz:
        quiz = Quiz(
            course_id=data.course_id,
            title=data.title,
            description=data.description,
            passing_score=data.passing_score
        )
        self.db.add(quiz)
        self.db.commit()
        self.db.refresh(quiz)
        return quiz

    def get_quiz_by_id(self, quiz_id: int) -> Quiz:
        quiz = self.db.query(Quiz).options(
            joinedload(Quiz.questions).joinedload(Question.options)
        ).filter(Quiz.id == quiz_id).first()
        
        if not quiz:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Quiz not found"
            )
        return quiz

    def get_quizzes_by_course(self, course_id: int) -> List[Quiz]:
        return self.db.query(Quiz).filter(Quiz.course_id == course_id).all()

    # Question operations
    def add_question(self, quiz_id: int, data: QuestionCreate) -> Question:
        # Verify quiz exists
        self.get_quiz_by_id(quiz_id)
        
        question = Question(
            quiz_id=quiz_id,
            question_text=data.question_text,
            question_type=data.question_type
        )
        self.db.add(question)
        self.db.commit()
        self.db.refresh(question)

        for opt in data.options:
            option = AnswerOption(
                question_id=question.id,
                option_text=opt.option_text,
                is_correct=opt.is_correct
            )
            self.db.add(option)
            
        self.db.commit()
        self.db.refresh(question)
        return question

    def delete_question(self, question_id: int) -> None:
        question = self.db.query(Question).filter(Question.id == question_id).first()
        if not question:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Question not found")
        self.db.delete(question)
        self.db.commit()

    # Quiz Grading and Submission
    def submit_quiz(self, quiz_id: int, student_id: int, submission: QuizAttemptSubmit) -> QuizAttempt:
        quiz = self.get_quiz_by_id(quiz_id)
        
        if not quiz.questions:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This quiz has no questions and cannot be graded"
            )
            
        # Map submission answers
        sub_map = {ans.question_id: ans.selected_option_id for ans in submission.answers}
        
        correct_count = 0
        total_questions = len(quiz.questions)
        
        for q in quiz.questions:
            selected_opt_id = sub_map.get(q.id)
            if selected_opt_id:
                # Find if the selected option is correct
                correct_opt = next((o for o in q.options if o.id == selected_opt_id and o.is_correct), None)
                if correct_opt:
                    correct_count += 1

        score = (correct_count / total_questions) * 100
        passed = score >= quiz.passing_score
        
        attempt = QuizAttempt(
            quiz_id=quiz_id,
            student_id=student_id,
            score=round(score, 2),
            passed=passed
        )
        self.db.add(attempt)
        self.db.commit()
        self.db.refresh(attempt)
        
        # If the student passed, automatically issue a Certificate for the course!
        if passed:
            self.generate_certificate(student_id, quiz.course_id)
            
        return attempt

    # Progress Tracking
    def mark_lesson_progress(self, student_id: int, data: LessonProgressCreate) -> LessonProgress:
        progress = self.db.query(LessonProgress).filter(
            LessonProgress.student_id == student_id,
            LessonProgress.lesson_id == data.lesson_id
        ).first()
        
        if not progress:
            progress = LessonProgress(
                student_id=student_id,
                lesson_id=data.lesson_id,
                is_completed=data.is_completed
            )
            self.db.add(progress)
        else:
            progress.is_completed = data.is_completed
            
        self.db.commit()
        self.db.refresh(progress)
        return progress

    def get_completed_lessons(self, student_id: int) -> List[int]:
        progress_list = self.db.query(LessonProgress).filter(
            LessonProgress.student_id == student_id,
            LessonProgress.is_completed == True
        ).all()
        return [p.lesson_id for p in progress_list]

    # Certificate Generation
    def generate_certificate(self, student_id: int, course_id: int) -> Certificate:
        # Check if certificate already exists
        existing = self.db.query(Certificate).filter(
            Certificate.student_id == student_id,
            Certificate.course_id == course_id
        ).first()
        
        if existing:
            return existing
            
        # Generate a unique certificate code
        cert_code = f"EDU-{course_id:04d}-{student_id:04d}-{uuid.uuid4().hex[:8].upper()}"
        
        certificate = Certificate(
            student_id=student_id,
            course_id=course_id,
            certificate_code=cert_code
        )
        self.db.add(certificate)
        self.db.commit()
        self.db.refresh(certificate)
        return certificate

    def get_certificates(self, student_id: int) -> List[Certificate]:
        return self.db.query(Certificate).filter(Certificate.student_id == student_id).all()
