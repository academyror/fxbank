# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transfers::FxExchangeService do
  let(:user) { create(:user) }
  let(:usd_account) { create(:account, user: user, currency: "USD", balance_cents: 50_000) } # $500.00
  let(:eur_account) { create(:account, user: user, currency: "EUR", balance_cents: 0) }

  let(:quote) do
    Fx::QuoteService.create_quote(
      user: user,
      from_currency: "USD",
      to_currency: "EUR",
      source_amount_subunits: 10_000 # $100.00
    )
  end

  describe ".call" do
    it "executes the multi-currency swap atomically" do
      result = described_class.call(source_account: usd_account, target_account: eur_account, quote: quote)

      expect(result[:success]).to be true
      expect(usd_account.reload.balance_cents).to eq(40_000)
      expect(eur_account.reload.balance_cents).to eq(quote.target_amount_subunits)
      expect(quote.reload.status).to eq("executed")

      transfer = result[:transfer]
      expect(transfer).to be_persisted
      expect(transfer.from_account).to eq(usd_account)
      expect(transfer.to_account).to eq(eur_account)
      expect(transfer.fx_quote).to eq(quote)
      expect(transfer.metadata["fx_quote_id"]).to eq(quote.id)
    end

    it "rejects execution if the quote has expired" do
      quote.update!(expires_at: 5.seconds.ago)

      result = described_class.call(source_account: usd_account, target_account: eur_account, quote: quote)

      expect(result[:success]).to be false
      expect(result[:error]).to include("expired")
      expect(usd_account.reload.balance_cents).to eq(50_000)
      expect(eur_account.reload.balance_cents).to eq(0)
    end

    it "rejects execution if source account has insufficient funds" do
      usd_account.update!(balance_cents: 5_000) # Only $50 available

      result = described_class.call(source_account: usd_account, target_account: eur_account, quote: quote)

      expect(result[:success]).to be false
      expect(result[:error]).to include("Insufficient funds")
      expect(usd_account.reload.balance_cents).to eq(5_000)
      expect(eur_account.reload.balance_cents).to eq(0)
      expect(quote.reload.status).to eq("pending")
    end

    it "rejects execution if account currencies do not match the quote contract" do
      gbp_account = create(:account, user: user, currency: "GBP", balance_cents: 10_000)

      result = described_class.call(source_account: gbp_account, target_account: eur_account, quote: quote)

      expect(result[:success]).to be false
      expect(result[:error]).to include("do not match quote")
      expect(quote.reload.status).to eq("pending")
    end
  end
end
