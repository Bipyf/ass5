
# Assignment 5 — DevOps & CI/CD (Python + Docker + Jenkins)

This repository is a **minimal, exam‑friendly** example of a CI/CD pipeline for a research project.
It uses a *simple Python script* (no external data) to keep the focus on pipeline automation.

## What’s inside

```
.
├── budget_analyzer.py       # simple Python "research" script
├── requirements.txt         # minimal deps (pytest)
├── Dockerfile               # containerizes the script
├── Jenkinsfile              # CI pipeline: test → build image → (optional) push → (optional) deploy
├── deploy.sh                # simple "CD" script that runs the container locally
└── tests/
    └── test_budget.py       # unit test
```

> You can push this folder to GitHub/GitLab and point Jenkins to the repo.
> The pipeline works on every commit.

---

## Quick start (local, without Jenkins)

1. **Run unit tests**:
   ```bash
   python -m venv .venv && . .venv/bin/activate
   pip install -r requirements.txt
   pytest -q
   ```

2. **Build & run the container**:
   ```bash
   docker build -t expetra/budget-analyzer:local .
   ./deploy.sh
   docker logs budget-analyzer
   ```

You should see output like:
```
TOTAL_EXPENSES=350.5
```
(Change the numbers inside `budget_analyzer.py` to see different results.)

---

## Jenkins CI/CD — Step-by-step

### Prerequisites
- A machine with **Docker** installed.
- **Jenkins** (LTS) with access to Docker:
  ```bash
  docker run -d --name jenkins --restart unless-stopped     -p 8080:8080 -p 50000:50000     -v jenkins_home:/var/jenkins_home     -v /var/run/docker.sock:/var/run/docker.sock     jenkins/jenkins:lts
  ```
  Then open `http://<server-ip>:8080`, unlock Jenkins, and install recommended plugins.

> Mounting the Docker socket lets Jenkins run `docker build/push`. If you use agents, make sure the agent has Docker CLI.

### 1) Create pipeline job

- **New Item → Pipeline** → name it `expetra-assignment5`.
- In **Pipeline** section choose **Pipeline script from SCM** and paste your repo URL.
- Keep the default `Jenkinsfile` path.

### 2) (Optional) Webhook trigger from GitHub

- In Jenkins job: **Build Triggers → GitHub hook trigger for GITScm polling**.
- In GitHub repo: **Settings → Webhooks → Add webhook**:
  - Payload URL: `http://<server-ip>:8080/github-webhook/`  
  - Content type: `application/json`
  - Just the `push` event.
- Make sure Jenkins can reach GitHub and vice versa (open ports).

### 3) (Optional) Docker Hub credentials

- Jenkins: **Manage Jenkins → Credentials → (global)** → **Add Credentials**:
  - Kind: *Username with password*,
  - ID: `dockerhub-creds` (must match the `credentialsId` in `Jenkinsfile`),
  - Fill username/password.
- Also update `DOCKER_IMAGE` in `Jenkinsfile` to your Docker Hub namespace, e.g. `yourname/budget-analyzer`.

### 4) Run the pipeline

- Click **Build Now**. Stages:
  1. **Checkout** code
  2. **Install deps** (`pip install -r requirements.txt`)
  3. **Run tests** (`pytest -q`)
  4. **Docker build** (`docker build ...`)
  5. **(Optional) Docker push** (if credentials present)
  6. **(Optional) Deploy** (`./deploy.sh` on the Jenkins node)

You can toggle Push/Deploy via environment variables or by removing the stages from the `Jenkinsfile`.

---

## GitHub Actions (Optional Alternative)

Create `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install -r requirements.txt
      - run: pytest -q
  docker:
    needs: build-test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t ghcr.io/${{ github.repository }}:latest .
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - run: docker push ghcr.io/${{ github.repository }}:latest
```
This builds/tests, then pushes the image to **GitHub Container Registry**.
