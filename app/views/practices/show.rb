# frozen_string_literal: true

class Views::Practices::Show < Views::Base
  def initialize(practice:)
    @practice = practice
  end

  def view_template
    content_for :title, @practice.name

    div(class: "practice-show w-full px-8") do
      div(class: "patients-list flex justify-between items-center gap-4 mb-2") do
        h1(class: "font-bold text-2xl") { "Patients" }
        a(href: send(:new_patient_path), class: "btn btn-primary") { "New" }
      end

      table(class: "table table-md text-left") do
        thead do
          tr(class: "border-b border-base-content") do
            th { "Patient Number" }
            th { "Chart Number" }
            th(class: "text-center") { "Scans" }
            th(class: "text-center") { "Models" }
            th(class: "text-center") { "Plans" }
          end
        end

        tbody do
          @practice.patients.each do |patient|
            tr do
              td {
                a(href: patient_path(patient), class: "link link-primary") {
                  patient.patient_number
                }
              }
              td { patient.chart_number }
              td(class: "text-center") { 0 }
              td(class: "text-center") { patient.dental_models_count }
              td(class: "text-center") { 0 }
            end
          end
        end
      end
    end
  end
end
