RSpec::Matchers.define :have_validation_error_of_kind do |attribute, type|
  match do |actual|
    actual.valid?
    actual.errors.of_kind?(attribute, type || :invalid)
  end
end
