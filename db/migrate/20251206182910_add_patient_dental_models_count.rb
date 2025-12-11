class AddPatientDentalModelsCount < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :dental_models_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        Patient.find_each { |patient| Patient.reset_counters(patient.id, :dental_models) }
      end
    end
  end
end
