# FxBank &mdash; Section 7: Zero-Downtime Deployment, Monitoring & Day-2 Operations

Welcome to **FxBank**, a production-grade digital banking SaaS platform built with Ruby on Rails 7.2+, PostgreSQL, Tailwind CSS, and Hotwire.

This repository accompanies **Course 1: Building a Modern SaaS Banking Application** at [Ruby on Rails Academy (rubyonrails.academy)](https://www.rubyonrails.academy).

---

## 📌 Section 7 Overview

In Section 7, we take FxBank from localhost to cloud production servers with zero-downtime containerized deployments and enterprise observability:
- **Multi-Stage Production Dockerfile**:
  - Compiles assets and gems in a disposable build stage.
  - Generates a minimal, hardened Debian-slim runtime image (~180MB) running as a non-root `rails` user.
  - Optimizes memory usage with `jemalloc` (`LD_PRELOAD`).
- **Kamal 2 Deployment Automation**:
  - `config/deploy.yml`: Zero-downtime rolling updates, Traefik/Kamal-proxy SSL termination, and background worker orchestration.
- **Docker Compose (`docker-compose.yml`)**:
  - Local multi-container environment running PostgreSQL 16, Puma web threads, and Solid Queue dispatchers.
- **Production Observability & Reliability**:
  - Sentry exception monitoring configured with PII sanitization.
  - Lograge structured JSON logs for Datadog, ELK, or Papertrail ingestion.
  - Automated PostgreSQL backup script (`bin/db_backup.sh`) with retention policies.
  - System health check `/up` endpoint.

---

## 🐳 Running with Docker Compose

To boot the complete application locally using Docker:

```bash
# Build and run containers (web, postgres, solid_queue)
docker compose up --build

# Run migrations inside container
docker compose exec web bin/rails db:prepare db:seed

# Access the application
open http://localhost:3000
```

---

## 🚀 Deploying to Production with Kamal 2

```bash
# Deploy to production servers
kamal setup
kamal deploy
```

---

## 📚 Full Course & Interactive Curriculum

To access the complete step-by-step video lessons, quizzes, and community mentorship:  
👉 **[https://www.rubyonrails.academy](https://www.rubyonrails.academy)**
