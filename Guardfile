guard :minitest, spring: "bundle exec rails test", notification: false do
  # Test files — run directly when changed
  watch(%r{^test/(.+)_test\.rb$})

  # Support/helper changes — run all tests
  watch("test/test_helper.rb") { "test" }
  watch(%r{^test/support/(.+)\.rb$}) { "test" }
  watch(%r{^test/fixtures/(.+)\.yml$}) { "test" }

  # Models
  watch(%r{^app/models/(.+)\.rb$}) { |m| "test/models/#{m[1]}_test.rb" }

  # Controllers
  watch(%r{^app/controllers/(.+)_controller\.rb$}) { |m| "test/requests/#{m[1]}_test.rb" }
  watch(%r{^app/controllers/concerns/(.+)\.rb$}) { |m| "test/controllers/concerns/#{m[1]}_test.rb" }

  # Mailers
  watch(%r{^app/mailers/(.+)_mailer\.rb$}) { |m| "test/mailers/#{m[1]}_mailer_test.rb" }

  # Policies
  watch(%r{^app/policies/(.+)_policy\.rb$}) { |m| "test/policies/#{m[1]}_policy_test.rb" }

  # Views (Phlex .rb and ERB)
  watch(%r{^app/views/(.+)\.(rb|html\.erb)$}) { |m| "test/views/#{m[1]}_test.rb" }

  # Validators
  watch(%r{^app/validators/(.+)\.rb$}) { |m| "test/validators/#{m[1]}_test.rb" }

  # Routes
  watch("config/routes.rb") { "test/requests" }
end
