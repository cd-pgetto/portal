class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = false
  def show? = false
  def create? = false
  def new? = create?
  def update? = false
  def edit? = update?
  def destroy? = false

  private

  def system_admin? = user&.system_admin?
  def organization_admin? = user&.organization_admin?
  def user_organization_id = user&.organization_membership&.organization_id
end
