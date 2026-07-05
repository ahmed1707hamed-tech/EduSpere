import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVICES = ("auth-service", "course-service", "content-service", "quiz-service", "notification-service", "api-gateway")


def main() -> int:
    failures = []
    for service in SERVICES:
        path = ROOT / "services" / service
        tests = path / "tests"
        if not tests.exists():
            continue
        result = subprocess.run([sys.executable, "-m", "pytest", "-q"], cwd=path, check=False)
        if result.returncode:
            failures.append(service)
    if failures:
        print("Failed services:", ", ".join(failures))
        return 1
    print("All service tests passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
