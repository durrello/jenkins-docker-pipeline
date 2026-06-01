# jenkins-docker-pipeline

A complete **Jenkins CI/CD pipeline** that pulls an app from Git, builds a Docker image, runs tests,
pushes to a registry, and sends **Slack notifications** — with Jenkins itself running in Docker.
Reference implementation for the Jenkins pipeline project.

## What's here

```
.
├── docker-compose.yml   # Jenkins running in Docker (with Docker-in-Docker access)
├── Dockerfile           # builds the app image (Nginx serving a static site)
├── Jenkinsfile          # declarative pipeline: build → test → push → notify
├── test.sh              # smoke test run inside the pipeline
└── app/index.html       # sample app content
```

## Pipeline stages (Jenkinsfile)

```
Checkout → Build image → Test → Push to Docker Hub → Slack notify (success/failure)
```

## Run Jenkins locally

```bash
docker compose up -d
# Jenkins at http://localhost:8080
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Install the **Docker Pipeline** and **Slack Notification** plugins, then create a Pipeline job
pointing at this repo.

## Required Jenkins credentials

| ID | Type | Purpose |
|----|------|---------|
| `dockerhub` | Username/password | Push images to Docker Hub |
| `github-pat` | Secret text | Clone a private repo (if used) |
| `slack-token` | Secret text | Slack notifications |

## What this demonstrates

- Jenkins declarative pipelines with multiple stages
- Docker build + push from within a pipeline
- Automated testing as a gate before push
- Slack integration for build notifications (success and failure paths)
- Running Jenkins itself as a container

## Security notes

- All secrets (Docker Hub, GitHub, Slack) are stored in Jenkins credentials — never in the
  Jenkinsfile.
- For production, run agents separately from the controller and avoid mounting the host Docker
  socket; use a proper build agent or Kaniko instead.

## License

MIT
