require 'rspec/core'
require 'byebug'

Dir[ File.join(File.expand_path('../support/acceptance_tests/**/*.rb', __FILE__)) ].each do |file|
  require file
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  if config.respond_to?(:infer_spec_type_from_file_location!)
    config.infer_spec_type_from_file_location!
  end

  AcceptanceTests::Helpers.configure_example_group(config)
  config.include AcceptanceTests::Matchers
end

$VERBOSE = true
