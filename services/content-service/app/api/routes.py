from typing import List
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from sqlalchemy.orm import Session

from app.database.database import get_db
from app.models.content import MediaItem
from app.schemas.content import MediaItemResponse, SignedUrlResponse
from app.services.s3_service import S3Service
from app.core.security import get_current_user, RoleChecker, UserPayload

router = APIRouter(prefix="/content", tags=["Content"])
s3_service = S3Service()


@router.post("/upload", response_model=MediaItemResponse, status_code=status.HTTP_201_CREATED)
async def upload_file(
    file: UploadFile = File(...),
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    # Read file content
    content = await file.read()
    if not content:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File is empty"
        )
        
    # Upload to S3/MinIO
    s3_key = s3_service.upload_file(
        file_content=content,
        filename=file.filename,
        content_type=file.content_type,
        user_id=current_user.user_id
    )
    
    # Save metadata to DB
    media_item = MediaItem(
        filename=file.filename,
        file_type=file.content_type,
        s3_key=s3_key,
        uploaded_by=current_user.user_id
    )
    db.add(media_item)
    db.commit()
    db.refresh(media_item)
    
    return media_item


@router.get("/url/{media_id}", response_model=SignedUrlResponse)
def get_signed_url(
    media_id: int,
    expires_in: int = 3600,
    current_user: UserPayload = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    media_item = db.query(MediaItem).filter(MediaItem.id == media_id).first()
    if not media_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Media item not found"
        )
        
    # Generate pre-signed URL
    url = s3_service.generate_presigned_url(media_item.s3_key, expiration=expires_in)
    
    return SignedUrlResponse(
        url=url,
        s3_key=media_item.s3_key,
        expires_in=expires_in
    )


@router.delete("/{media_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_media_item(
    media_id: int,
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    media_item = db.query(MediaItem).filter(MediaItem.id == media_id).first()
    if not media_item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Media item not found"
        )
        
    # Access check: Only the instructor who uploaded it, or an admin
    if current_user.role != "admin" and media_item.uploaded_by != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to delete this file"
        )
        
    # Delete from S3/MinIO
    s3_service.delete_file(media_item.s3_key)
    
    # Delete metadata from DB
    db.delete(media_item)
    db.commit()
    
    return None


@router.get("/my-files", response_model=List[MediaItemResponse])
def get_my_files(
    current_user: UserPayload = Depends(RoleChecker(["instructor", "admin"])),
    db: Session = Depends(get_db)
):
    return db.query(MediaItem).filter(MediaItem.uploaded_by == current_user.user_id).all()
