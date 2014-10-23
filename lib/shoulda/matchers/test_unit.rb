require 'shoulda/matchers'

Shoulda::Matchers.assertion_error_class = Test::Unit::AssertionFailedError

Test::Unit::TestCase.class_eval do
  include Shoulda::Matchers::Independent
end
