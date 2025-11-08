guard :rspec, cmd: "bundle exec rspec" do
  notification :off

  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  # rails = dsl.rails(view_extensions: %w[erb haml slim])
  rails = dsl.rails(view_extensions: %w[erb rb])
  dsl.watch_spec_files_for(rails.app_files)
  dsl.watch_spec_files_for(rails.views)

  # View component templates (html.erb only)
  watch(%r{^app/(components/.+).html.erb$}) { |m| "#{rspec.spec_dir}/#{m[1]}_spec.rb" }

  # Phlex view components (.rb files)
  watch(%r{^app/components/(.+)\.rb$}) { |m| "spec/components/#{m[1]}_spec.rb" }

  # Phlex view specs and controller specs for view components
  watch(%r{^app/views/(.+)\.rb$}) do |m|
    [
      "spec/views/#{m[1]}_spec.rb",
      "spec/requests/#{m[1].split("/")[0..-2].join("/")}_spec.rb"
    ]
  end

  watch(rails.controllers) do |m|
    [
      rspec.spec.call("routing/#{m[1]}_routing"),
      rspec.spec.call("controllers/#{m[1]}_controller"),
      rspec.spec.call("requests/#{m[1]}"),
      rspec.spec.call("acceptance/#{m[1]}"),
      rspec.spec.call("system/#{m[1]}_system")
    ]
  end

  # Rails config changes
  watch(rails.spec_helper) { rspec.spec_dir }
  watch(rails.routes) { "#{rspec.spec_dir}/routing" }
  watch(rails.app_controller) { "#{rspec.spec_dir}/controllers" }

  # Capybara features specs
  watch(rails.view_dirs) { |m| rspec.spec.call("features/#{m[1]}") }
  watch(rails.layouts) { |m| rspec.spec.call("features/#{m[1]}") }

  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$}) do |m|
    Dir[File.join("**/#{m[1]}.feature")][0] || "spec/acceptance"
  end
end
