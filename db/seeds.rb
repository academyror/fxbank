# frozen_string_literal: true

puts "== Seeding FxBank Demo Data (Section 3) =="

# Clean existing records
Transfer.delete_all
Account.delete_all
User.delete_all

# 1. Create Demo Users with Devise credentials
admin = User.create!(
  email: "admin@fxbank.io",
  password: "Password123!",
  password_confirmation: "Password123!",
  first_name: "Eleanor",
  last_name: "Vance",
  phone_number: "+1-555-0100",
  kyc_status: "verified",
  role: "admin"
)
admin.confirm

alice = User.create!(
  email: "alice@fxbank.io",
  password: "Password123!",
  password_confirmation: "Password123!",
  first_name: "Alice",
  last_name: "Smith",
  phone_number: "+1-555-0101",
  kyc_status: "verified",
  role: "customer"
)
alice.confirm

bob = User.create!(
  email: "bob@fxbank.io",
  password: "Password123!",
  password_confirmation: "Password123!",
  first_name: "Bob",
  last_name: "Jones",
  phone_number: "+1-555-0102",
  kyc_status: "verified",
  role: "customer"
)
bob.confirm

charlie = User.create!(
  email: "charlie@fxbank.io",
  password: "Password123!",
  password_confirmation: "Password123!",
  first_name: "Charlie",
  last_name: "Vance",
  phone_number: "+1-555-0103",
  kyc_status: "pending",
  role: "customer"
)
charlie.confirm

puts "Created #{User.count} users (Admin Eleanor, Alice, Bob, Charlie)"

# 2. Create Accounts
alice_checking = Account.create!(
  user: alice,
  account_number: "FX-100001",
  balance_cents: 250_000, # $2,500.00
  currency: "USD",
  status: "active"
)

alice_savings = Account.create!(
  user: alice,
  account_number: "FX-100002",
  balance_cents: 1_000_000, # $10,000.00
  currency: "USD",
  status: "active"
)

bob_checking = Account.create!(
  user: bob,
  account_number: "FX-200001",
  balance_cents: 75_000, # $750.00
  currency: "USD",
  status: "active"
)

charlie_checking = Account.create!(
  user: charlie,
  account_number: "FX-300001",
  balance_cents: 10_000, # $100.00
  currency: "USD",
  status: "active"
)

puts "Created #{Account.count} accounts with initial balances"

# 3. Seed Transfers via TransferService
Transfers::TransferService.call(
  from_account: alice_checking,
  to_account: bob_checking,
  amount_cents: 25_000, # $250.00
  description: "Consulting invoice #1042",
  idempotency_key: "seed-tx-001"
)

Transfers::TransferService.call(
  from_account: bob_checking,
  to_account: alice_checking,
  amount_cents: 5_000, # $50.00
  description: "Coffee & lunch split",
  idempotency_key: "seed-tx-002"
)

puts "Executed #{Transfer.count} seed transfers successfully."
puts "Alice Checking Balance: #{alice_checking.reload.formatted_balance}"
puts "Bob Checking Balance: #{bob_checking.reload.formatted_balance}"
puts "== Seeding complete =="
