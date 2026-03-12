class DedicatedIdentityProvider < IdentityProvider
  belongs_to :organization

  validates :organization, presence: true

  def dedicated? = true
end
