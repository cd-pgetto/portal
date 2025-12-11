class Views::Graphical::DentalModels::Show < Views::Base
  def initialize(dental_model:)
    @dental_model = dental_model
  end

  def view_template
    canvas(class: "fixed top-0 left-0", data: {
      controller: "threejs",
      threejs_model_urls_value: model_urls.to_json
    }) {}
  end

  private

  def model_urls
    @dental_model.jaws.map { |jaw|
      jaw.teeth.includes(:crown_geometry_attachment).map { |tooth|
        rails_blob_path(tooth.crown_geometry) if tooth.crown_geometry.attached?
      }.compact
    }.flatten
  end
end
