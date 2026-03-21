# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                 :uuid             not null, primary key
#  email_address      :string           not null
#  failed_login_count :integer          default(0), not null
#  first_name         :string           not null
#  identities_count   :integer          default(0), not null
#  last_name          :string           not null
#  password_digest    :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
FactoryBot.define do
  factory :user do
    first_name { "Alice" }
    last_name { "Smith" }
    email_address { "#{first_name}.#{last_name}@example.com".downcase }
    password { "The-quick-brown-fox-8-a-bird" }

    factory :another_user do
      sequence(:first_name) { |n| "User_#{n}" }
      last_name { "Jones" }
    end

    factory :dr_sue do
      first_name { "Sue" }
      last_name { "Smith" }
    end

    factory :user_with_practice_and_org do
      organization
      practices { [build(:practice_with_org)] }
    end
  end
end
