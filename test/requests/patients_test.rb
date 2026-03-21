require "test_helper"

class PatientsTest < ActionDispatch::IntegrationTest
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:user) do
    u = create(:another_user)
    create(:organization_member, organization: organization, user: u)
    create(:practice_member, practice: practice, user: u)
    u.reload
  end
  let(:patient) { create(:patient, practice: practice) }

  describe "when not signed in" do
    it "redirects to sign in page" do
      get patients_url
      assert_redirected_to new_session_path
    end
  end

  describe "when signed in as a non-practice member" do
    let(:other_user) { create(:another_user) }
    before { sign_in_as(other_user, USER_PASSWORD) }

    it "is not authorized to access the index" do
      get patients_url
      assert_redirected_to home_path
      assert_includes flash[:alert], "You are not authorized"
    end

    it "is not authorized to create a patient" do
      post patients_url
      assert_redirected_to home_path
      assert_includes flash[:alert], "You are not authorized"
    end
  end

  describe "when signed in as a practice member" do
    before {
      practice
      sign_in_as(user, USER_PASSWORD)
    }

    describe "GET /patients" do
      it "renders a successful response" do
        patient
        get patients_url
        assert_response :success
      end

      it "lists only patients from the current practice" do
        own_patient = create(:patient, practice: practice)
        other_practice = create(:practice_with_org)
        other_patient = create(:patient, practice: other_practice)
        get patients_url
        assert_includes response.body, own_patient.patient_number
        assert_not_includes response.body, other_patient.patient_number
      end
    end

    describe "GET /patients/:id" do
      it "renders a successful response" do
        get patient_url(patient)
        assert_response :success
      end
    end

    describe "GET /patients/new" do
      it "renders a successful response" do
        get new_patient_url
        assert_response :success
      end
    end

    describe "DELETE /patients/:id" do
      it "is not authorized (practice members cannot destroy patients)" do
        patient
        delete patient_url(patient)
        assert_redirected_to home_path
        assert_includes flash[:alert], "You are not authorized"
      end
    end
  end
end
