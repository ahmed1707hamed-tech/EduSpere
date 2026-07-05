import logging
import smtplib
from datetime import datetime
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import Optional
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.notification import Notification
from app.repositories.notification_repository import NotificationRepository

logger = logging.getLogger(__name__)

# CSS Styling and layout for email templates
EMAIL_LAYOUT = """
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {{
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            background-color: #f8fafc;
            color: #0f172a;
            margin: 0;
            padding: 0;
        }}
        .container {{
            max-width: 600px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
            overflow: hidden;
            border: 1px solid #e2e8f0;
        }}
        .header {{
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            padding: 32px;
            text-align: center;
            color: #ffffff;
        }}
        .header h1 {{
            margin: 0;
            font-size: 28px;
            font-weight: 800;
            letter-spacing: -0.025em;
        }}
        .content {{
            padding: 32px;
            line-height: 1.6;
            font-size: 16px;
        }}
        .content h2 {{
            color: #1e1b4b;
            font-size: 20px;
            font-weight: 700;
            margin-top: 0;
        }}
        .button-container {{
            text-align: center;
            margin: 32px 0;
        }}
        .button {{
            background-color: #4f46e5;
            color: #ffffff !important;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: 600;
            display: inline-block;
        }}
        .footer {{
            background-color: #f1f5f9;
            padding: 24px;
            text-align: center;
            font-size: 12px;
            color: #64748b;
            border-top: 1px solid #e2e8f0;
        }}
        .meta-box {{
            background-color: #f8fafc;
            border: 1px dashed #cbd5e1;
            padding: 16px;
            border-radius: 8px;
            font-family: monospace;
            font-size: 14px;
            color: #334155;
            margin: 20px 0;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>EduSphere</h1>
        </div>
        <div class="content">
            {content_body}
        </div>
        <div class="footer">
            &copy; {current_year} EduSphere LMS. All rights reserved.<br>
            This is an automated system notification. Please do not reply directly to this email.
        </div>
    </div>
</body>
</html>
"""


class NotificationService:
    def __init__(self, db: Session):
        self.db = db
        self.repo = NotificationRepository(db)

    def _send_email_smtp(self, to_email: str, subject: str, html_body: str) -> bool:
        """Helper function to send email via SMTP, or logs it in dev mode if not configured."""
        if not settings.SMTP_HOST:
            logger.info("[SMTP MOCK] SMTP Host not configured. Outputting email details:")
            logger.info("TO: %s", to_email)
            logger.info("SUBJECT: %s", subject)
            logger.info("BODY:\n%s", html_body)
            return True

        try:
            msg = MIMEMultipart("alternative")
            msg["Subject"] = subject
            msg["From"] = settings.SMTP_FROM
            msg["To"] = to_email

            part = MIMEText(html_body, "html")
            msg.attach(part)

            # Connect to SMTP server
            server = smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT)
            if settings.SMTP_STARTTLS:
                server.starttls()
            
            if settings.SMTP_USERNAME and settings.SMTP_PASSWORD:
                server.login(settings.SMTP_USERNAME, settings.SMTP_PASSWORD)

            server.sendmail(settings.SMTP_FROM, [to_email], msg.as_string())
            server.quit()
            logger.info("Email sent successfully to %s", to_email)
            return True
        except Exception as e:
            logger.exception("Failed to send email via SMTP to %s", to_email)
            raise e

    def _create_and_send_notification(
        self,
        recipient_email: str,
        subject: str,
        content_body: str,
        notification_type: str
    ) -> Notification:
        # Wrap the content body in our beautiful layout
        html_body = EMAIL_LAYOUT.format(
            content_body=content_body,
            current_year=datetime.utcnow().year
        )

        notification = Notification(
            recipient_email=recipient_email,
            subject=subject,
            body=html_body,
            notification_type=notification_type,
            is_sent=False
        )
        self.repo.create(notification)

        try:
            success = self._send_email_smtp(recipient_email, subject, html_body)
            if success:
                notification.is_sent = True
                notification.sent_at = datetime.utcnow()
            else:
                notification.error_message = "Mock send failed"
        except Exception as e:
            notification.error_message = str(e)

        self.repo.update(notification)
        return notification

    def send_welcome_email(self, recipient_email: str, full_name: str) -> Notification:
        subject = "Welcome to EduSphere! 🚀"
        content_body = f"""
        <h2>Hello, {full_name}!</h2>
        <p>Thank you for registering at <strong>EduSphere</strong>, the cloud-native Learning Management System.</p>
        <p>Your account is now active. You can log in, browse the course catalog, enroll in courses, upload materials (if you're an instructor), and take graded quizzes to earn official completion certificates.</p>
        <div class="button-container">
            <a href="{settings.FRONTEND_URL}/login" class="button">Log In to EduSphere</a>
        </div>
        <p>If you have any questions or require support, please don't hesitate to reach out to the admin team.</p>
        <p>Happy Learning!<br>The EduSphere Team</p>
        """
        return self._create_and_send_notification(recipient_email, subject, content_body, "welcome")

    def send_enrollment_email(self, recipient_email: str, full_name: str, course_title: str) -> Notification:
        subject = f"Enrolled successfully: {course_title} 📚"
        content_body = f"""
        <h2>Hello, {full_name}!</h2>
        <p>You have successfully enrolled in the course: <strong>{course_title}</strong>.</p>
        <p>This course has been added to your dashboard. You can resume your progress, view syllabus modules and lessons, watch video lectures, review reading material, and complete the assessments at your own pace.</p>
        <div class="button-container">
            <a href="{settings.FRONTEND_URL}/dashboard" class="button">Go to Dashboard</a>
        </div>
        <p>Enjoy the course!<br>The EduSphere Team</p>
        """
        return self._create_and_send_notification(recipient_email, subject, content_body, "enrollment")

    def send_certificate_email(self, recipient_email: str, full_name: str, course_title: str, certificate_code: str) -> Notification:
        subject = f"Congratulations! Certificate earned for {course_title} 🎓"
        content_body = f"""
        <h2>Outstanding job, {full_name}!</h2>
        <p>Congratulations on successfully passing the final assessment and completing the course: <strong>{course_title}</strong>.</p>
        <p>In recognition of your achievement, we have issued your official completion certificate. You can view, verify, or download your certificate from your profile settings.</p>
        <div class="meta-box">
            Certificate Verification Code: {certificate_code}<br>
            Issue Date: {datetime.utcnow().strftime('%B %d, %Y')}
        </div>
        <div class="button-container">
            <a href="{settings.FRONTEND_URL}/profile" class="button">View Certificate</a>
        </div>
        <p>Keep up the great work!<br>The EduSphere Team</p>
        """
        return self._create_and_send_notification(recipient_email, subject, content_body, "certificate")

    def send_password_reset_email(self, recipient_email: str, full_name: str, reset_link: str) -> Notification:
        subject = "Reset your EduSphere Password 🔒"
        content_body = f"""
        <h2>Hello, {full_name}!</h2>
        <p>We received a request to reset the password for your EduSphere account. Click the button below to specify a new password:</p>
        <div class="button-container">
            <a href="{reset_link}" class="button">Reset Password</a>
        </div>
        <p>If you did not make this request, you can safely ignore this email; your password will remain unchanged.</p>
        <p>This link is valid for a limited time only.</p>
        <p>Best regards,<br>The EduSphere Team</p>
        """
        return self._create_and_send_notification(recipient_email, subject, content_body, "password_reset")
