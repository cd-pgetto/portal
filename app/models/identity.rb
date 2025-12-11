# == Schema Information
#
# Table name: identities
# Database name: primary
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  identity_provider_id :uuid             not null
#  provider_user_id     :string           not null
#  user_id              :uuid             not null
#
# Indexes
#
#  index_identities_on_identity_provider_id  (identity_provider_id)
#  index_identities_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (identity_provider_id => identity_providers.id)
#  fk_rails_...  (user_id => users.id)
#
class Identity < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :identity_provider

  validates :provider_user_id, presence: true
end
