require "test_helper"

class Admin::PracticesTest < ActionDispatch::IntegrationTest
  let(:valid_attributes) { {organization_id: create(:organization).id, name: "My Practice"} }
  let(:invalid_attributes) { {name: nil, organization_id: nil} }

  before { sign_in_as_admin }

  describe "GET /admin/practices" do
    it "renders a successful response" do
      Practice.create!(valid_attributes)
      get admin_practices_url
      assert_response :success
    end

    it "lists all practices" do
      org = create(:organization)
      practice_a = Practice.create!(valid_attributes)
      practice_b = Practice.create!(name: "Another Practice", organization_id: org.id)
      get admin_practices_url
      assert_includes response.body, practice_a.name
      assert_includes response.body, practice_b.name
    end
  end

  describe "GET /admin/practices/:id" do
    it "renders a successful response" do
      practice = Practice.create!(valid_attributes)
      get admin_practice_url(practice)
      assert_response :success
    end
  end

  describe "GET /admin/practices/new" do
    it "renders a successful response" do
      get new_admin_practice_url
      assert_response :success
    end
  end

  describe "GET /admin/practices/:id/edit" do
    it "renders a successful response" do
      practice = Practice.create!(valid_attributes)
      get edit_admin_practice_url(practice)
      assert_response :success
    end
  end

  describe "POST /admin/practices" do
    describe "with valid parameters" do
      it "creates a new Practice" do
        assert_difference -> { Practice.count }, 1 do
          post admin_practices_url, params: {practice: valid_attributes}
        end
      end

      it "redirects to the created practice" do
        post admin_practices_url, params: {practice: valid_attributes}
        assert_redirected_to admin_practice_url(Practice.order(:created_at).last)
      end
    end

    describe "with invalid parameters" do
      it "does not create a new Practice" do
        assert_no_difference -> { Practice.count } do
          post admin_practices_url, params: {practice: invalid_attributes}
        end
      end

      it "renders a 422 response" do
        post admin_practices_url, params: {practice: invalid_attributes}
        assert_response :unprocessable_content
      end
    end
  end

  describe "PATCH /admin/practices/:id" do
    let(:new_attributes) { {name: "My Updated Practice"} }

    describe "with valid parameters" do
      it "updates the requested practice" do
        practice = Practice.create!(valid_attributes)
        patch admin_practice_url(practice), params: {practice: new_attributes}
        assert_equal "My Updated Practice", practice.reload.name
      end

      it "redirects to the practice" do
        practice = Practice.create!(valid_attributes)
        patch admin_practice_url(practice), params: {practice: new_attributes}
        assert_redirected_to admin_practice_url(practice)
      end
    end

    describe "with invalid parameters" do
      it "renders a 422 response" do
        practice = Practice.create!(valid_attributes)
        patch admin_practice_url(practice), params: {practice: invalid_attributes}
        assert_response :unprocessable_content
      end
    end
  end

  describe "DELETE /admin/practices/:id" do
    it "destroys the requested practice" do
      practice = Practice.create!(valid_attributes)
      assert_difference -> { Practice.count }, -1 do
        delete admin_practice_url(practice)
      end
    end

    it "redirects to the practices list" do
      practice = Practice.create!(valid_attributes)
      delete admin_practice_url(practice)
      assert_redirected_to admin_practices_url
    end
  end
end
