require "test_helper"

class Graphical::DentalModelsTest < ActionDispatch::IntegrationTest
  let(:practice) { create(:practice_with_org) }
  let(:patient) { create(:patient, practice: practice) }
  let(:dental_model) { create(:dental_model, patient: patient) }
  let(:user) { create(:another_user) }

  before {
    dental_model
    create(:practice_member, practice: practice, user: user)
  }

  describe "when not signed in" do
    it "redirects to sign in page" do
      get graphical_dental_model_url(dental_model)
      assert_redirected_to new_session_path
    end
  end

  describe "when signed in as a non-practice member" do
    let(:other_user) { create(:another_user) }
    before { sign_in_as(other_user, USER_PASSWORD) }

    it "is not authorized" do
      get graphical_dental_model_url(dental_model)
      assert_redirected_to home_path
      assert_includes flash[:alert], "You are not authorized"
    end
  end

  describe "when signed in as a practice member" do
    before { sign_in_as(user, USER_PASSWORD) }

    describe "GET /graphical/dental_models/:id" do
      it "renders a successful response" do
        get graphical_dental_model_url(dental_model)
        assert_response :success
      end
    end
  end
end
