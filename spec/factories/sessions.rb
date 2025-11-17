# == Schema Information
#
# Table name: sessions
# Database name: primary
#
#  id         :uuid             not null, primary key
#  ip_address :string
#  user_agent :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :session do
    user
    ip_address { "192.168.1.1" }
    user_agent { "Mozilla/5.0" }
  end
end
