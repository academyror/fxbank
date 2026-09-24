# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ledger::ReconciliationAuditJob do
  let(:asset_acc) { create(:ledger_account, name: "Fed Clearing USD", code: "1000", account_type: "asset", currency: "USD", cached_balance_subunits: 0) }
  let(:liab_acc) { create(:ledger_account, name: "Customer Alice", code: "2000", account_type: "liability", currency: "USD", cached_balance_subunits: 0) }

  before do
    Ledger::PostingService.post(
      description: "Initial deposit",
      entries: [
        { account: asset_acc, entry_type: "debit", amount_subunits: 10_000 },
        { account: liab_acc, entry_type: "credit", amount_subunits: 10_000 }
      ]
    )
  end

  it "reports zero drift when cached balance matches computed entry sum" do
    report = described_class.new.perform
    expect(report[:drift_detected]).to be false
    expect(report[:discrepancies]).to be_empty
    expect(report[:accounts_checked]).to be >= 2
  end

  it "detects balance drift when cached balance is altered without entry" do
    liab_acc.update_columns(cached_balance_subunits: 8_000)

    report = described_class.new.perform
    expect(report[:drift_detected]).to be true
    expect(report[:discrepancies].first[:account_code]).to eq("2000")
    expect(report[:discrepancies].first[:drift_subunits]).to eq(2_000)
  end
end
