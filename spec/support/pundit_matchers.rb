# frozen_string_literal: true

RSpec::Matchers.define :permit_action do |action|
  match do |policy|
    policy.public_send(:"#{action}?")
  end

  failure_message do |policy|
    "expected #{policy.class.name} to permit #{action} for #{policy.user.inspect}, but it was forbidden"
  end

  failure_message_when_negated do |policy|
    "expected #{policy.class.name} to forbid #{action} for #{policy.user.inspect}, but it was permitted"
  end
end

RSpec::Matchers.define :forbid_action do |action|
  match do |policy|
    !policy.public_send(:"#{action}?")
  end

  failure_message do |policy|
    "expected #{policy.class.name} to forbid #{action} for #{policy.user.inspect}, but it was permitted"
  end

  failure_message_when_negated do |policy|
    "expected #{policy.class.name} to permit #{action} for #{policy.user.inspect}, but it was forbidden"
  end
end
