# Jenkins Docker Pipeline

> A complete Jenkins CI/CD pipeline that builds a Docker image, runs smoke tests, pushes to Docker Hub, and sends Slack notifications — with Jenkins itself running in Docker.

[![CI](https://github.com/durrello/jenkins-docker-pipeline/actions/workflows/ci.yml/badge.svg)](https://github.com/durrello/jenkins-docker-pipeline/actions/workflows/ci.yml)

## Problem Statement

Setting up a Jenkins CI/CD pipeline with Docker builds is a common requirement, but getting all the
pieces right — Docker-in-Docker access, credential management, automated testing gates, and
notifications — involves many moving parts. This repo provides a working reference implementation:
clone it, run `docker compose up`, and you have a fully functional pipeline locally in minutes.

## Architecture

```mermaid
flowchart LR
    subgraph Docker Host
        JK[Jenkins Container<br/>LTS JDK17]
        JK -->|mounts| DS[/var/run/docker.sock]
    end

    JK -->|1. Checkout| GH[GitHub Repo]
    JK -->|2. Build| IMG[Docker Image<br/>nginx:1.27-alpine + app]
    IMG -->|3. Smoke test| ST[Container on :8081<br/>curl → assert 200]
    ST -->|4. Push| DH[Docker Hub<br/>durrello/portfolio-app]
    JK -->|5. Notify| SL[Slack #ci<br/>✅ or ❌]
```

## Pipeline Stages

```
Checkout → Build Image → Test (smoke) → Push to Docker Hub → Slack Notify
```

| Stage | What happens |
|-------|-------------|
| **Checkout** | Pulls source from the configured SCM |
| **Build image** | `docker build` using the Dockerfile (nginx:1.27-alpine serving static content) |
| **Test** | Runs the container, curls localhost:8081, asserts HTTP 200 |
| **Push** | Tags with build number + `latest`, pushes to Docker Hub (main branch only) |
| **Notify** | Slack message to `#ci` — green for success, red for failure |

## Stack / Tools

| Tool | Purpose |
|------|---------|
| Jenkins LTS (JDK17) | CI/CD server |
| Docker + Docker Compose | Container runtime + local Jenkins environment |
| Nginx 1.27 Alpine | Base image for the app |
| Hadolint | Dockerfile linting (CI) |
| Slack Plugin | Build notifications |
| GitHub Actions | Lints Dockerfile + validates docker-compose on push/PR |

## Quick Start

```bash
# 1. Start Jenkins
docker compose up -d

# 2. Get the initial admin password
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# 3. Open Jenkins at http://localhost:8080
#    - Install suggested plugins + Docker Pipeline + Slack Notification plugins
#    - Create a Pipeline job pointing at this repo

# 4. Run the pipeline
#    Build → Test → Push (if on main) → Slack notification
```

## Required Jenkins Credentials

| ID | Type | Purpose |
|----|------|---------|
| `dockerhub` | Username/password | Push images to Docker Hub |
| `github-pat` | Secret text | Clone a private repo (if needed) |
| `slack-token` | Secret text | Slack notifications |

## Project Structure

```
.
├── .github/workflows/
│   └── ci.yml              # GitHub Actions: hadolint + docker-compose validate
├── app/
│   └── index.html          # Sample static app content
├── docker-compose.yml      # Jenkins in Docker (with Docker socket mount)
├── Dockerfile              # App image: nginx:1.27-alpine + static content
├── Jenkinsfile             # Declarative pipeline: build → test → push → notify
├── test.sh                 # Smoke test: run container, curl, assert 200
├── LICENSE
└── README.md
```

## Key Files Explained

### Dockerfile

```dockerfile
FROM nginx:1.27-alpine
COPY app/ /usr/share/nginx/html/
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost/ >/dev/null 2>&1 || exit 1
```

Lightweight image with a built-in health check.

### docker-compose.yml

Runs Jenkins with the host Docker socket mounted so pipelines can build images directly.
Exposes port 8080 (UI) and 50000 (agent connections).

### test.sh

Smoke test that starts the built image, waits 3 seconds, curls the container, and asserts an
HTTP 200 response. Uses `trap` for cleanup regardless of pass/fail.

## Security Notes

- All secrets (Docker Hub, GitHub, Slack) are stored in Jenkins credentials — never in the
  Jenkinsfile.
- The host Docker socket is mounted for this local demo. For production:
  - Run agents separately from the controller
  - Use Kaniko or a dedicated build agent instead of mounting the Docker socket
  - Enable RBAC and restrict pipeline access

## What This Demonstrates

- **Jenkins declarative pipelines** with multiple stages and conditional execution
- **Docker build + push** from within a pipeline (tagged with build number)
- **Automated testing as a gate** before pushing to a registry
- **Slack integration** for build notifications (success and failure paths)
- **Docker Compose** for running Jenkins itself as a container
- **Health checks** in Docker images
- **CI linting** with Hadolint and docker-compose validation

## Related

- [durrellgemuh.com](https://durrellgemuh.com) — Portfolio and blog
- [incident-response-runbooks](https://github.com/durrello/incident-response-runbooks) — SRE runbooks for when deploys go wrong

## License

MIT
