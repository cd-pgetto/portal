# == Schema Information
#
# Table name: identity_providers
#
#  id            :bigint           not null, primary key
#  availability  :enum             default("shared"), not null
#  client_secret :string           not null
#  icon_url      :string           not null
#  name          :string           not null
#  strategy      :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :string           not null
#
# Indexes
#
#  index_identity_providers_on_strategy                (strategy) UNIQUE WHERE (availability = 'shared'::availability)
#  index_identity_providers_on_strategy_and_client_id  (strategy,client_id) UNIQUE
#
class IdentityProvider < ApplicationRecord
  enum :availability, {shared: "shared", dedicated: "dedicated"}

  scope :shared, -> { where(availability: :shared) }
  scope :dedicated, -> { where(availability: :dedicated) }

  validates :name, presence: true
  validates :icon_url, presence: true
  validates :strategy, presence: true, uniqueness: {conditions: -> { shared }}
  validates :client_id, presence: true, uniqueness: {scope: :strategy}
  validates :client_secret, presence: true
end
