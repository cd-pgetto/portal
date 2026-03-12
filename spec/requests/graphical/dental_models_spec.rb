require "rails_helper"

RSpec.describe "Graphical::DentalModels", type: :request do
  let(:practice) { create(:practice_with_org) }
  let(:patient) { create(:patient, practice: practice) }
  let(:dental_model) { create(:dental_model, patient: patient) }
  let(:user) { create(:user) }

  before { create(:practice_member, practice: practice, user: user) }

  context "when not signed in" do
    it "redirects to sign in page" do
      get graphical_dental_model_url(dental_model)
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when signed in as a non-practice member" do
    let(:other_user) { create(:another_user) }

    before { sign_in_as(other_user, attributes_for(:user)[:password]) }

    it "is not authorized" do
      get graphical_dental_model_url(dental_model)
      expect(response).to redirect_to(home_path)
      expect(flash[:alert]).to include("You are not authorized")
    end
  end

  context "when signed in as a practice member" do
    before { sign_in_as(user, attributes_for(:user)[:password]) }

    describe "GET /show" do
      it "renders a successful response" do
        get graphical_dental_model_url(dental_model)
        expect(response).to be_successful
      end
    end
  end
end
