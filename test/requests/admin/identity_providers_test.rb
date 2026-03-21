require "test_helper"

class Admin::IdentityProvidersTest < ActionDispatch::IntegrationTest
  let(:valid_attributes) {
    {strategy: "google", name: "Google", icon_url: "google-icon.jpg",
     client_id: "some-client-id", client_secret: "some-client-secret"}
  }
  let(:invalid_attributes) {
    {strategy: "", name: "", icon_url: "", client_id: "", client_secret: ""}
  }

  before { sign_in_as_admin }

  describe "GET /admin/identity_providers" do
    it "renders a successful response" do
      get admin_identity_providers_url
      assert_response :success
    end

    it "lists all identity providers" do
      idp = IdentityProvider::Shared.create!(valid_attributes)
      get admin_identity_providers_url
      assert_includes response.body, idp.name
    end
  end

  describe "GET /admin/identity_providers/:id" do
    it "renders a successful response" do
      idp = IdentityProvider::Shared.create!(valid_attributes)
      get admin_identity_provider_url(idp)
      assert_response :success
    end
  end

  describe "GET /admin/identity_providers/new" do
    it "renders a successful response" do
      get new_admin_identity_provider_url
      assert_response :success
    end
  end

  describe "GET /admin/identity_providers/:id/edit" do
    it "renders a successful response" do
      idp = IdentityProvider::Shared.create!(valid_attributes)
      get edit_admin_identity_provider_url(idp)
      assert_response :success
    end
  end

  describe "POST /admin/identity_providers" do
    describe "with valid parameters" do
      it "creates a new IdentityProvider" do
        assert_difference -> { IdentityProvider.count }, 1 do
          post admin_identity_providers_url, params: {identity_provider: valid_attributes}
        end
      end

      it "redirects to the created identity provider with a flash" do
        post admin_identity_providers_url, params: {identity_provider: valid_attributes}
        assert_redirected_to admin_identity_provider_url(IdentityProvider.order(:created_at).last)
        follow_redirect!
        assert_includes response.body, "Identity provider was successfully created."
      end
    end

    describe "with invalid parameters" do
      it "does not create a new IdentityProvider" do
        assert_no_difference -> { IdentityProvider.count } do
          post admin_identity_providers_url, params: {identity_provider: invalid_attributes}
        end
      end

      it "renders a 422 response" do
        post admin_identity_providers_url, params: {identity_provider: invalid_attributes}
        assert_response :unprocessable_content
      end
    end
  end

  describe "PATCH /admin/identity_providers/:id" do
    let(:new_attributes) {
      {strategy: "facebook", name: "Facebook", icon_url: "fb-icon.jpg",
       client_id: "fb-client-id", client_secret: "fb-client-secret"}
    }

    describe "with valid parameters" do
      it "updates the requested identity provider" do
        idp = IdentityProvider::Shared.create!(valid_attributes)
        patch admin_identity_provider_url(idp), params: {identity_provider: new_attributes}
        idp.reload
        assert_equal "facebook", idp.strategy
        assert_equal "Facebook", idp.name
        assert_equal "fb-icon.jpg", idp.icon_url
      end

      it "redirects to the identity provider with a flash" do
        idp = IdentityProvider::Shared.create!(valid_attributes)
        patch admin_identity_provider_url(idp), params: {identity_provider: new_attributes}
        assert_redirected_to admin_identity_provider_url(idp)
        follow_redirect!
        assert_includes response.body, "Identity provider was successfully updated."
      end
    end

    describe "with invalid parameters" do
      it "renders a 422 response" do
        idp = IdentityProvider::Shared.create!(valid_attributes)
        patch admin_identity_provider_url(idp), params: {identity_provider: invalid_attributes}
        assert_response :unprocessable_content
      end
    end
  end

  describe "DELETE /admin/identity_providers/:id" do
    it "destroys the requested identity provider" do
      idp = IdentityProvider::Shared.create!(valid_attributes)
      assert_difference -> { IdentityProvider.count }, -1 do
        delete admin_identity_provider_url(idp)
      end
    end

    it "redirects to the list with a flash" do
      idp = IdentityProvider::Shared.create!(valid_attributes)
      delete admin_identity_provider_url(idp)
      assert_redirected_to admin_identity_providers_url
      follow_redirect!
      assert_includes response.body, "Identity provider was successfully destroyed."
    end
  end
end
