class Views::Patients::Show < Views::Base
  def initialize(patient:)
    @patient = patient
  end

  def view_template
  end
end
