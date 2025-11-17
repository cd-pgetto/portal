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
require "rails_helper"

RSpec.describe Identity, type: :model do
  subject { build(:identity) }

  describe "associations" do
    it { is_expected.to belong_to(:identity_provider) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:provider_user_id) }
  end
end
