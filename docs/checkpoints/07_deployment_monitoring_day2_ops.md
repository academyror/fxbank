# Checkpoint 07: Zero-Downtime Deployment, Monitoring & Day-2 Operations

- **Branch:** [`section/07-deployment-monitoring-day2-ops`](https://github.com/academyror/fxbank/tree/section/07-deployment-monitoring-day2-ops)
- **Tag:** `v0.7-section-7`
- **Course Lesson:** Section 7 at [rubyonrails.academy](https://www.rubyonrails.academy)

---

## Key Architectural Decisions

1. **Multi-Stage Production Docker Build**:
   - Compiles native gems and frontend assets in a disposable build stage.
   - Minimal runtime image (~180MB) running as non-root `rails` user.
   - Memory optimization using `jemalloc` (`LD_PRELOAD`).

2. **Kamal 2 Deployment Automation**:
   - Zero-downtime rolling container updates, automated Traefik/Kamal-proxy SSL certificates, and PostgreSQL accessory configuration.

3. **Production Observability & Reliability**:
   - **Lograge**: Structured JSON logs capturing request IDs, IP addresses, execution durations, and parameters.
   - **Sentry**: Application exception tracking with default PII sanitization.
   - **Automated Backups**: `bin/db_backup.sh` with timestamping, gzip compression, and 7-day retention cleanup.

---

## File Highlights in This Checkpoint

- `Dockerfile` (Multi-stage) & `.dockerignore`
- `docker-compose.yml`
- `config/deploy.yml` (Kamal 2)
- `config/initializers/sentry.rb`
- `config/initializers/lograge.rb`
- `bin/db_backup.sh`
- `spec/requests/health_spec.rb`
