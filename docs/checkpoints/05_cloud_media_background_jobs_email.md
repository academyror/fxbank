# Checkpoint 05: Media Storage, Background Workers & Transactional Email

- **Branch:** [`section/05-cloud-media-background-jobs-email`](https://github.com/academyror/fxbank/tree/section/05-cloud-media-background-jobs-email)
- **Tag:** `v0.5-section-5`
- **Course Lesson:** Section 5 at [rubyonrails.academy](https://www.rubyonrails.academy)

---

## Key Architectural Decisions

1. **Active Storage Direct-to-Cloud Uploads**:
   - Eliminated Puma web thread starvation by streaming multi-megabyte KYC ID documents and user avatars directly to object storage.
   - Enforced strict MIME type validations (PDF, PNG, JPEG) and size limits (15MB).

2. **Solid Queue Asynchronous Workers**:
   - Modern database-backed job queue eliminating Redis operational overhead.
   - `TransferNotificationJob`: Dispatches dual email notifications to sender and recipient outside the transaction block.
   - `KycVerificationJob`: Asynchronous compliance identity check.

3. **Action Mailer**:
   - `TransferMailer`: Transaction confirmation (`transfer_sent`) and credit notification (`transfer_received`) templates in HTML and plain-text.

---

## File Highlights in This Checkpoint

- `app/jobs/transfer_notification_job.rb` & `app/jobs/kyc_verification_job.rb`
- `app/mailers/transfer_mailer.rb`
- `app/views/transfer_mailer/`
- `app/controllers/kyc_verifications_controller.rb` & `app/views/kyc_verifications/`
- `config/queue.yml`
- `db/migrate/20260901000005_create_active_storage_tables.active_storage.rb`
- `db/migrate/20260901000006_create_solid_queue_tables.rb`
