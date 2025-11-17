# frozen_string_literal: true

# Lockable submodule for Authenticable
# Tracks consecutive failed login attempts
# Prevents logins to an account for a period after reaching a threshold of consecutive login failures
module Lockable
  extend ActiveSupport::Concern

  # rubocop:disable Lint/ConstantDefinitionInBlock
  included do
    LOCK_OUT_FAILED_ATTEMPTS = 10
    LOCK_OUT_DURATION = 5.minutes
  end
  # rubocop:enable Lint/ConstantDefinitionInBlock

  class_methods do
  end

  def increment_failed_login_count!
    increment!(:failed_login_count)
  end

  def reset_failed_login_count!
    update_attribute(:failed_login_count, 0)
  end

  def locked?
    too_many_failed_sign_in_attempts? && !lock_out_expired?
  end

  def too_many_failed_sign_in_attempts?
    failed_login_count >= LOCK_OUT_FAILED_ATTEMPTS
  end

  def lock_out_expired?
    updated_at + LOCK_OUT_DURATION <= Time.current
  end
end
