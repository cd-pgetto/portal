class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :practice
  delegate :user, to: :session, allow_nil: true
end
