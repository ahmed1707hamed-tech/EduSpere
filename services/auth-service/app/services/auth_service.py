from fastapi import HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.user import User
from app.schemas.user import (
    UserCreate,
    TokenResponse,
    PasswordChange,
    UserUpdate,
    PasswordResetRequest
)
from app.repositories.user_repository import UserRepository
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    verify_token
)

class AuthService:
    def __init__(self, db: Session):
        self.db = db
        self.user_repo = UserRepository(db)

    def register(self, user_data: UserCreate) -> User:
        existing_user = self.user_repo.get_by_email(user_data.email)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email is already registered"
            )
        
        role = user_data.role
        if role not in ["student", "instructor", "admin"]:
            role = "student"

        new_user = User(
            full_name=user_data.full_name,
            email=user_data.email,
            hashed_password=hash_password(user_data.password),
            role=role,
            is_active=True
        )
        try:
            return self.user_repo.create(new_user)
        except IntegrityError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email is already registered"
            )

    def login(self, login_data: OAuth2PasswordRequestForm) -> TokenResponse:
        user = self.user_repo.get_by_email(login_data.username)
        if not user or not verify_password(login_data.password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User account is inactive"
            )

        access_token = create_access_token(data={"sub": user.email, "role": user.role, "user_id": user.id})
        refresh_token = create_refresh_token(data={"sub": user.email})
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            role=user.role
        )

    def refresh_token(self, refresh_token: str) -> TokenResponse:
        payload = verify_token(refresh_token, "refresh")
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        email = payload.get("sub")
        user = self.user_repo.get_by_email(email)
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found or inactive",
                headers={"WWW-Authenticate": "Bearer"},
            )

        access_token = create_access_token(data={"sub": user.email, "role": user.role, "user_id": user.id})
        new_refresh_token = create_refresh_token(data={"sub": user.email})

        return TokenResponse(
            access_token=access_token,
            refresh_token=new_refresh_token,
            role=user.role
        )

    def change_password(self, user: User, data: PasswordChange) -> None:
        if not verify_password(data.old_password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Incorrect current password"
            )
        
        user.hashed_password = hash_password(data.new_password)
        self.user_repo.update(user)

    def update_profile(self, user: User, data: UserUpdate) -> User:
        if data.full_name:
            user.full_name = data.full_name
        if data.email and data.email != user.email:
            existing = self.user_repo.get_by_email(data.email)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Email is already in use"
                )
            user.email = data.email
            
        return self.user_repo.update(user)

    def forgot_password(self, data: PasswordResetRequest) -> dict:
        user = self.user_repo.get_by_email(data.email)
        if user:
            print(f"[MOCK EMAIL] Password reset requested for {user.email}. Send token or link.")
        return {"message": "If the email is registered, a password reset link has been sent."}