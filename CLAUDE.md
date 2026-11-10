# Claude Code CLI Guidelines

This project operates within a **Docker-out-of-Docker (DooD)** setup. The Claude Code CLI runs inside a container that has access to the host's Docker socket, allowing it to manage other Docker containers.

## Project Requirements

Whenever a new project is created or initialized using this environment, it must adhere to the following standards to ensure seamless integration and containerized execution:

### 1. Dockerfile
Every project must include a `Dockerfile` that defines the necessary runtime environment for the application.

### 2. Docker Compose
A `docker-compose.yaml` file must be provided. It should:
- Mount the source code as a volume to allow for live updates and persistent storage.
- Define the services required for building and running the application.
- (Recommended) Attach services to the `claude` network to allow the CLI to communicate with them directly.

Example `docker-compose.yaml` snippet:
```yaml
services:
  app:
    build: .
    volumes:
      - .:/app
    working_dir: /app
    networks:
      - claude

networks:
  claude:
    external: true
```

### 3. Containerized Execution
All build, test, and run commands must be executed inside a container (typically via `docker compose run` or `docker compose exec`). This ensures that the host system remains clean and dependencies are managed consistently.

---
*Note: This file serves as a guide for the Claude Code CLI and developers working within this environment.*