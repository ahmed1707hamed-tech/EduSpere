import uuid
from typing import Optional
import boto3
from botocore.config import Config
from botocore.exceptions import ClientError
from fastapi import HTTPException, status
from app.core.config import settings

class S3Service:
    def __init__(self):
        # Configure boto3 to connect to MinIO locally, or AWS S3 in production
        self.s3_client = boto3.client(
            "s3",
            endpoint_url=settings.S3_ENDPOINT_URL,
            aws_access_key_id=settings.S3_ACCESS_KEY,
            aws_secret_access_key=settings.S3_SECRET_KEY,
            region_name=settings.S3_REGION,
            config=Config(signature_version="s3v4")
        )
        self.bucket = settings.S3_BUCKET
        self._ensure_bucket_exists()

    def _ensure_bucket_exists(self):
        try:
            self.s3_client.head_bucket(Bucket=self.bucket)
        except ClientError as e:
            error_code = e.response.get("Error", {}).get("Code")
            if error_code in ["404", "NoSuchBucket"] or e.response.get("ResponseMetadata", {}).get("HTTPStatusCode") == 404:
                try:
                    if settings.S3_REGION == "us-east-1":
                        self.s3_client.create_bucket(Bucket=self.bucket)
                    else:
                        self.s3_client.create_bucket(
                            Bucket=self.bucket,
                            CreateBucketConfiguration={"LocationConstraint": settings.S3_REGION}
                        )
                except Exception as ex:
                    print(f"Warning: Failed to auto-create bucket: {ex}")
            else:
                print(f"Warning: Could not connect to S3/MinIO: {e}")
        except Exception as e:
            print(f"Warning: S3/MinIO unavailable at startup: {e}")

    def upload_file(self, file_content: bytes, filename: str, content_type: str, user_id: int) -> str:
        # Generate a unique S3 key
        unique_id = uuid.uuid4()
        # Keep clean S3 paths: e.g. "user_2/uuid_filename.ext"
        clean_filename = "".join(c for c in filename if c.isalnum() or c in "._-")
        s3_key = f"user_{user_id}/{unique_id}_{clean_filename}"
        
        try:
            self.s3_client.put_object(
                Bucket=self.bucket,
                Key=s3_key,
                Body=file_content,
                ContentType=content_type
            )
            return s3_key
        except ClientError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to upload file to S3: {str(e)}"
            )

    def generate_presigned_url(self, s3_key: str, expiration: int = 3600) -> str:
        try:
            url = self.s3_client.generate_presigned_url(
                "get_object",
                Params={"Bucket": self.bucket, "Key": s3_key},
                ExpiresIn=expiration
            )
            return url
        except ClientError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to generate signed URL: {str(e)}"
            )

    def delete_file(self, s3_key: str) -> None:
        try:
            self.s3_client.delete_object(Bucket=self.bucket, Key=s3_key)
        except ClientError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to delete file from S3: {str(e)}"
            )
