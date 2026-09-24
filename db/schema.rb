# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_09_25_000011) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "account_number", null: false
    t.bigint "balance_cents", default: 0, null: false
    t.string "currency", default: "USD", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_type", default: "checking", null: false
    t.index ["account_number"], name: "index_accounts_on_account_number", unique: true
    t.index ["user_id", "currency", "account_type"], name: "index_accounts_on_user_currency_and_type", unique: true
    t.index ["user_id"], name: "index_accounts_on_user_id"
    t.check_constraint "balance_cents >= 0", name: "check_account_balance_non_negative"
    t.check_constraint "currency::text = ANY (ARRAY['USD'::character varying::text, 'EUR'::character varying::text, 'GBP'::character varying::text, 'JPY'::character varying::text, 'CHF'::character varying::text])", name: "check_accounts_supported_currency"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "fx_quotes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "from_currency", limit: 3, null: false
    t.string "to_currency", limit: 3, null: false
    t.bigint "source_amount_subunits", null: false
    t.bigint "target_amount_subunits", null: false
    t.decimal "market_rate", precision: 16, scale: 6, null: false
    t.decimal "spread_percent", precision: 5, scale: 2, default: "0.5", null: false
    t.decimal "effective_rate", precision: 16, scale: 6, null: false
    t.bigint "fee_subunits", default: 0, null: false
    t.datetime "expires_at", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_fx_quotes_on_expires_at"
    t.index ["status"], name: "index_fx_quotes_on_status"
    t.index ["user_id"], name: "index_fx_quotes_on_user_id"
  end

  create_table "fx_rates", force: :cascade do |t|
    t.string "from_currency", limit: 3, null: false
    t.string "to_currency", limit: 3, null: false
    t.decimal "rate", precision: 16, scale: 6, null: false
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_currency", "to_currency", "recorded_at"], name: "index_fx_rates_on_currencies_and_recorded_at"
  end

  create_table "ledger_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "account_type", null: false
    t.string "currency", limit: 3, null: false
    t.bigint "cached_balance_subunits", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_ledger_accounts_on_account_id"
    t.index ["code"], name: "index_ledger_accounts_on_code", unique: true
    t.index ["currency", "account_type"], name: "index_ledger_accounts_on_currency_and_account_type"
  end

  create_table "ledger_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ledger_journal_id", null: false
    t.uuid "ledger_account_id", null: false
    t.string "entry_type", null: false
    t.bigint "amount_subunits", null: false
    t.string "currency", limit: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ledger_account_id"], name: "index_ledger_entries_on_ledger_account_id"
    t.index ["ledger_journal_id"], name: "index_ledger_entries_on_ledger_journal_id"
    t.check_constraint "amount_subunits > 0", name: "check_ledger_entry_amount_positive"
    t.check_constraint "entry_type::text = ANY (ARRAY['debit'::character varying, 'credit'::character varying]::text[])", name: "check_ledger_entry_type"
  end

  create_table "ledger_journals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description", null: false
    t.string "reference_type"
    t.string "reference_id"
    t.string "status", default: "posted", null: false
    t.datetime "posted_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["posted_at"], name: "index_ledger_journals_on_posted_at"
    t.index ["reference_type", "reference_id"], name: "index_ledger_journals_on_reference_type_and_reference_id"
  end

  create_table "ledger_snapshots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ledger_account_id", null: false
    t.bigint "balance_subunits", null: false
    t.string "currency", limit: 3, null: false
    t.datetime "snapshot_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ledger_account_id", "snapshot_at"], name: "index_ledger_snapshots_on_ledger_account_id_and_snapshot_at"
    t.index ["ledger_account_id"], name: "index_ledger_snapshots_on_ledger_account_id"
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "from_account_id", null: false
    t.bigint "to_account_id", null: false
    t.bigint "amount_cents", null: false
    t.string "status", default: "pending", null: false
    t.string "idempotency_key"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "fx_quote_id"
    t.jsonb "metadata", default: {}, null: false
    t.index ["from_account_id"], name: "index_transfers_on_from_account_id"
    t.index ["fx_quote_id"], name: "index_transfers_on_fx_quote_id"
    t.index ["idempotency_key"], name: "index_transfers_on_idempotency_key", unique: true
    t.index ["metadata"], name: "index_transfers_on_metadata", using: :gin
    t.index ["to_account_id"], name: "index_transfers_on_to_account_id"
    t.check_constraint "amount_cents > 0", name: "check_transfer_amount_positive"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone_number"
    t.string "kyc_status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "role", default: "customer", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "fx_quotes", "users"
  add_foreign_key "ledger_accounts", "accounts"
  add_foreign_key "ledger_entries", "ledger_accounts"
  add_foreign_key "ledger_entries", "ledger_journals"
  add_foreign_key "ledger_snapshots", "ledger_accounts"
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "transfers", "accounts", column: "from_account_id"
  add_foreign_key "transfers", "accounts", column: "to_account_id"
  add_foreign_key "transfers", "fx_quotes"
end
