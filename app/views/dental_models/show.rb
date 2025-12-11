class Views::DentalModels::Show < Views::Base
  def initialize(dental_model:)
    @dental_model = dental_model
  end

  def view_template
    h1 { "DentalModels::Show" }
    p { "Find me in app/views/dental_models/show.rb" }
  end
end
