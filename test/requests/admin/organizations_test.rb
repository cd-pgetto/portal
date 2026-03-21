require "test_helper"

class Admin::OrganizationsTest < ActionDispatch::IntegrationTest
  let(:valid_attributes) { {name: "Test Org", subdomain: "test-org"} }
  let(:invalid_attributes) {
    {name: "", subdomain: "",
     dedicated_identity_provider_attributes: {
       type: "IdentityProvider::Okta", strategy: "okta", name: "invalid-idp-name",
       icon_url: "    ", client_id: "    ", client_secret: "", okta_domain: ""
     }}
  }

  before { sign_in_as_admin }

  describe "GET /admin/organizations" do
    it "renders a successful response" do
      create(:organization)
      get admin_organizations_url
      assert_response :success
    end

    it "lists all organizations" do
      org_a = create(:organization)
      org_b = create(:organization)
      get admin_organizations_url
      assert_includes response.body, org_a.name
      assert_includes response.body, org_b.name
    end
  end

  describe "GET /admin/organizations/:id" do
    it "renders a successful response" do
      org = create(:organization)
      get admin_organization_url(org)
      assert_response :success
    end
  end

  describe "GET /admin/organizations/new" do
    it "renders a successful response" do
      get new_admin_organization_url
      assert_response :success
    end
  end

  describe "GET /admin/organizations/:id/edit" do
    it "renders a successful response" do
      org = create(:organization)
      get edit_admin_organization_url(org)
      assert_response :success
    end
  end

  describe "POST /admin/organizations" do
    describe "with valid parameters" do
      it "creates a new Organization" do
        assert_difference -> { Organization.count }, 1 do
          post admin_organizations_url, params: {organization: valid_attributes}
        end
      end

      it "redirects to the created organization" do
        post admin_organizations_url, params: {organization: valid_attributes}
        assert_redirected_to admin_organization_url(Organization.order(:created_at).last)
      end
    end

    describe "with invalid parameters" do
      it "does not create a new Organization" do
        assert_no_difference -> { Organization.count } do
          post admin_organizations_url, params: {organization: invalid_attributes}
        end
      end

      it "renders a 422 response" do
        post admin_organizations_url, params: {organization: invalid_attributes}
        assert_response :unprocessable_content
        assert_includes response.body, "invalid-idp-name"
      end
    end
  end

  describe "PATCH /admin/organizations/:id" do
    describe "with valid parameters" do
      let(:share_identity_provider) {
        IdentityProvider.find_by(strategy: "google_oauth2") || create(:google_identity_provider)
      }
      let(:new_attributes) {
        {name: "new name", subdomain: "new-subdomain",
         shared_identity_provider_ids: [share_identity_provider.id],
         email_domains_attributes: [{domain_name: "example.com"}]}
      }

      it "updates the requested organization" do
        org = create(:organization)
        patch admin_organization_url(org), params: {organization: new_attributes}
        org.reload
        assert_equal "new name", org.name
        assert_equal "new-subdomain", org.subdomain
        assert_equal 1, org.identity_providers.count
        assert_equal "google_oauth2", org.identity_providers.first.strategy
        assert_equal 1, org.email_domains.count
        assert_equal "example.com", org.email_domains.first.domain_name
        assert_redirected_to admin_organization_url(org)
      end
    end

    describe "with invalid parameters" do
      it "renders a 422 response" do
        org = create(:organization)
        patch admin_organization_url(org), params: {organization: invalid_attributes}
        assert_response :unprocessable_content
      end
    end
  end

  describe "DELETE /admin/organizations/:id" do
    it "destroys the requested org" do
      org = create(:organization)
      assert_difference -> { Organization.count }, -1 do
        delete admin_organization_url(org)
      end
      assert_redirected_to admin_organizations_url
    end
  end
end
