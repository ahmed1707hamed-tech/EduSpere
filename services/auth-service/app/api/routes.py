from typing import List
from fastapi import APIRouter, Depends, status, BackgroundTasks, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.utils.notification_helper import send_notification_task

from app.database.database import get_db
from app.schemas.user import (
    UserCreate,
    UserResponse,
    TokenResponse,
    TokenRefreshRequest,
    PasswordChange,
    UserUpdate,
    PasswordResetRequest
)
from app.services.auth_service import AuthService
from app.core.security import get_current_user, RoleChecker
from app.models.user import User
from app.repositories.user_repository import UserRepository

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(user: UserCreate, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    new_user = auth_service.register(user)
    background_tasks.add_task(
        send_notification_task,
        "/notifications/welcome",
        {"email": new_user.email, "full_name": new_user.full_name}
    )
    return new_user


from fastapi import Request

@router.post("/login", response_model=TokenResponse)
async def login(
    request: Request,
    db: Session = Depends(get_db)
):
    content_type = request.headers.get("content-type", "")
    username = None
    password = None

    if "application/json" in content_type:
        try:
            body = await request.json()
            username = body.get("email") or body.get("username")
            password = body.get("password")
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid JSON body")
    else:
        try:
            form = await request.form()
            username = form.get("username")
            password = form.get("password")
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid form data")

    if not username or not password:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Username and password are required"
        )

    class FormMock:
        def __init__(self, u, p):
            self.username = u
            self.password = p

    login_data = FormMock(username, password)
    auth_service = AuthService(db)
    return auth_service.login(login_data)


@router.post("/refresh", response_model=TokenResponse)
def refresh(refresh_data: TokenRefreshRequest, db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    return auth_service.refresh_token(refresh_data.refresh_token)


@router.post("/logout")
def logout(current_user: User = Depends(get_current_user)):
    return {"message": "Successfully logged out"}


@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.put("/me", response_model=UserResponse)
def update_me(data: UserUpdate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    return auth_service.update_profile(current_user, data)


@router.post("/change-password")
def change_password(data: PasswordChange, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    auth_service.change_password(current_user, data)
    return {"message": "Password changed successfully"}


@router.post("/forgot-password")
def forgot_password(data: PasswordResetRequest, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
    auth_service = AuthService(db)
    res = auth_service.forgot_password(data)
    user_repo = UserRepository(db)
    user = user_repo.get_by_email(data.email)
    if user:
        reset_link = f"http://localhost/reset-password?token=mock_token_123"
        background_tasks.add_task(
            send_notification_task,
            "/notifications/password-reset",
            {"email": user.email, "full_name": user.full_name, "reset_link": reset_link}
        )
    return res


@router.get("/users", response_model=List[UserResponse])
def get_users(
    skip: int = 0,
    limit: int = 100,
    admin_user: User = Depends(RoleChecker(["admin"])),
    db: Session = Depends(get_db)
):
    user_repo = UserRepository(db)
    return user_repo.get_all(skip=skip, limit=limit)