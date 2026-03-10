require "rails_helper"

RSpec.describe "/patients", type: :request do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:user) { create(:user, organization: organization, practices: [practice]) }
  let(:patient) { create(:patient, practice: practice) }

  context "when not signed in" do
    it "redirects to sign in page" do
      get patients_url
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when signed in as a non-practice member" do
    let(:other_user) { create(:another_user) }

    before { sign_in_as(other_user, attributes_for(:user)[:password]) }

    it "is not authorized to access the index" do
      get patients_url
      expect(response).to redirect_to(home_path)
      expect(flash[:alert]).to include("You are not authorized")
    end

    it "is not authorized to create a patient" do
      post patients_url
      expect(response).to redirect_to(home_path)
      expect(flash[:alert]).to include("You are not authorized")
    end
  end

  context "when signed in as a practice member" do
    before { sign_in_as(user, attributes_for(:user)[:password]) }

    describe "GET /index" do
      it "renders a successful response" do
        patient
        get patients_url
        expect(response).to be_successful
      end

      it "lists only patients from the current practice" do
        own_patient = create(:patient, practice: practice)
        other_practice = create(:practice_with_org)
        other_patient = create(:patient, practice: other_practice)
        get patients_url
        expect(response.body).to include(own_patient.patient_number)
        expect(response.body).not_to include(other_patient.patient_number)
      end
    end

    describe "GET /show" do
      it "renders a successful response" do
        get patient_url(patient)
        expect(response).to be_successful
      end
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_patient_url
        expect(response).to be_successful
      end
    end

    describe "DELETE /destroy" do
      it "is not authorized (practice members cannot destroy patients)" do
        patient
        delete patient_url(patient)
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to include("You are not authorized")
      end
    end
  end
end
