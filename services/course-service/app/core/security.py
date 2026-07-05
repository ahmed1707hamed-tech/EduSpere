from typing import Optional, List
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from pydantic import BaseModel

from app.core.config import settings

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


class UserPayload(BaseModel):
    user_id: int
    email: str
    role: str


def verify_token(token: str) -> Optional[UserPayload]:
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        user_id = payload.get("user_id")
        email = payload.get("sub")
        role = payload.get("role")
        
        if user_id is None or email is None or role is None:
            return None
            
        return UserPayload(user_id=user_id, email=email, role=role)
    except JWTError:
        return None


def get_current_user(token: str = Depends(oauth2_scheme)) -> UserPayload:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    user_payload = verify_token(token)
    if user_payload is None:
        raise credentials_exception
    return user_payload


class RoleChecker:
    def __init__(self, allowed_roles: List[str]):
        self.allowed_roles = allowed_roles

    def __call__(self, current_user: UserPayload = Depends(get_current_user)) -> UserPayload:
        if current_user.role not in self.allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to access this resource"
            )
        return current_user
