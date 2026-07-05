# EduSphere - Microservices Learning Management System (LMS)

EduSphere is a production-ready, cloud-native Learning Management System (LMS) built with a Microservices architecture. It is designed to demonstrate modern software engineering patterns, clean architecture, and enterprise-grade DevOps practices (infrastructure as code, container orchestration, GitOps, and observability).

---

## Architecture Overview

EduSphere is split into 4 independent backend microservices, a unified single-page frontend, and shared infrastructure components.

```mermaid
graph TD
    User([User Browser]) -->|HTTP/HTTPS: Port 80| Nginx[Nginx API Gateway]
    
    subgraph Frontend
        Nginx -->|/ | ReactApp[React + Vite Frontend]
     font-family: Inter, sans-serif;
    end

    subgraph Backend Microservices
        Nginx -->|/api/auth/*| AuthService[Auth Service :8001]
        Nginx -->|/api/courses/*| CourseService[Course Service :8002]
        Nginx -->|/api/content/*| ContentService[Content Service :8003]
        Nginx -->|/api/quizzes/*| QuizService[Quiz Service :8004]
    end

    subgraph Datastores & Storage
        AuthService -->|Postgres| DB_Auth[(auth_db)]
        CourseService -->|Postgres| DB_Course[(course_db)]
        QuizService -->|Postgres| DB_Quiz[(quiz_db)]
        ContentService -->|Postgres| DB_Content[(content_db)]
        
        CourseService -->|Cache| RedisCache[(Redis)]
        QuizService -->|Cache| RedisCache
        
        ContentService -->|Upload/Presign| S3Storage[(MinIO / AWS S3)]
    end
```

### Technology Stack
- **Frontend**: React, Vite, TypeScript, TailwindCSS, Lucide Icons, Recharts.
- **Backend**: Python, FastAPI, SQLAlchemy (2.0), Pydantic (V2).
- **Datastores**: PostgreSQL (relational database), Redis (session & cache).
- **Storage**: MinIO (local S3-compatible) / AWS S3 (production).
- **Gateway / Proxy**: Nginx.
- **Containerization**: Docker, Docker Compose.

---

## Microservices Breakdown

### 1. Auth Service (Port 8001)
Responsible for user account lifecycle, security, and access control.
- **Endpoints**:
  - `POST /auth/register` - Create a new user account (Student or Instructor).
  - `POST /auth/login` - Authenticate and return JWT access and refresh tokens.
  - `POST /auth/refresh` - Issue a new access token using a refresh token.
  - `GET /auth/me` - Fetch the current authenticated user's profile.
  - `PUT /auth/me` - Update profile information.
  - `POST /auth/change-password` - Update account password.
  - `GET /auth/users` - Admin-only list of all registered users.

### 2. Course Service (Port 8002)
Handles course catalog, modules, lessons, and student enrollment records.
- **Endpoints**:
  - `GET /courses/` - List all published courses (supports search and category filters).
  - `POST /courses/` - Create a new course (Instructor/Admin only).
  - `GET /courses/{id}` - Fetch course details, including module and lesson metadata.
  - `PUT /courses/{id}` - Update course details (Instructor/Admin only).
  - `POST /courses/{id}/enroll` - Enroll in a course (Student/Instructor/Admin).
  - `GET /courses/enrolled/me` - List courses the current user is enrolled in.
  - `POST /courses/{id}/modules` - Add a module to a course (Instructor/Admin only).
  - `POST /courses/modules/{id}/lessons` - Add a lesson to a module (Instructor/Admin only).

### 3. Content Service (Port 8003)
Manages file uploads (videos, PDFs, images) to S3/MinIO and generates secure pre-signed URLs.
- **Endpoints**:
  - `POST /content/upload` - Upload raw files (Instructor/Admin only).
  - `GET /content/url/{media_id}` - Generate a temporary secure pre-signed GET URL for course material consumption.
  - `DELETE /content/{media_id}` - Delete a file from S3 and metadata from DB (Instructor/Admin only).
  - `GET /content/my-files` - List files uploaded by the current instructor.

