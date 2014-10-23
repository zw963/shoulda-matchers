require 'shoulda/matchers'
require 'shoulda/matchers/active_model'
require 'shoulda/matchers/active_record'
require 'shoulda/matchers/action_controller'

Shoulda::Matchers.assertion_error_class = ActiveSupport::TestCase::Assertion

ActiveSupport::TestCase.class_eval do
  include Shoulda::Matchers::Independent
end
