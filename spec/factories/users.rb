# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                  :uuid             not null, primary key
#  email_address       :string           not null
#  failed_login_count  :integer          default(0), not null
#  first_name          :string           not null
#  last_name           :string           not null
#  original_first_name :string           not null
#  original_last_name  :string           not null
#  password_digest     :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
FactoryBot.define do
  factory :user do
    original_first_name { "Alice" }
    original_last_name { "Smith" }
    first_name { original_first_name.downcase }
    last_name { original_last_name.downcase }
    email_address { "#{first_name}.#{last_name}@example.com".downcase }
    password { "The-quick-brown-fox-8-a-bird" }

    factory :another_user do
      sequence(:original_first_name) { |n| "User_#{n}" }
      original_last_name { "Jones" }
    end

    factory :dr_sue do
      original_first_name { "Sue" }
      original_last_name { "Smith" }
    end
  end
end
