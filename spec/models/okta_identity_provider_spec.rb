# == Schema Information
#
# Table name: okta_identity_providers
# Database name: primary
#
#  id                   :uuid             not null, primary key
#  okta_domain          :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  identity_provider_id :uuid             not null
#
# Indexes
#
#  index_okta_identity_providers_on_identity_provider_id  (identity_provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (identity_provider_id => identity_providers.id)
#
require 'rails_helper'

RSpec.describe OktaIdentityProvider, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