### 4. Quiz & Progress Service (Port 8004)
Tracks lesson completion, administers quizzes, grades attempts, and issues certificates.
- **Endpoints**:
  - `POST /quizzes/` - Create a quiz for a course (Instructor/Admin only).
  - `GET /quizzes/course/{course_id}` - List quizzes for a course.
  - `GET /quizzes/{id}` - Fetch quiz questions (automatically hides correct answers for students).
  - `POST /quizzes/{id}/questions` - Add questions and options (Instructor/Admin only).
  - `POST /quizzes/{id}/submit` - Submit quiz answers for grading (grades instantly, auto-issues certificate on passing).
  - `POST /quizzes/progress` - Mark a lesson as completed.
  - `GET /quizzes/progress/completed` - List completed lesson IDs for the current student.
  - `GET /quizzes/certificates/me` - List certificates earned by the current student.

---

## Local Development (Getting Started)

### Prerequisites
- [Docker](https://www.docker.com/products/docker-desktop) (with Docker Compose)

### Running the Stack
1. Clone the repository and navigate to the root directory:
   ```bash
   cd EduSphere
   ```
2. Start all services in the background using Docker Compose:
   ```bash
   docker-compose up --build -d
   ```
3. Once the build completes and services are healthy:
   - Access the **EduSphere Frontend** at `http://localhost`.
   - Access **MinIO Object Storage Console** at `http://localhost:9001` (Credentials: `minioadmin` / `minioadmin`).
   - The API Swagger documentations are available at:
     - Auth Service: `http://localhost/api/auth/docs`
     - Course Service: `http://localhost/api/courses/docs`
     - Content Service: `http://localhost/api/content/docs`
     - Quiz Service: `http://localhost/api/quizzes/docs`

---

## Testing

Each microservice contains a unit and integration test suite using `pytest` and an in-memory SQLite database.

To run tests locally for a service (e.g., Auth Service):
1. Navigate to the service directory:
   ```bash
   cd services/auth-service
   ```
2. Create and activate a virtual environment, install requirements, and run pytest:
   ```bash
   python -m venv venv
   source venv/bin/activate  # Or venv\Scripts\activate on Windows
   pip install -r requirements.txt
   pytest
   ```

---

## Production & Cloud Deployment (DevOps Ready)

EduSphere is designed to be easily deployed to public clouds (such as AWS) using modern DevOps tooling.

### 1. Kubernetes & Helm
Preconfigured directories are provided under `kubernetes/` and `helm/` for orchestrating the application on a Kubernetes cluster (e.g., AWS EKS):
- Deployments, Services, ConfigMaps, Secrets, Ingress, and Horizontal Pod Autoscalers (HPA).
- A unified Helm chart is located under [helm/edusphere](file:///e:/Projects/EduSphere/helm/edusphere) to deploy the entire stack with a single command:
  ```bash
  helm install edusphere ./helm/edusphere -f values.yaml
  ```

### 2. Infrastructure as Code (Terraform)
Located under [infrastructure/terraform](file:///e:/Projects/EduSphere/infrastructure/terraform):
- Provisions AWS EKS (Elastic Kubernetes Service).
- Provisions AWS RDS (PostgreSQL) and AWS ElastiCache (Redis) instances.
- Provisions AWS S3 Buckets for secure course media storage.
- Configures IAM Roles for Service Accounts (IRSA) to grant secure S3 access to the `content-service` pod.

### 3. CI/CD (GitHub Actions & Argo CD)
- GitHub Actions workflows under `.github/workflows/` automate building Docker images, running tests, pushing to Amazon ECR, and updating Helm values.
- Ready for GitOps deployment via **Argo CD** by pointing to the `kubernetes/` or `helm/` directory.

### 4. Observability (Prometheus, Grafana, Loki)
The application is pre-instrumented for monitoring:
- Health check endpoints (`/health`) are exposed on all microservices.
- Docker Compose includes logging configurations ready to be scraped by Promtail and aggregated in Grafana Loki.
