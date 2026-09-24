# frozen_string_literal: true

module Ledger
  class ReconciliationAuditJob < ApplicationJob
    queue_as :maintenance

    def perform
      audit_report = {
        audited_at: Time.current,
        accounts_checked: 0,
        drift_detected: false,
        discrepancies: []
      }

      # 1. Verify every ledger account cached balance matches historical entry sum
      LedgerAccount.find_each do |account|
        audit_report[:accounts_checked] += 1
        true_balance = account.computed_balance_subunits
        cached = account.cached_balance_subunits

        if true_balance != cached
          drift_amount = true_balance - cached
          audit_report[:drift_detected] = true
          audit_report[:discrepancies] << {
            account_id: account.id,
            account_code: account.code,
            cached_balance: cached,
            computed_balance: true_balance,
            drift_subunits: drift_amount,
            currency: account.currency
          }
          Rails.logger.error("[LedgerAudit] DRIFT DETECTED on #{account.code}: Cached=#{cached}, True=#{true_balance}")
        end
      end

      # 2. Verify all journals satisfy the zero-sum invariant
      unbalanced_journals = find_unbalanced_journals
      if unbalanced_journals.any?
        audit_report[:drift_detected] = true
        audit_report[:unbalanced_journals] = unbalanced_journals
        Rails.logger.error("[LedgerAudit] CRITICAL: #{unbalanced_journals.count} unbalanced journals detected in database!")
      end

      # 3. Alert operations if discrepancies were detected
      if audit_report[:drift_detected]
        notify_operations_team(audit_report)
      else
        Rails.logger.info("[LedgerAudit] Nightly audit clean: #{audit_report[:accounts_checked]} accounts verified with zero drift.")
      end

      audit_report
    end

    private

    def find_unbalanced_journals
      # Query journals where debit sum != credit sum
      sql = <<~SQL
        SELECT ledger_journal_id, currency,
               SUM(CASE WHEN entry_type = 'debit' THEN amount_subunits ELSE -amount_subunits END) as net_balance
        FROM ledger_entries
        GROUP BY ledger_journal_id, currency
        HAVING SUM(CASE WHEN entry_type = 'debit' THEN amount_subunits ELSE -amount_subunits END) != 0;
      SQL

      ActiveRecord::Base.connection.select_all(sql).to_a
    end

    def notify_operations_team(report)
      Rails.logger.error("[LedgerAudit ALERT] Operations alerted: #{report.to_json}")
    end
  end
end
